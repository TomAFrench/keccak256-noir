import { acir_from_bytes } from '@noir-lang/noir_wasm';
import {
  setup_generic_prover_and_verifier,
  create_proof,
  verify_proof,
  StandardExampleProver,
  StandardExampleVerifier,
} from '@noir-lang/barretenberg/dest/client_proofs';
import { resolve } from 'path';
import { expect } from 'chai';
import { readFileSync } from 'fs';

const INPUT_SIZE = 10;
const BLOCK_SIZE = 10;

type ProofInput = {
  input: number[];
  input_length: number;
  return: number[];
};

describe('pad10*1', function () {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let acir: any;
  let prover: StandardExampleProver;
  let verifier: StandardExampleVerifier;

  before(async () => {
    const acirByteArray = path_to_uint8array(resolve(__dirname, './test-circuits/padding/build/test.acir'));
    acir = acir_from_bytes(acirByteArray);
    [prover, verifier] = await setup_generic_prover_and_verifier(acir);
  });

  async function createAndVerifyProof(abi: ProofInput): Promise<boolean> {
    const proof = await create_proof(prover, acir, abi);
    return verify_proof(verifier, proof);
  }

  const padMessage = (input: number[], input_length: number, padded_length: number) => {
    if (input.slice(input_length).some((x) => x !== 0))
      throw new Error('input_length greater than actual input length');
    if (input_length > padded_length - 2) throw new Error('input_length greater than max allowed');

    const paddingArrayLength = padded_length - input_length;
    const paddingArray = Array(paddingArrayLength).fill(0);
    paddingArray[0] = 1;
    paddingArray[paddingArrayLength - 1] = 1;

    const paddedInput = [...input.slice(0, input_length), ...paddingArray];

    return paddedInput;
  };

  context('when input is longer than reported length', () => {
    it('rejects the proof', async () => {
      const input_length = 2;

      const input = Array.from({ length: INPUT_SIZE }, () => 0);

      const paddedInput = padMessage(input, input_length, BLOCK_SIZE);

      // We now write a 1 in the position after where the message should end to invalidate it.
      input[input_length] = 1;

      const abi: ProofInput = { input, input_length, return: paddedInput };
      const verified = await createAndVerifyProof(abi);

      expect(verified).to.be.false;
    });
  });

  context('when input matches expected input length', () => {
    it('pads the input correctly', async () => {
      const input_length = 2;

      // const input = Array.from({ length: INPUT_SIZE }, (_, i) => (i < input_length && i % 3 == 0 ? 1 : 0));
      const input = Array(INPUT_SIZE).fill(0);
      const paddedInput = padMessage(input, input_length, BLOCK_SIZE);

      const abi: ProofInput = { input, input_length, return: paddedInput };
      const verified = await createAndVerifyProof(abi);

      expect(verified).to.be.true;
    });
  });
});

function path_to_uint8array(path: string) {
  const buffer = readFileSync(path);
  return new Uint8Array(buffer);
}
