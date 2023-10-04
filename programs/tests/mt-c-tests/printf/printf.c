#include <stdio.h>
#include <string.h>

#include <flexpret.h>
#include <flexpret_io.h>
#include <assert.h>

#include <printf/printf.h>

// Using floats increases the final .mem by approximately 30 kB
#define HAVE_FLOATS (PRINTF_SUPPORT_DECIMAL_SPECIFIERS == 1)

// FIXME: For some reason, the test fails for more than 4 threads. It seems
//        to be some issue with more than 4 threads trying to use the locks, 
//        though not sure about this...
static_assert(NUM_THREADS <= 4);

int i = 22;
const char *some_string = "This is some string!";

#if HAVE_FLOATS
float f = 8.928;
#endif

void *printer(void *args) {
#if HAVE_FLOATS
    printf("The variable f is: %f\n", f);
#endif

    printf("The variable i is: %i\n", i);
    printf("Some string is: %s\n", some_string);
    return NULL;
}

int main() {
    printf("Hello world %i\n", i);

    thread_t tid[NUM_THREADS-1];
    for (int i = 0; i < NUM_THREADS-1; i++) {
        assert(thread_create(HRTT, &tid[i], printer, NULL) == 0);
    }

    void *exit_codes[NUM_THREADS-1];
    for (int i = 0; i < NUM_THREADS-1; i++) {
        thread_join(tid[i], &exit_codes[i]);
        assert(exit_codes[i] == 0);
    }

    printf("Bye to all threads\n");
    return 0;
}
