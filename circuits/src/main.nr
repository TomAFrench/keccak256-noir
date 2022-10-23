const INPUT_SIZE: Field = 10;

const BLOCK_SIZE: Field = 10; // Blocks are 136 bytes. 138 * 8 = 1088 bits.
const STATE_SIZE: Field = 1600;

// This is a simplified implementation of the pad10*1 algorithm.
// As we assume that the input length is smaller than the block size, we can ignore the potential for the padding
// sequence to be spread over multiple blocks.
fn pad(input: [u1; INPUT_SIZE], input_length: u64) -> [u1; BLOCK_SIZE] {
  // We require 2 bits of space after the message in order to include the padding bits.
  // constrain input_length < BLOCK_SIZE - 2;

  let mut padded_input: [u1; BLOCK_SIZE] = [0 as u1; 10];
  for i in 0..BLOCK_SIZE {
    if (i as u64) < input_length {
      // Copy input into padded array.
      padded_input[i] = input[i];
    } else {
      // Input must be empty after end of message.
      constrain input[i] == 0;

      // Place the first 1 bit of the padding in the first bit after the message.
      if (i as u64) == input_length {
          padded_input[i] = 1;
      }
    }
  };
  // Place the second 1 bit of the padding in the last bit of the block.
  padded_input[BLOCK_SIZE - 1] = 1;

  padded_input
}

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u1; INPUT_SIZE], input_length: u64) -> pub [u1; BLOCK_SIZE] {
  pad(input, input_length)
}
