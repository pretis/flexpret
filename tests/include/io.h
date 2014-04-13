// Assembly code segments for IO
// Michael Zimmer (mzimmer@eecs.berkeley.edu)
// David Broman (broman@eecs.berkeley.edu)

// TODO jalr to ret?
#define DEFINITIONS \
        .equ    LED_GPIO,  0xFFFFFF00; \
        .equ    LED_NESW,  0xFFFFFF04; \
        .equ    UART_CIN,  0xFFFF0000; \
        .equ    UART_DIN,  0xFFFF0004; \
        .equ    UART_COUT, 0xFFFF0008; \
        .equ    UART_DOUT, 0xFFFF000C; \
        .equ    UART_TIMEOUT, 4000000; \
        .equ    TEXT_ADDR, 0x02000210; \
        .equ    DATA_ADDR, 0x04000000; \
        \
        .equ    PTP_RX_VALID, 0xFFFFFF10; \
        .equ    PTP_RX_MSG_ID, 0xFFFFFF14; \
        .equ    PTP_RX_SRC_PORT_SEQ_ID, 0xFFFFFF18; \
        .equ    PTP_RX_TS_SEC, 0xFFFFFF1c; \
        .equ    PTP_RX_TS_NS, 0xFFFFFF20; \
        \
        .equ    PTP_TX_VALID, 0xFFFFFF30; \
        .equ    PTP_TX_MSG_ID, 0xFFFFFF34; \
        .equ    PTP_TX_SRC_PORT_SEQ_ID, 0xFFFFFF38; \
        .equ    PTP_TX_TS_SEC, 0xFFFFFF3c; \
        .equ    PTP_TX_TS_NS, 0xFFFFFF40; \
        \
        .equ    ETH_TX_BUSY, 0xFFFFFF50; \
        .equ    ETH_TX_PKT_LEN, 0xFFFFFF54; \
        .equ    ETH_TX_PKT_DATA, 0xFFFFFF60; \
        \
        .equ    ETH_RX_SRC_RDY, 0xFFFFFA00; \
        .equ    ETH_RX_BUSY, 0xFFFFFA04; \
        .equ    ETH_RX_COMMAND, 0xFFFFFA08; \
        .equ    ETH_RX_PKT_LEN, 0xFFFFFA0C; \
        .equ    ETH_RX_PKT_DATA, 0xFFFFFA10;

#define START \
        .text; \
        .global _start; \
_start:
        
// Function: Turn of the LEDs.
// Input: None
// Output: x2, x3 affected        
#define TURN_OFF_LEDS \
turn_off_leds: \
        li     x2, 0; \
        la     x3, LED_NESW; \
        sb    x2, 0(x3); \
        jalr.r x0, x1, 0;

        //la     x3, LED_GPIO
        //sb     x2, 0(x3)

// Function: Setup UART variables
// Input:  Nothing
// Output: 
//         x8  = UART_CIN
//         x9  = UART_DIN
//         x10 = UART_COUT
//         x11 = UART_DOUT
#define UART_SETUP \
uart_setup: \
        li     x8, UART_CIN; \
        li     x9, UART_DIN; \
        li     x10, UART_COUT; \
        li     x11, UART_DOUT; \
        jalr.r x0, x1, 0;

// Function: Sending one byte to UART
// Input:  x4 = byte to send
//         x8-x11 = UART addresses
// Output:
//         x5 = 0 if timed out       
//         x6 = affected        
#define UART_SEND_BYTE \
uart_send_byte: \
        li x5, UART_TIMEOUT; \
uart_send_byte_loop: \
        lbu x6, 0(x10); \
        beq x0, x6, uart_dout; \
        addi x5, x5, -1; \
        bne x0, x5, uart_send_byte_loop; \
        jalr.r x0, x1, 0; \
uart_dout: \
        sb x4, 0(x11); \
        jalr.r x0, x1, 0; 
        
// Function: Receive one byte from UART
// Input:  x8-x11 = UART addresses
// Output: x4 = received byte
//         x5 = 0 if timed out       
//         x6 = affected
#define UART_RECEIVE_BYTE \
uart_receive_byte: \
        li x5, UART_TIMEOUT; \
uart_receive_byte_loop: \
        lbu x4, 0(x8); \
        li x6, 1; \
        beq x4, x6, uart_din; \
        addi x5, x5, -1; \
        bne x0, x5, uart_receive_byte_loop; \
        jalr.r x0, x1, 0; \
uart_din: \
        lbu x4, 0(x9); \
        jalr.r x0, x1, 0; 

// Function: Send one word to UART (little endian)
// Input:  x8-x11 = UART addresses
//         x12 = word to send
// Output: x5 = 0 if timeout 
//         x4, x6, x7, x13 = affected
#define UART_SEND_WORD \
uart_send_word: \
        move x13, ra; \
        li x7, 0; \
uart_send_word_loop: \
        srl x4, x12, x7; \
        jal uart_send_byte; \
        beq x0, x5, uart_send_word_ret; \
uart_wout: \
        addi x7, x7, 8; \
        li x5, 32; \
        bne x5, x7, uart_send_word_loop; \
uart_send_word_ret: \
        jalr.r x0, x13, 0;


// Function: Receive one word from UART (little endian)
// Input:  x8-x11 = UART addresses
// Output: x12 = received word
//         x5 = 0 if timeout
//         x4, x6, x7, x13 = affected
#define UART_RECEIVE_WORD \
uart_receive_word: \
        move x13, ra; \
        li x12, 0; \
        li x7, 0; \
uart_receive_word_loop: \
        jal uart_receive_byte; \
        beq x0, x5, uart_receive_word_ret; \
uart_win: \
        sll x4, x4, x7; \
        or x12, x12, x4; \
        addi x7, x7, 8; \
        li x5, 32; \
        bne x5, x7, uart_receive_word_loop; \
uart_receive_word_ret: \
        jalr.r x0, x13, 0;


// Function: Store array of data to address location.
// Input:  x2 = Destination address
// Input:  x8-x11 = UART addresses
// Output: x3-x7, x12-14 = affected
// Notes: Receive data length as first word, then data.
// TODO: will timeout if data section not multiple of 4.
#define UART_RECEIVE_DATA \
uart_receive_data: \
        move x14, ra; \
        jal uart_receive_word; \
        beq x0, x5, restart_loader; \
        move x3, x12; \
        beq x0, x3, uart_receive_data_ret; \
uart_receive_data_loop: \
        jal uart_receive_word; \
        sw x12, 0(x2); \
        nop; \
        nop; \
        nop; \
        nop; \
        addi x2, x2, 4; \
        addi x3, x3, -4; \
        blt x0, x3, uart_receive_data_loop; \
uart_receive_data_ret: \
        jalr.r x0, x14, 0;
    
    

