mod padding;
mod permutations;

// TODO: Change to final value (<= BLOCK_SIZE - 2).
global INPUT_SIZE: Field = 1088;

// TODO: Change to final value (1088)
global BLOCK_SIZE: Field = 1088; // Blocks are 136 bytes. 138 * 8 = 1088 bits.

// This is a simplified implementation of the Keccak256 hash function.
// In particular we assume that the `input_length` will be less than the size of the absorb step's block size.
fn main(input: [u1; padding::INPUT_SIZE], input_length: u64) -> pub [u1; 256] {
  //padding::pad(input, input_length)
  permutations::keccak(input, input_length)
}
