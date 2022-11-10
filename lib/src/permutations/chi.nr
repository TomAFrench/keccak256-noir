use crate::constants;

fn chi(state: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
  let mut new_state = state;

  // The labelling convention for the state array is `Lane(x, y) = state[5y + x]`.
  // Iterate over each plane and write updated values for each lane.
  for y in 0..constants::COLUMN_LENGTH {
    new_state[5 * y + 0] = state[5 * y + 0] ^ ((!state[5 * y + 1]) & state[5 * y + 2]);
    new_state[5 * y + 1] = state[5 * y + 1] ^ ((!state[5 * y + 2]) & state[5 * y + 3]);
    new_state[5 * y + 2] = state[5 * y + 2] ^ ((!state[5 * y + 3]) & state[5 * y + 4]);
    new_state[5 * y + 3] = state[5 * y + 3] ^ ((!state[5 * y + 4]) & state[5 * y + 0]);
    new_state[5 * y + 4] = state[5 * y + 4] ^ ((!state[5 * y + 0]) & state[5 * y + 1]);
  };

  new_state
}
