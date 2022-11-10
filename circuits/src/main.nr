use dep::keccak::padding::pad;
use dep::keccak::constants;

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u64; constants::INPUT_SIZE], input_length: u64) -> pub [u64; constants::BLOCK_SIZE] {
  pad(input, input_length)
}
