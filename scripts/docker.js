const Docker = require('dockerode');
const { parseProofObj } = require('./utils');

const docker = new Docker();

let c; // zokrates docker container
const cName = 'zokrates';
const cmdBase = '../genProof.sh';

async function execute(circuitName, cmd) {
  // set generated proof file when compute is complete.
  const workingDir = `/home/zokrates/circuits/${circuitName}`; // zokerates container Path

  const exec = await c.exec({
    Cmd: cmd.split(' '),
    WorkingDir: workingDir,
    AttachStdout: true,
    AttachStderr: true,
  });

  return new Promise(async (resolve, reject) => {
    await exec.start({ hijack: true, stdin: true }, (err, stream) => {
      if (err) {
        console.error(`Failed to execute ${cmd}`, err); // err null
        return reject(err);
      }

      let proof;
      const chunks = [];

      stream.on('end', (err) => {
        if (err) {
          console.error(`Failed to execute ${cmd}`, err); // err null
          return reject(err);
        }

        try {
          proof = chunks[chunks.length - 1];
          const i = proof.indexOf('{');
          proof = proof.slice(i);
          proof = JSON.parse(proof);
        } catch (e) {
          return reject(new Error(`Failed to parse proof json: ${e.message}`));
        }

        if (!proof) {
          return reject(new Error('proof is empty'));
        }

        return resolve(proof);
      });

      stream.on('data', (data) => {
        console.log(data.toString());
        chunks.push(data.toString());
      });
    });
  });
}

function initialized() {
  const MAX_TRY = 100;
  let i = 0;

  return new Promise((resolve, reject) => {
    const timer = () => setTimeout(() => {
      i++;
      if (i >= MAX_TRY) {
        return reject('Out of time');
      }

      if (!c) return timer();
      return resolve();
    }, 500);

    timer();
  });
}

(async () => {
  try {
    const containers = await docker.listContainers();

    c = containers.filter((c) => c.Names[0].includes(cName))[0];

    console.log('zokrates docker container running ', c.Id);
    c = await docker.getContainer(c.Id);
  } catch (e) {
    console.error('Failed to connect docker container', e);
    process.exit(-1);
  }
})();


async function getFactorizationProof() {
  console.log('arguments', arguments);
  const cmdArgs = [...arguments].join(' ');

  const proof = await execute('factorization', `${cmdBase} ${cmdArgs}`);
  return parseProofObj(proof);
}

async function getSha256Proof() {
  console.log('arguments', arguments);
  const cmdArgs = [...arguments].join(' ');

  const proof = await execute('sha256', `${cmdBase} ${cmdArgs}`);
  return parseProofObj(proof);
}


module.exports = {
  initialized,
  getFactorizationProof,
  getSha256Proof,
};
