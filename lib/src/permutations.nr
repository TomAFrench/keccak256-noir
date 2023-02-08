use crate::constants;
use crate::padding;

mod chi;
mod iota;
mod rhoPi;
mod theta;

global BYTE: Field = 8;

// This is a simplified implementation of the Keccak256 absorb function where we assume the input is smaller than the
// absorption function's rate. This allows us to write the input into the state without performing permutations.
fn absorb(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::NUM_LANES] {
  let mut state: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // We should in theory XOR the input with the internal state. However we know that X ^ 0 = X so we can just write
  // the input into the state. We can do this as the input is guaranteed to be smaller than the rate.
  for i in 0..constants::INPUT_SIZE {
    // Caching the word from input here reduces the number of gates.
    let word = input[i];

    if input_length >= ((i + 1) * BYTE) as u64 {
      // The input continues past the end of the current word.
      // We then copy it verbatim into the padded input.

      state[i] = word;
    } else if input_length >= (i * BYTE) as u64 {
      // The input ends in this current word.
      // We must then insert the first padding bit at the correct location before copying it.

      // Subtracting `i * 8` from `input_length` shifts it into the range [0, 8)
      let byte_position: Field = input_length as Field - i * BYTE;

      padding::check_message_end(word, byte_position);
      
      // Copy across both the input and the padding bit.
      state[i] = padding::insert_delimited_suffix(word, byte_position);
    } else {
      // Input must be empty after end of message.
      constrain word == 0;
    }
  }

  state[constants::BLOCK_SIZE - 1] = 0x0000000000000080;

  keccakf(state)
}

fn squeeze(input: [u64; constants::NUM_LANES]) -> [u64; constants::OUTPUT_SIZE] {

  let mut result: [u64; constants::OUTPUT_SIZE] = [0; constants::OUTPUT_SIZE];

  for i in 0..constants::OUTPUT_SIZE {
      result[i] = input[i];
  };
  result
}

fn keccakfRound(state: [u64; constants::NUM_LANES], round_number: comptime Field) -> [u64; constants::NUM_LANES] {

  let state_after_theta = theta::theta(state);
  let state_after_rhoPi = rhoPi::rhoPi(state_after_theta);
  let state_after_chi = chi::chi(state_after_rhoPi);
  let new_state = iota::iota(state_after_chi, round_number);

  new_state
}

fn keccakf(input: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
  let mut state = input;
  for i in 0..constants::NUM_ROUNDS {
    state = keccakfRound(state, i);
  };
  state
}

#[test]
fn test_keccakfRound(){
  let input: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // Round 0
  let mut after_round_one: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];
  after_round_one[0] = 0x0000000000000001;
  constrain keccakfRound(input, 0) == after_round_one;
}

