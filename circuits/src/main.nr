use dep::keccak;
use dep::keccak::constants;

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u64; 1], byte_position: Field) -> pub [u64; constants::NUM_LANES] {
  keccak::permutations::absorb(input, byte_position)
}
