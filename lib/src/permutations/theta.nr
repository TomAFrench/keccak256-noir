global STATE_SIZE: Field = 1600;
global LANE_LENGTH: Field = 64;

fn theta(state: [u1; STATE_SIZE]) -> [u1; STATE_SIZE] {
    // The theta function works by calculating the parity of each of the columns in the state array. We store these
    // in the C[x, z] arrays.
    // C[x, z] = A[x, 0, z] ^ A[x, 1, z] ^ A[x, 2, z] ^ A[x, 3, z] ^ A[x, 4, z]
    let mut c0: [u1; LANE_LENGTH] = [0 as u1; 64];
    let mut c1: [u1; LANE_LENGTH] = [0 as u1; 64];
    let mut c2: [u1; LANE_LENGTH] = [0 as u1; 64];
    let mut c3: [u1; LANE_LENGTH] = [0 as u1; 64];
    let mut c4: [u1; LANE_LENGTH] = [0 as u1; 64];
    for i in 0..LANE_LENGTH {
      c0[i] = state[0 * LANE_LENGTH + i] ^ state[5 * LANE_LENGTH + i] ^ state[10 * LANE_LENGTH + i] ^ state[15 * LANE_LENGTH + i] ^ state[20 * LANE_LENGTH + i];
      c1[i] = state[1 * LANE_LENGTH + i] ^ state[6 * LANE_LENGTH + i] ^ state[11 * LANE_LENGTH + i] ^ state[16 * LANE_LENGTH + i] ^ state[21 * LANE_LENGTH + i];
      c2[i] = state[2 * LANE_LENGTH + i] ^ state[7 * LANE_LENGTH + i] ^ state[12 * LANE_LENGTH + i] ^ state[17 * LANE_LENGTH + i] ^ state[22 * LANE_LENGTH + i];
      c3[i] = state[3 * LANE_LENGTH + i] ^ state[8 * LANE_LENGTH + i] ^ state[13 * LANE_LENGTH + i] ^ state[18 * LANE_LENGTH + i] ^ state[23 * LANE_LENGTH + i];
      c4[i] = state[4 * LANE_LENGTH + i] ^ state[9 * LANE_LENGTH + i] ^ state[14 * LANE_LENGTH + i] ^ state[19 * LANE_LENGTH + i] ^ state[24 * LANE_LENGTH + i];
    };

    // D[x, z] = C[(x - 1) mod 5, z] ^ C[(x + 1) mod 5, (z - 1) mod LANE_LENGTH]
    let mut d0: [u1; LANE_LENGTH] = [0 as u1; 64]; // D[0, Z] = C[4, z] ^ C[1, (z-1) mod LANE_LENGTH]
    let mut d1: [u1; LANE_LENGTH] = [0 as u1; 64]; // D[1, Z] = C[0, z] ^ C[2, (z-1) mod LANE_LENGTH]
    let mut d2: [u1; LANE_LENGTH] = [0 as u1; 64]; // D[2, Z] = C[1, z] ^ C[3, (z-1) mod LANE_LENGTH]
    let mut d3: [u1; LANE_LENGTH] = [0 as u1; 64]; // D[3, Z] = C[2, z] ^ C[4, (z-1) mod LANE_LENGTH]
    let mut d4: [u1; LANE_LENGTH] = [0 as u1; 64]; // D[4, Z] = C[3, z] ^ C[0, (z-1) mod LANE_LENGTH]
    // The modulus only affects the first cell in the lane so we handle this outside of the for-loop.
    d0[0] = c4[0] ^ c1[LANE_LENGTH - 1];
    d1[0] = c0[0] ^ c2[LANE_LENGTH - 1];
    d2[0] = c1[0] ^ c3[LANE_LENGTH - 1];
    d3[0] = c2[0] ^ c4[LANE_LENGTH - 1];
    d4[0] = c3[0] ^ c0[LANE_LENGTH - 1];
    for i in 1..LANE_LENGTH {
      d0[i] = c4[i] ^ c1[i-1];
      d1[i] = c0[i] ^ c2[i-1];
      d2[i] = c1[i] ^ c3[i-1];
      d3[i] = c2[i] ^ c4[i-1];
      d4[i] = c3[i] ^ c0[i-1];
    };

    // The labelling convention for the state array is `state[x, y, z] = state[LANE_LENGTH * (5y + x) + z]`.
    let mut new_state = state;
    for y in 0..4 {
      // Iterate over each row...
      for i in 0..LANE_LENGTH {
        // and write updated values for each lane.
        new_state[LANE_LENGTH * (5 * y + 0) + i] = state[LANE_LENGTH * (5 * y + 0) + i] ^ d0[i];
        new_state[LANE_LENGTH * (5 * y + 1) + i] = state[LANE_LENGTH * (5 * y + 1) + i] ^ d1[i];
        new_state[LANE_LENGTH * (5 * y + 2) + i] = state[LANE_LENGTH * (5 * y + 2) + i] ^ d2[i];
        new_state[LANE_LENGTH * (5 * y + 3) + i] = state[LANE_LENGTH * (5 * y + 3) + i] ^ d3[i];
        new_state[LANE_LENGTH * (5 * y + 4) + i] = state[LANE_LENGTH * (5 * y + 4) + i] ^ d4[i];
      };
    };

    new_state
}
