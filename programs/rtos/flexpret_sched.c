#include "flexpret_sched.h"

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// RISC-V context structure
typedef struct {
    uint32_t regs[32];
    uint32_t mstatus;
    uint32_t mepc;
} context_t;

// Task structure
typedef struct {
    task_func func;
    uint32_t priority;
    uint32_t period;
    uint32_t next_run_time;
    bool released;
    context_t *context;
} task_t;

#define MAX_TASKS 5
#define TASK_STACK_SIZE 1024

task_t tasks[MAX_TASKS];
uint8_t task_stacks[MAX_TASKS][TASK_STACK_SIZE];
uint32_t task_count = 0;
uint32_t current_task = UINT32_MAX;


void scheduler_init() {
    // Set up timer interrupt, assuming a provided API

}

// FIXME: Return status
// FIXME: Priority must be greater than 0
void scheduler_add_task(task_func func, uint32_t priority, uint32_t period) {
    if (task_count < MAX_TASKS) {
        tasks[task_count].func = func;
        tasks[task_count].priority = priority;
        tasks[task_count].period = period;
        tasks[task_count].next_run_time = 0;
        task_count++;
    }
}

static void update_task_released_status() {
    uint32_t current_time = get_current_time();
    for (uint32_t i = 0; i < task_count; i++) {
        if (tasks[i].next_run_time <= current_time) {
            tasks[i].released = true;
        }
    }
}

static uint32_t get_highest_priority_released_task() {
    uint32_t highest_priority_task = UINT32_MAX;
    uint32_t highest_priority = 0;

    for (uint32_t i = 0; i < task_count; i++) {
        if (tasks[i].released && tasks[i].priority > highest_priority) {
            highest_priority_task = i;
            highest_priority = tasks[i].priority;
        }
    }

    return highest_priority_task;
}

uint32_t get_next_interrupt_time() {
    uint32_t next_interrupt_time = UINT32_MAX;
    for (uint32_t i = 0; i < task_count; i++) {
        if (tasks[i].next_run_time < next_interrupt_time) {
            next_interrupt_time = tasks[i].next_run_time;
        }
    }

    return next_interrupt_time;
} 

static void schedule_future_interrupt(uint32_t time) {

}

void scheduler_run() {
    while (1) {


        update_task_released_status();
        uint32_t next_task = get_highest_priority_released_task();
        uint32_t next_event = get_next_interrupt_time();

        if (next_task != UINT32_MAX) {    
            schedule_future_interrupt(next_event);
            current_task = next_tas
        }

        uint32_t current_time = get_current_time();
        for (uint32_t i = 0; i < task_count; i++) {
            if (tasks[i].next_run_time <= current_time) {
                tasks[i].func();
                tasks[i].next_run_time = current_time + tasks[i].period;
            }
        }

        // Sleep for the shortest task period
        uint32_t min_period = UINT32_MAX;
        for (uint32_t i = 0; i < task_count; i++) {
            if (tasks[i].next_run_time - current_time < min_period) {
                min_period = tasks[i].next_run_time - current_time;
            }
        }
        sleep_duration(min_period);
    }
}

// Timer interrupt handler
void timer_interrupt_handler() {
    uint32_t next_task = 0;
    uint32_t highest_priority = 0;
    uint32_t current_time = get_current_time();

    for (uint32_t i = 0; i < task_count; i++) {
        if (tasks[i].next_run_time <= current_time && tasks[i].priority > highest_priority) {
            next_task = i;
            highest_priority = tasks[i].priority;
        }
    }

    if (next_task != current_task) {
        context_switch(&tasks[current_task], &tasks[next_task]);
        current_task = next_task;
    }
}



// Functions to get and set the stack pointer
uint32_t get_stack_pointer() {
    uint32_t sp;
    asm volatile("mv %0, sp" : "=r"(sp));
    return sp;
}

void set_stack_pointer(uint32_t sp) {
    asm volatile("mv sp, %0" : : "r"(sp));
}

