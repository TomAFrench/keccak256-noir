use dep::keccak::padding::pad;
use dep::keccak::constants;

fn main(input: [u64; constants::INPUT_SIZE], input_length: u64) -> pub [u64; constants::BLOCK_SIZE] {
  let padded_input = pad(input, input_length);
  padded_input
}
