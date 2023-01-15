/**
 * A threaded version of matrix multiplication, where the matrices are defined
 * in the static memory: a * b = c.
 *
 * The number of threads executing the the parallel matric multiply is set in
 * `nb_threads`.
 *
 * Make sure to pass the hardware thread number to the `riscv-compile.sh`. It
 * should be at least `nb_threads + 1`, where the extra one being for the master
 * thread. Ex: `riscv-compile.sh 5 mm matrix_multiply_stc_thr.c`.
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

#define NRA 20 // number of rows in matrix a
#define NCA 20 // number of columns in matrix a
#define NCB 20 // number of columns in matrix b

#define nb_threads (NUM_THREADS -1)

// Matrixes a, b, and c, to be statically allocated.
int32_t a[NRA][NCA], b[NCA][NCB], c[NRA][NCB];

// Matrix Multiplication routine, that will be executed by each thread
void* matrix_multiply();

////////////////////////////////////////////////////
int main(int argc, char *argv[]) {
    int i, j, k;
    uint32_t start_time, stop_time;
    
    // Initialize a and b matrices
    for (i = 0; i < NRA; i++) 
        for (j = 0; j < NCA; j++)
            a[i][j] = (int32_t) 1;
    for (i = 0; i < NCA; i++)
        for (j = 0; j < NCB; j++)
            b[i][j] = (int32_t) j;

    // Thread ids
    thread_t tid[nb_threads];
    int errno[nb_threads];

    start_time = rdtime();
    
    // Create the threads
    for (i = 0; i < nb_threads; i++) {
        errno[i] = thread_create(&tid[i], matrix_multiply, NULL);
        if (errno[i] != 0)
            _fp_print(666);
    }

    // Join once the job is done
    void *exit_code[nb_threads];
    for (i = 0; i < nb_threads; i++) {
        thread_join(tid[i], &exit_code[i]);
    }

    stop_time = rdtime();
    _fp_print(stop_time - start_time);

    return (0);
}

// Matrix multiply implementation
// The work will be shared among the nb_threads. 
// The index range of the outer loop is therefore derived from the thread id.  
void* matrix_multiply () {
    uint32_t tid = read_hartid();

    int i_start, i_end, i, j, k;
    i_start = (tid - 1) * NRA / nb_threads;
    i_end = tid * NRA / nb_threads;
    if (tid == nb_threads)
        i_end = NRA;

    // _fp_print(i_start);
    // _fp_print(i_end);

    for (i = i_start; i < i_end; i++) {
        for (j = 0; j < NCB; j++) {
            for (k = 0, c[i][j] = 0; k < NCA; k++) {
                c[i][j] += a[i][k] * b[k][j];
            }
            // if (i == 0) _fp_print(c[i][j]);
        }
    }
}