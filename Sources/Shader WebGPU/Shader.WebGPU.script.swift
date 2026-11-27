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
    /// A stage draws in a pass: `Shader.WebGPU.Pass.begin(_:clear:)` opens one into a texture or into the canvas,
    /// and draws and dispatches run in the order they are sent. A stage reads `heap` and does not write it. A text
    /// names the textures it uses as `shader_texture<number>` in group 1, and the sampler in group 0 at binding 4.
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
          const stages = [];
          const textures = [];
          const formats = ["rgba16float", "r16float", "rgba8unorm", "rg16float"];
          const operations = ["add", "subtract", "reverse-subtract", "min", "max"];
          const factors = ["zero", "one", "src", "one-minus-src", "src-alpha", "one-minus-src-alpha", "dst", "one-minus-dst", "dst-alpha", "one-minus-dst-alpha"];
          const between = device.createSampler({ magFilter: "linear", minFilter: "linear", addressModeU: "clamp-to-edge", addressModeV: "clamp-to-edge" });
          let heap = null;
          const image = device.createBuffer({ size: 16, usage: GPUBufferUsage.STORAGE });
          const stride = 256;
          let uniform = null, capacity = 0;
          let pending = [];
          let behind = null;
          let open = null;
          const inOrder = (needs, run) => {
            if (!behind && needs.every((made) => made.pipeline)) return run();
            const after = (behind ?? Promise.resolve()).then(() => Promise.all(needs.map((made) => made.ready))).then(run);
            const mine = after.catch(() => {}).then(() => { if (behind === mine) behind = null; });
            behind = mine;
          };
          const decoder = new TextDecoder();
          const text = (pointer, count) => decoder.decode(new Uint8Array(memory().buffer, pointer, count));
          const layoutOf = (code, visibility, written) => {
            const entries = [
              { binding: 0, visibility, buffer: { type: written ? "storage" : "read-only-storage" } },
              { binding: 1, visibility, buffer: { type: "uniform", hasDynamicOffset: true } },
            ];
            const reads = code.includes("var<storage, read> image");
            const writes = code.includes("@group(0) @binding(3)");
            const samples = code.includes("@group(0) @binding(4)");
            if (reads) entries.push({ binding: 2, visibility, buffer: { type: "read-only-storage" } });
            if (writes) entries.push({ binding: 3, visibility, storageTexture: { access: "write-only", format: "rgba8unorm" } });
            if (samples) entries.push({ binding: 4, visibility, sampler: { type: "filtering" } });
            const used = new Map();
            for (const found of code.matchAll(/@group\(1\) @binding\((\d+)\) var shader_texture\d+: (texture_2d|texture_storage_2d)/g)) {
              used.set(Number(found[1]), found[2] === "texture_storage_2d");
            }
            const numbers = [...used.keys()].sort((a, b) => a - b);
            const second = numbers.length ? device.createBindGroupLayout({ entries: numbers.map((binding) => used.get(binding)
              ? { binding, visibility, storageTexture: { access: "write-only", format: "rgba16float" } }
              : { binding, visibility, texture: { sampleType: "float" } }) }) : null;
            const layouts = second ? [device.createBindGroupLayout({ entries }), second] : [device.createBindGroupLayout({ entries })];
            return { layouts, reads, writes, samples, numbers, pipeline: null, group: null, groups: new Map() };
          };
          const forget = () => { for (const made of [...pipelines, ...stages]) { made.group = null; made.groups.clear(); } };
          const block = (columns, rows, bases) => {
            const words = new Uint32Array(36);
            words.set([columns, rows, 0, 0], 0);
            words.set(new Uint32Array(memory().buffer, bases, 32), 4);
            return words;
          };
          const handles = (pointer) => pointer ? Array.from(new Int32Array(memory().buffer, pointer, 8)) : [];
          const imports = {
            kernel(name, nameCount, code, codeCount) {
              const entry = text(name, nameCount), source = text(code, codeCount);
              const made = layoutOf(source, GPUShaderStage.COMPUTE, true);
              made.ready = device.createComputePipelineAsync({
                layout: device.createPipelineLayout({ bindGroupLayouts: made.layouts }),
                compute: { module: device.createShaderModule({ code: source }), entryPoint: entry },
              }).then((pipeline) => { made.pipeline = pipeline; });
              pipelines.push(made);
              return pipelines.length - 1;
            },
            stage(texts, counts, state) {
              const sizes = new Int32Array(memory().buffer, counts, 4), states = new Int32Array(memory().buffer, state, 7);
              let from = texts;
              const [vertex, vertexCode, fragment, fragmentCode] = Array.from(sizes, (size) => { const one = text(from, size); from += size; return one; });
              const made = layoutOf(vertexCode + "\n" + fragmentCode, GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, false);
              const part = (at) => ({ operation: operations[states[at]], srcFactor: factors[states[at + 1]], dstFactor: factors[states[at + 2]] });
              made.ready = device.createRenderPipelineAsync({
                layout: device.createPipelineLayout({ bindGroupLayouts: made.layouts }),
                vertex: { module: device.createShaderModule({ code: vertexCode }), entryPoint: vertex },
                fragment: {
                  module: device.createShaderModule({ code: fragmentCode }), entryPoint: fragment,
                  targets: [{ format: states[0] < 0 ? format : formats[states[0]], blend: { color: part(1), alpha: part(4) } }],
                },
                primitive: { topology: "triangle-list" },
              }).then((pipeline) => { made.pipeline = pipeline; });
              stages.push(made);
              return stages.length - 1;
            },
            texture(columns, rows, kind) {
              const storage = kind === 0 ? GPUTextureUsage.STORAGE_BINDING : 0;
              const texture = device.createTexture({
                size: [Math.max(columns, 1), Math.max(rows, 1)], format: formats[kind],
                usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_SRC | GPUTextureUsage.COPY_DST | storage,
              });
              textures.push({ texture, view: texture.createView(), columns, rows });
              return textures.length - 1;
            },
            release(texture) {
              pending.push({ kind: "release", texture });
            },
            reserve(words) {
              heap = device.createBuffer({ size: Math.max(words, 4) * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC });
              forget();
            },
            write(place, pointer, count) {
              if (!behind) return device.queue.writeBuffer(heap, place * 4, memory().buffer, pointer, count * 4);
              const words = new Uint8Array(memory().buffer, pointer, count * 4).slice();
              inOrder([], () => device.queue.writeBuffer(heap, place * 4, words));
            },
            dispatch(kernel, columns, rows, bases, bound) {
              pending.push({ kind: "dispatch", made: pipelines[kernel], columns, rows, block: block(columns, rows, bases), textures: handles(bound) });
            },
            begin(target, clears, red, green, blue, alpha) {
              open = target < 0 ? { columns: canvas ? canvas.width : 1, rows: canvas ? canvas.height : 1 } : textures[target];
              pending.push({ kind: "begin", target, clear: clears ? { r: red, g: green, b: blue, a: alpha } : null, columns: open.columns, rows: open.rows });
            },
            draw(stage, counts, bases, bound) {
              const [vertices, instances, left, top, width, height] = new Int32Array(memory().buffer, counts, 6);
              const within = width < 0 ? null : [left, top, width, height];
              pending.push({ kind: "draw", made: stages[stage], vertices, instances, within, block: block(open ? open.columns : 0, open ? open.rows : 0, bases), textures: handles(bound) });
            },
            end() {
              open = null;
              pending.push({ kind: "end" });
            },
            submit() {
              const work = pending;
              pending = [];
              if (work.length) inOrder(work.filter((one) => one.made).map((one) => one.made), () => send(work));
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
            const blocked = work.filter((one) => one.block);
            if (blocked.length > capacity) {
              capacity = Math.max(blocked.length, capacity * 2, 64);
              uniform = device.createBuffer({ size: capacity * stride, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
              forget();
            }
            if (blocked.length) {
              const blocks = new Uint32Array(blocked.length * stride / 4);
              blocked.forEach((one, place) => blocks.set(one.block, place * stride / 4));
              device.queue.writeBuffer(uniform, 0, blocks);
            }
            const surface = context && work.some((one) => one.made && one.made.writes) ? context.getCurrentTexture().createView() : null;
            const first = (made) => {
              if (made.group && !made.writes) return made.group;
              const entries = [{ binding: 0, resource: { buffer: heap } }, { binding: 1, resource: { buffer: uniform, size: 144 } }];
              if (made.reads) entries.push({ binding: 2, resource: { buffer: image } });
              if (made.writes) entries.push({ binding: 3, resource: surface });
              if (made.samples) entries.push({ binding: 4, resource: between });
              const group = device.createBindGroup({ layout: made.layouts[0], entries });
              if (!made.writes) made.group = group;
              return group;
            };
            const second = (made, bound) => {
              const key = made.numbers.map((number) => bound[number]).join(",");
              let group = made.groups.get(key);
              if (!group) {
                group = device.createBindGroup({ layout: made.layouts[1], entries: made.numbers.map((number) => ({ binding: number, resource: textures[bound[number]].view })) });
                made.groups.set(key, group);
              }
              return group;
            };
            const encoder = device.createCommandEncoder();
            const released = [];
            let pass = null, computing = false, size = null, place = 0;
            const close = () => { if (pass) pass.end(); pass = null; computing = false; };
            for (const one of work) {
              if (one.kind === "release") { released.push(one.texture); continue; }
              if (one.kind === "end") { close(); continue; }
              if (one.kind === "begin") {
                close();
                const view = one.target < 0 ? context.getCurrentTexture().createView() : textures[one.target].view;
                pass = encoder.beginRenderPass({ colorAttachments: [{ view, loadOp: one.clear ? "clear" : "load", clearValue: one.clear ?? undefined, storeOp: "store" }] });
                size = [one.columns, one.rows];
                continue;
              }
              const made = one.made;
              if (one.kind === "dispatch" && !computing) { close(); pass = encoder.beginComputePass(); computing = true; }
              if (!pass || (one.kind === "draw" && computing)) { place += 1; continue; }
              pass.setPipeline(made.pipeline);
              pass.setBindGroup(0, first(made), [place * stride]);
              if (made.layouts.length > 1) pass.setBindGroup(1, second(made, one.textures));
              place += 1;
              if (one.kind === "dispatch") {
                pass.dispatchWorkgroups(Math.ceil(one.columns / 64), one.rows);
              } else {
                const within = one.within ?? [0, 0, size[0], size[1]];
                pass.setScissorRect(within[0], within[1], within[2], within[3]);
                pass.draw(one.vertices, one.instances);
              }
            }
            close();
            device.queue.submit([encoder.finish()]);
            for (const texture of released) {
              if (!textures[texture]) continue;
              textures[texture].texture.destroy();
              textures[texture] = null;
            }
            if (released.length) for (const made of [...pipelines, ...stages]) made.groups.clear();
          };
          return { imports, ready: () => Promise.all([...pipelines, ...stages].map((made) => made.ready)) };
        }
        """#
}
