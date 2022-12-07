use crate::constants;

// This is a simplified implementation of the pad10*1 algorithm.
// As we assume that the input length is smaller than the block size, we can ignore the potential for the padding
// sequence to be spread over multiple blocks.
fn pad(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::BLOCK_SIZE] {
  // We require 2 bits of space after the message in order to include the padding bits.
  // constrain input_length < BLOCK_SIZE - 2;


  let mut padded_input: [u64; constants::BLOCK_SIZE] = [0 as u64; constants::BLOCK_SIZE];
  for i in 0..constants::INPUT_SIZE {
    // Caching the word from input here reduces the number of gates.
    let word = input[i];

    if input_length >= ((i + 1) * constants::LANE_LENGTH) as u64 {
      // The input continues past the end of the current word.
      // We then copy it verbatim into the padded input.

      padded_input[i] = word;
    } else if input_length >= (i * constants::LANE_LENGTH) as u64 {
      // The input ends in this current word.
      // We must then insert the first padding bit at the correct location before copying it.

      // Subtracting `i * constants::LANE_LENGTH` from `input_length` shifts it into the range [0, 63]
      let bit_position: Field = input_length as Field - i * constants::LANE_LENGTH;
      let bit_mask = get_bit_mask(bit_position);

      // Copy across both the input and the padding bit.
      padded_input[i] = word | bit_mask;

      // Ensure that all bits after the stated end of the message are zero.
      constrain word & (bit_mask - 1) == 0;
    } else {
      // Input must be empty after end of message.
      constrain word == 0;
    }
  };

  if input_length == (constants::INPUT_SIZE * constants::LANE_LENGTH) as u64 {
    // Both padding bits fall in the last word and so the first wasn't written during the for-loop.
    // We can then just write both bits directly now.
    padded_input[constants::BLOCK_SIZE - 1] = 0x8000000000000001;
  } else {
    // Place the second 1 bit of the padding in the last bit of the block.
    padded_input[constants::BLOCK_SIZE - 1] = 0x0000000000000001;
  }

  padded_input
}


fn get_bit_mask(bit_position: Field) -> u64 {
  // We need to be able to map from a bit position in the range [0, 63] to a bitmask which pulls out
  // that particular bit from a u64.
  // As we cannot perform bitshifts of non-comptime values then we must use a lookup table.
  let bit_masks: [comptime u64; 64] = [
    0x8000000000000000, 0x4000000000000000, 0x2000000000000000, 0x1000000000000000,
    0x0800000000000000, 0x0400000000000000, 0x0200000000000000, 0x0100000000000000,
    0x0080000000000000, 0x0040000000000000, 0x0020000000000000, 0x0010000000000000,
    0x0008000000000000, 0x0004000000000000, 0x0002000000000000, 0x0001000000000000,
    0x0000800000000000, 0x0000400000000000, 0x0000200000000000, 0x0000100000000000,
    0x0000080000000000, 0x0000040000000000, 0x0000020000000000, 0x0000010000000000,
    0x0000008000000000, 0x0000004000000000, 0x0000002000000000, 0x0000001000000000,
    0x0000000800000000, 0x0000000400000000, 0x0000000200000000, 0x0000000100000000,
    0x0000000080000000, 0x0000000040000000, 0x0000000020000000, 0x0000000010000000,
    0x0000000008000000, 0x0000000004000000, 0x0000000002000000, 0x0000000001000000,
    0x0000000000800000, 0x0000000000400000, 0x0000000000200000, 0x0000000000100000,
    0x0000000000080000, 0x0000000000040000, 0x0000000000020000, 0x0000000000010000,
    0x0000000000008000, 0x0000000000004000, 0x0000000000002000, 0x0000000000001000,
    0x0000000000000800, 0x0000000000000400, 0x0000000000000200, 0x0000000000000100,
    0x0000000000000080, 0x0000000000000040, 0x0000000000000020, 0x0000000000000010,
    0x0000000000000008, 0x0000000000000004, 0x0000000000000002, 0x0000000000000001
  ];

  let mut bit_mask: u64 = 0;
  for j in 0..63 {
    if j == bit_position {
      bit_mask = bit_masks[j];
    }
  };

  bit_mask
}
