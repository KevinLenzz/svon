///|
/// Top-level entry point: parses a `.svon` source string into a `Template` AST.
///
/// # Parsing Pipeline
/// 1. `extract_script` — pulls the `<script>` body (MoonBit code) out of source.
/// 2. `extract_style` — pulls the `<style>` body (CSS) out of source.
/// 3. `extract_script_imports` — reads the `import="..."` attribute on `<script>`.
/// 4. `html_parse_bounds` — computes the character range in `source` where the HTML
///    template lives (skipping `<script>` and `<style>` blocks).
/// 5. `parse_nodes` — recursive-descent parser that walks the HTML portion and
///    produces an `Array[HtmlNode]`.  All positions in diagnostics are relative
///    to the original `source` string, so line/column calculations are accurate.
///
/// Parse errors are recorded in `template.diagnostics`.  An empty `diagnostics`
/// array means the template was parsed successfully.
pub fn parse(source : String) -> Template {
  let script = extract_script(source)
  let styles = extract_style(source)
  let imports = extract_script_imports(source)
  let html = extract_html(source)
  let html_no_style = remove_style_block(html)
  let diags = Array::new(capacity=4)
  let nodes = parse_nodes(html_no_style, 0, html_no_style.length(), diags, Ref(0))
  let script_start_line = match source.find("<script") {
    Option::Some(pos) => offset_to_line_col(source, pos).line
    Option::None => 1
  }
  { script, styles, imports, nodes, diagnostics: diags, script_start_line }
}

///|
fn extract_html(source : String) -> String {
  let start_tag = "<script lang=\"moonbit\">"
  let end_tag = "</script>"
  match source.find(start_tag) {
    Option::Some(start) =>
      match source.find(end_tag) {
        Option::Some(end) => {
          let before = source.unsafe_substring(start=0, end=start)
          let aft = end + end_tag.length()
          let after = source.unsafe_substring(start=aft, end=source.length())
          before + after
        }
        Option::None => source
      }
    Option::None =>
      match source.find("<script>") {
        Option::Some(start) =>
          match source.find("</script>") {
            Option::Some(end) => {
              let before = source.unsafe_substring(start=0, end=start)
              let aft = end + "</script>".length()
              let after = source.unsafe_substring(
                start=aft,
                end=source.length(),
              )
              before + after
            }
            Option::None => source
          }
        Option::None => source
      }
  }
}

///|
fn remove_style_block(source : String) -> String {
  let start_tag = "<style>"
  let end_tag = "</style>"
  match source.find(start_tag) {
    Option::Some(start) =>
      match source.find(end_tag) {
        Option::Some(end) => {
          let before = source.unsafe_substring(start=0, end=start)
          let after_start = end + end_tag.length()
          let after = source.unsafe_substring(
            start=after_start,
            end=source.length(),
          )
          before + after
        }
        Option::None => source
      }
    Option::None => source
  }
}

///|
/// Compute the start and end offsets of the HTML template content within
/// the full `source` string.  We skip over `<script>…</script>` and
/// `<style>…</style>` blocks, returning the character range that contains
/// the actual HTML markup.
///
/// All error positions reported by the parser are relative to the full
/// `source` string, so line/column calculations are correct without any
/// offset arithmetic.

///|
/// Convert a character offset into a 1-based line and column for display.
fn offset_to_line_col(source : String, offset : Int) -> SourcePos {
  let mut line = 1
  let mut col = 1
  let mut i = 0
  while i < offset && i < source.length() {
    if source[i] == 10 {
      line = line + 1
      col = 1
    } else {
      col = col + 1
    }
    i = i + 1
  }
  { line, column: col }
}

///|
/// Record a parse diagnostic at a given source span.
fn record(
  diags : Array[Diagnostic],
  code : String,
  message : String,
  start : Int,
  end : Int,
) -> Unit {
  diags.push({ code, message, start, end })
}

///|
/// Helper: build a string of `n` space characters.
fn spaces(n : Int) -> String {
  let b = StringBuilder::new()
  let mut i = 0
  while i < n {
    b.write_string(" ")
    i = i + 1
  }
  b.to_string()
}

