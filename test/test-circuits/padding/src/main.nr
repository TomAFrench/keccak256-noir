use dep::keccak::padding::pad;
use dep::keccak::constants;

fn main(input: [u1; constants::INPUT_SIZE], input_length: u64) -> pub [u1; constants::BLOCK_SIZE] {
  pad(input, input_length)
}
