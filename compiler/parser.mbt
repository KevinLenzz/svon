///|
/// Template parser for `.svon` files.
pub fn parse(source : String) -> Template {
  let script = extract_script(source)
  let styles = extract_style(source)
  let imports = extract_script_imports(source)
  let html_full = extract_html(source)
  let html = remove_style_block(html_full)
  let nodes = parse_nodes(html, 0, html.length())
  { script, styles, imports, nodes }
}

fn extract_style(source : String) -> String {
  let start_tag = "<style>"
  let end_tag = "</style>"
  match source.find(start_tag) {
    Option::Some(start) => {
      let body_start = start + start_tag.length()
      match source.find(end_tag) {
        Option::Some(end) => source.unsafe_substring(start=body_start, end=end)
        Option::None => ""
      }
    }
    Option::None => ""
  }
}

fn remove_style_block(source : String) -> String {
  let start_tag = "<style>"
  let end_tag = "</style>"
  match source.find(start_tag) {
    Option::Some(start) => match source.find(end_tag) {
      Option::Some(end) => {
        let before = source.unsafe_substring(start=0, end=start)
        let after_start = end + end_tag.length()
        let after = source.unsafe_substring(start=after_start, end=source.length())
        before + after
      }
      Option::None => source
    }
    Option::None => source
  }
}

