pragma solidity >=0.4.21 <0.6.0;

import { factorizationVerifier as FactorizationVerifier } from "./verifiers/factorizationVerifier.sol";
import { sha256Verifier as Sha256Verifier } from "./verifiers/sha256Verifier.sol";


contract EtherBox {
  uint256 public constant P = 2**252 - 1;
  uint256 public constant MAX_DEPOSIT = 2 ** 128 - 1;

  FactorizationVerifier public factorizationVerifier;
  Sha256Verifier public sha256Verifier;

  uint256 public N;
  bytes32 public H;

  uint256 public numSolutions;

  event FactorizationSolved();
  event Sha256Solved();


  modifier checkNumSolutions() {
    require(numSolutions < 2, "All ether are already withdrawn");
    _;
  }

  constructor(uint _n, bytes32 _h) public payable {
    require(msg.value < MAX_DEPOSIT, "Ether amount must be under MAX_DEPOSIT");
    require(_n < P, "n must be less than 2**252 - 1");

    factorizationVerifier = new FactorizationVerifier();
    sha256Verifier = new Sha256Verifier();

    N = _n;
    H = _h;
  }

  /**
   * circuit parameters a, b are private.
   * input[0] : c
   * input[1] : output
   */
  function solveFactorization(
    uint[2] calldata a,
    uint[2] calldata a_p,
    uint[2][2] calldata b,
    uint[2] calldata b_p,
    uint[2] calldata c,
    uint[2] calldata c_p,
    uint[2] calldata h,
    uint[2] calldata k,
    uint[2] calldata input
  ) external checkNumSolutions {
    require(input[0] == N, "N mismatch");

    require(factorizationVerifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input), "circuit is not verified");

    emit FactorizationSolved();

    _transfer();
  }

  /**
   * circuit parameters a, b, c, d are private.
   * input[0] : Most significant 128 bits of hash
   * input[1] : Least significant 128 bits of hash
   */
  function solveSha256(
    uint[2] calldata a,
    uint[2] calldata a_p,
    uint[2][2] calldata b,
    uint[2] calldata b_p,
    uint[2] calldata c,
    uint[2] calldata c_p,
    uint[2] calldata h,
    uint[2] calldata k,
    uint[2] calldata input
  ) external checkNumSolutions {
    require(_combine(input[0], input[1]) == H, "Hash mismatch");

    require(sha256Verifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input), "circuit is not verified");

    emit Sha256Solved();

    _transfer();
  }

  function _transfer() internal {
    uint amount = address(this).balance;

    if (numSolutions == 1) amount /= 2;
    numSolutions += 1;

    msg.sender.transfer(amount);
  }

  /**
   * @dev Concatenates the 2 chunks of 128 bits into 256 bits
   * @param _a Most significant 128 bits
   * @param _b Least significant 128 bits
   */
  function _combine(uint _a, uint _b) internal pure returns (bytes32 v) {
    bytes16 a = bytes16(uint128(_a));
    bytes16 b = bytes16(uint128(_b));
    bytes memory _v = new bytes(32);

    for (uint i = 0; i < 16; i++) {
      _v[i] = a[i];
      _v[16 + i] = b[i];
    }
    v = _bytesToBytes32(_v, 0);
  }

  function _bytesToBytes32(bytes memory b, uint offset) internal pure returns (bytes32 out) {
    for (uint i = 0; i < 32; i++) {
      out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
    }
  }
}