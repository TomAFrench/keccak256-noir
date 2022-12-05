
fn main(input: u64, bit_position: u64) -> pub u64 {

  let mut bit_mask: u64 = 1;
  for j in 0..64 {
    // Note: pay attention to endianness here.
    if (j as u64) > bit_position {
      bit_mask = bit_mask * 2;
    }
  };

  input | bit_mask
}