///|
/// Generate a formatted source-code snippet around a given line with a
/// caret (`^`) pointing at the error column.
///
/// Includes up to 2 lines of context before and after the error line.
fn generate_code_frame(source : String, line : Int, col : Int) -> String {
  let b = StringBuilder::new()
  let mut current_line = 1
  let mut line_start = 0
  let mut i = 0
  let digits = (line + 2).to_string().length()
  while i <= source.length() && current_line <= line + 2 {
    if i == source.length() || source[i] == 10 {
      if current_line >= line - 2 {
        let src_line = if current_line <= line + 2 {
          let ln_end = if i <= source.length() { i } else { source.length() }
          source.unsafe_substring(start=line_start, end=ln_end)
        } else {
          ""
        }
        let line_num_str = current_line.to_string()
        let pad = spaces(digits - line_num_str.length())
        b.write_string(pad)
        b.write_string(line_num_str)
        b.write_string(": ")
        b.write_string(src_line)
        b.write_string("\n")
        if current_line == line {
          b.write_string(spaces(digits + 2 + col - 1))
          b.write_string("^\n")
        }
      }
      current_line = current_line + 1
      line_start = i + 1
    }
    i = i + 1
  }
  b.to_string()
}

///|
/// Format all diagnostics into a human-readable error report with source
/// code frames.  Matches the output conventions of modern compilers
/// (Rust/Svelte-style diagnostics).
pub fn format_diagnostics(source : String, diags : Array[Diagnostic]) -> String {
  let b = StringBuilder::new()
  b.write_string("\n")
  for i in 0..<diags.length() {
    let d = diags[i]
    let pos = offset_to_line_col(source, d.start)
    b.write_string("  ")
    b.write_string(d.code)
    b.write_string(": ")
    b.write_string(d.message)
    b.write_string("\n")
    b.write_string("  at ")
    b.write_string(pos.line.to_string())
    b.write_string(":")
    b.write_string(pos.column.to_string())
    b.write_string("\n\n")
    b.write_string(generate_code_frame(source, pos.line, pos.column))
    if i < diags.length() - 1 {
      b.write_string("\n")
    }
  }
  b.to_string()
}

///|
/// Extract the raw CSS inside the **first** `<style>…</style>` block in `source`.
///
/// # Algorithm
/// 1. Locate the opening `<style>` tag via `String::find`.
/// 2. From that position, locate the closing `</style>` tag.
/// 3. Return the substring between them.
///
/// Only the first block is considered; nested or multiple `<style>` blocks are
/// not supported.  Returns `""` if either tag is missing.
fn extract_style(source : String) -> String {
  let start_tag = "<style>"
  let end_tag = "</style>"
  match source.find(start_tag) {
    Option::Some(start) => {
      // body_start points to the first character after "<style>"
      let body_start = start + start_tag.length()
      match source.find(end_tag) {
        Option::Some(end) => source.unsafe_substring(start=body_start, end~)
        Option::None => ""
      }
    }
    Option::None => ""
  }
}

///|
/// Extract the value of the `import="…"` attribute from a `<script>` opening tag.
///
/// # Algorithm
/// 1. Find `<script` in the source.
/// 2. Find the first `>` (closing the opening tag).
/// 3. Slice out the entire opening tag substring (e.g. `<script lang="moonbit" import="foo">`).
/// 4. Search that substring for `import="`.
/// 5. Read characters until the matching `"` delimiter.
///
/// Returns `""` if the `<script>` tag, the attribute, or the closing quote are missing.
fn extract_script_imports(source : String) -> String {
  match source.find("<script") {
    Option::Some(start) =>
      match source.find(">") {
        Option::Some(gt) => {
          // The complete opening tag, e.g. "<script lang=\"moonbit\">"
          let tag = source.unsafe_substring(start~, end=gt + 1)
          match tag.find("import=\"") {
            Option::Some(im) => {
              // val_start = position right after import="
              let val_start = im + "import=\"".length()
              let rest = tag.unsafe_substring(start=val_start, end=tag.length())
              match rest.find("\"") {
                Option::Some(ve) =>
                  // Everything from val_start to the closing double-quote
                  rest.unsafe_substring(start=0, end=ve)
                Option::None => ""
              }
            }
            Option::None => ""
          }
        }
        Option::None => ""
      }
    Option::None => ""
  }
}

