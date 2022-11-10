use crate::constants;

fn chi(state: [u2; constants::STATE_SIZE]) -> [u2; constants::STATE_SIZE] {
  // The labelling convention for the state array is `state[x, y, z] = state[LANE_LENGTH * (5y + x) + z]`.
  let mut new_state = state;
  for z in 0..constants::LANE_LENGTH {
    // Iterate over each slice...
    for y in 0..constants::COLUMN_LENGTH {
      // and write updated values for each row.
      // new_state[x, y, z] = new_state[x, y, z] ^ new_state[(x + 1) % 5, y, z] ^ new_state[(x + 2) % 5, y, z]
      new_state[constants::LANE_LENGTH * (5 * y + 0) + z] = state[constants::LANE_LENGTH * (5 * y + 0) + z] ^ state[constants::LANE_LENGTH * (5 * y + 1) + z] ^ state[constants::LANE_LENGTH * (5 * y + 2) + z];
      new_state[constants::LANE_LENGTH * (5 * y + 1) + z] = state[constants::LANE_LENGTH * (5 * y + 1) + z] ^ state[constants::LANE_LENGTH * (5 * y + 2) + z] ^ state[constants::LANE_LENGTH * (5 * y + 3) + z];
      new_state[constants::LANE_LENGTH * (5 * y + 2) + z] = state[constants::LANE_LENGTH * (5 * y + 2) + z] ^ state[constants::LANE_LENGTH * (5 * y + 3) + z] ^ state[constants::LANE_LENGTH * (5 * y + 4) + z];
      new_state[constants::LANE_LENGTH * (5 * y + 3) + z] = state[constants::LANE_LENGTH * (5 * y + 3) + z] ^ state[constants::LANE_LENGTH * (5 * y + 4) + z] ^ state[constants::LANE_LENGTH * (5 * y + 0) + z];
      new_state[constants::LANE_LENGTH * (5 * y + 4) + z] = state[constants::LANE_LENGTH * (5 * y + 4) + z] ^ state[constants::LANE_LENGTH * (5 * y + 0) + z] ^ state[constants::LANE_LENGTH * (5 * y + 1) + z];
    };
  };

  new_state
}
