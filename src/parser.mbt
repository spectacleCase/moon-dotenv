///|
pub struct ParseError {
  message : String
  line : Int
}

///|
pub impl Show for ParseError with to_string(self) {
  "ParseError(line \{self.line}): \{self.message}"
}

///|
priv struct Parser {
  source : String
  mut pos : Int
  mut line : Int
}

///|
fn Parser::new(source : String) -> Parser {
  { source, pos: 0, line: 1 }
}

///|
fn Parser::is_eof(self : Parser) -> Bool {
  self.pos >= self.source.length()
}

///|
fn Parser::peek(self : Parser) -> Char? {
  if self.is_eof() {
    None
  } else {
    Some(Int::unsafe_to_char(self.source.code_unit_at(self.pos).to_int()))
  }
}

///|
fn Parser::read_char(self : Parser) -> Char? {
  if self.is_eof() {
    None
  } else {
    let ch = Int::unsafe_to_char(self.source.code_unit_at(self.pos).to_int())
    self.pos += 1
    Some(ch)
  }
}

///|
fn Parser::skip_whitespace(self : Parser) -> Unit {
  while !self.is_eof() {
    match self.peek() {
      Some(' ') | Some('\t') => self.pos += 1
      _ => break
    }
  }
}

///|
fn Parser::skip_to_eol(self : Parser) -> Unit {
  while !self.is_eof() {
    match self.peek() {
      Some('\n') | Some('\r') => break
      _ => self.pos += 1
    }
  }
}

///|
fn Parser::skip_eol(self : Parser) -> Unit {
  match self.peek() {
    Some('\r') => {
      self.pos += 1
      self.line += 1
      match self.peek() {
        Some('\n') => self.pos += 1
        _ => ()
      }
    }
    Some('\n') => {
      self.pos += 1
      self.line += 1
    }
    _ => ()
  }
}

///|
fn try_skip_export(p : Parser) -> Unit {
  let src = p.source
  let pos = p.pos
  if pos + 6 <= src.length() {
    let is_export = src.code_unit_at(pos).to_int() == 'e' &&
      src.code_unit_at(pos + 1).to_int() == 'x' &&
      src.code_unit_at(pos + 2).to_int() == 'p' &&
      src.code_unit_at(pos + 3).to_int() == 'o' &&
      src.code_unit_at(pos + 4).to_int() == 'r' &&
      src.code_unit_at(pos + 5).to_int() == 't'
    if is_export {
      let after = if pos + 6 < src.length() {
        Int::unsafe_to_char(src.code_unit_at(pos + 6).to_int())
      } else {
        '\n'
      }
      if after == ' ' || after == '\t' || after == '=' {
        p.pos = pos + 6
        p.skip_whitespace()
      }
    }
  }
}

///|
fn is_key_char(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= '0' && ch <= '9') ||
  ch == '_' ||
  ch == '.' ||
  ch == '-'
}

///|
fn parse_key(p : Parser) -> String {
  let start = p.pos
  while !p.is_eof() {
    match p.peek() {
      Some(ch) if is_key_char(ch) => p.pos += 1
      _ => break
    }
  }
  if p.pos == start {
    return ""
  }
  p.source[start:p.pos].to_owned()
}

///|
fn parse_value(p : Parser) -> String {
  p.skip_whitespace()
  if p.is_eof() {
    return ""
  }
  match p.peek() {
    Some('\n') | Some('\r') => {
      p.skip_eol()
      return ""
    }
    Some('\'') => {
      p.pos += 1
      return parse_single_quoted(p)
    }
    Some('"') => {
      p.pos += 1
      return parse_double_quoted(p)
    }
    Some('`') => {
      p.pos += 1
      return parse_backtick_quoted(p)
    }
    _ => ()
  }
  // Unquoted value: read until comment or end of line, trim trailing whitespace
  let start = p.pos
  let mut end = p.pos
  while !p.is_eof() {
    match p.peek() {
      Some('\n') | Some('\r') => break
      Some('#') => break
      _ => {
        p.pos += 1
        end = p.pos
      }
    }
  }
  // Trim trailing whitespace
  while end > start &&
        Int::unsafe_to_char(p.source.code_unit_at(end - 1).to_int()) == ' ' {
    end -= 1
  }
  p.skip_eol()
  p.source[start:end].to_owned()
}

