mod chi;
mod iota;
mod rhoPi;
mod theta;

global BLOCK_SIZE: Field = 1088; // Blocks are 136 bytes. 138 * 8 = 1088 bits.
global STATE_SIZE: Field = 1600;

// This is a simplified implementation of the Keccak256 absorb function where we assume the input is smaller than the
// internal state size.
fn absorb(input: [u1; BLOCK_SIZE]) -> [u1; STATE_SIZE] {
  let mut state: [u1; STATE_SIZE] = [0 as u1; 1600];

  // We should in theory XOR the input with the internal state. However we know that X ^ 0 = X so we can just write
  // the input into the state. We can do this as the input is guaranteed to be smaller than the state size.
  for i in 0..BLOCK_SIZE {
    state[i] = input[i];
  };

  // TODO: apply keccak-p functions
  state = keccakf(state);
  
  state
}

fn squeeze(input: [u1; STATE_SIZE]) -> [u1; 256] {
  
  // TODO: after PR for allowing expressions to be evaluated inside arrays gets merged in change array literal to [0 as u1; num_bits_out]
  let mut result: [u1; 256] = [0 as u1; 256];

  for i in 0..STATE_SIZE {
    if (i < 256) {
      result[i] = input[i];
    }
  };
  result
}

fn keccakfRound(state: [u1; STATE_SIZE], round_number: comptime Field) -> [u1; STATE_SIZE] {

  let state_after_theta = theta::theta(state);
  let state_after_rhoPi = rhoPi::rhoPi(state_after_theta);
  let state_after_chi = chi::chi(state_after_rhoPi);
  let new_state = iota::iota(state_after_chi, round_number);

  new_state
}

fn keccakf(input: [u1; STATE_SIZE]) -> [u1; STATE_SIZE] {
  let mut state: [u1; STATE_SIZE] = [0 as u1; 1600];
  for j in 0..STATE_SIZE {
    state[j] = input[j];
  };
  for i in 0..24 {
    state = keccakfRound(state, i);
  };
  state
}

fn keccakFinal(input: [u1; crate::padding::INPUT_SIZE], input_length: u64) -> [u1; STATE_SIZE] {
  let padded_input: [u1; crate::padding::BLOCK_SIZE] = crate::padding::pad(input, input_length);

  let absorb_result: [u1; STATE_SIZE] = absorb(padded_input);

  absorb_result
}

fn keccak(input: [u1; crate::padding::INPUT_SIZE], input_length: u64) -> [u1; 256] {

  let final_state = keccakFinal(input, input_length);

  let squeezed_state = squeeze(final_state);

  squeezed_state
}
