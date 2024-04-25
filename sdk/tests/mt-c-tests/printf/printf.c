#include <stdio.h>
#include <string.h>

#include <flexpret/flexpret.h>

// Using floats increases the final .mem by approximately 30 kB
#define HAVE_FLOATS (PRINTF_SUPPORT_DECIMAL_SPECIFIERS == 1)

int i = 22;
const char *some_string = "This is some string!";

#if HAVE_FLOATS
float f = 8.928;
#endif

void *printer(void *args) {
    UNUSED(args);
    
#if HAVE_FLOATS
    printf("The variable f is: %f\n", f);
#endif

    printf("The variable i is: %i\n", i);
    printf("Some string is: %s\n", some_string);
    return NULL;
}

int main() {
    printf("Hello world %i\n", i);

    fp_thread_t tid[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_assert(fp_thread_create(HRTT, &tid[i], printer, NULL) == 0, "Could not create thread");
    }

    void *exit_codes[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_thread_join(tid[i], &exit_codes[i]);
        fp_assert(exit_codes[i] == 0, "Thread's exit code was non-zero");
    }

    printf("Bye to all threads\n");
    return 0;
}
