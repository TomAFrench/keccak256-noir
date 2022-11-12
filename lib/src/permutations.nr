use crate::constants;

mod chi;
mod iota;
mod rhoPi;
mod theta;

// This is a simplified implementation of the Keccak256 absorb function where we assume the input is smaller than the
// internal state size.
fn absorb(input: [u64; constants::BLOCK_SIZE]) -> [u64; constants::NUM_LANES] {
  let mut state: [u64; constants::NUM_LANES] = [0 as u64; constants::NUM_LANES];

  // We should in theory XOR the input with the internal state. However we know that X ^ 0 = X so we can just write
  // the input into the state. We can do this as the input is guaranteed to be smaller than the state size.
  for i in 0..constants::BLOCK_SIZE {
    state[i] = input[i];
  };

  // TODO: apply keccak-p functions
  state = keccakf(state);

  state
}

fn squeeze(input: [u64; constants::NUM_LANES]) -> [u64; constants::OUTPUT_SIZE] {

  let mut result: [u64; constants::OUTPUT_SIZE] = [0 as u64; constants::OUTPUT_SIZE];

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
  let mut state: [u64; constants::NUM_LANES] = [0 as u64; constants::NUM_LANES];
  for j in 0..constants::NUM_LANES {
    state[j] = input[j];
  };
  for i in 0..constants::NUM_ROUNDS {
    state = keccakfRound(state, i);
  };
  state
}

fn keccakFinal(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::NUM_LANES] {
  let padded_input: [u64; constants::BLOCK_SIZE] = crate::padding::pad(input, input_length);

  let absorb_result: [u64; constants::NUM_LANES] = absorb(padded_input);

  absorb_result
}

fn keccak(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::OUTPUT_SIZE] {

  let final_state = keccakFinal(input, input_length);

  let squeezed_state = squeeze(final_state);

  squeezed_state
}
