use crate::constants;

fn theta(state: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
    // The theta function works by calculating the parity of each of the columns in the state array. We store these
    // in the C[x, z] arrays.
    // C[x, z] = A[x, 0, z] ^ A[x, 1, z] ^ A[x, 2, z] ^ A[x, 3, z] ^ A[x, 4, z]
    let c0: u64 = state[0] ^ state[5] ^ state[10] ^ state[15] ^ state[20];
    let c1: u64 = state[1] ^ state[6] ^ state[11] ^ state[16] ^ state[21];
    let c2: u64 = state[2] ^ state[7] ^ state[12] ^ state[17] ^ state[22];
    let c3: u64 = state[3] ^ state[8] ^ state[13] ^ state[18] ^ state[23];
    let c4: u64 = state[4] ^ state[9] ^ state[14] ^ state[19] ^ state[24];

    // D[x, z] = C[(x - 1) mod 5, z] ^ C[(x + 1) mod 5, (z - 1) mod LANE_LENGTH]
    let d0: u64 = c4 ^ rotl64(c1, 1);
    let d1: u64 = c0 ^ rotl64(c2, 1);
    let d2: u64 = c1 ^ rotl64(c3, 1);
    let d3: u64 = c2 ^ rotl64(c4, 1);
    let d4: u64 = c3 ^ rotl64(c0, 1);

    // The labelling convention for the state array is `lane(x, y) = state[5y + x]`.
    let mut new_state = state;
    for y in 0..constants::COLUMN_LENGTH {
        new_state[5 * y + 0] = state[5 * y + 0] ^ d0;
        new_state[5 * y + 1] = state[5 * y + 1] ^ d1;
        new_state[5 * y + 2] = state[5 * y + 2] ^ d2;
        new_state[5 * y + 3] = state[5 * y + 3] ^ d3;
        new_state[5 * y + 4] = state[5 * y + 4] ^ d4;
    };

    new_state
}

fn rotl64(num: u64, rot: comptime u64) -> u64 {
  (num << rot) | (num >> (64 - rot))
}
