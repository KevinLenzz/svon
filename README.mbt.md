# Svon — Reactive MoonBit Templates

A fine-grained reactive signal system + template compiler inspired by [Svelte 5](https://svelte.dev). Write `.svon` templates with MoonBit code, compile to JavaScript.

```html
<script lang="moonbit">
let count = state(0)
let doubled = derived(fn() { count.get() * 2 })
fn increment() { count.set(count.get() + 1) }
</script>

<style>
  h1 { color: #ff3e00; }
  button { font-size: 1.2rem; }
</style>

<h1>Count: {count.get()}</h1>
<p>Doubled: {doubled.get()}</p>
<button onclick={increment}>+</button>
```

## Architecture

```
.svon template    svonc compiler     MoonBit source    moon build         Browser
┌──────────┐     ┌──────────┐     ┌───────────┐     ┌──────────┐     ┌──────┐
│ <script> │ ──▶ │ parser   │ ──▶ │ fn main { │ ──▶ │ app.js   │ ──▶ │ DOM  │
│ <style>  │     │ codegen  │     │  state()  │     │          │     │      │
│ <div>..  │     └──────────┘     │  derived()│     └──────────┘     └──────┘
└──────────┘                      └───────────┘
```

| Layer | Source | Description |
|-------|--------|-------------|
| Signal runtime | `runtime.mbt`, `types.mbt`, `signal.mbt`, `state.mbt` | Dependency graph, dirtiness propagation, batched effects |
| DOM bindings | `dom.mbt` | `extern "js"` FFI — `document.createElement`, `textContent`, `addEventListener` |
| Template compiler | `compiler/` | Parses `.svon` → AST → MoonBit source |
| CLI | `cmd/compile/` | `svonc` — npm command-line tool |

## Quick Start

### Prerequisites

- [MoonBit toolchain](https://www.moonbitlang.com/download/) (`moon`/`mbt`)
- Node.js ≥ 18

### Install with npm

```bash
cd svon/cli && npm install -g .    # install svonc globally
```

### Create a project

```bash
svonc new my-app                    # scaffold a new project
cd my-app
```

```
my-app/
├── pages/
│   └── index.svon                  # starter template
├── moon.mod
└── README.md
```

### Compile and run

```bash
# Compile .svon → MoonBit source
svonc pages/index.svon > cmd/site/main.mbt

# Create moon.pkg
cat > cmd/site/moon.pkg << 'PKG'
import { "username/svon" @svon, }
supported_targets = "js"
options("is-main": true)
PKG

# Build JavaScript
moon build cmd/site --target js

# Serve
python3 -m http.server 8080
```

Open `http://localhost:8080` and navigate to `cmd/site/index.html`.

## Template Syntax

### Script block

```html
<script lang="moonbit">
let count = state(0)                          // reactive state
let doubled = derived(fn() { count.get() * 2 })   // computed value
let _ = effect(fn() {                         // side-effect
  ... 
  Option::None                                // no cleanup
})
fn handler() { count.set(count.get() + 1) }   // event handler
</script>
```

### Style block

```html
<style>
  h1 { color: #ff3e00; }
  .counter { background: white; border-radius: 8px; padding: 1rem; }
</style>
```

CSS is extracted at compile time and injected into the document `<head>` via a `<style>` element.

### HTML template

```html
<div>
  <h1>Counter: {count.get()}</h1>            <!-- expression interpolation -->
  <p class="label">{doubled.get()}</p>
  <button onclick={handler}>+</button>        <!-- event binding -->
</div>
```

| Feature | Syntax | Svelte equivalent |
|---------|--------|-------------------|
| State | `let x = state(v)` | `let x = $state(v)` |
| Computed | `let d = derived(fn)` | `let d = $derived(fn)` |
| Effect | `effect(fn() { ... Option::None })` | `$effect(() => { ... })` |
| Read | `.get()` | direct access |
| Write | `.set(v)` | `x = v` |
| Expression | `{expr}` | `{expr}` |
| Event | `onclick={fn}` | `onclick={fn}` |
| Style | `<style>...</style>` | `<style>...</style>` |

## Reactive API

```moonbit
// Create
let count = @svon.state(0)                   // State[Int]
let name  = @svon.state("Svon")              // State[String]

// Read (tracks dependency)
let v = count.get()
let v = @svon.read_source(count)

// Write (triggers propagation)
count.set(42)
@svon.write_source(count, 42)

// Computed (lazily recomputed, auto-tracks)
let d = @svon.derived(fn() { count.get() * 2 })
let v = @svon.read_derived(d)

// Side-effect (re-runs when deps change)
@svon.effect(fn() {
  println(count.get().to_string())
  Option::None
})

// Suppress dependency tracking
@svon.untrack(fn() { count.get() })
```

## CLI Reference

```bash
svonc <file.svon>           # compile to stdout (MoonBit source)
svonc new <name>             # scaffold a new project
svonc dev                    # serve current directory hint
svonc --help                 # show help
```

## Project Structure

```
svon/
├── compiler/                    # Template compiler (parser + codegen)
│   ├── parser.mbt               # .svon → AST
│   ├── codegen.mbt              # AST → MoonBit source
│   ├── compiler.mbt             # Public API: compile(), generate_project()
│   └── compiler_test.mbt        # 11 compiler tests
│
├── cmd/
│   └── compile/                 # svonc CLI (npm package)
│       └── main.mbt             # CLI implementation
│
├── runtime.mbt                  # Reactive runtime (dependency graph engine)
├── types.mbt                    # Reaction struct + bit flags
├── signal.mbt                   # Source / Derived / Effect structs
├── state.mbt                    # State[T] wrapper (.get / .set)
├── dom.mbt                      # DOM FFI bindings (js target)
├── svon.mbt                     # Public API facade
├── svon_test.mbt                # 8 reactive runtime tests
│
├── examples/                    # .svon template examples
│   ├── counter.svon             # Counter with deriveds
│   ├── hello.svon               # Hello world
│   ├── deepdom.svon             # Deep nested DOM + chained deriveds
│   └── test_suite.svon          # 6 pattern comprehensive test
│
├── cli/                         # npm package for svonc
├── vscode-extension/            # VS Code language support
└── moon.mod                     # MoonBit module configuration
```

## Testing

```bash
moon check          # type check — 0 errors
moon test           # 19 tests, all passing
moon test -v        # verbose output with test names
```

## License

Apache-2.0
