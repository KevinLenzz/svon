///|
extern "js" fn read_file(path : String) -> String =
  #| (path) => require("fs").readFileSync(path, "utf-8")

///|
extern "js" fn write_file(path : String, content : String) -> Unit =
  #| (path, content) => require("fs").writeFileSync(path, content)

///|
extern "js" fn mkdir(path : String) -> Unit =
  #| (path) => require("fs").mkdirSync(path, { recursive: true })

///|
extern "js" fn list_dir(path : String) -> Array[String] =
  #| (path) => require("fs").readdirSync(path)

///|
extern "js" fn file_exists(path : String) -> Bool =
  #| (path) => require("fs").existsSync(path)

///|
extern "js" fn copy_file(src : String, dst : String) -> Unit =
  #| (src, dst) => require("fs").copyFileSync(src, dst)

///|
extern "js" fn get_args() -> Array[String] =
  #| () => process.argv.slice(2)

///|
extern "js" fn write_stderr(msg : String) -> Unit =
  #| (msg) => process.stderr.write(msg)

///|
extern "js" fn exit(code : Int) -> Unit =
  #| (code) => process.exit(code)

///|
extern "js" fn cli_dir() -> String =
  #| () => __dirname

///|
extern "js" fn run(cmd : String) -> String =
  #| (cmd) => __svonc_run(cmd)

///|
extern "js" fn moon_path() -> String =
  #| () => process.env.MOON || "/home/kevinlenz/.moon/bin/moon"

///|
fn print_help() -> Unit {
  println("Svon — reactive MoonBit templates")
  println("")
  println("Commands:")
  println("  svonc <file.svon>              Compile to stdout")
  println("  svonc init [dir]               Initialize project with deps/svon/")
  println(
    "  svonc page <svon> <out_dir>    Generate page dir (main.mbt + moon.pkg)",
  )
  println(
    "  svonc build [dir]              Build project (pages/*.svon → out/)",
  )
  println("  svonc new <name>               Scaffold new project")
  println("")
}

///|
fn main {
  let args = get_args()
  if args.length() == 0 {
    print_help()
    return
  }
  let cmd = args[0]
  if cmd == "--help" || cmd == "-h" {
    print_help()
    return
  }
  if cmd == "new" && args.length() >= 2 {
    cmd_new(args)
    return
  }
  if cmd == "init" {
    cmd_init(args)
    return
  }
  if cmd == "page" {
    cmd_page(args)
    return
  }
  if cmd == "build" {
    cmd_build(args)
    return
  }
  if cmd.has_prefix("-") {
    print_help()
    return
  }
  cmd_compile(args)
}

///|
fn cmd_compile(args : Array[String]) -> Unit {
  let src = read_file(args[0])
  let tmpl = @compiler.parse(src)
  if tmpl.diagnostics.length() > 0 {
    write_stderr(@compiler.format_diagnostics(src, tmpl.diagnostics))
    write_stderr("\n")
    exit(1)
  }
  println(@compiler.compile(src))
}

///|
fn cmd_new(args : Array[String]) -> Unit {
  let name = args[1]
  mkdir(name)
  ensure_init(name)
  println("Created: " + name + "/")
  println("  cd " + name)
  println("  svonc build")
}

///|
fn cmd_init(args : Array[String]) -> Unit {
  let dir = if args.length() >= 2 { args[1] } else { "." }
  let svon_dep = dir + "/deps/svon"
  mkdir(svon_dep)
  let base = cli_dir()
  let files = [
    "types.mbt", "signal.mbt", "runtime.mbt", "dom.mbt", "state.mbt", "svon.mbt",
  ]
  for i in 0..<files.length() {
    let name = files[i]
    write_file(svon_dep + "/" + name, read_file(base + "/runtime/" + name))
  }
  write_file(svon_dep + "/moon.pkg", "")
  let project_name = dir_name(dir)
  write_file(dir + "/moon.mod", moon_mod_text(project_name))
  // Scaffold pages/ with starter template if not already present
  let pages_dir = dir + "/pages"
  if !file_exists(pages_dir + "/index.svon") {
    mkdir(pages_dir)
    write_file(pages_dir + "/index.svon", starter_template())
  }
  write_file(dir + "/README.md", readme_text(project_name))
  write_stderr("Initialized " + dir + "/\n")
}

///|
fn cmd_page(args : Array[String]) -> Unit {
  if args.length() < 3 {
    write_stderr("Usage: svonc page <file.svon> <output_dir>\n")
    exit(1)
  }
  let input = args[1]
  let output = args[2]
  let src = read_file(input)
  let tmpl = @compiler.parse(src)
  if tmpl.diagnostics.length() > 0 {
    write_stderr(@compiler.format_diagnostics(src, tmpl.diagnostics))
    write_stderr("\n")
    exit(1)
  }
  let code = @compiler.compile(src)
  mkdir(output)
  write_file(output + "/main.mbt", code)
  write_file(output + "/moon.pkg", moon_pkg_text(read_project_name(output)))
  write_stderr("Generated " + output + "/\n")
}

