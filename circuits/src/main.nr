use dep::keccak::permutations as permutations;
use dep::keccak::constants as constants;

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u2; constants::INPUT_SIZE], input_length: u64) -> pub [u2; constants::OUTPUT_SIZE] {
  permutations::keccak(input, input_length)
}
