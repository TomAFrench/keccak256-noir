use dep::keccak::padding::insert_bit_into_word_checked;

fn main(input: u64, bit_position: Field) -> pub u64 {
  let x = insert_bit_into_word_checked(input, bit_position);
  x
}
