use dep::keccak::padding::pad as pad;

global INPUT_SIZE: Field = 10;
global BLOCK_SIZE: Field = 10; // Blocks are 136 bytes. 138 * 8 = 1088 bits.

fn main(input: [u1; INPUT_SIZE], input_length: u64) -> pub [u1; BLOCK_SIZE] {
  pad(input, input_length)
}
