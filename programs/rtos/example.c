#include "flexpret.h"
#include "flexpret_sched.h"

// Example task functions
void task1() {
// Task 1 implementation

}

void task2() {
// Task 2 implementation
}

int main() {
    scheduler_init();
    scheduler_add_task(task1, 1, 1000); // Task 1 with priority 1 and period 1000 microseconds
    scheduler_add_task(task2, 2, 2000); // Task 2 with priority 2 and period 2000 microseconds
    scheduler_run();
}