/// Black-box tests for the Svon template compiler.

fn tpl(script : String, html : String) -> String {
  let b = StringBuilder::new()
  b.write_string("<script lang=\"moonbit\">\n")
  b.write_string(script)
  b.write_string("\n</script>\n\n")
  b.write_string(html)
  b.to_string()
}

test "extract script block" {
  let input = tpl(
    "let count = state(0)\nlet doubled = derived(fn() { count.get() * 2 })",
    "<h1>Hello</h1>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("@svon.state(0)"), content="true")
  inspect(result.contains("@svon.derived"), content="true")
}

test "generate static text node" {
  let input = tpl("", "<p>Hello World</p>")
  let result = @compiler.compile(input)
  inspect(result.contains("document_create_text_node(\"Hello World\")"), content="true")
  inspect(result.contains("node_append_child"), content="true")
}

test "generate expression text binding" {
  let input = tpl(
    "let name = state(\"Svon\")",
    "<h1>{name.get()}</h1>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("@svon.effect"), content="true")
  inspect(result.contains("node_set_text_content"), content="true")
}

test "generate element with attribute" {
  let input = tpl(
    "let cls = state(\"container\")",
    "<div class=\"container\"><span>text</span></div>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("document_create_element(\"div\")"), content="true")
  inspect(result.contains("document_create_element(\"span\")"), content="true")
  inspect(result.contains("node_set_attribute"), content="true")
}

test "generate event handler" {
  let input = tpl(
    "let count = state(0)\nfn increment() {\n  count.set(count.get() + 1)\n}",
    "<button onclick={increment}>+</button>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("node_add_event_listener"), content="true")
  inspect(result.contains("increment"), content="true")
}

test "parse nested elements" {
  let input = tpl(
    "let text = state(\"nested\")",
    "<div><p><span>{text.get()}</span></p></div>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("document_create_element(\"div\")"), content="true")
  inspect(result.contains("document_create_element(\"p\")"), content="true")
  inspect(result.contains("document_create_element(\"span\")"), content="true")
  inspect(result.contains("@svon.effect"), content="true")
}

test "transforms state() calls" {
  let input = tpl(
    "let a = state(1)\nlet b = state(\"hello\")",
    "<div></div>",
  )
  let result = @compiler.compile(input)
  inspect(result.contains("@svon.state(1)"), content="true")
  inspect(result.contains("@svon.state(\"hello\")"), content="true")
}

test "generate project files" {
  let input = tpl("", "<h1>Hello Svon</h1>")
  let (main_mbt, index_html, moon_pkg) = @compiler.generate_project(input, "testapp")
  inspect(main_mbt.contains("fn main"), content="true")
  inspect(main_mbt.contains("document_create_element"), content="true")
  inspect(index_html.contains("<!DOCTYPE html>"), content="true")
  inspect(index_html.contains("<title>testapp"), content="true")
  inspect(moon_pkg.contains("is-main"), content="true")
}

test "parse html comments" {
  let src = "<p>before</p>\n<!-- comment -->\n<p>after</p>"
  let tmpl = @compiler.parse(src)
  inspect(tmpl.nodes.length(), content="2")
}

test "parse style block" {
  let src = "<style>\nh1 { color: red; }\n</style>\n\n<p>Hello</p>"
  let tmpl = @compiler.parse(src)
  inspect(tmpl.styles.contains("color: red"), content="true")
  inspect(tmpl.nodes.length(), content="1")
}

test "generate style injection" {
  let src = "<style>\nh1 { color: red; }\n</style>\n\n<p>Hello</p>"
  let code = @compiler.compile(src)
  inspect(code.contains("document_create_element(\"style\")"), content="true")
  inspect(code.contains("document_head"), content="true")
  inspect(code.contains("color: red"), content="true")
}

test "diagnostic on unclosed tag" {
  let src = "<div><p>hello</div>"
  let tmpl = @compiler.parse(src)
  inspect(tmpl.diagnostics.length(), content="1")
  inspect(tmpl.diagnostics[0].code, content="unclosed-tag")
  inspect(tmpl.diagnostics[0].message.contains("<p>"), content="true")
}

test "diagnostic on unclosed brace" {
  let src = "<p>{count</p>"
  let tmpl = @compiler.parse(src)
  inspect(tmpl.diagnostics.length(), content="1")
  inspect(tmpl.diagnostics[0].code, content="unclosed-brace")
}

test "diagnostic on empty tag name" {
  let src = "<></>"
  let tmpl = @compiler.parse(src)
  inspect(tmpl.diagnostics.length(), content="1")
  inspect(tmpl.diagnostics[0].code, content="empty-tag-name")
}

test "compile emits errors as comments" {
  let src = "<div><p>hello</div>"
  let code = @compiler.compile(src)
  inspect(code.contains("Svon compilation failed"), content="true")
  inspect(code.contains("unclosed-tag"), content="true")
  inspect(code.contains("_svon_compile_error"), content="true")
}

test "no diagnostics on valid template" {
  let src = tpl("let x = state(0)", "<div><p>ok</p></div>")
  let tmpl = @compiler.parse(src)
  inspect(tmpl.diagnostics.length(), content="0")
  inspect(tmpl.nodes.length(), content="1")
}
