use dep::keccak::padding as padding;

use dep::keccak::constants as constants;

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u1; constants::INPUT_SIZE], input_length: u64) -> pub [u1; constants::BLOCK_SIZE] {
  padding::pad(input, input_length)
}
