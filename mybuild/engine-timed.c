#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <time.h>
#include <unistd.h>

#define BILLION ((int64_t)1000000000)

static void setTime(struct timespec* time_struct) {
    if (clock_gettime(CLOCK_REALTIME, time_struct) == -1) {
        perror("clock gettime");
        abort();
    }
}

static struct timespec start;

void Z_benchZ_startZ_vv() {
    // Warmup
    struct timespec dummy;

    for (int i = 0; i < 10; i++) {
        setTime(&dummy);
    }

    (void) dummy;
    setTime(&start);
}

void Z_benchZ_endZ_vv() {
    struct timespec stop;
    setTime(&stop);

    int64_t ns = (stop.tv_sec - start.tv_sec) * BILLION  + (stop.tv_nsec - start.tv_nsec);
    printf("!!!Capture_Time(ns): %" PRIi64 "\n", ns);

    const char* outfile = getenv("SIGHTGLASS_OUTPUTFILE");
    if (outfile) {
        FILE *fp = fopen(outfile, "w");
        if(fp == NULL) {
            printf("%s file can't be opened\n", outfile);
            abort();
        }
        fprintf(fp, "%" PRIi64 , ns);
        fclose(fp);
    }
}