fn extract_script_imports(source : String) -> String {
  match source.find("<script") {
    Option::Some(start) => match source.find(">") {
      Option::Some(gt) => {
        let tag = source.unsafe_substring(start=start, end=gt + 1)
        match tag.find("import=\"") {
          Option::Some(im) => {
            let val_start = im + "import=\"".length()
            let rest = tag.unsafe_substring(start=val_start, end=tag.length())
            match rest.find("\"") {
              Option::Some(ve) =>
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
fn extract_script(source : String) -> String {
  let start_tag = "<script lang=\"moonbit\">"
  let end_tag = "</script>"
  match source.find(start_tag) {
    Option::Some(start) => {
      let bs = start + start_tag.length()
      match source.find(end_tag) {
        Option::Some(end) => source.unsafe_substring(start=bs, end~)
        Option::None => ""
      }
    }
    Option::None =>
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
fn char_at(s : String, i : Int) -> UInt16 {
  if i < 0 || i >= s.length() {
    0
  } else {
    s[i]
  }
}

///|
fn is_space(ch : UInt16) -> Bool {
  ch == 32 || ch == 9 || ch == 13 || ch == 10
}

///|
fn is_special(ch : UInt16) -> Bool {
  ch == 62 || ch == 47 || ch == 61 || is_space(ch)
}

///|
fn skip_ws(s : String, i : Int, end : Int) -> Int {
  let mut p = i
  while p < end && is_space(char_at(s, p)) {
    p = p + 1
  }
  p
}

///|
fn read_word(s : String, i : Int, end : Int) -> (String, Int) {
  let start = i
  let mut p = i
  while p < end && !is_special(char_at(s, p)) {
    p = p + 1
  }
  (s.unsafe_substring(start~, end=p), p)
}

///|
fn parse_nodes(html : String, pos : Int, end : Int) -> Array[HtmlNode] {
  let nodes = Array::new(capacity=8)
  let mut i = pos
  while i < end {
    i = skip_ws(html, i, end)
    if i >= end {
      break
    }
    let ch = char_at(html, i)
    if ch == 60 {
      if i + 3 < end && char_at(html, i + 1) == 33 && char_at(html, i + 2) == 45 && char_at(html, i + 3) == 45 {
        i = i + 4
        while i + 2 < end && !(char_at(html, i) == 45 && char_at(html, i + 1) == 45 && char_at(html, i + 2) == 62) {
          i = i + 1
        }
        i = i + 3
        continue
      }
      if i + 1 < end && char_at(html, i + 1) == 47 {
        break
      }
      match parse_element(html, i, end) {
        Option::Some((el, next)) => {
          nodes.push(HtmlNode::Element(el))
          i = next
          continue
        }
        Option::None => i = i + 1
      }
    } else {
      match parse_text(html, i, end) {
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
  nodes
}

///|
fn parse_element(html : String, pos : Int, end : Int) -> (ElementNode, Int)? {
  let mut i = pos + 1
  i = skip_ws(html, i, end)
  let (tag, after_tag) = read_word(html, i, end)
  if tag.length() == 0 {
    return Option::None
  }
  i = after_tag

  let attrs = Array::new(capacity=4)
  let mut parsing = true
  while parsing {
    i = skip_ws(html, i, end)
    if i >= end {
      parsing = false
      continue
    }
    let ch = char_at(html, i)
    if ch == 62 {
      i = i + 1
      parsing = false
      continue
    }
    if ch == 47 && i + 1 < end && char_at(html, i + 1) == 62 {
      return Option::Some(({ tag, attributes: attrs, children: [] }, i + 2))
    }
    let (name, after_name) = read_word(html, i, end)
    i = after_name
    if char_at(html, i) == 61 {
      i = i + 1
      let q = char_at(html, i)
      if q == 34 || q == 39 {
        i = i + 1
        let vs = i
        while i < end && char_at(html, i) != q {
          i = i + 1
        }
        let val = html.unsafe_substring(start=vs, end=i)
        i = i + 1
        if name.length() > 2 && name.unsafe_substring(start=0, end=2) == "on" {
          let ev_name = name.unsafe_substring(start=2, end=name.length())
          attrs.push(Attribute::Event(ev_name, val))
        } else {
          attrs.push(Attribute::Static(name, val))
        }
      } else if q == 123 {
        i = i + 1
        let vs = i
        let mut d = 1
        while i < end && d > 0 {
          let c = char_at(html, i)
          if c == 123 {
            d = d + 1
          } else if c == 125 {
            d = d - 1
            if d == 0 {
              break
            }
          }
          i = i + 1
        }
        let val = html.unsafe_substring(start=vs, end=i)
        i = i + 1
        if name.length() > 2 && name.unsafe_substring(start=0, end=2) == "on" {
          let ev_name = name.unsafe_substring(start=2, end=name.length())
          attrs.push(Attribute::Event(ev_name, val))
        } else {
          attrs.push(Attribute::Bind(name, val))
        }
      }
    } else {
      attrs.push(Attribute::Static(name, ""))
    }
  }

  let children = parse_nodes(html, i, end)

  let close_tag = "</" + tag + ">"
  let rest = html.unsafe_substring(start=i, end=end)
  let close_end = match rest.find(close_tag) {
    Option::Some(ct) => i + ct + close_tag.length()
    Option::None => end
  }

  Option::Some(({ tag, attributes: attrs, children }, close_end))
}

///|
fn parse_text(html : String, pos : Int, end : Int) -> (Array[TextChunk], Int)? {
  let parts = Array::new(capacity=4)
  let mut i = pos
  let mut ts = i
  while i < end {
    let ch = char_at(html, i)
    if ch == 60 {
      break
    }
    if ch == 123 {
      if i > ts {
        let raw = html.unsafe_substring(start=ts, end=i)
        let s = raw.trim().to_owned()
        if s.length() > 0 {
          parts.push(TextChunk::Static(s))
        }
      }
      i = i + 1
      let es = i
      let mut d = 1
      while i < end && d > 0 {
        let c = char_at(html, i)
        if c == 123 {
          d = d + 1
        } else if c == 125 {
          d = d - 1
          if d == 0 {
            break
          }
        }
        i = i + 1
      }
      let raw_expr = html.unsafe_substring(start=es, end=i)
      let expr = raw_expr.trim().to_owned()
      if expr.length() > 0 {
        parts.push(TextChunk::Expr(expr))
      }
      i = i + 1
      ts = i
    } else {
      i = i + 1
    }
  }
  if i > ts {
    let raw = html.unsafe_substring(start=ts, end=i)
    let s = raw.trim().to_owned()
    if s.length() > 0 {
      parts.push(TextChunk::Static(s))
    }
  }
  if parts.length() == 0 {
    Option::None
  } else {
    Option::Some((parts, i))
  }
}
