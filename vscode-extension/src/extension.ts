import * as vscode from "vscode";

const DIAG_SOURCE = "svon";

export function activate(context: vscode.ExtensionContext) {
  const diag = vscode.languages.createDiagnosticCollection(DIAG_SOURCE);
  context.subscriptions.push(diag);

  const doDiagnostics = (document: vscode.TextDocument) => {
    if (document.languageId !== "svon") return;
    diag.set(document.uri, validateDocument(document));
  };

  // Trigger on open, change, and editor switch
  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument(doDiagnostics),
    vscode.workspace.onDidChangeTextDocument((e) => doDiagnostics(e.document)),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (editor) doDiagnostics(editor.document);
    }),
    vscode.workspace.onDidCloseTextDocument((doc) => diag.delete(doc.uri)),
  );

  // Run on all open .svon files
  vscode.workspace.textDocuments.forEach(doDiagnostics);

  // Completion
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider(
      "svon",
      new SvonCompletionProvider(),
      "{",
      " ",
      ".",
    ),
  );

  // Hover for reactive API
  context.subscriptions.push(
    vscode.languages.registerHoverProvider("svon", {
      provideHover(document, position) {
        if (!isInsideScript(document, position)) return null;

        const wordRange = document.getWordRangeAtPosition(position);
        if (!wordRange) return null;

        const word = document.getText(wordRange);
        const docs = getApiDoc(word);
        if (docs) {
          return new vscode.Hover(
            new vscode.MarkdownString(docs),
          );
        }
        return null;
      },
    }),
  );

  console.log("Svon extension activated");
}

// ---------------- diagnostics ----------------

function validateDocument(
  document: vscode.TextDocument,
): vscode.Diagnostic[] {
  const diags: vscode.Diagnostic[] = [];
  const text = document.getText();

  // Parse <script lang="moonbit"> blocks
  const scriptRegex =
    /<script\s+lang\s*=\s*"moonbit"\s*(import\s*=\s*"[^"]*")?\s*>/g;

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
    const diag = new vscode.Diagnostic(
      new vscode.Range(0, 0, 0, 1),
      'Missing <script lang="moonbit"> block',
      vscode.DiagnosticSeverity.Warning,
    );
    diag.source = DIAG_SOURCE;
    diags.push(diag);
  }

  // Check unclosed { } expressions in HTML portion
  checkUnclosedBrace(
    text.replace(/<script[\s\S]*?<\/script>/g, ""),
    document,
    diags,
  );

  return diags;
}

function validateMoonBitBlock(
  code: string,
  offset: number,
  document: vscode.TextDocument,
  diags: vscode.Diagnostic[],
) {
  const lines = code.split("\n");
  let lineOffset = offset;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const len = line.length;

    // Bare state/derived/effect without parentheses
    if (
      /\b(state|derived|effect)\s*$/m.test(line) &&
      !/\bfn\s+(state|derived|effect)\b/.test(line)
    ) {
      const match = line.match(/\b(state|derived|effect)\b/g);
      if (match) {
        const word = match[match.length - 1];
        const idx = line.lastIndexOf(word);
        diags.push({
          severity: vscode.DiagnosticSeverity.Warning,
          range: new vscode.Range(
            document.positionAt(lineOffset + idx),
            document.positionAt(lineOffset + idx + word.length),
          ),
          message: `${word} is called as ${word}(...) — missing parentheses?`,
          source: DIAG_SOURCE,
        });
      }
    }

    // Unused variables (basic check: let x = ... but x never used)
    const letMatch = line.match(/^\s*let\s+(\w+)\s*[:=]/);
    if (letMatch) {
      const varName = letMatch[1];
      const rest = code.substring(i + 1 < lines.length ? 0 : 0); // stub
    }

    // Missing -> return type on local fns
    const fnMatch = line.match(/^\s*fn\s+(\w+)\s*\(/);
    if (fnMatch && !/\)\s*(->|:)/.test(line)) {
      const idx = line.indexOf("fn");
      diags.push({
        severity: vscode.DiagnosticSeverity.Information,
        range: new vscode.Range(
          document.positionAt(lineOffset),
          document.positionAt(lineOffset + len),
        ),
        message: `Local function '${fnMatch[1]}': consider adding return type '-> Unit'`,
        source: DIAG_SOURCE,
      });
    }

    lineOffset += len + 1;
  }
}

