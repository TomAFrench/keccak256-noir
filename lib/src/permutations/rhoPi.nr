use crate::constants;

// This function is a combination of the rho and pi functions as defined in the Keccak256 specification.
// We merge these two functions as rho consists of a rotation of the bits within each lane and pi is a remapping of
// the lane indices. We can then efficiently perform both of these steps simultaneously by writing the output of rho
// directly into the remapped lane specified by pi.
fn rhoPi(state: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
    // These are precomputed pairs of indices within the state array which specify how to perform the pi mapping.
    // Lanes are remapped such that the lane sitting at index READ_LANE_OFFSETS[i] is remapped to WRITE_LANE_OFFSETS[i].
    let READ_LANE_OFFSETS: [comptime Field; 24] = [1, 10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6];
    let WRITE_LANE_OFFSETS: [comptime Field; 24] = [6, 1, 10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9];

    // This array defines the rho mapping to be applied to each lane.
    // Each lane is rotated by the specified number of bits, mapping the z coordinate as `z -> (z - T[i]) % LANE_LENGTH`
    // This array is defined as `T[i] = ((i+1)(i+2) / 2) % LANE_LENGTH`
    // This definition adds an additional modulo compared to the spec but makes it easier to calculate correct offsets.
    let T: [comptime u64; 24] = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, 27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44];

    let mut new_state: [u64; constants::NUM_LANES] = [0 as u64; constants::NUM_LANES];

    // The center lane is unaffected by the rho and pi functions so we write it directly into the new state.
    new_state[0] = state[0];

    // Now for the remaining lanes we write the rotated lane outputted from rho into the remapped lane specified by pi.
    for i in 0..constants::NUM_LANES - 1 {
        new_state[WRITE_LANE_OFFSETS[i]] = rotl64(state[READ_LANE_OFFSETS[i]], T[i]);
    };

    new_state
}

fn rotl64(num: u64, rot: u64) -> u64 {
  (num << rot) | (num >> (64 - rot))
}
