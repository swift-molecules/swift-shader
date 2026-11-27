public import Shader

extension Shader.WebGPU {
    /// The JavaScript that gives a module its `shader_webgpu` imports, as an ES module. A page calls
    /// `webgpu(device, canvas, exports, options)` with a `GPUDevice`, a canvas or nil, and a function that gives the
    /// module's exports once it is made, and passes `.imports` to `WebAssembly.instantiate` under `shader_webgpu`.
    ///
    /// A frame reaches the canvas in one of two ways. `Shader.WebGPU.show(at:columns:rows:)` draws encoded pixels that
    /// lie on the heap into the canvas's texture of the frame the page is in, with a pass of its own: the canvas is
    /// configured in the browser's preferred format and needs nothing more, so this works wherever WebGPU does. With
    /// `options.storage` the canvas is configured as `rgba8unorm` that a kernel may write, for a kernel that writes a
    /// whole frame itself, such as Picture Shader's `present`; not every browser gives a canvas such a texture.
    ///
    /// The canvas is opaque unless `options.alpha` is `"premultiplied"`: the page then shows through where a pixel's
    /// alpha is below one, and the colours written must already be multiplied by their alpha.
    ///
    /// Submits and reads run in the order the module sends them. One that names a kernel not compiled yet waits for
    /// it, and every one after it waits behind it; `ready()` is the promise that every kernel is compiled.
    public static let script: Swift.String = #"""
        export function webgpu(device, canvas, exports, options = {}) {
          const memory = () => exports().memory;
          const context = canvas ? canvas.getContext("webgpu") : null;
          const format = options.storage ? "rgba8unorm" : navigator.gpu.getPreferredCanvasFormat();
          const usage = GPUTextureUsage.RENDER_ATTACHMENT | (options.storage ? GPUTextureUsage.STORAGE_BINDING : 0);
          if (context) context.configure({ device, format, usage, alphaMode: options.alpha === "premultiplied" ? "premultiplied" : "opaque" });
          const painting = `
            struct Frame { place: u32, columns: u32, rows: u32, unused: u32 }
            @group(0) @binding(0) var<storage, read> heap: array<u32>;
            @group(0) @binding(1) var<uniform> frame: Frame;
            @vertex fn corner(@builtin(vertex_index) index: u32) -> @builtin(position) vec4<f32> {
              return vec4<f32>(f32((index << 1u) & 2u) * 2.0 - 1.0, 1.0 - f32(index & 2u) * 2.0, 0.0, 1.0);
            }
            @fragment fn pixel(@builtin(position) at: vec4<f32>) -> @location(0) vec4<f32> {
              let x = min(u32(at.x), frame.columns - 1u);
              let y = min(u32(at.y), frame.rows - 1u);
              let word = heap[frame.place + y * frame.columns + x];
              return vec4<f32>(f32((word >> 16u) & 255u), f32((word >> 8u) & 255u), f32(word & 255u), f32(word >> 24u)) / 255.0;
            }`;
          let painter = null, framed = null;
          const paint = (place, columns, rows) => {
            if (!context || !heap || columns < 1 || rows < 1) return;
            if (!painter) {
              const module = device.createShaderModule({ code: painting });
              painter = device.createRenderPipeline({ layout: "auto", vertex: { module, entryPoint: "corner" }, fragment: { module, entryPoint: "pixel", targets: [{ format }] } });
              framed = device.createBuffer({ size: 16, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
            }
            device.queue.writeBuffer(framed, 0, new Uint32Array([place, columns, rows, 0]));
            const group = device.createBindGroup({ layout: painter.getBindGroupLayout(0), entries: [{ binding: 0, resource: { buffer: heap } }, { binding: 1, resource: { buffer: framed } }] });
            const encoder = device.createCommandEncoder();
            const pass = encoder.beginRenderPass({ colorAttachments: [{ view: context.getCurrentTexture().createView(), loadOp: "clear", clearValue: { r: 0, g: 0, b: 0, a: 0 }, storeOp: "store" }] });
            pass.setPipeline(painter);
            pass.setBindGroup(0, group);
            pass.draw(3);
            pass.end();
            device.queue.submit([encoder.finish()]);
          };
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
            show(place, columns, rows) {
              inOrder([], () => paint(place, columns, rows));
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
            const texture = context && work.some((one) => pipelines[one.kernel].writes) ? context.getCurrentTexture().createView() : null;
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
