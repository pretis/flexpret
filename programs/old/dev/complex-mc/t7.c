#include "macros.h"
#include "pret.h"

#define THREAD 7
#define QUEUE_SIZE 5
#define NULL 0

// EDF Scheduler.

// Structure for jobs in list.
// Lower value for priority is highest priority.
typedef struct job_s {
    int (*task)();
    unsigned int priority;
    struct job_s* next_job;
    char id;
} job;

// 'head' points to a ready priority queue of jobs (can be executed).
// 'avail' points to a list of available job structures.
// Elements of 'jobs' are in one of the lists.
job jobs[QUEUE_SIZE];
job* head;
job* avail;

// Construct 'avail' list (contains all jobs).
void ready_queue_init() {
    unsigned int i;

    // No active jobs.
    head = NULL;
    // Create linked list of inactive jobs.
    avail = &jobs;
    for(i = 0; i < QUEUE_SIZE-1; i++) {
        jobs[i].next_job = &jobs[i+1];
    }
    jobs[QUEUE_SIZE-1].next_job = NULL;
}

// Add job to ready queue (remove one from avail list).
void ready_queue_add(int (*task)(), unsigned int priority, char id) {
    
    // Create job.
    job* new_job = avail;
    avail = new_job->next_job;
    if(avail == NULL) {
        // Out of space.
    }
    new_job->task = task;
    new_job->priority = priority;
    new_job->id = id;

    // Find location to add in ready queue.
    job* prev = NULL;
    job* current = head;
    while(current != NULL && current->priority <= priority) {
        prev = current;
        current = current->next_job;
    }
    // Insert in ready queue.
    if(prev == NULL) {
        // At front.
        new_job->next_job = head;
        head = new_job;
    } else {
        // In middle or end.
        new_job->next_job = current;
        prev->next_job = new_job;
    }

}

inline job* ready_queue_peek() {
    return head;
}

void ready_queue_pop() {
    deactive_exception();
    job* pop = head;
    head = pop->next_job;
    pop->next_job = avail;
    avail = pop;
    // Print end time.
    unsigned int message = tohost_id(THREAD, pop->id+10); mtpcr(30, message);
    message = tohost_time(get_time_low()); mtpcr(30, message);
    active_exception();

}

int taskD5_main(void);
int taskD6_main(void);
int taskD7_main(void);
int taskD8_main(void);
int taskD9_main(void);

void handler()
{
    // Get current job.
    job *current = head;

    // Add new jobs to queue.
    static unsigned int tick = 0;
    if(tick == 0) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
            ready_queue_add(taskD9_main, exception_ns_l + 50000000, 9);
            ready_queue_add(taskD6_main, exception_ns_l + 100000000, 6);
            ready_queue_add(taskD8_main, exception_ns_l + 100000000, 8);
            ready_queue_add(taskD7_main, exception_ns_l + 200000000, 7);
    } else if(tick == 1) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
    } else if(tick == 2) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
            ready_queue_add(taskD9_main, exception_ns_l + 50000000, 9);
    } else if(tick == 3) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
    } else if(tick == 4) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
            ready_queue_add(taskD9_main, exception_ns_l + 50000000, 9);
            ready_queue_add(taskD6_main, exception_ns_l + 100000000, 6);
            ready_queue_add(taskD8_main, exception_ns_l + 100000000, 8);
    } else if(tick == 5) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
    } else if (tick == 6) {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
            ready_queue_add(taskD9_main, exception_ns_l + 50000000, 9);
    } else {
            ready_queue_add(taskD5_main, exception_ns_l + 25000000, 5);
            tick = -1;
    }
    tick++;

    // Set and enable next exception.
    // This invocation of the handler is responsible for executing all
    // added jobs if it preempted any jobs.
    add_ms(exception_ns_h, exception_ns_l, 25);
    active_exception();

    // If a job was preempted, must run all higher priority jobs
    // before returning.
    job *run = ready_queue_peek();
    while(run != NULL && run != current) {
        unsigned int message = tohost_id(THREAD, run->id); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        run->task();
        ready_queue_pop();
        run = ready_queue_peek();
    }

    // Return to main loop or preempted job.    
}


int main(void) {

    // Initialize ready queue.
    ready_queue_init();

    // Initialize handler.
    exception_on_expire(0, 100000, handler);

    // Thread will sleep until exception occurs, where jobs may be added.
    // Run all jobs then sleep until next exception.
    while(1) {
        job *run = ready_queue_peek();
        while(run != NULL) {
        unsigned int message = tohost_id(THREAD, run->id); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
            run->task();
            ready_queue_pop();
            run = ready_queue_peek();
        }
        thread_sleep();
    }
    return 0;
}