#[test]
fn test_keccakf(){
  // Test cases taken from:
  // https://github.com/XKCP/XKCP/blob/64404beeeb261b08a1076fe2f076e4e28dd9b040/tests/TestVectors/KeccakF-1600-IntermediateValues.txt
  let input_state: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // Permutation 0
  let perm_zero_output: [u64; constants::NUM_LANES] = [
    0xF1258F7940E1DDE7, 0x84D5CCF933C0478A, 0xD598261EA65AA9EE, 0xBD1547306F80494D, 0x8B284E056253D057,
    0xFF97A42D7F8E6FD4, 0x90FEE5A0A44647C4, 0x8C5BDA0CD6192E76, 0xAD30A6F71B19059C, 0x30935AB7D08FFC64,
    0xEB5AA93F2317D635, 0xA9A6E6260D712103, 0x81A57C16DBCF555F, 0x43B831CD0347C826, 0x01F22F1A11A5569F,
    0x05E5635A21D9AE61, 0x64BEFEF28CC970F2, 0x613670957BC46611, 0xB87C5A554FD00ECB, 0x8C3EE88A1CCF32C8,
    0x940C7922AE3A2614, 0x1841F924A2C509E4, 0x16F53526E70465C2, 0x75F644E97F30A13B, 0xEAF1FF7B5CECA249,
  ];
  constrain keccakf(input_state) == perm_zero_output;

  // Permutation 1
  let perm_one_output: [u64; constants::NUM_LANES] = [
    0x2D5C954DF96ECB3C, 0x6A332CD07057B56D, 0x093D8D1270D76B6C, 0x8A20D9B25569D094, 0x4F9C4F99E5E7F156,
    0xF957B9A2DA65FB38, 0x85773DAE1275AF0D, 0xFAF4F247C3D810F7, 0x1F1B9EE6F79A8759, 0xE4FECC0FEE98B425,
    0x68CE61B6B9CE68A1, 0xDEEA66C4BA8F974F, 0x33C43D836EAFB1F5, 0xE00654042719DBD9, 0x7CF8A9F009831265,
    0xFD5449A6BF174743, 0x97DDAD33D8994B40, 0x48EAD5FC5D0BE774, 0xE3B8C8EE55B7B03C, 0x91A0226E649E42E9,
    0x900E3129E7BADD7B, 0x202A9EC5FAA3CCE8, 0x5B3402464E1C3DB6, 0x609F4E62A44C1059, 0x20D06CD26A8FBF5C,
  ];
  constrain keccakf(perm_zero_output) == perm_one_output;

  // Zero input (after padding)
  let padded_zero_input: [u64; constants::NUM_LANES] = [
    0x0600000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000080, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000,
  ];
  let expected_output: [u64; constants::NUM_LANES] = [
    0xA7FFC6F8BF1ED766, 0x51C14756A061D662, 0xF580FF4DE43B49FA, 0x82D80A4B80F8434A,
    0x5266BEB7346BF3E2, 0x6695CCCA215987FF, 0x89BAB376577BD980, 0x3B316AFC55BDDE28,
    0xCC8EE4F1193DAC03, 0xE934E4C1EC3A1978, 0x791EE8AF23A987C2, 0x331F6001E34A6821,
    0x5FE7099E467E2E28, 0xB8B682C2D21E7DD1, 0x4E43AFADD2E050F0, 0xB089A96AFBF67553,
    0x1EF1FA3260B9C6C2, 0xB2A155F0D34D6863, 0xB2C28E988B3908D9, 0x26D30B3E90103F91,
    0x1798474D6634FC33, 0x58DE8F071A5C712B, 0x79973651927C0B14, 0x5EEBBDAAA7437385,
    0xE5707BFB0E6E1392 
  ];
  constrain keccakf(padded_zero_input) == expected_output;
}


#[test]
fn test_absorb() {
  let input: [u64; constants::INPUT_SIZE] = [
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
  ];
  let input_length: u64 = 8;
  let expected_output: [u64; constants::NUM_LANES] = [
    0xA7FFC6F8BF1ED766, 0x51C14756A061D662, 0xF580FF4DE43B49FA, 0x82D80A4B80F8434A,
    0x5266BEB7346BF3E2, 0x6695CCCA215987FF, 0x89BAB376577BD980, 0x3B316AFC55BDDE28,
    0xCC8EE4F1193DAC03, 0xE934E4C1EC3A1978, 0x791EE8AF23A987C2, 0x331F6001E34A6821,
    0x5FE7099E467E2E28, 0xB8B682C2D21E7DD1, 0x4E43AFADD2E050F0, 0xB089A96AFBF67553,
    0x1EF1FA3260B9C6C2, 0xB2A155F0D34D6863, 0xB2C28E988B3908D9, 0x26D30B3E90103F91,
    0x1798474D6634FC33, 0x58DE8F071A5C712B, 0x79973651927C0B14, 0x5EEBBDAAA7437385,
    0xE5707BFB0E6E1392 
  ];
  constrain absorb(input, input_length) == expected_output;
}

#[test]
fn test_squeeze() {
  let state: [u64; constants::NUM_LANES] = [
    0x2D5C954DF96ECB3C, 0x6A332CD07057B56D, 0x093D8D1270D76B6C, 0x8A20D9B25569D094, 0x4F9C4F99E5E7F156,
    0xF957B9A2DA65FB38, 0x85773DAE1275AF0D, 0xFAF4F247C3D810F7, 0x1F1B9EE6F79A8759, 0xE4FECC0FEE98B425,
    0x68CE61B6B9CE68A1, 0xDEEA66C4BA8F974F, 0x33C43D836EAFB1F5, 0xE00654042719DBD9, 0x7CF8A9F009831265,
    0xFD5449A6BF174743, 0x97DDAD33D8994B40, 0x48EAD5FC5D0BE774, 0xE3B8C8EE55B7B03C, 0x91A0226E649E42E9,
    0x900E3129E7BADD7B, 0x202A9EC5FAA3CCE8, 0x5B3402464E1C3DB6, 0x609F4E62A44C1059, 0x20D06CD26A8FBF5C,
  ];
  let expected_output: [u64; constants::OUTPUT_SIZE] = [
    0x2D5C954DF96ECB3C, 0x6A332CD07057B56D, 0x093D8D1270D76B6C, 0x8A20D9B25569D094,
  ];
  constrain squeeze(state) == expected_output;
}