set -e
# set -o xtrace

CC=clang

BMKS_PATH=$(dirname $(realpath -s $0))
ROOT_PATH=${BMKS_PATH}/../..
WASI_SDK_ROOT=${ROOT_PATH}/wasi-sdk
WASI_CLANG=${WASI_SDK_ROOT}/bin/clang
WASI_CLANG_CXX=${WASI_SDK_ROOT}/bin/clang

WASI_CFLAGS="--sysroot ${WASI_SDK_ROOT}/share/wasi-sysroot -Wl,--export-all -Wl,--global-base=100000 -Wl,-z,stack-size=1048576 -Wl,--growable-table"
BENCHMARK_FLAGS=-I$(realpath ../include)
WABT_ROOT=${ROOT_PATH}/hfi_wasm2c_sandbox_compiler

HFI_PATH=${ROOT_PATH}/hw_isol_gem5/tests/test-progs/hfi
UVWASI_PATH=${WABT_ROOT}/third_party/uvwasi
W2C_RT_PATH=${WABT_ROOT}/wasm2c
W2C_RT_FILES="${W2C_RT_PATH}/wasm-rt-impl.c ${W2C_RT_PATH}/wasm-rt-os-unix.c ${W2C_RT_PATH}/uvwasi-rt.c ${W2C_RT_PATH}/wasm-rt-runner-static.c"

INCS="-I${UVWASI_PATH}/include -I${W2C_RT_PATH} -I${HFI_PATH} -I${BMKS_PATH}"
LIBS="-luvwasi_a -luv_a -lpthread"

GP_FLAGS=-DWASM_USE_GUARD_PAGES
BC_FLAGS=-DWASM_USE_BOUNDS_CHECKS
M_FLAGS=-DWASM_USE_MASKING
HFI_FLAGS=-DWASM_USE_HFI
EMU1_FLAGS="${HFI_FLAGS} -DHFI_EMULATION"
EMU2_FLAGS="${HFI_FLAGS} -DHFI_EMULATION2"

build_bin() {
    BIN_ROOT=${WABT_ROOT}/build_release_guardpages
    ${BIN_ROOT}/wasm2c $1/hfi_benchmark.wasm -o $1/hfi_benchmark_${SEC_CHOICE}.c
    DEPS="-L${BIN_ROOT}/_deps/libuv-build -L${BIN_ROOT}/third_party/uvwasi"
    ${CC} -O3 $1/hfi_benchmark_${SEC_CHOICE}.c ${W2C_RT_FILES} -o $1/hfi_benchmark_${SEC_CHOICE} ${INCS} ${DEPS} ${SEC_FLAGS} ${LIBS}
}

for dir in */
do
    # if [[ "${dir}" == "spidermonkey/" ]]; then
    #     echo "***skipping spidermonkey.**"
    #     continue
    # fi
    dir=${dir%*/}
    CPPSRC=${dir}/benchmark.cpp
    CSRC=${dir}/benchmark.c
    if [[ ! -L "${dir}/Dockerfile" ]]; then
    echo "Skipping ${dir}, custom docker file!"
    continue
    fi

    echo Building $dir.wasm...
    if test -f "${CPPSRC}"; then
       ${WASI_CLANG} ${WASI_CFLAGS} ${BENCHMARK_FLAGS} ${CPPSRC} -o ${dir}/hfi_benchmark.wasm
    else
        ${WASI_CLANG_CXX} ${WASI_CFLAGS} ${BENCHMARK_FLAGS} ${CSRC} -o ${dir}/hfi_benchmark.wasm
    fi

    echo "Building ${dir} with guard pages."
    SEC_CHOICE=guardpages
    SEC_FLAGS=${GP_FLAGS}
    build_bin ${dir}

    echo "Building ${dir} with bounds checks."
    SEC_CHOICE=boundschecks
    SEC_FLAGS=${BC_FLAGS}
    build_bin ${dir}

    echo "Building ${dir} with masking."
    SEC_CHOICE=masking
    SEC_FLAGS=${M_FLAGS}
    build_bin ${dir}

    echo "Building ${dir} with HFI."
    SEC_CHOICE=hfi
    SEC_FLAGS=${HFI_FLAGS}
    build_bin ${dir}

    echo "Building ${dir} with HFI emulation 1."
    SEC_CHOICE=hfiemulate
    SEC_FLAGS=${EMU1_FLAGS}
    build_bin ${dir}

    echo "Building ${dir} with HFI emulation 2."
    SEC_CHOICE=hfiemulate2
    SEC_FLAGS=${EMU2_FLAGS}
    build_bin ${dir}

    echo "Done with ${dir}."
done

