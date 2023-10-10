// This test checks if global variables are properly initialized.
#include <stdint.h>
#include <flexpret.h>

int x = 1; 
int y = 2;

int main() {
    printf("global variable x is %i\n", x);
    printf("global variable y is %i\n", y);

    assert(x == 1, "x not properly set");
    assert(y == 2, "y not properly set");

    return 0;
}
