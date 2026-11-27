# swift-shader

Use this package to write a kernel, code that runs at every place of a grid over buffers, once in Swift. Conform to `Shader.Kernel` and read and write through `Shader.Buffer`. `run(over:)` runs it on the CPU; swift-shader-compiler writes it in a GPU's language.

## Laws

- `run(over:)` visits every place of the grid once, row by row, on the calling thread.
- A buffer's elements lie `Element.stride` bytes apart, least significant byte first, in the layout of the same vector in Metal's shading language: 16 bytes for `SIMD4<Float>` and `SIMD2<UInt64>`, 8 for `SIMD4<Float16>`.
- A buffer does not check its bounds and does not keep its memory alive: making one over memory is `unsafe`.
- Built with `-D SHADER`, a buffer is a number instead of memory, and its reads and writes are calls to `load` and `store` of the WebAssembly module `shader`, and `Shader.result(_:)` to its `result`. That build is a shader compiler's input and nothing else.
- For a compiler, the number must be known when the code is compiled: a kernel's buffers are made in its entry, and code that reads them must be inlined there.
- An entry is a function exported for C: `kernel_<name>` takes the place's column and row, and `function_<name>` takes and gives scalars, or gives a vector through `Shader.result(_:)`.

## Textures and stages that draw

- `Shader.Texture` is read at a place, sampled between places, and written at a place. On the CPU it lies over a buffer of `SIMD4<Float>`, row by row. A point to sample is in the texture's own measure: the place in column `c` and row `r` has its middle at `(c + 0.5, r + 0.5)`; the four places around the point are weighed by nearness, and a point beyond the edge reads the edge.
- A `Shader.Vertex` gives a `Shader.Corner` for each corner of each triangle: a position in clip space, and a `Shader.Handed` of two vectors that vary over the triangle and one of whole numbers that does not. A `Shader.Fragment` gives a colour for a pixel's middle and what was handed on.
- Built with `-D SHADER`, an entry `vertex_<name>` takes the corner's and the instance's number and calls `Shader.give(_:)`; an entry `fragment_<name>` takes the pixel's middle as two `Float`, reads `Shader.Handed.taken`, and calls `Shader.result(_:)`. A texture is then the number it is bound at, apart from the buffers' numbers.

## Shader WebGPU

`Shader WebGPU` sends kernels and stages to a page's GPU from WebAssembly. `Shader.WebGPU.Texture` is a texture the page holds; `Shader.WebGPU.Stage` is a vertex and a fragment stage as one pipeline with a `Shader.WebGPU.Blend`; `Shader.WebGPU.Pass.begin(_:clear:)` opens a run of draws into a texture or the canvas. Draws and dispatches run in the order they are sent.

## Shader Metal

`Shader Metal` runs compiled kernels on Apple's GPU: `Shader.Metal.Library` makes the device, its queues and the kernels from Metal text, `Shader.Metal.Kernel.dispatch` encodes one over a grid, `Shader.Metal.Pool` keeps buffers between passes, and `Shader.Metal.Timing` counts each kernel's GPU time.

- Kernels are compiled with Metal's normal maths (`MTLMathMode.relaxed`): fused multiply-add and reordering are allowed, infinities and NaN are kept. A kernel's result may differ from `run(over:)` in its last bits.
- A kernel's time is the GPU's start and end of commands that run it alone. A renderer given a `Timing` sends each kernel alone and waits for it, so a timed run is slower than an untimed one; it is for choosing what to make faster.
- An encoder's label is the name of the last kernel dispatched on it.
