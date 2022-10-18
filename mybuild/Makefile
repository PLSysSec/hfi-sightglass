.DEFAULT_GOAL := build

# if we use gcc or cc, hfi mode breaks in gem5
# CC=clang

ROOT_PATH=$(shell realpath ../..)
WABT_SRC_ROOT=$(ROOT_PATH)/hfi_wasm2c_sandbox_compiler/
UVWASI_PATH=$(WABT_SRC_ROOT)/third_party/uvwasi
HFIPATH=$(ROOT_PATH)/hw_isol_gem5/tests/test-progs/hfi/

WASM2C_RUNTIME_PATH=$(WABT_SRC_ROOT)/wasm2c/
WASM2C_RUNTIME_FILES=$(addprefix $(WASM2C_RUNTIME_PATH), wasm-rt-impl.c wasm-rt-os-unix.c uvwasi-rt.c wasm-rt-runner-static.c)
# ifdef NOTIMED
ENGINE=engine-noop.c
# else
# 	ENGINE=engine-timed.c
# endif

# Just pick one of the builds, as we only want wasm2c and uv which are unchanges across all versions
WABT_BIN_ROOT=$(WABT_SRC_ROOT)/build_release_guardpages
WASM2C=$(WABT_BIN_ROOT)/wasm2c
INCS=-I$(UVWASI_PATH)/include -I$(WASM2C_RUNTIME_PATH) -I$(HFIPATH)
DEPS=-L$(WABT_BIN_ROOT)/_deps/libuv-build -L$(WABT_BIN_ROOT)/third_party/uvwasi
LIBS=-luvwasi_a -luv_a -ldl -lpthread -lm

# wasm2c: spidermonkey blake3-simd intgemm-simd
# length: meshoptimizer shootout-ed25519 shootout-seqhash
# hfiemulate: bz2
BENCHMARKS=$(shell cat ./SightglassBench.inc)
BENCHMARK_FLAGS=-O3

.PRECIOUS: %.wasm.c
%.wasm.c: ../benchmarks/%/benchmark.wasm
	$(WASM2C) $< -o $@

.PRECIOUS: %_build_guardpage
%_build_guardpage: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_GUARD_PAGES -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_guardpage

.PRECIOUS: %_build_guardpage_asmmove
%_build_guardpage_asmmove: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_GUARD_PAGES -DWASM_NONHFI_USE_ASM_MOVE -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_guardpage_asmmove

.PRECIOUS: %_build_boundschecks
%_build_boundschecks: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_BOUNDS_CHECKS -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_boundschecks

.PRECIOUS: %_build_masking
%_build_masking: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_MASKING -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_masking

.PRECIOUS: %_build_hfi
%_build_hfi: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_HFI -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_hfi

.PRECIOUS: %_build_hfiemulate
%_build_hfiemulate: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_HFI -DHFI_EMULATION -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_hfiemulate

.PRECIOUS: %_build_hfiemulate2
%_build_hfiemulate2: %.wasm.c $(WASM2C_RUNTIME_FILES) $(ENGINE)
	$(CC) $(BENCHMARK_FLAGS) -DWASM_USE_HFI -DHFI_EMULATION2 -o $@ $< $(WASM2C_RUNTIME_FILES) $(ENGINE) $(INCS) $(DEPS) $(LIBS)
	cp $@ ../benchmarks/$*/benchmark_hfiemulate2

%_all: %_build_guardpage %_build_guardpage_asmmove %_build_hfi %_build_hfiemulate %_build_hfiemulate2
	touch $*_all

build: $(addsuffix _all, $(BENCHMARKS))

%_guardpage_run:
	echo "Running ../benchmarks/$*/benchmark_guardpage" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage.json" ./benchmark_guardpage && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage"

%_guardpage_asmmove_run:
	echo "Running ../benchmarks/$*/benchmark_guardpage_asmmove" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage_asmmove.json" ./benchmark_guardpage_asmmove && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage_asmmove.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_guardpage_asmmove"

%_boundschecks_run:
	echo "Running ../benchmarks/$*/benchmark_boundschecks" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_boundschecks.json" ./benchmark_boundschecks && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_boundschecks.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_boundschecks"

%_masking_run:
	echo "Running ../benchmarks/$*/benchmark_masking" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_masking.json" ./benchmark_masking && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_masking.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_masking"

%_hfi_run:
	echo "Running ../benchmarks/$*/benchmark_hfi" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfi.json" ./benchmark_hfi && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfi.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfi"

%_hfiemulate_run:
	echo "Running ../benchmarks/$*/benchmark_hfiemulate" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate.json" ./benchmark_hfiemulate && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate"

%_hfiemulate2_run:
	echo "Running ../benchmarks/$*/benchmark_hfiemulate2" \
		&& cd ../benchmarks/$* && \
		hyperfine -N --warmup 10 --export-json "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate2.json" ./benchmark_hfiemulate2 && \
		cat "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate2.json" | jq '.results[0].mean * 1000' > "$(SIGHTGLASS_OUTPUTFOLDER)/$*_hfiemulate2"


run_guardpage         : $(addsuffix _guardpage_run,         $(BENCHMARKS))
run_guardpage_asmmove : $(addsuffix _guardpage_asmmove_run, $(BENCHMARKS))
run_boundschecks      : $(addsuffix _boundschecks_run,      $(BENCHMARKS))
run_masking           : $(addsuffix _masking_run,           $(BENCHMARKS))
run_hfi               : $(addsuffix _hfi_run,               $(BENCHMARKS))
run_hfiemulate        : $(addsuffix _hfiemulate_run,        $(BENCHMARKS))
run_hfiemulate2       : $(addsuffix _hfiemulate2_run,       $(BENCHMARKS))

%_remove_benchmark:
	rm -f ../benchmarks/$*/benchmark_*

clean: $(addsuffix _remove_benchmark, $(BENCHMARKS))
	rm -f *.wasm*
	rm -f *_*