///|
/// Extract the body of a `<script>` tag from `source`.
///
/// # Algorithm
/// 1. Try to find `<script lang="moonbit">` first (the MoonBit-specific form).
/// 2. If found, return the substring between it and the next `</script>`.
/// 3. If not found, fall back to a plain `<script>` / `</script>` pair.
/// 4. Return `""` if neither form is present.
fn extract_script(source : String) -> String {
  let start_tag = "<script lang=\"moonbit\">"
  let end_tag = "</script>"
  match source.find(start_tag) {
    Option::Some(start) => {
      // bs = body start (first character after the opening tag)
      let bs = start + start_tag.length()
      match source.find(end_tag) {
        Option::Some(end) => source.unsafe_substring(start=bs, end~)
        Option::None => ""
      }
    }
    Option::None =>
      // Fallback: plain <script> without lang attribute
      match source.find("<script>") {
        Option::Some(start) => {
          let bs = start + "<script>".length()
          match source.find("</script>") {
            Option::Some(end) => source.unsafe_substring(start=bs, end~)
            Option::None => ""
          }
        }
        Option::None => ""
      }
  }
}

///|
/// Safe character accessor: returns the UTF-16 code unit at index `i` of `s`,
/// or `0` (NUL) if `i` is out of bounds.
///
/// Using a single 0-return helper simplifies all the lexer loops that check
/// `char_at(s, p) == some_char` — they don't need a separate bounds check.
fn char_at(s : String, i : Int) -> UInt16 {
  if i < 0 || i >= s.length() {
    0
  } else {
    s[i]
  }
}

///|
/// Returns `true` when the character is an ASCII whitespace character:
/// space (32), tab (9), carriage-return (13), or line-feed (10).
fn is_space(ch : UInt16) -> Bool {
  ch == 32 || ch == 9 || ch == 13 || ch == 10
}

///|
/// Returns `true` for characters that delimit tokens in an HTML open-tag context.
///
/// The special characters are: `>` (end of tag), `/` (self-closing marker),
/// `=` (attribute assignment), and any ASCII whitespace.
/// Everything else is treated as part of a tag name or attribute name.
fn is_special(ch : UInt16) -> Bool {
  ch == 62 || ch == 47 || ch == 61 || is_space(ch)
}

///|
/// Advance `i` past any ASCII whitespace characters, returning the position
/// of the first non-space character (or `end` if all remaining characters are spaces).
fn skip_ws(s : String, i : Int, end : Int) -> Int {
  let mut p = i
  while p < end && is_space(char_at(s, p)) {
    p = p + 1
  }
  p
}

///|
/// Read a "word" token starting at position `i` in `s`.
///
/// A word is a maximal run of characters that are NOT special (as defined by
/// `is_special`).  This is used to read tag names and attribute names.
///
/// Returns a tuple `(word, next_position)`.  `word` may be empty if `i` is
/// already at a special character.
fn read_word(s : String, i : Int, end : Int) -> (String, Int) {
  let start = i
  let mut p = i
  while p < end && !is_special(char_at(s, p)) {
    p = p + 1
  }
  (s.unsafe_substring(start~, end=p), p)
}

