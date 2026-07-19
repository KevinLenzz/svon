/// DOM bindings — js target only. Native target provides stubs.

#external
pub(all) type DomNode

#cfg(target="js")
pub extern "js" fn document_create_element(tag : String) -> DomNode =
  #| (tag) => document.createElement(tag)

#cfg(target="js")
pub extern "js" fn document_create_text_node(text : String) -> DomNode =
  #| (text) => document.createTextNode(text)

#cfg(target="js")
pub extern "js" fn node_append_child(parent : DomNode, child : DomNode) -> Unit =
  #| (parent, child) => { parent.appendChild(child) }

#cfg(target="js")
pub extern "js" fn node_set_text_content(node : DomNode, text : String) -> Unit =
  #| (node, text) => { node.textContent = text }

#cfg(target="js")
pub extern "js" fn node_set_attribute(node : DomNode, name : String, value : String) -> Unit =
  #| (node, name, value) => { node.setAttribute(name, value) }

#cfg(target="js")
pub extern "js" fn node_add_event_listener(
  node : DomNode,
  event : String,
  handler : () -> Unit,
) -> Unit =
  #| (node, event, handler) => { node.addEventListener(event, handler) }

#cfg(target="js")
pub extern "js" fn document_body() -> DomNode =
  #| () => document.body

#cfg(target="js")
pub extern "js" fn document_head() -> DomNode =
  #| () => document.head
