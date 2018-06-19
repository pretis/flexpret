`timescale 1ns/1ns

`define DEFAULT_CYCLE_TIMEOUT 10000
`define INPUT_DELAY 0
`define OUTPUT_DELAY 0
`define CLOCK_PERIOD 10
`define THREADS 4

module core_testbench;

  // Process command line options.
  reg [31:0] max_cycles;
  reg [511:0] ispmfile;
  reg [511:0] dspmfile;
  reg [511:0] vcdplusfile;
  reg [31:0] vcdpluson;
  reg [15:0] k;

  initial begin

    // Read command line arguments.

    // Maximum number of cycles.
    if(!$value$plusargs("maxcycles=%d", max_cycles))
      max_cycles = `DEFAULT_CYCLE_TIMEOUT;

    // Where to store VPD trace file.
    if($value$plusargs("vcd=%s", vcdplusfile))
      $vcdplusfile(vcdplusfile);

    // When to turn on VCD tracing.
    if(!$value$plusargs("vcdstart=%d", vcdpluson))
      vcdpluson = 0; 
    
    // Enable warnings about comparisons with X's or Z's.
    //$xzcheckon;

  end
  // Clock signal.
  reg clk;
  initial begin
    clk <= 0;
    forever #(`CLOCK_PERIOD/2.0) clk = ~clk;
  end

  // SPM
  reg [31:0] ispm_init [4095:0];
  reg [31:0] dspm_init [4095:0];

  // Reset signal.
  reg reset;
  initial begin
    reset <= 1'b1;
    @(posedge clk);
    @(negedge clk); 

    // Module
    //$readmemh(ispmfile, core.imem.ispm);
    //$readmemh(dspmfile, core.dmem.dspm);	 
    
    // Blackbox
	$readmemh(ispmfile, ispm_init);
	$readmemh(dspmfile, dspm_init);
    for(k = 0; k < 4096; k = k + 1) begin
        core.imem.BRAMS[0].ispm[k] = ispm_init[k][3:0];
        core.imem.BRAMS[1].ispm[k] = ispm_init[k][7:4];
        core.imem.BRAMS[2].ispm[k] = ispm_init[k][11:8];
        core.imem.BRAMS[3].ispm[k] = ispm_init[k][15:12];
        core.imem.BRAMS[4].ispm[k] = ispm_init[k][19:16];
        core.imem.BRAMS[5].ispm[k] = ispm_init[k][23:20];
        core.imem.BRAMS[6].ispm[k] = ispm_init[k][27:24];
        core.imem.BRAMS[7].ispm[k] = ispm_init[k][31:28];
        core.dmem.BRAMS[0].dspm[k] = dspm_init[k][3:0];
        core.dmem.BRAMS[1].dspm[k] = dspm_init[k][7:4];
        core.dmem.BRAMS[2].dspm[k] = dspm_init[k][11:8];
        core.dmem.BRAMS[3].dspm[k] = dspm_init[k][15:12];
        core.dmem.BRAMS[4].dspm[k] = dspm_init[k][19:16];
        core.dmem.BRAMS[5].dspm[k] = dspm_init[k][23:20];
        core.dmem.BRAMS[6].dspm[k] = dspm_init[k][27:24];
        core.dmem.BRAMS[7].dspm[k] = dspm_init[k][31:28];
    end

	reset = 1'b0;
  end

  // FlexPRET core.
  wire [31:0] tohost;
  Core core 
  (
    .clk (clk),
    .reset (reset),
    .io_imem_addr(12'b0),
    .io_imem_enable(1'b0),
    .io_imem_write(1'b0),
    .io_imem_data_in(32'b0),
    .io_dmem_addr(12'b0),
    .io_dmem_enable(1'b0),
    .io_dmem_byte_write_3(1'b0),
    .io_dmem_byte_write_2(1'b0),
    .io_dmem_byte_write_1(1'b0),
    .io_dmem_byte_write_0(1'b0),
    .io_dmem_data_in(32'b0),
    .io_bus_data_out(32'b0),
    .io_host_to_host (tohost),
    .io_gpio_in_3(1'b0),
    .io_gpio_in_2(1'b0),
    .io_gpio_in_1(1'b0),
    .io_gpio_in_0(1'b0),
    .io_int_exts_3(1'b0),
    .io_int_exts_2(1'b0),
    .io_int_exts_1(1'b0),
    .io_int_exts_0(1'b0)
  );


  // Cycle counter.
  reg [31:0] cycle_count = 32'd0;
  always @(posedge clk)
  begin
    // Increment cycle.
    cycle_count <= cycle_count + 1;
    // Turn on vcdplus?
    if(cycle_count == vcdpluson)
      $vcdpluson(0);
  end

  // Check for completion.
  always @(posedge clk)
  begin

    // Timeout.
    if(cycle_count > max_cycles)
    begin
      $display("*** FAILED *** (Max cycles timeout)");
      $finish;
    end

    // Test failed.
    if(!reset && tohost[31:30] == 2'b0 && tohost > 1)
    begin
      $display("*** FAILED *** (test #%d)", tohost);
      $finish;
    end

    // Test passed.
    if(!reset && tohost == 1)
    begin
      $display("*** PASSED ***: %d", tohost);
      $finish;
    end

  end


endmodule