///|
/// Recursive-descent parser: consumes the HTML substring `html[pos..end]` and
/// returns a flat list of `HtmlNode`s.
///
/// # Algorithm
/// 1. Skip whitespace.
/// 2. Peek at the current character:
///    - `<` (60):
///      a. `<!--` — skip the entire HTML comment (`<!-- ... -->`).
///      b. `</` — closing tag encountered; **break** (return to caller — this
///         is the parent's closing tag, not a child node).
///      c. Otherwise — call `parse_element()` to consume a complete element node.
///    - Any other character — call `parse_text()` to consume a text node
///      (which may contain `{expr}` interpolation chunks).
/// 3. If a parse function returns `None`, advance by one character to avoid
///    getting stuck on unparseable input.
/// 4. Loop until `i >= end` or a closing tag is hit.
///
/// The returned `Array` may contain interleaved `Element` and `Text` nodes in
/// source order.
fn parse_nodes(
  html : String,
  pos : Int,
  end : Int,
  diags : Array[Diagnostic],
  child_end : Ref[Int],
) -> Array[HtmlNode] {
  let nodes = Array::new(capacity=8)
  let mut i = pos
  while i < end {
    i = skip_ws(html, i, end)
    if i >= end {
      break
    }
    let ch = char_at(html, i)
    // '<' — start of a tag (element, closing tag, or comment)
    if ch == 60 {
      // Check for HTML comment "<!--"
      if i + 3 < end &&
        char_at(html, i + 1) == 33 &&
        char_at(html, i + 2) == 45 &&
        char_at(html, i + 3) == 45 {
        i = i + 4 // skip past "<!--"
        // Scan forward until "-->" is found
        while i + 2 < end &&
              !(char_at(html, i) == 45 &&
              char_at(html, i + 1) == 45 &&
              char_at(html, i + 2) == 62) {
          i = i + 1
        }
        i = i + 3 // skip past "-->"
        continue
      }
      // "</" — a closing tag; this means we have reached the end of the parent's
      // content. Break out so the parent (parse_element) can handle the close tag.
      if i + 1 < end && char_at(html, i + 1) == 47 {
        break
      }
      // Otherwise it's an opening tag. Delegate to parse_element.
      match parse_element(html, i, end, diags) {
        Option::Some((el, next)) => {
          nodes.push(HtmlNode::Element(el))
          i = next
          continue
        }
        // Couldn't parse — skip this character to avoid an infinite loop
        Option::None => i = i + 1
      }
    } else if ch == 123 && i + 1 < end && char_at(html, i + 1) == 35 {
      // "{#" — control-flow block (if, for)
      if i + 5 < end && html.unsafe_substring(start=i, end=i + 5) == "{#if " {
        match parse_if_block(html, i, end, diags) {
          Option::Some((block, next)) => {
            nodes.push(HtmlNode::If(block))
            i = next
            continue
          }
          Option::None => i = i + 1
        }
      } else if i + 5 < end && html.unsafe_substring(start=i, end=i + 5) == "{#for" {
        match parse_for_block(html, i, end, diags) {
          Option::Some((block, next)) => {
            nodes.push(HtmlNode::For(block))
            i = next
            continue
          }
          Option::None => i = i + 1
        }
      } else {
        i = i + 1
      }
    } else {
      // Not a tag or control block — must be text content
      match parse_text(html, i, end, diags) {
        Option::Some((parts, next)) => {
          for j in 0..<parts.length() {
            nodes.push(HtmlNode::Text(parts[j]))
          }
          i = next
          continue
        }
        Option::None => i = i + 1
      }
    }
    i = i + 1
  }
  child_end.val = i
  nodes
}

