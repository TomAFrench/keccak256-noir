use crate::constants;

// This function is a combination of the rho and pi functions as defined in the Keccak256 specification.
// We merge these two functions as rho consists of a rotation of the bits within each lane and pi is a remapping of
// the lane indices. We can then efficiently perform both of these steps simultaneously by writing the output of rho
// directly into the remapped lane specified by pi.
fn rhoPi(state: [u1; constants::STATE_SIZE]) -> [u1; constants::STATE_SIZE] {
    // These are precomputed pairs of indices within the state array which specify how to perform the pi mapping.
    // Lanes are remapped such that the lane sitting at index READ_LANE_OFFSETS[i] is remapped to WRITE_LANE_OFFSETS[i].
    let READ_LANE_OFFSETS: [comptime Field; 24] = [64, 640, 448, 704, 1088, 1152, 192, 320, 1024, 512, 1344, 1536, 256, 960, 1472, 1216, 832, 768, 128, 1280, 896, 1408, 576, 384];
    let WRITE_LANE_OFFSETS: [comptime Field; 24] = [384, 64, 640, 448, 704, 1088, 1152, 192, 320, 1024, 512, 1344, 1536, 256, 960, 1472, 1216, 832, 768, 128, 1280, 896, 1408, 576];


    // This array defines the rho mapping to be applied to each lane.
    // Each lane is rotated by the specified number of bits, mapping the z coordinate as `z -> (z - T[i]) % LANE_LENGTH`
    // This array is defined as `T[i] = ((i+1)(i+2) / 2) % LANE_LENGTH`
    // This definition adds an additional modulo compared to the spec but makes it easier to calculate correct offsets.
    let T: [comptime Field; 24] = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, 27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44];

    let mut new_state: [u1; constants::STATE_SIZE] = [0 as u1; constants::STATE_SIZE];
    // The center lane is unaffected by the rho and pi functions so we write it directly into the new state.
    for i in 0..constants::LANE_LENGTH {
        new_state[i] = state[i];
    };

    // Now for the remaining lanes we write the rotated lane outputted from rho into the remapped lane specified by pi.
    for i in 0..constants::NUM_LANES - 1 {
      for z in 0..constants::LANE_LENGTH {
        // This is equivalent to `(z - T[i]) % LANE_LENGTH`
        let shifted_z_position = if z >= T[i] { z - T[i] } else { constants::LANE_LENGTH - T[i] + z };
        new_state[WRITE_LANE_OFFSETS[i] + z] = state[READ_LANE_OFFSETS[i] + shifted_z_position];
      };
    };

    new_state
}
