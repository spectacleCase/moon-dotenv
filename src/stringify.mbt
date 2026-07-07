///|
/// Serialize a Map back into `.env` format string.
///
/// Values containing spaces, `#`, `"`, `'`, backticks, `\n`, `\r`, or `\t`
/// are double-quoted with proper escape sequences.
/// Simple values are written unquoted.
pub fn stringify(map : Map[String, String]) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for key, value in map {
    if !first {
      buf.write_char('\n')
    }
    first = false
    buf.write_string(key)
    buf.write_char('=')
    buf.write_string(quote_value(value))
  }
  buf.to_string()
}

///|
fn needs_quoting(value : String) -> Bool {
  let len = value.length()
  if len == 0 {
    return true
  }
  let mut i = 0
  while i < len {
    let ch = Int::unsafe_to_char(value.code_unit_at(i).to_int())
    if ch == ' ' ||
      ch == '\t' ||
      ch == '\n' ||
      ch == '\r' ||
      ch == '#' ||
      ch == '"' ||
      ch == '\'' ||
      ch == '`' ||
      ch == '\\' {
      return true
    }
    i += 1
  }
  false
}

///|
fn quote_value(value : String) -> String {
  if !needs_quoting(value) {
    return value
  }
  let buf = StringBuilder::new()
  buf.write_char('"')
  let len = value.length()
  let mut i = 0
  while i < len {
    let ch = Int::unsafe_to_char(value.code_unit_at(i).to_int())
    match ch {
      '\\' => buf.write_string("\\\\")
      '\n' => buf.write_string("\\n")
      '\r' => buf.write_string("\\r")
      '\t' => buf.write_string("\\t")
      '"' => buf.write_string("\\\"")
      _ => buf.write_char(ch)
    }
    i += 1
  }
  buf.write_char('"')
  buf.to_string()
}
