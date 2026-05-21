///|
/// Parse a `.env` string and optionally merge with an existing environment.
///
/// When `force` is `true`, parsed values overwrite existing keys in `env`.
/// When `false` (default), existing keys in `env` are preserved.
pub fn config(
  src : String,
  env~ : Map[String, String] = Map([], capacity=0),
  force~ : Bool = false,
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
  force~ : Bool = false,
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
