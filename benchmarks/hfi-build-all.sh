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

    echo Building $dir...
    if test -f "${CPPSRC}"; then
	./hfi-wasi-clang.sh ${CPPSRC} -o ${dir}/hfi_benchmark.wasm
    else
	./hfi-wasi-clang.sh ${CSRC} -o ${dir}/hfi_benchmark.wasm
    fi
done