fn try_parse_value(p : Parser) -> Result[String, ParseError] {
  p.skip_whitespace()
  if p.is_eof() {
    return Ok("")
  }
  match p.peek() {
    Some('\n') | Some('\r') => {
      p.skip_eol()
      return Ok("")
    }
    Some('\'') => {
      p.pos += 1
      return try_parse_single_quoted(p)
    }
    Some('"') => {
      p.pos += 1
      return try_parse_double_quoted(p)
    }
    Some('`') => {
      p.pos += 1
      return try_parse_backtick_quoted(p)
    }
    _ => ()
  }
  let start = p.pos
  let mut end = p.pos
  while !p.is_eof() {
    match p.peek() {
      Some('\n') | Some('\r') => break
      Some('#') => break
      _ => {
        p.pos += 1
        end = p.pos
      }
    }
  }
  while end > start &&
        Int::unsafe_to_char(p.source.code_unit_at(end - 1).to_int()) == ' ' {
    end -= 1
  }
  p.skip_eol()
  Ok(p.source[start:end].to_owned())
}

///|
fn parse_single_quoted(p : Parser) -> String {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.read_char() {
      Some('\'') => break
      Some('\n') => buf.write_char('\n')
      Some(ch) => buf.write_char(ch)
      None => break
    }
  }
  p.skip_to_eol()
  p.skip_eol()
  buf.to_string()
}

fn try_parse_single_quoted(
  p : Parser,
) -> Result[String, ParseError] {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.read_char() {
      Some('\'') => {
        p.skip_to_eol()
        p.skip_eol()
        return Ok(buf.to_string())
      }
      Some('\n') => buf.write_char('\n')
      Some(ch) => buf.write_char(ch)
      None => {
        return Err({ message: "unclosed single quote", line: p.line })
      }
    }
  }
  Err({ message: "unclosed single quote", line: p.line })
}

///|
fn parse_double_quoted(p : Parser) -> String {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.peek() {
      Some('"') => {
        p.pos += 1
        break
      }
      Some('\\') =>
        if p.pos + 1 < p.source.length() {
          let next = Int::unsafe_to_char(
            p.source.code_unit_at(p.pos + 1).to_int(),
          )
          if next == 'n' {
            buf.write_char('\n')
            p.pos += 2
          } else if next == 'r' {
            buf.write_char('\r')
            p.pos += 2
          } else if next == 't' {
            buf.write_char('\t')
            p.pos += 2
          } else if next == '\\' {
            buf.write_char('\\')
            p.pos += 2
          } else {
            buf.write_char('\\')
            p.pos += 1
          }
        } else {
          buf.write_char('\\')
          p.pos += 1
        }
      Some('\n') => {
        buf.write_char('\n')
        p.pos += 1
      }
      Some(ch) => {
        buf.write_char(ch)
        p.pos += 1
      }
      None => break
    }
  }
  p.skip_to_eol()
  p.skip_eol()
  buf.to_string()
}

fn try_parse_double_quoted(
  p : Parser,
) -> Result[String, ParseError] {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.peek() {
      Some('"') => {
        p.pos += 1
        p.skip_to_eol()
        p.skip_eol()
        return Ok(buf.to_string())
      }
      Some('\\') =>
        if p.pos + 1 < p.source.length() {
          let next = Int::unsafe_to_char(
            p.source.code_unit_at(p.pos + 1).to_int(),
          )
          if next == 'n' {
            buf.write_char('\n')
            p.pos += 2
          } else if next == 'r' {
            buf.write_char('\r')
            p.pos += 2
          } else if next == 't' {
            buf.write_char('\t')
            p.pos += 2
          } else if next == '\\' {
            buf.write_char('\\')
            p.pos += 2
          } else {
            buf.write_char('\\')
            p.pos += 1
          }
        } else {
          buf.write_char('\\')
          p.pos += 1
        }
      Some('\n') => {
        buf.write_char('\n')
        p.pos += 1
      }
      Some(ch) => {
        buf.write_char(ch)
        p.pos += 1
      }
      None => {
        return Err({ message: "unclosed double quote", line: p.line })
      }
    }
  }
  Err({ message: "unclosed double quote", line: p.line })
}

///|
fn parse_backtick_quoted(p : Parser) -> String {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.read_char() {
      Some('`') => break
      Some('\n') => buf.write_char('\n')
      Some(ch) => buf.write_char(ch)
      None => break
    }
  }
  p.skip_to_eol()
  p.skip_eol()
  buf.to_string()
}

fn try_parse_backtick_quoted(
  p : Parser,
) -> Result[String, ParseError] {
  let buf = StringBuilder::new()
  while !p.is_eof() {
    match p.read_char() {
      Some('`') => {
        p.skip_to_eol()
        p.skip_eol()
        return Ok(buf.to_string())
      }
      Some('\n') => buf.write_char('\n')
      Some(ch) => buf.write_char(ch)
      None => {
        return Err({ message: "unclosed backtick", line: p.line })
      }
    }
  }
  Err({ message: "unclosed backtick", line: p.line })
}
