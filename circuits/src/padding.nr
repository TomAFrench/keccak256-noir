// TODO: Change to final value (<= BLOCK_SIZE - 2).
// Could likely make this generic even (need to check on language support).
global INPUT_SIZE: Field = 1088;

// TODO: Change to final value (1088)
global BLOCK_SIZE: Field = 1088; // Blocks are 136 bytes. 138 * 8 = 1088 bits.

// This is a simplified implementation of the pad10*1 algorithm.
// As we assume that the input length is smaller than the block size, we can ignore the potential for the padding
// sequence to be spread over multiple blocks.
fn pad(input: [u1; INPUT_SIZE], input_length: u64) -> [u1; BLOCK_SIZE] {
  // We require 2 bits of space after the message in order to include the padding bits.
  // constrain input_length < BLOCK_SIZE - 2;

  let mut padded_input: [u1; BLOCK_SIZE] = [0 as u1; 1088];
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
