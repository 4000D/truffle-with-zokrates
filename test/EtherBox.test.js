const crypto = require('crypto');
const { expectEvent } = require('openzeppelin-test-helpers');


const {
  initialized,
  getFactorizationProof,
  getSha256Proof,
} = require('../scripts/docker');

const EtherBox = artifacts.require('EtherBox.sol');

const { randomHex, toBN } = web3.utils;


contract('EtherBox', () => {
  before(async function () {
    await initialized();

    const c = (7 ** 3) * (17 ** 9);
    const a = (7 ** 2) * (17 ** 3);
    const b = (7 ** 1) * (17 ** 6);

    this.factorizationInput = [c, a, b].map(toBN).map((n) => n.toString(10));

    const hex = randomHex(64).slice(2);

    const h0 = hex.slice(0, 32);
    const h1 = hex.slice(32, 64);
    const h2 = hex.slice(64, 96);
    const h3 = hex.slice(96, 128);

    this.sha256Input = [h0, h1, h2, h3].map(toBN).map((n) => n.toString(10));

    const h = crypto.createHash('sha256')
      .update(Buffer.from(hex, 'hex'))
      .digest('hex');

    this.etherBox = await EtherBox.new(c, `0x${h}`);
  });

  it('should solve factorization', async function () {
    const proof = await getFactorizationProof(...this.factorizationInput);

    const tx = await this.etherBox.solveFactorization(...proof);
    expectEvent.inLogs(tx.logs, 'FactorizationSolved');
  });

  it('should solve sha256', async function () {
    const proof = await getSha256Proof(...this.sha256Input);

    const tx = await this.etherBox.solveSha256(...proof);
    expectEvent.inLogs(tx.logs, 'Sha256Solved');
  });
});