///|
/// Parse a single HTML element starting at position `pos` (which must point to
/// the `<` character).
///
/// # Algorithm — Three Phases
///
/// ## Phase 1 — Tag Name
/// Move past `<`, skip whitespace, then read the tag name with `read_word`.
/// If the tag name is empty, return `None`.
///
/// ## Phase 2 — Attributes
/// Loop parsing attributes until `>` or `/>` is seen:
/// - Skip whitespace.
/// - If `>` is encountered, the element has content/children; exit the attribute loop.
/// - If `/>` is encountered, the element is self-closing; return immediately with
///   an empty `children` array.
/// - Otherwise, read an attribute name with `read_word`.
///   - If the next char is `=`:
///     * If the value starts with `"` or `'` — parse a **quoted string** value.
///       If the attribute name starts with `on` (e.g. `onclick`), produce an
///       `Event` attribute; otherwise a `Static` attribute.
///     * If the value starts with `{` — parse a **brace-delimited** expression.
///       Brace-depth tracking handles nested `{…}`.  If the attribute name
///       starts with `on`, produce an `Event` attribute; otherwise a `Bind`
///       attribute.
///   - If there is no `=`, produce a `Static` attribute with an empty value
///     (a boolean attribute, e.g. `disabled`).
///
/// ## Phase 3 — Children and Close Tag
/// 1. Recursively call `parse_nodes` starting at the current position to collect
///    child nodes.
/// 2. Search for the closing tag `</tag>` **in the substring starting from the
///    current position** (NOT from the original `pos`).
///
///    **Infinite-loop fix:** Searching from `i` (current position after children)
///    rather than from the original `pos` (start of `<tag`) prevents the parser
///    from matching the opening tag's own `>` or finding a child element's
///    closing tag instead of the correct parent close tag.  If we searched from
///    `pos`, we could match `<` inside child text or child tags, causing the
///    parser to skip too far or loop forever when `find` returned the wrong
///    offset.  By only searching the *remainder* of the string (from `i`), we
///    guarantee the first match is the correct closing tag for this element.
///
/// 3. Return the `ElementNode` and the position right after the closing tag.
fn parse_element(
  html : String,
  pos : Int,
  end : Int,
  diags : Array[Diagnostic],
) -> (ElementNode, Int)? {
  // Move past the opening '<' and skip any whitespace before the tag name
  let mut i = pos + 1
  i = skip_ws(html, i, end)
  // Read the tag name (e.g. "div", "span", "h1")
  let (tag, after_tag) = read_word(html, i, end)
  if tag.length() == 0 {
    record(diags, "empty-tag-name", "Expected a tag name after `<`", pos, i)
    return Option::None
  }
  i = after_tag

  // Phase 2: parse attributes until '>' or '/>'
  let attrs = Array::new(capacity=4)
  let mut parsing = true
  while parsing {
    i = skip_ws(html, i, end)
    if i >= end {
      parsing = false
      continue
    }
    let ch = char_at(html, i)
    // '>' — end of opening tag; the element has children
    if ch == 62 {
      i = i + 1 // move past '>'
      parsing = false // exit attribute loop
      continue
    }
    // '/>' — self-closing tag; return immediately with no children
    if ch == 47 && i + 1 < end && char_at(html, i + 1) == 62 {
      return Option::Some(({ tag, attributes: attrs, children: [] }, i + 2))
    }
    // Read the attribute name
    let (name, after_name) = read_word(html, i, end)
    i = after_name
    // Check for '=' indicating this attribute has a value
    if char_at(html, i) == 61 {
      i = i + 1 // consume '='
      let q = char_at(html, i)
      // Quoted value (double or single quotes)
      if q == 34 || q == 39 {
        i = i + 1 // skip opening quote
        let vs = i // value start
        // Scan until the matching closing quote
        while i < end && char_at(html, i) != q {
          i = i + 1
        }
        let val = html.unsafe_substring(start=vs, end=i)
        i = i + 1 // skip closing quote
        // Attribute names starting with "on" (e.g. onclick, oninput) are
        // treated as event handlers → Attribute::Event
        if name.length() > 2 && name.unsafe_substring(start=0, end=2) == "on" {
          let ev_name = name.unsafe_substring(start=2, end=name.length())
          attrs.push(Attribute::Event(ev_name, val))
        } else {
          attrs.push(Attribute::Static(name, val))
        }
      } else if q == 123 {
        // Brace-delimited expression value: e.g. attr={someExpr}
        i = i + 1 // skip opening '{'
        let vs = i // value start
        let mut d = 1 // brace-depth counter (handles nested {...})
        while i < end && d > 0 {
          let c = char_at(html, i)
          if c == 123 {
            d = d + 1 // enter nested brace
          } else if c == 125 {
            d = d - 1 // exit a brace level
            if d == 0 {
              break // found the matching '}', stop
            }
          }
          i = i + 1
        }
        let val = html.unsafe_substring(start=vs, end=i)
        i = i + 1 // skip closing '}'
        // If name starts with "on", it's an event binding with a braced handler
        if name.length() > 2 && name.unsafe_substring(start=0, end=2) == "on" {
          let ev_name = name.unsafe_substring(start=2, end=name.length())
          attrs.push(Attribute::Event(ev_name, val))
        } else {
          // Strip "bind:" prefix for bind attributes
          let bind_name = if name.has_prefix("bind:") { name.unsafe_substring(start="bind:".length(), end=name.length()) } else { name }
          attrs.push(Attribute::Bind(bind_name, val))
        }
      }
    } else {
      // No '=' — this is a boolean attribute like `disabled` or `hidden`.
      // Store it as a Static attribute with an empty value string.
      attrs.push(Attribute::Static(name, ""))
    }
  }

  // Phase 3: recursively parse child nodes
  let child_end = Ref(i)
  let children = parse_nodes(html, i, end, diags, child_end)

  // Construct the expected closing tag, e.g. "</div>"
  let close_tag = "</" + tag + ">"
  // INFINITE-LOOP FIX: search for the close tag only in the substring starting
  // from `i` (the current position after parsing children), NOT from the original
  // `pos` (the start of this element).  If we searched from `pos`, we could
  // accidentally match a `<` or `>` inside child elements or text, causing the
  // parser to either overshoot the correct close tag or loop forever.  By
  // limiting the search to `rest` (the unparsed remainder), `find` returns the
  // **first** occurrence after the children, which is exactly the correct closing
  // tag for this element.
  let rest = html.unsafe_substring(start=child_end.val, end~)
  let close_end = match rest.find(close_tag) {
    Option::Some(ct) => child_end.val + ct + close_tag.length()
    Option::None => {
      record(
        diags,
        "unclosed-tag",
        "<" + tag + "> has no matching closing tag </" + tag + ">",
        pos,
        end,
      )
      end
    }
  }

  Option::Some(({ tag, attributes: attrs, children }, close_end))
}

