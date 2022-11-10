fn main(num: u64, rot: u64) -> pub u64 {
  rotl64(num, rot)
}

fn rotl64(num: u64, rot: u64) -> u64 {
  (num << rot) | (num >> (64 - rot))
}
