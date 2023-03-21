#ifndef FLEXPRET_SCHED_H
#define FLEXPRET_SCHED_H

typedef void (*task_func)(void);

void scheduler_run();
void scheduler_add_task(task_func func, uint32_t priority, uint32_t period);
void scheduler_init();


#endif