function checkUnclosedBrace(
  html: string,
  document: vscode.TextDocument,
  diags: vscode.Diagnostic[],
) {
  let depth = 0;
  let lastOpen = -1;
  for (let i = 0; i < html.length; i++) {
    if (html[i] === "{") {
      if (depth === 0) lastOpen = i;
      depth++;
    } else if (html[i] === "}") {
      depth--;
      if (depth < 0) {
        const p = document.positionAt(i);
        diags.push({
          severity: vscode.DiagnosticSeverity.Error,
          range: new vscode.Range(p, p.translate(0, 1)),
          message: "Unmatched closing brace '}'",
          source: DIAG_SOURCE,
        });
        depth = 0;
      }
    }
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

// ---------------- completion + hover ----------------

function isInsideScript(
  document: vscode.TextDocument,
  position: vscode.Position,
): boolean {
  const text = document.getText();
  const offset = document.offsetAt(position);
  const before = text.substring(0, offset);

  const open = /<script\s+lang\s*=\s*"moonbit"[^>]*>/g;
  const close = /<\/script>/g;

  let lastOpen = -1;
  let lastClose = -1;
  let m: RegExpExecArray | null;
  while ((m = open.exec(before)) !== null) lastOpen = m.index;
  while ((m = close.exec(before)) !== null) lastClose = m.index;

  return lastOpen > lastClose && lastOpen >= 0;
}

class SvonCompletionProvider implements vscode.CompletionItemProvider {
  provideCompletionItems(
    document: vscode.TextDocument,
    position: vscode.Position,
  ): vscode.CompletionItem[] {
    if (!isInsideScript(document, position)) return [];
    return [
      ci("state", "state(init)", "Create reactive state variable"),
      ci("derived", "derived(fn() { ... })", "Create computed derived value"),
      ci(
        "effect",
        "effect(fn() { ...; Option::None })",
        "Create reactive side-effect",
      ),
      ci("fn", "fn name() -> Unit { }", "Define a function"),
      ci("let", "let name = value", "Bind a variable"),
      ci("State", "State[T]", "Reactive state type"),
      ci("Derived", "Derived[T]", "Derived value type"),
      ci(".get()", ".get()", "Read reactive value (tracked)"),
      ci(".set(", ".set(value)", "Write reactive value"),
      ci("read_source", "read_source(s)", "Read Source, track dependency"),
      ci(
        "write_source",
        "write_source(s, val)",
        "Write Source, propagate dirtiness",
      ),
      ci("read_derived", "read_derived(d)", "Read Derived with lazy compute"),
      ci("untrack", "untrack(fn() { ... })", "Suppress dependency tracking"),
      ci("Option::None", "Option::None", "No cleanup (effect return)"),
    ];
  }
}

function ci(
  label: string,
  detail: string,
  doc: string,
): vscode.CompletionItem {
  const item = new vscode.CompletionItem(label);
  item.detail = detail;
  item.documentation = new vscode.MarkdownString(doc);
  item.kind = vscode.CompletionItemKind.Function;
  return item;
}

function getApiDoc(word: string): string | null {
  const docs: Record<string, string> = {
    state: "**state(init)** — create a writable reactive signal.\n\nEquivalent to Svelte's `$state()`.",
    derived:
      "**derived(fn)** — create a computed reactive value.\n\nAuto-tracks dependencies. Equivalent to `$derived()`.",
    effect:
      "**effect(fn)** — create a reactive side-effect.\n\nRe-runs when dependencies change. Return `Option::None` for no cleanup.\n\nEquivalent to Svelte's `$effect()`.",
    "State::get":
      "**State::get()** — read value, tracking it as a dependency.",
    "State::set":
      "**State::set(v)** — write value, dirtying all dependents.",
    "Derived::get":
      "**Derived::get()** — read computed value. Lazily recomputes if dirty.",
  };
  return docs[word] || null;
}

export function deactivate() {}
