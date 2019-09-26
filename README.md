## 1. initialize

```bash
$ npm i -g truffle
$ truffle init .
$ mkdir contracts/verifiers
$ git init .
$ npm init -y
```

## 2. write zokratets circuits
```bash
$ mkdir circuits
$ touch circuits/{othelloMove.code,othelloDecide.code} # and edit
```

## 3. write solidity contract

## 4. run docker

## 5. write JS helper to contact docker container

## 6. write test, and test...

```bash

# compile zokrates source code into arithmetic circuit
$ zokrates compile -i <file>

# generate witness
$ zokrates compute-witness -a <space-seperated-arguments>

# set up proving key, verification key
$ zokrates setup --proving-scheme <pghr13|g16|gm17>

# generate verifier smart contract written in Solidity
$ zokrates export-verifier --proving-scheme <pghr13|g16|gm17>

# generate verifier smart contract written in Solidity
$ zokrates generate-proof --proving-scheme <pghr13|g16|gm17>

.
├── circuits                          # zokrates source code
│   ├── factorization                 # circuit 1. factorization
│   │   ├── factorization.code
│   │   └── factorization.test.code
│   │
│   ├── sha256                        # circuit 2. sha256
│   │   ├── sha256.code
│   │   └── sha256.test.code
│   │
│   ├── build.sh                      # build each circuits
│   └── genProof.sh                   # generate proof
│
├── contracts                         # solidity source code
│   ├── EtherBox.sol
│   └── verifiers                     # circuit verifier contract
│       ├── factorizationVerifier.sol
│       └── sha256Verifier.sol
│  
├── scripts
│   ├── docker.js                     # docker connection helper
│   └── utils.js
│  
├── test
│   └── EtherBox.test.js
└── truffle-config.js


```