class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function _M0TPB4IterGRPC16string10StringViewE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function _M0TPB4IterGcE(param0, param1) {
  this.f = param0;
  this.size_hint = param1;
}
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function _M0TPB8MutLocalGORPC16string10StringViewE(param0) {
  this.val = param0;
}
function _M0TPC13ref3RefGiE(param0) {
  this.val = param0;
}
function _M0TP38username4svon8compiler10Diagnostic(param0, param1, param2, param3) {
  this.code = param0;
  this.message = param1;
  this.start = param2;
  this.end = param3;
}
function _M0DTP38username4svon8compiler9TextChunk6Static(param0) {
  this._0 = param0;
}
_M0DTP38username4svon8compiler9TextChunk6Static.prototype.$tag = 0;
function _M0DTP38username4svon8compiler9TextChunk4Expr(param0) {
  this._0 = param0;
}
_M0DTP38username4svon8compiler9TextChunk4Expr.prototype.$tag = 1;
function _M0DTP38username4svon8compiler8HtmlNode4Text(param0) {
  this._0 = param0;
}
_M0DTP38username4svon8compiler8HtmlNode4Text.prototype.$tag = 0;
function _M0DTP38username4svon8compiler8HtmlNode7Element(param0) {
  this._0 = param0;
}
_M0DTP38username4svon8compiler8HtmlNode7Element.prototype.$tag = 1;
function _M0TPB8MutLocalGbE(param0) {
  this.val = param0;
}
function _M0TP38username4svon8compiler11ElementNode(param0, param1, param2) {
  this.tag = param0;
  this.attributes = param1;
  this.children = param2;
}
function _M0DTP38username4svon8compiler9Attribute6Static(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP38username4svon8compiler9Attribute6Static.prototype.$tag = 0;
function _M0DTP38username4svon8compiler9Attribute5Event(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP38username4svon8compiler9Attribute5Event.prototype.$tag = 1;
function _M0DTP38username4svon8compiler9Attribute4Bind(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP38username4svon8compiler9Attribute4Bind.prototype.$tag = 2;
function _M0TP38username4svon8compiler8Template(param0, param1, param2, param3, param4) {
  this.script = param0;
  this.styles = param1;
  this.imports = param2;
  this.nodes = param3;
  this.diagnostics = param4;
}
function _M0TP38username4svon8compiler9SourcePos(param0, param1) {
  this.line = param0;
  this.column = param1;
}
function _M0TPB8MutLocalGsE(param0) {
  this.val = param0;
}
const _M0FP48username4svon3cmd7compile10read__file = (path) => require("fs").readFileSync(path, "utf-8");
const _M0FP48username4svon3cmd7compile11write__file = (path, content) => require("fs").writeFileSync(path, content);
const _M0FP48username4svon3cmd7compile5mkdir = (path) => require("fs").mkdirSync(path, { recursive: true });
const _M0FP48username4svon3cmd7compile9get__args = () => process.argv.slice(2);
const _M0FP48username4svon3cmd7compile13write__stderr = (msg) => process.stderr.write(msg);
const _M0FP48username4svon3cmd7compile4exit = (code) => process.exit(code);
const _M0FP48username4svon3cmd7compile8cli__dir = () => __dirname;
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0MPC16string6String4trimN7_2abindS6432 = "\t\n\r ";
const _M0MPB4Iter4nextN6constrS9183GRPC16string10StringViewE = 0;
const _M0MPB4Iter4nextN6constrS9184GRPC16string10StringViewE = 0;
const _M0MPB4Iter4nextN6constrS9183GcE = 0;
const _M0MPB4Iter4nextN6constrS9184GcE = 0;
const _M0MPB4Iter3newN6constrS9191GRPC16string10StringViewE = 0;
const _M0MPB4Iter3newN6constrS9191GcE = 0;
const _M0FPB18brute__force__findN6constrS9194 = 0;
const _M0FPB28boyer__moore__horspool__findN6constrS9193 = 0;
function _M0FPC15abort5abortGRPC16string10StringViewE(msg) {
  return $panic();
}
function _M0FPC15abort5abortGOiE(msg) {
  return $panic();
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC13int3Int16unsafe__to__char(self) {
  return self;
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1622is__leading__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 55296) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 56319);
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0FPB32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MPC16uint166UInt1616unsafe__to__char(self) {
  return self;
}
function _M0MPC16string6String16unsafe__char__at(self, index) {
  const c1 = self.charCodeAt(index);
  if (_M0MPC16uint166UInt1622is__leading__surrogate(c1)) {
    const c2 = self.charCodeAt(index + 1 | 0);
    return _M0FPB32code__point__of__surrogate__pair(c1, c2);
  } else {
    return _M0MPC16uint166UInt1616unsafe__to__char(c1);
  }
}
function _M0MPC16string10StringView12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.end - self.start | 0;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= (self.end - self.start | 0)) ? new _M0TPC16string10StringView(self.str, self.start + start_offset | 0, self.start + end_offset$2 | 0) : _M0FPC15abort5abortGRPC16string10StringViewE("Invalid index for View");
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IPC16uint166UInt16PB2Eq5equal(self, that) {
  return self === that;
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    end$2 = _Some;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    if (start < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0MPC16string10StringView4data(self) {
  return self.str;
}
function _M0MPC16string10StringView13start__offset(self) {
  return self.start;
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC16string6StringPB4Show10to__string(self));
}
function _M0MPB4Iter4nextGRPC16string10StringViewE(self) {
  const _func = self.f;
  const result = _func();
  const _bind = self.size_hint;
  if (result === undefined) {
    self.size_hint = _M0MPB4Iter4nextN6constrS9184GRPC16string10StringViewE;
  } else {
    if (_bind === undefined) {
    } else {
      const _Some = _bind;
      const _n = _Some;
      self.size_hint = _n > 0 ? _n - 1 | 0 : _M0MPB4Iter4nextN6constrS9183GRPC16string10StringViewE;
    }
  }
  return result;
}
function _M0MPB4Iter4nextGcE(self) {
  const _func = self.f;
  const result = _func();
  const _bind = self.size_hint;
  if (result === -1) {
    self.size_hint = _M0MPB4Iter4nextN6constrS9184GcE;
  } else {
    if (_bind === undefined) {
    } else {
      const _Some = _bind;
      const _n = _Some;
      self.size_hint = _n > 0 ? _n - 1 | 0 : _M0MPB4Iter4nextN6constrS9183GcE;
    }
  }
  return result;
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPB4Iter3newGRPC16string10StringViewE(f, size_hint) {
  let size_hint$2;
  if (size_hint === undefined) {
    size_hint$2 = undefined;
  } else {
    const _Some = size_hint;
    const _n = _Some;
    size_hint$2 = _n > 0 ? _n : _M0MPB4Iter3newN6constrS9191GRPC16string10StringViewE;
  }
  return new _M0TPB4IterGRPC16string10StringViewE(f, size_hint$2);
}
function _M0MPB4Iter3newGcE(f, size_hint) {
  let size_hint$2;
  if (size_hint === undefined) {
    size_hint$2 = undefined;
  } else {
    const _Some = size_hint;
    const _n = _Some;
    size_hint$2 = _n > 0 ? _n : _M0MPB4Iter3newN6constrS9191GcE;
  }
  return new _M0TPB4IterGcE(f, size_hint$2);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string10StringView4iter(self) {
  const start = self.start;
  const end = self.end;
  const index = new _M0TPB8MutLocalGiE(start);
  return _M0MPB4Iter3newGcE(() => {
    if (index.val < end) {
      const c1 = self.str.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < self.end) {
        const c2 = self.str.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          index.val = index.val + 2 | 0;
          return _M0FPB32code__point__of__surrogate__pair(c1, c2);
        }
      }
      index.val = index.val + 1 | 0;
      return _M0MPC16uint166UInt1616unsafe__to__char(c1);
    } else {
      return -1;
    }
  }, undefined);
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPC15abort5abortGRPC16string10StringViewE("Invalid index for View");
}
function _M0MPC16string6String31offset__of__nth__char__backward(self, n, start_offset, end_offset) {
  let _tmp = end_offset;
  let _tmp$2 = 0;
  while (true) {
    const utf16_offset = _tmp;
    const char_count = _tmp$2;
    if ((utf16_offset - 1 | 0) >= start_offset && char_count < n) {
      const c = self.charCodeAt(utf16_offset - 1 | 0);
      if (_M0MPC16uint166UInt1623is__trailing__surrogate(c)) {
        _tmp = utf16_offset - 2 | 0;
        _tmp$2 = char_count + 1 | 0;
        continue;
      } else {
        _tmp = utf16_offset - 1 | 0;
        _tmp$2 = char_count + 1 | 0;
        continue;
      }
    } else {
      return char_count < n || utf16_offset < start_offset ? undefined : utf16_offset;
    }
  }
}
function _M0MPC16string6String30offset__of__nth__char__forward(self, n, start_offset, end_offset) {
  if (start_offset >= 0 && start_offset <= end_offset) {
    let _tmp = start_offset;
    let _tmp$2 = 0;
    while (true) {
      const utf16_offset = _tmp;
      const char_count = _tmp$2;
      if (utf16_offset < end_offset && char_count < n) {
        const c = self.charCodeAt(utf16_offset);
        if (_M0MPC16uint166UInt1622is__leading__surrogate(c)) {
          _tmp = utf16_offset + 2 | 0;
          _tmp$2 = char_count + 1 | 0;
          continue;
        } else {
          _tmp = utf16_offset + 1 | 0;
          _tmp$2 = char_count + 1 | 0;
          continue;
        }
      } else {
        return char_count < n || utf16_offset >= end_offset ? undefined : utf16_offset;
      }
    }
  } else {
    return _M0FPC15abort5abortGOiE("Invalid start index");
  }
}
function _M0MPC16string6String29offset__of__nth__char_2einner(self, i, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return i >= 0 ? _M0MPC16string6String30offset__of__nth__char__forward(self, i, start_offset, end_offset$2) : _M0MPC16string6String31offset__of__nth__char__backward(self, -i | 0, start_offset, end_offset$2);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0FPB28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _bind = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _bind) {
          const _tmp$2 = needle.str.charCodeAt(needle.start + i | 0) & 255;
          $bound_check(skip_table, _tmp$2);
          skip_table[_tmp$2] = (needle_len - 1 | 0) - i | 0;
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i <= (haystack_len - needle_len | 0)) {
          const _bind$2 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _bind$2) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0), needle.str.charCodeAt(needle.start + j | 0))) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = haystack.str.charCodeAt(haystack.start + ((i + needle_len | 0) - 1 | 0) | 0) & 255;
          $bound_check(skip_table, _tmp$4);
          _tmp$2 = i + skip_table[_tmp$4] | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB28boyer__moore__horspool__findN6constrS9193;
  }
}
function _M0FPB18brute__force__find(haystack, needle) {
  const haystack_len = haystack.end - haystack.start | 0;
  const needle_len = needle.end - needle.start | 0;
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = needle.str.charCodeAt(needle.start);
      const forward_len = haystack_len - needle_len | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i <= forward_len) {
          _L: {
            if (_M0IPC16uint166UInt16PB2Eq10not__equal(haystack.str.charCodeAt(haystack.start + i | 0), needle_first)) {
              break _L;
            }
            let _tmp$2 = 1;
            while (true) {
              const j = _tmp$2;
              if (j < needle_len) {
                if (_M0IPC16uint166UInt16PB2Eq10not__equal(haystack.str.charCodeAt(haystack.start + (i + j | 0) | 0), needle.str.charCodeAt(needle.start + j | 0))) {
                  break;
                }
                _tmp$2 = j + 1 | 0;
                continue;
              } else {
                return i;
              }
            }
            break _L;
          }
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB18brute__force__findN6constrS9194;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return (str.end - str.start | 0) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0MPC16string6String4find(self, str) {
  return _M0MPC16string10StringView4find(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC16string10StringView11has__prefix(self, str) {
  const _bind = _M0MPC16string10StringView4find(self, str);
  if (_bind === undefined) {
    return false;
  } else {
    const _Some = _bind;
    const _i = _Some;
    return _i === 0;
  }
}
function _M0MPC16string6String11has__prefix(self, str) {
  return _M0MPC16string10StringView11has__prefix(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC15array5Array11new_2einnerGRP38username4svon8compiler10DiagnosticE(capacity) {
  return [];
}
function _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string10StringView20contains__code__unit(self, code) {
  const _bind = self.end - self.start | 0;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      if (_M0IPC16uint166UInt16PB2Eq5equal(self.str.charCodeAt(self.start + i | 0), code)) {
        return true;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return false;
}
function _M0MPC16string10StringView14contains__char(self, c) {
  const len = self.end - self.start | 0;
  if (len > 0) {
    const c$2 = c;
    if (c$2 >= 0 && c$2 <= 65535) {
      return _M0MPC16string10StringView20contains__code__unit(self, c$2 & 65535);
    } else {
      if (c$2 < 0) {
        return false;
      } else {
        if (len >= 2) {
          const adj = c$2 - 65536 | 0;
          const high = 55296 + (adj >> 10) | 0;
          if (high <= 65535) {
            const high$2 = high & 65535;
            const low = (56320 + (adj & 1023) | 0) & 65535;
            let _tmp = 0;
            while (true) {
              const i = _tmp;
              if (i < (len - 1 | 0)) {
                if (_M0IPC16uint166UInt16PB2Eq5equal(self.str.charCodeAt(self.start + i | 0), high$2)) {
                  if (_M0IPC16uint166UInt16PB2Eq5equal(self.str.charCodeAt(self.start + (i + 1 | 0) | 0), low)) {
                    return true;
                  }
                  _tmp = i + 2 | 0;
                  continue;
                }
                _tmp = i + 1 | 0;
                continue;
              } else {
                break;
              }
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    }
    return false;
  } else {
    return false;
  }
}
function _M0MPC16string10StringView19trim__start_2einner(self, chars) {
  let _tmp = self;
  while (true) {
    const x = _tmp;
    if ((x.end - x.start | 0) === 0) {
      return x;
    } else {
      const _c = _M0MPC16string6String16unsafe__char__at(x.str, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, 0, x.start, x.end));
      const _tmp$2 = x.str;
      const _bind = _M0MPC16string6String29offset__of__nth__char_2einner(x.str, 1, x.start, x.end);
      let _tmp$3;
      if (_bind === undefined) {
        _tmp$3 = x.end;
      } else {
        const _Some = _bind;
        _tmp$3 = _Some;
      }
      const _x = new _M0TPC16string10StringView(_tmp$2, _tmp$3, x.end);
      if (_M0MPC16string10StringView14contains__char(chars, _c)) {
        _tmp = _x;
        continue;
      } else {
        return x;
      }
    }
  }
}
function _M0MPC16string10StringView17trim__end_2einner(self, chars) {
  let _tmp = self;
  while (true) {
    const x = _tmp;
    if ((x.end - x.start | 0) === 0) {
      return x;
    } else {
      const _c = _M0MPC16string6String16unsafe__char__at(x.str, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, -1, x.start, x.end));
      const _x = new _M0TPC16string10StringView(x.str, x.start, _M0MPC16string6String29offset__of__nth__char_2einner(x.str, -1, x.start, x.end));
      if (_M0MPC16string10StringView14contains__char(chars, _c)) {
        _tmp = _x;
        continue;
      } else {
        return x;
      }
    }
  }
}
function _M0MPC16string10StringView12trim_2einner(self, chars) {
  return _M0MPC16string10StringView17trim__end_2einner(_M0MPC16string10StringView19trim__start_2einner(self, chars), chars);
}
function _M0MPC16string6String12trim_2einner(self, chars) {
  return _M0MPC16string10StringView12trim_2einner(new _M0TPC16string10StringView(self, 0, self.length), chars);
}
function _M0MPC16string6String4trim(self, chars$46$opt) {
  let chars;
  if (chars$46$opt === undefined) {
    chars = new _M0TPC16string10StringView(_M0MPC16string6String4trimN7_2abindS6432, 0, _M0MPC16string6String4trimN7_2abindS6432.length);
  } else {
    const _Some = chars$46$opt;
    chars = _Some;
  }
  return _M0MPC16string6String12trim_2einner(self, chars);
}
function _M0MPB4Iter3mapGcRPC16string10StringViewE(self, f) {
  return new _M0TPB4IterGRPC16string10StringViewE(() => {
    const _bind = _M0MPB4Iter4nextGcE(self);
    if (_bind === -1) {
      return undefined;
    } else {
      const _Some = _bind;
      const _x = _Some;
      return f(_x);
    }
  }, self.size_hint);
}
function _M0IPC14char4CharPB4Show10to__string(self) {
  return String.fromCodePoint(self);
}
function _M0MPC16string10StringView5split(self, sep) {
  const sep_len = sep.end - sep.start | 0;
  if (sep_len === 0) {
    return _M0MPB4Iter3mapGcRPC16string10StringViewE(_M0MPC16string10StringView4iter(self), (c) => _M0MPC16string6String12view_2einner(_M0IPC14char4CharPB4Show10to__string(c), 0, undefined));
  }
  const remaining = new _M0TPB8MutLocalGORPC16string10StringViewE(self);
  return _M0MPB4Iter3newGRPC16string10StringViewE(() => {
    const _bind = remaining.val;
    if (_bind === undefined) {
      return undefined;
    } else {
      const _Some = _bind;
      const _view = _Some;
      const _bind$2 = _M0MPC16string10StringView4find(_view, sep);
      if (_bind$2 === undefined) {
        remaining.val = undefined;
        return _view;
      } else {
        const _Some$2 = _bind$2;
        const _end = _Some$2;
        remaining.val = _M0MPC16string10StringView12view_2einner(_view, _end + sep_len | 0, undefined);
        return _M0MPC16string10StringView12view_2einner(_view, 0, _end);
      }
    }
  }, undefined);
}
function _M0MPC16string6String5split(self, sep) {
  return _M0MPC16string10StringView5split(new _M0TPC16string10StringView(self, 0, self.length), sep);
}
function _M0MPC16string6String12replace__all(self, old, new_) {
  const len = self.length;
  const buf = _M0MPB13StringBuilder21StringBuilder_2einner(len);
  const old_len = old.end - old.start | 0;
  const new$2 = _M0MPC16string10StringView9to__owned(new_);
  if (old_len === 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
    const _bind = self.length;
    let _tmp = 0;
    while (true) {
      const _string_index = _tmp;
      if (_string_index < _bind) {
        let _decoded_next_string_index;
        let _decoded_char;
        _L: {
          const _bind$2 = self.charCodeAt(_string_index);
          if (_bind$2 >= 55296 && _bind$2 <= 56319 && (_string_index + 1 | 0) < _bind) {
            const _bind$3 = self.charCodeAt(_string_index + 1 | 0);
            if (_bind$3 >= 56320 && _bind$3 <= 57343) {
              _decoded_next_string_index = _string_index + 2 | 0;
              _decoded_char = _M0MPC13int3Int16unsafe__to__char((((Math.imul(_bind$2 - 55296 | 0, 1024) | 0) + _bind$3 | 0) - 56320 | 0) + 65536 | 0);
              break _L;
            } else {
              _decoded_next_string_index = _string_index + 1 | 0;
              _decoded_char = _M0MPC13int3Int16unsafe__to__char(_bind$2);
              break _L;
            }
          } else {
            _decoded_next_string_index = _string_index + 1 | 0;
            _decoded_char = _M0MPC13int3Int16unsafe__to__char(_bind$2);
            break _L;
          }
        }
        _M0IPB13StringBuilderPB6Logger11write__char(buf, _decoded_char);
        _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
        _tmp = _decoded_next_string_index;
        continue;
      } else {
        break;
      }
    }
    return _M0MPB13StringBuilder10to__string(buf);
  } else {
    const first_end = _M0MPC16string6String4find(self, old);
    if (first_end === undefined) {
      return self;
    } else {
      const _Some = first_end;
      const _end = _Some;
      let _tmp = new _M0TPC16string10StringView(self, 0, self.length);
      let _tmp$2 = _end;
      while (true) {
        const view = _tmp;
        const end = _tmp$2;
        const seg = _M0MPC16string10StringView12view_2einner(view, 0, end);
        _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(buf, _M0MPC16string10StringView4data(seg), _M0MPC16string10StringView13start__offset(seg), seg.end - seg.start | 0);
        _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
        if ((end + old_len | 0) <= len) {
          const next_view = _M0MPC16string10StringView12view_2einner(view, end + old_len | 0, undefined);
          const _bind = _M0MPC16string10StringView4find(next_view, old);
          if (_bind === undefined) {
            _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(buf, _M0MPC16string10StringView4data(next_view), _M0MPC16string10StringView13start__offset(next_view), next_view.end - next_view.start | 0);
            break;
          } else {
            const _Some$2 = _bind;
            const _next_end = _Some$2;
            _tmp = next_view;
            _tmp$2 = _next_end;
            continue;
          }
        } else {
          break;
        }
      }
      return _M0MPB13StringBuilder10to__string(buf);
    }
  }
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0MPC15array5Array2atGsE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC13ref3Ref3RefGiE(x) {
  return new _M0TPC13ref3RefGiE(x);
}
function _M0FP38username4svon8compiler15extract__script(source) {
  const start_tag = "<script lang=\"moonbit\">";
  const end_tag = "</script>";
  let start;
  _L: {
    const _bind = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(start_tag, 0, start_tag.length));
    if (_bind === undefined) {
      let start$2;
      _L$2: {
        const _bind$2 = "<script>";
        const _bind$3 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
        if (_bind$3 === undefined) {
          return "";
        } else {
          const _Some = _bind$3;
          const _start = _Some;
          start$2 = _start;
          break _L$2;
        }
      }
      const bs = start$2 + "<script>".length | 0;
      let end;
      _L$3: {
        const _bind$2 = "</script>";
        const _bind$3 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
        if (_bind$3 === undefined) {
          return "";
        } else {
          const _Some = _bind$3;
          const _end = _Some;
          end = _end;
          break _L$3;
        }
      }
      return source.substring(bs, end);
    } else {
      const _Some = _bind;
      const _start = _Some;
      start = _start;
      break _L;
    }
  }
  const bs = start + start_tag.length | 0;
  let end;
  _L$2: {
    const _bind = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(end_tag, 0, end_tag.length));
    if (_bind === undefined) {
      return "";
    } else {
      const _Some = _bind;
      const _end = _Some;
      end = _end;
      break _L$2;
    }
  }
  return source.substring(bs, end);
}
function _M0FP38username4svon8compiler24extract__script__imports(source) {
  let start;
  _L: {
    const _bind = "<script";
    const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
    if (_bind$2 === undefined) {
      return "";
    } else {
      const _Some = _bind$2;
      const _start = _Some;
      start = _start;
      break _L;
    }
  }
  let gt;
  _L$2: {
    const _bind = ">";
    const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
    if (_bind$2 === undefined) {
      return "";
    } else {
      const _Some = _bind$2;
      const _gt = _Some;
      gt = _gt;
      break _L$2;
    }
  }
  const tag = source.substring(start, gt + 1 | 0);
  let im;
  _L$3: {
    const _bind = "import=\"";
    const _bind$2 = _M0MPC16string6String4find(tag, new _M0TPC16string10StringView(_bind, 0, _bind.length));
    if (_bind$2 === undefined) {
      return "";
    } else {
      const _Some = _bind$2;
      const _im = _Some;
      im = _im;
      break _L$3;
    }
  }
  const val_start = im + "import=\"".length | 0;
  const rest = tag.substring(val_start, tag.length);
  let ve;
  _L$4: {
    const _bind = "\"";
    const _bind$2 = _M0MPC16string6String4find(rest, new _M0TPC16string10StringView(_bind, 0, _bind.length));
    if (_bind$2 === undefined) {
      return "";
    } else {
      const _Some = _bind$2;
      const _ve = _Some;
      ve = _ve;
      break _L$4;
    }
  }
  return rest.substring(0, ve);
}
function _M0FP38username4svon8compiler14extract__style(source) {
  const start_tag = "<style>";
  const end_tag = "</style>";
  let start;
  _L: {
    const _bind = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(start_tag, 0, start_tag.length));
    if (_bind === undefined) {
      return "";
    } else {
      const _Some = _bind;
      const _start = _Some;
      start = _start;
      break _L;
    }
  }
  const body_start = start + start_tag.length | 0;
  let end;
  _L$2: {
    const _bind = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(end_tag, 0, end_tag.length));
    if (_bind === undefined) {
      return "";
    } else {
      const _Some = _bind;
      const _end = _Some;
      end = _end;
      break _L$2;
    }
  }
  return source.substring(body_start, end);
}
function _M0FP38username4svon8compiler9is__space(ch) {
  return _M0IPC16uint166UInt16PB2Eq5equal(ch, 32) || (_M0IPC16uint166UInt16PB2Eq5equal(ch, 9) || (_M0IPC16uint166UInt16PB2Eq5equal(ch, 13) || _M0IPC16uint166UInt16PB2Eq5equal(ch, 10)));
}
function _M0FP38username4svon8compiler19html__parse__bounds(source) {
  const start = new _M0TPB8MutLocalGiE(0);
  const end = source.length;
  let _s;
  _L: {
    _L$2: {
      const _bind = "<script";
      const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
      if (_bind$2 === undefined) {
      } else {
        const _Some = _bind$2;
        const __s = _Some;
        _s = __s;
        break _L$2;
      }
      break _L;
    }
    let e;
    _L$3: {
      _L$4: {
        const _bind = "</script>";
        const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
        if (_bind$2 === undefined) {
        } else {
          const _Some = _bind$2;
          const _e = _Some;
          e = _e;
          break _L$4;
        }
        break _L$3;
      }
      const after_script = e + "</script>".length | 0;
      start.val = after_script;
    }
  }
  let st;
  _L$2: {
    _L$3: {
      const _bind = "<style>";
      const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
      if (_bind$2 === undefined) {
      } else {
        const _Some = _bind$2;
        const _st = _Some;
        st = _st;
        break _L$3;
      }
      break _L$2;
    }
    let se;
    _L$4: {
      _L$5: {
        const _bind = "</style>";
        const _bind$2 = _M0MPC16string6String4find(source, new _M0TPC16string10StringView(_bind, 0, _bind.length));
        if (_bind$2 === undefined) {
        } else {
          const _Some = _bind$2;
          const _se = _Some;
          se = _se;
          break _L$5;
        }
        break _L$4;
      }
      if (st >= start.val) {
        start.val = se + "</style>".length | 0;
      }
    }
  }
  const i = new _M0TPB8MutLocalGiE(start.val);
  while (true) {
    let _tmp;
    if (i.val < end) {
      const _tmp$2 = i.val;
      $bound_check(source, _tmp$2);
      _tmp = _M0FP38username4svon8compiler9is__space(source.charCodeAt(_tmp$2));
    } else {
      _tmp = false;
    }
    if (_tmp) {
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { _0: i.val, _1: end };
}
function _M0FP38username4svon8compiler8char__at(s, i) {
  if (i < 0 || i >= s.length) {
    return 0;
  } else {
    $bound_check(s, i);
    return s.charCodeAt(i);
  }
}
function _M0FP38username4svon8compiler11is__special(ch) {
  return _M0IPC16uint166UInt16PB2Eq5equal(ch, 62) || (_M0IPC16uint166UInt16PB2Eq5equal(ch, 47) || (_M0IPC16uint166UInt16PB2Eq5equal(ch, 61) || _M0FP38username4svon8compiler9is__space(ch)));
}
function _M0FP38username4svon8compiler10read__word(s, i, end) {
  const start = i;
  const p = new _M0TPB8MutLocalGiE(i);
  while (true) {
    if (p.val < end && !_M0FP38username4svon8compiler11is__special(_M0FP38username4svon8compiler8char__at(s, p.val))) {
      p.val = p.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { _0: s.substring(start, p.val), _1: p.val };
}
function _M0FP38username4svon8compiler6record(diags, code, message, start, end) {
  _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(diags, new _M0TP38username4svon8compiler10Diagnostic(code, message, start, end));
}
function _M0FP38username4svon8compiler8skip__ws(s, i, end) {
  const p = new _M0TPB8MutLocalGiE(i);
  while (true) {
    if (p.val < end && _M0FP38username4svon8compiler9is__space(_M0FP38username4svon8compiler8char__at(s, p.val))) {
      p.val = p.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return p.val;
}
function _M0FP38username4svon8compiler11parse__text(html, pos, end, diags) {
  const parts = _M0MPC15array5Array11new_2einnerGRP38username4svon8compiler10DiagnosticE(4);
  const i = new _M0TPB8MutLocalGiE(pos);
  const ts = new _M0TPB8MutLocalGiE(i.val);
  while (true) {
    if (i.val < end) {
      const ch = _M0FP38username4svon8compiler8char__at(html, i.val);
      if (_M0IPC16uint166UInt16PB2Eq5equal(ch, 60)) {
        break;
      }
      if (_M0IPC16uint166UInt16PB2Eq5equal(ch, 123)) {
        if (i.val > ts.val) {
          const raw = html.substring(ts.val, i.val);
          const s = _M0MPC16string10StringView9to__owned(_M0MPC16string6String4trim(raw, undefined));
          if (s.length > 0) {
            _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(parts, new _M0DTP38username4svon8compiler9TextChunk6Static(s));
          }
        }
        const brace_start = i.val;
        i.val = i.val + 1 | 0;
        const es = i.val;
        const d = new _M0TPB8MutLocalGiE(1);
        while (true) {
          if (i.val < end && d.val > 0) {
            const c = _M0FP38username4svon8compiler8char__at(html, i.val);
            if (_M0IPC16uint166UInt16PB2Eq5equal(c, 123)) {
              d.val = d.val + 1 | 0;
            } else {
              if (_M0IPC16uint166UInt16PB2Eq5equal(c, 125)) {
                d.val = d.val - 1 | 0;
                if (d.val === 0) {
                  break;
                }
              }
            }
            i.val = i.val + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        if (d.val > 0) {
          _M0FP38username4svon8compiler6record(diags, "unclosed-brace", "Unclosed `{` in template expression — missing `}`", brace_start, i.val);
        }
        const raw_expr = html.substring(es, i.val);
        const expr = _M0MPC16string10StringView9to__owned(_M0MPC16string6String4trim(raw_expr, undefined));
        if (expr.length > 0) {
          _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(parts, new _M0DTP38username4svon8compiler9TextChunk4Expr(expr));
        }
        i.val = i.val + 1 | 0;
        ts.val = i.val;
      } else {
        i.val = i.val + 1 | 0;
      }
      continue;
    } else {
      break;
    }
  }
  if (i.val > ts.val) {
    const raw = html.substring(ts.val, i.val);
    const s = _M0MPC16string10StringView9to__owned(_M0MPC16string6String4trim(raw, undefined));
    if (s.length > 0) {
      _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(parts, new _M0DTP38username4svon8compiler9TextChunk6Static(s));
    }
  }
  return parts.length === 0 ? undefined : { _0: parts, _1: i.val };
}
function _M0FP38username4svon8compiler12parse__nodes(html, pos, end, diags) {
  const nodes = _M0MPC15array5Array11new_2einnerGRP38username4svon8compiler10DiagnosticE(8);
  const i = new _M0TPB8MutLocalGiE(pos);
  while (true) {
    if (i.val < end) {
      i.val = _M0FP38username4svon8compiler8skip__ws(html, i.val, end);
      if (i.val >= end) {
        break;
      }
      const ch = _M0FP38username4svon8compiler8char__at(html, i.val);
      if (_M0IPC16uint166UInt16PB2Eq5equal(ch, 60)) {
        if ((i.val + 3 | 0) < end && (_M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 1 | 0), 33) && (_M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 2 | 0), 45) && _M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 3 | 0), 45)))) {
          i.val = i.val + 4 | 0;
          while (true) {
            if ((i.val + 2 | 0) < end && !(_M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val), 45) && (_M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 1 | 0), 45) && _M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 2 | 0), 62)))) {
              i.val = i.val + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          i.val = i.val + 3 | 0;
          continue;
        }
        if ((i.val + 1 | 0) < end && _M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 1 | 0), 47)) {
          break;
        }
        let el;
        let next;
        _L: {
          _L$2: {
            const _bind = _M0FP38username4svon8compiler14parse__element(html, i.val, end, diags);
            if (_bind === undefined) {
              i.val = i.val + 1 | 0;
            } else {
              const _Some = _bind;
              const _x = _Some;
              const _el = _x._0;
              const _next = _x._1;
              el = _el;
              next = _next;
              break _L$2;
            }
            break _L;
          }
          _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(nodes, new _M0DTP38username4svon8compiler8HtmlNode7Element(el));
          i.val = next;
          continue;
        }
      } else {
        let parts;
        let next;
        _L: {
          _L$2: {
            const _bind = _M0FP38username4svon8compiler11parse__text(html, i.val, end, diags);
            if (_bind === undefined) {
              i.val = i.val + 1 | 0;
            } else {
              const _Some = _bind;
              const _x = _Some;
              const _parts = _x._0;
              const _next = _x._1;
              parts = _parts;
              next = _next;
              break _L$2;
            }
            break _L;
          }
          const _bind = 0;
          const _bind$2 = parts.length;
          let _tmp = _bind;
          while (true) {
            const j = _tmp;
            if (j < _bind$2) {
              _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(nodes, new _M0DTP38username4svon8compiler8HtmlNode4Text(_M0MPC15array5Array2atGsE(parts, j)));
              _tmp = j + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          i.val = next;
          continue;
        }
      }
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return nodes;
}
function _M0FP38username4svon8compiler14parse__element(html, pos, end, diags) {
  const i = new _M0TPB8MutLocalGiE(pos + 1 | 0);
  i.val = _M0FP38username4svon8compiler8skip__ws(html, i.val, end);
  let tag;
  let after_tag;
  _L: {
    const _bind = _M0FP38username4svon8compiler10read__word(html, i.val, end);
    const _tag = _bind._0;
    const _after_tag = _bind._1;
    tag = _tag;
    after_tag = _after_tag;
    break _L;
  }
  if (tag.length === 0) {
    _M0FP38username4svon8compiler6record(diags, "empty-tag-name", "Expected a tag name after `<`", pos, i.val);
    return undefined;
  }
  i.val = after_tag;
  const attrs = _M0MPC15array5Array11new_2einnerGRP38username4svon8compiler10DiagnosticE(4);
  const parsing = new _M0TPB8MutLocalGbE(true);
  while (true) {
    if (parsing.val) {
      i.val = _M0FP38username4svon8compiler8skip__ws(html, i.val, end);
      if (i.val >= end) {
        parsing.val = false;
        continue;
      }
      const ch = _M0FP38username4svon8compiler8char__at(html, i.val);
      if (_M0IPC16uint166UInt16PB2Eq5equal(ch, 62)) {
        i.val = i.val + 1 | 0;
        parsing.val = false;
        continue;
      }
      if (_M0IPC16uint166UInt16PB2Eq5equal(ch, 47) && ((i.val + 1 | 0) < end && _M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val + 1 | 0), 62))) {
        return { _0: new _M0TP38username4svon8compiler11ElementNode(tag, attrs, []), _1: i.val + 2 | 0 };
      }
      let name;
      let after_name;
      _L$2: {
        const _bind = _M0FP38username4svon8compiler10read__word(html, i.val, end);
        const _name = _bind._0;
        const _after_name = _bind._1;
        name = _name;
        after_name = _after_name;
        break _L$2;
      }
      i.val = after_name;
      if (_M0IPC16uint166UInt16PB2Eq5equal(_M0FP38username4svon8compiler8char__at(html, i.val), 61)) {
        i.val = i.val + 1 | 0;
        const q = _M0FP38username4svon8compiler8char__at(html, i.val);
        if (_M0IPC16uint166UInt16PB2Eq5equal(q, 34) || _M0IPC16uint166UInt16PB2Eq5equal(q, 39)) {
          i.val = i.val + 1 | 0;
          const vs = i.val;
          while (true) {
            if (i.val < end && _M0IPC16uint166UInt16PB2Eq10not__equal(_M0FP38username4svon8compiler8char__at(html, i.val), q)) {
              i.val = i.val + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          const val = html.substring(vs, i.val);
          i.val = i.val + 1 | 0;
          if (name.length > 2 && name.substring(0, 2) === "on") {
            const ev_name = name.substring(2, name.length);
            _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(attrs, new _M0DTP38username4svon8compiler9Attribute5Event(ev_name, val));
          } else {
            _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(attrs, new _M0DTP38username4svon8compiler9Attribute6Static(name, val));
          }
        } else {
          if (_M0IPC16uint166UInt16PB2Eq5equal(q, 123)) {
            i.val = i.val + 1 | 0;
            const vs = i.val;
            const d = new _M0TPB8MutLocalGiE(1);
            while (true) {
              if (i.val < end && d.val > 0) {
                const c = _M0FP38username4svon8compiler8char__at(html, i.val);
                if (_M0IPC16uint166UInt16PB2Eq5equal(c, 123)) {
                  d.val = d.val + 1 | 0;
                } else {
                  if (_M0IPC16uint166UInt16PB2Eq5equal(c, 125)) {
                    d.val = d.val - 1 | 0;
                    if (d.val === 0) {
                      break;
                    }
                  }
                }
                i.val = i.val + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            const val = html.substring(vs, i.val);
            i.val = i.val + 1 | 0;
            if (name.length > 2 && name.substring(0, 2) === "on") {
              const ev_name = name.substring(2, name.length);
              _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(attrs, new _M0DTP38username4svon8compiler9Attribute5Event(ev_name, val));
            } else {
              _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(attrs, new _M0DTP38username4svon8compiler9Attribute4Bind(name, val));
            }
          }
        }
      } else {
        _M0MPC15array5Array4pushGRP38username4svon8compiler8HtmlNodeE(attrs, new _M0DTP38username4svon8compiler9Attribute6Static(name, ""));
      }
      continue;
    } else {
      break;
    }
  }
  const children = _M0FP38username4svon8compiler12parse__nodes(html, i.val, end, diags);
  const close_tag = `</${tag}>`;
  const rest = html.substring(i.val, end);
  let close_end;
  let ct;
  _L$2: {
    _L$3: {
      const _bind = _M0MPC16string6String4find(rest, new _M0TPC16string10StringView(close_tag, 0, close_tag.length));
      if (_bind === undefined) {
        _M0FP38username4svon8compiler6record(diags, "unclosed-tag", `<${tag}> has no matching closing tag </${tag}>`, pos, end);
        close_end = end;
      } else {
        const _Some = _bind;
        const _ct = _Some;
        ct = _ct;
        break _L$3;
      }
      break _L$2;
    }
    close_end = (i.val + ct | 0) + close_tag.length | 0;
  }
  return { _0: new _M0TP38username4svon8compiler11ElementNode(tag, attrs, children), _1: close_end };
}
function _M0FP38username4svon8compiler5parse(source) {
  const script = _M0FP38username4svon8compiler15extract__script(source);
  const styles = _M0FP38username4svon8compiler14extract__style(source);
  const imports = _M0FP38username4svon8compiler24extract__script__imports(source);
  let html_start;
  let html_end;
  _L: {
    const _bind = _M0FP38username4svon8compiler19html__parse__bounds(source);
    const _html_start = _bind._0;
    const _html_end = _bind._1;
    html_start = _html_start;
    html_end = _html_end;
    break _L;
  }
  const diags = _M0MPC15array5Array11new_2einnerGRP38username4svon8compiler10DiagnosticE(4);
  const nodes = _M0FP38username4svon8compiler12parse__nodes(source, html_start, html_end, diags);
  return new _M0TP38username4svon8compiler8Template(script, styles, imports, nodes, diags);
}
function _M0FP38username4svon8compiler21offset__to__line__col(source, offset) {
  const line = new _M0TPB8MutLocalGiE(1);
  const col = new _M0TPB8MutLocalGiE(1);
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < offset && i.val < source.length) {
      const _tmp = i.val;
      $bound_check(source, _tmp);
      if (_M0IPC16uint166UInt16PB2Eq5equal(source.charCodeAt(_tmp), 10)) {
        line.val = line.val + 1 | 0;
        col.val = 1;
      } else {
        col.val = col.val + 1 | 0;
      }
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP38username4svon8compiler9SourcePos(line.val, col.val);
}
function _M0FP38username4svon8compiler6spaces(n) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < n) {
      _M0IPB13StringBuilderPB6Logger13write__string(b, " ");
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP38username4svon8compiler21generate__code__frame(source, line, col) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  const current_line = new _M0TPB8MutLocalGiE(1);
  const line_start = new _M0TPB8MutLocalGiE(0);
  const i = new _M0TPB8MutLocalGiE(0);
  const digits = _M0MPC13int3Int18to__string_2einner(line + 2 | 0, 10).length;
  while (true) {
    if (i.val <= source.length && current_line.val <= (line + 2 | 0)) {
      let _tmp;
      if (i.val === source.length) {
        _tmp = true;
      } else {
        const _tmp$2 = i.val;
        $bound_check(source, _tmp$2);
        _tmp = _M0IPC16uint166UInt16PB2Eq5equal(source.charCodeAt(_tmp$2), 10);
      }
      if (_tmp) {
        if (current_line.val >= (line - 2 | 0)) {
          let src_line;
          if (current_line.val <= (line + 2 | 0)) {
            const ln_end = i.val <= source.length ? i.val : source.length;
            src_line = source.substring(line_start.val, ln_end);
          } else {
            src_line = "";
          }
          const line_num_str = _M0MPC13int3Int18to__string_2einner(current_line.val, 10);
          const pad = _M0FP38username4svon8compiler6spaces(digits - line_num_str.length | 0);
          _M0IPB13StringBuilderPB6Logger13write__string(b, pad);
          _M0IPB13StringBuilderPB6Logger13write__string(b, line_num_str);
          _M0IPB13StringBuilderPB6Logger13write__string(b, ": ");
          _M0IPB13StringBuilderPB6Logger13write__string(b, src_line);
          _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
          if (current_line.val === line) {
            _M0IPB13StringBuilderPB6Logger13write__string(b, _M0FP38username4svon8compiler6spaces(((digits + 2 | 0) + col | 0) - 1 | 0));
            _M0IPB13StringBuilderPB6Logger13write__string(b, "^\n");
          }
        }
        current_line.val = current_line.val + 1 | 0;
        line_start.val = i.val + 1 | 0;
      }
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP38username4svon8compiler19format__diagnostics(source, diags) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
  const _bind = 0;
  const _bind$2 = diags.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const d = _M0MPC15array5Array2atGsE(diags, i);
      const pos = _M0FP38username4svon8compiler21offset__to__line__col(source, d.start);
      _M0IPB13StringBuilderPB6Logger13write__string(b, "  ");
      _M0IPB13StringBuilderPB6Logger13write__string(b, d.code);
      _M0IPB13StringBuilderPB6Logger13write__string(b, ": ");
      _M0IPB13StringBuilderPB6Logger13write__string(b, d.message);
      _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
      _M0IPB13StringBuilderPB6Logger13write__string(b, "  at ");
      _M0IPB13StringBuilderPB6Logger13write__string(b, _M0MPC13int3Int18to__string_2einner(pos.line, 10));
      _M0IPB13StringBuilderPB6Logger13write__string(b, ":");
      _M0IPB13StringBuilderPB6Logger13write__string(b, _M0MPC13int3Int18to__string_2einner(pos.column, 10));
      _M0IPB13StringBuilderPB6Logger13write__string(b, "\n\n");
      _M0IPB13StringBuilderPB6Logger13write__string(b, _M0FP38username4svon8compiler21generate__code__frame(source, pos.line, pos.column));
      if (i < (diags.length - 1 | 0)) {
        _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP38username4svon8compiler14generate__text(chunk, parent, b, el_id) {
  const id = el_id.val;
  el_id.val = id + 1 | 0;
  const id_str = _M0MPC13int3Int18to__string_2einner(id, 10);
  let expr;
  _L: {
    let s;
    _L$2: {
      if (chunk.$tag === 0) {
        const _Static = chunk;
        const _s = _Static._0;
        s = _s;
        break _L$2;
      } else {
        const _Expr = chunk;
        const _expr = _Expr._0;
        expr = _expr;
        break _L;
      }
    }
    const _writer_2 = b;
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_2, "  let t");
    _M0MPB13StringBuilder13write__objectGsE(_writer_2, id_str);
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_2, " : @svon.DomNode = @svon.document_create_text_node(\"");
    _M0MPB13StringBuilder13write__objectGsE(_writer_2, s);
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_2, "\")\n");
    const _writer_3 = b;
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_3, "  @svon.node_append_child(");
    _M0MPB13StringBuilder13write__objectGsE(_writer_3, parent);
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_3, ", t");
    _M0MPB13StringBuilder13write__objectGsE(_writer_3, id_str);
    _M0IPB13StringBuilderPB6Logger13write__string(_writer_3, ")\n");
    return;
  }
  const _writer_4 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_4, "  let t");
  _M0MPB13StringBuilder13write__objectGsE(_writer_4, id_str);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_4, " : @svon.DomNode = @svon.document_create_text_node(\"\")\n");
  const _writer_5 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_5, "  @svon.node_append_child(");
  _M0MPB13StringBuilder13write__objectGsE(_writer_5, parent);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_5, ", t");
  _M0MPB13StringBuilder13write__objectGsE(_writer_5, id_str);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_5, ")\n");
  const _writer_6 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_6, "        let _ = @svon.effect(fn() {\n");
  const _writer_7 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_7, "    @svon.node_set_text_content(t");
  _M0MPB13StringBuilder13write__objectGsE(_writer_7, id_str);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_7, ", ");
  _M0MPB13StringBuilder13write__objectGsE(_writer_7, expr);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_7, ".to_string())\n");
  const _writer_8 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_8, "    Option::None\n");
  const _writer_9 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_9, "  })\n");
}
function _M0FP38username4svon8compiler15generate__nodes(nodes, parent, b, el_id) {
  const _bind = 0;
  const _bind$2 = nodes.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const node = _M0MPC15array5Array2atGsE(nodes, i);
      let el;
      _L: {
        _L$2: {
          let chunk;
          _L$3: {
            if (node.$tag === 0) {
              const _Text = node;
              const _chunk = _Text._0;
              chunk = _chunk;
              break _L$3;
            } else {
              const _Element = node;
              const _el = _Element._0;
              el = _el;
              break _L$2;
            }
          }
          _M0FP38username4svon8compiler14generate__text(chunk, parent, b, el_id);
          break _L;
        }
        _M0FP38username4svon8compiler17generate__element(el, parent, b, el_id);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP38username4svon8compiler17generate__element(el, parent, b, el_id) {
  const id = el_id.val;
  el_id.val = id + 1 | 0;
  const el_var = `el${_M0MPC13int3Int18to__string_2einner(id, 10)}`;
  const _writer_10 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_10, "  let ");
  _M0MPB13StringBuilder13write__objectGsE(_writer_10, el_var);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_10, " : @svon.DomNode = @svon.document_create_element(\"");
  _M0MPB13StringBuilder13write__objectGsE(_writer_10, el.tag);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_10, "\")\n");
  const _bind = 0;
  const _bind$2 = el.attributes.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const attr = _M0MPC15array5Array2atGsE(el.attributes, i);
      let attr_name;
      let expr;
      _L: {
        _L$2: {
          let event;
          let handler;
          _L$3: {
            _L$4: {
              let name;
              let value;
              _L$5: {
                switch (attr.$tag) {
                  case 0: {
                    const _Static = attr;
                    const _name = _Static._0;
                    const _value = _Static._1;
                    name = _name;
                    value = _value;
                    break _L$5;
                  }
                  case 1: {
                    const _Event = attr;
                    const _event = _Event._0;
                    const _handler = _Event._1;
                    event = _event;
                    handler = _handler;
                    break _L$4;
                  }
                  default: {
                    const _Bind = attr;
                    const _attr_name = _Bind._0;
                    const _expr = _Bind._1;
                    attr_name = _attr_name;
                    expr = _expr;
                    break _L$2;
                  }
                }
              }
              const _writer_11 = b;
              _M0IPB13StringBuilderPB6Logger13write__string(_writer_11, "  @svon.node_set_attribute(");
              _M0MPB13StringBuilder13write__objectGsE(_writer_11, el_var);
              _M0IPB13StringBuilderPB6Logger13write__string(_writer_11, ", \"");
              _M0MPB13StringBuilder13write__objectGsE(_writer_11, name);
              _M0IPB13StringBuilderPB6Logger13write__string(_writer_11, "\", \"");
              _M0MPB13StringBuilder13write__objectGsE(_writer_11, value);
              _M0IPB13StringBuilderPB6Logger13write__string(_writer_11, "\")\n");
              break _L$3;
            }
            const _writer_12 = b;
            _M0IPB13StringBuilderPB6Logger13write__string(_writer_12, "  @svon.node_add_event_listener(");
            _M0MPB13StringBuilder13write__objectGsE(_writer_12, el_var);
            _M0IPB13StringBuilderPB6Logger13write__string(_writer_12, ", \"");
            _M0MPB13StringBuilder13write__objectGsE(_writer_12, event);
            _M0IPB13StringBuilderPB6Logger13write__string(_writer_12, "\", ");
            _M0MPB13StringBuilder13write__objectGsE(_writer_12, handler);
            _M0IPB13StringBuilderPB6Logger13write__string(_writer_12, ")\n");
          }
          break _L;
        }
        const _writer_13 = b;
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_13, "        let _ = @svon.effect(fn() {\n");
        const _writer_14 = b;
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_14, "    @svon.node_set_attribute(");
        _M0MPB13StringBuilder13write__objectGsE(_writer_14, el_var);
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_14, ", \"");
        _M0MPB13StringBuilder13write__objectGsE(_writer_14, attr_name);
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_14, "\", ");
        _M0MPB13StringBuilder13write__objectGsE(_writer_14, expr);
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_14, ".to_string())\n");
        const _writer_15 = b;
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_15, "    Option::None\n");
        const _writer_16 = b;
        _M0IPB13StringBuilderPB6Logger13write__string(_writer_16, "  })\n");
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP38username4svon8compiler15generate__nodes(el.children, el_var, b, el_id);
  const _writer_17 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_17, "  @svon.node_append_child(");
  _M0MPB13StringBuilder13write__objectGsE(_writer_17, parent);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_17, ", ");
  _M0MPB13StringBuilder13write__objectGsE(_writer_17, el_var);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_17, ")\n");
}
function _M0FP38username4svon8compiler15transform__line(line, standalone) {
  if (line === "") {
    return "";
  }
  const _bind = "//";
  if (_M0MPC16string6String11has__prefix(line, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    return line;
  }
  if (standalone) {
    return line;
  } else {
    const result = new _M0TPB8MutLocalGsE(line);
    const _tmp = result.val;
    const _bind$2 = "state(";
    const _tmp$2 = new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length);
    const _bind$3 = "@svon.state(";
    result.val = _M0MPC16string6String12replace__all(_tmp, _tmp$2, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length));
    const _tmp$3 = result.val;
    const _bind$4 = "derived(";
    const _tmp$4 = new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length);
    const _bind$5 = "@svon.derived(";
    result.val = _M0MPC16string6String12replace__all(_tmp$3, _tmp$4, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length));
    const _tmp$5 = result.val;
    const _bind$6 = "effect(";
    const _tmp$6 = new _M0TPC16string10StringView(_bind$6, 0, _bind$6.length);
    const _bind$7 = "@svon.effect(";
    result.val = _M0MPC16string6String12replace__all(_tmp$5, _tmp$6, new _M0TPC16string10StringView(_bind$7, 0, _bind$7.length));
    return result.val;
  }
}
function _M0FP38username4svon8compiler16generate__script(script, b, standalone) {
  const _bind = "\n";
  const raw_lines = _M0MPC16string6String5split(script, new _M0TPC16string10StringView(_bind, 0, _bind.length));
  const _it = raw_lines;
  while (true) {
    let line;
    _L: {
      const _bind$2 = _M0MPB4Iter4nextGRPC16string10StringViewE(_it);
      if (_bind$2 === undefined) {
        return;
      } else {
        const _Some = _bind$2;
        const _line = _Some;
        line = _line;
        break _L;
      }
    }
    const s = _M0MPC16string10StringView9to__owned(line);
    const trimmed = _M0MPC16string10StringView9to__owned(_M0MPC16string6String4trim(s, undefined));
    const transformed = _M0FP38username4svon8compiler15transform__line(trimmed, standalone);
    if (transformed.length > 0) {
      _M0IPB13StringBuilderPB6Logger13write__string(b, "  ");
      _M0IPB13StringBuilderPB6Logger13write__string(b, transformed);
      _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
    }
    continue;
  }
}
function _M0FP38username4svon8compiler26generate__style__injection(css, b) {
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  let style_el : @svon.DomNode = @svon.document_create_element(\"style\")\n");
  const _bind = "\"";
  const _tmp = new _M0TPC16string10StringView(_bind, 0, _bind.length);
  const _bind$2 = "\\\"";
  const _tmp$2 = _M0MPC16string6String12replace__all(css, _tmp, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
  const _bind$3 = "\n";
  const _tmp$3 = new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length);
  const _bind$4 = "\\n";
  const escaped = _M0MPC16string6String12replace__all(_tmp$2, _tmp$3, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length));
  const _writer_18 = b;
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_18, "  @svon.node_set_text_content(style_el, \"");
  _M0MPB13StringBuilder13write__objectGsE(_writer_18, escaped);
  _M0IPB13StringBuilderPB6Logger13write__string(_writer_18, "\")\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  let head = @svon.document_head()\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  @svon.node_append_child(head, style_el)\n");
}
function _M0FP38username4svon8compiler8generate(t, standalone) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "/// Generated by Svon compiler\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "fn main {\n");
  _M0FP38username4svon8compiler16generate__script(t.script, b, standalone);
  if (t.styles.length > 0) {
    _M0FP38username4svon8compiler26generate__style__injection(t.styles, b);
  }
  const el_id = _M0MPC13ref3Ref3RefGiE(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  let root : @svon.DomNode = @svon.document_create_element(\"div\")\n");
  _M0FP38username4svon8compiler15generate__nodes(t.nodes, "root", b, el_id);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  let body = @svon.document_body()\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  @svon.node_append_child(body, root)\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "}\n");
  const result = _M0MPB13StringBuilder10to__string(b);
  if (standalone) {
    const _bind = "@svon.";
    const _tmp = new _M0TPC16string10StringView(_bind, 0, _bind.length);
    const _bind$2 = "";
    return _M0MPC16string6String12replace__all(result, _tmp, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
  } else {
    return result;
  }
}
function _M0FP38username4svon8compiler7compile(source) {
  const template = _M0FP38username4svon8compiler5parse(source);
  if (template.diagnostics.length > 0) {
    const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
    _M0IPB13StringBuilderPB6Logger13write__string(b, "// ==========================================================\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "// Svon compilation failed with ");
    _M0IPB13StringBuilderPB6Logger13write__string(b, _M0MPC13int3Int18to__string_2einner(template.diagnostics.length, 10));
    _M0IPB13StringBuilderPB6Logger13write__string(b, " error(s):\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "//\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, _M0FP38username4svon8compiler19format__diagnostics(source, template.diagnostics));
    _M0IPB13StringBuilderPB6Logger13write__string(b, "//\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "// ==========================================================\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "fn main {\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "  let _svon_compile_error : Int = \"Fix the errors above in your .svon template\"\n");
    _M0IPB13StringBuilderPB6Logger13write__string(b, "}\n");
    return _M0MPB13StringBuilder10to__string(b);
  } else {
    return _M0FP38username4svon8compiler8generate(template, false);
  }
}
function _M0FP48username4svon3cmd7compile12cmd__compile(args) {
  const src = _M0FP48username4svon3cmd7compile10read__file(_M0MPC15array5Array2atGsE(args, 0));
  const tmpl = _M0FP38username4svon8compiler5parse(src);
  if (tmpl.diagnostics.length > 0) {
    const err = _M0FP38username4svon8compiler19format__diagnostics(src, tmpl.diagnostics);
    _M0FP48username4svon3cmd7compile13write__stderr(err);
    _M0FP48username4svon3cmd7compile13write__stderr("\n");
    _M0FP48username4svon3cmd7compile4exit(1);
  }
  const out = _M0FP38username4svon8compiler7compile(src);
  _M0FPB7printlnGsE(out);
}
function _M0FP48username4svon3cmd7compile8cmd__dev(args) {
  _M0FPB7printlnGsE("Run: python3 -m http.server 8080");
}
function _M0FP48username4svon3cmd7compile9cmd__init(args) {
  const dir = args.length >= 2 ? _M0MPC15array5Array2atGsE(args, 1) : ".";
  const svon_dep = `${dir}/deps/svon`;
  _M0FP48username4svon3cmd7compile5mkdir(svon_dep);
  const base = _M0FP48username4svon3cmd7compile8cli__dir();
  const files = ["types.mbt", "signal.mbt", "runtime.mbt", "dom.mbt", "state.mbt", "svon.mbt"];
  const _bind = 0;
  const _bind$2 = files.length;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const name = _M0MPC15array5Array2atGsE(files, i);
      _M0FP48username4svon3cmd7compile11write__file(`${svon_dep}/${name}`, _M0FP48username4svon3cmd7compile10read__file(`${base}/runtime/${name}`));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP48username4svon3cmd7compile11write__file(`${svon_dep}/moon.pkg`, "");
  _M0FP48username4svon3cmd7compile11write__file(`${dir}/moon.mod.json`, "{\n  \"name\": \"local/svonpages\",\n  \"version\": \"0.1.0\",\n  \"preferred_target\": \"js\"\n}\n");
  _M0FP48username4svon3cmd7compile13write__stderr(`Initialized ${dir}/deps/svon/\n`);
}
function _M0FP48username4svon3cmd7compile15moon__mod__text(name) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "name = \"username/");
  _M0IPB13StringBuilderPB6Logger13write__string(b, name);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "\"\nversion = \"0.1.0\"\npreferred_target = \"js\"\n");
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP48username4svon3cmd7compile12readme__text(name) {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "# ");
  _M0IPB13StringBuilderPB6Logger13write__string(b, name);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "\n\nBuilt with Svon.\n\n```bash\nsvonc pages/index.svon > cmd/site/main.mbt\nmoon build cmd/site --target js\npython3 -m http.server 8080\n```\n");
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP48username4svon3cmd7compile17starter__template() {
  const b = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(b, "<script lang=\"moonbit\">\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "let count = state(0)\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "fn increment() { count.set(count.get() + 1) }\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "</script>\n\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "<div>\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  <h1>Count: {count.get()}</h1>\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "  <button onclick={increment}>+</button>\n");
  _M0IPB13StringBuilderPB6Logger13write__string(b, "</div>\n");
  return _M0MPB13StringBuilder10to__string(b);
}
function _M0FP48username4svon3cmd7compile8cmd__new(args) {
  const name = _M0MPC15array5Array2atGsE(args, 1);
  _M0FP48username4svon3cmd7compile5mkdir(name);
  _M0FP48username4svon3cmd7compile5mkdir(`${name}/pages`);
  _M0FP48username4svon3cmd7compile11write__file(`${name}/pages/index.svon`, _M0FP48username4svon3cmd7compile17starter__template());
  _M0FP48username4svon3cmd7compile11write__file(`${name}/moon.mod`, _M0FP48username4svon3cmd7compile15moon__mod__text(name));
  _M0FP48username4svon3cmd7compile11write__file(`${name}/README.md`, _M0FP48username4svon3cmd7compile12readme__text(name));
  _M0FPB7printlnGsE(`Created: ${name}/`);
  _M0FPB7printlnGsE(`  cd ${name}`);
  _M0FPB7printlnGsE("  svonc init .                # initialize shared svonlib/");
  _M0FPB7printlnGsE("  svonc pages/index.svon > cmd/site/main.mbt");
  _M0FPB7printlnGsE("  moon build cmd/site --target js");
  _M0FPB7printlnGsE("  python3 -m http.server 8080");
}
function _M0FP48username4svon3cmd7compile11print__help() {
  _M0FPB7printlnGsE("Svon — reactive MoonBit templates");
  _M0FPB7printlnGsE("");
  _M0FPB7printlnGsE("Commands:");
  _M0FPB7printlnGsE("  svonc <file.svon>           Compile to stdout");
  _M0FPB7printlnGsE("  svonc init [dir]            Initialize project with shared svonlib/");
  _M0FPB7printlnGsE("  svonc new <name>            Scaffold new project");
  _M0FPB7printlnGsE("  svonc dev                   Serve current directory");
  _M0FPB7printlnGsE("");
}
(() => {
  const args = _M0FP48username4svon3cmd7compile9get__args();
  if (args.length === 0) {
    _M0FP48username4svon3cmd7compile11print__help();
    return;
  }
  const cmd = _M0MPC15array5Array2atGsE(args, 0);
  if (cmd === "--help" || cmd === "-h") {
    _M0FP48username4svon3cmd7compile11print__help();
    return;
  }
  if (cmd === "new" && args.length >= 2) {
    _M0FP48username4svon3cmd7compile8cmd__new(args);
    return;
  }
  if (cmd === "init") {
    _M0FP48username4svon3cmd7compile9cmd__init(args);
    return;
  }
  if (cmd === "dev") {
    _M0FP48username4svon3cmd7compile8cmd__dev(args);
    return;
  }
  const _bind = "-";
  if (_M0MPC16string6String11has__prefix(cmd, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    _M0FP48username4svon3cmd7compile11print__help();
    return;
  }
  _M0FP48username4svon3cmd7compile12cmd__compile(args);
})();
//# sourceMappingURL=compile.js.map
