///|
/// Result of comparing two environment maps.
pub struct DiffResult {
  added : Array[String]
  removed : Array[String]
  changed : Array[String]
}

///|
/// Compare two maps and return which keys were added, removed, or changed.
///
/// - `added`: keys present in `other` but not in `base`
/// - `removed`: keys present in `base` but not in `other`
/// - `changed`: keys present in both but with different values
pub fn diff(
  base : Map[String, String],
  other : Map[String, String],
) -> DiffResult {
  let added : Array[String] = []
  let removed : Array[String] = []
  let changed : Array[String] = []

  for k, v in base {
    if other.contains(k) {
      if v != other[k] {
        changed.push(k)
      }
    } else {
      removed.push(k)
    }
  }

  for k, _ in other {
    if !base.contains(k) {
      added.push(k)
    }
  }

  { added, removed, changed }
}