///|
fn moon_pkg_text(project : String) -> String {
  "import { \"local/" +
  project +
  "/deps/svon\" @svon, }\nsupported_targets = \"js\"\noptions(\"is-main\": true)\n"
}

///|
fn read_project_name(from : String) -> String {
  let mut dir = from
  while true {
    let path = dir + "/moon.mod"
    if file_exists(path) {
      let content = read_file(path)
      // Parse: name = "local/xxx"
      match content.find("\"local/") {
        Option::Some(pos) => {
          let start = pos + "\"local/".length()
          let mut end = start
          while end < content.length() && content[end] != 34 {
            end = end + 1
          }
          if end > start {
            return content.unsafe_substring(start~, end~)
          }
        }
        Option::None => ()
      }
    }
    if dir == "." || dir == "" {
      break
    }
    let mut pos = dir.length() - 1
    while pos > 0 && dir[pos] != 47 {
      pos = pos - 1
    }
    if pos > 0 {
      dir = dir.unsafe_substring(start=0, end=pos)
    } else {
      dir = "."
    }
  }
  dir_name(from)
}

///|
extern "js" fn cwd() -> String =
  #| () => process.cwd()

///|
fn dir_name(path : String) -> String {
  let s = if path == "." { cwd() } else { path }
  // Strip trailing /
  let mut end = s.length()
  while end > 0 && s[end - 1] == 47 {
    end = end - 1
  }
  if end == 0 {
    return ""
  }
  // Find last /
  let mut start = end - 1
  while start > 0 && s[start] != 47 {
    start = start - 1
  }
  if s[start] == 47 {
    start = start + 1
  }
  s.unsafe_substring(start~, end~)
}

///|
/// Build all pages/*.svon in a project, or a single file.
///   svonc build [dir]                build all pages
///   svonc build <file> <out_dir>     build single page
fn cmd_build(args : Array[String]) -> Unit {
  if args.length() >= 3 {
    build_page(args[1], args[2])
    return
  }
  let dir = if args.length() >= 2 { args[1] } else { "." }
  ensure_init(dir)
  let pages = list_dir(dir + "/pages")
  mkdir(dir + "/out")
  for i in 0..<pages.length() {
    let f = pages[i]
    if !f.has_suffix(".svon") {
      continue
    }
    let name = f.unsafe_substring(start=0, end=f.length() - ".svon".length())
    build_page(dir + "/pages/" + f, dir + "/gen/" + name)
    let out = dir + "/out"
    copy_file(
      dir + "/_build/js/debug/build/gen/" + name + "/" + name + ".js",
      out + "/" + name + ".js",
    )
    copy_file(dir + "/gen/" + name + "/index.html", out + "/" + name + ".html")
    write_stderr("  " + name + " → out/" + name + ".html\n")
  }
  write_stderr("Done: out/\n")
}

///|
fn ensure_init(dir : String) -> Unit {
  let svon_dep = dir + "/deps/svon"
  let base = cli_dir()
  mkdir(svon_dep)
  let rts = [
    "types.mbt", "signal.mbt", "runtime.mbt", "dom.mbt", "state.mbt", "svon.mbt",
  ]
  for i in 0..<rts.length() {
    let n = rts[i]
    write_file(svon_dep + "/" + n, read_file(base + "/runtime/" + n))
  }
  write_file(svon_dep + "/moon.pkg", "")
  write_file(dir + "/moon.mod", moon_mod_text(dir_name(dir)))
  let pages_dir = dir + "/pages"
  if !file_exists(pages_dir + "/index.svon") {
    mkdir(pages_dir)
    write_file(pages_dir + "/index.svon", starter_template())
  }
  write_file(dir + "/README.md", readme_text(dir_name(dir)))
  write_stderr("Initialized " + dir + "/\n")
}

///|
fn build_page(input : String, output : String) -> Unit {
  let src = read_file(input)
  let tmpl = @compiler.parse(src)
  if tmpl.diagnostics.length() > 0 {
    write_stderr(@compiler.format_diagnostics(src, tmpl.diagnostics))
    write_stderr("\n")
    exit(1)
  }
  let code = @compiler.compile(src)
  mkdir(output)
  write_file(output + "/main.mbt", code)
  write_file(output + "/moon.pkg", moon_pkg_text(read_project_name(output)))
  write_file(output + "/index.html", page_html(input))

  let raw = run(moon_path() + " build " + output + " --target js")
  let (out, ec) = strip_exit(raw)
  println(remap_output(out, input, code))
  if ec != 0 {
    exit(ec)
  }
}

///|
fn page_html(path : String) -> String {
  let name = page_name(path)
  let b = StringBuilder::new()
  b.write_string("<!DOCTYPE html><html lang=\"en\">\n")
  b.write_string(
    "<head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">\n",
  )
  b.write_string("<title>")
  b.write_string(name)
  b.write_string("</title></head>\n")
  b.write_string("<body><script src=\"")
  b.write_string(name)
  b.write_string(".js\"></script></body></html>\n")
  b.to_string()
}

