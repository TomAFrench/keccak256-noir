use crate::constants;

fn iota(state: [u64; constants::NUM_LANES], round_number: comptime Field) -> [u64; constants::NUM_LANES] {
  // Each element of RC is a bitmap for the mask to apply to the lane.
  let RC: [comptime u64; constants::NUM_ROUNDS] = [
        0x0000000000000001, 0x0000000000008082, 0x800000000000808A,
        0x8000000080008000, 0x000000000000808B, 0x0000000080000001,
        0x8000000080008081, 0x8000000000008009, 0x000000000000008A,
        0x0000000000000088, 0x0000000080008009, 0x000000008000000A,
        0x000000008000808B, 0x800000000000008B, 0x8000000000008089,
        0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
        0x000000000000800A, 0x800000008000000A, 0x8000000080008081,
        0x8000000000008080, 0x0000000080000001, 0x8000000080008008
    ];

    // In order to update Lane(0,0) we must only update the first element of the state array.
    let mut new_state = state;
    new_state[0] = state[0] ^ RC[round_number];

    new_state
}
