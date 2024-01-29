`timescale 1ns / 1ps

module Top(
  input CLK_100MHZ_FPGA,
  output [7:0] LEDS,
  //input [7:0] SWS,
  //input [3:0] BTNS,
  output UART_TX,
  input UART_RX
  //input [3:0] JBI,
  //output [3:0] JBO
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
      .clk_in1(CLK_100MHZ_FPGA)
  );
 
  FpgaTop flexpret(
    .clock(sysclk),
    .io_gpio_out_0(LEDS[1:0]),
    .io_gpio_out_1(LEDS[3:2]),
    .io_gpio_out_2(LEDS[5:4]),
    .io_gpio_out_3(LEDS[7:6]),
    .io_uart_rx(UART_RX),
    .io_uart_tx(UART_TX)
    //.io_gpio_in_0(SWS[0]),
    //.io_gpio_out_1(JBO),
    //.io_gpio_in_1(JBI),
    //.io_gpio_in_2(BTNS)
  );

  assign LEDS[7:6] = 2'b11;
  
endmodule
