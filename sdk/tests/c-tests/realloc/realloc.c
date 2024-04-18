// Example from https://www.geeksforgeeks.org/g-fact-66/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <flexpret/flexpret.h>

int main() {
	int *ptr = (int *)malloc(sizeof(int)*2);
	int i;
	int *ptr_new;
		
	*ptr = 1;
	*(ptr + 1) = 2;
		
	ptr_new = (int *)realloc(ptr, sizeof(int)*3);
	*(ptr_new + 2) = 3;
	for(i = 0; i < 3; i++) {
		printf("realloced[%i] is %i\n", i, *(ptr_new + i));
		fp_assert(*(ptr_new + i) == (i + 1), "Incorrect value");
	}

	return 0;
}

