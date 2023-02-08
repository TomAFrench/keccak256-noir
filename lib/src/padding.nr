use crate::constants;
use dep::std;

fn insert_delimited_suffix(word: u64, byte_position: Field) -> u64 {
  // As we cannot perform bitshifts of non-comptime values then we must use a lookup table.
  let check_bit_masks: [comptime Field; 8] = [
    0xffffffffffffffff, 0x00ffffffffffffff, 0x0000ffffffffffff, 0x000000ffffffffff,
    0x00000000ffffffff, 0x0000000000ffffff, 0x000000000000ffff, 0x00000000000000ff
  ];
  let insert_bit_masks: [comptime Field; 8] = [
    0x0600000000000000, 0x0006000000000000, 0x0000060000000000, 0x0000000600000000,
    0x0000000006000000, 0x0000000000060000, 0x0000000000000600, 0x0000000000000006
  ];

  let mut check_bit_mask: Field = 0;
  let mut insert_bit_mask: Field = 0;
  for j in 0..8 {
    if j == byte_position {
      check_bit_mask = check_bit_masks[j];
      insert_bit_mask = insert_bit_masks[j];
    }
  };

  constrain word & (check_bit_mask as u64) == 0; 
  word | (insert_bit_mask as u64)
}

#[test]
fn test_insert_delimited_suffix() {
  let input_words = [0x0600000000000000, 0x0600000000000000, 0x0600000000000000, 0x0600000000000000];
  let input_byte_positions = [1, 2, 3, 4];
  let expected_outputs = [0x0606000000000000, 0x0600060000000000, 0x0600000600000000, 0x0600000006000000];

  for i in 0..std::array::len(input_words) {
    constrain insert_delimited_suffix(input_words[i], input_byte_positions[i]) == expected_outputs[i];
  }

  // Expected failures:

  // Fails the `check_bit_mask` constraint
  // insert_delimited_suffix(0x8000000000000000, 0);
}