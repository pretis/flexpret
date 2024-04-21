#include <stdint.h>
#include <flexpret/flexpret.h>

int main() {
    uint32_t t1 = rdtime();
    printf("First  rdtime() call: %i\n", (int) t1);

    uint32_t t2 = rdtime();
    printf("Second rdtime() call: %i\n", (int) t2);

    fp_assert(t1 < t2, "Second call to rdtime() had smaller time value");

    uint64_t t3 = rdtime64();
    printf("First  rdtime64() call:\n\t[63-32]: %i\n\t[31- 0]: %i\n", (int) t3, (int) (t3 >> 32));

    uint64_t t4 = rdtime64();
    printf("Second rdtime64() call:\n\t[63-32]: %i\n\t[31- 0]: %i\n", (int) t4, (int) (t4 >> 32));

    fp_assert(t3 < t4, "Second call to rdtime64() had smaller value");
}

