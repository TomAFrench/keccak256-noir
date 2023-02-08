use crate::constants;

fn check_message_end(word: u64, byte_position: Field) {
  // As we cannot perform bitshifts of non-comptime values then we must use a lookup table.
  let bit_masks: [comptime Field; 8] = [
    0xffffffffffffffff, 0x00ffffffffffffff, 0x0000ffffffffffff, 0x000000ffffffffff,
    0x00000000ffffffff, 0x0000000000ffffff, 0x000000000000ffff, 0x00000000000000ff
  ];

  let mut bit_mask: Field = 0;
  for j in 0..8 {
    if j == byte_position {
      bit_mask = bit_masks[j];
    }
  };

  constrain word & (bit_mask as u64) == 0;
}


fn insert_delimited_suffix(word: u64, byte_position: Field) -> u64 {
  // As we cannot perform bitshifts of non-comptime values then we must use a lookup table.
  let bit_masks: [comptime Field; 8] = [
    0x0600000000000000, 0x0006000000000000, 0x0000060000000000, 0x0000000600000000,
    0x0000000006000000, 0x0000000000060000, 0x0000000000000600, 0x0000000000000006
  ];

  let mut bit_mask: Field = 0;
  for j in 0..8 {
    if j == byte_position {
      bit_mask = bit_masks[j];
    }
  };

  word | (bit_mask as u64)
}