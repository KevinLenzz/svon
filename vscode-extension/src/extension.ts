import * as vscode from "vscode";

const DIAG_SOURCE = "svon";
const fs = require("fs") as typeof import("fs");
const path = require("path") as typeof import("path");
const cp = require("child_process") as typeof import("child_process");

let svoncPath = "svonc";
let moonPath = path.join(process.env.HOME || "~", ".moon/bin/moon");
let outputChannel: vscode.OutputChannel | null = null;

function log(msg: string) {
  if (!outputChannel) outputChannel = vscode.window.createOutputChannel("Svon");
  outputChannel.appendLine(msg);
}

export function activate(context: vscode.ExtensionContext) {
  setupPaths(context);
  outputChannel = vscode.window.createOutputChannel("Svon");
  log("Svon extension activated, svonc=" + svoncPath + " moon=" + moonPath);

  const diag = vscode.languages.createDiagnosticCollection(DIAG_SOURCE);
  context.subscriptions.push(diag);

  let timer: NodeJS.Timeout | null = null;

  const doDiagnostics = (document: vscode.TextDocument) => {
    if (document.languageId !== "svon") return;

    // Quick regex checks always run immediately
    const quick = validateDocument(document);
    diag.set(document.uri, quick);

    // Full MoonBit check runs debounced (on save or 500ms idle)
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      const full = moonBitCheck(document, context);
      if (full) diag.set(document.uri, full);
    }, 500);
  };

  // Also check on save
  context.subscriptions.push(
    vscode.workspace.onDidSaveTextDocument((doc) => {
      if (doc.languageId === "svon") {
        const full = moonBitCheck(doc, context);
        if (full) diag.set(doc.uri, full);
      }
    }),
  );

  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument(doDiagnostics),
    vscode.workspace.onDidChangeTextDocument((e) => doDiagnostics(e.document)),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (editor) doDiagnostics(editor.document);
    }),
    vscode.workspace.onDidCloseTextDocument((doc) => diag.delete(doc.uri)),
  );

  vscode.workspace.textDocuments.forEach(doDiagnostics);
  vscode.languages.registerCompletionItemProvider("svon", new SvonCompletionProvider(), "{", " ", ".");
  vscode.languages.registerHoverProvider("svon", {
    provideHover(document, position) {
      if (!isInsideScript(document, position)) return null;
      const wordRange = document.getWordRangeAtPosition(position);
      if (!wordRange) return null;
      const word = document.getText(wordRange);
      const docs = getApiDoc(word);
      return docs ? new vscode.Hover(new vscode.MarkdownString(docs)) : null;
    },
  });
  console.log("Svon extension activated");
}

function setupPaths(_context: vscode.ExtensionContext) {
  svoncPath = vscode.workspace.getConfiguration("svon").get<string>("svoncPath", "svonc");
  // 1. env var, 2. vscode config, 3. $PATH, 4. common paths, 5. fallback
  // 1. env var, 2. config, 3. default install, 4. $PATH
  const homeMoon = path.join(process.env.HOME || "~", ".moon/bin/moon");
  moonPath = process.env.MOON
    || vscode.workspace.getConfiguration("svon").get<string>("moonPath", "")
    || (fs.existsSync(homeMoon) ? homeMoon : "")
    || which("moon")
    || which("mbt")
    || homeMoon;
}

function which(cmd: string): string | undefined {
  try {
    return cp.execSync(`which ${cmd}`, { encoding: "utf-8" }).trim() || undefined;
  } catch { return undefined; }
}

// ---------------- MoonBit check engine ----------------

function moonBitCheck(
  document: vscode.TextDocument,
  _context: vscode.ExtensionContext,
): vscode.Diagnostic[] {
  try {
    const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!wsRoot) return [];
    const projectDir = path.join(wsRoot, ".svon-cache");
    ensureProject(projectDir, wsRoot);

    const tmpSvon = path.join(projectDir, "_check.svon");
    fs.writeFileSync(tmpSvon, document.getText());

    log("Running svonc " + tmpSvon);
    const raw = cp.execSync(`${svoncPath} ${tmpSvon}`, { encoding: "utf-8" });
    if (raw.startsWith("// ==================================================")) {
      log("svonc compile failed (parse errors)");
      return [];
    }

    const genDir = path.join(projectDir, "gen");
    fs.mkdirSync(genDir, { recursive: true });
    fs.writeFileSync(path.join(genDir, "main.mbt"), raw);

    log("Running moon check in " + projectDir);
    const out = cp.execSync(`${moonPath} -C ${projectDir} check gen --target js`, { encoding: "utf-8" });
    return remapDiagnostics(out, document, raw);
  } catch (e: any) {
    const out = String(e.stdout || "") + String(e.stderr || "");
    log("moon check output (" + (out.length) + " chars): " + out.slice(0, 300));
    const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath || "";
    const genDir = path.join(wsRoot, ".svon-cache", "gen");
    const raw = fs.existsSync(path.join(genDir, "main.mbt")) ? fs.readFileSync(path.join(genDir, "main.mbt"), "utf-8") : "";
    return remapDiagnostics(out, document, raw);
  }
}

