#!/bin/bash
# Iterating all directories under circuit
# setup circuit only matched name directory & code file.

TARGET_DIR=${1:-*/}

for d in $TARGET_DIR ; do
    DIR=$(basename $d)

    CODE_FILE=${DIR}.code
    TEST_FILE=${DIR}.test.code
    cd $DIR

    if [[ ! -z "$TEST" ]]; then
        echo "Test $DIR"

        if [ -f "$TEST_FILE" ]; then
            echo "Testing $DIR... "
            RUST_BACKTRACE=1 ../../zokrates compile -i $TEST_FILE -o $TEST_FILE.out --light # 1> /dev/null

            RUST_BACKTRACE=1 ../../zokrates compute-witness -i $TEST_FILE.out -o $TEST_FILE.witness --light
        else
            echo "No test file exists"
        fi
        # continue
    elif [ -f "$CODE_FILE" ]; then
        echo "Working on $DIR"
        rm -rf out*
        rm -rf *.key

        echo "Compilling $DIR... "
        RUST_BACKTRACE=1 ../../zokrates compile -i $DIR.code --light

        echo "Setting proving scheme..."
        ../../zokrates setup --proving-scheme pghr13 --light

        echo "Exporting verifier contract..."
        ../../zokrates export-verifier --proving-scheme pghr13 --output "${DIR}Verifier.sol" --contract-name "${DIR}Verifier"

        mv "${DIR}Verifier.sol"  "../../contracts/verifiers/${DIR}Verifier.sol"

        echo ""
        echo "$DIR initialized"
        echo ""
    fi

    cd ..
done
