#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>
#include <flexpret_csrs.h>

#define NOC_BASE 0x40000020UL
#define NOC_CSR (*( (volatile uint32_t *) (NOC_BASE + 0x0UL)))
#define NOC_DATA (*( (volatile uint32_t *) (NOC_BASE + 0x4UL)))
#define NOC_SOURCE (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))
#define NOC_DEST (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))

// Macros for parsing the CSR register value
#define NOC_TX_READY(val) (val & 0x01)
#define NOC_DATA_AVAILABLE(val) (val & 0x02)

// Return values
#define SUCCESS 1
#define FAILIURE 0

/** Send a word over the NoC.
 * Depending on the value of the timeout, the function will exhibit a different behavior:
 *  * Blocking send is performed if timeout value is UNIT32_MAX,
 *  * Non blocking send is performed if the timeout value is 0,
 *  * And send within the given timeout, otherwise.
 *
 * Args:
 *  * addr: id of the core to send to
 *  * data: The data value to send
 *  * timeout: the timeout in ns
 * Returns:
 *  * int: SUCCESS, if sending is successful, FAILIURE otherwise
 **/
static int noc_send(uint32_t addr, uint32_t data, uint32_t timeout) {
    if (timeout == UINT32_MAX) {
        while (!NOC_TX_READY(NOC_CSR));
        NOC_DEST = addr;
        NOC_DATA = data;
        return SUCCESS;
    }
    if (timeout == 0) {
        if (NOC_TX_READY(NOC_CSR)) {
            NOC_DEST = addr;
            NOC_DATA = data;
            return SUCCESS;
        } else {
            return FAILIURE;
        }
    }
    uint32_t time = rdtime() + timeout;
    while (rdtime() < time) {
        if (NOC_TX_READY(NOC_CSR)) {
            NOC_DEST = addr;
            NOC_DATA = data;
            return SUCCESS;
        }
    }
    return FAILIURE;
}


// Send array, blocking
static void noc_send_arr(uint32_t addr, uint32_t *data, int length) {
    for (int i = 0; i < length; i++)
        noc_send(addr, data[i], UINT32_MAX);
    
}

/** Receive a word over the NoC.
 * Depending on the value of the timeout, the function will exhibit a different
 * behavior:
 *  * Blocking receive is performed if timeout value is UNIT32_MAX,
 *  * Non blocking receive is performed if the timeout value is 0,
 *  * And receive within the given timeout, otherwise.
 *
 * Args:
 *  * timeout: the timeout in ns
 *  * data: pointer to where the data will be written, if any
 * Returns:
 *  * int: SUCCESS, if sending is successful, FAILIURE otherwise
 **/
static uint32_t noc_receive(uint32_t timeout, uint32_t* data) {
    if (timeout == UINT32_MAX) {
        while (!NOC_DATA_AVAILABLE(NOC_CSR));
        *data = NOC_DATA;
        return SUCCESS;
    }
    if (timeout == 0) {
        if (NOC_DATA_AVAILABLE(NOC_CSR))
            *data = NOC_DATA;
            return SUCCESS;
        return FAILIURE;
    }
    uint32_t time = rdtime() + timeout;
    while (rdtime() < time) {
        if (NOC_DATA_AVAILABLE(NOC_CSR))
            *data = NOC_DATA;
            return SUCCESS;
    }
    return FAILIURE;
}

#endif
