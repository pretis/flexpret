`timescale 1ns / 1ps

module Top(
  input INPUT_CLOCK,
  input RESET,
  output [6:0] LEDS,
  input [1:0] SWS,
  output UART_TX,
  input UART_RX,
  input JA3,
  input JA4,
  output JA7
);

  // Outputs
  wire sysclk;

  clk_wiz_0 inst(
      // Clock out ports  
      .clk_out1(sysclk),
      // Status and control signals               
      .reset(RESET), 
      .locked(locked),
     // Clock in ports
      .clk_in1(INPUT_CLOCK)
  );
 
  FpgaTop flexpret(
    .clock(sysclk),
    .reset(RESET),
    .io_gpio_out_0(LEDS[1:0]),
    .io_gpio_out_1(LEDS[3:2]),
    .io_gpio_out_2(LEDS[5:4]),
    .io_gpio_out_3({JA7, LEDS[6]}),
    .io_uart_rx(UART_RX),
    .io_uart_tx(UART_TX),
    .io_gpio_in_0(SWS[0]),
    .io_gpio_in_1(SWS[1]),
    .io_int_exts_1(JA3),
    .io_int_exts_2(JA4)
  );

endmodule
