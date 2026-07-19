///|
/// AST types for the Svon template compiler.

///|
/// A parsed Svon template file.
pub(all) struct Template {
  script : String
  styles : String
  imports : String
  nodes : Array[HtmlNode]
}

///|
/// A node in the HTML template tree.
pub(all) enum HtmlNode {
  Text(TextChunk)
  Element(ElementNode)
}

///|
/// A text fragment — either static text or an interpolated expression.
pub(all) enum TextChunk {
  Static(String)
  Expr(String)
}

///|
/// An HTML element with a tag name, attributes, and children.
pub(all) struct ElementNode {
  tag : String
  attributes : Array[Attribute]
  children : Array[HtmlNode]
}

///|
/// An element attribute.
pub(all) enum Attribute {
  Static(String, String)
  Event(String, String)
  Bind(String, String)
}