///|
/// Parse a text node at position `pos` in `html`.
///
/// # Algorithm
/// Text nodes can contain static string segments interleaved with `{expr}`
/// interpolation chunks.
///
/// 1. Accumulate text characters into `parts` as `TextChunk` values.
/// 2. Track `ts` (text-start) — the position where the current static segment began.
/// 3. Walk forward character by character:
///    - `<` (60) — an element tag is beginning; **break** (text node ends).
///    - `{` (123) — start of an interpolation expression:
///      a. Flush any pending static text from `ts..i` (if non-empty after trimming).
///      b. Advance past `{`, track the expression start `es`.
///      c. Use a brace-depth counter `d` to match `{`…`}`, handling nesting.
///      d. Extract `es..i`, trim, and push as `TextChunk::Expr` if non-empty.
///      e. Move past `}` and reset `ts` to the next character.
///    - Any other character — advance `i` (continues accumulating static text).
/// 4. After the loop, flush any remaining static text.
/// 5. Return `None` if there were no parts at all (pure whitespace between tags).
///
/// The function returns the `Array[TextChunk]` and the position where parsing
/// stopped (at the `<` of the next tag, or at `end`).
fn parse_text(
  html : String,
  pos : Int,
  end : Int,
  diags : Array[Diagnostic],
) -> (Array[TextChunk], Int)? {
  let parts = Array::new(capacity=4)
  let mut i = pos
  let mut ts = i // ts = text-start: beginning of the current static text segment
  while i < end {
    let ch = char_at(html, i)
    // '<' — start of an element tag; text node ends here
    if ch == 60 {
      break
    }
    // '{' — interpolation expression begins
    if ch == 123 {
      // Flush any pending static text before the '{'
      if i > ts {
        let raw = html.unsafe_substring(start=ts, end=i)
        let s = raw.trim().to_owned()
        if s.length() > 0 {
          parts.push(TextChunk::Static(s))
        }
      }
      let brace_start = i
      i = i + 1 // skip '{'
      let es = i // expression start
      let mut d = 1 // brace-depth counter for nested {…}
      while i < end && d > 0 {
        let c = char_at(html, i)
        if c == 123 {
          d = d + 1
        } else if c == 125 {
          d = d - 1
          if d == 0 {
            break // matched the outer '{', stop
          }
        }
        i = i + 1
      }
      if d > 0 {
        record(
          diags, "unclosed-brace", "Unclosed `{` in template expression — missing `}`",
          brace_start, i,
        )
      }
      let raw_expr = html.unsafe_substring(start=es, end=i)
      let expr = raw_expr.trim().to_owned()
      if expr.length() > 0 {
        parts.push(TextChunk::Expr(expr))
      }
      i = i + 1 // skip '}'
      ts = i // reset text-start to after the expression
    } else {
      // Ordinary text character — keep accumulating
      i = i + 1
    }
  }
  // Flush any remaining static text after the last expression (or the whole text)
  if i > ts {
    let raw = html.unsafe_substring(start=ts, end=i)
    let s = raw.trim().to_owned()
    if s.length() > 0 {
      parts.push(TextChunk::Static(s))
    }
  }
  // If the text node was pure whitespace (trimmed to nothing), return None
  if parts.length() == 0 {
    Option::None
  } else {
    Option::Some((parts, i))
  }
}

