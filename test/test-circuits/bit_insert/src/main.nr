
fn main(input: u64, bit_position: u64) -> pub u64 {

  let mut bit_mask: Field = 1;
  for j in 0..64 {
    // Note: pay attention to endianness here.
    if (j as u64) > bit_position {
      bit_mask = bit_mask * 2;
    }
  };

  let word = input | (bit_mask as u64);

  let temp_mask = bit_mask - 1;
  // Using this line instead will generate a false proof
  // constrain word & (bit_mask as u64 - 1) == 0;
  constrain word & temp_mask as u64 == 0;
  word
}
