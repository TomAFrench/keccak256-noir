use crate::constants;

// This is a simplified implementation of the pad10*1 algorithm.
// As we assume that the input length is smaller than the block size, we can ignore the potential for the padding
// sequence to be spread over multiple blocks.
fn pad(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::BLOCK_SIZE] {
  // We require 2 bits of space after the message in order to include the padding bits.
  // constrain input_length < BLOCK_SIZE - 2;

  let mut padded_input: [u64; constants::BLOCK_SIZE] = [0; constants::BLOCK_SIZE];
  for i in 0..constants::INPUT_SIZE {
    // Caching the word from input here reduces the number of gates.
    let word = input[i];

    if input_length >= ((i + 1) * 8) as u64 {
      // The input continues past the end of the current word.
      // We then copy it verbatim into the padded input.

      padded_input[i] = word;
    } else if input_length >= (i * 8) as u64 {
      // The input ends in this current word.
      // We must then insert the first padding bit at the correct location before copying it.

      // Subtracting `i * 8` from `input_length` shifts it into the range [0, 8)
      let byte_position: Field = input_length as Field - i * 8;

      check_message_end(word, byte_position);
      
      // Copy across both the input and the padding bit.
      padded_input[i] = insert_delimited_suffix(word, byte_position);
    } else {
      // Input must be empty after end of message.
      constrain word == 0;
    }
  };

  if input_length == (constants::INPUT_SIZE * 8) as u64 {
    // Both padding bits fall in the last word and so the first wasn't written during the for-loop.
    // We can then just write both bits directly now.
    padded_input[constants::BLOCK_SIZE - 1] = 0x0600000000000080;
  } else {
    // Place the second 1 bit of the padding in the last bit of the block.
    padded_input[constants::BLOCK_SIZE - 1] = 0x0000000000000080;
  }

  padded_input
}

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

#[test]
fn test_pad() {
  {
    let input: [u64; constants::INPUT_SIZE] = [0; constants::INPUT_SIZE];
    let input_length: u64 = 0;
    let expected_output: [u64; constants::BLOCK_SIZE] = [
      0x0600000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000080
    ];
    constrain pad(input, input_length) == expected_output;
  }


  {
    let mut input: [u64; constants::INPUT_SIZE] = [0; constants::INPUT_SIZE];
    input[0] = 0x1234560000000000;
    let input_length: u64 = 3;
    let expected_output: [u64; constants::BLOCK_SIZE] = [
      0x1234560600000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000080
    ];
    constrain pad(input, input_length) == expected_output;
  }

   {
    let mut input: [u64; constants::INPUT_SIZE] = [0; constants::INPUT_SIZE];
    input[0] = 0x1234560000000000;
    input[1] = 0x1234560000000000;
    let input_length: u64 = 11;
    let expected_output: [u64; constants::BLOCK_SIZE] = [
      0x1234560000000000,
      0x1234560600000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000000,
      0x0000000000000080
    ];
    constrain pad(input, input_length) == expected_output;
  }
}