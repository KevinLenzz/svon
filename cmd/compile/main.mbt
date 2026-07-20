///| Reads a file synchronously from the filesystem using Node.js `fs.readFileSync`.
///| Returns the entire file contents as a UTF-8 encoded `String`.
///| This is a JS FFI binding — calls `require("fs").readFileSync(path, "utf-8")`.
extern "js" fn read_file(path : String) -> String =
  #| (path) => require("fs").readFileSync(path, "utf-8")

///| Writes a string to a file synchronously using Node.js `fs.writeFileSync`.
///| Overwrites the file if it already exists; creates it otherwise.
///| This is a JS FFI binding — calls `require("fs").writeFileSync(path, content)`.
extern "js" fn write_file(path : String, content : String) -> Unit =
  #| (path, content) => require("fs").writeFileSync(path, content)

///| Creates a directory (and any missing parent directories) synchronously.
///| Uses `fs.mkdirSync` with `recursive: true`, so it will not fail if the
///| directory already exists or if intermediate directories are missing.
///| This is a JS FFI binding — calls `require("fs").mkdirSync(path, { recursive: true })`.
extern "js" fn mkdir(path : String) -> Unit =
  #| (path) => require("fs").mkdirSync(path, { recursive: true })

///| Lists the names of all entries (files and directories) inside a directory.
///| Returns an `Array[String]` of entry names.
///| This is a JS FFI binding — calls `require("fs").readdirSync(path)`.
extern "js" fn list_dir(path : String) -> Array[String] =
  #| (path) => require("fs").readdirSync(path)

///| Retrieves command-line arguments passed to the Node.js process.
///| Slices off the first two elements (node executable path and script path),
///| returning only the user-supplied arguments as an `Array[String]`.
///| This is a JS FFI binding — calls `process.argv.slice(2)`.
extern "js" fn get_args() -> Array[String] =
  #| () => process.argv.slice(2)

///| Writes a message to stderr using `process.stderr.write`.
extern "js" fn write_stderr(msg : String) -> Unit =
  #| (msg) => process.stderr.write(msg)

///| Exit the process with the given code.
extern "js" fn exit(code : Int) -> Unit =
  #| (code) => process.exit(code)

///| Get the directory of the running script (used to locate bundled runtime files).
extern "js" fn cli_dir() -> String =
  #| () => __dirname

///| Entry point of the svonc CLI tool.
///|
///| Parses command-line arguments and dispatches to the appropriate subcommand:
///| - No arguments or `--help` / `-h`: prints help text.
///| - `new <name>`: scaffolds a new Svon project directory.
///| - `dev`: prints a hint for starting a local dev server.
///| - Any unrecognized flag starting with `-`: prints help text.
///| - Otherwise: treats the first argument as a `.svon` file path and compiles it to stdout.
fn main {
  // Retrieve CLI arguments (skipping `node` and script name).
  let args = get_args()
  // If no arguments, show help and exit.
  if args.length() == 0 { print_help(); return }

  let cmd = args[0]
  // Explicit help flag.
  if cmd == "--help" || cmd == "-h" { print_help(); return }
  // `new` command — expects at least a project name.
  if cmd == "new" && args.length() >= 2 { cmd_new(args); return }
  // `init` command — sets up shared svonlib/ in the given project directory.
  if cmd == "init" { cmd_init(args); return }
  // `dev` command — prints a dev server hint.
  if cmd == "dev" { cmd_dev(args); return }
  // Unrecognized flag-like argument (starts with `-`) → show help.
  if cmd.has_prefix("-") { print_help(); return }
  // Default: compile the given `.svon` file to stdout.
  cmd_compile(args)
}

///| Compiles a single `.svon` template file and writes the generated MoonBit
///| code to standard output.  Parse errors are printed to stderr before any
///| output is produced, so build pipelines fail with clear diagnostics.
fn cmd_compile(args : Array[String]) -> Unit {
  let src = read_file(args[0])
  let tmpl = @compiler.parse(src)
  if tmpl.diagnostics.length() > 0 {
    let err = @compiler.format_diagnostics(src, tmpl.diagnostics)
    write_stderr(err)
    write_stderr("\n")
    exit(1)
  }
  // Parse was clean — compile to MoonBit source and print.
  let out = @compiler.compile(src)
  println(out)
}

