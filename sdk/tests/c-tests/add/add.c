#include <stdint.h>
#include <flexpret/flexpret.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    
    int x = 1;
    printf("x is %i\n", x);
    int y = 2;
    printf("y is %i\n", y);

    int z = add(x, y);
    printf("z is %i\n", z);
    fp_assert(z == 3, "1 + 2 =/= 3");
    return 0;
}
