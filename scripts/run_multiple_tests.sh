cd $FP_PATH && cmake -DCMAKE_CONFIG=config2 -B build && cmake --build build && cmake --install build
cd $FP_SDK_PATH && cmake -B build && cmake --build build && ctest --test-dir build

