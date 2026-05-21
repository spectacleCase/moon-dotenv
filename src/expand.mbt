///|
/// Expand `$VAR` and `${VAR}` references in all values of a parsed map.
///
/// Variables are resolved from the parsed map itself first, then from
/// the provided `env` map (e.g. system environment variables).
///
/// If a referenced variable is not found, it is left as-is.
pub fn expand(
  parsed : Map[String, String],
  env? : Map[String, String] = Map([], capacity=0),
) -> Map[String, String] {
  let result = Map([], capacity=parsed.length())
  for key, value in parsed {
    result[key] = expand_value(value, parsed, env~)
  }
  result
}

///|
/// Expand `$VAR` and `${VAR}` references in a single value string.
fn expand_value(
  value : String,
  parsed : Map[String, String],
  env~ : Map[String, String],
) -> String {
  let buf = StringBuilder::new()
  let len = value.length()
  let mut i = 0
  while i < len {
    let ch = Int::unsafe_to_char(value.code_unit_at(i).to_int())
    if ch == '$' && i + 1 < len {
      let next = Int::unsafe_to_char(value.code_unit_at(i + 1).to_int())
      if next == '{' {
        // ${VAR} or ${VAR:-default} syntax
        i += 2
        let var_start = i
        while i < len &&
              Int::unsafe_to_char(value.code_unit_at(i).to_int()) != '}' {
          i += 1
        }
        let raw = value[var_start:i].to_owned()
        if i < len {
          i += 1
        } // skip closing }
        // Check for :-default syntax
        let (var_name, default_val) = parse_var_spec(raw)
        match resolve_var(var_name, parsed, env) {
          Some(v) => buf.write_string(v)
          None =>
            match default_val {
              Some(def) => buf.write_string(def)
              None => {
                buf.write_string("${")
                buf.write_string(raw)
                buf.write_char('}')
              }
            }
        }
      } else if next == '_' ||
        (next >= 'a' && next <= 'z') ||
        (next >= 'A' && next <= 'Z') {
        // $VAR syntax
        i += 1
        let var_start = i
        while i < len {
          let c = Int::unsafe_to_char(value.code_unit_at(i).to_int())
          if (c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') ||
            c == '_' {
            i += 1
          } else {
            break
          }
        }
        let var_name = value[var_start:i].to_owned()
        match resolve_var(var_name, parsed, env) {
          Some(v) => buf.write_string(v)
          None => {
            buf.write_char('$')
            buf.write_string(var_name)
          }
        }
      } else {
        buf.write_char(ch)
        i += 1
      }
    } else {
      buf.write_char(ch)
      i += 1
    }
  }
  buf.to_string()
}

///|
/// Try to resolve a variable name from parsed map first, then env map.
/// Returns Some(value) if found, None otherwise.
fn resolve_var(
  var_name : String,
  parsed : Map[String, String],
  env : Map[String, String],
) -> String? {
  for k, v in parsed {
    if k == var_name {
      return Some(v)
    }
  }
  for k, v in env {
    if k == var_name {
      return Some(v)
    }
  }
  None
}

/// Parse a variable spec like `VAR` or `VAR:-default`.
/// Returns (var_name, optional_default_value).
fn parse_var_spec(raw : String) -> (String, String?) {
  let len = raw.length()
  let mut i = 0
  while i < len {
    let ch = Int::unsafe_to_char(raw.code_unit_at(i).to_int())
    if ch == ':' && i + 1 < len {
      let next = Int::unsafe_to_char(raw.code_unit_at(i + 1).to_int())
      if next == '-' {
        let var_name = raw[0:i].to_owned()
        let default_val = raw[i + 2:len].to_owned()
        return (var_name, Some(default_val))
      }
    }
    i += 1
  }
  (raw, None)
}
