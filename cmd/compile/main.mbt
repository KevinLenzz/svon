extern "js" fn read_file(path : String) -> String =
  #| (path) => require("fs").readFileSync(path, "utf-8")

extern "js" fn write_file(path : String, content : String) -> Unit =
  #| (path, content) => require("fs").writeFileSync(path, content)

extern "js" fn mkdir(path : String) -> Unit =
  #| (path) => require("fs").mkdirSync(path, { recursive: true })

extern "js" fn list_dir(path : String) -> Array[String] =
  #| (path) => require("fs").readdirSync(path)

extern "js" fn get_args() -> Array[String] =
  #| () => process.argv.slice(2)

fn main {
  let args = get_args()
  if args.length() == 0 { print_help(); return }

  let cmd = args[0]
  if cmd == "--help" || cmd == "-h" { print_help(); return }
  if cmd == "new" && args.length() >= 2 { cmd_new(args); return }
  if cmd == "dev" { cmd_dev(args); return }
  if cmd.has_prefix("-") { print_help(); return }
  cmd_compile(args)
}

fn cmd_compile(args : Array[String]) -> Unit {
  let src = read_file(args[0])
  let out = @compiler.compile(src)
  println(out)
}

fn cmd_new(args : Array[String]) -> Unit {
  let name = args[1]
  mkdir(name)
  mkdir(name + "/pages")
  write_file(name + "/pages/index.svon", starter_template())
  write_file(name + "/moon.mod", moon_mod_text(name))
  write_file(name + "/README.md", readme_text(name))
  println("Created: " + name + "/")
  println("  cd " + name)
  println("  svonc pages/index.svon > cmd/site/main.mbt")
  println("  moon build cmd/site --target js")
  println("  python3 -m http.server 8080")
}

fn cmd_dev(args : Array[String]) -> Unit {
  println("Run: python3 -m http.server 8080")
}

fn print_help() -> Unit {
  println("Svon — reactive MoonBit templates")
  println("")
  println("Commands:")
  println("  svonc <file.svon>          Compile to stdout")
  println("  svonc new <name>           Scaffold new project")
  println("  svonc dev                  Serve current directory")
  println("")
}

fn starter_template() -> String {
  let b = StringBuilder::new()
  b.write_string("<script lang=\"moonbit\">\n")
  b.write_string("let count = state(0)\n")
  b.write_string("fn increment() { count.set(count.get() + 1) }\n")
  b.write_string("</script>\n\n")
  b.write_string("<div>\n")
  b.write_string("  <h1>Count: {count.get()}</h1>\n")
  b.write_string("  <button onclick={increment}>+</button>\n")
  b.write_string("</div>\n")
  b.to_string()
}

fn moon_mod_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("name = \"username/")
  b.write_string(name)
  b.write_string("\"\nversion = \"0.1.0\"\npreferred_target = \"js\"\n")
  b.to_string()
}

fn readme_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("# ")
  b.write_string(name)
  b.write_string("\n\nBuilt with Svon.\n\n```bash\nsvonc pages/index.svon > cmd/site/main.mbt\nmoon build cmd/site --target js\npython3 -m http.server 8080\n```\n")
  b.to_string()
}