///| Scaffolds a new Svon project directory with the following structure:
///|
///| ```
///| <name>/
///|   pages/
///|     index.svon    ← starter template with a reactive counter
///|   moon.mod        ← MoonBit package manifest
///|   README.md       ← project README with build instructions
///| ```
///|
///| After scaffolding, prints the next steps: `cd` into the directory, compile
///| the starter page, build the MoonBit project for JS, and serve it locally.
fn cmd_new(args : Array[String]) -> Unit {
  let name = args[1]
  // Create the project root directory.
  mkdir(name)
  // Create the pages subdirectory for .svon templates.
  mkdir(name + "/pages")
  // Write the starter .svon template with a counter example.
  write_file(name + "/pages/index.svon", starter_template())
  // Write the MoonBit package manifest (moon.mod.json).
  write_file(name + "/moon.mod", moon_mod_text(name))
  // Write the project README.
  write_file(name + "/README.md", readme_text(name))
  // Print post-scaffold instructions.
  println("Created: " + name + "/")
  println("  cd " + name)
  println("  svonc init .                # initialize shared svonlib/")
  println("  svonc pages/index.svon > cmd/site/main.mbt")
  println("  moon build cmd/site --target js")
  println("  python3 -m http.server 8080")
}

///| Prints a hint for starting a local development server.
///| Uses Python's built-in HTTP server as a simple way to serve the built
///| JS output during development.
fn cmd_dev(args : Array[String]) -> Unit {
  println("Run: python3 -m http.server 8080")
}

///| Initialize a Svon project directory with a shared deps/svon/ runtime.
///| All pages in the project share one copy of the runtime, avoiding
///| duplication across individual page build directories.
///|
///| Usage: svonc init [dir]
fn cmd_init(args : Array[String]) -> Unit {
  let dir = if args.length() >= 2 { args[1] } else { "." }
  let svon_dep = dir + "/deps/svon"
  mkdir(svon_dep)
  let base = cli_dir()
  let files = ["types.mbt", "signal.mbt", "runtime.mbt", "dom.mbt", "state.mbt", "svon.mbt"]
  for i in 0..<files.length() {
    let name = files[i]
    write_file(svon_dep + "/" + name, read_file(base + "/runtime/" + name))
  }
  write_file(svon_dep + "/moon.pkg", "")
  // moon.mod.json — shared module manifest
  write_file(dir + "/moon.mod.json", "{\n  \"name\": \"local/svonpages\",\n  \"version\": \"0.1.0\",\n  \"preferred_target\": \"js\"\n}\n")
  write_stderr("Initialized " + dir + "/deps/svon/\n")
}

///| Prints the svonc CLI usage help text, listing all available commands
///| and their basic syntax.
fn print_help() -> Unit {
  println("Svon — reactive MoonBit templates")
  println("")
  println("Commands:")
  println("  svonc <file.svon>           Compile to stdout")
  println("  svonc init [dir]            Initialize project with shared svonlib/")
  println("  svonc new <name>            Scaffold new project")
  println("  svonc dev                   Serve current directory")
  println("")
}

///| Returns a starter `.svon` template string containing a simple reactive
///| counter component.
///|
///| The template demonstrates:
///| - A `<script lang="moonbit">` block with MoonBit logic (a `state` variable
///|   and an `increment` function).
///| - HTML markup with Svon template expressions (`{count.get()}` for
///|   interpolation and `onclick={increment}` for event binding).
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

///| Generates the content of a `moon.mod.json` file for a new Svon project.
///|
///| Produces a minimal MoonBit package manifest with:
///| - `name`: set to `"username/<name>"` (a placeholder namespace convention).
///| - `version`: `"0.1.0"`.
///| - `preferred_target`: `"js"` (Svon compiles to JavaScript).
fn moon_mod_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("name = \"username/")
  b.write_string(name)
  b.write_string("\"\nversion = \"0.1.0\"\npreferred_target = \"js\"\n")
  b.to_string()
}

///| Generates the content of a `README.md` file for a new Svon project.
///|
///| Includes the project name as a heading and a quick-start section with
///| the shell commands needed to compile the Svon templates, build the
///| MoonBit project, and serve the output locally.
fn readme_text(name : String) -> String {
  let b = StringBuilder::new()
  b.write_string("# ")
  b.write_string(name)
  b.write_string("\n\nBuilt with Svon.\n\n```bash\nsvonc pages/index.svon > cmd/site/main.mbt\nmoon build cmd/site --target js\npython3 -m http.server 8080\n```\n")
  b.to_string()
}
