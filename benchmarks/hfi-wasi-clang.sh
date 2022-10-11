#!/bin/sh
/opt/wasi-sdk/bin/clang --sysroot /opt/wasi-sdk/share/wasi-sysroot -I../include -Wl,--export-all -Wl,--global-base=100000 -Wl,-z,stack-size=1048576 -Wl,--growable-table $*
