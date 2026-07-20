///|
/// AST types for the Svon template compiler.
///
/// These types form the intermediate representation (IR) between the parser
/// and the code-generator in the Svon template compilation pipeline:
///
///   1. **Lexer**   – tokenizes raw `.svon` template source text.
///   2. **Parser**  – consumes tokens and builds a `Template` AST.
///   3. **Compiler** – walks the `Template` AST and emits runnable MoonBit
///      code that produces the corresponding HTML at runtime.
///
/// The AST is intentionally simple: Svon templates are a thin superset of
/// HTML that additionally support value interpolation (`{expr}`), event
/// bindings (`on:click={handler}`), and reactive value bindings
/// (`bind:value={state}`).  These three extensions are modelled directly by
/// the `Attribute` enum variants.

///|
/// A compiler diagnostic — records a parse/compile error or warning with
/// source location information so the user gets actionable feedback.
pub(all) struct Diagnostic {
  code : String      // Machine-readable error code (e.g. "unclosed-tag").
  message : String   // Human-readable description.
  start : Int        // Character offset where the problem begins.
  end : Int          // Character offset where the problem ends.
}

///|
/// Source position computed from a character offset — line and column
/// numbers are 1-based (matching editor display convention).
pub(all) struct SourcePos {
  line : Int    // 1-based line number.
  column : Int  // 1-based column number (UTF-16 code units).
}

///|
/// A fully-parsed Svon template file.
///
/// This is the root node of the Svon AST.  A single `.svon` source file is
/// parsed into one `Template` value that bundles together the top-level
/// script block, the scoped `<style>` block, any import declarations, and
/// the HTML template nodes that form the body of the component.
///
/// `diagnostics` is populated by the parser when it encounters malformed
/// input.  An empty array means parsing completed without errors.
pub(all) struct Template {
  script : String          // The raw content of the top-level `<script>` block (MoonBit code).
  styles : String          // The raw content of the `<style>` block, scoped to this component.
  imports : String         // Collected import statements (e.g. from `use` directives).
  nodes : Array[HtmlNode]  // The list of top-level HTML nodes in the template body.
  diagnostics : Array[Diagnostic]  // Errors and warnings collected during parsing.
  script_start_line : Int  // 1-based line number in the source where "<script" appears.
}

///|
/// A single node in the HTML template tree.
///
/// `HtmlNode` is the recursive building block of the template AST.  Every
/// node is either a text fragment (which may be static or contain
/// interpolated expressions) or a full HTML element (which itself may
/// contain nested children).  This two-variant design keeps the tree
/// representation flat and easy to traverse during code generation.
pub(all) enum HtmlNode {
  Text(TextChunk)       // A text fragment — either plain text or an interpolated expression.
  Element(ElementNode)  // A complete HTML element with a tag, attributes, and children.
  If(IfBlock)           // A Svelte-style {#if}…{/if} control-flow block.
  For(ForBlock)         // A {#for …}…{/for} iteration block.
}

///|
/// A {#for expr}…{/for} iteration block.  The for expression is emitted
/// directly into the generated MoonBit code, so it supports the full
/// MoonBit iteration syntax: `{element in list}`, `{i, el in list}`,
/// `{k, v in map}`.
pub(all) struct ForBlock {
  for_expr : String           // The iteration clause (between {#for and }).
  body : Array[HtmlNode]      // The repeated content.
}

///|
/// A Svelte-style {#if}…{/if} block with optional {:else if} and {:else} branches.
pub(all) struct IfBlock {
  condition : String                    // MoonBit expression for the {#if condition}
  body : Array[HtmlNode]                // Content rendered when condition is true
  else_ifs : Array[ElseIfBranch]        // {:else if condition} branches (0 or more)
  else_body : Array[HtmlNode]           // Content rendered when no condition matches
}

pub(all) struct ElseIfBranch {
  condition : String
  body : Array[HtmlNode]
}

///|
/// A text fragment inside the template.
///
/// In Svon templates, static text and interpolated expressions are
/// interleaved.  The parser splits a run of text into a sequence of
/// `TextChunk` values so the code-generator can emit the static portions
/// as string literals and the expression portions as interpolated values
/// (typically printed or concatenated into the output at runtime).
pub(all) enum TextChunk {
  Static(String)  // A literal, verbatim stretch of HTML text.
  Expr(String)    // An interpolated expression inside `{...}`, emitted as-is in generated code.
}

///|
/// An HTML element node in the template tree.
///
/// Represents a single HTML element such as `<div class="foo">...</div>`.
/// It carries the tag name, a list of attributes (including special Svon
/// attributes like events and bindings), and a list of child nodes that
/// are recursively processed during code generation.
pub(all) struct ElementNode {
  tag : String              // The HTML tag name (e.g. `"div"`, `"span"`, `"input"`).
  attributes : Array[Attribute]  // All attributes on this element, including Svon-specific ones.
  children : Array[HtmlNode]     // The child nodes nested inside this element.
}

///|
/// An attribute on an HTML element.
///
/// Attributes in Svon fall into three categories, represented by the three
/// variants of this enum:
///
/// - **Static**  – a normal HTML attribute with a literal string value
///   (e.g. `class="card"`, `id="root"`).
/// - **Event**   – an event listener binding (e.g. `on:click={handleClick}`).
/// - **Bind**    – a reactive two-way or one-way binding to a component
///   state variable (e.g. `bind:value={name}`).
///
/// This classification drives how the code-generator emits the attribute:
/// static attributes become HTML attribute strings, events become
/// `addEventListener` calls or equivalent, and bindings become reactive
/// subscription/unsubscription statements.
pub(all) enum Attribute {
  Static(String, String)  // A static HTML attribute: (name, value).  Both are literal strings.
  Event(String, String)   // An event binding: (event_name, handler_expression). E.g. `("click", "handleClick")`.
  Bind(String, String)    // A reactive binding: (property_name, expression). E.g. `("value", "name")`.
}
