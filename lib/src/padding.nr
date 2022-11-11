use crate::constants;

// This is a simplified implementation of the pad10*1 algorithm.
// As we assume that the input length is smaller than the block size, we can ignore the potential for the padding
// sequence to be spread over multiple blocks.
fn pad(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::BLOCK_SIZE] {
  // We require 2 bits of space after the message in order to include the padding bits.
  // constrain input_length < BLOCK_SIZE - 2;

  let mut padded_input: [u64; constants::BLOCK_SIZE] = [0 as u64; constants::BLOCK_SIZE];
  for i in 0..constants::INPUT_SIZE {
    if input_length >= ((i + 1) * constants::LANE_LENGTH) as u64 {
      // The input continues past the end of the current word.
      // We then copy it verbatim into the padded input.

      padded_input[i] = input[i];
    } else if input_length >= (i * constants::LANE_LENGTH) as u64 {
      // The input ends in this current word.
      // We must then insert the first padding bit at the correct location before copying it.


      // Subtracting `i * constants::LANE_LENGTH` from `input_length` shifts it into the range [0, 63]
      let bit_position: u64 = input_length - (i * constants::LANE_LENGTH) as u64;

      // We then want to insert a bit `bit_position` bits into the current word.
      // To do this we mask the word with `2**(64 - bit_position)`.
      // Ideally we'd perform a bitshift here but we cannot know `input_length` at compile time.
      let mut bit_mask: u64 = 1;
      for j in 0..64 {
        // Multiply by 2 64 - j times.
        if (j as u64) > bit_position {
          bit_mask = bit_mask * 2;
        }
      };

      // Copy across both the input and the padding bit.
      padded_input[i] = input[i] | bit_mask;

      // Ensure that all bits after the stated end of the message are zero.
      constrain padded_input[i] & (bit_mask - 1) == 0;
    } else {
      // Input must be empty after end of message.
      constrain input[i] == 0;
    }
  };

  if input_length == (constants::INPUT_SIZE * constants::LANE_LENGTH) as u64 {
    // Both padding bits fall in the last word and so the first wasn't written during the for-loop.
    // We can then just write both bits directly now.
    padded_input[constants::BLOCK_SIZE - 1] = 0x8000000000000001;
  } else {
    // Place the second 1 bit of the padding in the last bit of the block.
    padded_input[constants::BLOCK_SIZE - 1] = 1;
  }

  padded_input
}
