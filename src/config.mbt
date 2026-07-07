///|
/// Parse a `.env` string and optionally merge with an existing environment.
///
/// When `force` is `true`, parsed values overwrite existing keys in `env`.
/// When `false` (default), existing keys in `env` are preserved.
pub fn config(
  src : String,
  env? : Map[String, String] = Map([], capacity=0),
  force? : Bool = false,
) -> Map[String, String] {
  let parsed = parse(src)
  merge(env, parsed, force~)
}

///|
/// Merge two maps. Keys from `other` are added to `base`.
/// When `force` is `true`, `other` wins on conflicts.
/// When `false`, `base` wins on conflicts.
pub fn merge(
  base : Map[String, String],
  other : Map[String, String],
  force? : Bool = false,
) -> Map[String, String] {
  let result = Map([], capacity=base.length() + other.length())
  for k, v in base {
    result[k] = v
  }
  for k, v in other {
    if force || !result.contains(k) {
      result[k] = v
    }
  }
  result
}

///|
/// Parse multiple `.env` strings and merge them in order.
/// Later files override earlier ones.
pub fn load_multi(sources : Array[String]) -> Map[String, String] {
  let result = Map([], capacity=16)
  for src in sources {
    let parsed = parse(src)
    for k, v in parsed {
      result[k] = v
    }
  }
  result
}

///|
/// Like `load_multi`, but also merge with an existing environment.
/// When `force` is `true`, parsed values overwrite existing keys.
pub fn config_multi(
  sources : Array[String],
  env? : Map[String, String] = Map([], capacity=0),
  force? : Bool = false,
) -> Map[String, String] {
  let merged = load_multi(sources)
  merge(env, merged, force~)
}

///|
/// Write parsed key-value pairs into a target map.
///
/// When `force` is `true`, parsed values overwrite existing keys.
/// When `false` (default), existing keys in `target` are preserved.
/// Returns the number of keys actually written.
pub fn populate(
  target : Map[String, String],
  parsed : Map[String, String],
  force? : Bool = false,
) -> Int {
  let mut count = 0
  for k, v in parsed {
    if force || !target.contains(k) {
      target[k] = v
      count += 1
    }
  }
  count
}
