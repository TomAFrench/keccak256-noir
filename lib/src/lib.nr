mod constants;
mod padding;
mod permutations;

fn keccak<I>(input: [u64; I], byte_position: Field) -> [u64; constants::OUTPUT_SIZE] {
  let final_state: [u64; constants::NUM_LANES] = permutations::absorb(input, byte_position);

  let output = permutations::squeeze(final_state);

  output
}

#[test]
fn test_keccak() {
  {
    let input: [u64; 1] = [0x6162630000000000];
    let byte_position: Field = 3;
    let expected_output: [u64; constants::OUTPUT_SIZE] = [
      0xA7FFC6F8BF1ED766,
      0x51C14756A061D662,
      0xF580FF4DE43B49FA,
      0x82D80A4B80F8434A 
    ];
    constrain keccak(input, byte_position) == expected_output;
  }
}