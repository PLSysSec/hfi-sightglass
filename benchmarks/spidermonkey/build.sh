#!/bin/sh

set -x -e

SM=/usr/src/spidermonkey-wasi-embedding

# /opt/wasi-sdk/bin/clang++ -Wl,--export-all -Wl,--global-base=150000 -Wl,-z,stack-size=1048576 -Wl,--growable-table -O3 -std=c++17 -o /benchmark.wasm runtime.cpp -I$SM/release/include/ $SM/release/lib/*.o $SM/release/lib/*.a
/opt/wasi-sdk/bin/clang++ -O3 -std=c++17 -o /benchmark.wasm runtime.cpp -I$SM/release/include/ $SM/release/lib/*.o $SM/release/lib/*.a

/opt/wasi-sdk/bin/strip /benchmark.wasm