// ---------------- Project scaffolding ----------------

let projectReady = false;
function ensureProject(projectDir: string, _wsRoot: string) {
  if (projectReady && fs.existsSync(path.join(projectDir, "deps", "svon", "types.mbt"))) return;

  fs.mkdirSync(projectDir, { recursive: true });
  log("Initializing project cache at " + projectDir);
  cp.execSync(`${svoncPath} init ${projectDir}`, { encoding: "utf-8" });

  const genDir = path.join(projectDir, "gen");
  fs.mkdirSync(genDir, { recursive: true });
  fs.writeFileSync(path.join(genDir, "moon.pkg"),
    'import { "local/svonpages/deps/svon" @svon, }\nsupported_targets = "js"\noptions("is-main": true)\n');

  projectReady = true;
}

// ---------------- Remapping ----------------

function remapDiagnostics(
  output: string,
  document: vscode.TextDocument,
  mbtContent: string,
): vscode.Diagnostic[] {
  const diags: vscode.Diagnostic[] = [];
  const sourceLines = document.getText().split("\n");
  const map = buildMap(mbtContent);

  let severity = vscode.DiagnosticSeverity.Error;
  const outLines = output.split("\n");
  for (let i = 0; i < outLines.length; i++) {
    const line = outLines[i];
    if (line.startsWith("Warning:")) severity = vscode.DiagnosticSeverity.Warning;
    if (line.startsWith("Error:")) severity = vscode.DiagnosticSeverity.Error;

    const m = line.match(/main\.mbt:(\d+):(\d+)/);
    if (!m) continue;

    const genLine = parseInt(m[1]);
    const col = parseInt(m[2]);
    const srcLine = map[genLine] || genLine;
    const lineIdx = srcLine - 1;

    if (lineIdx < 0 || lineIdx >= sourceLines.length) continue;

    // Collect error message from subsequent lines (look for ╰─ line)
    let msg = "";
    for (let j = i + 1; j < outLines.length; j++) {
      const nl = outLines[j];
      if (nl.includes("───╯") || nl.startsWith("Error:") || nl.startsWith("Warning:")) break;
      const idx = nl.indexOf("╰─");
      if (idx >= 0) {
        msg = nl.substring(idx + 2).trim();
        break;
      }
    }
    if (!msg) msg = "See output for details";

    const startPos = new vscode.Position(lineIdx, Math.max(0, col - 1));
    const endPos = new vscode.Position(lineIdx, Math.min(sourceLines[lineIdx]?.length || col, col));

    diags.push({
      severity,
      range: new vscode.Range(startPos, endPos),
      message: msg.slice(0, 200),
      source: DIAG_SOURCE,
    });
  }

  log("remapDiagnostics: " + diags.length + " diagnostics from " + output.split("\n").length + " lines, map has " + Object.keys(map).length + " entries, doc=" + document.fileName);

  for (const d of validateDocument(document)) {
    if (!diags.some((e) => e.range.isEqual(d.range))) diags.push(d);
  }

  return diags;
}

function buildMap(mbt: string): Record<number, number> {
  const map: Record<number, number> = {};
  const lines = mbt.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/@svon-line:(\d+)/);
    if (m) map[i + 1] = parseInt(m[1]);
  }
  return map;
}

// ---------------- quick regex diagnostics (unchanged) ----------------

function validateDocument(document: vscode.TextDocument): vscode.Diagnostic[] {
  const diags: vscode.Diagnostic[] = [];
  const text = document.getText();
  const scriptRegex = /<script\s+lang\s*=\s*"moonbit"\s*(import\s*=\s*"[^"]*")?\s*>/g;
  let m: RegExpExecArray | null;
  let hasScript = false;
  while ((m = scriptRegex.exec(text)) !== null) {
    hasScript = true;
    const tagLen = m[0].length;
    const start = m.index + tagLen;
    const endTag = text.indexOf("</script>", start);
    const end = endTag >= 0 ? endTag : text.length;
    validateMoonBitBlock(text.substring(start, end), start, document, diags);
  }
  if (!hasScript) {
    diags.push({
      severity: vscode.DiagnosticSeverity.Warning,
      range: new vscode.Range(0, 0, 0, 1),
      message: 'Missing <script lang="moonbit"> block',
      source: DIAG_SOURCE,
    });
  }
  checkUnclosedBrace(text.replace(/<script[\s\S]*?<\/script>/g, ""), document, diags);
  return diags;
}

