/**
 * A threaded version of merge sort, where the array is defined in the static
 * memory: 
 *
 * This example follows the scatter-gather pattern. The `main` function 
 * divides the indexes among the threads. The individual results are then
 * gathered. The number of working threads is set in `nb_threads`.
 *
 * Make sure to pass the hardware thread number to the `riscv-compile.sh`. It
 * should be at least `nb_threads + 1`, where the extra one being for the master
 * thread. Ex: `riscv-compile.sh 5 ms merge_sort_stc_thr.c`.
 * In addition, make sure that the FlexPRET was built wih the right number of
 * hardware threads. This can be set in the `config.mk` file, before building
 * the emulator.
 *
 * Currently, the program prints the time spent in the calculation, including
 * threads creation and joining. This latter needs to be assessed separateley.
 **/

#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_csrs.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

// Number of elements
#define SIZE 100

// Number of working threads
#define nb_threads (NUM_THREADS - 1)

// Array of size SIZE
int32_t array[SIZE];

// Deriving the number of elements
int size_per_thread = SIZE / nb_threads;
int size_remaining = SIZE % nb_threads;

// Merge Sort routine, that will be executed by each thread
void* merge_sort_thread();

// Routines for sorting and merging
void merge_sort(int left, int right);
void merge(int left, int middle, int right);
void gather(int number, int level);

////////////////////////////////////////////////////
int main(int argc, char *argv[]) {
    int i;
    uint32_t start_time, stop_time;
    
    // Initialize `array` with random numbers
    for (i = 0; i < SIZE; i++) {
        array[i] = rand() % 1000;
        _fp_print(array[i]);
    }

    // Thread ids
    thread_t tid[nb_threads];
    int errno[nb_threads];

    start_time = rdtime();

    // Create the threads and scatter the work based on the indexes
    for (i = 0; i < nb_threads; i++) {
        errno[i] = thread_create(&tid[i], merge_sort_thread, NULL);
        if (errno[i] != 0)
            _fp_print(666);
    }

    // Join once the job is done
    void *exit_code[nb_threads];
    for (i = 0; i < nb_threads; i++) {
        thread_join(tid[i], &exit_code[i]);
    }

    // Now, merge (gather) the results from the threads
    gather(nb_threads, 1);

    stop_time = rdtime();
    _fp_print(stop_time - start_time);

    for (i = 0; i < SIZE; i++) {
        _fp_print(array[i]);
    }

    return (0);
}

// Routine executed by each thread.
// It starts by deriving the sub-array to merge sort. 
void* merge_sort_thread() {
    // Compute the left and right indexes from the thread id.
    // Thread 0, which runs `main()` function is excluded.
    uint32_t tid = read_hartid() - 1;
    int left = tid * (size_per_thread);
    int right = (tid + 1) * (size_per_thread)-1;
    if (tid == nb_threads - 1) {
        right += size_remaining;
    }
    int middle = left + (right - left) / 2;

    if (left < right) {
        merge_sort(left, middle);
        merge_sort(middle + 1, right);
        merge(left, middle, right);
    }
}

// Recursive call on the two sub-arrays to sort and merge
void merge_sort(int left, int right) {
    if (left < right) {
        int middle = left + (right - left) / 2;
        merge_sort(left, middle);
        merge_sort(middle + 1, right);
        merge(left, middle, right);
    }
}

// Merge of two ordered sub-arrays
void merge(int left, int middle, int right) {
    int i, j, k;
    int left_size = middle - left + 1;
    int right_size = right - middle;
    int left_array[left_size];
    int right_array[right_size];
    // int *left_array = (int *)malloc(left_size * sizeof(int));
    // int *right_array = (int *)malloc(right_size * sizeof(int));

    // Save the elements in the left in a separate array
    for (int i = 0; i < left_size; i++) {
        left_array[i] = array[left + i];
    }

    // Save the elements in the right in a separate array
    for (int j = 0; j < right_size; j++) {
        right_array[j] = array[middle + 1 + j];
    }

    i = 0;
    j = 0;
    k = left;
    // Ordered copy of elements from left to right
    while (i < left_size && j < right_size) {
        if (left_array[i] <= right_array[j]) {
            array[k++] = left_array[i++];
        } else {
            array[k++] = right_array[j++];
        }
    }

    // Copy the remaining elements
    while (i < left_size) {
        array[k++] = left_array[i++];
    }
    while (j < right_size) {
        array[k++] = right_array[j++];
    }

    // free(left_array);
    // free(right_array);

}

// Gathering the nb_threads sub-arrays into array  
void gather(int nbr, int level) {
    for (int i = 0; i < nbr; i = i + 2) {
        int left = i * (size_per_thread * level);
        int right = ((i + 2) * size_per_thread * level) - 1;
        int middle = left + (size_per_thread * level) - 1;
        if (right >= SIZE) {
            right = SIZE - 1;
        }
        merge(left, middle, right);
    }
    if (nbr / 2 >= 1) {
        gather(nbr / 2, level * 2);
    }
}