///|
/// Parse a Svelte-style {#if}…{/if} control-flow block.
///
/// # Syntax
/// ```svon
/// {#if condition}
///   <p>rendered when true</p>
/// {:else if other}
///   <p>else-if branch</p>
/// {:else}
///   <p>fallthrough</p>
/// {/if}
/// ```
fn parse_if_block(
  html : String,
  pos : Int,
  end : Int,
  diags : Array[Diagnostic],
) -> (IfBlock, Int)? {
  if pos + 5 >= end {
    return Option::None
  }
  if html.unsafe_substring(start=pos, end=pos + 5) != "{#if " {
    return Option::None
  }
  let mut i = pos + 5
  let cond_start = i
  let mut d = 1
  while i < end && d > 0 {
    if html[i] == 123 {
      d = d + 1
    } else if html[i] == 125 {
      d = d - 1
    }
    if d == 0 {
      break
    }
    i = i + 1
  }
  if d > 0 {
    record(
      diags,
      "unclosed-if",
      "Unclosed {#if ...} — missing } at " + pos.to_string(),
      pos,
      i,
    )
    return Option::None
  }
  let condition = html
    .unsafe_substring(start=cond_start, end=i)
    .trim()
    .to_owned()
  i = i + 1 // skip "}"
  let body_start = i

  // Scan forward to find the matching {/if}, collecting {:else}/{:else if} positions
  let mut body_end = end
  let mut end_tag_pos = end // position of {/if}
  let elif_conds = Array::new(capacity=4)
  let elif_starts = Array::new(capacity=4)
  let mut else_start = -1
  let mut else_marker = -1 // position of {:else} for prev segment end
  let mut depth = 1
  let mut scan = body_start
  let mut first_else = false

  while scan < end {
    if html[scan] == 123 {
      if scan + 1 < end && html[scan + 1] == 35 {
        depth = depth + 1
      } else if scan + 1 < end && html[scan + 1] == 47 {
        let j = scan + 2
        let mut tag_end = j
        while tag_end < end &&
              html[tag_end] != 125 &&
              html[tag_end] != 32 &&
              html[tag_end] != 13 &&
              html[tag_end] != 10 {
          tag_end = tag_end + 1
        }
        if html.unsafe_substring(start=j, end=tag_end) == "if" {
          depth = depth - 1
          if depth == 0 {
            if !first_else {
              body_end = scan
            }
            end_tag_pos = scan
            i = tag_end
            while i < end && html[i] != 125 {
              i = i + 1
            }
            if i < end {
              i = i + 1
            }
            break
          }
        }
      } else if scan + 1 < end && html[scan + 1] == 58 {
        if depth == 1 {
          let j = scan + 2
          let mut tag_end = j
          while tag_end < end &&
                html[tag_end] != 125 &&
                html[tag_end] != 32 &&
                html[tag_end] != 13 &&
                html[tag_end] != 10 {
            tag_end = tag_end + 1
          }
          if html.unsafe_substring(start=j, end=tag_end) == "else" {
            if !first_else {
              body_end = scan // body ends at first {:else}
              first_else = true
            }
            let mut marker_end = tag_end
            if marker_end < end && html[marker_end] == 32 {
              marker_end = marker_end + 1
              if marker_end + 1 < end &&
                html.unsafe_substring(start=marker_end, end=marker_end + 2) ==
                "if" {
                marker_end = marker_end + 2
                if marker_end < end && html[marker_end] == 32 {
                  marker_end = marker_end + 1
                }
                let ec_start = marker_end
                let mut ed = 1
                let mut k = ec_start
                while k < end && ed > 0 {
                  if html[k] == 123 {
                    ed = ed + 1
                  } else if html[k] == 125 {
                    ed = ed - 1
                  }
                  if ed == 0 {
                    break
                  }
                  k = k + 1
                }
                if ed == 0 {
                  elif_conds.push(
                    html
                    .unsafe_substring(start=ec_start, end=k)
                    .trim()
                    .to_owned(),
                  )
                  elif_starts.push(k + 1)
                }
              }
            } else {
              else_marker = scan
              else_start = tag_end
              let mut k = else_start
              while k < end && html[k] != 125 {
                k = k + 1
              }
              else_start = k + 1
            }
          }
        }
      }
    }
    scan = scan + 1
  }

  // Parse body content
  let body = parse_nodes(html, body_start, body_end, diags, Ref(0))

  // Parse else-if branches
  let range = elif_conds.length()
  let else_ifs = Array::new(capacity=range)
  for ei in 0..<range {
    let ecs = elif_starts[ei]
    let ece = if ei + 1 < range {
      elif_starts[ei + 1]
    } else if else_marker >= 0 {
      else_marker
    } else {
      end_tag_pos
    }
    let ef_body = parse_nodes(html, ecs, ece, diags, Ref(0))
    let ef = { condition: elif_conds[ei], body: ef_body }
    else_ifs.push(ef)
  }

  // Parse else body
  let else_body = if else_start >= 0 {
    parse_nodes(html, else_start, end_tag_pos, diags, Ref(0))
  } else {
    let empty = Array::new(capacity=0)
    empty
  }

  Option::Some(({ condition, body, else_ifs, else_body }, i))
}

