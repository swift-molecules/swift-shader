public import Shader

extension Shader.WebGPU {
    /// The JavaScript that gives a module its `shader_webgpu` imports, as an ES module. A page calls
    /// `webgpu(device, canvas, exports, options)` with a `GPUDevice`, a canvas or nil, and a function that gives the
    /// module's exports once it is made, and passes `.imports` to `WebAssembly.instantiate` under `shader_webgpu`. The
    /// canvas is configured as `rgba8unorm`, for a kernel that writes a whole frame, such as Picture Shader's `present`;
    /// each submit writes into the canvas's texture of that frame. The canvas is opaque unless `options.alpha` is
    /// `"premultiplied"`: the page then shows through where a pixel's alpha is below one, and the kernel must write
    /// colours already multiplied by their alpha, as `present` does.
    ///
    /// Submits and reads run in the order the module sends them. One that names a kernel not compiled yet waits for
    /// it, and every one after it waits behind it; `ready()` is the promise that every kernel is compiled.
    public static let script: Swift.String = #"""
        export function webgpu(device, canvas, exports, options = {}) {
          const memory = () => exports().memory;
          const context = canvas ? canvas.getContext("webgpu") : null;
          if (context) context.configure({ device, format: "rgba8unorm", usage: GPUTextureUsage.STORAGE_BINDING, alphaMode: options.alpha === "premultiplied" ? "premultiplied" : "opaque" });
          const pipelines = [];
          let heap = null;
          const image = device.createBuffer({ size: 16, usage: GPUBufferUsage.STORAGE });
          const stride = 256;
          let uniform = null, capacity = 0;
          let pending = [];
          let behind = null;
          const inOrder = (needs, run) => {
            if (!behind && needs.every((made) => made.pipeline)) return run();
            const after = (behind ?? Promise.resolve()).then(() => Promise.all(needs.map((made) => made.ready))).then(run);
            const mine = after.catch(() => {}).then(() => { if (behind === mine) behind = null; });
            behind = mine;
          };
          const decoder = new TextDecoder();
          const text = (pointer, count) => decoder.decode(new Uint8Array(memory().buffer, pointer, count));
          const layoutOf = (code) => {
            const entries = [
              { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "storage" } },
              { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform", hasDynamicOffset: true } },
            ];
            const reads = code.includes("var<storage, read> image");
            const writes = code.includes("texture_storage_2d");
            if (reads) entries.push({ binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } });
            if (writes) entries.push({ binding: 3, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba8unorm" } });
            return { layout: device.createBindGroupLayout({ entries }), reads, writes };
          };
          const imports = {
            kernel(name, nameCount, code, codeCount) {
              const entry = text(name, nameCount), source = text(code, codeCount);
              const { layout, reads, writes } = layoutOf(source);
              const made = { layout, reads, writes, pipeline: null, group: null };
              made.ready = device.createComputePipelineAsync({
                layout: device.createPipelineLayout({ bindGroupLayouts: [layout] }),
                compute: { module: device.createShaderModule({ code: source }), entryPoint: entry },
              }).then((pipeline) => { made.pipeline = pipeline; });
              pipelines.push(made);
              return pipelines.length - 1;
            },
            reserve(words) {
              heap = device.createBuffer({ size: Math.max(words, 4) * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC });
              for (const made of pipelines) made.group = null;
            },
            write(place, pointer, count) {
              if (!behind) return device.queue.writeBuffer(heap, place * 4, memory().buffer, pointer, count * 4);
              const words = new Uint8Array(memory().buffer, pointer, count * 4).slice();
              inOrder([], () => device.queue.writeBuffer(heap, place * 4, words));
            },
            dispatch(kernel, columns, rows, bases) {
              const block = new Uint32Array(36);
              block.set([columns, rows, 0, 0], 0);
              block.set(new Uint32Array(memory().buffer, bases, 32), 4);
              pending.push({ kernel, columns, rows, block });
            },
            submit() {
              const work = pending;
              pending = [];
              if (work.length) inOrder(work.map((one) => pipelines[one.kernel]), () => send(work));
            },
            read(place, count, pointer, token) {
              const landed = (succeeded) => exports().shader_webgpu_landed(token, succeeded);
              inOrder([], () => {
                const size = Math.max(count, 1) * 4;
                const staging = device.createBuffer({ size, usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ });
                const encoder = device.createCommandEncoder();
                if (count > 0) encoder.copyBufferToBuffer(heap, place * 4, staging, 0, count * 4);
                device.queue.submit([encoder.finish()]);
                staging.mapAsync(GPUMapMode.READ).then(() => {
                  new Uint32Array(memory().buffer, pointer, count).set(new Uint32Array(staging.getMappedRange(0, size), 0, count));
                  staging.destroy();
                  landed(1);
                }, () => { staging.destroy(); landed(0); });
              });
            },
          };
          const send = (work) => {
            if (work.length > capacity) {
              capacity = Math.max(work.length, capacity * 2, 64);
              uniform = device.createBuffer({ size: capacity * stride, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
              for (const made of pipelines) made.group = null;
            }
            const blocks = new Uint32Array(work.length * stride / 4);
            work.forEach((one, place) => blocks.set(one.block, place * stride / 4));
            device.queue.writeBuffer(uniform, 0, blocks);
            const texture = context ? context.getCurrentTexture().createView() : null;
            const encoder = device.createCommandEncoder();
            const pass = encoder.beginComputePass();
            work.forEach((one, place) => {
              const made = pipelines[one.kernel];
              let group = made.group;
              if (!group || made.writes) {
                const entries = [{ binding: 0, resource: { buffer: heap } }, { binding: 1, resource: { buffer: uniform, size: 144 } }];
                if (made.reads) entries.push({ binding: 2, resource: { buffer: image } });
                if (made.writes) entries.push({ binding: 3, resource: texture });
                group = device.createBindGroup({ layout: made.layout, entries });
                if (!made.writes) made.group = group;
              }
              pass.setPipeline(made.pipeline);
              pass.setBindGroup(0, group, [place * stride]);
              pass.dispatchWorkgroups(Math.ceil(one.columns / 64), one.rows);
            });
            pass.end();
            device.queue.submit([encoder.finish()]);
          };
          return { imports, ready: () => Promise.all(pipelines.map((made) => made.ready)) };
        }
        """#
}
