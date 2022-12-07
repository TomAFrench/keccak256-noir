use dep::keccak::padding::get_bit_mask;

fn main(bit_position: Field) -> pub u64 {
  let bit_mask: Field = get_bit_mask(bit_position);

  (2 * bit_mask - 1) as u64
}
