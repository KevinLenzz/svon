///|
/// DOM bindings — `extern "js"` FFI wrappers that map MoonBit calls
/// directly to browser DOM APIs.  Only available when compiling with
/// `--target js`; for native/wasm targets these functions do not exist
/// (the caller must guard with `#cfg(target="js")`).
///
/// `DomNode` is an opaque `#external` type — it cannot be constructed
/// or inspected from MoonBit; it is just a typed handle that the JS
/// backend treats as a plain DOM object reference.

///|
/// Opaque handle to a DOM `Element` or `Text` node.
#external
pub(all) type DomNode

///|
/// Create an HTML element: `document.createElement(tag)`.
/// Example: `document_create_element("div")` → `<div></div>`
#cfg(target="js")
pub extern "js" fn document_create_element(tag : String) -> DomNode =
  #| (tag) => document.createElement(tag)

///|
/// Create a text node: `document.createTextNode(text)`.
/// The initial content is set; caller can update via `node_set_text_content`.
#cfg(target="js")
pub extern "js" fn document_create_text_node(text : String) -> DomNode =
  #| (text) => document.createTextNode(text)

///|
/// Append a child node under a parent: `parent.appendChild(child)`.
/// The child is moved if it was already in the DOM.
#cfg(target="js")
pub extern "js" fn node_append_child(parent : DomNode, child : DomNode) -> Unit =
  #| (parent, child) => { parent.appendChild(child) }

///|
/// Set the text content of a node: `node.textContent = text`.
/// Used by `@svon.effect` bindings to update `{expr}` interpolations.
#cfg(target="js")
pub extern "js" fn node_set_text_content(node : DomNode, text : String) -> Unit =
  #| (node, text) => { node.textContent = text }

///|
/// Set an HTML attribute: `node.setAttribute(name, value)`.
/// For static attributes like `class="container"`.
#cfg(target="js")
pub extern "js" fn node_set_attribute(node : DomNode, name : String, value : String) -> Unit =
  #| (node, name, value) => { node.setAttribute(name, value) }

///|
/// Add a DOM event listener: `node.addEventListener(event, handler)`.
/// The `handler` is a MoonBit closure that is callable from JavaScript
/// via the `extern "js"` bridge.
#cfg(target="js")
pub extern "js" fn node_add_event_listener(
  node : DomNode,
  event : String,
  handler : () -> Unit,
) -> Unit =
  #| (node, event, handler) => { node.addEventListener(event, handler) }

///|
/// Access `document.body` — the root element where all generated DOM
/// is appended by `fn main`.
#cfg(target="js")
pub extern "js" fn document_body() -> DomNode =
  #| () => document.body

///|
/// Access `document.head` — used by the `<style>` block injection to
/// append a `<style>` element into the document head.
#cfg(target="js")
pub extern "js" fn document_head() -> DomNode =
  #| () => document.head
