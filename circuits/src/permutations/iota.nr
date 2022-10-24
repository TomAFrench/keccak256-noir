const STATE_SIZE: Field = 1600;
const LANE_LENGTH: Field = 64;
const NUM_ROUNDS: Field = 24;

fn iota(state: [u1; STATE_SIZE], round_number: Field) -> [u1; STATE_SIZE] {
  // Each element of RC is a bitmap for the mask to apply to the lane.
  let RC: [u64; NUM_ROUNDS] = [
        0x0000000000000001, 0x0000000000008082, 0x800000000000808A,
        0x8000000080008000, 0x000000000000808B, 0x0000000080000001,
        0x8000000080008081, 0x8000000000008009, 0x000000000000008A,
        0x0000000000000088, 0x0000000080008009, 0x000000008000000A,
        0x000000008000808B, 0x800000000000008B, 0x8000000000008089,
        0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
        0x000000000000800A, 0x800000008000000A, 0x8000000080008081,
        0x8000000000008080, 0x0000000080000001, 0x8000000080008008
    ];
    let mut rc = RC[round_number];

    // The labelling convention for the state array is `state[x, y, z] = state[LANE_LENGTH * (5y + x) + z]`.
    // In order to update Lane(0,0) we must only update the first `LANE_LENGTH` values of the state array.
    let mut new_state = state;
    for i in 0..LANE_LENGTH {
      new_state[i] = state[i] ^ (rc & 1);
      // Equivalent to a bitshift right.
      rc = rc / 2;
    };
    new_state
}
