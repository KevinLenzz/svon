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
pub extern "js" fn node_set_attribute(
  node : DomNode,
  name : String,
  value : String,
) -> Unit =
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

///|
/// Create a `<template>` element pre-filled with static HTML.
/// The HTML is parsed by the browser's native parser once (at module-init
/// time when assigned to a `let`).  Call `template_clone_content` per
/// component instance to get a deep-cloned copy of the parsed DOM.
#cfg(target="js")
pub extern "js" fn template_from_html(html : String) -> DomNode =
  #| (html) => { let t = document.createElement("template"); t.innerHTML = html; return t }

///|
/// Clone the content of a `<template>` element (deep clone).
/// Returns a DocumentFragment that can be appended to the live DOM.
/// Call this once per component instance — `cloneNode(true)` is a
/// single native operation that deep-clones the entire pre-parsed tree.
#cfg(target="js")
pub extern "js" fn template_clone_content(tmpl : DomNode) -> DomNode =
  #| (tmpl) => tmpl.content.cloneNode(true)

///|
/// Get the nth child node (0-indexed).  Returns a DomNode or null.
/// Used to locate dynamic placeholder nodes within cloned templates.
#cfg(target="js")
pub extern "js" fn node_child(node : DomNode, index : Int) -> DomNode? =
  #| (node, index) => node.childNodes[index] ?? null

///|
/// Create a lightweight container node for grouping DOM nodes.
/// Uses a `<span>` with `display:contents` to avoid extra layout.
/// Used by control-flow blocks to batch-insert/remove child nodes.
#cfg(target="js")
pub extern "js" fn document_create_container() -> DomNode =
  #| () => { let s = document.createElement("span"); s.style.display = "contents"; return s }

///|
/// Create a Comment node — used as an anchor/placeholder for conditional blocks.
#cfg(target="js")
pub extern "js" fn document_create_comment(text : String) -> DomNode =
  #| (text) => document.createComment(text)

///|
/// Insert `new_child` into `parent` before `ref_child`.
/// If `ref_child` is null, appends to the end.
#cfg(target="js")
pub extern "js" fn node_insert_before(
  parent : DomNode,
  new_child : DomNode,
  ref_child : DomNode,
) -> Unit =
  #| (parent, new_child, ref_child) => parent.insertBefore(new_child, ref_child)

///|
/// Remove `child` from `parent`. Safe — no-op if child is not a child of parent.
#cfg(target="js")
pub extern "js" fn node_remove_child(parent : DomNode, child : DomNode) -> Unit =
  #| (parent, child) => { if (child.parentNode === parent) parent.removeChild(child) }

///|
/// Get the current value of an input/select/textarea element.
#cfg(target="js")
pub extern "js" fn node_get_value(el : DomNode) -> String =
  #| (el) => el.value

///|
/// Get the checked state of a checkbox/radio element.
#cfg(target="js")
pub extern "js" fn node_get_checked(el : DomNode) -> Bool =
  #| (el) => el.checked

///|
/// Set the .checked property of a checkbox/radio element.
#cfg(target="js")
pub extern "js" fn node_set_checked(el : DomNode, val : Bool) -> Unit =
  #| (el, val) => el.checked = val

///|
/// Get the open state of a <details> element.
#cfg(target="js")
pub extern "js" fn node_get_open(el : DomNode) -> Bool =
  #| (el) => el.open

///|
/// Get a boolean DOM property (paused, muted, indeterminate, etc.).
#cfg(target="js")
pub extern "js" fn node_get_bool(el : DomNode, prop : String) -> Bool =
  #| (el, prop) => !!el[prop]

///| Set the .value property of an input (not the HTML attribute).

///|
/// Prevents resetting the slider/input position during drag.
#cfg(target="js")
pub extern "js" fn node_set_value(el : DomNode, val : String) -> Unit =
  #| (el, val) => el.value = val

///|
/// Set the .open property of a <details> element.
#cfg(target="js")
pub extern "js" fn node_set_open(el : DomNode, val : Bool) -> Unit =
  #| (el, val) => el.open = val

///|
/// Set a text property (textContent, innerText, innerHTML) on an element.
#cfg(target="js")
pub extern "js" fn node_set_text_prop(
  el : DomNode,
  prop : String,
  val : String,
) -> Unit =
  #| (el, prop, val) => el[prop] = val

///|
/// Read a text property (textContent, innerText, innerHTML) from an element.
#cfg(target="js")
pub extern "js" fn node_get_text_prop(el : DomNode, prop : String) -> String =
  #| (el, prop) => el[prop] ?? ""

///| Get a DOM property value generically.  Used by bind:prop for properties

///|
/// not covered by specialised getters (value, checked, etc.).
#cfg(target="js")
pub extern "js" fn node_get_property(el : DomNode, prop : String) -> String =
  #| (el, prop) => String(el[prop] ?? "")

///|
/// Debug-print a DOM node structure using outerHTML (first 200 chars).
#cfg(target="js")
pub extern "js" fn dom_debug(node : DomNode) -> String =
  #| (node) => { let s = node.outerHTML || "<" + node.nodeName + ">"; return s.length > 200 ? s.slice(0, 200) + "..." : s }
