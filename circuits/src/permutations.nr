mod chi;
mod iota;
mod rhoPi;
mod theta;

const BLOCK_SIZE: Field = 1088; // Blocks are 136 bytes. 138 * 8 = 1088 bits.
const STATE_SIZE: Field = 1600;

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

  state
}
