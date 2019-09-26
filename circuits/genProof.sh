#!/bin/bash
# executed in each sub directory

echo "zokrates compute-witness --light -a $@"

../../zokrates compute-witness --light -a "$@" | tail -1

echo "zokrates generate-proof --proving-scheme pghr13"

../../zokrates generate-proof --proving-scheme pghr13

cat proof.json

rm proof.json
rm witness