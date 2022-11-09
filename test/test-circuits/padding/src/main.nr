use dep::keccak::padding::pad as pad;
use dep::keccak::constants as constants;

fn main(input: [u1; constants::INPUT_SIZE], input_length: u64) -> pub [u1; constants::BLOCK_SIZE] {
  pad(input, input_length)
}