///|
/// Parse a {#for expr}…{/for} iteration block.
fn parse_for_block(html : String, pos : Int, end : Int, diags : Array[Diagnostic]) -> (ForBlock, Int)? {
  if pos + 5 >= end { return Option::None }
  if html.unsafe_substring(start=pos, end=pos + 5) != "{#for" { return Option::None }
  // Skip whitespace after "for"
  let mut i = pos + 5
  while i < end && html[i] == 32 { i = i + 1 }
  // Parse expression until "}"
  let expr_start = i
  let mut d = 1
  while i < end && d > 0 {
    if html[i] == 123 { d = d + 1 } else if html[i] == 125 { d = d - 1 }
    if d == 0 { break }
    i = i + 1
  }
  if d > 0 {
    record(diags, "unclosed-for", "Unclosed {#for ...} — missing }", pos, i)
    return Option::None
  }
  let for_expr = html.unsafe_substring(start=expr_start, end=i).trim().to_owned()
  i = i + 1  // skip "}"
  let body_start = i

  // Find matching {/for}
  let mut depth = 1
  let mut scan = body_start
  while scan < end {
    if html[scan] == 123 {
      if scan + 1 < end && html[scan + 1] == 35 { depth = depth + 1 }
      else if scan + 1 < end && html[scan + 1] == 47 {
        let j = scan + 2
        let mut tag_end = j
        while tag_end < end && html[tag_end] != 125 && html[tag_end] != 32 && html[tag_end] != 13 && html[tag_end] != 10 { tag_end = tag_end + 1 }
        if html.unsafe_substring(start=j, end=tag_end) == "for" {
          depth = depth - 1
          if depth == 0 {
            let body_end = scan
            i = tag_end
            while i < end && html[i] != 125 { i = i + 1 }
            if i < end { i = i + 1 }
            let body = parse_nodes(html, body_start, body_end, diags, Ref(0))
            return Option::Some(({ for_expr, body }, i))
          }
        }
      }
    }
    scan = scan + 1
  }
  record(diags, "unclosed-for", "Unclosed {#for} — missing {/for}", pos, scan)
  Option::None
}
