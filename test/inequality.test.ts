import { compile } from '@noir-lang/noir_wasm';
import {
  setup_generic_prover_and_verifier,
  create_proof,
  verify_proof,
  StandardExampleProver,
  StandardExampleVerifier,
} from '@noir-lang/barretenberg/dest/client_proofs';
import { resolve } from 'path';
import { expect } from 'chai';

type ProofInput = {
  x: number;
  y: number;
};

describe('Tests using typescript wrapper', function () {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let acir: any;
  let prover: StandardExampleProver;
  let verifier: StandardExampleVerifier;

  before(async () => {
    const compiled_program = compile(resolve(__dirname, '../circuits/src/main.nr'));
    acir = compiled_program.circuit;
    [prover, verifier] = await setup_generic_prover_and_verifier(acir);
  });

  async function createAndVerifyProof(abi: ProofInput): Promise<boolean> {
    const proof = await create_proof(prover, acir, abi);

    return verify_proof(verifier, proof);
  }

  context('when inputs are equal', () => {
    it('rejects the proof', async () => {
      const abi: ProofInput = { x: 3, y: 3 };
      const verified = await createAndVerifyProof(abi);

      expect(verified).to.be.false;
    });
  });

  context('when inputs are unequal', () => {
    it('accepts the proof', async () => {
      const abi: ProofInput = { x: 3, y: 4 };
      const verified = await createAndVerifyProof(abi);

      expect(verified).to.be.true;
    });
  });
});
