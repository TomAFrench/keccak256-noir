mod constants;
mod padding;
mod permutations;

fn keccak(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::OUTPUT_SIZE] {
  let padded_input: [u64; constants::BLOCK_SIZE] = padding::pad(input, input_length);

  let final_state: [u64; constants::NUM_LANES] = permutations::absorb(padded_input);

  let output = permutations::squeeze(final_state);

  output
}

#[test]
fn test_keccak() {
  {
    let input: [u64; constants::INPUT_SIZE] = [0; constants::INPUT_SIZE];
    let input_length: u64 = 0;
    let expected_output: [u64; constants::OUTPUT_SIZE] = [
      0xA7FFC6F8BF1ED766,
      0x51C14756A061D662,
      0xF580FF4DE43B49FA,
      0x82D80A4B80F8434A 
    ];
    constrain keccak(input, input_length) == expected_output;
  }
}