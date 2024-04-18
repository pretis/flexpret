module Scheduler(
  input        clock,
  input        reset,
  input  [1:0] io_thread_modes_0,
  input  [1:0] io_thread_modes_1,
  input  [1:0] io_thread_modes_2,
  input  [1:0] io_thread_modes_3,
  output [1:0] io_thread,
  output       io_valid
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] currentThread; // @[scheduler.scala 60:32]
  wire [1:0] _currentThread_T_2 = currentThread + 2'h1; // @[scheduler.scala 61:78]
  wire [1:0] _GEN_1 = 2'h1 == currentThread ? io_thread_modes_1 : io_thread_modes_0; // @[scheduler.scala 53:{59,59}]
  wire [1:0] _GEN_2 = 2'h2 == currentThread ? io_thread_modes_2 : _GEN_1; // @[scheduler.scala 53:{59,59}]
  wire [1:0] _GEN_3 = 2'h3 == currentThread ? io_thread_modes_3 : _GEN_2; // @[scheduler.scala 53:{59,59}]
  assign io_thread = currentThread; // @[scheduler.scala 63:15]
  assign io_valid = _GEN_3 == 2'h0 | _GEN_3 == 2'h2; // @[scheduler.scala 53:73]
  always @(posedge clock) begin
    if (reset) begin // @[scheduler.scala 60:32]
      currentThread <= 2'h0; // @[scheduler.scala 60:32]
    end else if (currentThread < 2'h3) begin // @[scheduler.scala 61:25]
      currentThread <= _currentThread_T_2;
    end else begin
      currentThread <= 2'h0;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  currentThread = _RAND_0[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Control(
  input         clock,
  input         reset,
  output [2:0]  io_dec_imm_sel,
  output [1:0]  io_dec_op1_sel,
  output [1:0]  io_dec_op2_sel,
  output [3:0]  io_exe_alu_type,
  output [2:0]  io_exe_br_type,
  output [1:0]  io_exe_csr_type,
  output [1:0]  io_exe_rd_data_sel,
  output [3:0]  io_exe_mem_type,
  output [1:0]  io_mem_rd_data_sel,
  output [1:0]  io_next_pc_sel_0,
  output [1:0]  io_next_pc_sel_1,
  output [1:0]  io_next_pc_sel_2,
  output [1:0]  io_next_pc_sel_3,
  output [11:0] io_next_pc_sel_csr_addr,
  output [1:0]  io_next_tid,
  output        io_exe_load,
  output        io_exe_store,
  output        io_exe_csr_write,
  output        io_exe_exception,
  output [4:0]  io_exe_cause,
  output        io_exe_kill,
  output        io_exe_sleep_du,
  output        io_exe_sleep_wu,
  output        io_exe_ie,
  output        io_exe_ee,
  output        io_exe_mret,
  output        io_exe_cycle,
  output        io_exe_instret,
  output        io_mem_rd_write,
  input  [1:0]  io_if_tid,
  input  [31:0] io_dec_inst,
  input         io_exe_br_cond,
  input  [1:0]  io_exe_tid,
  input         io_exe_expire_du_0,
  input         io_exe_expire_du_1,
  input         io_exe_expire_du_2,
  input         io_exe_expire_du_3,
  input         io_exe_expire_ie_0,
  input         io_exe_expire_ie_1,
  input         io_exe_expire_ie_2,
  input         io_exe_expire_ie_3,
  input         io_exe_expire_ee_0,
  input         io_exe_expire_ee_1,
  input         io_exe_expire_ee_2,
  input         io_exe_expire_ee_3,
  input         io_timer_expire_du_wu_0,
  input         io_timer_expire_du_wu_1,
  input         io_timer_expire_du_wu_2,
  input         io_timer_expire_du_wu_3,
  input  [1:0]  io_csr_tmodes_0,
  input  [1:0]  io_csr_tmodes_1,
  input  [1:0]  io_csr_tmodes_2,
  input  [1:0]  io_csr_tmodes_3,
  input  [1:0]  io_mem_tid,
  input         io_if_exc_misaligned,
  input         io_if_exc_fault,
  input         io_exe_exc_load_misaligned,
  input         io_exe_exc_load_fault,
  input         io_exe_exc_store_misaligned,
  input         io_exe_exc_store_fault,
  input         io_exe_int_ext
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
`endif // RANDOMIZE_REG_INIT
  wire  scheduler_clock; // @[control.scala 276:25]
  wire  scheduler_reset; // @[control.scala 276:25]
  wire [1:0] scheduler_io_thread_modes_0; // @[control.scala 276:25]
  wire [1:0] scheduler_io_thread_modes_1; // @[control.scala 276:25]
  wire [1:0] scheduler_io_thread_modes_2; // @[control.scala 276:25]
  wire [1:0] scheduler_io_thread_modes_3; // @[control.scala 276:25]
  wire [1:0] scheduler_io_thread; // @[control.scala 276:25]
  wire  scheduler_io_valid; // @[control.scala 276:25]
  wire [31:0] _decoded_inst_bit_T = io_dec_inst & 32'h505f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_1 = _decoded_inst_bit_T == 32'h3; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_2 = io_dec_inst & 32'h207f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_3 = _decoded_inst_bit_T_2 == 32'h3; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_4 = io_dec_inst & 32'h607f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_5 = _decoded_inst_bit_T_4 == 32'hf; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_6 = io_dec_inst & 32'h5f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_7 = _decoded_inst_bit_T_6 == 32'h17; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_8 = io_dec_inst & 32'hfe00007f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_9 = _decoded_inst_bit_T_8 == 32'h33; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_10 = io_dec_inst & 32'hbe00707f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_11 = _decoded_inst_bit_T_10 == 32'h33; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_12 = io_dec_inst & 32'h707b; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_13 = _decoded_inst_bit_T_12 == 32'h63; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_14 = io_dec_inst & 32'h7f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_15 = _decoded_inst_bit_T_14 == 32'h6f; // @[decode.scala 41:121]
  wire  dec_scall = io_dec_inst == 32'h73; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_17 = io_dec_inst & 32'hfc00307f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_18 = _decoded_inst_bit_T_17 == 32'h1013; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_20 = _decoded_inst_bit_T_2 == 32'h2013; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_22 = _decoded_inst_bit_T_2 == 32'h2073; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_23 = io_dec_inst & 32'hbc00707f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_24 = _decoded_inst_bit_T_23 == 32'h5013; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_26 = _decoded_inst_bit_T_10 == 32'h5033; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_27 = io_dec_inst & 32'h705f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_28 = _decoded_inst_bit_T_27 == 32'h700b; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_29 = io_dec_inst & 32'h707f; // @[decode.scala 41:65]
  wire  dec_ie = _decoded_inst_bit_T_29 == 32'h705b; // @[decode.scala 41:121]
  wire  dec_mret = io_dec_inst == 32'h30200073; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_32 = io_dec_inst & 32'h603f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_33 = _decoded_inst_bit_T_32 == 32'h23; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_34 = io_dec_inst & 32'h306f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_35 = _decoded_inst_bit_T_34 == 32'h1063; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_36 = io_dec_inst & 32'h407f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_37 = _decoded_inst_bit_T_36 == 32'h4063; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_39 = _decoded_inst_bit_T_34 == 32'h3; // @[decode.scala 41:121]
  wire  dec_legal = _decoded_inst_bit_T_1 | _decoded_inst_bit_T_3 | _decoded_inst_bit_T_5 | _decoded_inst_bit_T_7 |
    _decoded_inst_bit_T_9 | _decoded_inst_bit_T_11 | _decoded_inst_bit_T_13 | _decoded_inst_bit_T_15 | dec_scall |
    _decoded_inst_bit_T_18 | _decoded_inst_bit_T_20 | _decoded_inst_bit_T_22 | _decoded_inst_bit_T_24 |
    _decoded_inst_bit_T_26 | _decoded_inst_bit_T_28 | dec_ie | dec_mret | _decoded_inst_bit_T_33 |
    _decoded_inst_bit_T_35 | _decoded_inst_bit_T_37 | _decoded_inst_bit_T_39; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T = io_dec_inst & 32'h8; // @[decode.scala 41:65]
  wire  _decoded_inst_T_1 = _decoded_inst_T == 32'h8; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_2 = io_dec_inst & 32'h44; // @[decode.scala 41:65]
  wire  _decoded_inst_T_3 = _decoded_inst_T_2 == 32'h40; // @[decode.scala 41:121]
  wire  _decoded_inst_T_5 = _decoded_inst_T_1 | _decoded_inst_T_3; // @[decode.scala 42:26]
  wire  _decoded_inst_T_7 = _decoded_inst_T_2 == 32'h4; // @[decode.scala 41:121]
  wire  _decoded_inst_T_9 = _decoded_inst_T_7 | _decoded_inst_T_1; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_10 = io_dec_inst & 32'h24; // @[decode.scala 41:65]
  wire  _decoded_inst_T_11 = _decoded_inst_T_10 == 32'h0; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_12 = io_dec_inst & 32'h1c; // @[decode.scala 41:65]
  wire  _decoded_inst_T_13 = _decoded_inst_T_12 == 32'h4; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_14 = io_dec_inst & 32'h14; // @[decode.scala 41:65]
  wire  _decoded_inst_T_15 = _decoded_inst_T_14 == 32'h10; // @[decode.scala 41:121]
  wire  _decoded_inst_T_18 = _decoded_inst_T_11 | _decoded_inst_T_13 | _decoded_inst_T_15; // @[decode.scala 42:26]
  wire [1:0] decoded_inst_hi = {_decoded_inst_T_18,_decoded_inst_T_9}; // @[Cat.scala 33:92]
  wire [31:0] _decoded_inst_T_19 = io_dec_inst & 32'h4c; // @[decode.scala 41:65]
  wire  _decoded_inst_T_20 = _decoded_inst_T_19 == 32'h0; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_21 = io_dec_inst & 32'h4014; // @[decode.scala 41:65]
  wire  _decoded_inst_T_22 = _decoded_inst_T_21 == 32'h10; // @[decode.scala 41:121]
  wire  _decoded_inst_T_25 = _decoded_inst_T_20 | _decoded_inst_T_13 | _decoded_inst_T_22; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_26 = io_dec_inst & 32'h64; // @[decode.scala 41:65]
  wire  _decoded_inst_T_27 = _decoded_inst_T_26 == 32'h24; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_28 = io_dec_inst & 32'h4058; // @[decode.scala 41:65]
  wire  _decoded_inst_T_29 = _decoded_inst_T_28 == 32'h4050; // @[decode.scala 41:121]
  wire  _decoded_inst_T_31 = _decoded_inst_T_27 | _decoded_inst_T_29; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_32 = io_dec_inst & 32'h74; // @[decode.scala 41:65]
  wire  _decoded_inst_T_33 = _decoded_inst_T_32 == 32'h30; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_34 = io_dec_inst & 32'h60; // @[decode.scala 41:65]
  wire  _decoded_inst_T_35 = _decoded_inst_T_34 == 32'h40; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_36 = io_dec_inst & 32'h4064; // @[decode.scala 41:65]
  wire  _decoded_inst_T_37 = _decoded_inst_T_36 == 32'h4020; // @[decode.scala 41:121]
  wire  _decoded_inst_T_40 = _decoded_inst_T_33 | _decoded_inst_T_35 | _decoded_inst_T_37; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_41 = io_dec_inst & 32'h4050; // @[decode.scala 41:65]
  wire  _decoded_inst_T_42 = _decoded_inst_T_41 == 32'h50; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_43 = io_dec_inst & 32'h6050; // @[decode.scala 41:65]
  wire  _decoded_inst_T_44 = _decoded_inst_T_43 == 32'h6000; // @[decode.scala 41:121]
  wire  _decoded_inst_T_47 = _decoded_inst_T_35 | _decoded_inst_T_42 | _decoded_inst_T_44; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_48 = io_dec_inst & 32'h304c; // @[decode.scala 41:65]
  wire  _decoded_inst_T_49 = _decoded_inst_T_48 == 32'h3000; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_50 = io_dec_inst & 32'h7014; // @[decode.scala 41:65]
  wire  _decoded_inst_T_51 = _decoded_inst_T_50 == 32'h4010; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_52 = io_dec_inst & 32'h40003034; // @[decode.scala 41:65]
  wire  _decoded_inst_T_53 = _decoded_inst_T_52 == 32'h40000030; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_54 = io_dec_inst & 32'h40006054; // @[decode.scala 41:65]
  wire  _decoded_inst_T_55 = _decoded_inst_T_54 == 32'h40004010; // @[decode.scala 41:121]
  wire  _decoded_inst_T_59 = _decoded_inst_T_49 | _decoded_inst_T_51 | _decoded_inst_T_53 | _decoded_inst_T_55; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_60 = io_dec_inst & 32'h7054; // @[decode.scala 41:65]
  wire  _decoded_inst_T_61 = _decoded_inst_T_60 == 32'h1010; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_62 = io_dec_inst & 32'h5054; // @[decode.scala 41:65]
  wire  _decoded_inst_T_63 = _decoded_inst_T_62 == 32'h4010; // @[decode.scala 41:121]
  wire  _decoded_inst_T_66 = _decoded_inst_T_61 | _decoded_inst_T_63 | _decoded_inst_T_55; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_67 = io_dec_inst & 32'h40004054; // @[decode.scala 41:65]
  wire  _decoded_inst_T_68 = _decoded_inst_T_67 == 32'h4010; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_69 = io_dec_inst & 32'h604c; // @[decode.scala 41:65]
  wire  _decoded_inst_T_70 = _decoded_inst_T_69 == 32'h6000; // @[decode.scala 41:121]
  wire  _decoded_inst_T_73 = _decoded_inst_T_68 | _decoded_inst_T_63 | _decoded_inst_T_70; // @[decode.scala 42:26]
  wire [31:0] _decoded_inst_T_74 = io_dec_inst & 32'h6054; // @[decode.scala 41:65]
  wire  _decoded_inst_T_75 = _decoded_inst_T_74 == 32'h2010; // @[decode.scala 41:121]
  wire [1:0] decoded_inst_lo = {_decoded_inst_T_66,_decoded_inst_T_59}; // @[Cat.scala 33:92]
  wire [1:0] decoded_inst_hi_1 = {_decoded_inst_T_75,_decoded_inst_T_73}; // @[Cat.scala 33:92]
  wire [31:0] _decoded_inst_T_77 = io_dec_inst & 32'h1000; // @[decode.scala 41:65]
  wire  _decoded_inst_T_78 = _decoded_inst_T_77 == 32'h1000; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_80 = io_dec_inst & 32'h6000; // @[decode.scala 41:65]
  wire  _decoded_inst_T_81 = _decoded_inst_T_80 == 32'h4000; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_83 = io_dec_inst & 32'h2000; // @[decode.scala 41:65]
  wire  _decoded_inst_T_84 = _decoded_inst_T_83 == 32'h2000; // @[decode.scala 41:121]
  wire [1:0] decoded_inst_hi_2 = {_decoded_inst_T_84,_decoded_inst_T_81}; // @[Cat.scala 33:92]
  wire [31:0] _decoded_inst_T_89 = io_dec_inst & 32'h10; // @[decode.scala 41:65]
  wire  _decoded_inst_T_90 = _decoded_inst_T_89 == 32'h0; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_92 = io_dec_inst & 32'h2020; // @[decode.scala 41:65]
  wire  _decoded_inst_T_93 = _decoded_inst_T_92 == 32'h2020; // @[decode.scala 41:121]
  wire  _decoded_inst_T_95 = _decoded_inst_T_78 | _decoded_inst_T_93; // @[decode.scala 42:26]
  wire  _decoded_inst_T_97 = _decoded_inst_T_92 == 32'h2000; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_T_99 = io_dec_inst & 32'h4000; // @[decode.scala 41:65]
  wire  _decoded_inst_T_100 = _decoded_inst_T_99 == 32'h4000; // @[decode.scala 41:121]
  wire  _decoded_inst_T_103 = _decoded_inst_T_92 == 32'h20; // @[decode.scala 41:121]
  wire [1:0] decoded_inst_lo_1 = {_decoded_inst_T_97,_decoded_inst_T_95}; // @[Cat.scala 33:92]
  wire [1:0] decoded_inst_hi_3 = {_decoded_inst_T_103,_decoded_inst_T_100}; // @[Cat.scala 33:92]
  wire [31:0] _decoded_inst_T_105 = io_dec_inst & 32'h50; // @[decode.scala 41:65]
  wire  _decoded_inst_T_106 = _decoded_inst_T_105 == 32'h0; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_60 = io_dec_inst & 32'h506f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_61 = _decoded_inst_bit_T_60 == 32'h3; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_63 = _decoded_inst_bit_T_29 == 32'h67; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_64 = io_dec_inst & 32'h107f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_65 = _decoded_inst_bit_T_64 == 32'h1073; // @[decode.scala 41:121]
  wire  dec_rd_en = _decoded_inst_bit_T_61 | _decoded_inst_bit_T_3 | _decoded_inst_bit_T_7 | _decoded_inst_bit_T_9 |
    _decoded_inst_bit_T_11 | _decoded_inst_bit_T_63 | _decoded_inst_bit_T_15 | _decoded_inst_bit_T_18 |
    _decoded_inst_bit_T_65 | _decoded_inst_bit_T_20 | _decoded_inst_bit_T_22 | _decoded_inst_bit_T_24 |
    _decoded_inst_bit_T_26 | _decoded_inst_bit_T_39; // @[decode.scala 42:26]
  wire  _decoded_inst_bit_T_80 = _decoded_inst_bit_T_2 == 32'h63; // @[decode.scala 41:121]
  wire [31:0] _decoded_inst_bit_T_84 = io_dec_inst & 32'h507f; // @[decode.scala 41:65]
  wire  _decoded_inst_bit_T_85 = _decoded_inst_bit_T_84 == 32'h3; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_88 = _decoded_inst_bit_T_4 == 32'h23; // @[decode.scala 41:121]
  wire  _decoded_inst_bit_T_90 = _decoded_inst_bit_T_84 == 32'h23; // @[decode.scala 41:121]
  wire  dec_fence_i = _decoded_inst_bit_T_29 == 32'h100f; // @[decode.scala 41:121]
  reg [3:0] exe_reg_alu_type; // @[control.scala 197:36]
  reg [2:0] exe_reg_br_type; // @[control.scala 198:36]
  reg [1:0] exe_reg_csr_type; // @[control.scala 199:36]
  reg [1:0] exe_reg_rd_data_sel; // @[control.scala 201:36]
  reg [3:0] exe_reg_mem_type; // @[control.scala 202:36]
  reg [1:0] mem_reg_rd_data_sel_REG; // @[control.scala 203:44]
  reg [1:0] mem_reg_rd_data_sel; // @[control.scala 203:36]
  reg  mem_reg_exception; // @[control.scala 225:34]
  reg [1:0] stall_count_0; // @[control.scala 236:28]
  reg [1:0] stall_count_1; // @[control.scala 236:28]
  reg [1:0] stall_count_2; // @[control.scala 236:28]
  reg [1:0] stall_count_3; // @[control.scala 236:28]
  wire [1:0] _stall_count_0_T_2 = stall_count_0 - 2'h1; // @[control.scala 239:72]
  wire [1:0] _stall_count_0_T_3 = stall_count_0 != 2'h0 ? _stall_count_0_T_2 : 2'h0; // @[control.scala 239:28]
  wire [1:0] _stall_count_1_T_2 = stall_count_1 - 2'h1; // @[control.scala 239:72]
  wire [1:0] _stall_count_1_T_3 = stall_count_1 != 2'h0 ? _stall_count_1_T_2 : 2'h0; // @[control.scala 239:28]
  wire [1:0] _stall_count_2_T_2 = stall_count_2 - 2'h1; // @[control.scala 239:72]
  wire [1:0] _stall_count_2_T_3 = stall_count_2 != 2'h0 ? _stall_count_2_T_2 : 2'h0; // @[control.scala 239:28]
  wire [1:0] _stall_count_3_T_2 = stall_count_3 - 2'h1; // @[control.scala 239:72]
  wire [1:0] _stall_count_3_T_3 = stall_count_3 != 2'h0 ? _stall_count_3_T_2 : 2'h0; // @[control.scala 239:28]
  reg  if_reg_valid; // @[control.scala 254:30]
  wire [1:0] _GEN_1 = 2'h1 == io_if_tid ? stall_count_1 : stall_count_0; // @[control.scala 257:{46,46}]
  wire [1:0] _GEN_2 = 2'h2 == io_if_tid ? stall_count_2 : _GEN_1; // @[control.scala 257:{46,46}]
  wire [1:0] _GEN_3 = 2'h3 == io_if_tid ? stall_count_3 : _GEN_2; // @[control.scala 257:{46,46}]
  wire  _if_pre_valid_T_4 = _GEN_3 == 2'h0; // @[control.scala 257:46]
  wire  if_pre_valid = if_reg_valid & _if_pre_valid_T_4; // @[control.scala 256:66]
  reg  dec_reg_valid; // @[control.scala 260:30]
  reg  exe_reg_valid; // @[control.scala 263:30]
  reg  exe_reg_exc; // @[control.scala 519:28]
  wire  exe_inst_exc = io_exe_exc_load_misaligned | io_exe_exc_load_fault | io_exe_exc_store_misaligned |
    io_exe_exc_store_fault; // @[control.scala 497:54]
  wire  _GEN_17 = 2'h1 == io_exe_tid ? io_exe_expire_ee_1 : io_exe_expire_ee_0; // @[control.scala 334:{55,55}]
  wire  _GEN_18 = 2'h2 == io_exe_tid ? io_exe_expire_ee_2 : _GEN_17; // @[control.scala 334:{55,55}]
  wire  _GEN_19 = 2'h3 == io_exe_tid ? io_exe_expire_ee_3 : _GEN_18; // @[control.scala 334:{55,55}]
  wire  _GEN_13 = 2'h1 == io_exe_tid ? io_exe_expire_ie_1 : io_exe_expire_ie_0; // @[control.scala 334:{55,55}]
  wire  _GEN_14 = 2'h2 == io_exe_tid ? io_exe_expire_ie_2 : _GEN_13; // @[control.scala 334:{55,55}]
  wire  _GEN_15 = 2'h3 == io_exe_tid ? io_exe_expire_ie_3 : _GEN_14; // @[control.scala 334:{55,55}]
  wire  exe_any_exc = _GEN_19 | _GEN_15 | io_exe_int_ext; // @[control.scala 497:54]
  wire  exe_exception = exe_reg_valid & (exe_reg_exc | exe_inst_exc | exe_any_exc); // @[control.scala 550:24]
  wire  exe_valid = exe_reg_valid & ~exe_exception; // @[control.scala 264:37]
  reg  mem_reg_valid; // @[control.scala 265:30]
  reg [1:0] next_tid_REG; // @[control.scala 283:24]
  reg  next_valid_REG; // @[control.scala 284:26]
  wire  dec_rd_write = io_dec_inst[11:7] != 5'h0 & dec_rd_en; // @[control.scala 289:51]
  reg  exe_reg_rd_write; // @[control.scala 292:33]
  reg  mem_reg_rd_write; // @[control.scala 296:33]
  reg  exe_reg_csr_write; // @[control.scala 307:34]
  reg  exe_reg_mret; // @[control.scala 312:29]
  wire  exe_mret = exe_reg_valid & exe_reg_mret; // @[control.scala 313:32]
  reg  exe_reg_load; // @[control.scala 319:29]
  reg  exe_reg_store; // @[control.scala 321:30]
  reg  exe_reg_branch; // @[control.scala 325:31]
  reg  exe_reg_jump; // @[control.scala 326:29]
  wire  exe_brjmp = exe_reg_valid & (exe_reg_jump | exe_reg_branch & io_exe_br_cond); // @[control.scala 328:33]
  reg  exe_du_exe_reg_du; // @[control.scala 343:29]
  wire  _GEN_21 = 2'h1 == io_exe_tid ? io_timer_expire_du_wu_1 : io_timer_expire_du_wu_0; // @[control.scala 344:{36,36}]
  wire  _GEN_22 = 2'h2 == io_exe_tid ? io_timer_expire_du_wu_2 : _GEN_21; // @[control.scala 344:{36,36}]
  wire  _GEN_23 = 2'h3 == io_exe_tid ? io_timer_expire_du_wu_3 : _GEN_22; // @[control.scala 344:{36,36}]
  wire  _exe_du_T_1 = ~_GEN_23; // @[control.scala 344:36]
  wire  exe_du = exe_reg_valid & exe_du_exe_reg_du & ~_GEN_23; // @[control.scala 344:33]
  reg  exe_wu_exe_reg_wu; // @[control.scala 356:29]
  wire  exe_wu = exe_reg_valid & exe_wu_exe_reg_wu & _exe_du_T_1; // @[control.scala 357:33]
  wire  exe_du_wu = exe_du | exe_wu; // @[control.scala 363:26]
  wire  exe_sleep_du = exe_du & exe_valid; // @[control.scala 364:29]
  wire  exe_sleep_wu = exe_wu & exe_valid; // @[control.scala 365:29]
  wire  exe_sleep = exe_sleep_du | exe_sleep_wu; // @[control.scala 366:32]
  reg  mem_reg_brjmp; // @[control.scala 369:30]
  reg  exe_reg_ie; // @[control.scala 375:27]
  reg  exe_reg_ee; // @[control.scala 377:27]
  wire  _GEN_25 = 2'h1 == io_if_tid ? io_exe_expire_du_1 : io_exe_expire_du_0; // @[control.scala 413:{21,21}]
  wire  _GEN_26 = 2'h2 == io_if_tid ? io_exe_expire_du_2 : _GEN_25; // @[control.scala 413:{21,21}]
  wire  _GEN_27 = 2'h3 == io_if_tid ? io_exe_expire_du_3 : _GEN_26; // @[control.scala 413:{21,21}]
  wire [1:0] _GEN_28 = 2'h0 == io_if_tid ? 2'h1 : 2'h0; // @[control.scala 412:55 413:{78,78}]
  wire [1:0] _GEN_29 = 2'h1 == io_if_tid ? 2'h1 : 2'h0; // @[control.scala 412:55 413:{78,78}]
  wire [1:0] _GEN_30 = 2'h2 == io_if_tid ? 2'h1 : 2'h0; // @[control.scala 412:55 413:{78,78}]
  wire [1:0] _GEN_31 = 2'h3 == io_if_tid ? 2'h1 : 2'h0; // @[control.scala 412:55 413:{78,78}]
  wire [1:0] _GEN_32 = if_pre_valid | _GEN_27 ? _GEN_28 : 2'h0; // @[control.scala 413:53 412:55]
  wire [1:0] _GEN_33 = if_pre_valid | _GEN_27 ? _GEN_29 : 2'h0; // @[control.scala 413:53 412:55]
  wire [1:0] _GEN_34 = if_pre_valid | _GEN_27 ? _GEN_30 : 2'h0; // @[control.scala 413:53 412:55]
  wire [1:0] _GEN_35 = if_pre_valid | _GEN_27 ? _GEN_31 : 2'h0; // @[control.scala 413:53 412:55]
  wire [1:0] _GEN_36 = 2'h0 == io_mem_tid ? 2'h2 : _GEN_32; // @[control.scala 417:{59,59}]
  wire [1:0] _GEN_37 = 2'h1 == io_mem_tid ? 2'h2 : _GEN_33; // @[control.scala 417:{59,59}]
  wire [1:0] _GEN_38 = 2'h2 == io_mem_tid ? 2'h2 : _GEN_34; // @[control.scala 417:{59,59}]
  wire [1:0] _GEN_39 = 2'h3 == io_mem_tid ? 2'h2 : _GEN_35; // @[control.scala 417:{59,59}]
  wire [1:0] _GEN_40 = mem_reg_brjmp ? _GEN_36 : _GEN_32; // @[control.scala 417:33]
  wire [1:0] _GEN_41 = mem_reg_brjmp ? _GEN_37 : _GEN_33; // @[control.scala 417:33]
  wire [1:0] _GEN_42 = mem_reg_brjmp ? _GEN_38 : _GEN_34; // @[control.scala 417:33]
  wire [1:0] _GEN_43 = mem_reg_brjmp ? _GEN_39 : _GEN_35; // @[control.scala 417:33]
  wire [1:0] _GEN_44 = 2'h0 == io_mem_tid ? 2'h3 : _GEN_40; // @[control.scala 429:{33,33}]
  wire [1:0] _GEN_45 = 2'h1 == io_mem_tid ? 2'h3 : _GEN_41; // @[control.scala 429:{33,33}]
  wire [1:0] _GEN_46 = 2'h2 == io_mem_tid ? 2'h3 : _GEN_42; // @[control.scala 429:{33,33}]
  wire [1:0] _GEN_47 = 2'h3 == io_mem_tid ? 2'h3 : _GEN_43; // @[control.scala 429:{33,33}]
  wire [1:0] _GEN_48 = mem_reg_exception ? _GEN_44 : _GEN_40; // @[control.scala 428:31]
  wire [1:0] _GEN_49 = mem_reg_exception ? _GEN_45 : _GEN_41; // @[control.scala 428:31]
  wire [1:0] _GEN_50 = mem_reg_exception ? _GEN_46 : _GEN_42; // @[control.scala 428:31]
  wire [1:0] _GEN_51 = mem_reg_exception ? _GEN_47 : _GEN_43; // @[control.scala 428:31]
  wire [11:0] _GEN_52 = mem_reg_exception ? 12'h508 : 12'h0; // @[control.scala 420:27 428:31 430:33]
  wire [1:0] _GEN_53 = 2'h0 == io_exe_tid ? 2'h3 : _GEN_48; // @[control.scala 436:{29,29}]
  wire [1:0] _GEN_54 = 2'h1 == io_exe_tid ? 2'h3 : _GEN_49; // @[control.scala 436:{29,29}]
  wire [1:0] _GEN_55 = 2'h2 == io_exe_tid ? 2'h3 : _GEN_50; // @[control.scala 436:{29,29}]
  wire [1:0] _GEN_56 = 2'h3 == io_exe_tid ? 2'h3 : _GEN_51; // @[control.scala 436:{29,29}]
  wire [11:0] _GEN_57 = exe_reg_mret ? 12'h511 : _GEN_52; // @[control.scala 437:25 438:31]
  wire [1:0] _GEN_63 = 2'h0 == io_exe_tid ? 2'h1 : _stall_count_0_T_3; // @[control.scala 239:22 448:{49,49}]
  wire [1:0] _GEN_64 = 2'h1 == io_exe_tid ? 2'h1 : _stall_count_1_T_3; // @[control.scala 239:22 448:{49,49}]
  wire [1:0] _GEN_65 = 2'h2 == io_exe_tid ? 2'h1 : _stall_count_2_T_3; // @[control.scala 239:22 448:{49,49}]
  wire [1:0] _GEN_66 = 2'h3 == io_exe_tid ? 2'h1 : _stall_count_3_T_3; // @[control.scala 239:22 448:{49,49}]
  wire [1:0] _GEN_68 = exe_brjmp | exe_mret ? _GEN_63 : _stall_count_0_T_3; // @[control.scala 239:22 446:31]
  wire [1:0] _GEN_69 = exe_brjmp | exe_mret ? _GEN_64 : _stall_count_1_T_3; // @[control.scala 239:22 446:31]
  wire [1:0] _GEN_70 = exe_brjmp | exe_mret ? _GEN_65 : _stall_count_2_T_3; // @[control.scala 239:22 446:31]
  wire [1:0] _GEN_71 = exe_brjmp | exe_mret ? _GEN_66 : _stall_count_3_T_3; // @[control.scala 239:22 446:31]
  wire [1:0] _GEN_72 = 2'h0 == io_exe_tid ? 2'h2 : _GEN_68; // @[control.scala 458:{31,31}]
  wire [1:0] _GEN_73 = 2'h1 == io_exe_tid ? 2'h2 : _GEN_69; // @[control.scala 458:{31,31}]
  wire [1:0] _GEN_74 = 2'h2 == io_exe_tid ? 2'h2 : _GEN_70; // @[control.scala 458:{31,31}]
  wire [1:0] _GEN_75 = 2'h3 == io_exe_tid ? 2'h2 : _GEN_71; // @[control.scala 458:{31,31}]
  wire [1:0] _GEN_77 = exe_sleep ? _GEN_72 : _GEN_68; // @[control.scala 453:19]
  wire [1:0] _GEN_78 = exe_sleep ? _GEN_73 : _GEN_69; // @[control.scala 453:19]
  wire [1:0] _GEN_79 = exe_sleep ? _GEN_74 : _GEN_70; // @[control.scala 453:19]
  wire [1:0] _GEN_80 = exe_sleep ? _GEN_75 : _GEN_71; // @[control.scala 453:19]
  wire [1:0] _GEN_82 = 2'h0 == io_exe_tid ? 2'h1 : _GEN_77; // @[control.scala 482:{29,29}]
  wire [1:0] _GEN_83 = 2'h1 == io_exe_tid ? 2'h1 : _GEN_78; // @[control.scala 482:{29,29}]
  wire [1:0] _GEN_84 = 2'h2 == io_exe_tid ? 2'h1 : _GEN_79; // @[control.scala 482:{29,29}]
  wire [1:0] _GEN_85 = 2'h3 == io_exe_tid ? 2'h1 : _GEN_80; // @[control.scala 482:{29,29}]
  wire [1:0] _GEN_87 = dec_reg_valid & dec_fence_i ? _GEN_82 : _GEN_77; // @[control.scala 480:45]
  wire [1:0] _GEN_88 = dec_reg_valid & dec_fence_i ? _GEN_83 : _GEN_78; // @[control.scala 480:45]
  wire [1:0] _GEN_89 = dec_reg_valid & dec_fence_i ? _GEN_84 : _GEN_79; // @[control.scala 480:45]
  wire [1:0] _GEN_90 = dec_reg_valid & dec_fence_i ? _GEN_85 : _GEN_80; // @[control.scala 480:45]
  reg  dec_reg_exc; // @[control.scala 510:28]
  reg  dec_reg_cause; // @[control.scala 511:30]
  wire  _T_8 = ~dec_legal; // @[control.scala 515:8]
  wire  dec_exc = _T_8 | dec_scall; // @[control.scala 497:54]
  reg [2:0] exe_reg_cause; // @[control.scala 520:30]
  wire [3:0] _T_11 = io_exe_exc_store_fault ? 4'hb : 4'h0; // @[control.scala 499:47]
  wire [3:0] _T_12 = io_exe_exc_store_misaligned ? 4'h9 : _T_11; // @[control.scala 499:47]
  wire [3:0] _T_13 = io_exe_exc_load_fault ? 4'ha : _T_12; // @[control.scala 499:47]
  wire [3:0] exe_inst_cause = io_exe_exc_load_misaligned ? 4'h8 : _T_13; // @[control.scala 499:47]
  wire [4:0] _T_15 = io_exe_int_ext ? 5'h1e : 5'h0; // @[control.scala 499:47]
  wire [4:0] _T_16 = _GEN_15 ? 5'h1d : _T_15; // @[control.scala 499:47]
  wire [4:0] exe_any_cause = _GEN_19 ? 5'hd : _T_16; // @[control.scala 499:47]
  wire [4:0] _exe_exception_cause_T = exe_inst_exc ? {{1'd0}, exe_inst_cause} : exe_any_cause; // @[control.scala 556:31]
  reg  exe_cycle_REG; // @[control.scala 573:41]
  reg  exe_cycle_REG_1; // @[control.scala 573:33]
  reg  exe_cycle_REG_2; // @[control.scala 573:25]
  Scheduler scheduler ( // @[control.scala 276:25]
    .clock(scheduler_clock),
    .reset(scheduler_reset),
    .io_thread_modes_0(scheduler_io_thread_modes_0),
    .io_thread_modes_1(scheduler_io_thread_modes_1),
    .io_thread_modes_2(scheduler_io_thread_modes_2),
    .io_thread_modes_3(scheduler_io_thread_modes_3),
    .io_thread(scheduler_io_thread),
    .io_valid(scheduler_io_valid)
  );
  assign io_dec_imm_sel = {decoded_inst_hi,_decoded_inst_T_5}; // @[Cat.scala 33:92]
  assign io_dec_op1_sel = {_decoded_inst_T_31,_decoded_inst_T_25}; // @[Cat.scala 33:92]
  assign io_dec_op2_sel = {_decoded_inst_T_47,_decoded_inst_T_40}; // @[Cat.scala 33:92]
  assign io_exe_alu_type = exe_reg_alu_type; // @[control.scala 208:22]
  assign io_exe_br_type = exe_reg_br_type; // @[control.scala 209:22]
  assign io_exe_csr_type = exe_reg_csr_type; // @[control.scala 210:22]
  assign io_exe_rd_data_sel = exe_reg_rd_data_sel; // @[control.scala 212:22]
  assign io_exe_mem_type = exe_reg_mem_type; // @[control.scala 213:22]
  assign io_mem_rd_data_sel = mem_reg_rd_data_sel; // @[control.scala 214:22]
  assign io_next_pc_sel_0 = exe_mret ? _GEN_53 : _GEN_48; // @[control.scala 435:18]
  assign io_next_pc_sel_1 = exe_mret ? _GEN_54 : _GEN_49; // @[control.scala 435:18]
  assign io_next_pc_sel_2 = exe_mret ? _GEN_55 : _GEN_50; // @[control.scala 435:18]
  assign io_next_pc_sel_3 = exe_mret ? _GEN_56 : _GEN_51; // @[control.scala 435:18]
  assign io_next_pc_sel_csr_addr = exe_mret ? _GEN_57 : _GEN_52; // @[control.scala 435:18]
  assign io_next_tid = next_tid_REG; // @[control.scala 275:22 283:14]
  assign io_exe_load = exe_reg_load & exe_reg_valid; // @[control.scala 320:31]
  assign io_exe_store = exe_reg_store & exe_reg_valid; // @[control.scala 322:33]
  assign io_exe_csr_write = exe_reg_csr_write & exe_reg_valid; // @[control.scala 308:41]
  assign io_exe_exception = exe_reg_valid & (exe_reg_exc | exe_inst_exc | exe_any_exc); // @[control.scala 550:24]
  assign io_exe_cause = exe_reg_exc ? {{2'd0}, exe_reg_cause} : _exe_exception_cause_T; // @[control.scala 555:31]
  assign io_exe_kill = exe_reg_exc | exe_any_exc; // @[control.scala 542:30]
  assign io_exe_sleep_du = exe_du & exe_valid; // @[control.scala 364:29]
  assign io_exe_sleep_wu = exe_wu & exe_valid; // @[control.scala 365:29]
  assign io_exe_ie = exe_valid & exe_reg_ie; // @[control.scala 376:23]
  assign io_exe_ee = exe_valid & exe_reg_ee; // @[control.scala 378:23]
  assign io_exe_mret = exe_reg_mret; // @[control.scala 594:20]
  assign io_exe_cycle = exe_cycle_REG_2; // @[control.scala 568:23 573:15]
  assign io_exe_instret = exe_reg_valid & ~exe_exception; // @[control.scala 264:37]
  assign io_mem_rd_write = mem_reg_rd_write & mem_reg_valid; // @[control.scala 297:39]
  assign scheduler_clock = clock;
  assign scheduler_reset = reset;
  assign scheduler_io_thread_modes_0 = io_csr_tmodes_0; // @[control.scala 278:29]
  assign scheduler_io_thread_modes_1 = io_csr_tmodes_1; // @[control.scala 278:29]
  assign scheduler_io_thread_modes_2 = io_csr_tmodes_2; // @[control.scala 278:29]
  assign scheduler_io_thread_modes_3 = io_csr_tmodes_3; // @[control.scala 278:29]
  always @(posedge clock) begin
    exe_reg_alu_type <= {decoded_inst_hi_1,decoded_inst_lo}; // @[Cat.scala 33:92]
    exe_reg_br_type <= {decoded_inst_hi_2,_decoded_inst_T_78}; // @[Cat.scala 33:92]
    exe_reg_csr_type <= {_decoded_inst_T_84,_decoded_inst_T_78}; // @[Cat.scala 33:92]
    exe_reg_rd_data_sel <= {_decoded_inst_T_90,_decoded_inst_T_3}; // @[Cat.scala 33:92]
    exe_reg_mem_type <= {decoded_inst_hi_3,decoded_inst_lo_1}; // @[Cat.scala 33:92]
    mem_reg_rd_data_sel_REG <= {1'h0,_decoded_inst_T_106}; // @[Cat.scala 33:92]
    mem_reg_rd_data_sel <= mem_reg_rd_data_sel_REG; // @[control.scala 203:36]
    mem_reg_exception <= exe_reg_valid & (exe_reg_exc | exe_inst_exc | exe_any_exc); // @[control.scala 550:24]
    if (reset) begin // @[control.scala 236:28]
      stall_count_0 <= 2'h0; // @[control.scala 236:28]
    end else if (2'h0 == io_exe_tid) begin // @[control.scala 564:29]
      stall_count_0 <= 2'h0; // @[control.scala 564:29]
    end else if (exe_exception) begin // @[control.scala 550:73]
      if (2'h0 == io_exe_tid) begin // @[control.scala 552:50]
        stall_count_0 <= 2'h1; // @[control.scala 552:50]
      end else begin
        stall_count_0 <= _GEN_87;
      end
    end else begin
      stall_count_0 <= _GEN_87;
    end
    if (reset) begin // @[control.scala 236:28]
      stall_count_1 <= 2'h0; // @[control.scala 236:28]
    end else if (2'h1 == io_exe_tid) begin // @[control.scala 564:29]
      stall_count_1 <= 2'h0; // @[control.scala 564:29]
    end else if (exe_exception) begin // @[control.scala 550:73]
      if (2'h1 == io_exe_tid) begin // @[control.scala 552:50]
        stall_count_1 <= 2'h1; // @[control.scala 552:50]
      end else begin
        stall_count_1 <= _GEN_88;
      end
    end else begin
      stall_count_1 <= _GEN_88;
    end
    if (reset) begin // @[control.scala 236:28]
      stall_count_2 <= 2'h0; // @[control.scala 236:28]
    end else if (2'h2 == io_exe_tid) begin // @[control.scala 564:29]
      stall_count_2 <= 2'h0; // @[control.scala 564:29]
    end else if (exe_exception) begin // @[control.scala 550:73]
      if (2'h2 == io_exe_tid) begin // @[control.scala 552:50]
        stall_count_2 <= 2'h1; // @[control.scala 552:50]
      end else begin
        stall_count_2 <= _GEN_89;
      end
    end else begin
      stall_count_2 <= _GEN_89;
    end
    if (reset) begin // @[control.scala 236:28]
      stall_count_3 <= 2'h0; // @[control.scala 236:28]
    end else if (2'h3 == io_exe_tid) begin // @[control.scala 564:29]
      stall_count_3 <= 2'h0; // @[control.scala 564:29]
    end else if (exe_exception) begin // @[control.scala 550:73]
      if (2'h3 == io_exe_tid) begin // @[control.scala 552:50]
        stall_count_3 <= 2'h1; // @[control.scala 552:50]
      end else begin
        stall_count_3 <= _GEN_90;
      end
    end else begin
      stall_count_3 <= _GEN_90;
    end
    if (reset) begin // @[control.scala 254:30]
      if_reg_valid <= 1'h0; // @[control.scala 254:30]
    end else begin
      if_reg_valid <= next_valid_REG; // @[control.scala 254:30]
    end
    if (reset) begin // @[control.scala 260:30]
      dec_reg_valid <= 1'h0; // @[control.scala 260:30]
    end else begin
      dec_reg_valid <= if_pre_valid; // @[control.scala 260:30]
    end
    if (reset) begin // @[control.scala 263:30]
      exe_reg_valid <= 1'h0; // @[control.scala 263:30]
    end else begin
      exe_reg_valid <= dec_reg_valid; // @[control.scala 263:30]
    end
    exe_reg_exc <= dec_reg_exc | dec_exc; // @[control.scala 519:41]
    if (reset) begin // @[control.scala 265:30]
      mem_reg_valid <= 1'h0; // @[control.scala 265:30]
    end else begin
      mem_reg_valid <= exe_valid; // @[control.scala 265:30]
    end
    next_tid_REG <= scheduler_io_thread; // @[control.scala 283:24]
    if (reset) begin // @[control.scala 284:26]
      next_valid_REG <= 1'h0; // @[control.scala 284:26]
    end else begin
      next_valid_REG <= scheduler_io_valid; // @[control.scala 284:26]
    end
    exe_reg_rd_write <= dec_rd_write & dec_reg_valid; // @[control.scala 292:47]
    mem_reg_rd_write <= exe_reg_rd_write & exe_reg_valid; // @[control.scala 296:51]
    exe_reg_csr_write <= _decoded_inst_bit_T_65 | _decoded_inst_bit_T_22; // @[decode.scala 42:26]
    exe_reg_mret <= io_dec_inst == 32'h30200073; // @[decode.scala 41:121]
    exe_reg_load <= _decoded_inst_bit_T_85 | _decoded_inst_bit_T_3; // @[decode.scala 42:26]
    exe_reg_store <= _decoded_inst_bit_T_88 | _decoded_inst_bit_T_90; // @[decode.scala 42:26]
    exe_reg_branch <= _decoded_inst_bit_T_80 | _decoded_inst_bit_T_37; // @[decode.scala 42:26]
    exe_reg_jump <= _decoded_inst_bit_T_63 | _decoded_inst_bit_T_15; // @[decode.scala 42:26]
    exe_du_exe_reg_du <= _decoded_inst_bit_T_29 == 32'h700b; // @[decode.scala 41:121]
    exe_wu_exe_reg_wu <= _decoded_inst_bit_T_29 == 32'h702b; // @[decode.scala 41:121]
    mem_reg_brjmp <= (exe_brjmp | exe_du_wu) & exe_valid; // @[control.scala 369:56]
    exe_reg_ie <= dec_ie & io_dec_inst[25]; // @[control.scala 375:42]
    exe_reg_ee <= dec_ie & ~io_dec_inst[25]; // @[control.scala 377:42]
    dec_reg_exc <= io_if_exc_misaligned | io_if_exc_fault; // @[control.scala 497:54]
    if (io_if_exc_misaligned) begin // @[control.scala 499:47]
      dec_reg_cause <= 1'h0;
    end else begin
      dec_reg_cause <= io_if_exc_fault;
    end
    if (dec_reg_exc) begin // @[control.scala 520:34]
      exe_reg_cause <= {{2'd0}, dec_reg_cause};
    end else if (_T_8) begin // @[control.scala 499:47]
      exe_reg_cause <= 3'h2;
    end else if (dec_scall) begin // @[control.scala 499:47]
      exe_reg_cause <= 3'h6;
    end else begin
      exe_reg_cause <= 3'h0;
    end
    exe_cycle_REG <= next_valid_REG; // @[control.scala 253:27 284:16]
    exe_cycle_REG_1 <= exe_cycle_REG; // @[control.scala 573:33]
    exe_cycle_REG_2 <= exe_cycle_REG_1; // @[control.scala 573:25]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  exe_reg_alu_type = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  exe_reg_br_type = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  exe_reg_csr_type = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  exe_reg_rd_data_sel = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  exe_reg_mem_type = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  mem_reg_rd_data_sel_REG = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  mem_reg_rd_data_sel = _RAND_6[1:0];
  _RAND_7 = {1{`RANDOM}};
  mem_reg_exception = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  stall_count_0 = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  stall_count_1 = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  stall_count_2 = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  stall_count_3 = _RAND_11[1:0];
  _RAND_12 = {1{`RANDOM}};
  if_reg_valid = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  dec_reg_valid = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  exe_reg_valid = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  exe_reg_exc = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  mem_reg_valid = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  next_tid_REG = _RAND_17[1:0];
  _RAND_18 = {1{`RANDOM}};
  next_valid_REG = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  exe_reg_rd_write = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  mem_reg_rd_write = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  exe_reg_csr_write = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  exe_reg_mret = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  exe_reg_load = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  exe_reg_store = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  exe_reg_branch = _RAND_25[0:0];
  _RAND_26 = {1{`RANDOM}};
  exe_reg_jump = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  exe_du_exe_reg_du = _RAND_27[0:0];
  _RAND_28 = {1{`RANDOM}};
  exe_wu_exe_reg_wu = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  mem_reg_brjmp = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  exe_reg_ie = _RAND_30[0:0];
  _RAND_31 = {1{`RANDOM}};
  exe_reg_ee = _RAND_31[0:0];
  _RAND_32 = {1{`RANDOM}};
  dec_reg_exc = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  dec_reg_cause = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  exe_reg_cause = _RAND_34[2:0];
  _RAND_35 = {1{`RANDOM}};
  exe_cycle_REG = _RAND_35[0:0];
  _RAND_36 = {1{`RANDOM}};
  exe_cycle_REG_1 = _RAND_36[0:0];
  _RAND_37 = {1{`RANDOM}};
  exe_cycle_REG_2 = _RAND_37[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module RegisterFile(
  input         clock,
  input  [1:0]  io_read_0_thread,
  input  [4:0]  io_read_0_addr,
  output [31:0] io_read_0_data,
  input  [1:0]  io_read_1_thread,
  input  [4:0]  io_read_1_addr,
  output [31:0] io_read_1_data,
  input  [1:0]  io_write_0_thread,
  input  [4:0]  io_write_0_addr,
  input  [31:0] io_write_0_data,
  input         io_write_0_enable
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] regfile [0:127]; // @[RegisterFile.scala 50:28]
  wire  regfile_regfileRead_MPORT_en; // @[RegisterFile.scala 50:28]
  wire [6:0] regfile_regfileRead_MPORT_addr; // @[RegisterFile.scala 50:28]
  wire [31:0] regfile_regfileRead_MPORT_data; // @[RegisterFile.scala 50:28]
  wire  regfile_regfileRead_MPORT_1_en; // @[RegisterFile.scala 50:28]
  wire [6:0] regfile_regfileRead_MPORT_1_addr; // @[RegisterFile.scala 50:28]
  wire [31:0] regfile_regfileRead_MPORT_1_data; // @[RegisterFile.scala 50:28]
  wire [31:0] regfile_MPORT_data; // @[RegisterFile.scala 50:28]
  wire [6:0] regfile_MPORT_addr; // @[RegisterFile.scala 50:28]
  wire  regfile_MPORT_mask; // @[RegisterFile.scala 50:28]
  wire  regfile_MPORT_en; // @[RegisterFile.scala 50:28]
  reg  regfile_regfileRead_MPORT_en_pipe_0;
  reg [6:0] regfile_regfileRead_MPORT_addr_pipe_0;
  reg  regfile_regfileRead_MPORT_1_en_pipe_0;
  reg [6:0] regfile_regfileRead_MPORT_1_addr_pipe_0;
  wire [31:0] regfileRead = regfile_regfileRead_MPORT_data; // @[RegisterFile.scala 57:26]
  reg [6:0] REG; // @[RegisterFile.scala 67:15]
  reg [31:0] REG_1; // @[RegisterFile.scala 68:24]
  reg  REG_2; // @[RegisterFile.scala 69:16]
  reg  REG_3; // @[RegisterFile.scala 70:16]
  wire [31:0] _T_2 = REG_3 ? regfileRead : REG_1; // @[Mux.scala 101:16]
  wire [31:0] _T_3 = REG_2 ? 32'h0 : _T_2; // @[Mux.scala 101:16]
  reg [6:0] readIndexReg; // @[RegisterFile.scala 74:31]
  wire [31:0] regfileRead_1 = regfile_regfileRead_MPORT_1_data; // @[RegisterFile.scala 57:26]
  reg [6:0] REG_4; // @[RegisterFile.scala 67:15]
  reg [31:0] REG_5; // @[RegisterFile.scala 68:24]
  reg  REG_6; // @[RegisterFile.scala 69:16]
  reg  REG_7; // @[RegisterFile.scala 70:16]
  wire [31:0] _T_6 = REG_7 ? regfileRead_1 : REG_5; // @[Mux.scala 101:16]
  wire [31:0] _T_7 = REG_6 ? 32'h0 : _T_6; // @[Mux.scala 101:16]
  reg [6:0] readIndexReg_1; // @[RegisterFile.scala 74:31]
  wire  _T_8 = io_write_0_addr != 5'h0; // @[RegisterFile.scala 81:35]
  assign regfile_regfileRead_MPORT_en = regfile_regfileRead_MPORT_en_pipe_0;
  assign regfile_regfileRead_MPORT_addr = regfile_regfileRead_MPORT_addr_pipe_0;
  assign regfile_regfileRead_MPORT_data = regfile[regfile_regfileRead_MPORT_addr]; // @[RegisterFile.scala 50:28]
  assign regfile_regfileRead_MPORT_1_en = regfile_regfileRead_MPORT_1_en_pipe_0;
  assign regfile_regfileRead_MPORT_1_addr = regfile_regfileRead_MPORT_1_addr_pipe_0;
  assign regfile_regfileRead_MPORT_1_data = regfile[regfile_regfileRead_MPORT_1_addr]; // @[RegisterFile.scala 50:28]
  assign regfile_MPORT_data = io_write_0_data;
  assign regfile_MPORT_addr = {io_write_0_thread,io_write_0_addr};
  assign regfile_MPORT_mask = 1'h1;
  assign regfile_MPORT_en = io_write_0_enable & _T_8;
  assign io_read_0_data = REG == readIndexReg ? _T_3 : regfileRead; // @[Mux.scala 81:58]
  assign io_read_1_data = REG_4 == readIndexReg_1 ? _T_7 : regfileRead_1; // @[Mux.scala 81:58]
  always @(posedge clock) begin
    if (regfile_MPORT_en & regfile_MPORT_mask) begin
      regfile[regfile_MPORT_addr] <= regfile_MPORT_data; // @[RegisterFile.scala 50:28]
    end
    regfile_regfileRead_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      regfile_regfileRead_MPORT_addr_pipe_0 <= {io_read_0_thread,io_read_0_addr};
    end
    regfile_regfileRead_MPORT_1_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      regfile_regfileRead_MPORT_1_addr_pipe_0 <= {io_read_1_thread,io_read_1_addr};
    end
    REG <= {io_write_0_thread,io_write_0_addr}; // @[Cat.scala 33:92]
    REG_1 <= io_write_0_data; // @[RegisterFile.scala 68:24]
    REG_2 <= io_write_0_addr == 5'h0; // @[RegisterFile.scala 69:32]
    REG_3 <= ~io_write_0_enable; // @[RegisterFile.scala 70:17]
    readIndexReg <= {io_read_0_thread,io_read_0_addr}; // @[Cat.scala 33:92]
    REG_4 <= {io_write_0_thread,io_write_0_addr}; // @[Cat.scala 33:92]
    REG_5 <= io_write_0_data; // @[RegisterFile.scala 68:24]
    REG_6 <= io_write_0_addr == 5'h0; // @[RegisterFile.scala 69:32]
    REG_7 <= ~io_write_0_enable; // @[RegisterFile.scala 70:17]
    readIndexReg_1 <= {io_read_1_thread,io_read_1_addr}; // @[Cat.scala 33:92]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 128; initvar = initvar+1)
    regfile[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  regfile_regfileRead_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  regfile_regfileRead_MPORT_addr_pipe_0 = _RAND_2[6:0];
  _RAND_3 = {1{`RANDOM}};
  regfile_regfileRead_MPORT_1_en_pipe_0 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  regfile_regfileRead_MPORT_1_addr_pipe_0 = _RAND_4[6:0];
  _RAND_5 = {1{`RANDOM}};
  REG = _RAND_5[6:0];
  _RAND_6 = {1{`RANDOM}};
  REG_1 = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  REG_2 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  REG_3 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  readIndexReg = _RAND_9[6:0];
  _RAND_10 = {1{`RANDOM}};
  REG_4 = _RAND_10[6:0];
  _RAND_11 = {1{`RANDOM}};
  REG_5 = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  REG_6 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  REG_7 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  readIndexReg_1 = _RAND_14[6:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ALU(
  input  [31:0] io_op1,
  input  [31:0] io_op2,
  input  [4:0]  io_shift,
  input  [3:0]  io_func,
  output [31:0] io_result
);
  wire [31:0] _io_result_T_3 = io_op1 + io_op2; // @[ALU.scala 73:27]
  wire [31:0] _io_result_T_6 = io_op1 - io_op2; // @[ALU.scala 74:27]
  wire [62:0] _GEN_0 = {{31'd0}, io_op1}; // @[ALU.scala 75:33]
  wire [62:0] _io_result_T_8 = _GEN_0 << io_shift; // @[ALU.scala 75:33]
  wire [31:0] _io_result_T_13 = $signed(io_op1) >>> io_shift; // @[ALU.scala 76:64]
  wire [31:0] _io_result_T_15 = io_op1 >> io_shift; // @[ALU.scala 77:41]
  wire [31:0] _io_result_T_17 = io_op1 & io_op2; // @[ALU.scala 78:27]
  wire [31:0] _io_result_T_19 = io_op1 | io_op2; // @[ALU.scala 79:26]
  wire [31:0] _io_result_T_21 = io_op1 ^ io_op2; // @[ALU.scala 80:27]
  wire  _io_result_T_25 = $signed(io_op1) < $signed(io_op2); // @[ALU.scala 81:45]
  wire  _io_result_T_27 = io_op1 < io_op2; // @[ALU.scala 82:40]
  wire [31:0] _io_result_T_29 = 4'h0 == io_func ? _io_result_T_3 : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_31 = 4'h1 == io_func ? _io_result_T_6 : _io_result_T_29; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_33 = 4'h2 == io_func ? _io_result_T_8[31:0] : _io_result_T_31; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_35 = 4'h3 == io_func ? _io_result_T_13 : _io_result_T_33; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_37 = 4'h4 == io_func ? _io_result_T_15 : _io_result_T_35; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_39 = 4'h5 == io_func ? _io_result_T_17 : _io_result_T_37; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_41 = 4'h6 == io_func ? _io_result_T_19 : _io_result_T_39; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_43 = 4'h7 == io_func ? _io_result_T_21 : _io_result_T_41; // @[Mux.scala 81:58]
  wire [31:0] _io_result_T_45 = 4'h8 == io_func ? {{31'd0}, _io_result_T_25} : _io_result_T_43; // @[Mux.scala 81:58]
  assign io_result = 4'h9 == io_func ? {{31'd0}, _io_result_T_27} : _io_result_T_45; // @[Mux.scala 81:58]
endmodule
module LoadStore(
  input         clock,
  input         reset,
  output [13:0] io_dmem_addr,
  output        io_dmem_enable,
  input  [31:0] io_dmem_data_out,
  output        io_dmem_byte_write_0,
  output        io_dmem_byte_write_1,
  output        io_dmem_byte_write_2,
  output        io_dmem_byte_write_3,
  output [31:0] io_dmem_data_in,
  output [15:0] io_imem_rw_addr,
  output        io_imem_rw_enable,
  input  [31:0] io_imem_rw_data_out,
  output        io_imem_rw_write,
  output [31:0] io_imem_rw_data_in,
  output [9:0]  io_bus_addr,
  output        io_bus_enable,
  input  [31:0] io_bus_data_out,
  output        io_bus_write,
  output [31:0] io_bus_data_in,
  input  [31:0] io_addr,
  input  [1:0]  io_thread,
  input         io_load,
  input         io_store,
  input  [3:0]  io_mem_type,
  input  [31:0] io_data_in,
  output [31:0] io_data_out,
  input  [3:0]  io_imem_protection_0,
  input  [3:0]  io_imem_protection_1,
  input  [3:0]  io_imem_protection_2,
  input  [3:0]  io_imem_protection_3,
  input  [3:0]  io_imem_protection_4,
  input  [3:0]  io_imem_protection_5,
  input  [3:0]  io_imem_protection_6,
  input  [3:0]  io_imem_protection_7,
  input  [3:0]  io_dmem_protection_0,
  input  [3:0]  io_dmem_protection_1,
  input  [3:0]  io_dmem_protection_2,
  input  [3:0]  io_dmem_protection_3,
  input  [3:0]  io_dmem_protection_4,
  input  [3:0]  io_dmem_protection_5,
  input  [3:0]  io_dmem_protection_6,
  input  [3:0]  io_dmem_protection_7,
  input         io_kill,
  output        io_load_misaligned,
  output        io_load_fault,
  output        io_store_misaligned,
  output        io_store_fault
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] addr_byte_reg; // @[loadstore.scala 114:30]
  reg [3:0] mem_type_reg; // @[loadstore.scala 115:29]
  wire  dmem_op = io_addr[31:29] == 3'h1; // @[loadstore.scala 118:48]
  wire  imem_op = io_addr[31:29] == 3'h0; // @[loadstore.scala 119:48]
  wire  bus_op = io_addr[31:30] == 2'h1; // @[loadstore.scala 120:48]
  wire  _bad_address_T_5 = imem_op & io_addr[28:18] != 11'h0; // @[loadstore.scala 125:14]
  wire  _bad_address_T_6 = dmem_op & io_addr[28:16] != 13'h0 | _bad_address_T_5; // @[loadstore.scala 124:72]
  wire  _bad_address_T_9 = bus_op & io_addr[29:8] != 22'h0; // @[loadstore.scala 126:14]
  wire  bad_address = _bad_address_T_6 | _bad_address_T_9; // @[loadstore.scala 125:74]
  wire [3:0] _GEN_1 = 3'h1 == io_addr[15:13] ? io_imem_protection_1 : io_imem_protection_0; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_2 = 3'h2 == io_addr[15:13] ? io_imem_protection_2 : _GEN_1; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_3 = 3'h3 == io_addr[15:13] ? io_imem_protection_3 : _GEN_2; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_4 = 3'h4 == io_addr[15:13] ? io_imem_protection_4 : _GEN_3; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_5 = 3'h5 == io_addr[15:13] ? io_imem_protection_5 : _GEN_4; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_6 = 3'h6 == io_addr[15:13] ? io_imem_protection_6 : _GEN_5; // @[loadstore.scala 137:{46,46}]
  wire [3:0] _GEN_7 = 3'h7 == io_addr[15:13] ? io_imem_protection_7 : _GEN_6; // @[loadstore.scala 137:{46,46}]
  wire  imem_permission = (_GEN_7 == 4'h8 | _GEN_7[1:0] == io_thread) & _GEN_7 != 4'hc; // @[loadstore.scala 137:117]
  wire [3:0] _GEN_9 = 3'h1 == io_addr[15:13] ? io_dmem_protection_1 : io_dmem_protection_0; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_10 = 3'h2 == io_addr[15:13] ? io_dmem_protection_2 : _GEN_9; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_11 = 3'h3 == io_addr[15:13] ? io_dmem_protection_3 : _GEN_10; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_12 = 3'h4 == io_addr[15:13] ? io_dmem_protection_4 : _GEN_11; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_13 = 3'h5 == io_addr[15:13] ? io_dmem_protection_5 : _GEN_12; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_14 = 3'h6 == io_addr[15:13] ? io_dmem_protection_6 : _GEN_13; // @[loadstore.scala 138:{46,46}]
  wire [3:0] _GEN_15 = 3'h7 == io_addr[15:13] ? io_dmem_protection_7 : _GEN_14; // @[loadstore.scala 138:{46,46}]
  wire  dmem_permission = (_GEN_15 == 4'h8 | _GEN_15[1:0] == io_thread) & _GEN_15 != 4'hc; // @[loadstore.scala 138:117]
  wire  permission = dmem_op & dmem_permission | imem_op & imem_permission | bus_op; // @[loadstore.scala 140:80]
  wire  _load_misaligned_T = io_mem_type == 4'h1; // @[loadstore.scala 150:22]
  wire  _load_misaligned_T_8 = io_addr[1:0] != 2'h0; // @[loadstore.scala 151:50]
  wire  _load_misaligned_T_9 = io_mem_type == 4'h2 & io_addr[1:0] != 2'h0; // @[loadstore.scala 151:33]
  wire  _load_misaligned_T_10 = (io_mem_type == 4'h1 | io_mem_type == 4'h5) & io_addr[0] | _load_misaligned_T_9; // @[loadstore.scala 150:89]
  wire  load_misaligned = io_load & _load_misaligned_T_10; // @[loadstore.scala 149:32]
  wire  load_fault = io_load & bad_address; // @[loadstore.scala 156:27]
  wire  _store_misaligned_T = io_mem_type == 4'h9; // @[loadstore.scala 162:21]
  wire  _store_misaligned_T_7 = _load_misaligned_T & _load_misaligned_T_8; // @[loadstore.scala 163:33]
  wire  _store_misaligned_T_8 = io_mem_type == 4'h9 & io_addr[0] | _store_misaligned_T_7; // @[loadstore.scala 162:58]
  wire  store_misaligned = io_store & _store_misaligned_T_8; // @[loadstore.scala 161:34]
  wire  store_fault = io_store & (bad_address | ~permission); // @[loadstore.scala 168:29]
  reg  dmem_op_reg; // @[loadstore.scala 172:28]
  reg  imem_op_reg; // @[loadstore.scala 173:28]
  wire  _write_T_1 = ~store_misaligned; // @[loadstore.scala 175:47]
  wire  _write_T_3 = ~store_fault; // @[loadstore.scala 175:68]
  wire  write = io_store & permission & ~store_misaligned & ~store_fault & ~io_kill; // @[loadstore.scala 175:81]
  wire  _io_dmem_data_in_T = io_mem_type == 4'h8; // @[loadstore.scala 45:17]
  wire [31:0] _io_dmem_data_in_T_3 = {io_data_in[7:0],io_data_in[7:0],io_data_in[7:0],io_data_in[7:0]}; // @[Cat.scala 33:92]
  wire [31:0] _io_dmem_data_in_T_6 = {io_data_in[15:0],io_data_in[15:0]}; // @[Cat.scala 33:92]
  wire [31:0] _io_dmem_data_in_T_7 = _store_misaligned_T ? _io_dmem_data_in_T_6 : io_data_in; // @[loadstore.scala 46:8]
  wire  _dmem_enable_T = io_load | io_store; // @[loadstore.scala 179:81]
  wire  dmem_enable = dmem_op & (io_load | io_store); // @[loadstore.scala 179:69]
  wire  _T_5 = ~reset; // @[loadstore.scala 74:15]
  wire [3:0] _result_T_1 = 4'h1 << io_addr[1:0]; // @[loadstore.scala 76:51]
  wire [4:0] _result_T_4 = 5'h3 << io_addr[1:0]; // @[loadstore.scala 77:45]
  wire [3:0] _result_T_7 = _load_misaligned_T ? 4'hf : 4'h0; // @[loadstore.scala 78:10]
  wire [3:0] _result_T_8 = _store_misaligned_T ? _result_T_4[3:0] : _result_T_7; // @[loadstore.scala 77:10]
  wire [3:0] result = _io_dmem_data_in_T ? _result_T_1 : _result_T_8; // @[loadstore.scala 76:20]
  wire [3:0] _T_8 = write ? 4'hf : 4'h0; // @[Bitwise.scala 77:12]
  wire [3:0] _T_9 = result & _T_8; // @[loadstore.scala 181:84]
  wire [4:0] _io_data_out_shifted_T = {addr_byte_reg,3'h0}; // @[Cat.scala 33:92]
  wire [31:0] io_data_out_shifted = io_dmem_data_out >> _io_data_out_shifted_T; // @[loadstore.scala 26:24]
  wire [23:0] _io_data_out_T_3 = io_data_out_shifted[7] ? 24'hffffff : 24'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _io_data_out_T_5 = {_io_data_out_T_3,io_data_out_shifted[7:0]}; // @[Cat.scala 33:92]
  wire [31:0] _io_data_out_T_8 = {24'h0,io_data_out_shifted[7:0]}; // @[Cat.scala 33:92]
  wire [15:0] _io_data_out_T_12 = io_data_out_shifted[15] ? 16'hffff : 16'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _io_data_out_T_14 = {_io_data_out_T_12,io_data_out_shifted[15:0]}; // @[Cat.scala 33:92]
  wire [31:0] _io_data_out_T_17 = {16'h0,io_data_out_shifted[15:0]}; // @[Cat.scala 33:92]
  wire [31:0] _io_data_out_T_18 = mem_type_reg == 4'h5 ? _io_data_out_T_17 : io_data_out_shifted; // @[loadstore.scala 32:8]
  wire [31:0] _io_data_out_T_19 = mem_type_reg == 4'h1 ? _io_data_out_T_14 : _io_data_out_T_18; // @[loadstore.scala 31:8]
  wire [31:0] _io_data_out_T_20 = mem_type_reg == 4'h4 ? _io_data_out_T_8 : _io_data_out_T_19; // @[loadstore.scala 30:8]
  wire [31:0] _io_data_out_T_21 = mem_type_reg == 4'h0 ? _io_data_out_T_5 : _io_data_out_T_20; // @[loadstore.scala 29:8]
  wire [31:0] _io_data_out_T_22 = imem_op_reg ? io_imem_rw_data_out : io_bus_data_out; // @[loadstore.scala 208:21]
  assign io_dmem_addr = io_addr[15:2]; // @[loadstore.scala 177:26]
  assign io_dmem_enable = dmem_op & (io_load | io_store); // @[loadstore.scala 179:69]
  assign io_dmem_byte_write_0 = _T_9[0]; // @[loadstore.scala 181:109]
  assign io_dmem_byte_write_1 = _T_9[1]; // @[loadstore.scala 181:109]
  assign io_dmem_byte_write_2 = _T_9[2]; // @[loadstore.scala 181:109]
  assign io_dmem_byte_write_3 = _T_9[3]; // @[loadstore.scala 181:109]
  assign io_dmem_data_in = io_mem_type == 4'h8 ? _io_dmem_data_in_T_3 : _io_dmem_data_in_T_7; // @[loadstore.scala 45:8]
  assign io_imem_rw_addr = {{2'd0}, io_addr[15:2]}; // @[loadstore.scala 188:21]
  assign io_imem_rw_enable = imem_op & _dmem_enable_T; // @[loadstore.scala 191:40]
  assign io_imem_rw_write = imem_op & write; // @[loadstore.scala 192:33]
  assign io_imem_rw_data_in = io_data_in; // @[loadstore.scala 189:24]
  assign io_bus_addr = {io_thread,io_addr[7:0]}; // @[Cat.scala 33:92]
  assign io_bus_enable = bus_op & _dmem_enable_T; // @[loadstore.scala 203:27]
  assign io_bus_write = bus_op & write; // @[loadstore.scala 204:26]
  assign io_bus_data_in = io_data_in; // @[loadstore.scala 202:18]
  assign io_data_out = dmem_op_reg ? _io_data_out_T_21 : _io_data_out_T_22; // @[loadstore.scala 207:21]
  assign io_load_misaligned = io_load & _load_misaligned_T_10; // @[loadstore.scala 149:32]
  assign io_load_fault = io_load & bad_address; // @[loadstore.scala 156:27]
  assign io_store_misaligned = io_store & _store_misaligned_T_8; // @[loadstore.scala 161:34]
  assign io_store_fault = io_store & (bad_address | ~permission); // @[loadstore.scala 168:29]
  always @(posedge clock) begin
    addr_byte_reg <= io_addr[1:0]; // @[loadstore.scala 114:38]
    mem_type_reg <= io_mem_type; // @[loadstore.scala 115:29]
    dmem_op_reg <= io_addr[31:29] == 3'h1; // @[loadstore.scala 118:48]
    imem_op_reg <= io_addr[31:29] == 3'h0; // @[loadstore.scala 119:48]
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (dmem_enable & _store_misaligned_T & ~reset & ~(~io_addr[0])) begin
          $fwrite(32'h80000002,"Assertion failed\n    at loadstore.scala:74 assert(addressLastTwo(0) === 0.U)\n"); // @[loadstore.scala 74:15]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (dmem_enable & _store_misaligned_T & ~reset & ~(~io_addr[0])) begin
          $fatal; // @[loadstore.scala 74:15]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_5 & ~(~load_misaligned)) begin
          $fwrite(32'h80000002,
            "Assertion failed: Load misaligned\n    at loadstore.scala:217 assert(!load_misaligned, \"Load misaligned\")\n"
            ); // @[loadstore.scala 217:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_5 & ~(~load_misaligned)) begin
          $fatal; // @[loadstore.scala 217:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_5 & ~(~load_fault)) begin
          $fwrite(32'h80000002,
            "Assertion failed: Load fault\n    at loadstore.scala:218 assert(!load_fault, \"Load fault\")\n"); // @[loadstore.scala 218:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_5 & ~(~load_fault)) begin
          $fatal; // @[loadstore.scala 218:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_5 & ~_write_T_1) begin
          $fwrite(32'h80000002,
            "Assertion failed: Store misaligned\n    at loadstore.scala:219 assert(!store_misaligned, \"Store misaligned\")\n"
            ); // @[loadstore.scala 219:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_5 & ~_write_T_1) begin
          $fatal; // @[loadstore.scala 219:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_5 & ~_write_T_3) begin
          $fwrite(32'h80000002,
            "Assertion failed: Store fault\n    at loadstore.scala:220 assert(!store_fault, \"Store fault\")\n"); // @[loadstore.scala 220:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_5 & ~_write_T_3) begin
          $fatal; // @[loadstore.scala 220:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  addr_byte_reg = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  mem_type_reg = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  dmem_op_reg = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  imem_op_reg = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Lock(
  input        clock,
  input        reset,
  input        io_valid,
  input  [1:0] io_tid,
  input        io_acquire,
  output       io_grant
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg  regLocked; // @[lock.scala 31:26]
  reg [1:0] regOwner; // @[lock.scala 32:25]
  wire  _T = ~regLocked; // @[lock.scala 38:12]
  wire  _GEN_0 = ~regLocked | regLocked; // @[lock.scala 38:24 39:19 31:26]
  wire  _T_2 = ~reset; // @[lock.scala 46:13]
  wire  _T_4 = io_tid == regOwner; // @[lock.scala 47:20]
  wire  _GEN_8 = io_acquire ? _T : _T_4; // @[lock.scala 36:22]
  wire  _GEN_13 = io_valid & ~io_acquire; // @[lock.scala 46:13]
  assign io_grant = io_valid & _GEN_8; // @[lock.scala 22:11 35:18]
  always @(posedge clock) begin
    if (reset) begin // @[lock.scala 31:26]
      regLocked <= 1'h0; // @[lock.scala 31:26]
    end else if (io_valid) begin // @[lock.scala 35:18]
      if (io_acquire) begin // @[lock.scala 36:22]
        regLocked <= _GEN_0;
      end else if (io_tid == regOwner) begin // @[lock.scala 47:34]
        regLocked <= 1'h0; // @[lock.scala 48:19]
      end
    end
    if (reset) begin // @[lock.scala 32:25]
      regOwner <= 2'h0; // @[lock.scala 32:25]
    end else if (io_valid) begin // @[lock.scala 35:18]
      if (io_acquire) begin // @[lock.scala 36:22]
        if (~regLocked) begin // @[lock.scala 38:24]
          regOwner <= io_tid; // @[lock.scala 40:18]
        end
      end else if (io_tid == regOwner) begin // @[lock.scala 47:34]
        regOwner <= 2'h0; // @[lock.scala 49:18]
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (io_valid & ~io_acquire & ~reset & _T) begin
          $fwrite(32'h80000002,
            "Assertion failed: thread %d tried to release unlocked lock\n    at lock.scala:46 assert(regLocked, \"thread %%%%d tried to release unlocked lock\", io.tid)\n"
            ,io_tid); // @[lock.scala 46:13]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (io_valid & ~io_acquire & ~reset & _T) begin
          $fatal; // @[lock.scala 46:13]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_13 & ~_T_4 & _T_2) begin
          $fwrite(32'h80000002,
            "Assertion failed: thread-%d tried to release locked owned by %d\n    at lock.scala:53 assert(false.B, \"thread-%%%%d tried to release locked owned by %%%%d\", io.tid, regOwner)\n"
            ,io_tid,regOwner); // @[lock.scala 53:15]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_GEN_13 & ~_T_4 & _T_2) begin
          $fatal; // @[lock.scala 53:15]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regLocked = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regOwner = _RAND_1[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module CSR(
  input         clock,
  input         reset,
  input  [11:0] io_rw_addr,
  input  [1:0]  io_rw_thread,
  input  [1:0]  io_rw_csr_type,
  input         io_rw_write,
  input  [31:0] io_rw_data_in,
  output [31:0] io_rw_data_out,
  output [1:0]  io_tmodes_0,
  output [1:0]  io_tmodes_1,
  output [1:0]  io_tmodes_2,
  output [1:0]  io_tmodes_3,
  input         io_kill,
  input         io_exception,
  input  [31:0] io_epc,
  input  [4:0]  io_cause,
  output [31:0] io_evecs_0,
  output [31:0] io_evecs_1,
  output [31:0] io_evecs_2,
  output [31:0] io_evecs_3,
  output [31:0] io_mepcs_0,
  output [31:0] io_mepcs_1,
  output [31:0] io_mepcs_2,
  output [31:0] io_mepcs_3,
  input         io_sleep_du,
  input         io_sleep_wu,
  input         io_ie,
  input         io_ee,
  output        io_expire_du_0,
  output        io_expire_du_1,
  output        io_expire_du_2,
  output        io_expire_du_3,
  output        io_expire_ie_0,
  output        io_expire_ie_1,
  output        io_expire_ie_2,
  output        io_expire_ie_3,
  output        io_expire_ee_0,
  output        io_expire_ee_1,
  output        io_expire_ee_2,
  output        io_expire_ee_3,
  output        io_timer_expire_du_wu_0,
  output        io_timer_expire_du_wu_1,
  output        io_timer_expire_du_wu_2,
  output        io_timer_expire_du_wu_3,
  input  [1:0]  io_if_tid,
  input         io_mret,
  input         io_gpio_in_3,
  input         io_gpio_in_2,
  input         io_gpio_in_1,
  input         io_gpio_in_0,
  output [1:0]  io_gpio_out_3,
  output [1:0]  io_gpio_out_2,
  output [1:0]  io_gpio_out_1,
  output [1:0]  io_gpio_out_0,
  input         io_int_exts_0,
  input         io_int_exts_1,
  input         io_int_exts_2,
  input         io_int_exts_3,
  output [3:0]  io_imem_protection_0,
  output [3:0]  io_imem_protection_1,
  output [3:0]  io_imem_protection_2,
  output [3:0]  io_imem_protection_3,
  output [3:0]  io_imem_protection_4,
  output [3:0]  io_imem_protection_5,
  output [3:0]  io_imem_protection_6,
  output [3:0]  io_imem_protection_7,
  output [3:0]  io_dmem_protection_0,
  output [3:0]  io_dmem_protection_1,
  output [3:0]  io_dmem_protection_2,
  output [3:0]  io_dmem_protection_3,
  output [3:0]  io_dmem_protection_4,
  output [3:0]  io_dmem_protection_5,
  output [3:0]  io_dmem_protection_6,
  output [3:0]  io_dmem_protection_7,
  input         io_cycle,
  input         io_instret,
  output        io_int_ext
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [63:0] _RAND_24;
  reg [63:0] _RAND_25;
  reg [63:0] _RAND_26;
  reg [63:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
  reg [31:0] _RAND_38;
  reg [31:0] _RAND_39;
  reg [31:0] _RAND_40;
  reg [31:0] _RAND_41;
  reg [31:0] _RAND_42;
  reg [31:0] _RAND_43;
  reg [31:0] _RAND_44;
  reg [31:0] _RAND_45;
  reg [31:0] _RAND_46;
  reg [31:0] _RAND_47;
  reg [31:0] _RAND_48;
  reg [31:0] _RAND_49;
  reg [31:0] _RAND_50;
  reg [31:0] _RAND_51;
  reg [31:0] _RAND_52;
  reg [31:0] _RAND_53;
  reg [31:0] _RAND_54;
  reg [31:0] _RAND_55;
  reg [31:0] _RAND_56;
  reg [31:0] _RAND_57;
  reg [31:0] _RAND_58;
  reg [31:0] _RAND_59;
  reg [63:0] _RAND_60;
  reg [63:0] _RAND_61;
  reg [63:0] _RAND_62;
  reg [63:0] _RAND_63;
  reg [63:0] _RAND_64;
  reg [63:0] _RAND_65;
  reg [63:0] _RAND_66;
  reg [63:0] _RAND_67;
  reg [31:0] _RAND_68;
  reg [31:0] _RAND_69;
  reg [31:0] _RAND_70;
  reg [31:0] _RAND_71;
  reg [31:0] _RAND_72;
  reg [31:0] _RAND_73;
  reg [31:0] _RAND_74;
  reg [31:0] _RAND_75;
  reg [31:0] _RAND_76;
  reg [31:0] _RAND_77;
  reg [31:0] _RAND_78;
  reg [31:0] _RAND_79;
  reg [31:0] _RAND_80;
  reg [31:0] _RAND_81;
  reg [31:0] _RAND_82;
  reg [31:0] _RAND_83;
  reg [63:0] _RAND_84;
  reg [31:0] _RAND_85;
  reg [31:0] _RAND_86;
  reg [31:0] _RAND_87;
  reg [31:0] _RAND_88;
  reg [31:0] _RAND_89;
  reg [31:0] _RAND_90;
  reg [31:0] _RAND_91;
  reg [31:0] _RAND_92;
  reg [31:0] _RAND_93;
  reg [31:0] _RAND_94;
  reg [31:0] _RAND_95;
  reg [31:0] _RAND_96;
  reg [31:0] _RAND_97;
  reg [31:0] _RAND_98;
  reg [31:0] _RAND_99;
  reg [31:0] _RAND_100;
`endif // RANDOMIZE_REG_INIT
  wire  Lock_clock; // @[CSR.scala 360:22]
  wire  Lock_reset; // @[CSR.scala 360:22]
  wire  Lock_io_valid; // @[CSR.scala 360:22]
  wire [1:0] Lock_io_tid; // @[CSR.scala 360:22]
  wire  Lock_io_acquire; // @[CSR.scala 360:22]
  wire  Lock_io_grant; // @[CSR.scala 360:22]
  reg [3:0] reg_slots_0; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_1; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_2; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_3; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_4; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_5; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_6; // @[CSR.scala 75:26]
  reg [3:0] reg_slots_7; // @[CSR.scala 75:26]
  reg [1:0] reg_tmodes_0; // @[CSR.scala 76:27]
  reg [1:0] reg_tmodes_1; // @[CSR.scala 76:27]
  reg [1:0] reg_tmodes_2; // @[CSR.scala 76:27]
  reg [1:0] reg_tmodes_3; // @[CSR.scala 76:27]
  reg [35:0] reg_evecs_0; // @[CSR.scala 78:22]
  reg [35:0] reg_evecs_1; // @[CSR.scala 78:22]
  reg [35:0] reg_evecs_2; // @[CSR.scala 78:22]
  reg [35:0] reg_evecs_3; // @[CSR.scala 78:22]
  reg [31:0] reg_mepcs_0; // @[CSR.scala 79:22]
  reg [31:0] reg_mepcs_1; // @[CSR.scala 79:22]
  reg [31:0] reg_mepcs_2; // @[CSR.scala 79:22]
  reg [31:0] reg_mepcs_3; // @[CSR.scala 79:22]
  reg [4:0] reg_causes_0; // @[CSR.scala 81:23]
  reg [4:0] reg_causes_1; // @[CSR.scala 81:23]
  reg [4:0] reg_causes_2; // @[CSR.scala 81:23]
  reg [4:0] reg_causes_3; // @[CSR.scala 81:23]
  reg [35:0] reg_sup0_0; // @[CSR.scala 82:21]
  reg [35:0] reg_sup0_1; // @[CSR.scala 82:21]
  reg [35:0] reg_sup0_2; // @[CSR.scala 82:21]
  reg [35:0] reg_sup0_3; // @[CSR.scala 82:21]
  reg [31:0] regs_to_host_0; // @[CSR.scala 85:29]
  reg [31:0] regs_to_host_1; // @[CSR.scala 85:29]
  reg [31:0] regs_to_host_2; // @[CSR.scala 85:29]
  reg [31:0] regs_to_host_3; // @[CSR.scala 85:29]
  reg  reg_gpis_0; // @[CSR.scala 86:59]
  reg  reg_gpis_1; // @[CSR.scala 86:59]
  reg  reg_gpis_2; // @[CSR.scala 86:59]
  reg  reg_gpis_3; // @[CSR.scala 86:59]
  reg [1:0] reg_gpos_0; // @[CSR.scala 87:63]
  reg [1:0] reg_gpos_1; // @[CSR.scala 87:63]
  reg [1:0] reg_gpos_2; // @[CSR.scala 87:63]
  reg [1:0] reg_gpos_3; // @[CSR.scala 87:63]
  reg [3:0] reg_gpo_protection_0; // @[CSR.scala 89:35]
  reg [3:0] reg_gpo_protection_1; // @[CSR.scala 89:35]
  reg [3:0] reg_gpo_protection_2; // @[CSR.scala 89:35]
  reg [3:0] reg_gpo_protection_3; // @[CSR.scala 89:35]
  reg [3:0] reg_imem_protection_0; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_1; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_2; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_3; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_4; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_5; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_6; // @[CSR.scala 90:36]
  reg [3:0] reg_imem_protection_7; // @[CSR.scala 90:36]
  reg [3:0] reg_dmem_protection_0; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_1; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_2; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_3; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_4; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_5; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_6; // @[CSR.scala 91:36]
  reg [3:0] reg_dmem_protection_7; // @[CSR.scala 91:36]
  reg [63:0] reg_cycle_0; // @[CSR.scala 93:22]
  reg [63:0] reg_cycle_1; // @[CSR.scala 93:22]
  reg [63:0] reg_cycle_2; // @[CSR.scala 93:22]
  reg [63:0] reg_cycle_3; // @[CSR.scala 93:22]
  reg [63:0] reg_instret_0; // @[CSR.scala 94:24]
  reg [63:0] reg_instret_1; // @[CSR.scala 94:24]
  reg [63:0] reg_instret_2; // @[CSR.scala 94:24]
  reg [63:0] reg_instret_3; // @[CSR.scala 94:24]
  reg  reg_mtie_0; // @[CSR.scala 96:25]
  reg  reg_mtie_1; // @[CSR.scala 96:25]
  reg  reg_mtie_2; // @[CSR.scala 96:25]
  reg  reg_mtie_3; // @[CSR.scala 96:25]
  reg  reg_ie_0; // @[CSR.scala 100:23]
  reg  reg_ie_1; // @[CSR.scala 100:23]
  reg  reg_ie_2; // @[CSR.scala 100:23]
  reg  reg_ie_3; // @[CSR.scala 100:23]
  reg  reg_msip_0; // @[CSR.scala 101:25]
  reg  reg_msip_1; // @[CSR.scala 101:25]
  reg  reg_msip_2; // @[CSR.scala 101:25]
  reg  reg_msip_3; // @[CSR.scala 101:25]
  reg  reg_in_interrupt_0; // @[CSR.scala 102:33]
  reg  reg_in_interrupt_1; // @[CSR.scala 102:33]
  reg  reg_in_interrupt_2; // @[CSR.scala 102:33]
  reg  reg_in_interrupt_3; // @[CSR.scala 102:33]
  reg [63:0] reg_time; // @[CSR.scala 105:25]
  reg [31:0] reg_compare_du_wu_0; // @[CSR.scala 106:30]
  reg [31:0] reg_compare_du_wu_1; // @[CSR.scala 106:30]
  reg [31:0] reg_compare_du_wu_2; // @[CSR.scala 106:30]
  reg [31:0] reg_compare_du_wu_3; // @[CSR.scala 106:30]
  reg [31:0] reg_compare_ie_ee_0; // @[CSR.scala 107:30]
  reg [31:0] reg_compare_ie_ee_1; // @[CSR.scala 107:30]
  reg [31:0] reg_compare_ie_ee_2; // @[CSR.scala 107:30]
  reg [31:0] reg_compare_ie_ee_3; // @[CSR.scala 107:30]
  reg [2:0] reg_compare_du_wu_type_0; // @[CSR.scala 110:39]
  reg [2:0] reg_compare_du_wu_type_1; // @[CSR.scala 110:39]
  reg [2:0] reg_compare_du_wu_type_2; // @[CSR.scala 110:39]
  reg [2:0] reg_compare_du_wu_type_3; // @[CSR.scala 110:39]
  reg [2:0] reg_compare_ie_ee_type_0; // @[CSR.scala 113:39]
  reg [2:0] reg_compare_ie_ee_type_1; // @[CSR.scala 113:39]
  reg [2:0] reg_compare_ie_ee_type_2; // @[CSR.scala 113:39]
  reg [2:0] reg_compare_ie_ee_type_3; // @[CSR.scala 113:39]
  wire [35:0] status_0 = {5'h10,reg_mtie_0,23'h0,2'h3,reg_ie_0,reg_msip_0,reg_in_interrupt_0,2'h0}; // @[Cat.scala 33:92]
  wire [35:0] status_1 = {5'h10,reg_mtie_1,23'h0,2'h3,reg_ie_1,reg_msip_1,reg_in_interrupt_1,2'h0}; // @[Cat.scala 33:92]
  wire [35:0] status_2 = {5'h10,reg_mtie_2,23'h0,2'h3,reg_ie_2,reg_msip_2,reg_in_interrupt_2,2'h0}; // @[Cat.scala 33:92]
  wire [35:0] status_3 = {5'h10,reg_mtie_3,23'h0,2'h3,reg_ie_3,reg_msip_3,reg_in_interrupt_3,2'h0}; // @[Cat.scala 33:92]
  wire  write = io_rw_write & ~io_kill; // @[CSR.scala 163:42]
  wire  _T_74 = io_rw_addr == 12'h520; // @[CSR.scala 126:16]
  wire  _T_75 = write & _T_74; // @[CSR.scala 363:17]
  wire  _T_72 = io_rw_addr == 12'h510; // @[CSR.scala 126:16]
  wire  _T_71 = io_rw_addr == 12'h50a; // @[CSR.scala 126:16]
  wire [35:0] _GEN_258 = 2'h1 == io_rw_thread ? status_1 : status_0; // @[CSR.scala 332:{14,14}]
  wire [35:0] _GEN_259 = 2'h2 == io_rw_thread ? status_2 : _GEN_258; // @[CSR.scala 332:{14,14}]
  wire [35:0] _GEN_260 = 2'h3 == io_rw_thread ? status_3 : _GEN_259; // @[CSR.scala 332:{14,14}]
  wire  _T_70 = io_rw_addr == 12'hc82; // @[CSR.scala 126:16]
  wire [63:0] _GEN_250 = 2'h1 == io_rw_thread ? reg_instret_1 : reg_instret_0; // @[CSR.scala 319:{44,44}]
  wire [63:0] _GEN_251 = 2'h2 == io_rw_thread ? reg_instret_2 : _GEN_250; // @[CSR.scala 319:{44,44}]
  wire [63:0] _GEN_252 = 2'h3 == io_rw_thread ? reg_instret_3 : _GEN_251; // @[CSR.scala 319:{44,44}]
  wire  _T_69 = io_rw_addr == 12'hc80; // @[CSR.scala 126:16]
  wire [63:0] _GEN_245 = 2'h1 == io_rw_thread ? reg_cycle_1 : reg_cycle_0; // @[CSR.scala 316:{42,42}]
  wire [63:0] _GEN_246 = 2'h2 == io_rw_thread ? reg_cycle_2 : _GEN_245; // @[CSR.scala 316:{42,42}]
  wire [63:0] _GEN_247 = 2'h3 == io_rw_thread ? reg_cycle_3 : _GEN_246; // @[CSR.scala 316:{42,42}]
  wire  _T_68 = io_rw_addr == 12'hc81; // @[CSR.scala 126:16]
  wire  _T_67 = io_rw_addr == 12'hc02; // @[CSR.scala 126:16]
  wire  _T_66 = io_rw_addr == 12'hc00; // @[CSR.scala 126:16]
  wire  _T_65 = io_rw_addr == 12'hc01; // @[CSR.scala 126:16]
  wire  _T_64 = io_rw_addr == 12'h50c; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_18 = {reg_dmem_protection_7,reg_dmem_protection_6,reg_dmem_protection_5,reg_dmem_protection_4,
    reg_dmem_protection_3,reg_dmem_protection_2,reg_dmem_protection_1,reg_dmem_protection_0}; // @[CSR.scala 308:39]
  wire  _T_63 = io_rw_addr == 12'h505; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_17 = {reg_imem_protection_7,reg_imem_protection_6,reg_imem_protection_5,reg_imem_protection_4,
    reg_imem_protection_3,reg_imem_protection_2,reg_imem_protection_1,reg_imem_protection_0}; // @[CSR.scala 305:39]
  wire  _T_62 = io_rw_addr == 12'h50d; // @[CSR.scala 126:16]
  wire [15:0] _data_out_T_16 = {reg_gpo_protection_3,reg_gpo_protection_2,reg_gpo_protection_1,reg_gpo_protection_0}; // @[CSR.scala 300:38]
  wire  _T_61 = io_rw_addr == 12'hcc7; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_15 = {30'h0,reg_gpos_3}; // @[Cat.scala 33:92]
  wire  _T_60 = io_rw_addr == 12'hcc6; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_14 = {30'h0,reg_gpos_2}; // @[Cat.scala 33:92]
  wire  _T_59 = io_rw_addr == 12'hcc5; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_13 = {30'h0,reg_gpos_1}; // @[Cat.scala 33:92]
  wire  _T_58 = io_rw_addr == 12'hcc4; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_12 = {30'h0,reg_gpos_0}; // @[Cat.scala 33:92]
  wire  _T_57 = io_rw_addr == 12'hcc3; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_11 = {31'h0,reg_gpis_3}; // @[Cat.scala 33:92]
  wire  _T_56 = io_rw_addr == 12'hcc2; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_10 = {31'h0,reg_gpis_2}; // @[Cat.scala 33:92]
  wire  _T_55 = io_rw_addr == 12'hcc1; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_9 = {31'h0,reg_gpis_1}; // @[Cat.scala 33:92]
  wire  _T_54 = io_rw_addr == 12'hcc0; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_8 = {31'h0,reg_gpis_0}; // @[Cat.scala 33:92]
  wire  _T_53 = io_rw_addr == 12'h533; // @[CSR.scala 126:16]
  wire  _T_52 = io_rw_addr == 12'h532; // @[CSR.scala 126:16]
  wire  _T_51 = io_rw_addr == 12'h531; // @[CSR.scala 126:16]
  wire  _T_50 = io_rw_addr == 12'h530; // @[CSR.scala 126:16]
  wire  _T_49 = io_rw_addr == 12'h1; // @[CSR.scala 126:16]
  wire  _T_48 = io_rw_addr == 12'h500; // @[CSR.scala 126:16]
  wire [35:0] _GEN_223 = 2'h1 == io_rw_thread ? reg_sup0_1 : reg_sup0_0; // @[CSR.scala 274:{16,16}]
  wire [35:0] _GEN_224 = 2'h2 == io_rw_thread ? reg_sup0_2 : _GEN_223; // @[CSR.scala 274:{16,16}]
  wire [35:0] _GEN_225 = 2'h3 == io_rw_thread ? reg_sup0_3 : _GEN_224; // @[CSR.scala 274:{16,16}]
  wire  _T_47 = io_rw_addr == 12'h509; // @[CSR.scala 126:16]
  wire [4:0] _GEN_218 = 2'h1 == io_rw_thread ? reg_causes_1 : reg_causes_0; // @[CSR.scala 271:{47,47}]
  wire [4:0] _GEN_219 = 2'h2 == io_rw_thread ? reg_causes_2 : _GEN_218; // @[CSR.scala 271:{47,47}]
  wire [4:0] _GEN_220 = 2'h3 == io_rw_thread ? reg_causes_3 : _GEN_219; // @[CSR.scala 271:{47,47}]
  wire [31:0] _data_out_T_6 = {_GEN_220[4],27'h0,_GEN_220[3:0]}; // @[Cat.scala 33:92]
  wire  _T_46 = io_rw_addr == 12'h511; // @[CSR.scala 126:16]
  wire [31:0] _GEN_213 = 2'h1 == io_rw_thread ? reg_mepcs_1 : reg_mepcs_0; // @[CSR.scala 268:{16,16}]
  wire [31:0] _GEN_214 = 2'h2 == io_rw_thread ? reg_mepcs_2 : _GEN_213; // @[CSR.scala 268:{16,16}]
  wire [31:0] _GEN_215 = 2'h3 == io_rw_thread ? reg_mepcs_3 : _GEN_214; // @[CSR.scala 268:{16,16}]
  wire  _T_45 = io_rw_addr == 12'h508; // @[CSR.scala 126:16]
  wire [35:0] _GEN_208 = 2'h1 == io_rw_thread ? reg_evecs_1 : reg_evecs_0; // @[CSR.scala 265:{16,16}]
  wire [35:0] _GEN_209 = 2'h2 == io_rw_thread ? reg_evecs_2 : _GEN_208; // @[CSR.scala 265:{16,16}]
  wire [35:0] _GEN_210 = 2'h3 == io_rw_thread ? reg_evecs_3 : _GEN_209; // @[CSR.scala 265:{16,16}]
  wire  _T_44 = io_rw_addr == 12'h504; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_3 = {24'h0,reg_tmodes_3,reg_tmodes_2,reg_tmodes_1,reg_tmodes_0}; // @[Cat.scala 33:92]
  wire  _T_43 = io_rw_addr == 12'h50b; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T_1 = {30'h0,io_rw_thread}; // @[Cat.scala 33:92]
  wire  _T_42 = io_rw_addr == 12'h503; // @[CSR.scala 126:16]
  wire [31:0] _data_out_T = {reg_slots_7,reg_slots_6,reg_slots_5,reg_slots_4,reg_slots_3,reg_slots_2,reg_slots_1,
    reg_slots_0}; // @[CSR.scala 254:29]
  wire [31:0] _GEN_204 = _T_42 ? _data_out_T : 32'h0; // @[CSR.scala 251:12 253:36 254:16]
  wire [31:0] _GEN_205 = _T_43 ? _data_out_T_1 : _GEN_204; // @[CSR.scala 256:37 257:16]
  wire [31:0] _GEN_206 = _T_44 ? _data_out_T_3 : _GEN_205; // @[CSR.scala 260:35 261:14]
  wire [35:0] _GEN_211 = _T_45 ? _GEN_210 : {{4'd0}, _GEN_206}; // @[CSR.scala 264:35 265:16]
  wire [35:0] _GEN_216 = _T_46 ? {{4'd0}, _GEN_215} : _GEN_211; // @[CSR.scala 267:35 268:16]
  wire [35:0] _GEN_221 = _T_47 ? {{4'd0}, _data_out_T_6} : _GEN_216; // @[CSR.scala 270:36 271:16]
  wire [35:0] _GEN_226 = _T_48 ? _GEN_225 : _GEN_221; // @[CSR.scala 273:35 274:16]
  wire [35:0] _GEN_227 = _T_49 ? {{4'd0}, reg_time[31:0]} : _GEN_226; // @[CSR.scala 278:36 279:16]
  wire [35:0] _GEN_228 = _T_50 ? {{4'd0}, regs_to_host_0} : _GEN_227; // @[CSR.scala 283:44 284:16]
  wire [35:0] _GEN_229 = _T_51 ? {{4'd0}, regs_to_host_1} : _GEN_228; // @[CSR.scala 283:44 284:16]
  wire [35:0] _GEN_230 = _T_52 ? {{4'd0}, regs_to_host_2} : _GEN_229; // @[CSR.scala 283:44 284:16]
  wire [35:0] _GEN_231 = _T_53 ? {{4'd0}, regs_to_host_3} : _GEN_230; // @[CSR.scala 283:44 284:16]
  wire [35:0] _GEN_232 = _T_54 ? {{4'd0}, _data_out_T_8} : _GEN_231; // @[CSR.scala 288:42 289:16]
  wire [35:0] _GEN_233 = _T_55 ? {{4'd0}, _data_out_T_9} : _GEN_232; // @[CSR.scala 288:42 289:16]
  wire [35:0] _GEN_234 = _T_56 ? {{4'd0}, _data_out_T_10} : _GEN_233; // @[CSR.scala 288:42 289:16]
  wire [35:0] _GEN_235 = _T_57 ? {{4'd0}, _data_out_T_11} : _GEN_234; // @[CSR.scala 288:42 289:16]
  wire [35:0] _GEN_236 = _T_58 ? {{4'd0}, _data_out_T_12} : _GEN_235; // @[CSR.scala 293:42 294:16]
  wire [35:0] _GEN_237 = _T_59 ? {{4'd0}, _data_out_T_13} : _GEN_236; // @[CSR.scala 293:42 294:16]
  wire [35:0] _GEN_238 = _T_60 ? {{4'd0}, _data_out_T_14} : _GEN_237; // @[CSR.scala 293:42 294:16]
  wire [35:0] _GEN_239 = _T_61 ? {{4'd0}, _data_out_T_15} : _GEN_238; // @[CSR.scala 293:42 294:16]
  wire [35:0] _GEN_240 = _T_62 ? {{20'd0}, _data_out_T_16} : _GEN_239; // @[CSR.scala 299:44 300:16]
  wire [35:0] _GEN_241 = _T_63 ? {{4'd0}, _data_out_T_17} : _GEN_240; // @[CSR.scala 304:45 305:16]
  wire [35:0] _GEN_242 = _T_64 ? {{4'd0}, _data_out_T_18} : _GEN_241; // @[CSR.scala 307:45 308:16]
  wire [35:0] _GEN_243 = _T_65 ? {{4'd0}, reg_time[31:0]} : _GEN_242; // @[CSR.scala 312:35 313:16]
  wire [35:0] _GEN_248 = _T_66 ? {{4'd0}, _GEN_247[31:0]} : _GEN_243; // @[CSR.scala 315:36 316:16]
  wire [35:0] _GEN_253 = _T_67 ? {{4'd0}, _GEN_252[31:0]} : _GEN_248; // @[CSR.scala 318:38 319:16]
  wire [35:0] _GEN_254 = _T_68 ? {{4'd0}, reg_time[63:32]} : _GEN_253; // @[CSR.scala 321:36 322:16]
  wire [35:0] _GEN_255 = _T_69 ? {{4'd0}, _GEN_247[63:32]} : _GEN_254; // @[CSR.scala 324:37 325:16]
  wire [35:0] _GEN_256 = _T_70 ? {{4'd0}, _GEN_252[63:32]} : _GEN_255; // @[CSR.scala 327:39 328:16]
  wire [35:0] _GEN_261 = _T_71 ? _GEN_260 : _GEN_256; // @[CSR.scala 331:35 332:14]
  wire [35:0] _GEN_262 = _T_72 ? 36'h0 : _GEN_261; // @[CSR.scala 335:36 336:14]
  wire [35:0] data_out = write & _T_74 ? {{35'd0}, Lock_io_grant} : _GEN_262; // @[CSR.scala 363:47 366:16]
  wire [35:0] _GEN_586 = {{4'd0}, io_rw_data_in}; // @[CSR.scala 132:24]
  wire [35:0] _data_in_T = data_out | _GEN_586; // @[CSR.scala 132:24]
  wire [31:0] _data_in_T_1 = ~io_rw_data_in; // @[CSR.scala 133:26]
  wire [35:0] _GEN_587 = {{4'd0}, _data_in_T_1}; // @[CSR.scala 133:24]
  wire [35:0] _data_in_T_2 = data_out & _GEN_587; // @[CSR.scala 133:24]
  wire [35:0] _data_in_T_4 = 2'h2 == io_rw_csr_type ? _data_in_T : {{4'd0}, io_rw_data_in}; // @[Mux.scala 81:58]
  wire [35:0] _data_in_T_6 = 2'h3 == io_rw_csr_type ? _data_in_T_2 : _data_in_T_4; // @[Mux.scala 81:58]
  wire [35:0] data_in = 2'h1 == io_rw_csr_type ? {{4'd0}, io_rw_data_in} : _data_in_T_6; // @[Mux.scala 81:58]
  wire [1:0] _GEN_8 = _T_44 ? data_in[1:0] : reg_tmodes_0; // @[CSR.scala 170:37 172:15 76:27]
  wire [1:0] _GEN_9 = _T_44 ? data_in[3:2] : reg_tmodes_1; // @[CSR.scala 170:37 172:15 76:27]
  wire [1:0] _GEN_10 = _T_44 ? data_in[5:4] : reg_tmodes_2; // @[CSR.scala 170:37 172:15 76:27]
  wire [1:0] _GEN_11 = _T_44 ? data_in[7:6] : reg_tmodes_3; // @[CSR.scala 170:37 172:15 76:27]
  wire  _T_4 = io_rw_addr == 12'h521; // @[CSR.scala 126:16]
  wire [2:0] _GEN_32 = 2'h0 == io_rw_thread ? 3'h0 : reg_compare_du_wu_type_0; // @[CSR.scala 110:39 188:{46,46}]
  wire [2:0] _GEN_33 = 2'h1 == io_rw_thread ? 3'h0 : reg_compare_du_wu_type_1; // @[CSR.scala 110:39 188:{46,46}]
  wire [2:0] _GEN_34 = 2'h2 == io_rw_thread ? 3'h0 : reg_compare_du_wu_type_2; // @[CSR.scala 110:39 188:{46,46}]
  wire [2:0] _GEN_35 = 2'h3 == io_rw_thread ? 3'h0 : reg_compare_du_wu_type_3; // @[CSR.scala 110:39 188:{46,46}]
  wire [2:0] _GEN_40 = _T_4 ? _GEN_32 : reg_compare_du_wu_type_0; // @[CSR.scala 110:39 186:46]
  wire [2:0] _GEN_41 = _T_4 ? _GEN_33 : reg_compare_du_wu_type_1; // @[CSR.scala 110:39 186:46]
  wire [2:0] _GEN_42 = _T_4 ? _GEN_34 : reg_compare_du_wu_type_2; // @[CSR.scala 110:39 186:46]
  wire [2:0] _GEN_43 = _T_4 ? _GEN_35 : reg_compare_du_wu_type_3; // @[CSR.scala 110:39 186:46]
  wire  _T_5 = io_rw_addr == 12'h522; // @[CSR.scala 126:16]
  wire [2:0] _GEN_48 = 2'h0 == io_rw_thread ? 3'h0 : reg_compare_ie_ee_type_0; // @[CSR.scala 113:39 194:{46,46}]
  wire [2:0] _GEN_49 = 2'h1 == io_rw_thread ? 3'h0 : reg_compare_ie_ee_type_1; // @[CSR.scala 113:39 194:{46,46}]
  wire [2:0] _GEN_50 = 2'h2 == io_rw_thread ? 3'h0 : reg_compare_ie_ee_type_2; // @[CSR.scala 113:39 194:{46,46}]
  wire [2:0] _GEN_51 = 2'h3 == io_rw_thread ? 3'h0 : reg_compare_ie_ee_type_3; // @[CSR.scala 113:39 194:{46,46}]
  wire [2:0] _GEN_56 = _T_5 ? _GEN_48 : reg_compare_ie_ee_type_0; // @[CSR.scala 113:39 192:46]
  wire [2:0] _GEN_57 = _T_5 ? _GEN_49 : reg_compare_ie_ee_type_1; // @[CSR.scala 113:39 192:46]
  wire [2:0] _GEN_58 = _T_5 ? _GEN_50 : reg_compare_ie_ee_type_2; // @[CSR.scala 113:39 192:46]
  wire [2:0] _GEN_59 = _T_5 ? _GEN_51 : reg_compare_ie_ee_type_3; // @[CSR.scala 113:39 192:46]
  wire [35:0] _GEN_60 = _T_50 ? data_in : {{4'd0}, regs_to_host_0}; // @[CSR.scala 198:46 199:27 85:29]
  wire [35:0] _GEN_61 = _T_51 ? data_in : {{4'd0}, regs_to_host_1}; // @[CSR.scala 198:46 199:27 85:29]
  wire [35:0] _GEN_62 = _T_52 ? data_in : {{4'd0}, regs_to_host_2}; // @[CSR.scala 198:46 199:27 85:29]
  wire [35:0] _GEN_63 = _T_53 ? data_in : {{4'd0}, regs_to_host_3}; // @[CSR.scala 198:46 199:27 85:29]
  wire  _GEN_92 = 2'h0 == io_rw_thread ? data_in[4] : reg_ie_0; // @[CSR.scala 100:23 234:{30,30}]
  wire  _GEN_93 = 2'h1 == io_rw_thread ? data_in[4] : reg_ie_1; // @[CSR.scala 100:23 234:{30,30}]
  wire  _GEN_94 = 2'h2 == io_rw_thread ? data_in[4] : reg_ie_2; // @[CSR.scala 100:23 234:{30,30}]
  wire  _GEN_95 = 2'h3 == io_rw_thread ? data_in[4] : reg_ie_3; // @[CSR.scala 100:23 234:{30,30}]
  wire  _GEN_96 = 2'h0 == io_rw_thread ? data_in[26] : reg_mtie_0; // @[CSR.scala 237:{32,32} 96:25]
  wire  _GEN_97 = 2'h1 == io_rw_thread ? data_in[26] : reg_mtie_1; // @[CSR.scala 237:{32,32} 96:25]
  wire  _GEN_98 = 2'h2 == io_rw_thread ? data_in[26] : reg_mtie_2; // @[CSR.scala 237:{32,32} 96:25]
  wire  _GEN_99 = 2'h3 == io_rw_thread ? data_in[26] : reg_mtie_3; // @[CSR.scala 237:{32,32} 96:25]
  wire  _GEN_100 = 2'h0 == io_rw_thread ? data_in[3] : reg_msip_0; // @[CSR.scala 101:25 240:{32,32}]
  wire  _GEN_101 = 2'h1 == io_rw_thread ? data_in[3] : reg_msip_1; // @[CSR.scala 101:25 240:{32,32}]
  wire  _GEN_102 = 2'h2 == io_rw_thread ? data_in[3] : reg_msip_2; // @[CSR.scala 101:25 240:{32,32}]
  wire  _GEN_103 = 2'h3 == io_rw_thread ? data_in[3] : reg_msip_3; // @[CSR.scala 101:25 240:{32,32}]
  wire  _GEN_104 = 2'h0 == io_rw_thread ? data_in[2] : reg_in_interrupt_0; // @[CSR.scala 102:33 242:{38,38}]
  wire  _GEN_105 = 2'h1 == io_rw_thread ? data_in[2] : reg_in_interrupt_1; // @[CSR.scala 102:33 242:{38,38}]
  wire  _GEN_106 = 2'h2 == io_rw_thread ? data_in[2] : reg_in_interrupt_2; // @[CSR.scala 102:33 242:{38,38}]
  wire  _GEN_107 = 2'h3 == io_rw_thread ? data_in[2] : reg_in_interrupt_3; // @[CSR.scala 102:33 242:{38,38}]
  wire  _GEN_108 = _T_71 ? _GEN_92 : reg_ie_0; // @[CSR.scala 100:23 232:37]
  wire  _GEN_109 = _T_71 ? _GEN_93 : reg_ie_1; // @[CSR.scala 100:23 232:37]
  wire  _GEN_110 = _T_71 ? _GEN_94 : reg_ie_2; // @[CSR.scala 100:23 232:37]
  wire  _GEN_111 = _T_71 ? _GEN_95 : reg_ie_3; // @[CSR.scala 100:23 232:37]
  wire  _GEN_112 = _T_71 ? _GEN_96 : reg_mtie_0; // @[CSR.scala 232:37 96:25]
  wire  _GEN_113 = _T_71 ? _GEN_97 : reg_mtie_1; // @[CSR.scala 232:37 96:25]
  wire  _GEN_114 = _T_71 ? _GEN_98 : reg_mtie_2; // @[CSR.scala 232:37 96:25]
  wire  _GEN_115 = _T_71 ? _GEN_99 : reg_mtie_3; // @[CSR.scala 232:37 96:25]
  wire  _GEN_116 = _T_71 ? _GEN_100 : reg_msip_0; // @[CSR.scala 101:25 232:37]
  wire  _GEN_117 = _T_71 ? _GEN_101 : reg_msip_1; // @[CSR.scala 101:25 232:37]
  wire  _GEN_118 = _T_71 ? _GEN_102 : reg_msip_2; // @[CSR.scala 101:25 232:37]
  wire  _GEN_119 = _T_71 ? _GEN_103 : reg_msip_3; // @[CSR.scala 101:25 232:37]
  wire  _GEN_120 = _T_71 ? _GEN_104 : reg_in_interrupt_0; // @[CSR.scala 102:33 232:37]
  wire  _GEN_121 = _T_71 ? _GEN_105 : reg_in_interrupt_1; // @[CSR.scala 102:33 232:37]
  wire  _GEN_122 = _T_71 ? _GEN_106 : reg_in_interrupt_2; // @[CSR.scala 102:33 232:37]
  wire  _GEN_123 = _T_71 ? _GEN_107 : reg_in_interrupt_3; // @[CSR.scala 102:33 232:37]
  wire [1:0] _GEN_132 = write ? _GEN_8 : reg_tmodes_0; // @[CSR.scala 164:15 76:27]
  wire [1:0] _GEN_133 = write ? _GEN_9 : reg_tmodes_1; // @[CSR.scala 164:15 76:27]
  wire [1:0] _GEN_134 = write ? _GEN_10 : reg_tmodes_2; // @[CSR.scala 164:15 76:27]
  wire [1:0] _GEN_135 = write ? _GEN_11 : reg_tmodes_3; // @[CSR.scala 164:15 76:27]
  wire [2:0] _GEN_148 = write ? _GEN_40 : reg_compare_du_wu_type_0; // @[CSR.scala 164:15 110:39]
  wire [2:0] _GEN_149 = write ? _GEN_41 : reg_compare_du_wu_type_1; // @[CSR.scala 164:15 110:39]
  wire [2:0] _GEN_150 = write ? _GEN_42 : reg_compare_du_wu_type_2; // @[CSR.scala 164:15 110:39]
  wire [2:0] _GEN_151 = write ? _GEN_43 : reg_compare_du_wu_type_3; // @[CSR.scala 164:15 110:39]
  wire [2:0] _GEN_156 = write ? _GEN_56 : reg_compare_ie_ee_type_0; // @[CSR.scala 164:15 113:39]
  wire [2:0] _GEN_157 = write ? _GEN_57 : reg_compare_ie_ee_type_1; // @[CSR.scala 164:15 113:39]
  wire [2:0] _GEN_158 = write ? _GEN_58 : reg_compare_ie_ee_type_2; // @[CSR.scala 164:15 113:39]
  wire [2:0] _GEN_159 = write ? _GEN_59 : reg_compare_ie_ee_type_3; // @[CSR.scala 164:15 113:39]
  wire [35:0] _GEN_160 = write ? _GEN_60 : {{4'd0}, regs_to_host_0}; // @[CSR.scala 164:15 85:29]
  wire [35:0] _GEN_161 = write ? _GEN_61 : {{4'd0}, regs_to_host_1}; // @[CSR.scala 164:15 85:29]
  wire [35:0] _GEN_162 = write ? _GEN_62 : {{4'd0}, regs_to_host_2}; // @[CSR.scala 164:15 85:29]
  wire [35:0] _GEN_163 = write ? _GEN_63 : {{4'd0}, regs_to_host_3}; // @[CSR.scala 164:15 85:29]
  wire  _GEN_188 = write ? _GEN_108 : reg_ie_0; // @[CSR.scala 164:15 100:23]
  wire  _GEN_189 = write ? _GEN_109 : reg_ie_1; // @[CSR.scala 164:15 100:23]
  wire  _GEN_190 = write ? _GEN_110 : reg_ie_2; // @[CSR.scala 164:15 100:23]
  wire  _GEN_191 = write ? _GEN_111 : reg_ie_3; // @[CSR.scala 164:15 100:23]
  wire  _GEN_192 = write ? _GEN_112 : reg_mtie_0; // @[CSR.scala 164:15 96:25]
  wire  _GEN_193 = write ? _GEN_113 : reg_mtie_1; // @[CSR.scala 164:15 96:25]
  wire  _GEN_194 = write ? _GEN_114 : reg_mtie_2; // @[CSR.scala 164:15 96:25]
  wire  _GEN_195 = write ? _GEN_115 : reg_mtie_3; // @[CSR.scala 164:15 96:25]
  wire  _GEN_196 = write ? _GEN_116 : reg_msip_0; // @[CSR.scala 164:15 101:25]
  wire  _GEN_197 = write ? _GEN_117 : reg_msip_1; // @[CSR.scala 164:15 101:25]
  wire  _GEN_198 = write ? _GEN_118 : reg_msip_2; // @[CSR.scala 164:15 101:25]
  wire  _GEN_199 = write ? _GEN_119 : reg_msip_3; // @[CSR.scala 164:15 101:25]
  wire  _GEN_200 = write ? _GEN_120 : reg_in_interrupt_0; // @[CSR.scala 164:15 102:33]
  wire  _GEN_201 = write ? _GEN_121 : reg_in_interrupt_1; // @[CSR.scala 164:15 102:33]
  wire  _GEN_202 = write ? _GEN_122 : reg_in_interrupt_2; // @[CSR.scala 164:15 102:33]
  wire  _GEN_203 = write ? _GEN_123 : reg_in_interrupt_3; // @[CSR.scala 164:15 102:33]
  wire [1:0] _GEN_264 = 2'h1 == io_rw_thread ? reg_tmodes_1 : reg_tmodes_0; // @[CSR.scala 345:{58,58}]
  wire [1:0] _GEN_265 = 2'h2 == io_rw_thread ? reg_tmodes_2 : _GEN_264; // @[CSR.scala 345:{58,58}]
  wire [1:0] _GEN_266 = 2'h3 == io_rw_thread ? reg_tmodes_3 : _GEN_265; // @[CSR.scala 345:{58,58}]
  wire [1:0] _reg_tmodes_T = _GEN_266 | 2'h1; // @[CSR.scala 345:58]
  wire [1:0] _reg_tmodes_0_T_1 = reg_tmodes_0 & 2'h2; // @[CSR.scala 353:42]
  wire  _T_89 = io_rw_thread != 2'h0; // @[CSR.scala 471:27]
  wire [31:0] _reg_compare_expired_du_wu_0_T_2 = reg_time[31:0] - reg_compare_du_wu_0; // @[CSR.scala 460:74]
  wire  reg_compare_expired_du_wu_0 = ~_reg_compare_expired_du_wu_0_T_2[31]; // @[CSR.scala 460:120]
  wire  _GEN_361 = reg_compare_du_wu_type_0 == 3'h1 & reg_compare_expired_du_wu_0; // @[CSR.scala 462:55 463:25 437:28]
  wire  expired_du_0 = io_rw_thread != 2'h0 ? 1'h0 : _GEN_361; // @[CSR.scala 471:38 472:27]
  wire  _GEN_362 = reg_compare_du_wu_type_0 == 3'h2 & reg_compare_expired_du_wu_0; // @[CSR.scala 466:55 467:25 438:28]
  wire  expired_wu_0 = io_rw_thread != 2'h0 ? 1'h0 : _GEN_362; // @[CSR.scala 471:38 473:27]
  wire [2:0] _GEN_378 = 2'h1 == io_rw_thread ? reg_compare_ie_ee_type_1 : reg_compare_ie_ee_type_0; // @[CSR.scala 486:{50,50}]
  wire [2:0] _GEN_379 = 2'h2 == io_rw_thread ? reg_compare_ie_ee_type_2 : _GEN_378; // @[CSR.scala 486:{50,50}]
  wire [2:0] _GEN_380 = 2'h3 == io_rw_thread ? reg_compare_ie_ee_type_3 : _GEN_379; // @[CSR.scala 486:{50,50}]
  wire  _T_109 = _GEN_380 == 3'h3; // @[CSR.scala 490:50]
  wire [31:0] _reg_compare_expired_ie_ee_3_T_2 = reg_time[31:0] - reg_compare_ie_ee_3; // @[CSR.scala 483:74]
  wire  reg_compare_expired_ie_ee_3 = ~_reg_compare_expired_ie_ee_3_T_2[31]; // @[CSR.scala 483:120]
  wire  expired_ie_part_3 = _GEN_380 == 3'h3 & reg_compare_expired_ie_ee_3; // @[CSR.scala 490:64 491:30 443:33]
  wire [31:0] _reg_compare_expired_ie_ee_2_T_2 = reg_time[31:0] - reg_compare_ie_ee_2; // @[CSR.scala 483:74]
  wire  reg_compare_expired_ie_ee_2 = ~_reg_compare_expired_ie_ee_2_T_2[31]; // @[CSR.scala 483:120]
  wire  expired_ie_part_2 = _GEN_380 == 3'h3 & reg_compare_expired_ie_ee_2; // @[CSR.scala 490:64 491:30 443:33]
  wire [31:0] _reg_compare_expired_ie_ee_1_T_2 = reg_time[31:0] - reg_compare_ie_ee_1; // @[CSR.scala 483:74]
  wire  reg_compare_expired_ie_ee_1 = ~_reg_compare_expired_ie_ee_1_T_2[31]; // @[CSR.scala 483:120]
  wire  expired_ie_part_1 = _GEN_380 == 3'h3 & reg_compare_expired_ie_ee_1; // @[CSR.scala 490:64 491:30 443:33]
  wire [31:0] _reg_compare_expired_ie_ee_0_T_2 = reg_time[31:0] - reg_compare_ie_ee_0; // @[CSR.scala 483:74]
  wire  reg_compare_expired_ie_ee_0 = ~_reg_compare_expired_ie_ee_0_T_2[31]; // @[CSR.scala 483:120]
  wire  expired_ie_part_0 = _GEN_380 == 3'h3 & reg_compare_expired_ie_ee_0; // @[CSR.scala 490:64 491:30 443:33]
  wire  _GEN_414 = 2'h1 == io_rw_thread ? expired_ie_part_1 : expired_ie_part_0; // @[CSR.scala 514:{23,23}]
  wire  _GEN_415 = 2'h2 == io_rw_thread ? expired_ie_part_2 : _GEN_414; // @[CSR.scala 514:{23,23}]
  wire  _GEN_416 = 2'h3 == io_rw_thread ? expired_ie_part_3 : _GEN_415; // @[CSR.scala 514:{23,23}]
  wire  _T_110 = io_rw_thread != 2'h3; // @[CSR.scala 495:27]
  wire  _T_108 = _GEN_380 == 3'h4; // @[CSR.scala 486:50]
  wire  _GEN_393 = _GEN_380 == 3'h4 & reg_compare_expired_ie_ee_3; // @[CSR.scala 486:64 487:25 440:28]
  wire  expired_ee_3 = io_rw_thread != 2'h3 ? 1'h0 : _GEN_393; // @[CSR.scala 495:38 497:27]
  wire  _T_107 = io_rw_thread != 2'h2; // @[CSR.scala 495:27]
  wire  _GEN_389 = _GEN_380 == 3'h4 & reg_compare_expired_ie_ee_2; // @[CSR.scala 486:64 487:25 440:28]
  wire  expired_ee_2 = io_rw_thread != 2'h2 ? 1'h0 : _GEN_389; // @[CSR.scala 495:38 497:27]
  wire  _T_104 = io_rw_thread != 2'h1; // @[CSR.scala 495:27]
  wire  _GEN_385 = _GEN_380 == 3'h4 & reg_compare_expired_ie_ee_1; // @[CSR.scala 486:64 487:25 440:28]
  wire  expired_ee_1 = io_rw_thread != 2'h1 ? 1'h0 : _GEN_385; // @[CSR.scala 495:38 497:27]
  wire  _GEN_381 = _GEN_380 == 3'h4 & reg_compare_expired_ie_ee_0; // @[CSR.scala 486:64 487:25 440:28]
  wire  expired_ee_0 = _T_89 ? 1'h0 : _GEN_381; // @[CSR.scala 495:38 497:27]
  wire  _GEN_418 = 2'h1 == io_rw_thread ? expired_ee_1 : expired_ee_0; // @[CSR.scala 514:{56,56}]
  wire  _GEN_419 = 2'h2 == io_rw_thread ? expired_ee_2 : _GEN_418; // @[CSR.scala 514:{56,56}]
  wire  _GEN_420 = 2'h3 == io_rw_thread ? expired_ee_3 : _GEN_419; // @[CSR.scala 514:{56,56}]
  wire  _GEN_421 = 2'h0 == io_rw_thread; // @[CSR.scala 349:15 515:{28,28}]
  wire  _GEN_425 = (io_int_ext | _GEN_416 | _GEN_420) & _GEN_421; // @[CSR.scala 349:15 514:85]
  wire  _GEN_441 = expired_du_0 | expired_wu_0 | _GEN_425; // @[CSR.scala 521:48 522:19]
  wire  wake_0 = io_int_exts_0 | _GEN_441; // @[CSR.scala 567:30 569:19]
  wire [1:0] _reg_tmodes_1_T_1 = reg_tmodes_1 & 2'h2; // @[CSR.scala 353:42]
  wire [31:0] _reg_compare_expired_du_wu_1_T_2 = reg_time[31:0] - reg_compare_du_wu_1; // @[CSR.scala 460:74]
  wire  reg_compare_expired_du_wu_1 = ~_reg_compare_expired_du_wu_1_T_2[31]; // @[CSR.scala 460:120]
  wire  _GEN_365 = reg_compare_du_wu_type_1 == 3'h1 & reg_compare_expired_du_wu_1; // @[CSR.scala 462:55 463:25 437:28]
  wire  expired_du_1 = _T_104 ? 1'h0 : _GEN_365; // @[CSR.scala 471:38 472:27]
  wire  _GEN_366 = reg_compare_du_wu_type_1 == 3'h2 & reg_compare_expired_du_wu_1; // @[CSR.scala 466:55 467:25 438:28]
  wire  expired_wu_1 = _T_104 ? 1'h0 : _GEN_366; // @[CSR.scala 471:38 473:27]
  wire  _GEN_422 = 2'h1 == io_rw_thread; // @[CSR.scala 349:15 515:{28,28}]
  wire  _GEN_426 = (io_int_ext | _GEN_416 | _GEN_420) & _GEN_422; // @[CSR.scala 349:15 514:85]
  wire  _GEN_454 = expired_du_1 | expired_wu_1 | _GEN_426; // @[CSR.scala 521:48 522:19]
  wire  wake_1 = io_int_exts_1 | _GEN_454; // @[CSR.scala 567:30 569:19]
  wire [1:0] _reg_tmodes_2_T_1 = reg_tmodes_2 & 2'h2; // @[CSR.scala 353:42]
  wire [31:0] _reg_compare_expired_du_wu_2_T_2 = reg_time[31:0] - reg_compare_du_wu_2; // @[CSR.scala 460:74]
  wire  reg_compare_expired_du_wu_2 = ~_reg_compare_expired_du_wu_2_T_2[31]; // @[CSR.scala 460:120]
  wire  _GEN_369 = reg_compare_du_wu_type_2 == 3'h1 & reg_compare_expired_du_wu_2; // @[CSR.scala 462:55 463:25 437:28]
  wire  expired_du_2 = _T_107 ? 1'h0 : _GEN_369; // @[CSR.scala 471:38 472:27]
  wire  _GEN_370 = reg_compare_du_wu_type_2 == 3'h2 & reg_compare_expired_du_wu_2; // @[CSR.scala 466:55 467:25 438:28]
  wire  expired_wu_2 = _T_107 ? 1'h0 : _GEN_370; // @[CSR.scala 471:38 473:27]
  wire  _GEN_423 = 2'h2 == io_rw_thread; // @[CSR.scala 349:15 515:{28,28}]
  wire  _GEN_427 = (io_int_ext | _GEN_416 | _GEN_420) & _GEN_423; // @[CSR.scala 349:15 514:85]
  wire  _GEN_467 = expired_du_2 | expired_wu_2 | _GEN_427; // @[CSR.scala 521:48 522:19]
  wire  wake_2 = io_int_exts_2 | _GEN_467; // @[CSR.scala 567:30 569:19]
  wire [1:0] _reg_tmodes_3_T_1 = reg_tmodes_3 & 2'h2; // @[CSR.scala 353:42]
  wire [31:0] _reg_compare_expired_du_wu_3_T_2 = reg_time[31:0] - reg_compare_du_wu_3; // @[CSR.scala 460:74]
  wire  reg_compare_expired_du_wu_3 = ~_reg_compare_expired_du_wu_3_T_2[31]; // @[CSR.scala 460:120]
  wire  _GEN_373 = reg_compare_du_wu_type_3 == 3'h1 & reg_compare_expired_du_wu_3; // @[CSR.scala 462:55 463:25 437:28]
  wire  expired_du_3 = _T_110 ? 1'h0 : _GEN_373; // @[CSR.scala 471:38 472:27]
  wire  _GEN_374 = reg_compare_du_wu_type_3 == 3'h2 & reg_compare_expired_du_wu_3; // @[CSR.scala 466:55 467:25 438:28]
  wire  expired_wu_3 = _T_110 ? 1'h0 : _GEN_374; // @[CSR.scala 471:38 473:27]
  wire  _GEN_424 = 2'h3 == io_rw_thread; // @[CSR.scala 349:15 515:{28,28}]
  wire  _GEN_428 = (io_int_ext | _GEN_416 | _GEN_420) & _GEN_424; // @[CSR.scala 349:15 514:85]
  wire  _GEN_480 = expired_du_3 | expired_wu_3 | _GEN_428; // @[CSR.scala 521:48 522:19]
  wire  wake_3 = io_int_exts_3 | _GEN_480; // @[CSR.scala 567:30 569:19]
  wire  _T_76 = io_rw_data_in == 32'h1; // @[CSR.scala 368:26]
  wire  _T_77 = io_rw_data_in == 32'h0; // @[CSR.scala 372:32]
  wire  _T_79 = ~reset; // @[CSR.scala 376:15]
  wire [2:0] _GEN_286 = 2'h1 == io_rw_thread ? reg_compare_du_wu_type_1 : reg_compare_du_wu_type_0; // @[CSR.scala 388:{50,50}]
  wire [2:0] _GEN_287 = 2'h2 == io_rw_thread ? reg_compare_du_wu_type_2 : _GEN_286; // @[CSR.scala 388:{50,50}]
  wire [2:0] _GEN_288 = 2'h3 == io_rw_thread ? reg_compare_du_wu_type_3 : _GEN_287; // @[CSR.scala 388:{50,50}]
  wire  _T_85 = ~io_mret; // @[CSR.scala 393:15]
  wire [31:0] _reg_mepcs_T_1 = io_epc + 32'h4; // @[CSR.scala 396:45]
  wire [2:0] _GEN_297 = 2'h0 == io_rw_thread ? 3'h0 : _GEN_148; // @[CSR.scala 400:{46,46}]
  wire [2:0] _GEN_298 = 2'h1 == io_rw_thread ? 3'h0 : _GEN_149; // @[CSR.scala 400:{46,46}]
  wire [2:0] _GEN_299 = 2'h2 == io_rw_thread ? 3'h0 : _GEN_150; // @[CSR.scala 400:{46,46}]
  wire [2:0] _GEN_300 = 2'h3 == io_rw_thread ? 3'h0 : _GEN_151; // @[CSR.scala 400:{46,46}]
  wire [2:0] _GEN_313 = _GEN_288 == 3'h2 ? _GEN_297 : _GEN_148; // @[CSR.scala 388:64]
  wire [2:0] _GEN_314 = _GEN_288 == 3'h2 ? _GEN_298 : _GEN_149; // @[CSR.scala 388:64]
  wire [2:0] _GEN_315 = _GEN_288 == 3'h2 ? _GEN_299 : _GEN_150; // @[CSR.scala 388:64]
  wire [2:0] _GEN_316 = _GEN_288 == 3'h2 ? _GEN_300 : _GEN_151; // @[CSR.scala 388:64]
  wire  _GEN_321 = _GEN_421 | _GEN_200; // @[CSR.scala 414:{38,38}]
  wire  _GEN_322 = _GEN_422 | _GEN_201; // @[CSR.scala 414:{38,38}]
  wire  _GEN_323 = _GEN_423 | _GEN_202; // @[CSR.scala 414:{38,38}]
  wire  _GEN_324 = _GEN_424 | _GEN_203; // @[CSR.scala 414:{38,38}]
  wire  _GEN_325 = 2'h0 == io_rw_thread ? 1'h0 : _GEN_196; // @[CSR.scala 417:{30,30}]
  wire  _GEN_326 = 2'h1 == io_rw_thread ? 1'h0 : _GEN_197; // @[CSR.scala 417:{30,30}]
  wire  _GEN_327 = 2'h2 == io_rw_thread ? 1'h0 : _GEN_198; // @[CSR.scala 417:{30,30}]
  wire  _GEN_328 = 2'h3 == io_rw_thread ? 1'h0 : _GEN_199; // @[CSR.scala 417:{30,30}]
  wire  _GEN_333 = io_mret ? _GEN_325 : _GEN_196; // @[CSR.scala 415:27]
  wire  _GEN_334 = io_mret ? _GEN_326 : _GEN_197; // @[CSR.scala 415:27]
  wire  _GEN_335 = io_mret ? _GEN_327 : _GEN_198; // @[CSR.scala 415:27]
  wire  _GEN_336 = io_mret ? _GEN_328 : _GEN_199; // @[CSR.scala 415:27]
  wire [2:0] _GEN_345 = io_exception ? _GEN_313 : _GEN_148; // @[CSR.scala 387:24]
  wire [2:0] _GEN_346 = io_exception ? _GEN_314 : _GEN_149; // @[CSR.scala 387:24]
  wire [2:0] _GEN_347 = io_exception ? _GEN_315 : _GEN_150; // @[CSR.scala 387:24]
  wire [2:0] _GEN_348 = io_exception ? _GEN_316 : _GEN_151; // @[CSR.scala 387:24]
  wire  _GEN_357 = io_exception ? _GEN_196 : _GEN_333; // @[CSR.scala 387:24]
  wire  _GEN_358 = io_exception ? _GEN_197 : _GEN_334; // @[CSR.scala 387:24]
  wire  _GEN_359 = io_exception ? _GEN_198 : _GEN_335; // @[CSR.scala 387:24]
  wire  _GEN_360 = io_exception ? _GEN_199 : _GEN_336; // @[CSR.scala 387:24]
  wire [63:0] _reg_time_T_1 = reg_time + 64'ha; // @[CSR.scala 424:26]
  wire [2:0] _GEN_397 = 2'h0 == io_rw_thread ? 3'h1 : _GEN_345; // @[CSR.scala 507:{44,44}]
  wire [2:0] _GEN_398 = 2'h1 == io_rw_thread ? 3'h1 : _GEN_346; // @[CSR.scala 507:{44,44}]
  wire [2:0] _GEN_399 = 2'h2 == io_rw_thread ? 3'h1 : _GEN_347; // @[CSR.scala 507:{44,44}]
  wire [2:0] _GEN_400 = 2'h3 == io_rw_thread ? 3'h1 : _GEN_348; // @[CSR.scala 507:{44,44}]
  wire [2:0] _GEN_401 = io_sleep_du ? _GEN_397 : _GEN_345; // @[CSR.scala 506:24]
  wire [2:0] _GEN_402 = io_sleep_du ? _GEN_398 : _GEN_346; // @[CSR.scala 506:24]
  wire [2:0] _GEN_403 = io_sleep_du ? _GEN_399 : _GEN_347; // @[CSR.scala 506:24]
  wire [2:0] _GEN_404 = io_sleep_du ? _GEN_400 : _GEN_348; // @[CSR.scala 506:24]
  wire [2:0] _GEN_405 = 2'h0 == io_rw_thread ? 3'h2 : _GEN_401; // @[CSR.scala 510:{44,44}]
  wire [2:0] _GEN_406 = 2'h1 == io_rw_thread ? 3'h2 : _GEN_402; // @[CSR.scala 510:{44,44}]
  wire [2:0] _GEN_407 = 2'h2 == io_rw_thread ? 3'h2 : _GEN_403; // @[CSR.scala 510:{44,44}]
  wire [2:0] _GEN_408 = 2'h3 == io_rw_thread ? 3'h2 : _GEN_404; // @[CSR.scala 510:{44,44}]
  wire [2:0] _GEN_409 = io_sleep_wu ? _GEN_405 : _GEN_401; // @[CSR.scala 509:24]
  wire [2:0] _GEN_410 = io_sleep_wu ? _GEN_406 : _GEN_402; // @[CSR.scala 509:24]
  wire [2:0] _GEN_411 = io_sleep_wu ? _GEN_407 : _GEN_403; // @[CSR.scala 509:24]
  wire [2:0] _GEN_412 = io_sleep_wu ? _GEN_408 : _GEN_404; // @[CSR.scala 509:24]
  wire [1:0] _GEN_430 = 2'h1 == io_if_tid ? reg_tmodes_1 : reg_tmodes_0; // @[CSR.scala 524:{52,52}]
  wire [1:0] _GEN_431 = 2'h2 == io_if_tid ? reg_tmodes_2 : _GEN_430; // @[CSR.scala 524:{52,52}]
  wire [1:0] _GEN_432 = 2'h3 == io_if_tid ? reg_tmodes_3 : _GEN_431; // @[CSR.scala 524:{52,52}]
  wire  thread_active = _GEN_432 == 2'h0 | _GEN_432 == 2'h2; // @[CSR.scala 524:66]
  wire [2:0] _GEN_433 = 2'h0 == io_if_tid ? 3'h0 : _GEN_409; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_434 = 2'h1 == io_if_tid ? 3'h0 : _GEN_410; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_435 = 2'h2 == io_if_tid ? 3'h0 : _GEN_411; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_436 = 2'h3 == io_if_tid ? 3'h0 : _GEN_412; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_437 = thread_active ? _GEN_433 : _GEN_409; // @[CSR.scala 525:30]
  wire [2:0] _GEN_438 = thread_active ? _GEN_434 : _GEN_410; // @[CSR.scala 525:30]
  wire [2:0] _GEN_439 = thread_active ? _GEN_435 : _GEN_411; // @[CSR.scala 525:30]
  wire [2:0] _GEN_440 = thread_active ? _GEN_436 : _GEN_412; // @[CSR.scala 525:30]
  wire [2:0] _GEN_442 = expired_du_0 | expired_wu_0 ? _GEN_437 : _GEN_409; // @[CSR.scala 521:48]
  wire [2:0] _GEN_443 = expired_du_0 | expired_wu_0 ? _GEN_438 : _GEN_410; // @[CSR.scala 521:48]
  wire [2:0] _GEN_444 = expired_du_0 | expired_wu_0 ? _GEN_439 : _GEN_411; // @[CSR.scala 521:48]
  wire [2:0] _GEN_445 = expired_du_0 | expired_wu_0 ? _GEN_440 : _GEN_412; // @[CSR.scala 521:48]
  wire [2:0] _GEN_446 = 2'h0 == io_if_tid ? 3'h0 : _GEN_442; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_447 = 2'h1 == io_if_tid ? 3'h0 : _GEN_443; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_448 = 2'h2 == io_if_tid ? 3'h0 : _GEN_444; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_449 = 2'h3 == io_if_tid ? 3'h0 : _GEN_445; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_450 = thread_active ? _GEN_446 : _GEN_442; // @[CSR.scala 525:30]
  wire [2:0] _GEN_451 = thread_active ? _GEN_447 : _GEN_443; // @[CSR.scala 525:30]
  wire [2:0] _GEN_452 = thread_active ? _GEN_448 : _GEN_444; // @[CSR.scala 525:30]
  wire [2:0] _GEN_453 = thread_active ? _GEN_449 : _GEN_445; // @[CSR.scala 525:30]
  wire [2:0] _GEN_455 = expired_du_1 | expired_wu_1 ? _GEN_450 : _GEN_442; // @[CSR.scala 521:48]
  wire [2:0] _GEN_456 = expired_du_1 | expired_wu_1 ? _GEN_451 : _GEN_443; // @[CSR.scala 521:48]
  wire [2:0] _GEN_457 = expired_du_1 | expired_wu_1 ? _GEN_452 : _GEN_444; // @[CSR.scala 521:48]
  wire [2:0] _GEN_458 = expired_du_1 | expired_wu_1 ? _GEN_453 : _GEN_445; // @[CSR.scala 521:48]
  wire [2:0] _GEN_459 = 2'h0 == io_if_tid ? 3'h0 : _GEN_455; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_460 = 2'h1 == io_if_tid ? 3'h0 : _GEN_456; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_461 = 2'h2 == io_if_tid ? 3'h0 : _GEN_457; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_462 = 2'h3 == io_if_tid ? 3'h0 : _GEN_458; // @[CSR.scala 526:{45,45}]
  wire [2:0] _GEN_463 = thread_active ? _GEN_459 : _GEN_455; // @[CSR.scala 525:30]
  wire [2:0] _GEN_464 = thread_active ? _GEN_460 : _GEN_456; // @[CSR.scala 525:30]
  wire [2:0] _GEN_465 = thread_active ? _GEN_461 : _GEN_457; // @[CSR.scala 525:30]
  wire [2:0] _GEN_466 = thread_active ? _GEN_462 : _GEN_458; // @[CSR.scala 525:30]
  wire [2:0] _GEN_468 = expired_du_2 | expired_wu_2 ? _GEN_463 : _GEN_455; // @[CSR.scala 521:48]
  wire [2:0] _GEN_469 = expired_du_2 | expired_wu_2 ? _GEN_464 : _GEN_456; // @[CSR.scala 521:48]
  wire [2:0] _GEN_470 = expired_du_2 | expired_wu_2 ? _GEN_465 : _GEN_457; // @[CSR.scala 521:48]
  wire [2:0] _GEN_471 = expired_du_2 | expired_wu_2 ? _GEN_466 : _GEN_458; // @[CSR.scala 521:48]
  wire [2:0] _GEN_485 = 2'h0 == io_rw_thread ? 3'h3 : _GEN_156; // @[CSR.scala 535:{44,44}]
  wire [2:0] _GEN_486 = 2'h1 == io_rw_thread ? 3'h3 : _GEN_157; // @[CSR.scala 535:{44,44}]
  wire [2:0] _GEN_487 = 2'h2 == io_rw_thread ? 3'h3 : _GEN_158; // @[CSR.scala 535:{44,44}]
  wire [2:0] _GEN_488 = 2'h3 == io_rw_thread ? 3'h3 : _GEN_159; // @[CSR.scala 535:{44,44}]
  wire [2:0] _GEN_489 = io_ie ? _GEN_485 : _GEN_156; // @[CSR.scala 534:17]
  wire [2:0] _GEN_490 = io_ie ? _GEN_486 : _GEN_157; // @[CSR.scala 534:17]
  wire [2:0] _GEN_491 = io_ie ? _GEN_487 : _GEN_158; // @[CSR.scala 534:17]
  wire [2:0] _GEN_492 = io_ie ? _GEN_488 : _GEN_159; // @[CSR.scala 534:17]
  wire [2:0] _GEN_493 = 2'h0 == io_rw_thread ? 3'h4 : _GEN_489; // @[CSR.scala 538:{44,44}]
  wire [2:0] _GEN_494 = 2'h1 == io_rw_thread ? 3'h4 : _GEN_490; // @[CSR.scala 538:{44,44}]
  wire [2:0] _GEN_495 = 2'h2 == io_rw_thread ? 3'h4 : _GEN_491; // @[CSR.scala 538:{44,44}]
  wire [2:0] _GEN_496 = 2'h3 == io_rw_thread ? 3'h4 : _GEN_492; // @[CSR.scala 538:{44,44}]
  wire [2:0] _GEN_497 = io_ee ? _GEN_493 : _GEN_489; // @[CSR.scala 537:17]
  wire [2:0] _GEN_498 = io_ee ? _GEN_494 : _GEN_490; // @[CSR.scala 537:17]
  wire [2:0] _GEN_499 = io_ee ? _GEN_495 : _GEN_491; // @[CSR.scala 537:17]
  wire [2:0] _GEN_500 = io_ee ? _GEN_496 : _GEN_492; // @[CSR.scala 537:17]
  wire [2:0] _GEN_501 = 2'h0 == io_rw_thread ? 3'h0 : _GEN_497; // @[CSR.scala 543:{44,44}]
  wire [2:0] _GEN_502 = 2'h1 == io_rw_thread ? 3'h0 : _GEN_498; // @[CSR.scala 543:{44,44}]
  wire [2:0] _GEN_503 = 2'h2 == io_rw_thread ? 3'h0 : _GEN_499; // @[CSR.scala 543:{44,44}]
  wire [2:0] _GEN_504 = 2'h3 == io_rw_thread ? 3'h0 : _GEN_500; // @[CSR.scala 543:{44,44}]
  wire [2:0] _GEN_505 = _T_108 & _GEN_420 ? _GEN_501 : _GEN_497; // @[CSR.scala 542:89]
  wire [2:0] _GEN_506 = _T_108 & _GEN_420 ? _GEN_502 : _GEN_498; // @[CSR.scala 542:89]
  wire [2:0] _GEN_507 = _T_108 & _GEN_420 ? _GEN_503 : _GEN_499; // @[CSR.scala 542:89]
  wire [2:0] _GEN_508 = _T_108 & _GEN_420 ? _GEN_504 : _GEN_500; // @[CSR.scala 542:89]
  wire  mtie = _T_109 & _GEN_416; // @[CSR.scala 547:60]
  wire  _GEN_513 = _GEN_421 | _GEN_192; // @[CSR.scala 550:{30,30}]
  wire  _GEN_514 = _GEN_422 | _GEN_193; // @[CSR.scala 550:{30,30}]
  wire  _GEN_515 = _GEN_423 | _GEN_194; // @[CSR.scala 550:{30,30}]
  wire  _GEN_516 = _GEN_424 | _GEN_195; // @[CSR.scala 550:{30,30}]
  wire  _GEN_527 = 2'h1 == io_rw_thread ? reg_mtie_1 : reg_mtie_0; // @[CSR.scala 554:{81,81}]
  wire  _GEN_528 = 2'h2 == io_rw_thread ? reg_mtie_2 : _GEN_527; // @[CSR.scala 554:{81,81}]
  wire  _GEN_529 = 2'h3 == io_rw_thread ? reg_mtie_3 : _GEN_528; // @[CSR.scala 554:{81,81}]
  wire  _GEN_531 = 2'h1 == io_rw_thread ? reg_ie_1 : reg_ie_0; // @[CSR.scala 554:{54,54}]
  wire  _GEN_532 = 2'h2 == io_rw_thread ? reg_ie_2 : _GEN_531; // @[CSR.scala 554:{54,54}]
  wire  _GEN_533 = 2'h3 == io_rw_thread ? reg_ie_3 : _GEN_532; // @[CSR.scala 554:{54,54}]
  wire  expired_ie_0 = _GEN_421 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  wire  expired_ie_1 = _GEN_422 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  wire  expired_ie_2 = _GEN_423 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  wire  expired_ie_3 = _GEN_424 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  wire  _GEN_538 = io_int_exts_0 | _GEN_357; // @[CSR.scala 567:30 568:23]
  wire  _GEN_540 = io_int_exts_1 | _GEN_358; // @[CSR.scala 567:30 568:23]
  wire  _GEN_542 = io_int_exts_2 | _GEN_359; // @[CSR.scala 567:30 568:23]
  wire  _GEN_544 = io_int_exts_3 | _GEN_360; // @[CSR.scala 567:30 568:23]
  wire  _GEN_547 = 2'h1 == io_rw_thread ? reg_msip_1 : reg_msip_0; // @[CSR.scala 574:{37,37}]
  wire  _GEN_548 = 2'h2 == io_rw_thread ? reg_msip_2 : _GEN_547; // @[CSR.scala 574:{37,37}]
  wire  _GEN_549 = 2'h3 == io_rw_thread ? reg_msip_3 : _GEN_548; // @[CSR.scala 574:{37,37}]
  wire [63:0] _reg_cycle_T_1 = _GEN_247 + 64'h1; // @[CSR.scala 580:58]
  wire [63:0] _reg_instret_T_1 = _GEN_252 + 64'h1; // @[CSR.scala 583:62]
  wire  _GEN_567 = 2'h1 == io_rw_thread ? expired_ie_1 : expired_ie_0; // @[CSR.scala 606:{38,38}]
  wire  _GEN_568 = 2'h2 == io_rw_thread ? expired_ie_2 : _GEN_567; // @[CSR.scala 606:{38,38}]
  wire  _GEN_569 = 2'h3 == io_rw_thread ? expired_ie_3 : _GEN_568; // @[CSR.scala 606:{38,38}]
  wire  _GEN_571 = 2'h1 == io_rw_thread ? io_int_exts_1 : io_int_exts_0; // @[CSR.scala 606:{66,66}]
  wire  _GEN_572 = 2'h2 == io_rw_thread ? io_int_exts_2 : _GEN_571; // @[CSR.scala 606:{66,66}]
  wire  _GEN_573 = 2'h3 == io_rw_thread ? io_int_exts_3 : _GEN_572; // @[CSR.scala 606:{66,66}]
  wire  _GEN_574 = 2'h0 == io_rw_thread ? 1'h0 : _GEN_188; // @[CSR.scala 609:{30,30}]
  wire  _GEN_575 = 2'h1 == io_rw_thread ? 1'h0 : _GEN_189; // @[CSR.scala 609:{30,30}]
  wire  _GEN_576 = 2'h2 == io_rw_thread ? 1'h0 : _GEN_190; // @[CSR.scala 609:{30,30}]
  wire  _GEN_577 = 2'h3 == io_rw_thread ? 1'h0 : _GEN_191; // @[CSR.scala 609:{30,30}]
  wire  _GEN_578 = (_GEN_569 | _GEN_420 | _GEN_573) & _GEN_574; // @[CSR.scala 606:96 611:16]
  wire  _GEN_579 = (_GEN_569 | _GEN_420 | _GEN_573) & _GEN_575; // @[CSR.scala 606:96 611:16]
  wire  _GEN_580 = (_GEN_569 | _GEN_420 | _GEN_573) & _GEN_576; // @[CSR.scala 606:96 611:16]
  wire  _GEN_581 = (_GEN_569 | _GEN_420 | _GEN_573) & _GEN_577; // @[CSR.scala 606:96 611:16]
  wire [35:0] _GEN_604 = reset ? 36'h0 : _GEN_160; // @[CSR.scala 85:{29,29}]
  wire [35:0] _GEN_605 = reset ? 36'h0 : _GEN_161; // @[CSR.scala 85:{29,29}]
  wire [35:0] _GEN_606 = reset ? 36'h0 : _GEN_162; // @[CSR.scala 85:{29,29}]
  wire [35:0] _GEN_607 = reset ? 36'h0 : _GEN_163; // @[CSR.scala 85:{29,29}]
  wire  _GEN_609 = _T_75 & ~_T_76; // @[CSR.scala 376:15]
  Lock Lock ( // @[CSR.scala 360:22]
    .clock(Lock_clock),
    .reset(Lock_reset),
    .io_valid(Lock_io_valid),
    .io_tid(Lock_io_tid),
    .io_acquire(Lock_io_acquire),
    .io_grant(Lock_io_grant)
  );
  assign io_rw_data_out = data_out[31:0]; // @[CSR.scala 616:18]
  assign io_tmodes_0 = reg_tmodes_0; // @[CSR.scala 618:13]
  assign io_tmodes_1 = reg_tmodes_1; // @[CSR.scala 618:13]
  assign io_tmodes_2 = reg_tmodes_2; // @[CSR.scala 618:13]
  assign io_tmodes_3 = reg_tmodes_3; // @[CSR.scala 618:13]
  assign io_evecs_0 = reg_evecs_0[31:0]; // @[CSR.scala 620:14]
  assign io_evecs_1 = reg_evecs_1[31:0]; // @[CSR.scala 620:14]
  assign io_evecs_2 = reg_evecs_2[31:0]; // @[CSR.scala 620:14]
  assign io_evecs_3 = reg_evecs_3[31:0]; // @[CSR.scala 620:14]
  assign io_mepcs_0 = reg_mepcs_0; // @[CSR.scala 621:15]
  assign io_mepcs_1 = reg_mepcs_1; // @[CSR.scala 621:15]
  assign io_mepcs_2 = reg_mepcs_2; // @[CSR.scala 621:15]
  assign io_mepcs_3 = reg_mepcs_3; // @[CSR.scala 621:15]
  assign io_expire_du_0 = io_rw_thread != 2'h0 ? 1'h0 : _GEN_361; // @[CSR.scala 471:38 472:27]
  assign io_expire_du_1 = _T_104 ? 1'h0 : _GEN_365; // @[CSR.scala 471:38 472:27]
  assign io_expire_du_2 = _T_107 ? 1'h0 : _GEN_369; // @[CSR.scala 471:38 472:27]
  assign io_expire_du_3 = _T_110 ? 1'h0 : _GEN_373; // @[CSR.scala 471:38 472:27]
  assign io_expire_ie_0 = _GEN_421 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  assign io_expire_ie_1 = _GEN_422 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  assign io_expire_ie_2 = _GEN_423 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  assign io_expire_ie_3 = _GEN_424 & (_GEN_533 & (_GEN_529 | mtie)); // @[CSR.scala 554:{30,30}]
  assign io_expire_ee_0 = _T_89 ? 1'h0 : _GEN_381; // @[CSR.scala 495:38 497:27]
  assign io_expire_ee_1 = io_rw_thread != 2'h1 ? 1'h0 : _GEN_385; // @[CSR.scala 495:38 497:27]
  assign io_expire_ee_2 = io_rw_thread != 2'h2 ? 1'h0 : _GEN_389; // @[CSR.scala 495:38 497:27]
  assign io_expire_ee_3 = io_rw_thread != 2'h3 ? 1'h0 : _GEN_393; // @[CSR.scala 495:38 497:27]
  assign io_timer_expire_du_wu_0 = ~_reg_compare_expired_du_wu_0_T_2[31]; // @[CSR.scala 460:120]
  assign io_timer_expire_du_wu_1 = ~_reg_compare_expired_du_wu_1_T_2[31]; // @[CSR.scala 460:120]
  assign io_timer_expire_du_wu_2 = ~_reg_compare_expired_du_wu_2_T_2[31]; // @[CSR.scala 460:120]
  assign io_timer_expire_du_wu_3 = ~_reg_compare_expired_du_wu_3_T_2[31]; // @[CSR.scala 460:120]
  assign io_gpio_out_3 = reg_gpos_3; // @[CSR.scala 634:53]
  assign io_gpio_out_2 = reg_gpos_2; // @[CSR.scala 634:53]
  assign io_gpio_out_1 = reg_gpos_1; // @[CSR.scala 634:53]
  assign io_gpio_out_0 = reg_gpos_0; // @[CSR.scala 634:53]
  assign io_imem_protection_0 = reg_imem_protection_0; // @[CSR.scala 637:22]
  assign io_imem_protection_1 = reg_imem_protection_1; // @[CSR.scala 637:22]
  assign io_imem_protection_2 = reg_imem_protection_2; // @[CSR.scala 637:22]
  assign io_imem_protection_3 = reg_imem_protection_3; // @[CSR.scala 637:22]
  assign io_imem_protection_4 = reg_imem_protection_4; // @[CSR.scala 637:22]
  assign io_imem_protection_5 = reg_imem_protection_5; // @[CSR.scala 637:22]
  assign io_imem_protection_6 = reg_imem_protection_6; // @[CSR.scala 637:22]
  assign io_imem_protection_7 = reg_imem_protection_7; // @[CSR.scala 637:22]
  assign io_dmem_protection_0 = reg_dmem_protection_0; // @[CSR.scala 638:22]
  assign io_dmem_protection_1 = reg_dmem_protection_1; // @[CSR.scala 638:22]
  assign io_dmem_protection_2 = reg_dmem_protection_2; // @[CSR.scala 638:22]
  assign io_dmem_protection_3 = reg_dmem_protection_3; // @[CSR.scala 638:22]
  assign io_dmem_protection_4 = reg_dmem_protection_4; // @[CSR.scala 638:22]
  assign io_dmem_protection_5 = reg_dmem_protection_5; // @[CSR.scala 638:22]
  assign io_dmem_protection_6 = reg_dmem_protection_6; // @[CSR.scala 638:22]
  assign io_dmem_protection_7 = reg_dmem_protection_7; // @[CSR.scala 638:22]
  assign io_int_ext = _GEN_533 & _GEN_549; // @[CSR.scala 574:37]
  assign Lock_clock = clock;
  assign Lock_reset = reset;
  assign Lock_io_valid = write & _T_74; // @[CSR.scala 363:17]
  assign Lock_io_tid = write & _T_74 ? io_rw_thread : 2'h0; // @[CSR.scala 363:47 365:16 lock.scala 17:9]
  assign Lock_io_acquire = write & _T_74 & _T_76; // @[CSR.scala 363:47 lock.scala 18:13]
  always @(posedge clock) begin
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_0 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_0 <= data_in[3:0]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_1 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_1 <= data_in[7:4]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_2 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_2 <= data_in[11:8]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_3 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_3 <= data_in[15:12]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_4 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_4 <= data_in[19:16]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_5 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_5 <= data_in[23:20]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_6 <= 4'hf; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_6 <= data_in[27:24]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 75:26]
      reg_slots_7 <= 4'h0; // @[CSR.scala 75:26]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_42) begin // @[CSR.scala 165:36]
        reg_slots_7 <= data_in[31:28]; // @[CSR.scala 167:14]
      end
    end
    if (reset) begin // @[CSR.scala 76:27]
      reg_tmodes_0 <= 2'h0; // @[CSR.scala 76:27]
    end else if (wake_0) begin // @[CSR.scala 352:21]
      reg_tmodes_0 <= _reg_tmodes_0_T_1; // @[CSR.scala 353:23]
    end else if (io_sleep_du | io_sleep_wu) begin // @[CSR.scala 344:36]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 345:30]
        reg_tmodes_0 <= _reg_tmodes_T; // @[CSR.scala 345:30]
      end else begin
        reg_tmodes_0 <= _GEN_132;
      end
    end else begin
      reg_tmodes_0 <= _GEN_132;
    end
    if (reset) begin // @[CSR.scala 76:27]
      reg_tmodes_1 <= 2'h1; // @[CSR.scala 76:27]
    end else if (wake_1) begin // @[CSR.scala 352:21]
      reg_tmodes_1 <= _reg_tmodes_1_T_1; // @[CSR.scala 353:23]
    end else if (io_sleep_du | io_sleep_wu) begin // @[CSR.scala 344:36]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 345:30]
        reg_tmodes_1 <= _reg_tmodes_T; // @[CSR.scala 345:30]
      end else begin
        reg_tmodes_1 <= _GEN_133;
      end
    end else begin
      reg_tmodes_1 <= _GEN_133;
    end
    if (reset) begin // @[CSR.scala 76:27]
      reg_tmodes_2 <= 2'h1; // @[CSR.scala 76:27]
    end else if (wake_2) begin // @[CSR.scala 352:21]
      reg_tmodes_2 <= _reg_tmodes_2_T_1; // @[CSR.scala 353:23]
    end else if (io_sleep_du | io_sleep_wu) begin // @[CSR.scala 344:36]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 345:30]
        reg_tmodes_2 <= _reg_tmodes_T; // @[CSR.scala 345:30]
      end else begin
        reg_tmodes_2 <= _GEN_134;
      end
    end else begin
      reg_tmodes_2 <= _GEN_134;
    end
    if (reset) begin // @[CSR.scala 76:27]
      reg_tmodes_3 <= 2'h1; // @[CSR.scala 76:27]
    end else if (wake_3) begin // @[CSR.scala 352:21]
      reg_tmodes_3 <= _reg_tmodes_3_T_1; // @[CSR.scala 353:23]
    end else if (io_sleep_du | io_sleep_wu) begin // @[CSR.scala 344:36]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 345:30]
        reg_tmodes_3 <= _reg_tmodes_T; // @[CSR.scala 345:30]
      end else begin
        reg_tmodes_3 <= _GEN_135;
      end
    end else begin
      reg_tmodes_3 <= _GEN_135;
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_45) begin // @[CSR.scala 178:37]
        if (2'h0 == io_rw_thread) begin // @[CSR.scala 179:33]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_evecs_0 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_evecs_0 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_45) begin // @[CSR.scala 178:37]
        if (2'h1 == io_rw_thread) begin // @[CSR.scala 179:33]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_evecs_1 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_evecs_1 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_45) begin // @[CSR.scala 178:37]
        if (2'h2 == io_rw_thread) begin // @[CSR.scala 179:33]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_evecs_2 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_evecs_2 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_45) begin // @[CSR.scala 178:37]
        if (2'h3 == io_rw_thread) begin // @[CSR.scala 179:33]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_evecs_3 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_evecs_3 <= _data_in_T_6;
          end
        end
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (_GEN_288 == 3'h2) begin // @[CSR.scala 388:64]
        if (~io_mret) begin // @[CSR.scala 393:25]
          if (2'h0 == io_rw_thread) begin // @[CSR.scala 396:35]
            reg_mepcs_0 <= _reg_mepcs_T_1; // @[CSR.scala 396:35]
          end
        end
      end else if (_T_85) begin // @[CSR.scala 407:25]
        if (2'h0 == io_rw_thread) begin // @[CSR.scala 410:35]
          reg_mepcs_0 <= io_epc; // @[CSR.scala 410:35]
        end
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (_GEN_288 == 3'h2) begin // @[CSR.scala 388:64]
        if (~io_mret) begin // @[CSR.scala 393:25]
          if (2'h1 == io_rw_thread) begin // @[CSR.scala 396:35]
            reg_mepcs_1 <= _reg_mepcs_T_1; // @[CSR.scala 396:35]
          end
        end
      end else if (_T_85) begin // @[CSR.scala 407:25]
        if (2'h1 == io_rw_thread) begin // @[CSR.scala 410:35]
          reg_mepcs_1 <= io_epc; // @[CSR.scala 410:35]
        end
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (_GEN_288 == 3'h2) begin // @[CSR.scala 388:64]
        if (~io_mret) begin // @[CSR.scala 393:25]
          if (2'h2 == io_rw_thread) begin // @[CSR.scala 396:35]
            reg_mepcs_2 <= _reg_mepcs_T_1; // @[CSR.scala 396:35]
          end
        end
      end else if (_T_85) begin // @[CSR.scala 407:25]
        if (2'h2 == io_rw_thread) begin // @[CSR.scala 410:35]
          reg_mepcs_2 <= io_epc; // @[CSR.scala 410:35]
        end
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (_GEN_288 == 3'h2) begin // @[CSR.scala 388:64]
        if (~io_mret) begin // @[CSR.scala 393:25]
          if (2'h3 == io_rw_thread) begin // @[CSR.scala 396:35]
            reg_mepcs_3 <= _reg_mepcs_T_1; // @[CSR.scala 396:35]
          end
        end
      end else if (_T_85) begin // @[CSR.scala 407:25]
        if (2'h3 == io_rw_thread) begin // @[CSR.scala 410:35]
          reg_mepcs_3 <= io_epc; // @[CSR.scala 410:35]
        end
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 413:32]
        reg_causes_0 <= io_cause; // @[CSR.scala 413:32]
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 413:32]
        reg_causes_1 <= io_cause; // @[CSR.scala 413:32]
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 413:32]
        reg_causes_2 <= io_cause; // @[CSR.scala 413:32]
      end
    end
    if (io_exception) begin // @[CSR.scala 387:24]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 413:32]
        reg_causes_3 <= io_cause; // @[CSR.scala 413:32]
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_48) begin // @[CSR.scala 181:37]
        if (2'h0 == io_rw_thread) begin // @[CSR.scala 182:32]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_sup0_0 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_sup0_0 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_48) begin // @[CSR.scala 181:37]
        if (2'h1 == io_rw_thread) begin // @[CSR.scala 182:32]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_sup0_1 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_sup0_1 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_48) begin // @[CSR.scala 181:37]
        if (2'h2 == io_rw_thread) begin // @[CSR.scala 182:32]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_sup0_2 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_sup0_2 <= _data_in_T_6;
          end
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_48) begin // @[CSR.scala 181:37]
        if (2'h3 == io_rw_thread) begin // @[CSR.scala 182:32]
          if (2'h1 == io_rw_csr_type) begin // @[Mux.scala 81:58]
            reg_sup0_3 <= {{4'd0}, io_rw_data_in};
          end else begin
            reg_sup0_3 <= _data_in_T_6;
          end
        end
      end
    end
    regs_to_host_0 <= _GEN_604[31:0]; // @[CSR.scala 85:{29,29}]
    regs_to_host_1 <= _GEN_605[31:0]; // @[CSR.scala 85:{29,29}]
    regs_to_host_2 <= _GEN_606[31:0]; // @[CSR.scala 85:{29,29}]
    regs_to_host_3 <= _GEN_607[31:0]; // @[CSR.scala 85:{29,29}]
    reg_gpis_0 <= io_gpio_in_0; // @[CSR.scala 559:52]
    reg_gpis_1 <= io_gpio_in_1; // @[CSR.scala 559:52]
    reg_gpis_2 <= io_gpio_in_2; // @[CSR.scala 559:52]
    reg_gpis_3 <= io_gpio_in_3; // @[CSR.scala 559:52]
    if (reset) begin // @[CSR.scala 87:63]
      reg_gpos_0 <= 2'h0; // @[CSR.scala 87:63]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_58) begin // @[CSR.scala 203:44]
        if ((reg_gpo_protection_0 == 4'h8 | reg_gpo_protection_0[1:0] == io_rw_thread) & reg_gpo_protection_0 != 4'hc
          ) begin // @[CSR.scala 205:162]
          reg_gpos_0 <= data_in[1:0]; // @[CSR.scala 206:25]
        end
      end
    end
    if (reset) begin // @[CSR.scala 87:63]
      reg_gpos_1 <= 2'h0; // @[CSR.scala 87:63]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_59) begin // @[CSR.scala 203:44]
        if ((reg_gpo_protection_1 == 4'h8 | reg_gpo_protection_1[1:0] == io_rw_thread) & reg_gpo_protection_1 != 4'hc
          ) begin // @[CSR.scala 205:162]
          reg_gpos_1 <= data_in[1:0]; // @[CSR.scala 206:25]
        end
      end
    end
    if (reset) begin // @[CSR.scala 87:63]
      reg_gpos_2 <= 2'h0; // @[CSR.scala 87:63]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_60) begin // @[CSR.scala 203:44]
        if ((reg_gpo_protection_2 == 4'h8 | reg_gpo_protection_2[1:0] == io_rw_thread) & reg_gpo_protection_2 != 4'hc
          ) begin // @[CSR.scala 205:162]
          reg_gpos_2 <= data_in[1:0]; // @[CSR.scala 206:25]
        end
      end
    end
    if (reset) begin // @[CSR.scala 87:63]
      reg_gpos_3 <= 2'h0; // @[CSR.scala 87:63]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_61) begin // @[CSR.scala 203:44]
        if ((reg_gpo_protection_3 == 4'h8 | reg_gpo_protection_3[1:0] == io_rw_thread) & reg_gpo_protection_3 != 4'hc
          ) begin // @[CSR.scala 205:162]
          reg_gpos_3 <= data_in[1:0]; // @[CSR.scala 206:25]
        end
      end
    end
    if (reset) begin // @[CSR.scala 89:35]
      reg_gpo_protection_0 <= 4'h0; // @[CSR.scala 89:35]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_62) begin // @[CSR.scala 226:46]
        reg_gpo_protection_0 <= data_in[3:0]; // @[CSR.scala 228:16]
      end
    end
    if (reset) begin // @[CSR.scala 89:35]
      reg_gpo_protection_1 <= 4'h8; // @[CSR.scala 89:35]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_62) begin // @[CSR.scala 226:46]
        reg_gpo_protection_1 <= data_in[7:4]; // @[CSR.scala 228:16]
      end
    end
    if (reset) begin // @[CSR.scala 89:35]
      reg_gpo_protection_2 <= 4'h8; // @[CSR.scala 89:35]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_62) begin // @[CSR.scala 226:46]
        reg_gpo_protection_2 <= data_in[11:8]; // @[CSR.scala 228:16]
      end
    end
    if (reset) begin // @[CSR.scala 89:35]
      reg_gpo_protection_3 <= 4'h8; // @[CSR.scala 89:35]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_62) begin // @[CSR.scala 226:46]
        reg_gpo_protection_3 <= data_in[15:12]; // @[CSR.scala 228:16]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_0 <= 4'h8; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_0 <= data_in[3:0]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_1 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_1 <= data_in[7:4]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_2 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_2 <= data_in[11:8]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_3 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_3 <= data_in[15:12]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_4 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_4 <= data_in[19:16]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_5 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_5 <= data_in[23:20]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_6 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_6 <= data_in[27:24]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 90:36]
      reg_imem_protection_7 <= 4'hc; // @[CSR.scala 90:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_63) begin // @[CSR.scala 214:47]
        reg_imem_protection_7 <= data_in[31:28]; // @[CSR.scala 216:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_0 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_0 <= data_in[3:0]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_1 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_1 <= data_in[7:4]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_2 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_2 <= data_in[11:8]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_3 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_3 <= data_in[15:12]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_4 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_4 <= data_in[19:16]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_5 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_5 <= data_in[23:20]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_6 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_6 <= data_in[27:24]; // @[CSR.scala 221:18]
      end
    end
    if (reset) begin // @[CSR.scala 91:36]
      reg_dmem_protection_7 <= 4'h8; // @[CSR.scala 91:36]
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_64) begin // @[CSR.scala 219:47]
        reg_dmem_protection_7 <= data_in[31:28]; // @[CSR.scala 221:18]
      end
    end
    if (io_cycle) begin // @[CSR.scala 579:20]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 580:31]
        reg_cycle_0 <= _reg_cycle_T_1; // @[CSR.scala 580:31]
      end
    end
    if (io_cycle) begin // @[CSR.scala 579:20]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 580:31]
        reg_cycle_1 <= _reg_cycle_T_1; // @[CSR.scala 580:31]
      end
    end
    if (io_cycle) begin // @[CSR.scala 579:20]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 580:31]
        reg_cycle_2 <= _reg_cycle_T_1; // @[CSR.scala 580:31]
      end
    end
    if (io_cycle) begin // @[CSR.scala 579:20]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 580:31]
        reg_cycle_3 <= _reg_cycle_T_1; // @[CSR.scala 580:31]
      end
    end
    if (io_instret) begin // @[CSR.scala 582:22]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 583:33]
        reg_instret_0 <= _reg_instret_T_1; // @[CSR.scala 583:33]
      end
    end
    if (io_instret) begin // @[CSR.scala 582:22]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 583:33]
        reg_instret_1 <= _reg_instret_T_1; // @[CSR.scala 583:33]
      end
    end
    if (io_instret) begin // @[CSR.scala 582:22]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 583:33]
        reg_instret_2 <= _reg_instret_T_1; // @[CSR.scala 583:33]
      end
    end
    if (io_instret) begin // @[CSR.scala 582:22]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 583:33]
        reg_instret_3 <= _reg_instret_T_1; // @[CSR.scala 583:33]
      end
    end
    if (reset) begin // @[CSR.scala 96:25]
      reg_mtie_0 <= 1'h0; // @[CSR.scala 96:25]
    end else if (mtie) begin // @[CSR.scala 547:94]
      reg_mtie_0 <= _GEN_513;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_mtie_0 <= _GEN_96;
      end
    end
    if (reset) begin // @[CSR.scala 96:25]
      reg_mtie_1 <= 1'h0; // @[CSR.scala 96:25]
    end else if (mtie) begin // @[CSR.scala 547:94]
      reg_mtie_1 <= _GEN_514;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_mtie_1 <= _GEN_97;
      end
    end
    if (reset) begin // @[CSR.scala 96:25]
      reg_mtie_2 <= 1'h0; // @[CSR.scala 96:25]
    end else if (mtie) begin // @[CSR.scala 547:94]
      reg_mtie_2 <= _GEN_515;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_mtie_2 <= _GEN_98;
      end
    end
    if (reset) begin // @[CSR.scala 96:25]
      reg_mtie_3 <= 1'h0; // @[CSR.scala 96:25]
    end else if (mtie) begin // @[CSR.scala 547:94]
      reg_mtie_3 <= _GEN_516;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_mtie_3 <= _GEN_99;
      end
    end
    if (reset) begin // @[CSR.scala 100:23]
      reg_ie_0 <= 1'h0; // @[CSR.scala 100:23]
    end else if (io_exception) begin // @[CSR.scala 605:25]
      reg_ie_0 <= _GEN_578;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_ie_0 <= _GEN_92;
      end
    end
    if (reset) begin // @[CSR.scala 100:23]
      reg_ie_1 <= 1'h0; // @[CSR.scala 100:23]
    end else if (io_exception) begin // @[CSR.scala 605:25]
      reg_ie_1 <= _GEN_579;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_ie_1 <= _GEN_93;
      end
    end
    if (reset) begin // @[CSR.scala 100:23]
      reg_ie_2 <= 1'h0; // @[CSR.scala 100:23]
    end else if (io_exception) begin // @[CSR.scala 605:25]
      reg_ie_2 <= _GEN_580;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_ie_2 <= _GEN_94;
      end
    end
    if (reset) begin // @[CSR.scala 100:23]
      reg_ie_3 <= 1'h0; // @[CSR.scala 100:23]
    end else if (io_exception) begin // @[CSR.scala 605:25]
      reg_ie_3 <= _GEN_581;
    end else if (write) begin // @[CSR.scala 164:15]
      if (_T_71) begin // @[CSR.scala 232:37]
        reg_ie_3 <= _GEN_95;
      end
    end
    if (reset) begin // @[CSR.scala 101:25]
      reg_msip_0 <= 1'h0; // @[CSR.scala 101:25]
    end else begin
      reg_msip_0 <= _GEN_538;
    end
    if (reset) begin // @[CSR.scala 101:25]
      reg_msip_1 <= 1'h0; // @[CSR.scala 101:25]
    end else begin
      reg_msip_1 <= _GEN_540;
    end
    if (reset) begin // @[CSR.scala 101:25]
      reg_msip_2 <= 1'h0; // @[CSR.scala 101:25]
    end else begin
      reg_msip_2 <= _GEN_542;
    end
    if (reset) begin // @[CSR.scala 101:25]
      reg_msip_3 <= 1'h0; // @[CSR.scala 101:25]
    end else begin
      reg_msip_3 <= _GEN_544;
    end
    if (reset) begin // @[CSR.scala 102:33]
      reg_in_interrupt_0 <= 1'h0; // @[CSR.scala 102:33]
    end else if (io_exception) begin // @[CSR.scala 387:24]
      reg_in_interrupt_0 <= _GEN_321;
    end else if (io_mret) begin // @[CSR.scala 415:27]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 418:38]
        reg_in_interrupt_0 <= 1'h0; // @[CSR.scala 418:38]
      end else begin
        reg_in_interrupt_0 <= _GEN_200;
      end
    end else begin
      reg_in_interrupt_0 <= _GEN_200;
    end
    if (reset) begin // @[CSR.scala 102:33]
      reg_in_interrupt_1 <= 1'h0; // @[CSR.scala 102:33]
    end else if (io_exception) begin // @[CSR.scala 387:24]
      reg_in_interrupt_1 <= _GEN_322;
    end else if (io_mret) begin // @[CSR.scala 415:27]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 418:38]
        reg_in_interrupt_1 <= 1'h0; // @[CSR.scala 418:38]
      end else begin
        reg_in_interrupt_1 <= _GEN_201;
      end
    end else begin
      reg_in_interrupt_1 <= _GEN_201;
    end
    if (reset) begin // @[CSR.scala 102:33]
      reg_in_interrupt_2 <= 1'h0; // @[CSR.scala 102:33]
    end else if (io_exception) begin // @[CSR.scala 387:24]
      reg_in_interrupt_2 <= _GEN_323;
    end else if (io_mret) begin // @[CSR.scala 415:27]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 418:38]
        reg_in_interrupt_2 <= 1'h0; // @[CSR.scala 418:38]
      end else begin
        reg_in_interrupt_2 <= _GEN_202;
      end
    end else begin
      reg_in_interrupt_2 <= _GEN_202;
    end
    if (reset) begin // @[CSR.scala 102:33]
      reg_in_interrupt_3 <= 1'h0; // @[CSR.scala 102:33]
    end else if (io_exception) begin // @[CSR.scala 387:24]
      reg_in_interrupt_3 <= _GEN_324;
    end else if (io_mret) begin // @[CSR.scala 415:27]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 418:38]
        reg_in_interrupt_3 <= 1'h0; // @[CSR.scala 418:38]
      end else begin
        reg_in_interrupt_3 <= _GEN_203;
      end
    end else begin
      reg_in_interrupt_3 <= _GEN_203;
    end
    if (reset) begin // @[CSR.scala 105:25]
      reg_time <= 64'h0; // @[CSR.scala 105:25]
    end else begin
      reg_time <= _reg_time_T_1; // @[CSR.scala 424:14]
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_4) begin // @[CSR.scala 186:46]
        if (2'h0 == io_rw_thread) begin // @[CSR.scala 187:41]
          reg_compare_du_wu_0 <= data_in[31:0]; // @[CSR.scala 187:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_4) begin // @[CSR.scala 186:46]
        if (2'h1 == io_rw_thread) begin // @[CSR.scala 187:41]
          reg_compare_du_wu_1 <= data_in[31:0]; // @[CSR.scala 187:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_4) begin // @[CSR.scala 186:46]
        if (2'h2 == io_rw_thread) begin // @[CSR.scala 187:41]
          reg_compare_du_wu_2 <= data_in[31:0]; // @[CSR.scala 187:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_4) begin // @[CSR.scala 186:46]
        if (2'h3 == io_rw_thread) begin // @[CSR.scala 187:41]
          reg_compare_du_wu_3 <= data_in[31:0]; // @[CSR.scala 187:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_5) begin // @[CSR.scala 192:46]
        if (2'h0 == io_rw_thread) begin // @[CSR.scala 193:41]
          reg_compare_ie_ee_0 <= data_in[31:0]; // @[CSR.scala 193:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_5) begin // @[CSR.scala 192:46]
        if (2'h1 == io_rw_thread) begin // @[CSR.scala 193:41]
          reg_compare_ie_ee_1 <= data_in[31:0]; // @[CSR.scala 193:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_5) begin // @[CSR.scala 192:46]
        if (2'h2 == io_rw_thread) begin // @[CSR.scala 193:41]
          reg_compare_ie_ee_2 <= data_in[31:0]; // @[CSR.scala 193:41]
        end
      end
    end
    if (write) begin // @[CSR.scala 164:15]
      if (_T_5) begin // @[CSR.scala 192:46]
        if (2'h3 == io_rw_thread) begin // @[CSR.scala 193:41]
          reg_compare_ie_ee_3 <= data_in[31:0]; // @[CSR.scala 193:41]
        end
      end
    end
    if (reset) begin // @[CSR.scala 110:39]
      reg_compare_du_wu_type_0 <= 3'h0; // @[CSR.scala 110:39]
    end else if (expired_du_3 | expired_wu_3) begin // @[CSR.scala 521:48]
      if (thread_active) begin // @[CSR.scala 525:30]
        if (2'h0 == io_if_tid) begin // @[CSR.scala 526:45]
          reg_compare_du_wu_type_0 <= 3'h0; // @[CSR.scala 526:45]
        end else begin
          reg_compare_du_wu_type_0 <= _GEN_468;
        end
      end else begin
        reg_compare_du_wu_type_0 <= _GEN_468;
      end
    end else begin
      reg_compare_du_wu_type_0 <= _GEN_468;
    end
    if (reset) begin // @[CSR.scala 110:39]
      reg_compare_du_wu_type_1 <= 3'h0; // @[CSR.scala 110:39]
    end else if (expired_du_3 | expired_wu_3) begin // @[CSR.scala 521:48]
      if (thread_active) begin // @[CSR.scala 525:30]
        if (2'h1 == io_if_tid) begin // @[CSR.scala 526:45]
          reg_compare_du_wu_type_1 <= 3'h0; // @[CSR.scala 526:45]
        end else begin
          reg_compare_du_wu_type_1 <= _GEN_469;
        end
      end else begin
        reg_compare_du_wu_type_1 <= _GEN_469;
      end
    end else begin
      reg_compare_du_wu_type_1 <= _GEN_469;
    end
    if (reset) begin // @[CSR.scala 110:39]
      reg_compare_du_wu_type_2 <= 3'h0; // @[CSR.scala 110:39]
    end else if (expired_du_3 | expired_wu_3) begin // @[CSR.scala 521:48]
      if (thread_active) begin // @[CSR.scala 525:30]
        if (2'h2 == io_if_tid) begin // @[CSR.scala 526:45]
          reg_compare_du_wu_type_2 <= 3'h0; // @[CSR.scala 526:45]
        end else begin
          reg_compare_du_wu_type_2 <= _GEN_470;
        end
      end else begin
        reg_compare_du_wu_type_2 <= _GEN_470;
      end
    end else begin
      reg_compare_du_wu_type_2 <= _GEN_470;
    end
    if (reset) begin // @[CSR.scala 110:39]
      reg_compare_du_wu_type_3 <= 3'h0; // @[CSR.scala 110:39]
    end else if (expired_du_3 | expired_wu_3) begin // @[CSR.scala 521:48]
      if (thread_active) begin // @[CSR.scala 525:30]
        if (2'h3 == io_if_tid) begin // @[CSR.scala 526:45]
          reg_compare_du_wu_type_3 <= 3'h0; // @[CSR.scala 526:45]
        end else begin
          reg_compare_du_wu_type_3 <= _GEN_471;
        end
      end else begin
        reg_compare_du_wu_type_3 <= _GEN_471;
      end
    end else begin
      reg_compare_du_wu_type_3 <= _GEN_471;
    end
    if (reset) begin // @[CSR.scala 113:39]
      reg_compare_ie_ee_type_0 <= 3'h0; // @[CSR.scala 113:39]
    end else if (mtie) begin // @[CSR.scala 547:94]
      if (2'h0 == io_rw_thread) begin // @[CSR.scala 548:44]
        reg_compare_ie_ee_type_0 <= 3'h0; // @[CSR.scala 548:44]
      end else begin
        reg_compare_ie_ee_type_0 <= _GEN_505;
      end
    end else begin
      reg_compare_ie_ee_type_0 <= _GEN_505;
    end
    if (reset) begin // @[CSR.scala 113:39]
      reg_compare_ie_ee_type_1 <= 3'h0; // @[CSR.scala 113:39]
    end else if (mtie) begin // @[CSR.scala 547:94]
      if (2'h1 == io_rw_thread) begin // @[CSR.scala 548:44]
        reg_compare_ie_ee_type_1 <= 3'h0; // @[CSR.scala 548:44]
      end else begin
        reg_compare_ie_ee_type_1 <= _GEN_506;
      end
    end else begin
      reg_compare_ie_ee_type_1 <= _GEN_506;
    end
    if (reset) begin // @[CSR.scala 113:39]
      reg_compare_ie_ee_type_2 <= 3'h0; // @[CSR.scala 113:39]
    end else if (mtie) begin // @[CSR.scala 547:94]
      if (2'h2 == io_rw_thread) begin // @[CSR.scala 548:44]
        reg_compare_ie_ee_type_2 <= 3'h0; // @[CSR.scala 548:44]
      end else begin
        reg_compare_ie_ee_type_2 <= _GEN_507;
      end
    end else begin
      reg_compare_ie_ee_type_2 <= _GEN_507;
    end
    if (reset) begin // @[CSR.scala 113:39]
      reg_compare_ie_ee_type_3 <= 3'h0; // @[CSR.scala 113:39]
    end else if (mtie) begin // @[CSR.scala 547:94]
      if (2'h3 == io_rw_thread) begin // @[CSR.scala 548:44]
        reg_compare_ie_ee_type_3 <= 3'h0; // @[CSR.scala 548:44]
      end else begin
        reg_compare_ie_ee_type_3 <= _GEN_508;
      end
    end else begin
      reg_compare_ie_ee_type_3 <= _GEN_508;
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_75 & ~_T_76 & _T_77 & ~reset & ~Lock_io_grant) begin
          $fwrite(32'h80000002,
            "Assertion failed: thread-%d could not release lock\n    at CSR.scala:376 assert(lock.grant, cf\"thread-${io.rw.thread} could not release lock\")\n"
            ,io_rw_thread); // @[CSR.scala 376:15]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_75 & ~_T_76 & _T_77 & ~reset & ~Lock_io_grant) begin
          $fatal; // @[CSR.scala 376:15]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_609 & ~_T_77 & _T_79) begin
          $fwrite(32'h80000002,"Assertion failed\n    at CSR.scala:378 assert(false.B)\n"); // @[CSR.scala 378:15]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_GEN_609 & ~_T_77 & _T_79) begin
          $fatal; // @[CSR.scala 378:15]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_slots_0 = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  reg_slots_1 = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  reg_slots_2 = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  reg_slots_3 = _RAND_3[3:0];
  _RAND_4 = {1{`RANDOM}};
  reg_slots_4 = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  reg_slots_5 = _RAND_5[3:0];
  _RAND_6 = {1{`RANDOM}};
  reg_slots_6 = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  reg_slots_7 = _RAND_7[3:0];
  _RAND_8 = {1{`RANDOM}};
  reg_tmodes_0 = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  reg_tmodes_1 = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  reg_tmodes_2 = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  reg_tmodes_3 = _RAND_11[1:0];
  _RAND_12 = {2{`RANDOM}};
  reg_evecs_0 = _RAND_12[35:0];
  _RAND_13 = {2{`RANDOM}};
  reg_evecs_1 = _RAND_13[35:0];
  _RAND_14 = {2{`RANDOM}};
  reg_evecs_2 = _RAND_14[35:0];
  _RAND_15 = {2{`RANDOM}};
  reg_evecs_3 = _RAND_15[35:0];
  _RAND_16 = {1{`RANDOM}};
  reg_mepcs_0 = _RAND_16[31:0];
  _RAND_17 = {1{`RANDOM}};
  reg_mepcs_1 = _RAND_17[31:0];
  _RAND_18 = {1{`RANDOM}};
  reg_mepcs_2 = _RAND_18[31:0];
  _RAND_19 = {1{`RANDOM}};
  reg_mepcs_3 = _RAND_19[31:0];
  _RAND_20 = {1{`RANDOM}};
  reg_causes_0 = _RAND_20[4:0];
  _RAND_21 = {1{`RANDOM}};
  reg_causes_1 = _RAND_21[4:0];
  _RAND_22 = {1{`RANDOM}};
  reg_causes_2 = _RAND_22[4:0];
  _RAND_23 = {1{`RANDOM}};
  reg_causes_3 = _RAND_23[4:0];
  _RAND_24 = {2{`RANDOM}};
  reg_sup0_0 = _RAND_24[35:0];
  _RAND_25 = {2{`RANDOM}};
  reg_sup0_1 = _RAND_25[35:0];
  _RAND_26 = {2{`RANDOM}};
  reg_sup0_2 = _RAND_26[35:0];
  _RAND_27 = {2{`RANDOM}};
  reg_sup0_3 = _RAND_27[35:0];
  _RAND_28 = {1{`RANDOM}};
  regs_to_host_0 = _RAND_28[31:0];
  _RAND_29 = {1{`RANDOM}};
  regs_to_host_1 = _RAND_29[31:0];
  _RAND_30 = {1{`RANDOM}};
  regs_to_host_2 = _RAND_30[31:0];
  _RAND_31 = {1{`RANDOM}};
  regs_to_host_3 = _RAND_31[31:0];
  _RAND_32 = {1{`RANDOM}};
  reg_gpis_0 = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  reg_gpis_1 = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  reg_gpis_2 = _RAND_34[0:0];
  _RAND_35 = {1{`RANDOM}};
  reg_gpis_3 = _RAND_35[0:0];
  _RAND_36 = {1{`RANDOM}};
  reg_gpos_0 = _RAND_36[1:0];
  _RAND_37 = {1{`RANDOM}};
  reg_gpos_1 = _RAND_37[1:0];
  _RAND_38 = {1{`RANDOM}};
  reg_gpos_2 = _RAND_38[1:0];
  _RAND_39 = {1{`RANDOM}};
  reg_gpos_3 = _RAND_39[1:0];
  _RAND_40 = {1{`RANDOM}};
  reg_gpo_protection_0 = _RAND_40[3:0];
  _RAND_41 = {1{`RANDOM}};
  reg_gpo_protection_1 = _RAND_41[3:0];
  _RAND_42 = {1{`RANDOM}};
  reg_gpo_protection_2 = _RAND_42[3:0];
  _RAND_43 = {1{`RANDOM}};
  reg_gpo_protection_3 = _RAND_43[3:0];
  _RAND_44 = {1{`RANDOM}};
  reg_imem_protection_0 = _RAND_44[3:0];
  _RAND_45 = {1{`RANDOM}};
  reg_imem_protection_1 = _RAND_45[3:0];
  _RAND_46 = {1{`RANDOM}};
  reg_imem_protection_2 = _RAND_46[3:0];
  _RAND_47 = {1{`RANDOM}};
  reg_imem_protection_3 = _RAND_47[3:0];
  _RAND_48 = {1{`RANDOM}};
  reg_imem_protection_4 = _RAND_48[3:0];
  _RAND_49 = {1{`RANDOM}};
  reg_imem_protection_5 = _RAND_49[3:0];
  _RAND_50 = {1{`RANDOM}};
  reg_imem_protection_6 = _RAND_50[3:0];
  _RAND_51 = {1{`RANDOM}};
  reg_imem_protection_7 = _RAND_51[3:0];
  _RAND_52 = {1{`RANDOM}};
  reg_dmem_protection_0 = _RAND_52[3:0];
  _RAND_53 = {1{`RANDOM}};
  reg_dmem_protection_1 = _RAND_53[3:0];
  _RAND_54 = {1{`RANDOM}};
  reg_dmem_protection_2 = _RAND_54[3:0];
  _RAND_55 = {1{`RANDOM}};
  reg_dmem_protection_3 = _RAND_55[3:0];
  _RAND_56 = {1{`RANDOM}};
  reg_dmem_protection_4 = _RAND_56[3:0];
  _RAND_57 = {1{`RANDOM}};
  reg_dmem_protection_5 = _RAND_57[3:0];
  _RAND_58 = {1{`RANDOM}};
  reg_dmem_protection_6 = _RAND_58[3:0];
  _RAND_59 = {1{`RANDOM}};
  reg_dmem_protection_7 = _RAND_59[3:0];
  _RAND_60 = {2{`RANDOM}};
  reg_cycle_0 = _RAND_60[63:0];
  _RAND_61 = {2{`RANDOM}};
  reg_cycle_1 = _RAND_61[63:0];
  _RAND_62 = {2{`RANDOM}};
  reg_cycle_2 = _RAND_62[63:0];
  _RAND_63 = {2{`RANDOM}};
  reg_cycle_3 = _RAND_63[63:0];
  _RAND_64 = {2{`RANDOM}};
  reg_instret_0 = _RAND_64[63:0];
  _RAND_65 = {2{`RANDOM}};
  reg_instret_1 = _RAND_65[63:0];
  _RAND_66 = {2{`RANDOM}};
  reg_instret_2 = _RAND_66[63:0];
  _RAND_67 = {2{`RANDOM}};
  reg_instret_3 = _RAND_67[63:0];
  _RAND_68 = {1{`RANDOM}};
  reg_mtie_0 = _RAND_68[0:0];
  _RAND_69 = {1{`RANDOM}};
  reg_mtie_1 = _RAND_69[0:0];
  _RAND_70 = {1{`RANDOM}};
  reg_mtie_2 = _RAND_70[0:0];
  _RAND_71 = {1{`RANDOM}};
  reg_mtie_3 = _RAND_71[0:0];
  _RAND_72 = {1{`RANDOM}};
  reg_ie_0 = _RAND_72[0:0];
  _RAND_73 = {1{`RANDOM}};
  reg_ie_1 = _RAND_73[0:0];
  _RAND_74 = {1{`RANDOM}};
  reg_ie_2 = _RAND_74[0:0];
  _RAND_75 = {1{`RANDOM}};
  reg_ie_3 = _RAND_75[0:0];
  _RAND_76 = {1{`RANDOM}};
  reg_msip_0 = _RAND_76[0:0];
  _RAND_77 = {1{`RANDOM}};
  reg_msip_1 = _RAND_77[0:0];
  _RAND_78 = {1{`RANDOM}};
  reg_msip_2 = _RAND_78[0:0];
  _RAND_79 = {1{`RANDOM}};
  reg_msip_3 = _RAND_79[0:0];
  _RAND_80 = {1{`RANDOM}};
  reg_in_interrupt_0 = _RAND_80[0:0];
  _RAND_81 = {1{`RANDOM}};
  reg_in_interrupt_1 = _RAND_81[0:0];
  _RAND_82 = {1{`RANDOM}};
  reg_in_interrupt_2 = _RAND_82[0:0];
  _RAND_83 = {1{`RANDOM}};
  reg_in_interrupt_3 = _RAND_83[0:0];
  _RAND_84 = {2{`RANDOM}};
  reg_time = _RAND_84[63:0];
  _RAND_85 = {1{`RANDOM}};
  reg_compare_du_wu_0 = _RAND_85[31:0];
  _RAND_86 = {1{`RANDOM}};
  reg_compare_du_wu_1 = _RAND_86[31:0];
  _RAND_87 = {1{`RANDOM}};
  reg_compare_du_wu_2 = _RAND_87[31:0];
  _RAND_88 = {1{`RANDOM}};
  reg_compare_du_wu_3 = _RAND_88[31:0];
  _RAND_89 = {1{`RANDOM}};
  reg_compare_ie_ee_0 = _RAND_89[31:0];
  _RAND_90 = {1{`RANDOM}};
  reg_compare_ie_ee_1 = _RAND_90[31:0];
  _RAND_91 = {1{`RANDOM}};
  reg_compare_ie_ee_2 = _RAND_91[31:0];
  _RAND_92 = {1{`RANDOM}};
  reg_compare_ie_ee_3 = _RAND_92[31:0];
  _RAND_93 = {1{`RANDOM}};
  reg_compare_du_wu_type_0 = _RAND_93[2:0];
  _RAND_94 = {1{`RANDOM}};
  reg_compare_du_wu_type_1 = _RAND_94[2:0];
  _RAND_95 = {1{`RANDOM}};
  reg_compare_du_wu_type_2 = _RAND_95[2:0];
  _RAND_96 = {1{`RANDOM}};
  reg_compare_du_wu_type_3 = _RAND_96[2:0];
  _RAND_97 = {1{`RANDOM}};
  reg_compare_ie_ee_type_0 = _RAND_97[2:0];
  _RAND_98 = {1{`RANDOM}};
  reg_compare_ie_ee_type_1 = _RAND_98[2:0];
  _RAND_99 = {1{`RANDOM}};
  reg_compare_ie_ee_type_2 = _RAND_99[2:0];
  _RAND_100 = {1{`RANDOM}};
  reg_compare_ie_ee_type_3 = _RAND_100[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Datapath(
  input         clock,
  input         reset,
  input  [2:0]  io_control_dec_imm_sel,
  input  [1:0]  io_control_dec_op1_sel,
  input  [1:0]  io_control_dec_op2_sel,
  input  [3:0]  io_control_exe_alu_type,
  input  [2:0]  io_control_exe_br_type,
  input  [1:0]  io_control_exe_csr_type,
  input  [1:0]  io_control_exe_rd_data_sel,
  input  [3:0]  io_control_exe_mem_type,
  input  [1:0]  io_control_mem_rd_data_sel,
  input  [1:0]  io_control_next_pc_sel_0,
  input  [1:0]  io_control_next_pc_sel_1,
  input  [1:0]  io_control_next_pc_sel_2,
  input  [1:0]  io_control_next_pc_sel_3,
  input  [11:0] io_control_next_pc_sel_csr_addr,
  input  [1:0]  io_control_next_tid,
  input         io_control_exe_load,
  input         io_control_exe_store,
  input         io_control_exe_csr_write,
  input         io_control_exe_exception,
  input  [4:0]  io_control_exe_cause,
  input         io_control_exe_kill,
  input         io_control_exe_sleep_du,
  input         io_control_exe_sleep_wu,
  input         io_control_exe_ie,
  input         io_control_exe_ee,
  input         io_control_exe_mret,
  input         io_control_exe_cycle,
  input         io_control_exe_instret,
  input         io_control_mem_rd_write,
  output [1:0]  io_control_if_tid,
  output [31:0] io_control_dec_inst,
  output        io_control_exe_br_cond,
  output [1:0]  io_control_exe_tid,
  output        io_control_exe_expire_du_0,
  output        io_control_exe_expire_du_1,
  output        io_control_exe_expire_du_2,
  output        io_control_exe_expire_du_3,
  output        io_control_exe_expire_ie_0,
  output        io_control_exe_expire_ie_1,
  output        io_control_exe_expire_ie_2,
  output        io_control_exe_expire_ie_3,
  output        io_control_exe_expire_ee_0,
  output        io_control_exe_expire_ee_1,
  output        io_control_exe_expire_ee_2,
  output        io_control_exe_expire_ee_3,
  output        io_control_timer_expire_du_wu_0,
  output        io_control_timer_expire_du_wu_1,
  output        io_control_timer_expire_du_wu_2,
  output        io_control_timer_expire_du_wu_3,
  output [1:0]  io_control_csr_tmodes_0,
  output [1:0]  io_control_csr_tmodes_1,
  output [1:0]  io_control_csr_tmodes_2,
  output [1:0]  io_control_csr_tmodes_3,
  output [1:0]  io_control_mem_tid,
  output        io_control_if_exc_misaligned,
  output        io_control_if_exc_fault,
  output        io_control_exe_exc_load_misaligned,
  output        io_control_exe_exc_load_fault,
  output        io_control_exe_exc_store_misaligned,
  output        io_control_exe_exc_store_fault,
  output        io_control_exe_int_ext,
  output [15:0] io_imem_r_addr,
  input  [31:0] io_imem_r_data_out,
  output [15:0] io_imem_rw_addr,
  output        io_imem_rw_enable,
  input  [31:0] io_imem_rw_data_out,
  output        io_imem_rw_write,
  output [31:0] io_imem_rw_data_in,
  output [13:0] io_dmem_addr,
  output        io_dmem_enable,
  input  [31:0] io_dmem_data_out,
  output        io_dmem_byte_write_0,
  output        io_dmem_byte_write_1,
  output        io_dmem_byte_write_2,
  output        io_dmem_byte_write_3,
  output [31:0] io_dmem_data_in,
  output [9:0]  io_bus_addr,
  output        io_bus_enable,
  input  [31:0] io_bus_data_out,
  output        io_bus_write,
  output [31:0] io_bus_data_in,
  input         io_gpio_in_3,
  input         io_gpio_in_2,
  input         io_gpio_in_1,
  input         io_gpio_in_0,
  output [1:0]  io_gpio_out_3,
  output [1:0]  io_gpio_out_2,
  output [1:0]  io_gpio_out_1,
  output [1:0]  io_gpio_out_0,
  input         io_int_exts_0,
  input         io_int_exts_1,
  input         io_int_exts_2,
  input         io_int_exts_3
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
`endif // RANDOMIZE_REG_INIT
  wire  regfile_clock; // @[Datapath.scala 170:23]
  wire [1:0] regfile_io_read_0_thread; // @[Datapath.scala 170:23]
  wire [4:0] regfile_io_read_0_addr; // @[Datapath.scala 170:23]
  wire [31:0] regfile_io_read_0_data; // @[Datapath.scala 170:23]
  wire [1:0] regfile_io_read_1_thread; // @[Datapath.scala 170:23]
  wire [4:0] regfile_io_read_1_addr; // @[Datapath.scala 170:23]
  wire [31:0] regfile_io_read_1_data; // @[Datapath.scala 170:23]
  wire [1:0] regfile_io_write_0_thread; // @[Datapath.scala 170:23]
  wire [4:0] regfile_io_write_0_addr; // @[Datapath.scala 170:23]
  wire [31:0] regfile_io_write_0_data; // @[Datapath.scala 170:23]
  wire  regfile_io_write_0_enable; // @[Datapath.scala 170:23]
  wire [31:0] alu_io_op1; // @[Datapath.scala 284:19]
  wire [31:0] alu_io_op2; // @[Datapath.scala 284:19]
  wire [4:0] alu_io_shift; // @[Datapath.scala 284:19]
  wire [3:0] alu_io_func; // @[Datapath.scala 284:19]
  wire [31:0] alu_io_result; // @[Datapath.scala 284:19]
  wire  loadstore_clock; // @[Datapath.scala 320:25]
  wire  loadstore_reset; // @[Datapath.scala 320:25]
  wire [13:0] loadstore_io_dmem_addr; // @[Datapath.scala 320:25]
  wire  loadstore_io_dmem_enable; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_dmem_data_out; // @[Datapath.scala 320:25]
  wire  loadstore_io_dmem_byte_write_0; // @[Datapath.scala 320:25]
  wire  loadstore_io_dmem_byte_write_1; // @[Datapath.scala 320:25]
  wire  loadstore_io_dmem_byte_write_2; // @[Datapath.scala 320:25]
  wire  loadstore_io_dmem_byte_write_3; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_dmem_data_in; // @[Datapath.scala 320:25]
  wire [15:0] loadstore_io_imem_rw_addr; // @[Datapath.scala 320:25]
  wire  loadstore_io_imem_rw_enable; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_imem_rw_data_out; // @[Datapath.scala 320:25]
  wire  loadstore_io_imem_rw_write; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_imem_rw_data_in; // @[Datapath.scala 320:25]
  wire [9:0] loadstore_io_bus_addr; // @[Datapath.scala 320:25]
  wire  loadstore_io_bus_enable; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_bus_data_out; // @[Datapath.scala 320:25]
  wire  loadstore_io_bus_write; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_bus_data_in; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_addr; // @[Datapath.scala 320:25]
  wire [1:0] loadstore_io_thread; // @[Datapath.scala 320:25]
  wire  loadstore_io_load; // @[Datapath.scala 320:25]
  wire  loadstore_io_store; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_mem_type; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_data_in; // @[Datapath.scala 320:25]
  wire [31:0] loadstore_io_data_out; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_0; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_1; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_2; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_3; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_4; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_5; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_6; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_imem_protection_7; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_0; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_1; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_2; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_3; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_4; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_5; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_6; // @[Datapath.scala 320:25]
  wire [3:0] loadstore_io_dmem_protection_7; // @[Datapath.scala 320:25]
  wire  loadstore_io_kill; // @[Datapath.scala 320:25]
  wire  loadstore_io_load_misaligned; // @[Datapath.scala 320:25]
  wire  loadstore_io_load_fault; // @[Datapath.scala 320:25]
  wire  loadstore_io_store_misaligned; // @[Datapath.scala 320:25]
  wire  loadstore_io_store_fault; // @[Datapath.scala 320:25]
  wire  csr_clock; // @[Datapath.scala 340:19]
  wire  csr_reset; // @[Datapath.scala 340:19]
  wire [11:0] csr_io_rw_addr; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_rw_thread; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_rw_csr_type; // @[Datapath.scala 340:19]
  wire  csr_io_rw_write; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_rw_data_in; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_rw_data_out; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_tmodes_0; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_tmodes_1; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_tmodes_2; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_tmodes_3; // @[Datapath.scala 340:19]
  wire  csr_io_kill; // @[Datapath.scala 340:19]
  wire  csr_io_exception; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_epc; // @[Datapath.scala 340:19]
  wire [4:0] csr_io_cause; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_evecs_0; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_evecs_1; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_evecs_2; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_evecs_3; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_mepcs_0; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_mepcs_1; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_mepcs_2; // @[Datapath.scala 340:19]
  wire [31:0] csr_io_mepcs_3; // @[Datapath.scala 340:19]
  wire  csr_io_sleep_du; // @[Datapath.scala 340:19]
  wire  csr_io_sleep_wu; // @[Datapath.scala 340:19]
  wire  csr_io_ie; // @[Datapath.scala 340:19]
  wire  csr_io_ee; // @[Datapath.scala 340:19]
  wire  csr_io_expire_du_0; // @[Datapath.scala 340:19]
  wire  csr_io_expire_du_1; // @[Datapath.scala 340:19]
  wire  csr_io_expire_du_2; // @[Datapath.scala 340:19]
  wire  csr_io_expire_du_3; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ie_0; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ie_1; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ie_2; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ie_3; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ee_0; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ee_1; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ee_2; // @[Datapath.scala 340:19]
  wire  csr_io_expire_ee_3; // @[Datapath.scala 340:19]
  wire  csr_io_timer_expire_du_wu_0; // @[Datapath.scala 340:19]
  wire  csr_io_timer_expire_du_wu_1; // @[Datapath.scala 340:19]
  wire  csr_io_timer_expire_du_wu_2; // @[Datapath.scala 340:19]
  wire  csr_io_timer_expire_du_wu_3; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_if_tid; // @[Datapath.scala 340:19]
  wire  csr_io_mret; // @[Datapath.scala 340:19]
  wire  csr_io_gpio_in_3; // @[Datapath.scala 340:19]
  wire  csr_io_gpio_in_2; // @[Datapath.scala 340:19]
  wire  csr_io_gpio_in_1; // @[Datapath.scala 340:19]
  wire  csr_io_gpio_in_0; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_gpio_out_3; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_gpio_out_2; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_gpio_out_1; // @[Datapath.scala 340:19]
  wire [1:0] csr_io_gpio_out_0; // @[Datapath.scala 340:19]
  wire  csr_io_int_exts_0; // @[Datapath.scala 340:19]
  wire  csr_io_int_exts_1; // @[Datapath.scala 340:19]
  wire  csr_io_int_exts_2; // @[Datapath.scala 340:19]
  wire  csr_io_int_exts_3; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_0; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_1; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_2; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_3; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_4; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_5; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_6; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_imem_protection_7; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_0; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_1; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_2; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_3; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_4; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_5; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_6; // @[Datapath.scala 340:19]
  wire [3:0] csr_io_dmem_protection_7; // @[Datapath.scala 340:19]
  wire  csr_io_cycle; // @[Datapath.scala 340:19]
  wire  csr_io_instret; // @[Datapath.scala 340:19]
  wire  csr_io_int_ext; // @[Datapath.scala 340:19]
  reg [1:0] if_reg_tid; // @[Datapath.scala 49:23]
  reg [31:0] if_reg_pc; // @[Datapath.scala 50:44]
  reg [31:0] if_reg_pcs_0; // @[Datapath.scala 51:27]
  reg [31:0] if_reg_pcs_1; // @[Datapath.scala 51:27]
  reg [31:0] if_reg_pcs_2; // @[Datapath.scala 51:27]
  reg [31:0] if_reg_pcs_3; // @[Datapath.scala 51:27]
  reg [1:0] dec_reg_tid; // @[Datapath.scala 56:24]
  reg [31:0] dec_reg_pc; // @[Datapath.scala 57:23]
  reg [31:0] dec_reg_pc4; // @[Datapath.scala 58:24]
  reg [31:0] dec_reg_inst; // @[Datapath.scala 59:25]
  reg [1:0] exe_reg_tid; // @[Datapath.scala 63:24]
  reg [4:0] exe_reg_rd_addr; // @[Datapath.scala 64:28]
  reg [31:0] exe_reg_op1; // @[Datapath.scala 65:24]
  reg [31:0] exe_reg_op2; // @[Datapath.scala 66:24]
  reg [31:0] exe_reg_rs1_data; // @[Datapath.scala 67:29]
  reg [31:0] exe_reg_rs2_data; // @[Datapath.scala 68:29]
  reg [31:0] exe_reg_pc; // @[Datapath.scala 69:23]
  reg [31:0] exe_reg_pc4; // @[Datapath.scala 70:24]
  reg [11:0] exe_reg_csr_addr; // @[Datapath.scala 71:29]
  reg [31:0] exe_csr_data; // @[Datapath.scala 72:29]
  reg [1:0] mem_reg_tid; // @[Datapath.scala 84:24]
  reg [4:0] mem_reg_rd_addr; // @[Datapath.scala 85:28]
  reg [31:0] mem_reg_rd_data; // @[Datapath.scala 86:28]
  reg [31:0] mem_reg_address; // @[Datapath.scala 87:28]
  wire [1:0] _GEN_1 = 2'h1 == if_reg_tid ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0; // @[Datapath.scala 108:{43,43}]
  wire [1:0] _GEN_2 = 2'h2 == if_reg_tid ? io_control_next_pc_sel_2 : _GEN_1; // @[Datapath.scala 108:{43,43}]
  wire [1:0] _GEN_3 = 2'h3 == if_reg_tid ? io_control_next_pc_sel_3 : _GEN_2; // @[Datapath.scala 108:{43,43}]
  wire [31:0] if_pc_plus4 = if_reg_pc + 32'h4; // @[Datapath.scala 163:28]
  wire [31:0] _GEN_4 = 2'h0 == if_reg_tid ? if_pc_plus4 : if_reg_pcs_0; // @[Datapath.scala 106:19 109:{26,26}]
  wire [31:0] _GEN_5 = 2'h1 == if_reg_tid ? if_pc_plus4 : if_reg_pcs_1; // @[Datapath.scala 106:19 109:{26,26}]
  wire [31:0] _GEN_6 = 2'h2 == if_reg_tid ? if_pc_plus4 : if_reg_pcs_2; // @[Datapath.scala 106:19 109:{26,26}]
  wire [31:0] _GEN_7 = 2'h3 == if_reg_tid ? if_pc_plus4 : if_reg_pcs_3; // @[Datapath.scala 106:19 109:{26,26}]
  wire [31:0] _GEN_8 = _GEN_3 == 2'h1 ? _GEN_4 : if_reg_pcs_0; // @[Datapath.scala 106:19 108:58]
  wire [31:0] _GEN_9 = _GEN_3 == 2'h1 ? _GEN_5 : if_reg_pcs_1; // @[Datapath.scala 106:19 108:58]
  wire [31:0] _GEN_10 = _GEN_3 == 2'h1 ? _GEN_6 : if_reg_pcs_2; // @[Datapath.scala 106:19 108:58]
  wire [31:0] _GEN_11 = _GEN_3 == 2'h1 ? _GEN_7 : if_reg_pcs_3; // @[Datapath.scala 106:19 108:58]
  wire [1:0] _GEN_13 = 2'h1 == mem_reg_tid ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0; // @[Datapath.scala 116:{46,46}]
  wire [1:0] _GEN_14 = 2'h2 == mem_reg_tid ? io_control_next_pc_sel_2 : _GEN_13; // @[Datapath.scala 116:{46,46}]
  wire [1:0] _GEN_15 = 2'h3 == mem_reg_tid ? io_control_next_pc_sel_3 : _GEN_14; // @[Datapath.scala 116:{46,46}]
  wire [31:0] _GEN_16 = 2'h0 == mem_reg_tid ? mem_reg_address : _GEN_8; // @[Datapath.scala 117:{29,29}]
  wire [31:0] _GEN_17 = 2'h1 == mem_reg_tid ? mem_reg_address : _GEN_9; // @[Datapath.scala 117:{29,29}]
  wire [31:0] _GEN_18 = 2'h2 == mem_reg_tid ? mem_reg_address : _GEN_10; // @[Datapath.scala 117:{29,29}]
  wire [31:0] _GEN_19 = 2'h3 == mem_reg_tid ? mem_reg_address : _GEN_11; // @[Datapath.scala 117:{29,29}]
  wire [31:0] _GEN_20 = _GEN_15 == 2'h2 ? _GEN_16 : _GEN_8; // @[Datapath.scala 116:61]
  wire [31:0] _GEN_21 = _GEN_15 == 2'h2 ? _GEN_17 : _GEN_9; // @[Datapath.scala 116:61]
  wire [31:0] _GEN_22 = _GEN_15 == 2'h2 ? _GEN_18 : _GEN_10; // @[Datapath.scala 116:61]
  wire [31:0] _GEN_23 = _GEN_15 == 2'h2 ? _GEN_19 : _GEN_11; // @[Datapath.scala 116:61]
  wire [31:0] _GEN_68 = csr_io_evecs_0; // @[Datapath.scala 446:{12,12}]
  wire [31:0] _GEN_69 = 2'h1 == mem_reg_tid ? csr_io_evecs_1 : _GEN_68; // @[Datapath.scala 446:{12,12}]
  wire [31:0] _GEN_70 = 2'h2 == mem_reg_tid ? csr_io_evecs_2 : _GEN_69; // @[Datapath.scala 446:{12,12}]
  wire [31:0] mem_evec = 2'h3 == mem_reg_tid ? csr_io_evecs_3 : _GEN_70; // @[Datapath.scala 446:{12,12}]
  wire [31:0] _GEN_28 = 2'h0 == mem_reg_tid ? mem_evec : _GEN_20; // @[Datapath.scala 131:{33,33}]
  wire [31:0] _GEN_29 = 2'h1 == mem_reg_tid ? mem_evec : _GEN_21; // @[Datapath.scala 131:{33,33}]
  wire [31:0] _GEN_30 = 2'h2 == mem_reg_tid ? mem_evec : _GEN_22; // @[Datapath.scala 131:{33,33}]
  wire [31:0] _GEN_31 = 2'h3 == mem_reg_tid ? mem_evec : _GEN_23; // @[Datapath.scala 131:{33,33}]
  wire [31:0] _GEN_32 = io_control_next_pc_sel_csr_addr == 12'h508 ? _GEN_28 : _GEN_20; // @[Datapath.scala 130:63]
  wire [31:0] _GEN_33 = io_control_next_pc_sel_csr_addr == 12'h508 ? _GEN_29 : _GEN_21; // @[Datapath.scala 130:63]
  wire [31:0] _GEN_34 = io_control_next_pc_sel_csr_addr == 12'h508 ? _GEN_30 : _GEN_22; // @[Datapath.scala 130:63]
  wire [31:0] _GEN_35 = io_control_next_pc_sel_csr_addr == 12'h508 ? _GEN_31 : _GEN_23; // @[Datapath.scala 130:63]
  wire [31:0] _GEN_36 = _GEN_15 == 2'h3 ? _GEN_32 : _GEN_20; // @[Datapath.scala 129:61]
  wire [31:0] _GEN_37 = _GEN_15 == 2'h3 ? _GEN_33 : _GEN_21; // @[Datapath.scala 129:61]
  wire [31:0] _GEN_38 = _GEN_15 == 2'h3 ? _GEN_34 : _GEN_22; // @[Datapath.scala 129:61]
  wire [31:0] _GEN_39 = _GEN_15 == 2'h3 ? _GEN_35 : _GEN_23; // @[Datapath.scala 129:61]
  wire [1:0] _GEN_41 = 2'h1 == exe_reg_tid ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0; // @[Datapath.scala 137:{44,44}]
  wire [1:0] _GEN_42 = 2'h2 == exe_reg_tid ? io_control_next_pc_sel_2 : _GEN_41; // @[Datapath.scala 137:{44,44}]
  wire [1:0] _GEN_43 = 2'h3 == exe_reg_tid ? io_control_next_pc_sel_3 : _GEN_42; // @[Datapath.scala 137:{44,44}]
  wire [31:0] _GEN_64 = csr_io_mepcs_0; // @[Datapath.scala 383:{13,13}]
  wire [31:0] _GEN_65 = 2'h1 == exe_reg_tid ? csr_io_mepcs_1 : _GEN_64; // @[Datapath.scala 383:{13,13}]
  wire [31:0] _GEN_66 = 2'h2 == exe_reg_tid ? csr_io_mepcs_2 : _GEN_65; // @[Datapath.scala 383:{13,13}]
  wire [31:0] exe_mepc = 2'h3 == exe_reg_tid ? csr_io_mepcs_3 : _GEN_66; // @[Datapath.scala 383:{13,13}]
  wire [31:0] _GEN_44 = 2'h0 == exe_reg_tid ? exe_mepc : _GEN_36; // @[Datapath.scala 139:{29,29}]
  wire [31:0] _GEN_45 = 2'h1 == exe_reg_tid ? exe_mepc : _GEN_37; // @[Datapath.scala 139:{29,29}]
  wire [31:0] _GEN_46 = 2'h2 == exe_reg_tid ? exe_mepc : _GEN_38; // @[Datapath.scala 139:{29,29}]
  wire [31:0] _GEN_47 = 2'h3 == exe_reg_tid ? exe_mepc : _GEN_39; // @[Datapath.scala 139:{29,29}]
  wire [31:0] _GEN_48 = io_control_next_pc_sel_csr_addr == 12'h511 ? _GEN_44 : _GEN_36; // @[Datapath.scala 138:59]
  wire [31:0] _GEN_49 = io_control_next_pc_sel_csr_addr == 12'h511 ? _GEN_45 : _GEN_37; // @[Datapath.scala 138:59]
  wire [31:0] _GEN_50 = io_control_next_pc_sel_csr_addr == 12'h511 ? _GEN_46 : _GEN_38; // @[Datapath.scala 138:59]
  wire [31:0] _GEN_51 = io_control_next_pc_sel_csr_addr == 12'h511 ? _GEN_47 : _GEN_39; // @[Datapath.scala 138:59]
  wire [31:0] next_pcs_0 = _GEN_43 == 2'h3 ? _GEN_48 : _GEN_36; // @[Datapath.scala 137:57]
  wire [31:0] next_pcs_1 = _GEN_43 == 2'h3 ? _GEN_49 : _GEN_37; // @[Datapath.scala 137:57]
  wire [31:0] next_pcs_2 = _GEN_43 == 2'h3 ? _GEN_50 : _GEN_38; // @[Datapath.scala 137:57]
  wire [31:0] next_pcs_3 = _GEN_43 == 2'h3 ? _GEN_51 : _GEN_39; // @[Datapath.scala 137:57]
  wire [31:0] _GEN_57 = 2'h1 == io_control_next_tid ? next_pcs_1 : next_pcs_0; // @[Datapath.scala 150:{28,28}]
  wire [31:0] _GEN_58 = 2'h2 == io_control_next_tid ? next_pcs_2 : _GEN_57; // @[Datapath.scala 150:{28,28}]
  wire [31:0] _GEN_59 = 2'h3 == io_control_next_tid ? next_pcs_3 : _GEN_58; // @[Datapath.scala 150:{28,28}]
  wire [20:0] _dec_imm_i_T_2 = dec_reg_inst[31] ? 21'h1fffff : 21'h0; // @[Bitwise.scala 77:12]
  wire [31:0] dec_imm_i = {_dec_imm_i_T_2,dec_reg_inst[30:20]}; // @[Cat.scala 33:92]
  wire [31:0] dec_imm_s = {_dec_imm_i_T_2,dec_reg_inst[30:25],dec_reg_inst[11:7]}; // @[Cat.scala 33:92]
  wire [19:0] _dec_imm_b_T_2 = dec_reg_inst[31] ? 20'hfffff : 20'h0; // @[Bitwise.scala 77:12]
  wire [31:0] dec_imm_b = {_dec_imm_b_T_2,dec_reg_inst[7],dec_reg_inst[30:25],dec_reg_inst[11:8],1'h0}; // @[Cat.scala 33:92]
  wire [31:0] dec_imm_u = {dec_reg_inst[31:12],12'h0}; // @[Cat.scala 33:92]
  wire [11:0] _dec_imm_j_T_2 = dec_reg_inst[31] ? 12'hfff : 12'h0; // @[Bitwise.scala 77:12]
  wire [31:0] dec_imm_j = {_dec_imm_j_T_2,dec_reg_inst[19:12],dec_reg_inst[20],dec_reg_inst[30:21],1'h0}; // @[Cat.scala 33:92]
  wire [31:0] dec_imm_z = {27'h0,dec_reg_inst[19:15]}; // @[Cat.scala 33:92]
  wire [31:0] _dec_imm_T_1 = 3'h0 == io_control_dec_imm_sel ? dec_imm_s : dec_imm_i; // @[Mux.scala 81:58]
  wire [31:0] _dec_imm_T_3 = 3'h1 == io_control_dec_imm_sel ? dec_imm_b : _dec_imm_T_1; // @[Mux.scala 81:58]
  wire [31:0] _dec_imm_T_5 = 3'h2 == io_control_dec_imm_sel ? dec_imm_u : _dec_imm_T_3; // @[Mux.scala 81:58]
  wire [31:0] dec_rs1_data = regfile_io_read_0_data; // @[Datapath.scala 210:26 228:18]
  wire [31:0] dec_rs2_data = regfile_io_read_1_data; // @[Datapath.scala 211:26 229:18]
  wire  exe_lt = $signed(exe_reg_rs1_data) < $signed(exe_reg_rs2_data); // @[Datapath.scala 295:40]
  wire  exe_ltu = exe_reg_rs1_data < exe_reg_rs2_data; // @[Datapath.scala 296:34]
  wire  exe_eq = exe_reg_rs1_data == exe_reg_rs2_data; // @[Datapath.scala 297:33]
  wire  _exe_br_cond_T = ~exe_eq; // @[Datapath.scala 303:14]
  wire  _exe_br_cond_T_1 = ~exe_lt; // @[Datapath.scala 304:14]
  wire  _exe_br_cond_T_2 = ~exe_ltu; // @[Datapath.scala 305:15]
  wire  _exe_br_cond_T_6 = 3'h2 == io_control_exe_br_type ? exe_lt : 3'h0 == io_control_exe_br_type & exe_eq; // @[Mux.scala 81:58]
  wire  _exe_br_cond_T_8 = 3'h4 == io_control_exe_br_type ? exe_ltu : _exe_br_cond_T_6; // @[Mux.scala 81:58]
  wire  _exe_br_cond_T_10 = 3'h1 == io_control_exe_br_type ? _exe_br_cond_T : _exe_br_cond_T_8; // @[Mux.scala 81:58]
  wire  _exe_br_cond_T_12 = 3'h3 == io_control_exe_br_type ? _exe_br_cond_T_1 : _exe_br_cond_T_10; // @[Mux.scala 81:58]
  wire [31:0] exe_alu_result = alu_io_result; // @[Datapath.scala 289:18 74:28]
  RegisterFile regfile ( // @[Datapath.scala 170:23]
    .clock(regfile_clock),
    .io_read_0_thread(regfile_io_read_0_thread),
    .io_read_0_addr(regfile_io_read_0_addr),
    .io_read_0_data(regfile_io_read_0_data),
    .io_read_1_thread(regfile_io_read_1_thread),
    .io_read_1_addr(regfile_io_read_1_addr),
    .io_read_1_data(regfile_io_read_1_data),
    .io_write_0_thread(regfile_io_write_0_thread),
    .io_write_0_addr(regfile_io_write_0_addr),
    .io_write_0_data(regfile_io_write_0_data),
    .io_write_0_enable(regfile_io_write_0_enable)
  );
  ALU alu ( // @[Datapath.scala 284:19]
    .io_op1(alu_io_op1),
    .io_op2(alu_io_op2),
    .io_shift(alu_io_shift),
    .io_func(alu_io_func),
    .io_result(alu_io_result)
  );
  LoadStore loadstore ( // @[Datapath.scala 320:25]
    .clock(loadstore_clock),
    .reset(loadstore_reset),
    .io_dmem_addr(loadstore_io_dmem_addr),
    .io_dmem_enable(loadstore_io_dmem_enable),
    .io_dmem_data_out(loadstore_io_dmem_data_out),
    .io_dmem_byte_write_0(loadstore_io_dmem_byte_write_0),
    .io_dmem_byte_write_1(loadstore_io_dmem_byte_write_1),
    .io_dmem_byte_write_2(loadstore_io_dmem_byte_write_2),
    .io_dmem_byte_write_3(loadstore_io_dmem_byte_write_3),
    .io_dmem_data_in(loadstore_io_dmem_data_in),
    .io_imem_rw_addr(loadstore_io_imem_rw_addr),
    .io_imem_rw_enable(loadstore_io_imem_rw_enable),
    .io_imem_rw_data_out(loadstore_io_imem_rw_data_out),
    .io_imem_rw_write(loadstore_io_imem_rw_write),
    .io_imem_rw_data_in(loadstore_io_imem_rw_data_in),
    .io_bus_addr(loadstore_io_bus_addr),
    .io_bus_enable(loadstore_io_bus_enable),
    .io_bus_data_out(loadstore_io_bus_data_out),
    .io_bus_write(loadstore_io_bus_write),
    .io_bus_data_in(loadstore_io_bus_data_in),
    .io_addr(loadstore_io_addr),
    .io_thread(loadstore_io_thread),
    .io_load(loadstore_io_load),
    .io_store(loadstore_io_store),
    .io_mem_type(loadstore_io_mem_type),
    .io_data_in(loadstore_io_data_in),
    .io_data_out(loadstore_io_data_out),
    .io_imem_protection_0(loadstore_io_imem_protection_0),
    .io_imem_protection_1(loadstore_io_imem_protection_1),
    .io_imem_protection_2(loadstore_io_imem_protection_2),
    .io_imem_protection_3(loadstore_io_imem_protection_3),
    .io_imem_protection_4(loadstore_io_imem_protection_4),
    .io_imem_protection_5(loadstore_io_imem_protection_5),
    .io_imem_protection_6(loadstore_io_imem_protection_6),
    .io_imem_protection_7(loadstore_io_imem_protection_7),
    .io_dmem_protection_0(loadstore_io_dmem_protection_0),
    .io_dmem_protection_1(loadstore_io_dmem_protection_1),
    .io_dmem_protection_2(loadstore_io_dmem_protection_2),
    .io_dmem_protection_3(loadstore_io_dmem_protection_3),
    .io_dmem_protection_4(loadstore_io_dmem_protection_4),
    .io_dmem_protection_5(loadstore_io_dmem_protection_5),
    .io_dmem_protection_6(loadstore_io_dmem_protection_6),
    .io_dmem_protection_7(loadstore_io_dmem_protection_7),
    .io_kill(loadstore_io_kill),
    .io_load_misaligned(loadstore_io_load_misaligned),
    .io_load_fault(loadstore_io_load_fault),
    .io_store_misaligned(loadstore_io_store_misaligned),
    .io_store_fault(loadstore_io_store_fault)
  );
  CSR csr ( // @[Datapath.scala 340:19]
    .clock(csr_clock),
    .reset(csr_reset),
    .io_rw_addr(csr_io_rw_addr),
    .io_rw_thread(csr_io_rw_thread),
    .io_rw_csr_type(csr_io_rw_csr_type),
    .io_rw_write(csr_io_rw_write),
    .io_rw_data_in(csr_io_rw_data_in),
    .io_rw_data_out(csr_io_rw_data_out),
    .io_tmodes_0(csr_io_tmodes_0),
    .io_tmodes_1(csr_io_tmodes_1),
    .io_tmodes_2(csr_io_tmodes_2),
    .io_tmodes_3(csr_io_tmodes_3),
    .io_kill(csr_io_kill),
    .io_exception(csr_io_exception),
    .io_epc(csr_io_epc),
    .io_cause(csr_io_cause),
    .io_evecs_0(csr_io_evecs_0),
    .io_evecs_1(csr_io_evecs_1),
    .io_evecs_2(csr_io_evecs_2),
    .io_evecs_3(csr_io_evecs_3),
    .io_mepcs_0(csr_io_mepcs_0),
    .io_mepcs_1(csr_io_mepcs_1),
    .io_mepcs_2(csr_io_mepcs_2),
    .io_mepcs_3(csr_io_mepcs_3),
    .io_sleep_du(csr_io_sleep_du),
    .io_sleep_wu(csr_io_sleep_wu),
    .io_ie(csr_io_ie),
    .io_ee(csr_io_ee),
    .io_expire_du_0(csr_io_expire_du_0),
    .io_expire_du_1(csr_io_expire_du_1),
    .io_expire_du_2(csr_io_expire_du_2),
    .io_expire_du_3(csr_io_expire_du_3),
    .io_expire_ie_0(csr_io_expire_ie_0),
    .io_expire_ie_1(csr_io_expire_ie_1),
    .io_expire_ie_2(csr_io_expire_ie_2),
    .io_expire_ie_3(csr_io_expire_ie_3),
    .io_expire_ee_0(csr_io_expire_ee_0),
    .io_expire_ee_1(csr_io_expire_ee_1),
    .io_expire_ee_2(csr_io_expire_ee_2),
    .io_expire_ee_3(csr_io_expire_ee_3),
    .io_timer_expire_du_wu_0(csr_io_timer_expire_du_wu_0),
    .io_timer_expire_du_wu_1(csr_io_timer_expire_du_wu_1),
    .io_timer_expire_du_wu_2(csr_io_timer_expire_du_wu_2),
    .io_timer_expire_du_wu_3(csr_io_timer_expire_du_wu_3),
    .io_if_tid(csr_io_if_tid),
    .io_mret(csr_io_mret),
    .io_gpio_in_3(csr_io_gpio_in_3),
    .io_gpio_in_2(csr_io_gpio_in_2),
    .io_gpio_in_1(csr_io_gpio_in_1),
    .io_gpio_in_0(csr_io_gpio_in_0),
    .io_gpio_out_3(csr_io_gpio_out_3),
    .io_gpio_out_2(csr_io_gpio_out_2),
    .io_gpio_out_1(csr_io_gpio_out_1),
    .io_gpio_out_0(csr_io_gpio_out_0),
    .io_int_exts_0(csr_io_int_exts_0),
    .io_int_exts_1(csr_io_int_exts_1),
    .io_int_exts_2(csr_io_int_exts_2),
    .io_int_exts_3(csr_io_int_exts_3),
    .io_imem_protection_0(csr_io_imem_protection_0),
    .io_imem_protection_1(csr_io_imem_protection_1),
    .io_imem_protection_2(csr_io_imem_protection_2),
    .io_imem_protection_3(csr_io_imem_protection_3),
    .io_imem_protection_4(csr_io_imem_protection_4),
    .io_imem_protection_5(csr_io_imem_protection_5),
    .io_imem_protection_6(csr_io_imem_protection_6),
    .io_imem_protection_7(csr_io_imem_protection_7),
    .io_dmem_protection_0(csr_io_dmem_protection_0),
    .io_dmem_protection_1(csr_io_dmem_protection_1),
    .io_dmem_protection_2(csr_io_dmem_protection_2),
    .io_dmem_protection_3(csr_io_dmem_protection_3),
    .io_dmem_protection_4(csr_io_dmem_protection_4),
    .io_dmem_protection_5(csr_io_dmem_protection_5),
    .io_dmem_protection_6(csr_io_dmem_protection_6),
    .io_dmem_protection_7(csr_io_dmem_protection_7),
    .io_cycle(csr_io_cycle),
    .io_instret(csr_io_instret),
    .io_int_ext(csr_io_int_ext)
  );
  assign io_control_if_tid = if_reg_tid; // @[Datapath.scala 181:21]
  assign io_control_dec_inst = dec_reg_inst; // @[Datapath.scala 264:23]
  assign io_control_exe_br_cond = 3'h5 == io_control_exe_br_type ? _exe_br_cond_T_2 : _exe_br_cond_T_12; // @[Mux.scala 81:58]
  assign io_control_exe_tid = exe_reg_tid; // @[Datapath.scala 397:22]
  assign io_control_exe_expire_du_0 = csr_io_expire_du_0; // @[Datapath.scala 362:28]
  assign io_control_exe_expire_du_1 = csr_io_expire_du_1; // @[Datapath.scala 362:28]
  assign io_control_exe_expire_du_2 = csr_io_expire_du_2; // @[Datapath.scala 362:28]
  assign io_control_exe_expire_du_3 = csr_io_expire_du_3; // @[Datapath.scala 362:28]
  assign io_control_exe_expire_ie_0 = csr_io_expire_ie_0; // @[Datapath.scala 364:28]
  assign io_control_exe_expire_ie_1 = csr_io_expire_ie_1; // @[Datapath.scala 364:28]
  assign io_control_exe_expire_ie_2 = csr_io_expire_ie_2; // @[Datapath.scala 364:28]
  assign io_control_exe_expire_ie_3 = csr_io_expire_ie_3; // @[Datapath.scala 364:28]
  assign io_control_exe_expire_ee_0 = csr_io_expire_ee_0; // @[Datapath.scala 365:28]
  assign io_control_exe_expire_ee_1 = csr_io_expire_ee_1; // @[Datapath.scala 365:28]
  assign io_control_exe_expire_ee_2 = csr_io_expire_ee_2; // @[Datapath.scala 365:28]
  assign io_control_exe_expire_ee_3 = csr_io_expire_ee_3; // @[Datapath.scala 365:28]
  assign io_control_timer_expire_du_wu_0 = csr_io_timer_expire_du_wu_0; // @[Datapath.scala 366:33]
  assign io_control_timer_expire_du_wu_1 = csr_io_timer_expire_du_wu_1; // @[Datapath.scala 366:33]
  assign io_control_timer_expire_du_wu_2 = csr_io_timer_expire_du_wu_2; // @[Datapath.scala 366:33]
  assign io_control_timer_expire_du_wu_3 = csr_io_timer_expire_du_wu_3; // @[Datapath.scala 366:33]
  assign io_control_csr_tmodes_0 = csr_io_tmodes_0; // @[Datapath.scala 436:25]
  assign io_control_csr_tmodes_1 = csr_io_tmodes_1; // @[Datapath.scala 436:25]
  assign io_control_csr_tmodes_2 = csr_io_tmodes_2; // @[Datapath.scala 436:25]
  assign io_control_csr_tmodes_3 = csr_io_tmodes_3; // @[Datapath.scala 436:25]
  assign io_control_mem_tid = mem_reg_tid; // @[Datapath.scala 431:22]
  assign io_control_if_exc_misaligned = if_reg_pc[1:0] != 2'h0; // @[Datapath.scala 186:53]
  assign io_control_if_exc_fault = if_reg_pc[31:18] != 14'h0; // @[Datapath.scala 193:69]
  assign io_control_exe_exc_load_misaligned = loadstore_io_load_misaligned; // @[Datapath.scala 403:38]
  assign io_control_exe_exc_load_fault = loadstore_io_load_fault; // @[Datapath.scala 404:33]
  assign io_control_exe_exc_store_misaligned = loadstore_io_store_misaligned; // @[Datapath.scala 405:39]
  assign io_control_exe_exc_store_fault = loadstore_io_store_fault; // @[Datapath.scala 406:34]
  assign io_control_exe_int_ext = csr_io_int_ext; // @[Datapath.scala 401:26]
  assign io_imem_r_addr = _GEN_59[17:2]; // @[Datapath.scala 150:18]
  assign io_imem_rw_addr = loadstore_io_imem_rw_addr; // @[Datapath.scala 324:24]
  assign io_imem_rw_enable = loadstore_io_imem_rw_enable; // @[Datapath.scala 324:24]
  assign io_imem_rw_write = loadstore_io_imem_rw_write; // @[Datapath.scala 324:24]
  assign io_imem_rw_data_in = loadstore_io_imem_rw_data_in; // @[Datapath.scala 324:24]
  assign io_dmem_addr = loadstore_io_dmem_addr; // @[Datapath.scala 322:21]
  assign io_dmem_enable = loadstore_io_dmem_enable; // @[Datapath.scala 322:21]
  assign io_dmem_byte_write_0 = loadstore_io_dmem_byte_write_0; // @[Datapath.scala 322:21]
  assign io_dmem_byte_write_1 = loadstore_io_dmem_byte_write_1; // @[Datapath.scala 322:21]
  assign io_dmem_byte_write_2 = loadstore_io_dmem_byte_write_2; // @[Datapath.scala 322:21]
  assign io_dmem_byte_write_3 = loadstore_io_dmem_byte_write_3; // @[Datapath.scala 322:21]
  assign io_dmem_data_in = loadstore_io_dmem_data_in; // @[Datapath.scala 322:21]
  assign io_bus_addr = loadstore_io_bus_addr; // @[Datapath.scala 325:20]
  assign io_bus_enable = loadstore_io_bus_enable; // @[Datapath.scala 325:20]
  assign io_bus_write = loadstore_io_bus_write; // @[Datapath.scala 325:20]
  assign io_bus_data_in = loadstore_io_bus_data_in; // @[Datapath.scala 325:20]
  assign io_gpio_out_3 = csr_io_gpio_out_3; // @[Datapath.scala 442:11]
  assign io_gpio_out_2 = csr_io_gpio_out_2; // @[Datapath.scala 442:11]
  assign io_gpio_out_1 = csr_io_gpio_out_1; // @[Datapath.scala 442:11]
  assign io_gpio_out_0 = csr_io_gpio_out_0; // @[Datapath.scala 442:11]
  assign regfile_clock = clock;
  assign regfile_io_read_0_thread = if_reg_tid; // @[Datapath.scala 171:29]
  assign regfile_io_read_0_addr = io_imem_r_data_out[19:15]; // @[Datapath.scala 173:37]
  assign regfile_io_read_1_thread = if_reg_tid; // @[Datapath.scala 175:29]
  assign regfile_io_read_1_addr = io_imem_r_data_out[24:20]; // @[Datapath.scala 177:37]
  assign regfile_io_write_0_thread = mem_reg_tid; // @[Datapath.scala 426:30]
  assign regfile_io_write_0_addr = mem_reg_rd_addr; // @[Datapath.scala 427:28]
  assign regfile_io_write_0_data = io_control_mem_rd_data_sel == 2'h1 ? loadstore_io_data_out : mem_reg_rd_data; // @[Datapath.scala 419:8]
  assign regfile_io_write_0_enable = io_control_mem_rd_write; // @[Datapath.scala 429:30]
  assign alu_io_op1 = exe_reg_op1; // @[Datapath.scala 285:14]
  assign alu_io_op2 = exe_reg_op2; // @[Datapath.scala 286:14]
  assign alu_io_shift = exe_reg_op2[4:0]; // @[Datapath.scala 287:30]
  assign alu_io_func = io_control_exe_alu_type; // @[Datapath.scala 288:15]
  assign loadstore_clock = clock;
  assign loadstore_reset = reset;
  assign loadstore_io_dmem_data_out = io_dmem_data_out; // @[Datapath.scala 322:21]
  assign loadstore_io_imem_rw_data_out = io_imem_rw_data_out; // @[Datapath.scala 324:24]
  assign loadstore_io_bus_data_out = io_bus_data_out; // @[Datapath.scala 325:20]
  assign loadstore_io_addr = alu_io_result; // @[Datapath.scala 289:18 74:28]
  assign loadstore_io_thread = exe_reg_tid; // @[Datapath.scala 328:23]
  assign loadstore_io_load = io_control_exe_load; // @[Datapath.scala 329:21]
  assign loadstore_io_store = io_control_exe_store; // @[Datapath.scala 330:22]
  assign loadstore_io_mem_type = io_control_exe_mem_type; // @[Datapath.scala 331:25]
  assign loadstore_io_data_in = exe_reg_rs2_data; // @[Datapath.scala 332:24]
  assign loadstore_io_imem_protection_0 = csr_io_imem_protection_0; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_1 = csr_io_imem_protection_1; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_2 = csr_io_imem_protection_2; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_3 = csr_io_imem_protection_3; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_4 = csr_io_imem_protection_4; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_5 = csr_io_imem_protection_5; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_6 = csr_io_imem_protection_6; // @[Datapath.scala 387:32]
  assign loadstore_io_imem_protection_7 = csr_io_imem_protection_7; // @[Datapath.scala 387:32]
  assign loadstore_io_dmem_protection_0 = csr_io_dmem_protection_0; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_1 = csr_io_dmem_protection_1; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_2 = csr_io_dmem_protection_2; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_3 = csr_io_dmem_protection_3; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_4 = csr_io_dmem_protection_4; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_5 = csr_io_dmem_protection_5; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_6 = csr_io_dmem_protection_6; // @[Datapath.scala 386:32]
  assign loadstore_io_dmem_protection_7 = csr_io_dmem_protection_7; // @[Datapath.scala 386:32]
  assign loadstore_io_kill = io_control_exe_kill; // @[Datapath.scala 334:21]
  assign csr_clock = clock;
  assign csr_reset = reset;
  assign csr_io_rw_addr = exe_reg_csr_addr; // @[Datapath.scala 343:18]
  assign csr_io_rw_thread = exe_reg_tid; // @[Datapath.scala 344:20]
  assign csr_io_rw_csr_type = io_control_exe_csr_type; // @[Datapath.scala 345:22]
  assign csr_io_rw_write = io_control_exe_csr_write; // @[Datapath.scala 346:19]
  assign csr_io_rw_data_in = exe_csr_data; // @[Datapath.scala 347:21]
  assign csr_io_kill = io_control_exe_kill; // @[Datapath.scala 351:15]
  assign csr_io_exception = io_control_exe_exception; // @[Datapath.scala 352:20]
  assign csr_io_epc = exe_reg_pc; // @[Datapath.scala 353:14]
  assign csr_io_cause = io_control_exe_cause; // @[Datapath.scala 354:16]
  assign csr_io_sleep_du = io_control_exe_sleep_du; // @[Datapath.scala 357:19]
  assign csr_io_sleep_wu = io_control_exe_sleep_wu; // @[Datapath.scala 358:19]
  assign csr_io_ie = io_control_exe_ie; // @[Datapath.scala 360:13]
  assign csr_io_ee = io_control_exe_ee; // @[Datapath.scala 361:13]
  assign csr_io_if_tid = if_reg_tid; // @[Datapath.scala 368:17]
  assign csr_io_mret = io_control_exe_mret; // @[Datapath.scala 372:15]
  assign csr_io_gpio_in_3 = io_gpio_in_3; // @[Datapath.scala 442:11]
  assign csr_io_gpio_in_2 = io_gpio_in_2; // @[Datapath.scala 442:11]
  assign csr_io_gpio_in_1 = io_gpio_in_1; // @[Datapath.scala 442:11]
  assign csr_io_gpio_in_0 = io_gpio_in_0; // @[Datapath.scala 442:11]
  assign csr_io_int_exts_0 = io_int_exts_0; // @[Datapath.scala 375:19]
  assign csr_io_int_exts_1 = io_int_exts_1; // @[Datapath.scala 375:19]
  assign csr_io_int_exts_2 = io_int_exts_2; // @[Datapath.scala 375:19]
  assign csr_io_int_exts_3 = io_int_exts_3; // @[Datapath.scala 375:19]
  assign csr_io_cycle = io_control_exe_cycle; // @[Datapath.scala 378:16]
  assign csr_io_instret = io_control_exe_instret; // @[Datapath.scala 379:18]
  always @(posedge clock) begin
    if_reg_tid <= io_control_next_tid; // @[Datapath.scala 155:14]
    if (2'h3 == io_control_next_tid) begin // @[Datapath.scala 150:28]
      if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
        if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
          if (2'h3 == exe_reg_tid) begin // @[Datapath.scala 139:29]
            if_reg_pc <= exe_mepc; // @[Datapath.scala 139:29]
          end else begin
            if_reg_pc <= _GEN_39;
          end
        end else begin
          if_reg_pc <= _GEN_39;
        end
      end else begin
        if_reg_pc <= _GEN_39;
      end
    end else if (2'h2 == io_control_next_tid) begin // @[Datapath.scala 150:28]
      if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
        if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
          if_reg_pc <= _GEN_46;
        end else begin
          if_reg_pc <= _GEN_38;
        end
      end else begin
        if_reg_pc <= _GEN_38;
      end
    end else if (2'h1 == io_control_next_tid) begin // @[Datapath.scala 150:28]
      if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
        if_reg_pc <= _GEN_49;
      end else begin
        if_reg_pc <= _GEN_37;
      end
    end else if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
      if_reg_pc <= _GEN_48;
    end else begin
      if_reg_pc <= _GEN_36;
    end
    if (reset) begin // @[Datapath.scala 51:27]
      if_reg_pcs_0 <= 32'h0; // @[Datapath.scala 51:27]
    end else if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
      if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
        if (2'h0 == exe_reg_tid) begin // @[Datapath.scala 139:29]
          if_reg_pcs_0 <= exe_mepc; // @[Datapath.scala 139:29]
        end else begin
          if_reg_pcs_0 <= _GEN_36;
        end
      end else begin
        if_reg_pcs_0 <= _GEN_36;
      end
    end else begin
      if_reg_pcs_0 <= _GEN_36;
    end
    if (reset) begin // @[Datapath.scala 51:27]
      if_reg_pcs_1 <= 32'h0; // @[Datapath.scala 51:27]
    end else if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
      if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
        if (2'h1 == exe_reg_tid) begin // @[Datapath.scala 139:29]
          if_reg_pcs_1 <= exe_mepc; // @[Datapath.scala 139:29]
        end else begin
          if_reg_pcs_1 <= _GEN_37;
        end
      end else begin
        if_reg_pcs_1 <= _GEN_37;
      end
    end else begin
      if_reg_pcs_1 <= _GEN_37;
    end
    if (reset) begin // @[Datapath.scala 51:27]
      if_reg_pcs_2 <= 32'h0; // @[Datapath.scala 51:27]
    end else if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
      if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
        if (2'h2 == exe_reg_tid) begin // @[Datapath.scala 139:29]
          if_reg_pcs_2 <= exe_mepc; // @[Datapath.scala 139:29]
        end else begin
          if_reg_pcs_2 <= _GEN_38;
        end
      end else begin
        if_reg_pcs_2 <= _GEN_38;
      end
    end else begin
      if_reg_pcs_2 <= _GEN_38;
    end
    if (reset) begin // @[Datapath.scala 51:27]
      if_reg_pcs_3 <= 32'h0; // @[Datapath.scala 51:27]
    end else if (_GEN_43 == 2'h3) begin // @[Datapath.scala 137:57]
      if (io_control_next_pc_sel_csr_addr == 12'h511) begin // @[Datapath.scala 138:59]
        if (2'h3 == exe_reg_tid) begin // @[Datapath.scala 139:29]
          if_reg_pcs_3 <= exe_mepc; // @[Datapath.scala 139:29]
        end else begin
          if_reg_pcs_3 <= _GEN_39;
        end
      end else begin
        if_reg_pcs_3 <= _GEN_39;
      end
    end else begin
      if_reg_pcs_3 <= _GEN_39;
    end
    dec_reg_tid <= if_reg_tid; // @[Datapath.scala 199:15]
    dec_reg_pc <= if_reg_pc; // @[Datapath.scala 200:14]
    dec_reg_pc4 <= if_reg_pc + 32'h4; // @[Datapath.scala 163:28]
    dec_reg_inst <= io_imem_r_data_out; // @[Datapath.scala 202:16]
    exe_reg_tid <= dec_reg_tid; // @[Datapath.scala 268:15]
    exe_reg_rd_addr <= dec_reg_inst[11:7]; // @[Datapath.scala 269:34]
    if (2'h0 == io_control_dec_op1_sel) begin // @[Mux.scala 81:58]
      exe_reg_op1 <= dec_reg_pc;
    end else if (2'h1 == io_control_dec_op1_sel) begin // @[Mux.scala 81:58]
      exe_reg_op1 <= dec_rs1_data;
    end else begin
      exe_reg_op1 <= 32'h0;
    end
    if (2'h0 == io_control_dec_op2_sel) begin // @[Mux.scala 81:58]
      if (3'h5 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_reg_op2 <= dec_imm_z;
      end else if (3'h4 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_reg_op2 <= dec_imm_i;
      end else if (3'h3 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_reg_op2 <= dec_imm_j;
      end else begin
        exe_reg_op2 <= _dec_imm_T_5;
      end
    end else if (2'h1 == io_control_dec_op2_sel) begin // @[Mux.scala 81:58]
      exe_reg_op2 <= dec_rs2_data;
    end else begin
      exe_reg_op2 <= 32'h0;
    end
    exe_reg_rs1_data <= regfile_io_read_0_data; // @[Datapath.scala 210:26 228:18]
    exe_reg_rs2_data <= regfile_io_read_1_data; // @[Datapath.scala 211:26 229:18]
    exe_reg_pc <= dec_reg_pc; // @[Datapath.scala 274:14]
    exe_reg_pc4 <= dec_reg_pc4; // @[Datapath.scala 275:15]
    exe_reg_csr_addr <= dec_reg_inst[31:20]; // @[Datapath.scala 276:35]
    if (io_control_dec_op2_sel == 2'h0) begin // @[Datapath.scala 260:25]
      if (3'h5 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_csr_data <= dec_imm_z;
      end else if (3'h4 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_csr_data <= dec_imm_i;
      end else if (3'h3 == io_control_dec_imm_sel) begin // @[Mux.scala 81:58]
        exe_csr_data <= dec_imm_j;
      end else begin
        exe_csr_data <= _dec_imm_T_5;
      end
    end else begin
      exe_csr_data <= dec_rs1_data;
    end
    mem_reg_tid <= exe_reg_tid; // @[Datapath.scala 409:15]
    mem_reg_rd_addr <= exe_reg_rd_addr; // @[Datapath.scala 410:19]
    if (io_control_exe_rd_data_sel == 2'h1) begin // @[Datapath.scala 391:21]
      mem_reg_rd_data <= csr_io_rw_data_out;
    end else if (io_control_exe_rd_data_sel == 2'h2) begin // @[Datapath.scala 392:8]
      mem_reg_rd_data <= exe_reg_pc4;
    end else begin
      mem_reg_rd_data <= exe_alu_result;
    end
    mem_reg_address <= alu_io_result; // @[Datapath.scala 289:18 74:28]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  if_reg_tid = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  if_reg_pc = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  if_reg_pcs_0 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  if_reg_pcs_1 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  if_reg_pcs_2 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  if_reg_pcs_3 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  dec_reg_tid = _RAND_6[1:0];
  _RAND_7 = {1{`RANDOM}};
  dec_reg_pc = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  dec_reg_pc4 = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  dec_reg_inst = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  exe_reg_tid = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  exe_reg_rd_addr = _RAND_11[4:0];
  _RAND_12 = {1{`RANDOM}};
  exe_reg_op1 = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  exe_reg_op2 = _RAND_13[31:0];
  _RAND_14 = {1{`RANDOM}};
  exe_reg_rs1_data = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  exe_reg_rs2_data = _RAND_15[31:0];
  _RAND_16 = {1{`RANDOM}};
  exe_reg_pc = _RAND_16[31:0];
  _RAND_17 = {1{`RANDOM}};
  exe_reg_pc4 = _RAND_17[31:0];
  _RAND_18 = {1{`RANDOM}};
  exe_reg_csr_addr = _RAND_18[11:0];
  _RAND_19 = {1{`RANDOM}};
  exe_csr_data = _RAND_19[31:0];
  _RAND_20 = {1{`RANDOM}};
  mem_reg_tid = _RAND_20[1:0];
  _RAND_21 = {1{`RANDOM}};
  mem_reg_rd_addr = _RAND_21[4:0];
  _RAND_22 = {1{`RANDOM}};
  mem_reg_rd_data = _RAND_22[31:0];
  _RAND_23 = {1{`RANDOM}};
  mem_reg_address = _RAND_23[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ISpm(
  input         clock,
  input  [15:0] io_core_r_addr,
  output [31:0] io_core_r_data_out,
  input  [15:0] io_core_rw_addr,
  input         io_core_rw_enable,
  output [31:0] io_core_rw_data_out,
  input         io_core_rw_write,
  input  [31:0] io_core_rw_data_in
);
  wire  ispm_clk; // @[ispm.scala 65:20]
  wire  ispm_a_wr; // @[ispm.scala 65:20]
  wire [15:0] ispm_a_addr; // @[ispm.scala 65:20]
  wire [31:0] ispm_a_din; // @[ispm.scala 65:20]
  wire [31:0] ispm_a_dout; // @[ispm.scala 65:20]
  wire  ispm_b_wr; // @[ispm.scala 65:20]
  wire [15:0] ispm_b_addr; // @[ispm.scala 65:20]
  wire [31:0] ispm_b_din; // @[ispm.scala 65:20]
  wire [31:0] ispm_b_dout; // @[ispm.scala 65:20]
  wire [31:0] _GEN_1 = io_core_rw_write ? io_core_rw_data_in : 32'h0; // @[ispm.scala 104:32 106:21 78:32]
  wire [31:0] addr = io_core_rw_enable ? {{16'd0}, io_core_rw_addr} : 32'h0; // @[ispm.scala 101:31 102:14 77:27]
  DualPortBram #(.DATA(32), .ADDR(16)) ispm ( // @[ispm.scala 65:20]
    .clk(ispm_clk),
    .a_wr(ispm_a_wr),
    .a_addr(ispm_a_addr),
    .a_din(ispm_a_din),
    .a_dout(ispm_a_dout),
    .b_wr(ispm_b_wr),
    .b_addr(ispm_b_addr),
    .b_din(ispm_b_din),
    .b_dout(ispm_b_dout)
  );
  assign io_core_r_data_out = ispm_a_dout; // @[ispm.scala 72:22]
  assign io_core_rw_data_out = ispm_b_dout; // @[ispm.scala 100:27]
  assign ispm_clk = clock; // @[ispm.scala 66:15]
  assign ispm_a_wr = 1'h0; // @[ispm.scala 70:16]
  assign ispm_a_addr = io_core_r_addr; // @[ispm.scala 69:18]
  assign ispm_a_din = 32'h0; // @[ispm.scala 71:17]
  assign ispm_b_wr = io_core_rw_enable & io_core_rw_write; // @[ispm.scala 101:31 79:28]
  assign ispm_b_addr = addr[15:0]; // @[ispm.scala 80:20]
  assign ispm_b_din = io_core_rw_enable ? _GEN_1 : 32'h0; // @[ispm.scala 101:31 78:32]
endmodule
module DSpm(
  input         clock,
  input  [13:0] io_core_addr,
  input         io_core_enable,
  output [31:0] io_core_data_out,
  input         io_core_byte_write_0,
  input         io_core_byte_write_1,
  input         io_core_byte_write_2,
  input         io_core_byte_write_3,
  input  [31:0] io_core_data_in
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_9;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] dspm_0 [0:16383]; // @[dspm.scala 38:25]
  wire  dspm_0_corePort_en; // @[dspm.scala 38:25]
  wire [13:0] dspm_0_corePort_addr; // @[dspm.scala 38:25]
  wire [7:0] dspm_0_corePort_data; // @[dspm.scala 38:25]
  wire [7:0] dspm_0_MPORT_data; // @[dspm.scala 38:25]
  wire [13:0] dspm_0_MPORT_addr; // @[dspm.scala 38:25]
  wire  dspm_0_MPORT_mask; // @[dspm.scala 38:25]
  wire  dspm_0_MPORT_en; // @[dspm.scala 38:25]
  reg  dspm_0_corePort_en_pipe_0;
  reg [13:0] dspm_0_corePort_addr_pipe_0;
  reg [7:0] dspm_1 [0:16383]; // @[dspm.scala 38:25]
  wire  dspm_1_corePort_en; // @[dspm.scala 38:25]
  wire [13:0] dspm_1_corePort_addr; // @[dspm.scala 38:25]
  wire [7:0] dspm_1_corePort_data; // @[dspm.scala 38:25]
  wire [7:0] dspm_1_MPORT_data; // @[dspm.scala 38:25]
  wire [13:0] dspm_1_MPORT_addr; // @[dspm.scala 38:25]
  wire  dspm_1_MPORT_mask; // @[dspm.scala 38:25]
  wire  dspm_1_MPORT_en; // @[dspm.scala 38:25]
  reg  dspm_1_corePort_en_pipe_0;
  reg [13:0] dspm_1_corePort_addr_pipe_0;
  reg [7:0] dspm_2 [0:16383]; // @[dspm.scala 38:25]
  wire  dspm_2_corePort_en; // @[dspm.scala 38:25]
  wire [13:0] dspm_2_corePort_addr; // @[dspm.scala 38:25]
  wire [7:0] dspm_2_corePort_data; // @[dspm.scala 38:25]
  wire [7:0] dspm_2_MPORT_data; // @[dspm.scala 38:25]
  wire [13:0] dspm_2_MPORT_addr; // @[dspm.scala 38:25]
  wire  dspm_2_MPORT_mask; // @[dspm.scala 38:25]
  wire  dspm_2_MPORT_en; // @[dspm.scala 38:25]
  reg  dspm_2_corePort_en_pipe_0;
  reg [13:0] dspm_2_corePort_addr_pipe_0;
  reg [7:0] dspm_3 [0:16383]; // @[dspm.scala 38:25]
  wire  dspm_3_corePort_en; // @[dspm.scala 38:25]
  wire [13:0] dspm_3_corePort_addr; // @[dspm.scala 38:25]
  wire [7:0] dspm_3_corePort_data; // @[dspm.scala 38:25]
  wire [7:0] dspm_3_MPORT_data; // @[dspm.scala 38:25]
  wire [13:0] dspm_3_MPORT_addr; // @[dspm.scala 38:25]
  wire  dspm_3_MPORT_mask; // @[dspm.scala 38:25]
  wire  dspm_3_MPORT_en; // @[dspm.scala 38:25]
  reg  dspm_3_corePort_en_pipe_0;
  reg [13:0] dspm_3_corePort_addr_pipe_0;
  wire [15:0] io_core_data_out_lo = {dspm_1_corePort_data,dspm_0_corePort_data}; // @[dspm.scala 42:32]
  wire [15:0] io_core_data_out_hi = {dspm_3_corePort_data,dspm_2_corePort_data}; // @[dspm.scala 42:32]
  assign dspm_0_corePort_en = dspm_0_corePort_en_pipe_0;
  assign dspm_0_corePort_addr = dspm_0_corePort_addr_pipe_0;
  assign dspm_0_corePort_data = dspm_0[dspm_0_corePort_addr]; // @[dspm.scala 38:25]
  assign dspm_0_MPORT_data = io_core_data_in[7:0];
  assign dspm_0_MPORT_addr = io_core_addr;
  assign dspm_0_MPORT_mask = io_core_byte_write_0;
  assign dspm_0_MPORT_en = io_core_enable;
  assign dspm_1_corePort_en = dspm_1_corePort_en_pipe_0;
  assign dspm_1_corePort_addr = dspm_1_corePort_addr_pipe_0;
  assign dspm_1_corePort_data = dspm_1[dspm_1_corePort_addr]; // @[dspm.scala 38:25]
  assign dspm_1_MPORT_data = io_core_data_in[15:8];
  assign dspm_1_MPORT_addr = io_core_addr;
  assign dspm_1_MPORT_mask = io_core_byte_write_1;
  assign dspm_1_MPORT_en = io_core_enable;
  assign dspm_2_corePort_en = dspm_2_corePort_en_pipe_0;
  assign dspm_2_corePort_addr = dspm_2_corePort_addr_pipe_0;
  assign dspm_2_corePort_data = dspm_2[dspm_2_corePort_addr]; // @[dspm.scala 38:25]
  assign dspm_2_MPORT_data = io_core_data_in[23:16];
  assign dspm_2_MPORT_addr = io_core_addr;
  assign dspm_2_MPORT_mask = io_core_byte_write_2;
  assign dspm_2_MPORT_en = io_core_enable;
  assign dspm_3_corePort_en = dspm_3_corePort_en_pipe_0;
  assign dspm_3_corePort_addr = dspm_3_corePort_addr_pipe_0;
  assign dspm_3_corePort_data = dspm_3[dspm_3_corePort_addr]; // @[dspm.scala 38:25]
  assign dspm_3_MPORT_data = io_core_data_in[31:24];
  assign dspm_3_MPORT_addr = io_core_addr;
  assign dspm_3_MPORT_mask = io_core_byte_write_3;
  assign dspm_3_MPORT_en = io_core_enable;
  assign io_core_data_out = {io_core_data_out_hi,io_core_data_out_lo}; // @[dspm.scala 42:32]
  always @(posedge clock) begin
    if (dspm_0_MPORT_en & dspm_0_MPORT_mask) begin
      dspm_0[dspm_0_MPORT_addr] <= dspm_0_MPORT_data; // @[dspm.scala 38:25]
    end
    dspm_0_corePort_en_pipe_0 <= io_core_enable;
    if (io_core_enable) begin
      dspm_0_corePort_addr_pipe_0 <= io_core_addr;
    end
    if (dspm_1_MPORT_en & dspm_1_MPORT_mask) begin
      dspm_1[dspm_1_MPORT_addr] <= dspm_1_MPORT_data; // @[dspm.scala 38:25]
    end
    dspm_1_corePort_en_pipe_0 <= io_core_enable;
    if (io_core_enable) begin
      dspm_1_corePort_addr_pipe_0 <= io_core_addr;
    end
    if (dspm_2_MPORT_en & dspm_2_MPORT_mask) begin
      dspm_2[dspm_2_MPORT_addr] <= dspm_2_MPORT_data; // @[dspm.scala 38:25]
    end
    dspm_2_corePort_en_pipe_0 <= io_core_enable;
    if (io_core_enable) begin
      dspm_2_corePort_addr_pipe_0 <= io_core_addr;
    end
    if (dspm_3_MPORT_en & dspm_3_MPORT_mask) begin
      dspm_3[dspm_3_MPORT_addr] <= dspm_3_MPORT_data; // @[dspm.scala 38:25]
    end
    dspm_3_corePort_en_pipe_0 <= io_core_enable;
    if (io_core_enable) begin
      dspm_3_corePort_addr_pipe_0 <= io_core_addr;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16384; initvar = initvar+1)
    dspm_0[initvar] = _RAND_0[7:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16384; initvar = initvar+1)
    dspm_1[initvar] = _RAND_3[7:0];
  _RAND_6 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16384; initvar = initvar+1)
    dspm_2[initvar] = _RAND_6[7:0];
  _RAND_9 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16384; initvar = initvar+1)
    dspm_3[initvar] = _RAND_9[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  dspm_0_corePort_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  dspm_0_corePort_addr_pipe_0 = _RAND_2[13:0];
  _RAND_4 = {1{`RANDOM}};
  dspm_1_corePort_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  dspm_1_corePort_addr_pipe_0 = _RAND_5[13:0];
  _RAND_7 = {1{`RANDOM}};
  dspm_2_corePort_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  dspm_2_corePort_addr_pipe_0 = _RAND_8[13:0];
  _RAND_10 = {1{`RANDOM}};
  dspm_3_corePort_en_pipe_0 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  dspm_3_corePort_addr_pipe_0 = _RAND_11[13:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Core(
  input         clock,
  input         reset,
  output [9:0]  io_bus_addr,
  output        io_bus_enable,
  input  [31:0] io_bus_data_out,
  output        io_bus_write,
  output [31:0] io_bus_data_in,
  input         io_gpio_in_3,
  input         io_gpio_in_2,
  input         io_gpio_in_1,
  input         io_gpio_in_0,
  output [1:0]  io_gpio_out_3,
  output [1:0]  io_gpio_out_2,
  output [1:0]  io_gpio_out_1,
  output [1:0]  io_gpio_out_0,
  input         io_int_exts_0,
  input         io_int_exts_1,
  input         io_int_exts_2,
  input         io_int_exts_3
);
  wire  control_clock; // @[core.scala 90:23]
  wire  control_reset; // @[core.scala 90:23]
  wire [2:0] control_io_dec_imm_sel; // @[core.scala 90:23]
  wire [1:0] control_io_dec_op1_sel; // @[core.scala 90:23]
  wire [1:0] control_io_dec_op2_sel; // @[core.scala 90:23]
  wire [3:0] control_io_exe_alu_type; // @[core.scala 90:23]
  wire [2:0] control_io_exe_br_type; // @[core.scala 90:23]
  wire [1:0] control_io_exe_csr_type; // @[core.scala 90:23]
  wire [1:0] control_io_exe_rd_data_sel; // @[core.scala 90:23]
  wire [3:0] control_io_exe_mem_type; // @[core.scala 90:23]
  wire [1:0] control_io_mem_rd_data_sel; // @[core.scala 90:23]
  wire [1:0] control_io_next_pc_sel_0; // @[core.scala 90:23]
  wire [1:0] control_io_next_pc_sel_1; // @[core.scala 90:23]
  wire [1:0] control_io_next_pc_sel_2; // @[core.scala 90:23]
  wire [1:0] control_io_next_pc_sel_3; // @[core.scala 90:23]
  wire [11:0] control_io_next_pc_sel_csr_addr; // @[core.scala 90:23]
  wire [1:0] control_io_next_tid; // @[core.scala 90:23]
  wire  control_io_exe_load; // @[core.scala 90:23]
  wire  control_io_exe_store; // @[core.scala 90:23]
  wire  control_io_exe_csr_write; // @[core.scala 90:23]
  wire  control_io_exe_exception; // @[core.scala 90:23]
  wire [4:0] control_io_exe_cause; // @[core.scala 90:23]
  wire  control_io_exe_kill; // @[core.scala 90:23]
  wire  control_io_exe_sleep_du; // @[core.scala 90:23]
  wire  control_io_exe_sleep_wu; // @[core.scala 90:23]
  wire  control_io_exe_ie; // @[core.scala 90:23]
  wire  control_io_exe_ee; // @[core.scala 90:23]
  wire  control_io_exe_mret; // @[core.scala 90:23]
  wire  control_io_exe_cycle; // @[core.scala 90:23]
  wire  control_io_exe_instret; // @[core.scala 90:23]
  wire  control_io_mem_rd_write; // @[core.scala 90:23]
  wire [1:0] control_io_if_tid; // @[core.scala 90:23]
  wire [31:0] control_io_dec_inst; // @[core.scala 90:23]
  wire  control_io_exe_br_cond; // @[core.scala 90:23]
  wire [1:0] control_io_exe_tid; // @[core.scala 90:23]
  wire  control_io_exe_expire_du_0; // @[core.scala 90:23]
  wire  control_io_exe_expire_du_1; // @[core.scala 90:23]
  wire  control_io_exe_expire_du_2; // @[core.scala 90:23]
  wire  control_io_exe_expire_du_3; // @[core.scala 90:23]
  wire  control_io_exe_expire_ie_0; // @[core.scala 90:23]
  wire  control_io_exe_expire_ie_1; // @[core.scala 90:23]
  wire  control_io_exe_expire_ie_2; // @[core.scala 90:23]
  wire  control_io_exe_expire_ie_3; // @[core.scala 90:23]
  wire  control_io_exe_expire_ee_0; // @[core.scala 90:23]
  wire  control_io_exe_expire_ee_1; // @[core.scala 90:23]
  wire  control_io_exe_expire_ee_2; // @[core.scala 90:23]
  wire  control_io_exe_expire_ee_3; // @[core.scala 90:23]
  wire  control_io_timer_expire_du_wu_0; // @[core.scala 90:23]
  wire  control_io_timer_expire_du_wu_1; // @[core.scala 90:23]
  wire  control_io_timer_expire_du_wu_2; // @[core.scala 90:23]
  wire  control_io_timer_expire_du_wu_3; // @[core.scala 90:23]
  wire [1:0] control_io_csr_tmodes_0; // @[core.scala 90:23]
  wire [1:0] control_io_csr_tmodes_1; // @[core.scala 90:23]
  wire [1:0] control_io_csr_tmodes_2; // @[core.scala 90:23]
  wire [1:0] control_io_csr_tmodes_3; // @[core.scala 90:23]
  wire [1:0] control_io_mem_tid; // @[core.scala 90:23]
  wire  control_io_if_exc_misaligned; // @[core.scala 90:23]
  wire  control_io_if_exc_fault; // @[core.scala 90:23]
  wire  control_io_exe_exc_load_misaligned; // @[core.scala 90:23]
  wire  control_io_exe_exc_load_fault; // @[core.scala 90:23]
  wire  control_io_exe_exc_store_misaligned; // @[core.scala 90:23]
  wire  control_io_exe_exc_store_fault; // @[core.scala 90:23]
  wire  control_io_exe_int_ext; // @[core.scala 90:23]
  wire  datapath_clock; // @[core.scala 91:24]
  wire  datapath_reset; // @[core.scala 91:24]
  wire [2:0] datapath_io_control_dec_imm_sel; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_dec_op1_sel; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_dec_op2_sel; // @[core.scala 91:24]
  wire [3:0] datapath_io_control_exe_alu_type; // @[core.scala 91:24]
  wire [2:0] datapath_io_control_exe_br_type; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_exe_csr_type; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_exe_rd_data_sel; // @[core.scala 91:24]
  wire [3:0] datapath_io_control_exe_mem_type; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_mem_rd_data_sel; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_next_pc_sel_0; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_next_pc_sel_1; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_next_pc_sel_2; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_next_pc_sel_3; // @[core.scala 91:24]
  wire [11:0] datapath_io_control_next_pc_sel_csr_addr; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_next_tid; // @[core.scala 91:24]
  wire  datapath_io_control_exe_load; // @[core.scala 91:24]
  wire  datapath_io_control_exe_store; // @[core.scala 91:24]
  wire  datapath_io_control_exe_csr_write; // @[core.scala 91:24]
  wire  datapath_io_control_exe_exception; // @[core.scala 91:24]
  wire [4:0] datapath_io_control_exe_cause; // @[core.scala 91:24]
  wire  datapath_io_control_exe_kill; // @[core.scala 91:24]
  wire  datapath_io_control_exe_sleep_du; // @[core.scala 91:24]
  wire  datapath_io_control_exe_sleep_wu; // @[core.scala 91:24]
  wire  datapath_io_control_exe_ie; // @[core.scala 91:24]
  wire  datapath_io_control_exe_ee; // @[core.scala 91:24]
  wire  datapath_io_control_exe_mret; // @[core.scala 91:24]
  wire  datapath_io_control_exe_cycle; // @[core.scala 91:24]
  wire  datapath_io_control_exe_instret; // @[core.scala 91:24]
  wire  datapath_io_control_mem_rd_write; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_if_tid; // @[core.scala 91:24]
  wire [31:0] datapath_io_control_dec_inst; // @[core.scala 91:24]
  wire  datapath_io_control_exe_br_cond; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_exe_tid; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_du_0; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_du_1; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_du_2; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_du_3; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ie_0; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ie_1; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ie_2; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ie_3; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ee_0; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ee_1; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ee_2; // @[core.scala 91:24]
  wire  datapath_io_control_exe_expire_ee_3; // @[core.scala 91:24]
  wire  datapath_io_control_timer_expire_du_wu_0; // @[core.scala 91:24]
  wire  datapath_io_control_timer_expire_du_wu_1; // @[core.scala 91:24]
  wire  datapath_io_control_timer_expire_du_wu_2; // @[core.scala 91:24]
  wire  datapath_io_control_timer_expire_du_wu_3; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_csr_tmodes_0; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_csr_tmodes_1; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_csr_tmodes_2; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_csr_tmodes_3; // @[core.scala 91:24]
  wire [1:0] datapath_io_control_mem_tid; // @[core.scala 91:24]
  wire  datapath_io_control_if_exc_misaligned; // @[core.scala 91:24]
  wire  datapath_io_control_if_exc_fault; // @[core.scala 91:24]
  wire  datapath_io_control_exe_exc_load_misaligned; // @[core.scala 91:24]
  wire  datapath_io_control_exe_exc_load_fault; // @[core.scala 91:24]
  wire  datapath_io_control_exe_exc_store_misaligned; // @[core.scala 91:24]
  wire  datapath_io_control_exe_exc_store_fault; // @[core.scala 91:24]
  wire  datapath_io_control_exe_int_ext; // @[core.scala 91:24]
  wire [15:0] datapath_io_imem_r_addr; // @[core.scala 91:24]
  wire [31:0] datapath_io_imem_r_data_out; // @[core.scala 91:24]
  wire [15:0] datapath_io_imem_rw_addr; // @[core.scala 91:24]
  wire  datapath_io_imem_rw_enable; // @[core.scala 91:24]
  wire [31:0] datapath_io_imem_rw_data_out; // @[core.scala 91:24]
  wire  datapath_io_imem_rw_write; // @[core.scala 91:24]
  wire [31:0] datapath_io_imem_rw_data_in; // @[core.scala 91:24]
  wire [13:0] datapath_io_dmem_addr; // @[core.scala 91:24]
  wire  datapath_io_dmem_enable; // @[core.scala 91:24]
  wire [31:0] datapath_io_dmem_data_out; // @[core.scala 91:24]
  wire  datapath_io_dmem_byte_write_0; // @[core.scala 91:24]
  wire  datapath_io_dmem_byte_write_1; // @[core.scala 91:24]
  wire  datapath_io_dmem_byte_write_2; // @[core.scala 91:24]
  wire  datapath_io_dmem_byte_write_3; // @[core.scala 91:24]
  wire [31:0] datapath_io_dmem_data_in; // @[core.scala 91:24]
  wire [9:0] datapath_io_bus_addr; // @[core.scala 91:24]
  wire  datapath_io_bus_enable; // @[core.scala 91:24]
  wire [31:0] datapath_io_bus_data_out; // @[core.scala 91:24]
  wire  datapath_io_bus_write; // @[core.scala 91:24]
  wire [31:0] datapath_io_bus_data_in; // @[core.scala 91:24]
  wire  datapath_io_gpio_in_3; // @[core.scala 91:24]
  wire  datapath_io_gpio_in_2; // @[core.scala 91:24]
  wire  datapath_io_gpio_in_1; // @[core.scala 91:24]
  wire  datapath_io_gpio_in_0; // @[core.scala 91:24]
  wire [1:0] datapath_io_gpio_out_3; // @[core.scala 91:24]
  wire [1:0] datapath_io_gpio_out_2; // @[core.scala 91:24]
  wire [1:0] datapath_io_gpio_out_1; // @[core.scala 91:24]
  wire [1:0] datapath_io_gpio_out_0; // @[core.scala 91:24]
  wire  datapath_io_int_exts_0; // @[core.scala 91:24]
  wire  datapath_io_int_exts_1; // @[core.scala 91:24]
  wire  datapath_io_int_exts_2; // @[core.scala 91:24]
  wire  datapath_io_int_exts_3; // @[core.scala 91:24]
  wire  imem_clock; // @[core.scala 92:63]
  wire [15:0] imem_io_core_r_addr; // @[core.scala 92:63]
  wire [31:0] imem_io_core_r_data_out; // @[core.scala 92:63]
  wire [15:0] imem_io_core_rw_addr; // @[core.scala 92:63]
  wire  imem_io_core_rw_enable; // @[core.scala 92:63]
  wire [31:0] imem_io_core_rw_data_out; // @[core.scala 92:63]
  wire  imem_io_core_rw_write; // @[core.scala 92:63]
  wire [31:0] imem_io_core_rw_data_in; // @[core.scala 92:63]
  wire  dmem_clock; // @[core.scala 93:20]
  wire [13:0] dmem_io_core_addr; // @[core.scala 93:20]
  wire  dmem_io_core_enable; // @[core.scala 93:20]
  wire [31:0] dmem_io_core_data_out; // @[core.scala 93:20]
  wire  dmem_io_core_byte_write_0; // @[core.scala 93:20]
  wire  dmem_io_core_byte_write_1; // @[core.scala 93:20]
  wire  dmem_io_core_byte_write_2; // @[core.scala 93:20]
  wire  dmem_io_core_byte_write_3; // @[core.scala 93:20]
  wire [31:0] dmem_io_core_data_in; // @[core.scala 93:20]
  Control control ( // @[core.scala 90:23]
    .clock(control_clock),
    .reset(control_reset),
    .io_dec_imm_sel(control_io_dec_imm_sel),
    .io_dec_op1_sel(control_io_dec_op1_sel),
    .io_dec_op2_sel(control_io_dec_op2_sel),
    .io_exe_alu_type(control_io_exe_alu_type),
    .io_exe_br_type(control_io_exe_br_type),
    .io_exe_csr_type(control_io_exe_csr_type),
    .io_exe_rd_data_sel(control_io_exe_rd_data_sel),
    .io_exe_mem_type(control_io_exe_mem_type),
    .io_mem_rd_data_sel(control_io_mem_rd_data_sel),
    .io_next_pc_sel_0(control_io_next_pc_sel_0),
    .io_next_pc_sel_1(control_io_next_pc_sel_1),
    .io_next_pc_sel_2(control_io_next_pc_sel_2),
    .io_next_pc_sel_3(control_io_next_pc_sel_3),
    .io_next_pc_sel_csr_addr(control_io_next_pc_sel_csr_addr),
    .io_next_tid(control_io_next_tid),
    .io_exe_load(control_io_exe_load),
    .io_exe_store(control_io_exe_store),
    .io_exe_csr_write(control_io_exe_csr_write),
    .io_exe_exception(control_io_exe_exception),
    .io_exe_cause(control_io_exe_cause),
    .io_exe_kill(control_io_exe_kill),
    .io_exe_sleep_du(control_io_exe_sleep_du),
    .io_exe_sleep_wu(control_io_exe_sleep_wu),
    .io_exe_ie(control_io_exe_ie),
    .io_exe_ee(control_io_exe_ee),
    .io_exe_mret(control_io_exe_mret),
    .io_exe_cycle(control_io_exe_cycle),
    .io_exe_instret(control_io_exe_instret),
    .io_mem_rd_write(control_io_mem_rd_write),
    .io_if_tid(control_io_if_tid),
    .io_dec_inst(control_io_dec_inst),
    .io_exe_br_cond(control_io_exe_br_cond),
    .io_exe_tid(control_io_exe_tid),
    .io_exe_expire_du_0(control_io_exe_expire_du_0),
    .io_exe_expire_du_1(control_io_exe_expire_du_1),
    .io_exe_expire_du_2(control_io_exe_expire_du_2),
    .io_exe_expire_du_3(control_io_exe_expire_du_3),
    .io_exe_expire_ie_0(control_io_exe_expire_ie_0),
    .io_exe_expire_ie_1(control_io_exe_expire_ie_1),
    .io_exe_expire_ie_2(control_io_exe_expire_ie_2),
    .io_exe_expire_ie_3(control_io_exe_expire_ie_3),
    .io_exe_expire_ee_0(control_io_exe_expire_ee_0),
    .io_exe_expire_ee_1(control_io_exe_expire_ee_1),
    .io_exe_expire_ee_2(control_io_exe_expire_ee_2),
    .io_exe_expire_ee_3(control_io_exe_expire_ee_3),
    .io_timer_expire_du_wu_0(control_io_timer_expire_du_wu_0),
    .io_timer_expire_du_wu_1(control_io_timer_expire_du_wu_1),
    .io_timer_expire_du_wu_2(control_io_timer_expire_du_wu_2),
    .io_timer_expire_du_wu_3(control_io_timer_expire_du_wu_3),
    .io_csr_tmodes_0(control_io_csr_tmodes_0),
    .io_csr_tmodes_1(control_io_csr_tmodes_1),
    .io_csr_tmodes_2(control_io_csr_tmodes_2),
    .io_csr_tmodes_3(control_io_csr_tmodes_3),
    .io_mem_tid(control_io_mem_tid),
    .io_if_exc_misaligned(control_io_if_exc_misaligned),
    .io_if_exc_fault(control_io_if_exc_fault),
    .io_exe_exc_load_misaligned(control_io_exe_exc_load_misaligned),
    .io_exe_exc_load_fault(control_io_exe_exc_load_fault),
    .io_exe_exc_store_misaligned(control_io_exe_exc_store_misaligned),
    .io_exe_exc_store_fault(control_io_exe_exc_store_fault),
    .io_exe_int_ext(control_io_exe_int_ext)
  );
  Datapath datapath ( // @[core.scala 91:24]
    .clock(datapath_clock),
    .reset(datapath_reset),
    .io_control_dec_imm_sel(datapath_io_control_dec_imm_sel),
    .io_control_dec_op1_sel(datapath_io_control_dec_op1_sel),
    .io_control_dec_op2_sel(datapath_io_control_dec_op2_sel),
    .io_control_exe_alu_type(datapath_io_control_exe_alu_type),
    .io_control_exe_br_type(datapath_io_control_exe_br_type),
    .io_control_exe_csr_type(datapath_io_control_exe_csr_type),
    .io_control_exe_rd_data_sel(datapath_io_control_exe_rd_data_sel),
    .io_control_exe_mem_type(datapath_io_control_exe_mem_type),
    .io_control_mem_rd_data_sel(datapath_io_control_mem_rd_data_sel),
    .io_control_next_pc_sel_0(datapath_io_control_next_pc_sel_0),
    .io_control_next_pc_sel_1(datapath_io_control_next_pc_sel_1),
    .io_control_next_pc_sel_2(datapath_io_control_next_pc_sel_2),
    .io_control_next_pc_sel_3(datapath_io_control_next_pc_sel_3),
    .io_control_next_pc_sel_csr_addr(datapath_io_control_next_pc_sel_csr_addr),
    .io_control_next_tid(datapath_io_control_next_tid),
    .io_control_exe_load(datapath_io_control_exe_load),
    .io_control_exe_store(datapath_io_control_exe_store),
    .io_control_exe_csr_write(datapath_io_control_exe_csr_write),
    .io_control_exe_exception(datapath_io_control_exe_exception),
    .io_control_exe_cause(datapath_io_control_exe_cause),
    .io_control_exe_kill(datapath_io_control_exe_kill),
    .io_control_exe_sleep_du(datapath_io_control_exe_sleep_du),
    .io_control_exe_sleep_wu(datapath_io_control_exe_sleep_wu),
    .io_control_exe_ie(datapath_io_control_exe_ie),
    .io_control_exe_ee(datapath_io_control_exe_ee),
    .io_control_exe_mret(datapath_io_control_exe_mret),
    .io_control_exe_cycle(datapath_io_control_exe_cycle),
    .io_control_exe_instret(datapath_io_control_exe_instret),
    .io_control_mem_rd_write(datapath_io_control_mem_rd_write),
    .io_control_if_tid(datapath_io_control_if_tid),
    .io_control_dec_inst(datapath_io_control_dec_inst),
    .io_control_exe_br_cond(datapath_io_control_exe_br_cond),
    .io_control_exe_tid(datapath_io_control_exe_tid),
    .io_control_exe_expire_du_0(datapath_io_control_exe_expire_du_0),
    .io_control_exe_expire_du_1(datapath_io_control_exe_expire_du_1),
    .io_control_exe_expire_du_2(datapath_io_control_exe_expire_du_2),
    .io_control_exe_expire_du_3(datapath_io_control_exe_expire_du_3),
    .io_control_exe_expire_ie_0(datapath_io_control_exe_expire_ie_0),
    .io_control_exe_expire_ie_1(datapath_io_control_exe_expire_ie_1),
    .io_control_exe_expire_ie_2(datapath_io_control_exe_expire_ie_2),
    .io_control_exe_expire_ie_3(datapath_io_control_exe_expire_ie_3),
    .io_control_exe_expire_ee_0(datapath_io_control_exe_expire_ee_0),
    .io_control_exe_expire_ee_1(datapath_io_control_exe_expire_ee_1),
    .io_control_exe_expire_ee_2(datapath_io_control_exe_expire_ee_2),
    .io_control_exe_expire_ee_3(datapath_io_control_exe_expire_ee_3),
    .io_control_timer_expire_du_wu_0(datapath_io_control_timer_expire_du_wu_0),
    .io_control_timer_expire_du_wu_1(datapath_io_control_timer_expire_du_wu_1),
    .io_control_timer_expire_du_wu_2(datapath_io_control_timer_expire_du_wu_2),
    .io_control_timer_expire_du_wu_3(datapath_io_control_timer_expire_du_wu_3),
    .io_control_csr_tmodes_0(datapath_io_control_csr_tmodes_0),
    .io_control_csr_tmodes_1(datapath_io_control_csr_tmodes_1),
    .io_control_csr_tmodes_2(datapath_io_control_csr_tmodes_2),
    .io_control_csr_tmodes_3(datapath_io_control_csr_tmodes_3),
    .io_control_mem_tid(datapath_io_control_mem_tid),
    .io_control_if_exc_misaligned(datapath_io_control_if_exc_misaligned),
    .io_control_if_exc_fault(datapath_io_control_if_exc_fault),
    .io_control_exe_exc_load_misaligned(datapath_io_control_exe_exc_load_misaligned),
    .io_control_exe_exc_load_fault(datapath_io_control_exe_exc_load_fault),
    .io_control_exe_exc_store_misaligned(datapath_io_control_exe_exc_store_misaligned),
    .io_control_exe_exc_store_fault(datapath_io_control_exe_exc_store_fault),
    .io_control_exe_int_ext(datapath_io_control_exe_int_ext),
    .io_imem_r_addr(datapath_io_imem_r_addr),
    .io_imem_r_data_out(datapath_io_imem_r_data_out),
    .io_imem_rw_addr(datapath_io_imem_rw_addr),
    .io_imem_rw_enable(datapath_io_imem_rw_enable),
    .io_imem_rw_data_out(datapath_io_imem_rw_data_out),
    .io_imem_rw_write(datapath_io_imem_rw_write),
    .io_imem_rw_data_in(datapath_io_imem_rw_data_in),
    .io_dmem_addr(datapath_io_dmem_addr),
    .io_dmem_enable(datapath_io_dmem_enable),
    .io_dmem_data_out(datapath_io_dmem_data_out),
    .io_dmem_byte_write_0(datapath_io_dmem_byte_write_0),
    .io_dmem_byte_write_1(datapath_io_dmem_byte_write_1),
    .io_dmem_byte_write_2(datapath_io_dmem_byte_write_2),
    .io_dmem_byte_write_3(datapath_io_dmem_byte_write_3),
    .io_dmem_data_in(datapath_io_dmem_data_in),
    .io_bus_addr(datapath_io_bus_addr),
    .io_bus_enable(datapath_io_bus_enable),
    .io_bus_data_out(datapath_io_bus_data_out),
    .io_bus_write(datapath_io_bus_write),
    .io_bus_data_in(datapath_io_bus_data_in),
    .io_gpio_in_3(datapath_io_gpio_in_3),
    .io_gpio_in_2(datapath_io_gpio_in_2),
    .io_gpio_in_1(datapath_io_gpio_in_1),
    .io_gpio_in_0(datapath_io_gpio_in_0),
    .io_gpio_out_3(datapath_io_gpio_out_3),
    .io_gpio_out_2(datapath_io_gpio_out_2),
    .io_gpio_out_1(datapath_io_gpio_out_1),
    .io_gpio_out_0(datapath_io_gpio_out_0),
    .io_int_exts_0(datapath_io_int_exts_0),
    .io_int_exts_1(datapath_io_int_exts_1),
    .io_int_exts_2(datapath_io_int_exts_2),
    .io_int_exts_3(datapath_io_int_exts_3)
  );
  ISpm imem ( // @[core.scala 92:63]
    .clock(imem_clock),
    .io_core_r_addr(imem_io_core_r_addr),
    .io_core_r_data_out(imem_io_core_r_data_out),
    .io_core_rw_addr(imem_io_core_rw_addr),
    .io_core_rw_enable(imem_io_core_rw_enable),
    .io_core_rw_data_out(imem_io_core_rw_data_out),
    .io_core_rw_write(imem_io_core_rw_write),
    .io_core_rw_data_in(imem_io_core_rw_data_in)
  );
  DSpm dmem ( // @[core.scala 93:20]
    .clock(dmem_clock),
    .io_core_addr(dmem_io_core_addr),
    .io_core_enable(dmem_io_core_enable),
    .io_core_data_out(dmem_io_core_data_out),
    .io_core_byte_write_0(dmem_io_core_byte_write_0),
    .io_core_byte_write_1(dmem_io_core_byte_write_1),
    .io_core_byte_write_2(dmem_io_core_byte_write_2),
    .io_core_byte_write_3(dmem_io_core_byte_write_3),
    .io_core_data_in(dmem_io_core_data_in)
  );
  assign io_bus_addr = datapath_io_bus_addr; // @[core.scala 110:10]
  assign io_bus_enable = datapath_io_bus_enable; // @[core.scala 110:10]
  assign io_bus_write = datapath_io_bus_write; // @[core.scala 110:10]
  assign io_bus_data_in = datapath_io_bus_data_in; // @[core.scala 110:10]
  assign io_gpio_out_3 = datapath_io_gpio_out_3; // @[core.scala 112:11]
  assign io_gpio_out_2 = datapath_io_gpio_out_2; // @[core.scala 112:11]
  assign io_gpio_out_1 = datapath_io_gpio_out_1; // @[core.scala 112:11]
  assign io_gpio_out_0 = datapath_io_gpio_out_0; // @[core.scala 112:11]
  assign control_clock = clock;
  assign control_reset = reset;
  assign control_io_if_tid = datapath_io_control_if_tid; // @[core.scala 97:23]
  assign control_io_dec_inst = datapath_io_control_dec_inst; // @[core.scala 97:23]
  assign control_io_exe_br_cond = datapath_io_control_exe_br_cond; // @[core.scala 97:23]
  assign control_io_exe_tid = datapath_io_control_exe_tid; // @[core.scala 97:23]
  assign control_io_exe_expire_du_0 = datapath_io_control_exe_expire_du_0; // @[core.scala 97:23]
  assign control_io_exe_expire_du_1 = datapath_io_control_exe_expire_du_1; // @[core.scala 97:23]
  assign control_io_exe_expire_du_2 = datapath_io_control_exe_expire_du_2; // @[core.scala 97:23]
  assign control_io_exe_expire_du_3 = datapath_io_control_exe_expire_du_3; // @[core.scala 97:23]
  assign control_io_exe_expire_ie_0 = datapath_io_control_exe_expire_ie_0; // @[core.scala 97:23]
  assign control_io_exe_expire_ie_1 = datapath_io_control_exe_expire_ie_1; // @[core.scala 97:23]
  assign control_io_exe_expire_ie_2 = datapath_io_control_exe_expire_ie_2; // @[core.scala 97:23]
  assign control_io_exe_expire_ie_3 = datapath_io_control_exe_expire_ie_3; // @[core.scala 97:23]
  assign control_io_exe_expire_ee_0 = datapath_io_control_exe_expire_ee_0; // @[core.scala 97:23]
  assign control_io_exe_expire_ee_1 = datapath_io_control_exe_expire_ee_1; // @[core.scala 97:23]
  assign control_io_exe_expire_ee_2 = datapath_io_control_exe_expire_ee_2; // @[core.scala 97:23]
  assign control_io_exe_expire_ee_3 = datapath_io_control_exe_expire_ee_3; // @[core.scala 97:23]
  assign control_io_timer_expire_du_wu_0 = datapath_io_control_timer_expire_du_wu_0; // @[core.scala 97:23]
  assign control_io_timer_expire_du_wu_1 = datapath_io_control_timer_expire_du_wu_1; // @[core.scala 97:23]
  assign control_io_timer_expire_du_wu_2 = datapath_io_control_timer_expire_du_wu_2; // @[core.scala 97:23]
  assign control_io_timer_expire_du_wu_3 = datapath_io_control_timer_expire_du_wu_3; // @[core.scala 97:23]
  assign control_io_csr_tmodes_0 = datapath_io_control_csr_tmodes_0; // @[core.scala 97:23]
  assign control_io_csr_tmodes_1 = datapath_io_control_csr_tmodes_1; // @[core.scala 97:23]
  assign control_io_csr_tmodes_2 = datapath_io_control_csr_tmodes_2; // @[core.scala 97:23]
  assign control_io_csr_tmodes_3 = datapath_io_control_csr_tmodes_3; // @[core.scala 97:23]
  assign control_io_mem_tid = datapath_io_control_mem_tid; // @[core.scala 97:23]
  assign control_io_if_exc_misaligned = datapath_io_control_if_exc_misaligned; // @[core.scala 97:23]
  assign control_io_if_exc_fault = datapath_io_control_if_exc_fault; // @[core.scala 97:23]
  assign control_io_exe_exc_load_misaligned = datapath_io_control_exe_exc_load_misaligned; // @[core.scala 97:23]
  assign control_io_exe_exc_load_fault = datapath_io_control_exe_exc_load_fault; // @[core.scala 97:23]
  assign control_io_exe_exc_store_misaligned = datapath_io_control_exe_exc_store_misaligned; // @[core.scala 97:23]
  assign control_io_exe_exc_store_fault = datapath_io_control_exe_exc_store_fault; // @[core.scala 97:23]
  assign control_io_exe_int_ext = datapath_io_control_exe_int_ext; // @[core.scala 97:23]
  assign datapath_clock = clock;
  assign datapath_reset = reset;
  assign datapath_io_control_dec_imm_sel = control_io_dec_imm_sel; // @[core.scala 97:23]
  assign datapath_io_control_dec_op1_sel = control_io_dec_op1_sel; // @[core.scala 97:23]
  assign datapath_io_control_dec_op2_sel = control_io_dec_op2_sel; // @[core.scala 97:23]
  assign datapath_io_control_exe_alu_type = control_io_exe_alu_type; // @[core.scala 97:23]
  assign datapath_io_control_exe_br_type = control_io_exe_br_type; // @[core.scala 97:23]
  assign datapath_io_control_exe_csr_type = control_io_exe_csr_type; // @[core.scala 97:23]
  assign datapath_io_control_exe_rd_data_sel = control_io_exe_rd_data_sel; // @[core.scala 97:23]
  assign datapath_io_control_exe_mem_type = control_io_exe_mem_type; // @[core.scala 97:23]
  assign datapath_io_control_mem_rd_data_sel = control_io_mem_rd_data_sel; // @[core.scala 97:23]
  assign datapath_io_control_next_pc_sel_0 = control_io_next_pc_sel_0; // @[core.scala 97:23]
  assign datapath_io_control_next_pc_sel_1 = control_io_next_pc_sel_1; // @[core.scala 97:23]
  assign datapath_io_control_next_pc_sel_2 = control_io_next_pc_sel_2; // @[core.scala 97:23]
  assign datapath_io_control_next_pc_sel_3 = control_io_next_pc_sel_3; // @[core.scala 97:23]
  assign datapath_io_control_next_pc_sel_csr_addr = control_io_next_pc_sel_csr_addr; // @[core.scala 97:23]
  assign datapath_io_control_next_tid = control_io_next_tid; // @[core.scala 97:23]
  assign datapath_io_control_exe_load = control_io_exe_load; // @[core.scala 97:23]
  assign datapath_io_control_exe_store = control_io_exe_store; // @[core.scala 97:23]
  assign datapath_io_control_exe_csr_write = control_io_exe_csr_write; // @[core.scala 97:23]
  assign datapath_io_control_exe_exception = control_io_exe_exception; // @[core.scala 97:23]
  assign datapath_io_control_exe_cause = control_io_exe_cause; // @[core.scala 97:23]
  assign datapath_io_control_exe_kill = control_io_exe_kill; // @[core.scala 97:23]
  assign datapath_io_control_exe_sleep_du = control_io_exe_sleep_du; // @[core.scala 97:23]
  assign datapath_io_control_exe_sleep_wu = control_io_exe_sleep_wu; // @[core.scala 97:23]
  assign datapath_io_control_exe_ie = control_io_exe_ie; // @[core.scala 97:23]
  assign datapath_io_control_exe_ee = control_io_exe_ee; // @[core.scala 97:23]
  assign datapath_io_control_exe_mret = control_io_exe_mret; // @[core.scala 97:23]
  assign datapath_io_control_exe_cycle = control_io_exe_cycle; // @[core.scala 97:23]
  assign datapath_io_control_exe_instret = control_io_exe_instret; // @[core.scala 97:23]
  assign datapath_io_control_mem_rd_write = control_io_mem_rd_write; // @[core.scala 97:23]
  assign datapath_io_imem_r_data_out = imem_io_core_r_data_out; // @[core.scala 98:20]
  assign datapath_io_imem_rw_data_out = imem_io_core_rw_data_out; // @[core.scala 98:20]
  assign datapath_io_dmem_data_out = dmem_io_core_data_out; // @[core.scala 102:20]
  assign datapath_io_bus_data_out = io_bus_data_out; // @[core.scala 110:10]
  assign datapath_io_gpio_in_3 = io_gpio_in_3; // @[core.scala 112:11]
  assign datapath_io_gpio_in_2 = io_gpio_in_2; // @[core.scala 112:11]
  assign datapath_io_gpio_in_1 = io_gpio_in_1; // @[core.scala 112:11]
  assign datapath_io_gpio_in_0 = io_gpio_in_0; // @[core.scala 112:11]
  assign datapath_io_int_exts_0 = io_int_exts_0; // @[core.scala 114:31]
  assign datapath_io_int_exts_1 = io_int_exts_1; // @[core.scala 114:31]
  assign datapath_io_int_exts_2 = io_int_exts_2; // @[core.scala 114:31]
  assign datapath_io_int_exts_3 = io_int_exts_3; // @[core.scala 114:31]
  assign imem_clock = clock;
  assign imem_io_core_r_addr = datapath_io_imem_r_addr; // @[core.scala 98:20]
  assign imem_io_core_rw_addr = datapath_io_imem_rw_addr; // @[core.scala 98:20]
  assign imem_io_core_rw_enable = datapath_io_imem_rw_enable; // @[core.scala 98:20]
  assign imem_io_core_rw_write = datapath_io_imem_rw_write; // @[core.scala 98:20]
  assign imem_io_core_rw_data_in = datapath_io_imem_rw_data_in; // @[core.scala 98:20]
  assign dmem_clock = clock;
  assign dmem_io_core_addr = datapath_io_dmem_addr; // @[core.scala 102:20]
  assign dmem_io_core_enable = datapath_io_dmem_enable; // @[core.scala 102:20]
  assign dmem_io_core_byte_write_0 = datapath_io_dmem_byte_write_0; // @[core.scala 102:20]
  assign dmem_io_core_byte_write_1 = datapath_io_dmem_byte_write_1; // @[core.scala 102:20]
  assign dmem_io_core_byte_write_2 = datapath_io_dmem_byte_write_2; // @[core.scala 102:20]
  assign dmem_io_core_byte_write_3 = datapath_io_dmem_byte_write_3; // @[core.scala 102:20]
  assign dmem_io_core_data_in = datapath_io_dmem_data_in; // @[core.scala 102:20]
endmodule
module WishboneMaster(
  input         clock,
  input         reset,
  output [9:0]  wbIO_addr,
  output [31:0] wbIO_wrData,
  input  [31:0] wbIO_rdData,
  output        wbIO_we,
  output        wbIO_stb,
  input         wbIO_ack,
  output        wbIO_cyc,
  input  [9:0]  busIO_addr,
  input         busIO_enable,
  output [31:0] busIO_data_out,
  input         busIO_write,
  input  [31:0] busIO_data_in
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [9:0] regAddr; // @[WishboneMaster.scala 17:24]
  reg [31:0] regWriteData; // @[WishboneMaster.scala 18:29]
  reg [31:0] regReadData; // @[WishboneMaster.scala 19:28]
  reg  regStatus; // @[WishboneMaster.scala 20:26]
  reg [31:0] regBusRead; // @[WishboneMaster.scala 23:27]
  reg [1:0] regState; // @[WishboneMaster.scala 29:25]
  wire  _T_11 = 2'h0 == regState; // @[WishboneMaster.scala 36:20]
  wire  _T_12 = busIO_addr == 10'h0; // @[WishboneMaster.scala 46:21]
  wire  _GEN_13 = busIO_write & _T_12; // @[WishboneMaster.scala 44:27 31:28]
  wire  _GEN_19 = busIO_enable & _GEN_13; // @[WishboneMaster.scala 42:26 31:28]
  wire  wDoRead = 2'h0 == regState & _GEN_19; // @[WishboneMaster.scala 36:20 31:28]
  wire  _T_13 = busIO_addr == 10'h4; // @[WishboneMaster.scala 50:27]
  wire  _GEN_6 = busIO_addr == 10'h0 ? 1'h0 : _T_13; // @[WishboneMaster.scala 32:29 46:41]
  wire  _GEN_14 = busIO_write & _GEN_6; // @[WishboneMaster.scala 44:27 32:29]
  wire  _GEN_20 = busIO_enable & _GEN_14; // @[WishboneMaster.scala 42:26 32:29]
  wire  wDoWrite = 2'h0 == regState & _GEN_20; // @[WishboneMaster.scala 36:20 32:29]
  wire  _T_3 = ~reset; // @[WishboneMaster.scala 33:9]
  wire  _T_14 = busIO_addr == 10'h8; // @[WishboneMaster.scala 55:27]
  wire [31:0] _GEN_0 = busIO_addr == 10'h8 ? busIO_data_in : regWriteData; // @[WishboneMaster.scala 55:48 56:26 18:29]
  wire [31:0] _GEN_1 = busIO_addr == 10'h4 ? busIO_data_in : {{22'd0}, regAddr}; // @[WishboneMaster.scala 50:48 51:21 17:24]
  wire [31:0] _GEN_3 = busIO_addr == 10'h4 ? regWriteData : _GEN_0; // @[WishboneMaster.scala 18:29 50:48]
  wire [31:0] _GEN_4 = busIO_addr == 10'h0 ? busIO_data_in : _GEN_1; // @[WishboneMaster.scala 46:41 47:21]
  wire [31:0] _GEN_7 = busIO_addr == 10'h0 ? regWriteData : _GEN_3; // @[WishboneMaster.scala 18:29 46:41]
  wire  _T_18 = busIO_addr == 10'hc; // @[WishboneMaster.scala 62:21]
  wire  _T_19 = busIO_addr == 10'h10; // @[WishboneMaster.scala 64:27]
  wire [31:0] _GEN_8 = busIO_addr == 10'h10 ? {{31'd0}, regStatus} : regBusRead; // @[WishboneMaster.scala 64:44 65:24 23:27]
  wire  _GEN_9 = busIO_addr == 10'h10 ? 1'h0 : regStatus; // @[WishboneMaster.scala 64:44 66:23 20:26]
  wire [31:0] _GEN_10 = busIO_addr == 10'hc ? regReadData : _GEN_8; // @[WishboneMaster.scala 62:41 63:24]
  wire  _GEN_11 = busIO_addr == 10'hc ? regStatus : _GEN_9; // @[WishboneMaster.scala 20:26 62:41]
  wire [31:0] _GEN_12 = busIO_write ? _GEN_4 : {{22'd0}, regAddr}; // @[WishboneMaster.scala 17:24 44:27]
  wire [31:0] _GEN_18 = busIO_enable ? _GEN_12 : {{22'd0}, regAddr}; // @[WishboneMaster.scala 17:24 42:26]
  wire [1:0] _GEN_28 = wbIO_ack ? 2'h0 : regState; // @[WishboneMaster.scala 84:22 87:18 29:25]
  wire [9:0] _GEN_29 = 2'h1 == regState ? regAddr : 10'h0; // @[WishboneIO.scala 36:10 WishboneMaster.scala 36:20 WishboneIO.scala 59:10]
  wire [31:0] _GEN_30 = 2'h1 == regState ? regWriteData : 32'h0; // @[WishboneMaster.scala 36:20 WishboneIO.scala 37:12 60:12]
  wire [9:0] _GEN_35 = 2'h2 == regState ? regAddr : _GEN_29; // @[WishboneMaster.scala 36:20 WishboneIO.scala 50:10]
  wire [31:0] _GEN_36 = 2'h2 == regState ? 32'h0 : _GEN_30; // @[WishboneMaster.scala 36:20 WishboneIO.scala 51:12]
  wire  _GEN_37 = 2'h2 == regState ? 1'h0 : 2'h1 == regState; // @[WishboneMaster.scala 36:20 WishboneIO.scala 52:8]
  wire  _GEN_38 = 2'h2 == regState | 2'h1 == regState; // @[WishboneMaster.scala 36:20 WishboneIO.scala 53:9]
  wire [31:0] _GEN_43 = 2'h0 == regState ? _GEN_18 : {{22'd0}, regAddr}; // @[WishboneMaster.scala 36:20 17:24]
  wire [31:0] _GEN_56 = reset ? 32'h0 : _GEN_43; // @[WishboneMaster.scala 17:{24,24}]
  wire  _GEN_59 = _T_11 & busIO_enable; // @[WishboneMaster.scala 58:19]
  assign wbIO_addr = 2'h0 == regState ? 10'h0 : _GEN_35; // @[WishboneIO.scala 36:10 WishboneMaster.scala 36:20]
  assign wbIO_wrData = 2'h0 == regState ? 32'h0 : _GEN_36; // @[WishboneMaster.scala 36:20 WishboneIO.scala 37:12]
  assign wbIO_we = 2'h0 == regState ? 1'h0 : _GEN_37; // @[WishboneMaster.scala 36:20 WishboneIO.scala 38:8]
  assign wbIO_stb = 2'h0 == regState ? 1'h0 : _GEN_38; // @[WishboneMaster.scala 36:20 WishboneIO.scala 39:9]
  assign wbIO_cyc = 2'h0 == regState ? 1'h0 : _GEN_38; // @[WishboneMaster.scala 36:20 WishboneIO.scala 39:9]
  assign busIO_data_out = regBusRead; // @[WishboneMaster.scala 24:18]
  always @(posedge clock) begin
    regAddr <= _GEN_56[9:0]; // @[WishboneMaster.scala 17:{24,24}]
    if (reset) begin // @[WishboneMaster.scala 18:29]
      regWriteData <= 32'h0; // @[WishboneMaster.scala 18:29]
    end else if (2'h0 == regState) begin // @[WishboneMaster.scala 36:20]
      if (busIO_enable) begin // @[WishboneMaster.scala 42:26]
        if (busIO_write) begin // @[WishboneMaster.scala 44:27]
          regWriteData <= _GEN_7;
        end
      end
    end
    if (reset) begin // @[WishboneMaster.scala 19:28]
      regReadData <= 32'h0; // @[WishboneMaster.scala 19:28]
    end else if (!(2'h0 == regState)) begin // @[WishboneMaster.scala 36:20]
      if (2'h2 == regState) begin // @[WishboneMaster.scala 36:20]
        if (wbIO_ack) begin // @[WishboneMaster.scala 84:22]
          regReadData <= wbIO_rdData; // @[WishboneMaster.scala 85:21]
        end
      end
    end
    if (reset) begin // @[WishboneMaster.scala 20:26]
      regStatus <= 1'h0; // @[WishboneMaster.scala 20:26]
    end else if (2'h0 == regState) begin // @[WishboneMaster.scala 36:20]
      if (busIO_enable) begin // @[WishboneMaster.scala 42:26]
        if (!(busIO_write)) begin // @[WishboneMaster.scala 44:27]
          regStatus <= _GEN_11;
        end
      end
    end else if (2'h2 == regState) begin // @[WishboneMaster.scala 36:20]
      regStatus <= wbIO_ack;
    end else if (2'h1 == regState) begin // @[WishboneMaster.scala 36:20]
      regStatus <= wbIO_ack;
    end
    if (reset) begin // @[WishboneMaster.scala 23:27]
      regBusRead <= 32'h0; // @[WishboneMaster.scala 23:27]
    end else if (2'h0 == regState) begin // @[WishboneMaster.scala 36:20]
      if (busIO_enable) begin // @[WishboneMaster.scala 42:26]
        if (!(busIO_write)) begin // @[WishboneMaster.scala 44:27]
          regBusRead <= _GEN_10;
        end
      end
    end
    if (reset) begin // @[WishboneMaster.scala 29:25]
      regState <= 2'h0; // @[WishboneMaster.scala 29:25]
    end else if (2'h0 == regState) begin // @[WishboneMaster.scala 36:20]
      if (wDoRead) begin // @[WishboneMaster.scala 72:22]
        regState <= 2'h2; // @[WishboneMaster.scala 73:18]
      end else if (wDoWrite) begin // @[WishboneMaster.scala 74:28]
        regState <= 2'h1; // @[WishboneMaster.scala 75:18]
      end
    end else if (2'h2 == regState) begin // @[WishboneMaster.scala 36:20]
      regState <= _GEN_28;
    end else if (2'h1 == regState) begin // @[WishboneMaster.scala 36:20]
      regState <= _GEN_28;
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset & ~(~(wDoRead & wDoWrite))) begin
          $fwrite(32'h80000002,
            "Assertion failed: Both read and write at the same time\n    at WishboneMaster.scala:33 assert(!(wDoRead && wDoWrite), \"Both read and write at the same time\")\n"
            ); // @[WishboneMaster.scala 33:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~reset & ~(~(wDoRead & wDoWrite))) begin
          $fatal; // @[WishboneMaster.scala 33:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_3 & ~(~(busIO_enable & regState != 2'h0))) begin
          $fwrite(32'h80000002,
            "Assertion failed: Recevied bus request while busy\n    at WishboneMaster.scala:34 assert(!(busIO.enable && regState =/= sIdle), \"Recevied bus request while busy\")\n"
            ); // @[WishboneMaster.scala 34:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_3 & ~(~(busIO_enable & regState != 2'h0))) begin
          $fatal; // @[WishboneMaster.scala 34:9]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_11 & busIO_enable & busIO_write & ~_T_12 & ~_T_13 & ~_T_14 & _T_3) begin
          $fwrite(32'h80000002,
            "Assertion failed: Tried to write to invalid address %d on wishbone bus master\n    at WishboneMaster.scala:58 assert(false.B, \"Tried to write to invalid address %%%%d on wishbone bus master\",addr)\n"
            ,busIO_addr); // @[WishboneMaster.scala 58:19]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_11 & busIO_enable & busIO_write & ~_T_12 & ~_T_13 & ~_T_14 & _T_3) begin
          $fatal; // @[WishboneMaster.scala 58:19]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_59 & ~busIO_write & ~_T_18 & ~_T_19 & _T_3) begin
          $fwrite(32'h80000002,
            "Assertion failed: Tried to read from invalid address %d on wishbone bus master\n    at WishboneMaster.scala:68 assert(false.B, \"Tried to read from invalid address %%%%d on wishbone bus master\", addr)\n"
            ,busIO_addr); // @[WishboneMaster.scala 68:19]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_GEN_59 & ~busIO_write & ~_T_18 & ~_T_19 & _T_3) begin
          $fatal; // @[WishboneMaster.scala 68:19]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regAddr = _RAND_0[9:0];
  _RAND_1 = {1{`RANDOM}};
  regWriteData = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  regReadData = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  regStatus = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  regBusRead = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  regState = _RAND_5[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Rx(
  input        clock,
  input        reset,
  input        io_rxd,
  input        io_channel_ready,
  output       io_channel_valid,
  output [7:0] io_channel_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg  rxReg_REG; // @[Uart.scala 76:30]
  reg  rxReg; // @[Uart.scala 76:22]
  reg [7:0] shiftReg; // @[Uart.scala 78:25]
  reg [19:0] cntReg; // @[Uart.scala 79:23]
  reg [3:0] bitsReg; // @[Uart.scala 80:24]
  reg  valReg; // @[Uart.scala 81:23]
  wire [19:0] _cntReg_T_1 = cntReg - 20'h1; // @[Uart.scala 84:22]
  wire [7:0] _shiftReg_T_1 = {rxReg,shiftReg[7:1]}; // @[Cat.scala 33:92]
  wire [3:0] _bitsReg_T_1 = bitsReg - 4'h1; // @[Uart.scala 88:24]
  wire  _GEN_0 = bitsReg == 4'h1 | valReg; // @[Uart.scala 90:27 91:14 81:23]
  assign io_channel_valid = valReg; // @[Uart.scala 103:20]
  assign io_channel_bits = shiftReg; // @[Uart.scala 102:19]
  always @(posedge clock) begin
    rxReg_REG <= reset | io_rxd; // @[Uart.scala 76:{30,30,30}]
    rxReg <= reset | rxReg_REG; // @[Uart.scala 76:{22,22,22}]
    if (reset) begin // @[Uart.scala 78:25]
      shiftReg <= 8'h0; // @[Uart.scala 78:25]
    end else if (!(cntReg != 20'h0)) begin // @[Uart.scala 83:24]
      if (bitsReg != 4'h0) begin // @[Uart.scala 85:31]
        shiftReg <= _shiftReg_T_1; // @[Uart.scala 87:14]
      end
    end
    if (reset) begin // @[Uart.scala 79:23]
      cntReg <= 20'h0; // @[Uart.scala 79:23]
    end else if (cntReg != 20'h0) begin // @[Uart.scala 83:24]
      cntReg <= _cntReg_T_1; // @[Uart.scala 84:12]
    end else if (bitsReg != 4'h0) begin // @[Uart.scala 85:31]
      cntReg <= 20'h365; // @[Uart.scala 86:12]
    end else if (~rxReg) begin // @[Uart.scala 93:29]
      cntReg <= 20'h517; // @[Uart.scala 94:12]
    end
    if (reset) begin // @[Uart.scala 80:24]
      bitsReg <= 4'h0; // @[Uart.scala 80:24]
    end else if (!(cntReg != 20'h0)) begin // @[Uart.scala 83:24]
      if (bitsReg != 4'h0) begin // @[Uart.scala 85:31]
        bitsReg <= _bitsReg_T_1; // @[Uart.scala 88:13]
      end else if (~rxReg) begin // @[Uart.scala 93:29]
        bitsReg <= 4'h8; // @[Uart.scala 95:13]
      end
    end
    if (reset) begin // @[Uart.scala 81:23]
      valReg <= 1'h0; // @[Uart.scala 81:23]
    end else if (valReg & io_channel_ready) begin // @[Uart.scala 98:36]
      valReg <= 1'h0; // @[Uart.scala 99:12]
    end else if (!(cntReg != 20'h0)) begin // @[Uart.scala 83:24]
      if (bitsReg != 4'h0) begin // @[Uart.scala 85:31]
        valReg <= _GEN_0;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  rxReg_REG = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  rxReg = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  shiftReg = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  cntReg = _RAND_3[19:0];
  _RAND_4 = {1{`RANDOM}};
  bitsReg = _RAND_4[3:0];
  _RAND_5 = {1{`RANDOM}};
  valReg = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Tx(
  input        clock,
  input        reset,
  output       io_txd,
  output       io_channel_ready,
  input        io_channel_valid,
  input  [7:0] io_channel_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [10:0] shiftReg; // @[Uart.scala 30:25]
  reg [19:0] cntReg; // @[Uart.scala 31:23]
  reg [3:0] bitsReg; // @[Uart.scala 32:24]
  wire  _io_channel_ready_T = cntReg == 20'h0; // @[Uart.scala 34:31]
  wire [9:0] shift = shiftReg[10:1]; // @[Uart.scala 41:28]
  wire [10:0] _shiftReg_T_1 = {1'h1,shift}; // @[Cat.scala 33:92]
  wire [3:0] _bitsReg_T_1 = bitsReg - 4'h1; // @[Uart.scala 43:26]
  wire [10:0] _shiftReg_T_3 = {2'h3,io_channel_bits,1'h0}; // @[Cat.scala 33:92]
  wire [19:0] _cntReg_T_1 = cntReg - 20'h1; // @[Uart.scala 54:22]
  assign io_txd = shiftReg[0]; // @[Uart.scala 35:21]
  assign io_channel_ready = cntReg == 20'h0 & bitsReg == 4'h0; // @[Uart.scala 34:40]
  always @(posedge clock) begin
    if (reset) begin // @[Uart.scala 30:25]
      shiftReg <= 11'h7ff; // @[Uart.scala 30:25]
    end else if (_io_channel_ready_T) begin // @[Uart.scala 37:24]
      if (bitsReg != 4'h0) begin // @[Uart.scala 40:27]
        shiftReg <= _shiftReg_T_1; // @[Uart.scala 42:16]
      end else if (io_channel_valid) begin // @[Uart.scala 45:30]
        shiftReg <= _shiftReg_T_3; // @[Uart.scala 46:18]
      end else begin
        shiftReg <= 11'h7ff; // @[Uart.scala 49:18]
      end
    end
    if (reset) begin // @[Uart.scala 31:23]
      cntReg <= 20'h0; // @[Uart.scala 31:23]
    end else if (_io_channel_ready_T) begin // @[Uart.scala 37:24]
      cntReg <= 20'h365; // @[Uart.scala 39:12]
    end else begin
      cntReg <= _cntReg_T_1; // @[Uart.scala 54:12]
    end
    if (reset) begin // @[Uart.scala 32:24]
      bitsReg <= 4'h0; // @[Uart.scala 32:24]
    end else if (_io_channel_ready_T) begin // @[Uart.scala 37:24]
      if (bitsReg != 4'h0) begin // @[Uart.scala 40:27]
        bitsReg <= _bitsReg_T_1; // @[Uart.scala 43:15]
      end else if (io_channel_valid) begin // @[Uart.scala 45:30]
        bitsReg <= 4'hb; // @[Uart.scala 47:17]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  shiftReg = _RAND_0[10:0];
  _RAND_1 = {1{`RANDOM}};
  cntReg = _RAND_1[19:0];
  _RAND_2 = {1{`RANDOM}};
  bitsReg = _RAND_2[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [7:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [7:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:7]; // @[Decoupled.scala 273:95]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 273:95]
  wire [2:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 273:95]
  wire [7:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 273:95]
  wire [7:0] ram_MPORT_data; // @[Decoupled.scala 273:95]
  wire [2:0] ram_MPORT_addr; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_mask; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_en; // @[Decoupled.scala 273:95]
  reg [2:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [2:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 276:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 277:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 278:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 279:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 51:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 51:35]
  wire [2:0] _value_T_1 = enq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  wire [2:0] _value_T_3 = deq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  assign ram_io_deq_bits_MPORT_en = 1'h1;
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 273:95]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 303:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 302:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 310:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 273:95]
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_enq) begin // @[Decoupled.scala 286:16]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_deq) begin // @[Decoupled.scala 290:16]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Decoupled.scala 276:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 276:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 293:27]
      maybe_full <= do_enq; // @[Decoupled.scala 294:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 8; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_1(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [7:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [7:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:7]; // @[Decoupled.scala 273:95]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 273:95]
  wire [2:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 273:95]
  wire [7:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 273:95]
  wire [7:0] ram_MPORT_data; // @[Decoupled.scala 273:95]
  wire [2:0] ram_MPORT_addr; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_mask; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_en; // @[Decoupled.scala 273:95]
  reg [2:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [2:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 276:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 277:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 278:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 279:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 51:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 51:35]
  wire [2:0] _value_T_1 = enq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  wire [2:0] _value_T_3 = deq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  assign ram_io_deq_bits_MPORT_en = 1'h1;
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 273:95]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 303:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 302:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 310:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 273:95]
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_enq) begin // @[Decoupled.scala 286:16]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_deq) begin // @[Decoupled.scala 290:16]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Decoupled.scala 276:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 276:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 293:27]
      maybe_full <= do_enq; // @[Decoupled.scala 294:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 8; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WishboneUart(
  input         clock,
  input         reset,
  input  [3:0]  io_port_addr,
  input  [31:0] io_port_wrData,
  output [31:0] io_port_rdData,
  input         io_port_we,
  input         io_port_stb,
  output        io_port_ack,
  input         io_port_cyc,
  input         ioUart_rx,
  output        ioUart_tx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  wire  Rx_clock; // @[WishboneUart.scala 33:18]
  wire  Rx_reset; // @[WishboneUart.scala 33:18]
  wire  Rx_io_rxd; // @[WishboneUart.scala 33:18]
  wire  Rx_io_channel_ready; // @[WishboneUart.scala 33:18]
  wire  Rx_io_channel_valid; // @[WishboneUart.scala 33:18]
  wire [7:0] Rx_io_channel_bits; // @[WishboneUart.scala 33:18]
  wire  Tx_clock; // @[WishboneUart.scala 34:18]
  wire  Tx_reset; // @[WishboneUart.scala 34:18]
  wire  Tx_io_txd; // @[WishboneUart.scala 34:18]
  wire  Tx_io_channel_ready; // @[WishboneUart.scala 34:18]
  wire  Tx_io_channel_valid; // @[WishboneUart.scala 34:18]
  wire [7:0] Tx_io_channel_bits; // @[WishboneUart.scala 34:18]
  wire  Queue_clock; // @[WishboneUart.scala 42:22]
  wire  Queue_reset; // @[WishboneUart.scala 42:22]
  wire  Queue_io_enq_ready; // @[WishboneUart.scala 42:22]
  wire  Queue_io_enq_valid; // @[WishboneUart.scala 42:22]
  wire [7:0] Queue_io_enq_bits; // @[WishboneUart.scala 42:22]
  wire  Queue_io_deq_ready; // @[WishboneUart.scala 42:22]
  wire  Queue_io_deq_valid; // @[WishboneUart.scala 42:22]
  wire [7:0] Queue_io_deq_bits; // @[WishboneUart.scala 42:22]
  wire  Queue_1_clock; // @[WishboneUart.scala 43:22]
  wire  Queue_1_reset; // @[WishboneUart.scala 43:22]
  wire  Queue_1_io_enq_ready; // @[WishboneUart.scala 43:22]
  wire  Queue_1_io_enq_valid; // @[WishboneUart.scala 43:22]
  wire [7:0] Queue_1_io_enq_bits; // @[WishboneUart.scala 43:22]
  wire  Queue_1_io_deq_ready; // @[WishboneUart.scala 43:22]
  wire  Queue_1_io_deq_valid; // @[WishboneUart.scala 43:22]
  wire [7:0] Queue_1_io_deq_bits; // @[WishboneUart.scala 43:22]
  reg  fault_bad_addr; // @[WishboneUart.scala 50:31]
  reg [2:0] regCSR; // @[WishboneUart.scala 53:23]
  wire  wCSR_1 = ~Queue_1_io_enq_ready; // @[WishboneUart.scala 56:29]
  wire  wCSR_0 = Queue_io_deq_valid; // @[WishboneUart.scala 54:22 55:22]
  wire [2:0] _regCSR_T = {fault_bad_addr,wCSR_1,wCSR_0}; // @[WishboneUart.scala 58:18]
  reg [7:0] regReadData; // @[WishboneUart.scala 61:28]
  reg [1:0] regState; // @[WishboneUart.scala 69:25]
  wire  start = io_port_cyc & io_port_stb; // @[WishboneUart.scala 70:24]
  wire  _T = 2'h0 == regState; // @[WishboneUart.scala 72:21]
  wire  _T_1 = io_port_addr == 4'h0; // @[WishboneUart.scala 76:26]
  wire  _T_2 = Queue_1_io_enq_ready & Queue_1_io_enq_valid; // @[Decoupled.scala 51:35]
  wire  _T_4 = ~reset; // @[WishboneUart.scala 79:19]
  wire [31:0] _GEN_1 = io_port_addr == 4'h0 ? io_port_wrData : 32'h0; // @[WishboneUart.scala 47:19 76:41 78:29]
  wire  _GEN_2 = io_port_addr == 4'h0 ? fault_bad_addr : 1'h1; // @[WishboneUart.scala 50:31 76:41 81:28]
  wire  _T_6 = io_port_addr == 4'h4; // @[WishboneUart.scala 85:26]
  wire  _T_7 = Queue_io_deq_ready & Queue_io_deq_valid; // @[Decoupled.scala 51:35]
  wire [7:0] _GEN_3 = io_port_addr == 4'hc ? 8'h55 : regReadData; // @[WishboneUart.scala 92:50 93:25 61:28]
  wire  _GEN_4 = io_port_addr == 4'hc ? fault_bad_addr : 1'h1; // @[WishboneUart.scala 50:31 92:50 95:28]
  wire [7:0] _GEN_5 = io_port_addr == 4'h8 ? {{5'd0}, regCSR} : _GEN_3; // @[WishboneUart.scala 89:48 90:25]
  wire  _GEN_6 = io_port_addr == 4'h8 ? 1'h0 : _GEN_4; // @[WishboneUart.scala 89:48 91:28]
  wire [7:0] _GEN_7 = io_port_addr == 4'h4 ? Queue_io_deq_bits : _GEN_5; // @[WishboneUart.scala 85:41 86:25]
  wire  _GEN_9 = io_port_addr == 4'h4 ? fault_bad_addr : _GEN_6; // @[WishboneUart.scala 50:31 85:41]
  wire  _GEN_10 = io_port_we & _T_1; // @[WishboneUart.scala 46:20 75:23]
  wire [31:0] _GEN_11 = io_port_we ? _GEN_1 : 32'h0; // @[WishboneUart.scala 47:19 75:23]
  wire  _GEN_15 = io_port_we ? 1'h0 : _T_6; // @[WishboneUart.scala 48:20 75:23]
  wire  _GEN_16 = start & _GEN_10; // @[WishboneUart.scala 74:19 46:20]
  wire [31:0] _GEN_17 = start ? _GEN_11 : 32'h0; // @[WishboneUart.scala 47:19 74:19]
  wire  _GEN_21 = start & _GEN_15; // @[WishboneUart.scala 74:19 48:20]
  wire  _GEN_25 = 2'h2 == regState | 2'h1 == regState; // @[WishboneUart.scala 103:16 72:21]
  wire [31:0] _GEN_29 = 2'h0 == regState ? _GEN_17 : 32'h0; // @[WishboneUart.scala 47:19 72:21]
  wire  _GEN_35 = _T & start; // @[WishboneUart.scala 79:19]
  Rx Rx ( // @[WishboneUart.scala 33:18]
    .clock(Rx_clock),
    .reset(Rx_reset),
    .io_rxd(Rx_io_rxd),
    .io_channel_ready(Rx_io_channel_ready),
    .io_channel_valid(Rx_io_channel_valid),
    .io_channel_bits(Rx_io_channel_bits)
  );
  Tx Tx ( // @[WishboneUart.scala 34:18]
    .clock(Tx_clock),
    .reset(Tx_reset),
    .io_txd(Tx_io_txd),
    .io_channel_ready(Tx_io_channel_ready),
    .io_channel_valid(Tx_io_channel_valid),
    .io_channel_bits(Tx_io_channel_bits)
  );
  Queue Queue ( // @[WishboneUart.scala 42:22]
    .clock(Queue_clock),
    .reset(Queue_reset),
    .io_enq_ready(Queue_io_enq_ready),
    .io_enq_valid(Queue_io_enq_valid),
    .io_enq_bits(Queue_io_enq_bits),
    .io_deq_ready(Queue_io_deq_ready),
    .io_deq_valid(Queue_io_deq_valid),
    .io_deq_bits(Queue_io_deq_bits)
  );
  Queue_1 Queue_1 ( // @[WishboneUart.scala 43:22]
    .clock(Queue_1_clock),
    .reset(Queue_1_reset),
    .io_enq_ready(Queue_1_io_enq_ready),
    .io_enq_valid(Queue_1_io_enq_valid),
    .io_enq_bits(Queue_1_io_enq_bits),
    .io_deq_ready(Queue_1_io_deq_ready),
    .io_deq_valid(Queue_1_io_deq_valid),
    .io_deq_bits(Queue_1_io_deq_bits)
  );
  assign io_port_rdData = {{24'd0}, regReadData}; // @[WishboneUart.scala 66:15]
  assign io_port_ack = 2'h0 == regState ? 1'h0 : _GEN_25; // @[WishboneUart.scala 72:21 WishboneIO.scala 46:9]
  assign ioUart_tx = Tx_io_txd; // @[WishboneUart.scala 36:13]
  assign Rx_clock = clock;
  assign Rx_reset = reset;
  assign Rx_io_rxd = ioUart_rx; // @[WishboneUart.scala 37:10]
  assign Rx_io_channel_ready = Queue_io_enq_ready; // @[WishboneUart.scala 44:14]
  assign Tx_clock = clock;
  assign Tx_reset = reset;
  assign Tx_io_channel_valid = Queue_1_io_deq_valid; // @[WishboneUart.scala 45:14]
  assign Tx_io_channel_bits = Queue_1_io_deq_bits; // @[WishboneUart.scala 45:14]
  assign Queue_clock = clock;
  assign Queue_reset = reset;
  assign Queue_io_enq_valid = Rx_io_channel_valid; // @[WishboneUart.scala 44:14]
  assign Queue_io_enq_bits = Rx_io_channel_bits; // @[WishboneUart.scala 44:14]
  assign Queue_io_deq_ready = 2'h0 == regState & _GEN_21; // @[WishboneUart.scala 48:20 72:21]
  assign Queue_1_clock = clock;
  assign Queue_1_reset = reset;
  assign Queue_1_io_enq_valid = 2'h0 == regState & _GEN_16; // @[WishboneUart.scala 46:20 72:21]
  assign Queue_1_io_enq_bits = _GEN_29[7:0];
  assign Queue_1_io_deq_ready = Tx_io_channel_ready; // @[WishboneUart.scala 45:14]
  always @(posedge clock) begin
    if (reset) begin // @[WishboneUart.scala 50:31]
      fault_bad_addr <= 1'h0; // @[WishboneUart.scala 50:31]
    end else if (2'h0 == regState) begin // @[WishboneUart.scala 72:21]
      if (start) begin // @[WishboneUart.scala 74:19]
        if (io_port_we) begin // @[WishboneUart.scala 75:23]
          fault_bad_addr <= _GEN_2;
        end else begin
          fault_bad_addr <= _GEN_9;
        end
      end
    end
    if (reset) begin // @[WishboneUart.scala 53:23]
      regCSR <= 3'h0; // @[WishboneUart.scala 53:23]
    end else begin
      regCSR <= _regCSR_T; // @[WishboneUart.scala 58:10]
    end
    if (reset) begin // @[WishboneUart.scala 61:28]
      regReadData <= 8'h0; // @[WishboneUart.scala 61:28]
    end else if (2'h0 == regState) begin // @[WishboneUart.scala 72:21]
      if (start) begin // @[WishboneUart.scala 74:19]
        if (!(io_port_we)) begin // @[WishboneUart.scala 75:23]
          regReadData <= _GEN_7;
        end
      end
    end else if (!(2'h2 == regState)) begin // @[WishboneUart.scala 72:21]
      if (2'h1 == regState) begin // @[WishboneUart.scala 72:21]
        regReadData <= 8'h0; // @[WishboneUart.scala 110:19]
      end
    end
    if (reset) begin // @[WishboneUart.scala 69:25]
      regState <= 2'h0; // @[WishboneUart.scala 69:25]
    end else if (2'h0 == regState) begin // @[WishboneUart.scala 72:21]
      if (start) begin // @[WishboneUart.scala 74:19]
        if (io_port_we) begin // @[WishboneUart.scala 75:23]
          regState <= 2'h2; // @[WishboneUart.scala 83:20]
        end else begin
          regState <= 2'h1; // @[WishboneUart.scala 97:20]
        end
      end
    end else if (2'h2 == regState) begin // @[WishboneUart.scala 72:21]
      regState <= 2'h0; // @[WishboneUart.scala 104:16]
    end else if (2'h1 == regState) begin // @[WishboneUart.scala 72:21]
      regState <= 2'h0; // @[WishboneUart.scala 109:16]
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T & start & io_port_we & _T_1 & ~reset & ~_T_2) begin
          $fwrite(32'h80000002,"Assertion failed\n    at WishboneUart.scala:79 assert(txFifo.enq.fire)\n"); // @[WishboneUart.scala 79:19]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T & start & io_port_we & _T_1 & ~reset & ~_T_2) begin
          $fatal; // @[WishboneUart.scala 79:19]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_35 & ~io_port_we & _T_6 & _T_4 & ~_T_7) begin
          $fwrite(32'h80000002,"Assertion failed\n    at WishboneUart.scala:88 assert(rxFifo.deq.fire)\n"); // @[WishboneUart.scala 88:19]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_GEN_35 & ~io_port_we & _T_6 & _T_4 & ~_T_7) begin
          $fatal; // @[WishboneUart.scala 88:19]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  fault_bad_addr = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regCSR = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  regReadData = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  regState = _RAND_3[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WishboneBus(
  input  [9:0]  io_wbMaster_addr,
  input  [31:0] io_wbMaster_wrData,
  output [31:0] io_wbMaster_rdData,
  input         io_wbMaster_we,
  input         io_wbMaster_stb,
  output        io_wbMaster_ack,
  input         io_wbMaster_cyc,
  output [3:0]  io_wbDevices_0_addr,
  output [31:0] io_wbDevices_0_wrData,
  input  [31:0] io_wbDevices_0_rdData,
  output        io_wbDevices_0_we,
  output        io_wbDevices_0_stb,
  input         io_wbDevices_0_ack,
  output        io_wbDevices_0_cyc
);
  wire  _T = io_wbMaster_cyc & io_wbMaster_stb; // @[WishboneBus.scala 40:7]
  wire  _T_4 = _T & io_wbMaster_addr < 10'h10; // @[WishboneBus.scala 42:7]
  assign io_wbMaster_rdData = _T_4 ? io_wbDevices_0_rdData : 32'h0; // @[WishboneBus.scala 43:7 47:26 WishboneIO.scala 45:12]
  assign io_wbMaster_ack = _T_4 & io_wbDevices_0_ack; // @[WishboneBus.scala 43:7 48:23 WishboneIO.scala 46:9]
  assign io_wbDevices_0_addr = io_wbMaster_addr[3:0]; // @[WishboneBus.scala 35:14]
  assign io_wbDevices_0_wrData = io_wbMaster_wrData; // @[WishboneBus.scala 36:16]
  assign io_wbDevices_0_we = _T_4 & io_wbMaster_we; // @[WishboneBus.scala 43:7 44:14 WishboneIO.scala 38:8]
  assign io_wbDevices_0_stb = _T_4 & io_wbMaster_stb; // @[WishboneBus.scala 43:7 45:15 WishboneIO.scala 41:9]
  assign io_wbDevices_0_cyc = _T_4 & io_wbMaster_cyc; // @[WishboneBus.scala 43:7 46:15 WishboneIO.scala 39:9]
endmodule
module FpgaTop(
  input        clock,
  input        reset,
  input        io_gpio_in_3,
  input        io_gpio_in_2,
  input        io_gpio_in_1,
  input        io_gpio_in_0,
  output [1:0] io_gpio_out_3,
  output [1:0] io_gpio_out_2,
  output [1:0] io_gpio_out_1,
  output [1:0] io_gpio_out_0,
  input        io_uart_rx,
  output       io_uart_tx,
  input        io_int_exts_0,
  input        io_int_exts_1,
  input        io_int_exts_2,
  input        io_int_exts_3
);
  wire  core_clock; // @[Top.scala 27:22]
  wire  core_reset; // @[Top.scala 27:22]
  wire [9:0] core_io_bus_addr; // @[Top.scala 27:22]
  wire  core_io_bus_enable; // @[Top.scala 27:22]
  wire [31:0] core_io_bus_data_out; // @[Top.scala 27:22]
  wire  core_io_bus_write; // @[Top.scala 27:22]
  wire [31:0] core_io_bus_data_in; // @[Top.scala 27:22]
  wire  core_io_gpio_in_3; // @[Top.scala 27:22]
  wire  core_io_gpio_in_2; // @[Top.scala 27:22]
  wire  core_io_gpio_in_1; // @[Top.scala 27:22]
  wire  core_io_gpio_in_0; // @[Top.scala 27:22]
  wire [1:0] core_io_gpio_out_3; // @[Top.scala 27:22]
  wire [1:0] core_io_gpio_out_2; // @[Top.scala 27:22]
  wire [1:0] core_io_gpio_out_1; // @[Top.scala 27:22]
  wire [1:0] core_io_gpio_out_0; // @[Top.scala 27:22]
  wire  core_io_int_exts_0; // @[Top.scala 27:22]
  wire  core_io_int_exts_1; // @[Top.scala 27:22]
  wire  core_io_int_exts_2; // @[Top.scala 27:22]
  wire  core_io_int_exts_3; // @[Top.scala 27:22]
  wire  wbMaster_clock; // @[Top.scala 29:26]
  wire  wbMaster_reset; // @[Top.scala 29:26]
  wire [9:0] wbMaster_wbIO_addr; // @[Top.scala 29:26]
  wire [31:0] wbMaster_wbIO_wrData; // @[Top.scala 29:26]
  wire [31:0] wbMaster_wbIO_rdData; // @[Top.scala 29:26]
  wire  wbMaster_wbIO_we; // @[Top.scala 29:26]
  wire  wbMaster_wbIO_stb; // @[Top.scala 29:26]
  wire  wbMaster_wbIO_ack; // @[Top.scala 29:26]
  wire  wbMaster_wbIO_cyc; // @[Top.scala 29:26]
  wire [9:0] wbMaster_busIO_addr; // @[Top.scala 29:26]
  wire  wbMaster_busIO_enable; // @[Top.scala 29:26]
  wire [31:0] wbMaster_busIO_data_out; // @[Top.scala 29:26]
  wire  wbMaster_busIO_write; // @[Top.scala 29:26]
  wire [31:0] wbMaster_busIO_data_in; // @[Top.scala 29:26]
  wire  wbUart_clock; // @[Top.scala 30:26]
  wire  wbUart_reset; // @[Top.scala 30:26]
  wire [3:0] wbUart_io_port_addr; // @[Top.scala 30:26]
  wire [31:0] wbUart_io_port_wrData; // @[Top.scala 30:26]
  wire [31:0] wbUart_io_port_rdData; // @[Top.scala 30:26]
  wire  wbUart_io_port_we; // @[Top.scala 30:26]
  wire  wbUart_io_port_stb; // @[Top.scala 30:26]
  wire  wbUart_io_port_ack; // @[Top.scala 30:26]
  wire  wbUart_io_port_cyc; // @[Top.scala 30:26]
  wire  wbUart_ioUart_rx; // @[Top.scala 30:26]
  wire  wbUart_ioUart_tx; // @[Top.scala 30:26]
  wire [9:0] wbBus_io_wbMaster_addr; // @[Top.scala 31:26]
  wire [31:0] wbBus_io_wbMaster_wrData; // @[Top.scala 31:26]
  wire [31:0] wbBus_io_wbMaster_rdData; // @[Top.scala 31:26]
  wire  wbBus_io_wbMaster_we; // @[Top.scala 31:26]
  wire  wbBus_io_wbMaster_stb; // @[Top.scala 31:26]
  wire  wbBus_io_wbMaster_ack; // @[Top.scala 31:26]
  wire  wbBus_io_wbMaster_cyc; // @[Top.scala 31:26]
  wire [3:0] wbBus_io_wbDevices_0_addr; // @[Top.scala 31:26]
  wire [31:0] wbBus_io_wbDevices_0_wrData; // @[Top.scala 31:26]
  wire [31:0] wbBus_io_wbDevices_0_rdData; // @[Top.scala 31:26]
  wire  wbBus_io_wbDevices_0_we; // @[Top.scala 31:26]
  wire  wbBus_io_wbDevices_0_stb; // @[Top.scala 31:26]
  wire  wbBus_io_wbDevices_0_ack; // @[Top.scala 31:26]
  wire  wbBus_io_wbDevices_0_cyc; // @[Top.scala 31:26]
  Core core ( // @[Top.scala 27:22]
    .clock(core_clock),
    .reset(core_reset),
    .io_bus_addr(core_io_bus_addr),
    .io_bus_enable(core_io_bus_enable),
    .io_bus_data_out(core_io_bus_data_out),
    .io_bus_write(core_io_bus_write),
    .io_bus_data_in(core_io_bus_data_in),
    .io_gpio_in_3(core_io_gpio_in_3),
    .io_gpio_in_2(core_io_gpio_in_2),
    .io_gpio_in_1(core_io_gpio_in_1),
    .io_gpio_in_0(core_io_gpio_in_0),
    .io_gpio_out_3(core_io_gpio_out_3),
    .io_gpio_out_2(core_io_gpio_out_2),
    .io_gpio_out_1(core_io_gpio_out_1),
    .io_gpio_out_0(core_io_gpio_out_0),
    .io_int_exts_0(core_io_int_exts_0),
    .io_int_exts_1(core_io_int_exts_1),
    .io_int_exts_2(core_io_int_exts_2),
    .io_int_exts_3(core_io_int_exts_3)
  );
  WishboneMaster wbMaster ( // @[Top.scala 29:26]
    .clock(wbMaster_clock),
    .reset(wbMaster_reset),
    .wbIO_addr(wbMaster_wbIO_addr),
    .wbIO_wrData(wbMaster_wbIO_wrData),
    .wbIO_rdData(wbMaster_wbIO_rdData),
    .wbIO_we(wbMaster_wbIO_we),
    .wbIO_stb(wbMaster_wbIO_stb),
    .wbIO_ack(wbMaster_wbIO_ack),
    .wbIO_cyc(wbMaster_wbIO_cyc),
    .busIO_addr(wbMaster_busIO_addr),
    .busIO_enable(wbMaster_busIO_enable),
    .busIO_data_out(wbMaster_busIO_data_out),
    .busIO_write(wbMaster_busIO_write),
    .busIO_data_in(wbMaster_busIO_data_in)
  );
  WishboneUart wbUart ( // @[Top.scala 30:26]
    .clock(wbUart_clock),
    .reset(wbUart_reset),
    .io_port_addr(wbUart_io_port_addr),
    .io_port_wrData(wbUart_io_port_wrData),
    .io_port_rdData(wbUart_io_port_rdData),
    .io_port_we(wbUart_io_port_we),
    .io_port_stb(wbUart_io_port_stb),
    .io_port_ack(wbUart_io_port_ack),
    .io_port_cyc(wbUart_io_port_cyc),
    .ioUart_rx(wbUart_ioUart_rx),
    .ioUart_tx(wbUart_ioUart_tx)
  );
  WishboneBus wbBus ( // @[Top.scala 31:26]
    .io_wbMaster_addr(wbBus_io_wbMaster_addr),
    .io_wbMaster_wrData(wbBus_io_wbMaster_wrData),
    .io_wbMaster_rdData(wbBus_io_wbMaster_rdData),
    .io_wbMaster_we(wbBus_io_wbMaster_we),
    .io_wbMaster_stb(wbBus_io_wbMaster_stb),
    .io_wbMaster_ack(wbBus_io_wbMaster_ack),
    .io_wbMaster_cyc(wbBus_io_wbMaster_cyc),
    .io_wbDevices_0_addr(wbBus_io_wbDevices_0_addr),
    .io_wbDevices_0_wrData(wbBus_io_wbDevices_0_wrData),
    .io_wbDevices_0_rdData(wbBus_io_wbDevices_0_rdData),
    .io_wbDevices_0_we(wbBus_io_wbDevices_0_we),
    .io_wbDevices_0_stb(wbBus_io_wbDevices_0_stb),
    .io_wbDevices_0_ack(wbBus_io_wbDevices_0_ack),
    .io_wbDevices_0_cyc(wbBus_io_wbDevices_0_cyc)
  );
  assign io_gpio_out_3 = core_io_gpio_out_3; // @[Top.scala 92:13]
  assign io_gpio_out_2 = core_io_gpio_out_2; // @[Top.scala 92:13]
  assign io_gpio_out_1 = core_io_gpio_out_1; // @[Top.scala 92:13]
  assign io_gpio_out_0 = core_io_gpio_out_0; // @[Top.scala 92:13]
  assign io_uart_tx = wbUart_ioUart_tx; // @[Top.scala 96:16]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_bus_data_out = wbMaster_busIO_data_out; // @[Top.scala 35:20]
  assign core_io_gpio_in_3 = io_gpio_in_3; // @[Top.scala 92:13]
  assign core_io_gpio_in_2 = io_gpio_in_2; // @[Top.scala 92:13]
  assign core_io_gpio_in_1 = io_gpio_in_1; // @[Top.scala 92:13]
  assign core_io_gpio_in_0 = io_gpio_in_0; // @[Top.scala 92:13]
  assign core_io_int_exts_0 = io_int_exts_0; // @[Top.scala 93:22]
  assign core_io_int_exts_1 = io_int_exts_1; // @[Top.scala 93:22]
  assign core_io_int_exts_2 = io_int_exts_2; // @[Top.scala 93:22]
  assign core_io_int_exts_3 = io_int_exts_3; // @[Top.scala 93:22]
  assign wbMaster_clock = clock;
  assign wbMaster_reset = reset;
  assign wbMaster_wbIO_rdData = wbBus_io_wbMaster_rdData; // @[Top.scala 39:23]
  assign wbMaster_wbIO_ack = wbBus_io_wbMaster_ack; // @[Top.scala 39:23]
  assign wbMaster_busIO_addr = core_io_bus_addr; // @[Top.scala 35:20]
  assign wbMaster_busIO_enable = core_io_bus_enable; // @[Top.scala 35:20]
  assign wbMaster_busIO_write = core_io_bus_write; // @[Top.scala 35:20]
  assign wbMaster_busIO_data_in = core_io_bus_data_in; // @[Top.scala 35:20]
  assign wbUart_clock = clock;
  assign wbUart_reset = reset;
  assign wbUart_io_port_addr = wbBus_io_wbDevices_0_addr; // @[Top.scala 42:27]
  assign wbUart_io_port_wrData = wbBus_io_wbDevices_0_wrData; // @[Top.scala 42:27]
  assign wbUart_io_port_we = wbBus_io_wbDevices_0_we; // @[Top.scala 42:27]
  assign wbUart_io_port_stb = wbBus_io_wbDevices_0_stb; // @[Top.scala 42:27]
  assign wbUart_io_port_cyc = wbBus_io_wbDevices_0_cyc; // @[Top.scala 42:27]
  assign wbUart_ioUart_rx = io_uart_rx; // @[Top.scala 97:22]
  assign wbBus_io_wbMaster_addr = wbMaster_wbIO_addr; // @[Top.scala 39:23]
  assign wbBus_io_wbMaster_wrData = wbMaster_wbIO_wrData; // @[Top.scala 39:23]
  assign wbBus_io_wbMaster_we = wbMaster_wbIO_we; // @[Top.scala 39:23]
  assign wbBus_io_wbMaster_stb = wbMaster_wbIO_stb; // @[Top.scala 39:23]
  assign wbBus_io_wbMaster_cyc = wbMaster_wbIO_cyc; // @[Top.scala 39:23]
  assign wbBus_io_wbDevices_0_rdData = wbUart_io_port_rdData; // @[Top.scala 42:27]
  assign wbBus_io_wbDevices_0_ack = wbUart_io_port_ack; // @[Top.scala 42:27]
endmodule
