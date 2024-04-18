/**
 * @file stack.c
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief This file tests the stack protection feature, which is enabled by passing
 * -fstack-protector<-all> to the compiler. The stack protector essentially 
 * pushes a value onto the stack at the beginning of a function and pops it 
 * at the end of the function. If the value is different, the __stack_chk_fail()
 * function is called.
 * 
 * This test aims to trigger the stack guard in several ways:
 *  1. By directly changing the variable during a function call.
 *  2. By allocating a huge variable on the stack (triggers a compile-time error).
 *     Had it not been for the compile-time error, it would overflow the stack.
 * 
 */

#include <stdio.h>
#include <string.h>

#include <flexpret/flexpret.h>
#include <flexpret/exceptions.h>

extern uint32_t __stack_chk_guard;

static volatile bool stack_fail_fnc_called[FP_THREADS] = THREAD_ARRAY_INITIALIZER(false);

// The function is weakly linked. Its default implementation would exit and fail
// the test. In this test, we want the function to be called but not fail the test.
// The solution is to override it with something that does not exit. 
void __stack_chk_fail(void) {
    int hartid = read_hartid();
    stack_fail_fnc_called[hartid] = true;
}

void break_stack_guard_direct(void) {
    /**
     * The way the stack guard works is that the variable __stack_chk_guard is
     * pushed on the stack at the beginning of the function. At the end of the
     * function, it is popped and checked against the value it had before the
     * function was called.
     * 
     * Therefore, changing it will break it and trigger __stack_chk_fail().
     */
    __stack_chk_guard--;
}

void break_stack_guard_bigvar(void) {
    /**
     * Some stack errors can be found at compile-time, e.g., if the compiler
     * sees that a variable is allocated which is bigger than the stack size.
     * This feature is enabled by passing -Wstack-usage=<stack size> to the
     * compiler.
     * 
     * The program will not compile if this array is bigger than the compile-time
     * configured stack size. The stack size can easily be changed in the
     * makefile of this folder.
     * 
     * Note that it may still crash, since the compiler does not have knowledge
     * of how many functions have been called before this one, and how much stack
     * those functions have used.
     * 
     */
    uint8_t big_array[1000];
    memset(big_array, 66, sizeof(big_array));
}

int safe_function(void) {
    return 42;
}

void *test_break_and_safe(void *args) {
    int hartid = read_hartid();

    break_stack_guard_direct();
    fp_assert(stack_fail_fnc_called[hartid] == true, 
        "Fail function not called after guard broken\n");
    stack_fail_fnc_called[hartid] = false;

    safe_function();
    fp_assert(stack_fail_fnc_called[hartid] == false, 
        "Fail function called when not supposed to\n");

    break_stack_guard_direct();
    fp_assert(stack_fail_fnc_called[hartid] == true, 
        "Fail function not called after guard broken\n");
    stack_fail_fnc_called[hartid] = false;
}

int main() {
    test_break_and_safe(NULL);

    printf("Test success in single-threaded environment\n");

    fp_thread_t tid[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_assert(fp_thread_create(HRTT, &tid[i], test_break_and_safe, NULL) == 0, 
            "Could not create thread\n");
    }


    void *exit_codes[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_thread_join(tid[i], &exit_codes[i]);
        fp_assert(exit_codes[i] == 0, "Thread's exit code was non-zero\n");
    }

    printf("Test success in multi-threaded environment\n");

    return 0;
}
