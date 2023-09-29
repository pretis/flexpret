#include <stdio.h>
#include <string.h>

#include <flexpret.h>
#include <flexpret_io.h>
#include <assert.h>

static_assert(NUM_THREADS >= 3);

// FIXME: Printf does not work with arguments as of now...
void *printer(void *args) {
    puts("Hello world\n");
    return NULL;
}

int main() {
    puts("Hello world1\n");
    puts("Hello world12\n");
    puts("Hello world123\n");
    puts("Hello world1234\n");

    thread_t tid[2];
    int ok = thread_create(HRTT, &tid[0], printer, NULL);
    assert(ok == 0);
    ok = thread_create(HRTT, &tid[1], printer, NULL);
    assert(ok == 0);

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    _fp_print(1);
}