///|
fn page_name(path : String) -> String {
  let s = path
  let mut start = s.length() - 1
  while start > 0 && s[start] != 47 {
    start = start - 1
  }
  if s[start] == 47 {
    start = start + 1
  }
  let mut end = start
  while end < s.length() && s[end] != 46 {
    end = end + 1
  }
  s.unsafe_substring(start~, end~)
}

///|
fn strip_exit(s : String) -> (String, Int) {
  match s.find("\nSVONC_EXIT:") {
    Option::Some(pos) => {
      let num = s
        .unsafe_substring(start=pos + "\nSVONC_EXIT:".length(), end=s.length())
        .trim()
        .to_owned()
      (s.unsafe_substring(start=0, end=pos), parse_int(num))
    }
    Option::None => (s, 0)
  }
}

///|
fn remap_output(raw : String, svon_file : String, mbt : String) -> String {
  let map = build_remap(mbt)
  let b = StringBuilder::new()
  let lines = raw.split("\n")
  for line in lines {
    let s = line.to_owned()
    if s.contains("deps/svon/") {
      continue
    }
    b.write_string(remap_line(s, svon_file, map))
    b.write_string("\n")
  }
  b.to_string()
}

///|
fn parse_int(s : String) -> Int {
  let mut n = 0
  for i in 0..<s.length() {
    let c = s[i]
    if c >= 48 && c <= 57 {
      n = n * 10 + (c.to_int64() - 48).to_int()
    } else {
      break
    }
  }
  n
}

///|
fn build_remap(mbt : String) -> Array[Int] {
  let arr = Array::new(capacity=64)
  let lines = mbt.split("\n")
  let mut n = 1
  for l in lines {
    let s = l.to_owned()
    match s.find("@svon-line:") {
      Option::Some(pos) => {
        let after = pos + "@svon-line:".length()
        let mut i = after
        while i < s.length() && s[i] >= 48 && s[i] <= 57 {
          i = i + 1
        }
        if i > after {
          let num = parse_int(s.unsafe_substring(start=after, end=i))
          while arr.length() < n {
            arr.push(-1)
          }
          arr.push(num)
        } else {
          while arr.length() <= n {
            arr.push(-1)
          }
        }
      }
      Option::None =>
        while arr.length() <= n {
          arr.push(-1)
        }
    }
    n = n + 1
  }
  arr
}

///|
fn remap_line(line : String, svon_file : String, map : Array[Int]) -> String {
  let mut result = line
  let mut pos = 0
  while pos + 9 < result.length() {
    match
      result.unsafe_substring(start=pos, end=result.length()).find("main.mbt:") {
      Option::Some(found) => {
        let main_pos = pos + found
        let num_start = main_pos + 9
        let mut num_end = num_start
        while num_end < result.length() &&
              result[num_end] >= 48 &&
              result[num_end] <= 57 {
          num_end = num_end + 1
        }
        if num_end > num_start &&
          num_end < result.length() &&
          result[num_end] == 58 {
          let mut col_end = num_end + 1
          while col_end < result.length() &&
                result[col_end] >= 48 &&
                result[col_end] <= 57 {
            col_end = col_end + 1
          }
          let gen = parse_int(
            result.unsafe_substring(start=num_start, end=num_end),
          )
          let src = if gen > 0 && gen < map.length() && map[gen] > 0 {
            map[gen]
          } else {
            gen
          }
          let mut path_start = main_pos
          while path_start > 0 &&
                result[path_start - 1] != 32 &&
                result[path_start - 1] != 91 {
            path_start = path_start - 1
          }
          let before = result.unsafe_substring(start=0, end=path_start)
          let after = result.unsafe_substring(
            start=col_end,
            end=result.length(),
          )
          let col_str = result.unsafe_substring(start=num_end + 1, end=col_end)
          result = before +
            svon_file +
            ":" +
            src.to_string() +
            ":" +
            col_str +
            after
          pos = main_pos + svon_file.length()
          continue
        }
        pos = main_pos + 1
      }
      Option::None => break
    }
  }
  result
}

///|
fn starter_template() -> String {
  let b = StringBuilder::new()
  b.write_string("<script lang=\"moonbit\">\n")
  b.write_string("let count = state(0)\n")
  b.write_string("fn increment() { count.set(count.get() + 1) }\n")
  b.write_string("</script>\n\n")
  b.write_string("<div>\n")
  b.write_string("  <h1>Welcome to Svon. Count: {count.get()}</h1>\n")
  b.write_string("  click this: <button onclick={increment}>+</button>\n")
  b.write_string("</div>\n")
  b.to_string()
}

///|
fn moon_mod_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("name = \"local/")
  b.write_string(name)
  b.write_string("\"\nversion = \"0.1.0\"\npreferred_target = \"js\"\n")
  b.to_string()
}

///|
fn readme_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("# ")
  b.write_string(name)
  b.write_string(
    "\n\nBuilt with Svon.\n\n```bash\nsvonc init .\nsvonc build\n```\n",
  )
  b.to_string()
}