// FIXME: This function shall be called from the ISR. But what happens in this process?
// I think we can assume that nothing is being saved when there is a IE interrupt.
// This is somehow quite easy. We have to manually  
void context_switch(task_t *old_task, task_t *new_task) {
    // Save the context of the old task
    asm volatile("addi sp, sp, -132"); // Make room for the context on the stack
    asm volatile("sw ra, 0(sp)");      // Save registers on the stack
    asm volatile("sw x1, 4(sp)");
    asm volatile("sw x2, 8(sp)");
    asm volatile("sw x3, 12(sp)");
    asm volatile("sw x4, 16(sp)");
    asm volatile("sw x5, 20(sp)");
    asm volatile("sw x6, 24(sp)");
    asm volatile("sw x7, 28(sp)");
    asm volatile("sw x8, 32(sp)");
    asm volatile("sw x9, 36(sp)");
    asm volatile("sw x10, 40(sp)");
    asm volatile("sw x11, 44(sp)");
    asm volatile("sw x12, 48(sp)");
    asm volatile("sw x13, 52(sp)");
    asm volatile("sw x14, 56(sp)");
    asm volatile("sw x15, 60(sp)");
    asm volatile("sw x16, 64(sp)");
    asm volatile("sw x17, 68(sp)");
    asm volatile("sw x18, 72(sp)");
    asm volatile("sw x19, 76(sp)");
    asm volatile("sw x20, 80(sp)");
    asm volatile("sw x21, 84(sp)");
    asm volatile("sw x22, 88(sp)");
    asm volatile("sw x23, 92(sp)");
    asm volatile("sw x24, 96(sp)");
    asm volatile("sw x25, 100(sp)");
    asm volatile("sw x26, 104(sp)");
    asm volatile("sw x27, 108(sp)");
    asm volatile("sw x28, 112(sp)");
    asm volatile("sw x29, 116(sp)");
    asm volatile("sw x30, 120(sp)");
    asm volatile("sw x31, 124(sp)");
    asm volatile("csrr t0, mstatus");
    asm volatile("sw t0, 128(sp)");

    // Store the old task's stack pointer
    old_task->context = (context_t *)get_stack_pointer();

    // Restore the new task's context
    set_stack_pointer((uint32_t)new_task->context);
    asm volatile("lw t0, 128(sp)");
    asm volatile("csrw mstatus, t0");
    asm volatile("lw ra, 0(sp)"); // Load registers from the stack
    asm volatile("lw x1, 4(sp)");
    asm volatile("lw x2, 8(sp)");
    asm volatile("lw x3, 12(sp)");
    asm volatile("lw x4, 16(sp)");
    asm volatile("lw x5, 20(sp)");
    asm volatile("lw x6, 24(sp)");
    asm volatile("lw x7, 28(sp)");
    asm volatile("lw x8, 32(sp)");
    asm volatile("lw x9, 36(sp)");
    asm volatile("lw x10, 40(sp)");
    asm volatile("lw x11, 44(sp)");
    asm volatile("lw x12, 48(sp)");
    asm volatile("lw x13, 52(sp)");
    asm volatile("lw x14, 56(sp)");
    asm volatile("lw x15, 60(sp)");
    asm volatile("lw x16, 64(sp)");
    asm volatile("lw x17, 68(sp)");
    asm volatile("lw x18, 72(sp)");
    asm volatile("lw x19, 76(sp)");
    asm volatile("lw x20, 80(sp)");
    asm volatile("lw x21, 84(sp)");
    asm volatile("lw x22, 88(sp)");
    asm volatile("lw x23, 92(sp)");
    asm volatile("lw x24, 96(sp)");
    asm volatile("lw x25, 100(sp)");
    asm volatile("lw x26, 104(sp)");
    asm volatile("lw x27, 108(sp)");
    asm volatile("lw x28, 112(sp)");
    asm volatile("lw x29, 116(sp)");
    asm volatile("lw x30, 120(sp)");
    asm volatile("lw x31, 124(sp)");
    asm volatile("csrw t0, mstatus");
    asm volatile("lw t0, 128(sp)"); // FIXME is this the PC register? What happens now?

}
    

