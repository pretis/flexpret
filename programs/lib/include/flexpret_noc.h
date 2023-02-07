#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>
#include <flexpret_csrs.h>
#include <flexpret_types.h>

#define NOC_BASE 0x40000020UL
#define NOC_CSR (*( (volatile uint32_t *) (NOC_BASE + 0x0UL)))
#define NOC_DATA (*( (volatile uint32_t *) (NOC_BASE + 0x4UL)))
#define NOC_SOURCE (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))
#define NOC_DEST (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))

// Macros for parsing the CSR register value
#define NOC_TX_READY(val) (val & 0x01)
#define NOC_DATA_AVAILABLE(val) (val & 0x02)

/**
 * @brief Send a word over the NoC. Depending on the value of the timeout, the 
 * function will exhibit a different behavior:
 *  * Blocking send is performed if timeout value is TIMEOUT_FOREVER,
 *  * Non blocking send is performed if the timeout value is TIMEOUT_NEVER,
 *  * And send within the given timeout, otherwise.
 *
 * @param addr: id of the core to send to
 * @param data: The data value to send
 * @param timeout: the timeout in ns
 *
 * @return fp_ret_t: FP_SUCCESS, if sending is successful, FP_FAILIURE otherwise
 **/
static fp_ret_t noc_send(uint32_t addr, uint32_t data, timeout_t timeout) {
    if (timeout == TIMEOUT_FOREVER) {
        while (!NOC_TX_READY(NOC_CSR));
        NOC_DEST = addr;
        NOC_DATA = data;
        return FP_SUCCESS;
    }
    if (timeout == TIMEOUT_NEVER) {
        if (NOC_TX_READY(NOC_CSR)) {
            NOC_DEST = addr;
            NOC_DATA = data;
            return FP_SUCCESS;
        } else {
            return FP_FAILURE;
        }
    }
    timeout_t time = rdtime() + timeout;
    while (rdtime() < time) {
        if (NOC_TX_READY(NOC_CSR)) {
            NOC_DEST = addr;
            NOC_DATA = data;
            return FP_SUCCESS;
        }
    }
    return FP_FAILURE;
}

/**
 * @brief Blocking send of an array of words over the NoC. 
 *
 * @param addr: id of the core to send to
 * @param data: pointer to start of the array 
 * @param length: length of the array 
 *
 * @return fp_ret_t: FP_SUCCESS, if sending is successful
 **/
static fp_ret_t noc_send_arr(uint32_t addr, uint32_t *data, int length) {
    for (int i = 0; i < length; i++)
        noc_send(addr, data[i], TIMEOUT_FOREVER);
    return FP_SUCCESS;
}

/**
 * Receive a word over the NoC. Depending on the value of the timeout, the function
 * will exhibit a different behavior:
 *  * Blocking receive is performed if timeout value is TIMEOUT_FOREVER,
 *  * Non blocking receive is performed if the timeout value is TIMEOUT_NEVER,
 *  * And receive within the given timeout, otherwise.
 *
 * @param data: pointer to where the data will be written, if any
 * @param timeout: the timeout in ns
 * FIXME: Should the data type be passed as well?
 *
 * @return fp_ret_t: FP_SUCCESS, if sending is successful, FP_FAILIURE otherwise
 **/
static fp_ret_t noc_receive(uint32_t* data, timeout_t timeout) {
    if (timeout == TIMEOUT_FOREVER) {
        while (!NOC_DATA_AVAILABLE(NOC_CSR));
        *data = NOC_DATA;
        return FP_SUCCESS;
    }
    if (timeout == TIMEOUT_NEVER) {
        if (NOC_DATA_AVAILABLE(NOC_CSR)) {
            *data = NOC_DATA;
            return FP_SUCCESS;
        }
        return FP_FAILURE;
    }
    uint32_t time = rdtime() + timeout;
    while (rdtime() < time) {
        if (NOC_DATA_AVAILABLE(NOC_CSR)) {
            *data = NOC_DATA;
            return FP_SUCCESS;
        }
    }
    return FP_FAILURE;
}

#endif
