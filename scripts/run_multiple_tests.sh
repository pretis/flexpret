set -e

# $1: Which config to run
run_test() {
    # Get a clean state
    rm -rf $FP_PATH/build && rm -rf $FP_SDK_PATH/build && rm -rf $FP_SDK_PATH/flexpret
    
    # Build FlexPRET
    cd $FP_PATH && cmake -DFP_CONFIG=$1 -B build && cmake --build build && cmake --install build
    
    # Build SDK and run tests
    cd $FP_SDK_PATH && cmake -B build && cmake --build build && ctest --test-dir build --output-on-failure
}

# These configurations correspond with the files inside `./flexpret/cmake/configs`
configs=(
    highmem 8threads 3threads 5threads@50MHz
)

# Run test on each config
for cfg in "${configs[@]}"
do
    run_test $cfg
done
