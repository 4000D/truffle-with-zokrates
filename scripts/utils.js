const convert = (c) => {
  if (c === 3) return 0;
  return c;
};

function copy(v) {
  return JSON.parse(JSON.stringify(v));
}

function convertBoard(board) {
  return copy(board).map((row) => row.map(convert));
}

function parseProofObj(obj) {
  const { proof } = obj;
  const { input } = obj;

  const _proof = [];
  Object.keys(proof).forEach((key) => _proof.push(proof[key]));
  _proof.push(input);
  return _proof;
}


module.exports = {
  copy,
  convertBoard,
  parseProofObj,
};
