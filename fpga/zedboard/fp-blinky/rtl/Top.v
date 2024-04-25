`timescale 1ns / 1ps

module Top(
  input INPUT_CLOCK,
  output [7:0] LEDS,
  output UART_TX,
  input UART_RX
);

  // Outputs
  wire sysclk;

  clk_wiz_0 inst(
      // Clock out ports  
      .clk_out1(sysclk),
      // Status and control signals               
      .reset(reset), 
      .locked(locked),
     // Clock in ports
      .clk_in1(INPUT_CLOCK)
  );
 
  FpgaTop flexpret(
    .clock(sysclk),
    .io_gpio_out_0(LEDS[1:0]),
    .io_gpio_out_1(LEDS[3:2]),
    .io_gpio_out_2(LEDS[5:4]),
    .io_gpio_out_3(LEDS[7:6]),
    .io_uart_rx(UART_RX),
    .io_uart_tx(UART_TX)
  );

endmodule
