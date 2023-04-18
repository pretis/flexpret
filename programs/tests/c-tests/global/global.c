// This test checks if global variables are properly initialized.
#include <stdint.h>
#include <flexpret.h>

int x = 1; 
int y = 2;

int main() {

    _fp_print(x);
    _fp_print(y);

    assert(x == 1);
    assert(y == 2);

    return 0;
}
