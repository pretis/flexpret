/**
 * @brief These functions will be used by the multi-threaded version of the
 *        interrupt tests as well.
 * 
 */

void reset_flags(void);
void *test_long_interrupt(void *args);
void *test_two_interrupts(void *args);
void *test_disabled_interrupts(void *args);
void *test_low_timeout(void *args);
void *test_interrupt_expire_with_expire(void *args);
void *test_exception_expire_with_expire(void *args);
void *test_fp_delay_until(void *args);
void *test_fp_wait_until(void *args);
void *test_external_interrupt(void *args);
void *test_external_interrupt_disabled(void *args);
void *test_du_not_stopped_by_int(void *args);
void *test_wu_stopped_by_int(void *args);
