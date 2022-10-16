#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <time.h>
#include <unistd.h>

__attribute__((weak)) uint32_t Z_envZ_emscripten_stack_get_endZ_iv(void* sbx) {
    return 0;
}

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

    // SIGHTGLASS_WRITEOUTPUT="1"
    // SIGHTGLASS_OUTPUTFOLDER="/tmp/"
    // SIGHTGLASS_OUTPUTFILE="shootout-heapsort_guardpages"
    const char* writeoutput = getenv("SIGHTGLASS_WRITEOUTPUT");
    const char* outputfile = getenv("SIGHTGLASS_OUTPUTFILE");
    const char* outputfolder = getenv("SIGHTGLASS_OUTPUTFOLDER");
    if (writeoutput) {
        if (!outputfile || !outputfolder) {
            printf("Could not save output. Expected SIGHTGLASS_OUTPUTFILE and SIGHTGLASS_OUTPUTFOLDER\n");
            abort();
        }

        char path[300];
        strcpy(path, outputfolder);
        strcat(path, "/");
        strcat(path, outputfile);

        FILE *fp = fopen(path, "w");
        if(fp == NULL) {
            printf("%s file can't be opened\n", path);
            abort();
        }
        fprintf(fp, "%" PRIi64 , ns);
        fclose(fp);
    }
}