function validateMoonBitBlock(
  code: string, offset: number, document: vscode.TextDocument, diags: vscode.Diagnostic[],
) {
  const lines = code.split("\n");
  let lineOffset = offset;
  for (const line of lines) {
    const len = line.length;
    if (/\b(state|derived|effect)\s*$/m.test(line) && !/\bfn\s+(state|derived|effect)\b/.test(line)) {
      const match = line.match(/\b(state|derived|effect)\b/g);
      if (match) {
        const word = match[match.length - 1];
        const idx = line.lastIndexOf(word);
        diags.push({
          severity: vscode.DiagnosticSeverity.Warning,
          range: new vscode.Range(document.positionAt(lineOffset + idx), document.positionAt(lineOffset + idx + word.length)),
          message: `${word} is called as ${word}(...) — missing parentheses?`,
          source: DIAG_SOURCE,
        });
      }
    }
    const fnMatch = line.match(/^\s*fn\s+(\w+)\s*\(/);
    if (fnMatch && !/\)\s*(->|:)/.test(line)) {
      const idx = line.indexOf("fn");
      diags.push({
        severity: vscode.DiagnosticSeverity.Information,
        range: new vscode.Range(document.positionAt(lineOffset), document.positionAt(lineOffset + len)),
        message: `Local function '${fnMatch[1]}': consider adding return type '-> Unit'`,
        source: DIAG_SOURCE,
      });
    }
    lineOffset += len + 1;
  }
}

function checkUnclosedBrace(html: string, document: vscode.TextDocument, diags: vscode.Diagnostic[]) {
  let depth = 0;
  let lastOpen = -1;
  for (let i = 0; i < html.length; i++) {
    if (html[i] === "{") { if (depth === 0) lastOpen = i; depth++; }
    else if (html[i] === "}") { depth--; }
  }
  if (depth > 0 && lastOpen >= 0) {
    const p = document.positionAt(lastOpen);
    diags.push({
      severity: vscode.DiagnosticSeverity.Error,
      range: new vscode.Range(p, p.translate(0, 1)),
      message: `Unclosed expression — missing ${depth} closing brace(s)`,
      source: DIAG_SOURCE,
    });
  }
}

// ---------------- completion / hover (unchanged) ----------------

function isInsideScript(document: vscode.TextDocument, position: vscode.Position): boolean {
  const text = document.getText();
  const offset = document.offsetAt(position);
  const before = text.substring(0, offset);
  const open = /<script\s+lang\s*=\s*"moonbit"[^>]*>/g;
  const close = /<\/script>/g;
  let lastOpen = -1, lastClose = -1, m: RegExpExecArray | null;
  while ((m = open.exec(before)) !== null) lastOpen = m.index;
  while ((m = close.exec(before)) !== null) lastClose = m.index;
  return lastOpen > lastClose && lastOpen >= 0;
}

class SvonCompletionProvider implements vscode.CompletionItemProvider {
  provideCompletionItems(): vscode.CompletionItem[] {
    return [
      ci("state", "state(init)", "Create reactive state variable"),
      ci("derived", "derived(fn() { ... })", "Create computed derived value"),
      ci("effect", "effect(fn() { ...; Option::None })", "Create reactive side-effect"),
      ci("fn", "fn name() -> Unit { }", "Define a function"),
      ci("let", "let name = value", "Bind a variable"),
      ci("State", "State[T]", "Reactive state type"),
      ci("Derived", "Derived[T]", "Derived value type"),
      ci(".get()", ".get()", "Read reactive value (tracked)"),
      ci(".set(", ".set(value)", "Write reactive value"),
      ci("read_source", "read_source(s)", "Read Source, track dependency"),
      ci("write_source", "write_source(s, val)", "Write Source, propagate dirtiness"),
      ci("read_derived", "read_derived(d)", "Read Derived with lazy compute"),
      ci("untrack", "untrack(fn() { ... })", "Suppress dependency tracking"),
      ci("Option::None", "Option::None", "No cleanup (effect return)"),
    ];
  }
}

function ci(label: string, detail: string, doc: string): vscode.CompletionItem {
  const item = new vscode.CompletionItem(label);
  item.detail = detail;
  item.documentation = new vscode.MarkdownString(doc);
  item.kind = vscode.CompletionItemKind.Function;
  return item;
}

function getApiDoc(word: string): string | null {
  const docs: Record<string, string> = {
    state: "**state(init)** — create a writable reactive signal.\n\nEquivalent to Svelte's `$state()`.",
    derived: "**derived(fn)** — create a computed reactive value.\n\nAuto-tracks dependencies. Equivalent to `$derived()`.",
    effect: "**effect(fn)** — create a reactive side-effect.\n\nRe-runs when dependencies change. Return `Option::None` for no cleanup.\n\nEquivalent to Svelte's `$effect()`.",
    "State::get": "**State::get()** — read value, tracking it as a dependency.",
    "State::set": "**State::set(v)** — write value, dirtying all dependents.",
    "Derived::get": "**Derived::get()** — read computed value. Lazily recomputes if dirty.",
  };
  return docs[word] || null;
}

export function deactivate() {}
