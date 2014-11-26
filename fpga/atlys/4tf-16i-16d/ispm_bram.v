
module ISpm(input clk,
    input [11:0] io_core_r_addr,
    input  io_core_r_enable,
    output[31:0] io_core_r_data_out,
    input [11:0] io_core_rw_addr,
    input  io_core_rw_enable,
    output[31:0] io_core_rw_data_out,
    input  io_core_rw_write,
    input [31:0] io_core_rw_data_in,
    input [11:0] io_bus_addr,
    input  io_bus_write,
    input [31:0] io_bus_data_in,
    output io_bus_ready
);


genvar i;

generate
for(i = 0; i < 8; i = i+1)
begin: BRAMS

reg [3:0] ispm [4095:0];
reg [3:0] r_data_out, rw_data_out;

always @(posedge clk) begin
    if(io_core_r_enable) begin
	    r_data_out <= ispm[io_core_r_addr];
    end
end
assign io_core_r_data_out[4*i+3:4*i] = r_data_out;

always @(posedge clk) begin
    if(io_core_rw_enable) begin
        if(io_core_rw_write) begin
		    ispm[io_core_rw_addr] <= io_core_rw_data_in[4*i+3:4*i];
        end
        rw_data_out <= ispm[io_core_rw_addr];
    end
end
//assign io_core_rw_data_out[4*i+3:4*i] = rw_data_out;

end
endgenerate

//assign io_core_rw_data_out = 32'b0;
assign io_bus_ready = 1'b0;

endmodule
