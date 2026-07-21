# Svon — Reactive MoonBit Templates

A fine-grained reactive signal system + template compiler inspired by [Svelte 5](https://svelte.dev). Write `.svon` templates with MoonBit code, compile to JavaScript.

```html
<script lang="moonbit">
let name = $state("")
let agreed = $state(false)
let selected = $state("a")
let volume_val = $state("50")
let show = $state(false)
let time_val = $state("0")
let speed = $state("1.0")
let paused = $state(true)
let muted = $state(false)
let html = $state("<b>edit</b>")
let dim = $state(0)
let mut el : DomNode? = None
let count=$state(0)
</script>

<div>
  <h1>Bindings Demo</h1>

  <h2>input bind:value</h2>
  <input bind:value={name.get()} placeholder="type here"/>
  <p>You typed: {name.get()}</p>

  <h2>checkbox bind:checked</h2>
  <label><input type="checkbox" bind:checked={agreed.get()}/> I agree</label>
  <p>Agreed: {agreed.get().to_string()}</p>

  <h2>radio bind:value</h2>
  <label><input type="radio" name="sel" bind:group={selected.get()} checked value="a"/> A</label>
  <label><input type="radio" name="sel" bind:group={selected.get()} value="b"/> B</label>
  <label><input type="radio" name="sel" bind:group={selected.get()} value="c"/> C</label>
  <p>Selected: {selected.get()}</p>

  <h2>range bind:value</h2>
  <input type="range" min="0" max="100" bind:value={volume_val.get()}/>
  <p>Volume: {volume_val.get()}</p>

  <h2>details bind:open</h2>
  <details bind:open={show.get()}>
    <summary>Toggle me</summary>
    <p>Content shown: {show.get().to_string()}</p>
  </details>

  <!-- <h2>bind:currentTime + bind:playbackRate + bind:paused + bind:volume + bind:muted</h2>
  <p>These work on audio/video elements (JS runtime only).</p> -->

  <h2>bind:this (DOM reference)</h2>
  <p id="ref-para" bind:this={el}>This paragraph has bind:this</p>
  <p>The reference is captured at mount time.</p>
  <button onclick={fn(){count.set(count.get()+1)}}>+</button>
  {#for i in 0..=count.get()}
    {
      match el{
        Some(e)=>@svon.dom_debug(e)
        None=>"no";
      }
    }
  {/for}
</div>



<style>
  body { font-family: system-ui, sans-serif; max-width: 700px; margin: 2rem auto; padding: 0 1rem; }
  h2 { margin-top: 1.5rem; color: #333; }
  input, select, textarea { padding: 4px 8px; margin: 4px 0; }
  label { display: flex; align-items: center; gap: 4px; margin: 4px 0; }
  [contenteditable] { outline: none; }
</style>
```

![generated page](.\README\page.png)

## Architecture

```
.svon template    svonc compiler     MoonBit source    moon build         Browser
┌──────────┐     ┌──────────┐     ┌────────────┐     ┌──────────┐     ┌──────┐
│ <script> │ ──▶ │ parser   │ ──▶ │ fn main {  │ ──▶ │ app.js   │ ──▶ │ DOM  │
│ <style>  │     │ codegen  │     │  $state()  │     │          │     │      │
│ <div>..  │     └──────────┘     │  $derived()│     └──────────┘     └──────┘
└──────────┘                      └────────────┘
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
#compiled to ./out/
svonc build

# Serve, you may use python to manually open a simple server in current time
python3 -m http.server 8080
```

Open `http://localhost:8080` and navigate to `cmd/site/index.html`.

## Template Syntax

### Script block

```html
<script lang="moonbit">
let count = $state(0)                          // reactive state
let doubled = $derived(fn() { count.get() * 2 })   // computed value
let _ = $effect(fn() {                         // side-effect
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

| Feature | Syntax | Svelte equivalent |
|---------|--------|-------------------|
| State | `let x = $state(v)` | `let x = $state(v)` |
| Computed | `let d = $derived(fn)` | `let d = $derived(fn)` |
| Effect | `$effect(fn() { ... Option::None })` | `$effect(() => { ... })` |
| Read | `.get()` | direct access |
| Write | `.set(v)` | `x = v` |
| Expression | `{expr}` | `{expr}` |
| Event | `onclick={fn}` | `onclick={fn}` |
| Style | `<style>...</style>` | `<style>...</style>` |

## CLI Reference

```bash
svonc <file.svon>           # compile to stdout (MoonBit source)
svonc new <name>             # scaffold a new project
svonc dev                    # serve current directory hint
svonc --help                 # show help
```

## License

Apache-2.0
