use dep::keccak::padding::get_bit_mask;

fn main(input: u64, bit_position: Field) -> pub u64 {
  let bit_mask: u64 = get_bit_mask(bit_position);

  input | bit_mask
}
