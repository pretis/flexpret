// Michael Zimmer (mzimmer@eecs.berkeley.edu)

module Top(
    input clk,
    input reset_n,
    input[7:0] switch,
    output[7:0] led
);
    
wire clk_fb;
wire clk_core;
wire[11:0] io_imem_addr;
wire io_imem_write;
wire[31:0] io_imem_data_in;
wire[11:0] io_dmem_addr;
wire io_dmem_enable;
wire io_dmem_byte_write_3;
wire io_dmem_byte_write_2;
wire io_dmem_byte_write_1;
wire io_dmem_byte_write_0;
wire[31:0] io_dmem_data_in;
wire[31:0] io_bus_data_out;
wire[31:0] io_host_to_host;
wire[7:0] io_gpio_in_3;
wire[7:0] io_gpio_in_2;
wire[7:0] io_gpio_in_1;
wire[7:0] io_gpio_in_0;
wire[7:0] io_gpio_out_3;
wire[7:0] io_gpio_out_2;
wire[7:0] io_gpio_out_1;
wire[7:0] io_gpio_out_0;
wire reset;

assign reset = !reset_n;

Core flexpret (
 //   .clk(clk_fb),
    .clk(clk_core), 
    .reset(reset), 
    .io_imem_addr(io_imem_addr),
    .io_imem_write(io_imem_write),
    .io_imem_data_in(io_imem_data_in),
    //output io_imem_ready,
    .io_dmem_addr(io_dmem_addr),
    .io_dmem_enable(io_dmem_enable),
    //output[31:0] io_dmem_data_out,
    .io_dmem_byte_write_3(io_dmem_byte_write_3),
    .io_dmem_byte_write_2(io_dmem_byte_write_2),
    .io_dmem_byte_write_1(io_dmem_byte_write_1),
    .io_dmem_byte_write_0(io_dmem_byte_write_0),
    .io_dmem_data_in(io_dmem_data_in),
    //output[15:0] io_bus_addr,
    //output io_bus_enable,
    .io_bus_data_out(io_bus_data_out),
    //output io_bus_write,
    //output[31:0] io_bus_data_in,
    .io_host_to_host(io_host_to_host),
    .io_gpio_in_3(io_gpio_in_3),
    .io_gpio_in_2(io_gpio_in_2),
    .io_gpio_in_1(io_gpio_in_1),
    .io_gpio_in_0(io_gpio_in_0),
    .io_gpio_out_3(io_gpio_out_3),
    .io_gpio_out_2(io_gpio_out_2),
    .io_gpio_out_1(io_gpio_out_1),
    .io_gpio_out_0(io_gpio_out_0)
    );


assign io_dmem_addr = 12'b0;
assign io_dmem_enable = 1'b0;
assign io_dmem_byte_write_3 = 1'b0;
assign io_dmem_byte_write_2 = 1'b0;
assign io_dmem_byte_write_1 = 1'b0;
assign io_dmem_byte_write_0 = 1'b0;
assign io_dmem_data_in = 32'b0;
assign io_imem_addr = 12'b0;
assign io_imem_write = 1'b0;
assign io_imem_data_in = 32'b0;
assign io_bus_data_out = 32'b0;

assign io_gpio_in_3 = {6'b0, switch[7:6]};
assign io_gpio_in_2 = {6'b0, switch[5:4]};
assign io_gpio_in_1 = {6'b0, switch[3:2]};
assign io_gpio_in_0 = {6'b0, switch[1:0]};
//assign led = io_host_to_host[7:0];
assign led = {io_gpio_out_3[1:0], io_gpio_out_2[1:0], io_gpio_out_1[1:0], io_gpio_out_0[1:0]};

	assign clk_core = clk_fb; // otherwise use clkfx or clkdv
   DCM_SP #(
      .CLKDV_DIVIDE(2.0),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(12),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(10),                   // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(10.0),                  // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("NONE"),          // Output phase shift (NONE, FIXED, VARIABLE)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_inst (
      .CLK0(clk_fb),         // 1-bit output: 0 degree clock output
      .CLK180(),     // 1-bit output: 180 degree clock output
      .CLK270(),     // 1-bit output: 270 degree clock output
      .CLK2X(),       // 1-bit output: 2X clock frequency clock output
      .CLK2X180(), // 1-bit output: 2X clock frequency, 180 degree clock output
      .CLK90(),       // 1-bit output: 90 degree clock output
      .CLKDV(),       // 1-bit output: Divided clock output
      //.CLKFX(clk_core),       // 1-bit output: Digital Frequency Synthesizer output (DFS)
		.CLKFX(),
      .CLKFX180(), // 1-bit output: 180 degree CLKFX output
      .LOCKED(),     // 1-bit output: DCM_SP Lock Output
      .PSDONE(),     // 1-bit output: Phase shift done output
      .STATUS(),     // 8-bit output: DCM_SP status output
      .CLKFB(clk_fb),       // 1-bit input: Clock feedback input
      .CLKIN(clk),       // 1-bit input: Clock input
      .DSSEN(1'b0),       // 1-bit input: Unsupported, specify to GND.
      .PSCLK(1'b0),       // 1-bit input: Phase shift clock input
      .PSEN(1'b0),         // 1-bit input: Phase shift enable
      .PSINCDEC(1'b0), // 1-bit input: Phase shift increment/decrement input
      .RST(1'b0)            // 1-bit input: Active high reset input
   );

endmodule
