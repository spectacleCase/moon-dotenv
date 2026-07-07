///|
/// Strip UTF-8 BOM (U+FEFF) from the beginning of a string if present.
fn strip_bom(src : String) -> String {
  if src.length() >= 1 && src.code_unit_at(0).to_int() == 0xFEFF {
    src[1:src.length()].to_owned()
  } else {
    src
  }
}

///|
/// Parse a `.env` file string into a Map of key-value pairs.
///
/// Supports:
/// - UTF-8 BOM (U+FEFF) is silently stripped
/// - `KEY=value` and `KEY: value` syntax
/// - `export KEY=value` prefix
/// - Single-quoted values (literal, no escape processing)
/// - Double-quoted values (with `\n`, `\r`, `\t`, `\\` escape sequences)
/// - Backtick-quoted values (literal, no escape processing)
/// - Inline comments with `#`
/// - Multiline values within quotes
/// - Empty values
/// - Keys and values surrounded by whitespace
///
/// Last duplicate key wins. Malformed quotes are silently ignored.
pub fn parse(src : String) -> Map[String, String] {
  let result = Map([], capacity=16)
  let p = Parser::new(strip_bom(src))
  while !p.is_eof() {
    p.skip_whitespace()
    if p.is_eof() {
      break
    }
    match p.peek() {
      Some('\n') | Some('\r') => {
        p.skip_eol()
        continue
      }
      Some('#') => {
        p.skip_to_eol()
        p.skip_eol()
        continue
      }
      _ => ()
    }
    try_skip_export(p)
    let key = parse_key(p)
    if key == "" {
      p.skip_to_eol()
      p.skip_eol()
      continue
    }
    p.skip_whitespace()
    match p.peek() {
      Some('=') | Some(':') => p.pos += 1
      _ => {
        p.skip_to_eol()
        p.skip_eol()
        continue
      }
    }
    let value = parse_value(p)
    result[key] = value
  }
  result
}

///|
/// Like `parse`, but returns `Err(ParseError)` on malformed input
/// (e.g. unclosed quotes).
pub fn try_parse(src : String) -> Result[Map[String, String], ParseError] {
  let result = Map([], capacity=16)
  let p = Parser::new(strip_bom(src))
  while !p.is_eof() {
    p.skip_whitespace()
    if p.is_eof() {
      break
    }
    match p.peek() {
      Some('\n') | Some('\r') => {
        p.skip_eol()
        continue
      }
      Some('#') => {
        p.skip_to_eol()
        p.skip_eol()
        continue
      }
      _ => ()
    }
    try_skip_export(p)
    let key = parse_key(p)
    if key == "" {
      p.skip_to_eol()
      p.skip_eol()
      continue
    }
    p.skip_whitespace()
    match p.peek() {
      Some('=') | Some(':') => p.pos += 1
      _ => {
        p.skip_to_eol()
        p.skip_eol()
        continue
      }
    }
    match try_parse_value(p) {
      Ok(value) => result[key] = value
      Err(e) => return Err(e)
    }
  }
  Ok(result)
}
