use crate::constants as constants;

mod chi;
mod iota;
mod rhoPi;
mod theta;

// This is a simplified implementation of the Keccak256 absorb function where we assume the input is smaller than the
// internal state size.
fn absorb(input: [u1; constants::BLOCK_SIZE]) -> [u1; constants::STATE_SIZE] {
  let mut state: [u1; constants::STATE_SIZE] = [0 as u1; constants::STATE_SIZE];

  // We should in theory XOR the input with the internal state. However we know that X ^ 0 = X so we can just write
  // the input into the state. We can do this as the input is guaranteed to be smaller than the state size.
  for i in 0..constants::BLOCK_SIZE {
    state[i] = input[i];
  };

  // TODO: apply keccak-p functions
  state = keccakf(state);

  state
}

fn squeeze(input: [u1; constants::STATE_SIZE]) -> [u1; constants::OUTPUT_SIZE] {

  // TODO: after PR for allowing expressions to be evaluated inside arrays gets merged in change array literal to [0 as u1; num_bits_out]
  let mut result: [u1; constants::OUTPUT_SIZE] = [0 as u1; constants::OUTPUT_SIZE];

  for i in 0..constants::STATE_SIZE {
    if (i < constants::OUTPUT_SIZE) {
      result[i] = input[i];
    }
  };
  result
}

fn keccakfRound(state: [u1; constants::STATE_SIZE], round_number: comptime Field) -> [u1; constants::STATE_SIZE] {

  let state_after_theta = theta::theta(state);
  let state_after_rhoPi = rhoPi::rhoPi(state_after_theta);
  let state_after_chi = chi::chi(state_after_rhoPi);
  let new_state = iota::iota(state_after_chi, round_number);

  new_state
}

fn keccakf(input: [u1; constants::STATE_SIZE]) -> [u1; constants::STATE_SIZE] {
  let mut state: [u1; constants::STATE_SIZE] = [0 as u1; constants::STATE_SIZE];
  for j in 0..constants::STATE_SIZE {
    state[j] = input[j];
  };
  for i in 0..constants::NUM_ROUNDS {
    state = keccakfRound(state, i);
  };
  state
}

fn keccakFinal(input: [u1; constants::INPUT_SIZE], input_length: u64) -> [u1; constants::STATE_SIZE] {
  let padded_input: [u1; constants::BLOCK_SIZE] = crate::padding::pad(input, input_length);

  let absorb_result: [u1; constants::STATE_SIZE] = absorb(padded_input);

  absorb_result
}

fn keccak(input: [u1; constants::INPUT_SIZE], input_length: u64) -> [u1; constants::OUTPUT_SIZE] {

  let final_state = keccakFinal(input, input_length);

  let squeezed_state = squeeze(final_state);

  squeezed_state
}
