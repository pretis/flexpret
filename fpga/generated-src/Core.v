module Scheduler(input clk, input reset,
    input [3:0] io_slots_7,
    input [3:0] io_slots_6,
    input [3:0] io_slots_5,
    input [3:0] io_slots_4,
    input [3:0] io_slots_3,
    input [3:0] io_slots_2,
    input [3:0] io_slots_1,
    input [3:0] io_slots_0,
    input [1:0] io_thread_modes_3,
    input [1:0] io_thread_modes_2,
    input [1:0] io_thread_modes_1,
    input [1:0] io_thread_modes_0,
    output[1:0] io_thread,
    output io_valid
);

  wire T0;
  wire T1;
  wire T2;
  wire T3;
  wire T4;
  wire[1:0] T5;
  wire[1:0] T6;
  wire T7;
  wire[1:0] T8;
  wire[1:0] T9;
  wire[3:0] T10;
  wire[3:0] T11;
  wire T12;
  wire T13;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  wire T18;
  wire T19;
  wire T20;
  wire T21;
  wire T22;
  wire T23;
  wire T24;
  wire T25;
  wire T26;
  wire T27;
  wire T28;
  wire T29;
  wire T30;
  wire T31;
  wire T32;
  wire T33;
  reg  R34;
  wire T214;
  wire T35;
  wire T36;
  wire T37;
  wire T38;
  wire T39;
  wire T40;
  wire T41;
  wire T42;
  wire T43;
  wire T44;
  wire T45;
  wire T46;
  wire T47;
  reg  R48;
  wire T215;
  wire T49;
  wire T50;
  wire T51;
  wire T52;
  wire T53;
  wire T54;
  wire T55;
  wire T56;
  wire T57;
  wire T58;
  wire T59;
  reg  R60;
  wire T216;
  wire T61;
  wire T62;
  wire T63;
  wire T64;
  reg  R65;
  wire T217;
  wire T66;
  wire T67;
  wire T68;
  wire T69;
  wire T70;
  reg  R71;
  wire T218;
  wire T72;
  wire T73;
  wire T74;
  wire T75;
  wire T76;
  wire T77;
  wire T78;
  wire T79;
  wire T80;
  wire T81;
  wire T82;
  wire T83;
  wire T84;
  wire T85;
  reg  R86;
  wire T219;
  wire T87;
  wire T88;
  wire T89;
  wire T90;
  wire T91;
  wire T92;
  wire T93;
  wire T94;
  wire T95;
  wire T96;
  wire T97;
  wire T98;
  wire T99;
  wire T100;
  wire T101;
  wire T102;
  wire T103;
  wire T104;
  wire T105;
  wire T106;
  wire T107;
  wire T108;
  wire T109;
  wire T110;
  reg  R111;
  wire T220;
  wire T112;
  wire T113;
  wire T114;
  wire T115;
  wire T116;
  wire T117;
  wire T118;
  wire T119;
  wire T120;
  wire T121;
  wire T122;
  wire T123;
  wire T124;
  wire T125;
  wire T126;
  wire T127;
  wire T128;
  wire T129;
  wire T130;
  wire T131;
  wire T132;
  wire T133;
  wire T134;
  wire T135;
  wire T136;
  wire T137;
  wire[3:0] T138;
  wire[3:0] T139;
  wire[3:0] T140;
  wire[3:0] T141;
  wire[3:0] T142;
  wire[3:0] T143;
  wire[3:0] T144;
  wire[3:0] T145;
  wire[3:0] T146;
  wire[3:0] T147;
  wire[3:0] T148;
  wire[3:0] T149;
  wire[3:0] T150;
  wire[1:0] T151;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  wire T156;
  wire T157;
  wire T158;
  wire T159;
  wire T160;
  wire T161;
  wire T162;
  wire T163;
  wire T164;
  wire T165;
  wire T166;
  wire T167;
  wire T168;
  wire T169;
  wire T170;
  wire T171;
  wire T172;
  wire T173;
  wire T174;
  wire T175;
  wire T176;
  wire T177;
  wire T178;
  wire T179;
  reg  R180;
  wire T221;
  wire T181;
  wire T182;
  wire T183;
  wire T184;
  reg  R185;
  wire T222;
  wire T186;
  wire T187;
  wire T188;
  wire T189;
  wire T190;
  reg  R191;
  wire T223;
  wire T192;
  wire T193;
  wire T194;
  wire T195;
  wire T196;
  wire T197;
  wire T198;
  wire T199;
  wire T200;
  wire T201;
  wire T202;
  wire T203;
  wire T204;
  wire[1:0] T224;
  wire[2:0] T205;
  wire[2:0] T206;
  wire[2:0] T225;
  wire[1:0] T207;
  wire[2:0] T208;
  wire[2:0] T226;
  wire[1:0] T227;
  wire T228;
  wire[1:0] T229;
  wire[1:0] T230;
  wire[3:0] T210;
  wire[3:0] T211;
  wire[1:0] T212;
  wire[1:0] T213;
  wire[1:0] T231;
  wire T232;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    R34 = {1{$random}};
    R48 = {1{$random}};
    R60 = {1{$random}};
    R65 = {1{$random}};
    R71 = {1{$random}};
    R86 = {1{$random}};
    R111 = {1{$random}};
    R180 = {1{$random}};
    R185 = {1{$random}};
    R191 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_valid = T0;
  assign T0 = T163 ? 1'h1 : T1;
  assign T1 = T156 & T2;
  assign T2 = T155 & T3;
  assign T3 = T154 | T4;
  assign T4 = T5 == 2'h2;
  assign T5 = T153 ? T151 : T6;
  assign T6 = T7 ? io_thread_modes_1 : io_thread_modes_0;
  assign T7 = T8[1'h0:1'h0];
  assign T8 = T9;
  assign T9 = T10[1'h1:1'h0];
  assign T10 = T138 | T11;
  assign T11 = T12 ? io_slots_7 : 4'h0;
  assign T12 = T132 ? T29 : T13;
  assign T13 = T28 & T14;
  assign T14 = T15 ^ 1'h1;
  assign T15 = T17 | T16;
  assign T16 = io_slots_6 != 4'hf;
  assign T17 = T19 | T18;
  assign T18 = io_slots_5 != 4'hf;
  assign T19 = T21 | T20;
  assign T20 = io_slots_4 != 4'hf;
  assign T21 = T23 | T22;
  assign T22 = io_slots_3 != 4'hf;
  assign T23 = T25 | T24;
  assign T24 = io_slots_2 != 4'hf;
  assign T25 = T27 | T26;
  assign T26 = io_slots_1 != 4'hf;
  assign T27 = io_slots_0 != 4'hf;
  assign T28 = io_slots_7 != 4'hf;
  assign T29 = T109 & T30;
  assign T30 = T31 ^ 1'h1;
  assign T31 = T105 | T32;
  assign T32 = T16 & T33;
  assign T33 = T101 | R34;
  assign T214 = reset ? 1'h0 : T35;
  assign T35 = T156 ? T36 : R34;
  assign T36 = T132 ? T43 : T37;
  assign T37 = T18 & T38;
  assign T38 = T39 ^ 1'h1;
  assign T39 = T40 | T20;
  assign T40 = T41 | T22;
  assign T41 = T42 | T24;
  assign T42 = T27 | T26;
  assign T43 = T84 & T44;
  assign T44 = T45 ^ 1'h1;
  assign T45 = T82 | T46;
  assign T46 = T20 & T47;
  assign T47 = T80 | R48;
  assign T215 = reset ? 1'h0 : T49;
  assign T49 = T156 ? T50 : R48;
  assign T50 = T132 ? T55 : T51;
  assign T51 = T22 & T52;
  assign T52 = T53 ^ 1'h1;
  assign T53 = T54 | T24;
  assign T54 = T27 | T26;
  assign T55 = T69 & T56;
  assign T56 = T57 ^ 1'h1;
  assign T57 = T68 | T58;
  assign T58 = T24 & T59;
  assign T59 = R65 | R60;
  assign T216 = reset ? 1'h0 : T61;
  assign T61 = T156 ? T62 : R60;
  assign T62 = T132 ? T68 : T63;
  assign T63 = T26 & T64;
  assign T64 = T27 ^ 1'h1;
  assign T217 = reset ? 1'h0 : T66;
  assign T66 = T156 ? T67 : R65;
  assign T67 = T132 ? 1'h0 : T27;
  assign T68 = T26 & R65;
  assign T69 = T22 & T70;
  assign T70 = T79 | R71;
  assign T218 = reset ? 1'h0 : T72;
  assign T72 = T156 ? T73 : R71;
  assign T73 = T132 ? T77 : T74;
  assign T74 = T24 & T75;
  assign T75 = T76 ^ 1'h1;
  assign T76 = T27 | T26;
  assign T77 = T58 & T78;
  assign T78 = T68 ^ 1'h1;
  assign T79 = R65 | R60;
  assign T80 = T81 | R71;
  assign T81 = R65 | R60;
  assign T82 = T83 | T69;
  assign T83 = T68 | T58;
  assign T84 = T18 & T85;
  assign T85 = T98 | R86;
  assign T219 = reset ? 1'h0 : T87;
  assign T87 = T156 ? T88 : R86;
  assign T88 = T132 ? T94 : T89;
  assign T89 = T20 & T90;
  assign T90 = T91 ^ 1'h1;
  assign T91 = T92 | T22;
  assign T92 = T93 | T24;
  assign T93 = T27 | T26;
  assign T94 = T46 & T95;
  assign T95 = T96 ^ 1'h1;
  assign T96 = T97 | T69;
  assign T97 = T68 | T58;
  assign T98 = T99 | R48;
  assign T99 = T100 | R71;
  assign T100 = R65 | R60;
  assign T101 = T102 | R86;
  assign T102 = T103 | R48;
  assign T103 = T104 | R71;
  assign T104 = R65 | R60;
  assign T105 = T106 | T84;
  assign T106 = T107 | T46;
  assign T107 = T108 | T69;
  assign T108 = T68 | T58;
  assign T109 = T28 & T110;
  assign T110 = T127 | R111;
  assign T220 = reset ? 1'h0 : T112;
  assign T112 = T156 ? T113 : R111;
  assign T113 = T132 ? T121 : T114;
  assign T114 = T16 & T115;
  assign T115 = T116 ^ 1'h1;
  assign T116 = T117 | T18;
  assign T117 = T118 | T20;
  assign T118 = T119 | T22;
  assign T119 = T120 | T24;
  assign T120 = T27 | T26;
  assign T121 = T32 & T122;
  assign T122 = T123 ^ 1'h1;
  assign T123 = T124 | T84;
  assign T124 = T125 | T46;
  assign T125 = T126 | T69;
  assign T126 = T68 | T58;
  assign T127 = T128 | R34;
  assign T128 = T129 | R86;
  assign T129 = T130 | R48;
  assign T130 = T131 | R71;
  assign T131 = R65 | R60;
  assign T132 = T133 | T109;
  assign T133 = T134 | T32;
  assign T134 = T135 | T84;
  assign T135 = T136 | T46;
  assign T136 = T137 | T69;
  assign T137 = T68 | T58;
  assign T138 = T140 | T139;
  assign T139 = T113 ? io_slots_6 : 4'h0;
  assign T140 = T142 | T141;
  assign T141 = T36 ? io_slots_5 : 4'h0;
  assign T142 = T144 | T143;
  assign T143 = T88 ? io_slots_4 : 4'h0;
  assign T144 = T146 | T145;
  assign T145 = T50 ? io_slots_3 : 4'h0;
  assign T146 = T148 | T147;
  assign T147 = T73 ? io_slots_2 : 4'h0;
  assign T148 = T150 | T149;
  assign T149 = T62 ? io_slots_1 : 4'h0;
  assign T150 = T67 ? io_slots_0 : 4'h0;
  assign T151 = T152 ? io_thread_modes_3 : io_thread_modes_2;
  assign T152 = T8[1'h0:1'h0];
  assign T153 = T8[1'h1:1'h1];
  assign T154 = T5 == 2'h0;
  assign T155 = T10 != 4'he;
  assign T156 = T157 | T12;
  assign T157 = T158 | T113;
  assign T158 = T159 | T36;
  assign T159 = T160 | T88;
  assign T160 = T161 | T50;
  assign T161 = T162 | T73;
  assign T162 = T67 | T62;
  assign T163 = T156 & T164;
  assign T164 = T204 & T165;
  assign T165 = T202 | T166;
  assign T166 = T200 ? T175 : T167;
  assign T167 = T174 & T168;
  assign T168 = T169 ^ 1'h1;
  assign T169 = T171 | T170;
  assign T170 = io_thread_modes_2 == 2'h2;
  assign T171 = T173 | T172;
  assign T172 = io_thread_modes_1 == 2'h2;
  assign T173 = io_thread_modes_0 == 2'h2;
  assign T174 = io_thread_modes_3 == 2'h2;
  assign T175 = T189 & T176;
  assign T176 = T177 ^ 1'h1;
  assign T177 = T188 | T178;
  assign T178 = T170 & T179;
  assign T179 = R185 | R180;
  assign T221 = reset ? 1'h0 : T181;
  assign T181 = T163 ? T182 : R180;
  assign T182 = T200 ? T188 : T183;
  assign T183 = T172 & T184;
  assign T184 = T173 ^ 1'h1;
  assign T222 = reset ? 1'h0 : T186;
  assign T186 = T163 ? T187 : R185;
  assign T187 = T200 ? 1'h0 : T173;
  assign T188 = T172 & R185;
  assign T189 = T174 & T190;
  assign T190 = T199 | R191;
  assign T223 = reset ? 1'h0 : T192;
  assign T192 = T163 ? T193 : R191;
  assign T193 = T200 ? T197 : T194;
  assign T194 = T170 & T195;
  assign T195 = T196 ^ 1'h1;
  assign T196 = T173 | T172;
  assign T197 = T178 & T198;
  assign T198 = T188 ^ 1'h1;
  assign T199 = R185 | R180;
  assign T200 = T201 | T189;
  assign T201 = T188 | T178;
  assign T202 = T203 | T193;
  assign T203 = T187 | T182;
  assign T204 = T2 ^ 1'h1;
  assign io_thread = T224;
  assign T224 = T205[1'h1:1'h0];
  assign T205 = T163 ? T226 : T206;
  assign T206 = T1 ? T208 : T225;
  assign T225 = {1'h0, T207};
  assign T207 = T10[1'h1:1'h0];
  assign T208 = T10[2'h2:1'h0];
  assign T226 = {1'h0, T227};
  assign T227 = {T232, T228};
  assign T228 = T229[1'h1:1'h1];
  assign T229 = T231 | T230;
  assign T230 = T210[1'h1:1'h0];
  assign T210 = T211;
  assign T211 = {T213, T212};
  assign T212 = {T182, T187};
  assign T213 = {T166, T193};
  assign T231 = T210[2'h3:2'h2];
  assign T232 = T231 != 2'h0;

  always @(posedge clk) begin
    if(reset) begin
      R34 <= 1'h0;
    end else if(T156) begin
      R34 <= T36;
    end
    if(reset) begin
      R48 <= 1'h0;
    end else if(T156) begin
      R48 <= T50;
    end
    if(reset) begin
      R60 <= 1'h0;
    end else if(T156) begin
      R60 <= T62;
    end
    if(reset) begin
      R65 <= 1'h0;
    end else if(T156) begin
      R65 <= T67;
    end
    if(reset) begin
      R71 <= 1'h0;
    end else if(T156) begin
      R71 <= T73;
    end
    if(reset) begin
      R86 <= 1'h0;
    end else if(T156) begin
      R86 <= T88;
    end
    if(reset) begin
      R111 <= 1'h0;
    end else if(T156) begin
      R111 <= T113;
    end
    if(reset) begin
      R180 <= 1'h0;
    end else if(T163) begin
      R180 <= T182;
    end
    if(reset) begin
      R185 <= 1'h0;
    end else if(T163) begin
      R185 <= T187;
    end
    if(reset) begin
      R191 <= 1'h0;
    end else if(T163) begin
      R191 <= T193;
    end
  end
endmodule

module Control(input clk, input reset,
    output[2:0] io_dec_imm_sel,
    output[1:0] io_dec_op1_sel,
    output[1:0] io_dec_op2_sel,
    output[3:0] io_exe_alu_type,
    output[2:0] io_exe_br_type,
    output[1:0] io_exe_csr_type,
    output[1:0] io_exe_mul_type,
    output[1:0] io_exe_rd_data_sel,
    output[3:0] io_exe_mem_type,
    output[1:0] io_mem_rd_data_sel,
    output[1:0] io_next_pc_sel_3,
    output[1:0] io_next_pc_sel_2,
    output[1:0] io_next_pc_sel_1,
    output[1:0] io_next_pc_sel_0,
    output[1:0] io_next_tid,
    output io_next_valid,
    output[1:0] io_dec_rs1_sel,
    output[1:0] io_dec_rs2_sel,
    output io_exe_valid,
    output io_exe_load,
    output io_exe_store,
    output io_exe_csr_write,
    output io_exe_exception,
    output[4:0] io_exe_cause,
    output io_exe_kill,
    output io_exe_sleep,
    output io_exe_ie,
    output io_exe_ee,
    output io_exe_sret,
    output io_exe_cycle,
    output io_exe_instret,
    output io_mem_rd_write,
    input [1:0] io_if_tid,
    input [1:0] io_dec_tid,
    input [31:0] io_dec_inst,
    input  io_exe_br_cond,
    input [1:0] io_exe_tid,
    input [4:0] io_exe_rd_addr,
    input  io_exe_expire,
    input [3:0] io_csr_slots_7,
    input [3:0] io_csr_slots_6,
    input [3:0] io_csr_slots_5,
    input [3:0] io_csr_slots_4,
    input [3:0] io_csr_slots_3,
    input [3:0] io_csr_slots_2,
    input [3:0] io_csr_slots_1,
    input [3:0] io_csr_slots_0,
    input [1:0] io_csr_tmodes_3,
    input [1:0] io_csr_tmodes_2,
    input [1:0] io_csr_tmodes_1,
    input [1:0] io_csr_tmodes_0,
    input [1:0] io_mem_tid,
    input [4:0] io_mem_rd_addr,
    input [1:0] io_wb_tid,
    input [4:0] io_wb_rd_addr,
    input  io_if_exc_misaligned,
    input  io_if_exc_fault,
    input  io_exe_exc_priv_inst,
    input  io_exe_exc_load_misaligned,
    input  io_exe_exc_load_fault,
    input  io_exe_exc_store_misaligned,
    input  io_exe_exc_store_fault,
    input  io_exe_exc_expire,
    input  io_exe_int_expire,
    input  io_exe_int_ext
);

  wire exe_valid;
  wire T0;
  wire exe_exception;
  wire T1;
  wire T2;
  wire exe_any_exc;
  wire T3;
  wire T4;
  wire exe_inst_exc;
  wire T5;
  reg  exe_reg_exc;
  wire T6;
  wire dec_exc;
  wire T7;
  wire dec_scall;
  wire[31:0] T8;
  wire T9;
  wire T10;
  wire dec_legal;
  wire T11;
  wire[31:0] T12;
  wire T13;
  wire T14;
  wire[31:0] T15;
  wire T16;
  wire T17;
  wire[31:0] T18;
  wire T19;
  wire T20;
  wire[31:0] T21;
  wire T22;
  wire dec_ie;
  wire[31:0] T23;
  wire T24;
  wire dec_du;
  wire[31:0] T25;
  wire T26;
  wire T27;
  wire[31:0] T28;
  wire T29;
  wire T30;
  wire[31:0] T31;
  wire T32;
  wire T33;
  wire[31:0] T34;
  wire T35;
  wire T36;
  wire[31:0] T37;
  wire T38;
  wire T39;
  wire[31:0] T40;
  wire T41;
  wire T42;
  wire T43;
  wire[31:0] T44;
  wire T45;
  wire T46;
  wire[31:0] T47;
  wire T48;
  wire T49;
  wire[31:0] T50;
  wire T51;
  wire T52;
  wire[31:0] T53;
  wire T54;
  wire T55;
  wire[31:0] T56;
  wire T57;
  wire T58;
  wire[31:0] T59;
  wire T60;
  wire T61;
  wire[31:0] T62;
  wire T63;
  wire[31:0] T64;
  reg  dec_reg_exc;
  reg  exe_reg_valid;
  wire T345;
  wire dec_valid;
  wire T65;
  wire T66;
  wire T67;
  wire exe_flush;
  wire T68;
  wire T69;
  wire exe_brjmp;
  wire T70;
  wire T71;
  reg  exe_reg_branch;
  wire T72;
  wire dec_branch;
  wire T73;
  wire[31:0] T74;
  reg  exe_reg_jump;
  wire T75;
  wire dec_jump;
  wire T76;
  wire[31:0] T77;
  wire exe_sleep;
  wire exe_du;
  wire T78;
  wire T79;
  wire T80;
  reg  R81;
  wire T82;
  reg  dec_reg_valid;
  wire T346;
  wire if_valid;
  wire T83;
  wire T84;
  wire T85;
  wire if_pre_valid;
  wire T86;
  wire[1:0] T87;
  wire[1:0] T88;
  reg [1:0] stall_count_0;
  wire[1:0] T347;
  wire[1:0] T89;
  wire[1:0] T90;
  wire[1:0] T91;
  wire[1:0] T92;
  wire[1:0] T93;
  wire T94;
  wire T95;
  wire T96;
  wire[3:0] T97;
  wire[1:0] T98;
  wire T99;
  wire T100;
  wire T101;
  wire dec_fence_i;
  wire[31:0] T102;
  wire T103;
  reg [1:0] stall_count_1;
  wire[1:0] T348;
  wire[1:0] T104;
  wire[1:0] T105;
  wire[1:0] T106;
  wire[1:0] T107;
  wire[1:0] T108;
  wire T109;
  wire T110;
  wire T111;
  wire T112;
  wire T113;
  wire T114;
  wire[1:0] T115;
  wire[1:0] T116;
  reg [1:0] stall_count_2;
  wire[1:0] T349;
  wire[1:0] T117;
  wire[1:0] T118;
  wire[1:0] T119;
  wire[1:0] T120;
  wire[1:0] T121;
  wire T122;
  wire T123;
  wire T124;
  wire T125;
  wire T126;
  reg [1:0] stall_count_3;
  wire[1:0] T350;
  wire[1:0] T127;
  wire[1:0] T128;
  wire[1:0] T129;
  wire[1:0] T130;
  wire[1:0] T131;
  wire T132;
  wire T133;
  wire T134;
  wire T135;
  wire T136;
  wire T137;
  wire T138;
  wire T139;
  wire T140;
  wire T141;
  wire T142;
  wire dec_stall;
  wire T143;
  wire T144;
  wire T145;
  wire dec_load;
  wire T146;
  wire[31:0] T147;
  reg  if_reg_valid;
  wire T351;
  wire next_valid;
  reg  R148;
  wire T352;
  wire mem_rd_write;
  reg  mem_reg_valid;
  wire T353;
  reg  mem_reg_rd_write;
  wire T149;
  reg  exe_reg_rd_write;
  wire T150;
  wire dec_rd_write;
  wire T151;
  wire dec_rd_en;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  wire T156;
  wire T157;
  wire[31:0] T158;
  wire T159;
  wire T160;
  wire T161;
  wire T162;
  wire T163;
  wire T164;
  wire T165;
  wire T166;
  wire[31:0] T167;
  wire T168;
  wire[4:0] T169;
  wire exe_instret;
  wire exe_cycle;
  wire exe_sret;
  reg  exe_reg_sret;
  wire T170;
  wire exe_ee;
  wire T171;
  reg  R172;
  wire T173;
  wire T174;
  wire T175;
  wire T176;
  wire T177;
  wire exe_ie;
  wire T178;
  reg  R179;
  wire T180;
  wire T181;
  wire T182;
  wire T183;
  wire exe_kill;
  wire[4:0] exe_exception_cause;
  wire[4:0] T184;
  wire[4:0] T185;
  wire[4:0] exe_any_cause;
  wire[4:0] T186;
  wire[4:0] T187;
  wire[4:0] T354;
  wire[3:0] exe_inst_cause;
  wire[3:0] T188;
  wire[3:0] T189;
  wire[4:0] T355;
  reg [2:0] exe_reg_cause;
  wire[2:0] T190;
  wire[2:0] dec_cause;
  wire[2:0] T191;
  wire[2:0] T356;
  reg  dec_reg_cause;
  wire exe_csr_write;
  reg  exe_reg_csr_write;
  wire T192;
  wire dec_csr;
  wire exe_store;
  reg  exe_reg_store;
  wire T193;
  wire dec_store;
  wire T194;
  wire[31:0] T195;
  wire T196;
  wire[31:0] T197;
  wire exe_load;
  reg  exe_reg_load;
  wire T198;
  wire[1:0] dec_rs2_sel;
  wire[1:0] T199;
  wire[1:0] T200;
  wire[1:0] T201;
  wire T202;
  wire T203;
  wire[4:0] T204;
  wire T205;
  reg  wb_reg_rd_write;
  wire T206;
  wire T207;
  wire T208;
  wire T209;
  wire T210;
  wire T211;
  wire T212;
  wire T213;
  wire T214;
  wire[1:0] dec_rs1_sel;
  wire[1:0] T215;
  wire[1:0] T216;
  wire[1:0] T217;
  wire T218;
  wire T219;
  wire[4:0] T220;
  wire T221;
  wire T222;
  wire T223;
  wire T224;
  wire[1:0] next_tid;
  reg [1:0] R225;
  wire[1:0] next_pc_sel_0;
  wire[1:0] T226;
  wire[1:0] T227;
  wire[1:0] T228;
  wire T229;
  wire T230;
  wire[3:0] T231;
  wire[1:0] T232;
  wire T233;
  wire T234;
  wire[3:0] T235;
  wire[1:0] T236;
  wire T237;
  wire T238;
  wire T239;
  wire[3:0] T240;
  wire[1:0] T241;
  reg  mem_reg_exception;
  wire[1:0] next_pc_sel_1;
  wire[1:0] T242;
  wire[1:0] T243;
  wire[1:0] T244;
  wire T245;
  wire T246;
  wire T247;
  wire T248;
  wire T249;
  wire T250;
  wire[1:0] next_pc_sel_2;
  wire[1:0] T251;
  wire[1:0] T252;
  wire[1:0] T253;
  wire T254;
  wire T255;
  wire T256;
  wire T257;
  wire T258;
  wire T259;
  wire[1:0] next_pc_sel_3;
  wire[1:0] T260;
  wire[1:0] T261;
  wire[1:0] T262;
  wire T263;
  wire T264;
  wire T265;
  wire T266;
  wire T267;
  wire T268;
  reg [1:0] mem_reg_rd_data_sel;
  reg [1:0] R269;
  wire[1:0] dec_mem_rd_data_sel;
  wire T270;
  wire[31:0] T271;
  reg [3:0] exe_reg_mem_type;
  wire[3:0] dec_mem_type;
  wire[2:0] T272;
  wire[1:0] T273;
  wire T274;
  wire[31:0] T275;
  wire T276;
  wire[31:0] T277;
  wire T278;
  wire[31:0] T279;
  wire T280;
  wire[31:0] T281;
  reg [1:0] exe_reg_rd_data_sel;
  wire[1:0] dec_exe_rd_data_sel;
  wire T282;
  wire[31:0] T283;
  wire T284;
  wire[31:0] T285;
  reg [1:0] exe_reg_mul_type;
  reg [1:0] exe_reg_csr_type;
  wire[1:0] dec_csr_type;
  reg [2:0] exe_reg_br_type;
  wire[2:0] dec_br_type;
  wire[1:0] T286;
  wire T287;
  wire[31:0] T288;
  reg [3:0] exe_reg_alu_type;
  wire[3:0] dec_alu_type;
  wire[2:0] T289;
  wire[1:0] T290;
  wire T291;
  wire[31:0] T292;
  wire T293;
  wire[31:0] T294;
  wire T295;
  wire[31:0] T296;
  wire T297;
  wire T298;
  wire[31:0] T299;
  wire T300;
  wire T301;
  wire[31:0] T302;
  wire T303;
  wire[31:0] T304;
  wire[1:0] dec_op2_sel;
  wire T305;
  wire T306;
  wire[31:0] T307;
  wire T308;
  wire T309;
  wire[31:0] T310;
  wire T311;
  wire[31:0] T312;
  wire T313;
  wire T314;
  wire[31:0] T315;
  wire T316;
  wire T317;
  wire[31:0] T318;
  wire[1:0] dec_op1_sel;
  wire T319;
  wire T320;
  wire[31:0] T321;
  wire T322;
  wire T323;
  wire[31:0] T324;
  wire T325;
  wire[31:0] T326;
  wire T327;
  wire T328;
  wire[31:0] T329;
  wire T330;
  wire[31:0] T331;
  wire[2:0] dec_imm_sel;
  wire[1:0] T332;
  wire T333;
  wire T334;
  wire[31:0] T335;
  wire T336;
  wire T337;
  wire[31:0] T338;
  wire T339;
  wire T340;
  wire[31:0] T341;
  wire T342;
  wire T343;
  wire[31:0] T344;
  wire[1:0] scheduler_io_thread;
  wire scheduler_io_valid;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    exe_reg_exc = {1{$random}};
    dec_reg_exc = {1{$random}};
    exe_reg_valid = {1{$random}};
    exe_reg_branch = {1{$random}};
    exe_reg_jump = {1{$random}};
    R81 = {1{$random}};
    dec_reg_valid = {1{$random}};
    stall_count_0 = {1{$random}};
    stall_count_1 = {1{$random}};
    stall_count_2 = {1{$random}};
    stall_count_3 = {1{$random}};
    if_reg_valid = {1{$random}};
    R148 = {1{$random}};
    mem_reg_valid = {1{$random}};
    mem_reg_rd_write = {1{$random}};
    exe_reg_rd_write = {1{$random}};
    exe_reg_sret = {1{$random}};
    R172 = {1{$random}};
    R179 = {1{$random}};
    exe_reg_cause = {1{$random}};
    dec_reg_cause = {1{$random}};
    exe_reg_csr_write = {1{$random}};
    exe_reg_store = {1{$random}};
    exe_reg_load = {1{$random}};
    wb_reg_rd_write = {1{$random}};
    R225 = {1{$random}};
    mem_reg_exception = {1{$random}};
    mem_reg_rd_data_sel = {1{$random}};
    R269 = {1{$random}};
    exe_reg_mem_type = {1{$random}};
    exe_reg_rd_data_sel = {1{$random}};
    exe_reg_mul_type = {1{$random}};
    exe_reg_csr_type = {1{$random}};
    exe_reg_br_type = {1{$random}};
    exe_reg_alu_type = {1{$random}};
  end
// synthesis translate_on
`endif

  assign exe_valid = exe_reg_valid & T0;
  assign T0 = exe_exception ^ 1'h1;
  assign exe_exception = T1;
  assign T1 = exe_reg_valid & T2;
  assign T2 = T4 | exe_any_exc;
  assign exe_any_exc = T3 | io_exe_int_ext;
  assign T3 = io_exe_exc_expire | io_exe_int_expire;
  assign T4 = exe_reg_exc | exe_inst_exc;
  assign exe_inst_exc = T5 | io_exe_exc_store_misaligned;
  assign T5 = io_exe_exc_priv_inst | io_exe_exc_load_misaligned;
  assign T6 = dec_reg_exc | dec_exc;
  assign dec_exc = T9 | T7;
  assign T7 = dec_scall;
  assign dec_scall = T8 == 32'h73;
  assign T8 = io_dec_inst & 32'h8010707f;
  assign T9 = T10 ^ 1'h1;
  assign T10 = dec_legal;
  assign dec_legal = T13 | T11;
  assign T11 = T12 == 32'h3;
  assign T12 = io_dec_inst & 32'h306f;
  assign T13 = T16 | T14;
  assign T14 = T15 == 32'h4063;
  assign T15 = io_dec_inst & 32'h407f;
  assign T16 = T19 | T17;
  assign T17 = T18 == 32'h1063;
  assign T18 = io_dec_inst & 32'h306f;
  assign T19 = T22 | T20;
  assign T20 = T21 == 32'h23;
  assign T21 = io_dec_inst & 32'h603f;
  assign T22 = T24 | dec_ie;
  assign dec_ie = T23 == 32'h705b;
  assign T23 = io_dec_inst & 32'h707f;
  assign T24 = T26 | dec_du;
  assign dec_du = T25 == 32'h700b;
  assign T25 = io_dec_inst & 32'h705f;
  assign T26 = T29 | T27;
  assign T27 = T28 == 32'h5033;
  assign T28 = io_dec_inst & 32'hbe00707f;
  assign T29 = T32 | T30;
  assign T30 = T31 == 32'h5013;
  assign T31 = io_dec_inst & 32'hbc00707f;
  assign T32 = T35 | T33;
  assign T33 = T34 == 32'h2073;
  assign T34 = io_dec_inst & 32'h207f;
  assign T35 = T38 | T36;
  assign T36 = T37 == 32'h2013;
  assign T37 = io_dec_inst & 32'h207f;
  assign T38 = T41 | T39;
  assign T39 = T40 == 32'h1013;
  assign T40 = io_dec_inst & 32'hfc00307f;
  assign T41 = T42 | dec_scall;
  assign T42 = T45 | T43;
  assign T43 = T44 == 32'h6f;
  assign T44 = io_dec_inst & 32'h7f;
  assign T45 = T48 | T46;
  assign T46 = T47 == 32'h63;
  assign T47 = io_dec_inst & 32'h707b;
  assign T48 = T51 | T49;
  assign T49 = T50 == 32'h33;
  assign T50 = io_dec_inst & 32'hbe00707f;
  assign T51 = T54 | T52;
  assign T52 = T53 == 32'h33;
  assign T53 = io_dec_inst & 32'hfe00007f;
  assign T54 = T57 | T55;
  assign T55 = T56 == 32'h17;
  assign T56 = io_dec_inst & 32'h5f;
  assign T57 = T60 | T58;
  assign T58 = T59 == 32'hf;
  assign T59 = io_dec_inst & 32'h607f;
  assign T60 = T63 | T61;
  assign T61 = T62 == 32'h3;
  assign T62 = io_dec_inst & 32'h207f;
  assign T63 = T64 == 32'h3;
  assign T64 = io_dec_inst & 32'h505f;
  assign T345 = reset ? 1'h0 : dec_valid;
  assign dec_valid = dec_reg_valid & T65;
  assign T65 = T66 ^ 1'h1;
  assign T66 = exe_flush & T67;
  assign T67 = io_dec_tid == io_exe_tid;
  assign exe_flush = T68;
  assign T68 = exe_sleep ? 1'h1 : T69;
  assign T69 = exe_brjmp ? 1'h1 : exe_exception;
  assign exe_brjmp = exe_reg_valid & T70;
  assign T70 = exe_reg_jump | T71;
  assign T71 = exe_reg_branch & io_exe_br_cond;
  assign T72 = dec_branch;
  assign dec_branch = T73 | T14;
  assign T73 = T74 == 32'h63;
  assign T74 = io_dec_inst & 32'h207f;
  assign T75 = dec_jump;
  assign dec_jump = T76 | T43;
  assign T76 = T77 == 32'h67;
  assign T77 = io_dec_inst & 32'h707f;
  assign exe_sleep = exe_du & exe_valid;
  assign exe_du = T78;
  assign T78 = T80 & T79;
  assign T79 = io_exe_expire ^ 1'h1;
  assign T80 = exe_reg_valid & R81;
  assign T82 = dec_du;
  assign T346 = reset ? 1'h0 : if_valid;
  assign if_valid = if_pre_valid & T83;
  assign T83 = T84 ^ 1'h1;
  assign T84 = exe_flush & T85;
  assign T85 = io_if_tid == io_exe_tid;
  assign if_pre_valid = T139 & T86;
  assign T86 = T87 == 2'h0;
  assign T87 = T138 ? T116 : T88;
  assign T88 = T114 ? stall_count_1 : stall_count_0;
  assign T347 = reset ? 2'h0 : T89;
  assign T89 = T103 ? 2'h1 : T90;
  assign T90 = T99 ? 2'h1 : T91;
  assign T91 = T95 ? 2'h2 : T92;
  assign T92 = T94 ? T93 : 2'h0;
  assign T93 = stall_count_0 - 2'h1;
  assign T94 = stall_count_0 != 2'h0;
  assign T95 = exe_sleep & T96;
  assign T96 = T97[1'h0:1'h0];
  assign T97 = 1'h1 << T98;
  assign T98 = io_exe_tid;
  assign T99 = T100 & T96;
  assign T100 = dec_reg_valid & T101;
  assign T101 = dec_fence_i;
  assign dec_fence_i = T102 == 32'h100f;
  assign T102 = io_dec_inst & 32'h707f;
  assign T103 = T1 & T96;
  assign T348 = reset ? 2'h0 : T104;
  assign T104 = T113 ? 2'h1 : T105;
  assign T105 = T112 ? 2'h1 : T106;
  assign T106 = T110 ? 2'h2 : T107;
  assign T107 = T109 ? T108 : 2'h0;
  assign T108 = stall_count_1 - 2'h1;
  assign T109 = stall_count_1 != 2'h0;
  assign T110 = exe_sleep & T111;
  assign T111 = T97[1'h1:1'h1];
  assign T112 = T100 & T111;
  assign T113 = T1 & T111;
  assign T114 = T115[1'h0:1'h0];
  assign T115 = io_if_tid;
  assign T116 = T137 ? stall_count_3 : stall_count_2;
  assign T349 = reset ? 2'h0 : T117;
  assign T117 = T126 ? 2'h1 : T118;
  assign T118 = T125 ? 2'h1 : T119;
  assign T119 = T123 ? 2'h2 : T120;
  assign T120 = T122 ? T121 : 2'h0;
  assign T121 = stall_count_2 - 2'h1;
  assign T122 = stall_count_2 != 2'h0;
  assign T123 = exe_sleep & T124;
  assign T124 = T97[2'h2:2'h2];
  assign T125 = T100 & T124;
  assign T126 = T1 & T124;
  assign T350 = reset ? 2'h0 : T127;
  assign T127 = T136 ? 2'h1 : T128;
  assign T128 = T135 ? 2'h1 : T129;
  assign T129 = T133 ? 2'h2 : T130;
  assign T130 = T132 ? T131 : 2'h0;
  assign T131 = stall_count_3 - 2'h1;
  assign T132 = stall_count_3 != 2'h0;
  assign T133 = exe_sleep & T134;
  assign T134 = T97[2'h3:2'h3];
  assign T135 = T100 & T134;
  assign T136 = T1 & T134;
  assign T137 = T115[1'h0:1'h0];
  assign T138 = T115[1'h1:1'h1];
  assign T139 = if_reg_valid & T140;
  assign T140 = T141 ^ 1'h1;
  assign T141 = dec_stall & T142;
  assign T142 = io_if_tid == io_dec_tid;
  assign dec_stall = T143;
  assign T143 = T100 ? 1'h1 : T144;
  assign T144 = dec_reg_valid & T145;
  assign T145 = dec_load;
  assign dec_load = T146 | T61;
  assign T146 = T147 == 32'h3;
  assign T147 = io_dec_inst & 32'h507f;
  assign T351 = reset ? 1'h0 : next_valid;
  assign next_valid = R148;
  assign T352 = reset ? 1'h0 : scheduler_io_valid;
  assign io_mem_rd_write = mem_rd_write;
  assign mem_rd_write = mem_reg_rd_write & mem_reg_valid;
  assign T353 = reset ? 1'h0 : exe_valid;
  assign T149 = exe_reg_rd_write & exe_reg_valid;
  assign T150 = dec_rd_write & dec_reg_valid;
  assign dec_rd_write = T168 & T151;
  assign T151 = dec_rd_en;
  assign dec_rd_en = T152 | T11;
  assign T152 = T153 | T27;
  assign T153 = T154 | T30;
  assign T154 = T155 | T33;
  assign T155 = T156 | T36;
  assign T156 = T159 | T157;
  assign T157 = T158 == 32'h1073;
  assign T158 = io_dec_inst & 32'h107f;
  assign T159 = T160 | T39;
  assign T160 = T161 | T43;
  assign T161 = T162 | T76;
  assign T162 = T163 | T49;
  assign T163 = T164 | T52;
  assign T164 = T165 | T55;
  assign T165 = T166 | T61;
  assign T166 = T167 == 32'h3;
  assign T167 = io_dec_inst & 32'h506f;
  assign T168 = T169 != 5'h0;
  assign T169 = io_dec_inst[4'hb:3'h7];
  assign io_exe_instret = exe_instret;
  assign exe_instret = 1'h0;
  assign io_exe_cycle = exe_cycle;
  assign exe_cycle = 1'h0;
  assign io_exe_sret = exe_sret;
  assign exe_sret = exe_reg_sret & exe_reg_valid;
  assign T170 = 1'h0;
  assign io_exe_ee = exe_ee;
  assign exe_ee = T171;
  assign T171 = exe_valid & R172;
  assign T173 = T177 & T174;
  assign T174 = T175 ^ 1'h1;
  assign T175 = T176;
  assign T176 = io_dec_inst[5'h19:5'h19];
  assign T177 = dec_ie;
  assign io_exe_ie = exe_ie;
  assign exe_ie = T178;
  assign T178 = exe_valid & R179;
  assign T180 = T183 & T181;
  assign T181 = T182;
  assign T182 = io_dec_inst[5'h19:5'h19];
  assign T183 = dec_ie;
  assign io_exe_sleep = exe_sleep;
  assign io_exe_kill = exe_kill;
  assign exe_kill = exe_reg_exc | exe_any_exc;
  assign io_exe_cause = exe_exception_cause;
  assign exe_exception_cause = T184;
  assign T184 = exe_reg_exc ? T355 : T185;
  assign T185 = exe_inst_exc ? T354 : exe_any_cause;
  assign exe_any_cause = io_exe_exc_expire ? 5'hd : T186;
  assign T186 = io_exe_int_expire ? 5'h1d : T187;
  assign T187 = io_exe_int_ext ? 5'h1e : 5'h0;
  assign T354 = {1'h0, exe_inst_cause};
  assign exe_inst_cause = io_exe_exc_priv_inst ? 4'h3 : T188;
  assign T188 = io_exe_exc_load_misaligned ? 4'h8 : T189;
  assign T189 = io_exe_exc_store_misaligned ? 4'h9 : 4'h0;
  assign T355 = {2'h0, exe_reg_cause};
  assign T190 = dec_reg_exc ? T356 : dec_cause;
  assign dec_cause = T9 ? 3'h2 : T191;
  assign T191 = T7 ? 3'h6 : 3'h0;
  assign T356 = {2'h0, dec_reg_cause};
  assign io_exe_exception = exe_exception;
  assign io_exe_csr_write = exe_csr_write;
  assign exe_csr_write = exe_reg_csr_write & exe_reg_valid;
  assign T192 = dec_csr;
  assign dec_csr = T157 | T33;
  assign io_exe_store = exe_store;
  assign exe_store = exe_reg_store & exe_reg_valid;
  assign T193 = dec_store;
  assign dec_store = T196 | T194;
  assign T194 = T195 == 32'h23;
  assign T195 = io_dec_inst & 32'h507f;
  assign T196 = T197 == 32'h23;
  assign T197 = io_dec_inst & 32'h607f;
  assign io_exe_load = exe_load;
  assign exe_load = exe_reg_load & exe_reg_valid;
  assign T198 = dec_load;
  assign io_exe_valid = exe_reg_valid;
  assign io_dec_rs2_sel = dec_rs2_sel;
  assign dec_rs2_sel = T199;
  assign T199 = T211 ? 2'h1 : T200;
  assign T200 = T207 ? 2'h2 : T201;
  assign T201 = T202 ? 2'h3 : 2'h0;
  assign T202 = T205 & T203;
  assign T203 = T204 == io_wb_rd_addr;
  assign T204 = io_dec_inst[5'h18:5'h14];
  assign T205 = T206 & wb_reg_rd_write;
  assign T206 = io_dec_tid == io_wb_tid;
  assign T207 = T209 & T208;
  assign T208 = T204 == io_mem_rd_addr;
  assign T209 = T210 & mem_reg_rd_write;
  assign T210 = io_dec_tid == io_mem_tid;
  assign T211 = T213 & T212;
  assign T212 = T204 == io_exe_rd_addr;
  assign T213 = T214 & exe_reg_rd_write;
  assign T214 = io_dec_tid == io_exe_tid;
  assign io_dec_rs1_sel = dec_rs1_sel;
  assign dec_rs1_sel = T215;
  assign T215 = T223 ? 2'h1 : T216;
  assign T216 = T221 ? 2'h2 : T217;
  assign T217 = T218 ? 2'h3 : 2'h0;
  assign T218 = T205 & T219;
  assign T219 = T220 == io_wb_rd_addr;
  assign T220 = io_dec_inst[5'h13:4'hf];
  assign T221 = T209 & T222;
  assign T222 = T220 == io_mem_rd_addr;
  assign T223 = T213 & T224;
  assign T224 = T220 == io_exe_rd_addr;
  assign io_next_valid = next_valid;
  assign io_next_tid = next_tid;
  assign next_tid = R225;
  assign io_next_pc_sel_0 = next_pc_sel_0;
  assign next_pc_sel_0 = T226;
  assign T226 = T238 ? 2'h3 : T227;
  assign T227 = T233 ? 2'h2 : T228;
  assign T228 = T229 ? 2'h1 : 2'h0;
  assign T229 = if_pre_valid & T230;
  assign T230 = T231[1'h0:1'h0];
  assign T231 = 1'h1 << T232;
  assign T232 = io_if_tid;
  assign T233 = T237 & T234;
  assign T234 = T235[1'h0:1'h0];
  assign T235 = 1'h1 << T236;
  assign T236 = io_exe_tid;
  assign T237 = exe_brjmp | exe_du;
  assign T238 = mem_reg_exception & T239;
  assign T239 = T240[1'h0:1'h0];
  assign T240 = 1'h1 << T241;
  assign T241 = io_mem_tid;
  assign io_next_pc_sel_1 = next_pc_sel_1;
  assign next_pc_sel_1 = T242;
  assign T242 = T249 ? 2'h3 : T243;
  assign T243 = T247 ? 2'h2 : T244;
  assign T244 = T245 ? 2'h1 : 2'h0;
  assign T245 = if_pre_valid & T246;
  assign T246 = T231[1'h1:1'h1];
  assign T247 = T237 & T248;
  assign T248 = T235[1'h1:1'h1];
  assign T249 = mem_reg_exception & T250;
  assign T250 = T240[1'h1:1'h1];
  assign io_next_pc_sel_2 = next_pc_sel_2;
  assign next_pc_sel_2 = T251;
  assign T251 = T258 ? 2'h3 : T252;
  assign T252 = T256 ? 2'h2 : T253;
  assign T253 = T254 ? 2'h1 : 2'h0;
  assign T254 = if_pre_valid & T255;
  assign T255 = T231[2'h2:2'h2];
  assign T256 = T237 & T257;
  assign T257 = T235[2'h2:2'h2];
  assign T258 = mem_reg_exception & T259;
  assign T259 = T240[2'h2:2'h2];
  assign io_next_pc_sel_3 = next_pc_sel_3;
  assign next_pc_sel_3 = T260;
  assign T260 = T267 ? 2'h3 : T261;
  assign T261 = T265 ? 2'h2 : T262;
  assign T262 = T263 ? 2'h1 : 2'h0;
  assign T263 = if_pre_valid & T264;
  assign T264 = T231[2'h3:2'h3];
  assign T265 = T237 & T266;
  assign T266 = T235[2'h3:2'h3];
  assign T267 = mem_reg_exception & T268;
  assign T268 = T240[2'h3:2'h3];
  assign io_mem_rd_data_sel = mem_reg_rd_data_sel;
  assign dec_mem_rd_data_sel = {1'h0, T270};
  assign T270 = T271 == 32'h0;
  assign T271 = io_dec_inst & 32'h50;
  assign io_exe_mem_type = exe_reg_mem_type;
  assign dec_mem_type = {T280, T272};
  assign T272 = {T278, T273};
  assign T273 = {T276, T274};
  assign T274 = T275 == 32'h1000;
  assign T275 = io_dec_inst & 32'h1000;
  assign T276 = T277 == 32'h2000;
  assign T277 = io_dec_inst & 32'h2000;
  assign T278 = T279 == 32'h4000;
  assign T279 = io_dec_inst & 32'h4000;
  assign T280 = T281 == 32'h20;
  assign T281 = io_dec_inst & 32'h20;
  assign io_exe_rd_data_sel = exe_reg_rd_data_sel;
  assign dec_exe_rd_data_sel = {T284, T282};
  assign T282 = T283 == 32'h40;
  assign T283 = io_dec_inst & 32'h44;
  assign T284 = T285 == 32'h0;
  assign T285 = io_dec_inst & 32'h10;
  assign io_exe_mul_type = exe_reg_mul_type;
  assign io_exe_csr_type = exe_reg_csr_type;
  assign dec_csr_type = {T276, T274};
  assign io_exe_br_type = exe_reg_br_type;
  assign dec_br_type = {T276, T286};
  assign T286 = {T287, T274};
  assign T287 = T288 == 32'h4000;
  assign T288 = io_dec_inst & 32'h6000;
  assign io_exe_alu_type = exe_reg_alu_type;
  assign dec_alu_type = {T297, T289};
  assign T289 = {T295, T290};
  assign T290 = {T293, T291};
  assign T291 = T292 == 32'h1010;
  assign T292 = io_dec_inst & 32'h1054;
  assign T293 = T294 == 32'h2010;
  assign T294 = io_dec_inst & 32'h2054;
  assign T295 = T296 == 32'h4010;
  assign T296 = io_dec_inst & 32'h4054;
  assign T297 = T300 | T298;
  assign T298 = T299 == 32'h40001010;
  assign T299 = io_dec_inst & 32'h40003054;
  assign T300 = T303 | T301;
  assign T301 = T302 == 32'h40000030;
  assign T302 = io_dec_inst & 32'h40003034;
  assign T303 = T304 == 32'h2010;
  assign T304 = io_dec_inst & 32'h6054;
  assign io_dec_op2_sel = dec_op2_sel;
  assign dec_op2_sel = {T313, T305};
  assign T305 = T308 | T306;
  assign T306 = T307 == 32'h4020;
  assign T307 = io_dec_inst & 32'h4064;
  assign T308 = T311 | T309;
  assign T309 = T310 == 32'h40;
  assign T310 = io_dec_inst & 32'h60;
  assign T311 = T312 == 32'h30;
  assign T312 = io_dec_inst & 32'h74;
  assign T313 = T316 | T314;
  assign T314 = T315 == 32'h6000;
  assign T315 = io_dec_inst & 32'h6050;
  assign T316 = T309 | T317;
  assign T317 = T318 == 32'h50;
  assign T318 = io_dec_inst & 32'h4050;
  assign io_dec_op1_sel = dec_op1_sel;
  assign dec_op1_sel = {T327, T319};
  assign T319 = T322 | T320;
  assign T320 = T321 == 32'h10;
  assign T321 = io_dec_inst & 32'h4014;
  assign T322 = T325 | T323;
  assign T323 = T324 == 32'h4;
  assign T324 = io_dec_inst & 32'h1c;
  assign T325 = T326 == 32'h0;
  assign T326 = io_dec_inst & 32'h4c;
  assign T327 = T330 | T328;
  assign T328 = T329 == 32'h4050;
  assign T329 = io_dec_inst & 32'h4058;
  assign T330 = T331 == 32'h24;
  assign T331 = io_dec_inst & 32'h64;
  assign io_dec_imm_sel = dec_imm_sel;
  assign dec_imm_sel = {T339, T332};
  assign T332 = {T336, T333};
  assign T333 = T334 | T282;
  assign T334 = T335 == 32'h8;
  assign T335 = io_dec_inst & 32'h8;
  assign T336 = T337 | T334;
  assign T337 = T338 == 32'h4;
  assign T338 = io_dec_inst & 32'h44;
  assign T339 = T342 | T340;
  assign T340 = T341 == 32'h10;
  assign T341 = io_dec_inst & 32'h14;
  assign T342 = T343 | T323;
  assign T343 = T344 == 32'h0;
  assign T344 = io_dec_inst & 32'h24;
  Scheduler scheduler(.clk(clk), .reset(reset),
       .io_slots_7( io_csr_slots_7 ),
       .io_slots_6( io_csr_slots_6 ),
       .io_slots_5( io_csr_slots_5 ),
       .io_slots_4( io_csr_slots_4 ),
       .io_slots_3( io_csr_slots_3 ),
       .io_slots_2( io_csr_slots_2 ),
       .io_slots_1( io_csr_slots_1 ),
       .io_slots_0( io_csr_slots_0 ),
       .io_thread_modes_3( io_csr_tmodes_3 ),
       .io_thread_modes_2( io_csr_tmodes_2 ),
       .io_thread_modes_1( io_csr_tmodes_1 ),
       .io_thread_modes_0( io_csr_tmodes_0 ),
       .io_thread( scheduler_io_thread ),
       .io_valid( scheduler_io_valid )
  );

  always @(posedge clk) begin
    exe_reg_exc <= T6;
    dec_reg_exc <= io_if_exc_misaligned;
    if(reset) begin
      exe_reg_valid <= 1'h0;
    end else begin
      exe_reg_valid <= dec_valid;
    end
    exe_reg_branch <= T72;
    exe_reg_jump <= T75;
    R81 <= T82;
    if(reset) begin
      dec_reg_valid <= 1'h0;
    end else begin
      dec_reg_valid <= if_valid;
    end
    if(reset) begin
      stall_count_0 <= 2'h0;
    end else if(T103) begin
      stall_count_0 <= 2'h1;
    end else if(T99) begin
      stall_count_0 <= 2'h1;
    end else if(T95) begin
      stall_count_0 <= 2'h2;
    end else if(T94) begin
      stall_count_0 <= T93;
    end else begin
      stall_count_0 <= 2'h0;
    end
    if(reset) begin
      stall_count_1 <= 2'h0;
    end else if(T113) begin
      stall_count_1 <= 2'h1;
    end else if(T112) begin
      stall_count_1 <= 2'h1;
    end else if(T110) begin
      stall_count_1 <= 2'h2;
    end else if(T109) begin
      stall_count_1 <= T108;
    end else begin
      stall_count_1 <= 2'h0;
    end
    if(reset) begin
      stall_count_2 <= 2'h0;
    end else if(T126) begin
      stall_count_2 <= 2'h1;
    end else if(T125) begin
      stall_count_2 <= 2'h1;
    end else if(T123) begin
      stall_count_2 <= 2'h2;
    end else if(T122) begin
      stall_count_2 <= T121;
    end else begin
      stall_count_2 <= 2'h0;
    end
    if(reset) begin
      stall_count_3 <= 2'h0;
    end else if(T136) begin
      stall_count_3 <= 2'h1;
    end else if(T135) begin
      stall_count_3 <= 2'h1;
    end else if(T133) begin
      stall_count_3 <= 2'h2;
    end else if(T132) begin
      stall_count_3 <= T131;
    end else begin
      stall_count_3 <= 2'h0;
    end
    if(reset) begin
      if_reg_valid <= 1'h0;
    end else begin
      if_reg_valid <= next_valid;
    end
    if(reset) begin
      R148 <= 1'h0;
    end else begin
      R148 <= scheduler_io_valid;
    end
    if(reset) begin
      mem_reg_valid <= 1'h0;
    end else begin
      mem_reg_valid <= exe_valid;
    end
    mem_reg_rd_write <= T149;
    exe_reg_rd_write <= T150;
    exe_reg_sret <= T170;
    R172 <= T173;
    R179 <= T180;
    if(dec_reg_exc) begin
      exe_reg_cause <= T356;
    end else if(T9) begin
      exe_reg_cause <= 3'h2;
    end else if(T7) begin
      exe_reg_cause <= 3'h6;
    end else begin
      exe_reg_cause <= 3'h0;
    end
    dec_reg_cause <= 1'h0;
    exe_reg_csr_write <= T192;
    exe_reg_store <= T193;
    exe_reg_load <= T198;
    wb_reg_rd_write <= mem_rd_write;
    R225 <= scheduler_io_thread;
    mem_reg_exception <= exe_exception;
    mem_reg_rd_data_sel <= R269;
    R269 <= dec_mem_rd_data_sel;
    exe_reg_mem_type <= dec_mem_type;
    exe_reg_rd_data_sel <= dec_exe_rd_data_sel;
    exe_reg_mul_type <= 2'h0;
    exe_reg_csr_type <= dec_csr_type;
    exe_reg_br_type <= dec_br_type;
    exe_reg_alu_type <= dec_alu_type;
  end
endmodule

module RegisterFile(input clk,
    input [1:0] io_rs1_thread,
    input [4:0] io_rs1_addr,
    output[31:0] io_rs1_data,
    input [1:0] io_rs2_thread,
    input [4:0] io_rs2_addr,
    output[31:0] io_rs2_data,
    input [1:0] io_rd_thread,
    input [4:0] io_rd_addr,
    input [31:0] io_rd_data,
    input  io_rd_enable
);

  reg [31:0] dout2;
  wire[31:0] T0;
  wire[31:0] T1;
  reg [31:0] regfile [127:0];
  wire[31:0] T2;
  wire[6:0] T3;
  wire[6:0] T4;
  wire T5;
  reg [31:0] dout1;
  wire[31:0] T6;
  wire[31:0] T7;
  wire[6:0] T8;
  wire T9;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    dout2 = {1{$random}};
    for (initvar = 0; initvar < 128; initvar = initvar+1)
      regfile[initvar] = {1{$random}};
    dout1 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_rs2_data = dout2;
  assign T0 = T5 ? 32'h0 : T1;
  assign T1 = regfile[T4];
  assign T3 = {io_rd_addr, io_rd_thread};
  assign T4 = {io_rs2_addr, io_rs2_thread};
  assign T5 = io_rs2_addr == 5'h0;
  assign io_rs1_data = dout1;
  assign T6 = T9 ? 32'h0 : T7;
  assign T7 = regfile[T8];
  assign T8 = {io_rs1_addr, io_rs1_thread};
  assign T9 = io_rs1_addr == 5'h0;

  always @(posedge clk) begin
    if(T5) begin
      dout2 <= 32'h0;
    end else begin
      dout2 <= T1;
    end
    if (io_rd_enable)
      regfile[T3] <= io_rd_data;
    if(T9) begin
      dout1 <= 32'h0;
    end else begin
      dout1 <= T7;
    end
  end
endmodule

module LoadStore(input clk,
    output[11:0] io_dmem_addr,
    output io_dmem_enable,
    input [31:0] io_dmem_data_out,
    output io_dmem_byte_write_3,
    output io_dmem_byte_write_2,
    output io_dmem_byte_write_1,
    output io_dmem_byte_write_0,
    output[31:0] io_dmem_data_in,
    //output[11:0] io_imem_r_addr
    //output io_imem_r_enable
    //input [31:0] io_imem_r_data_out
    output[11:0] io_imem_rw_addr,
    output io_imem_rw_enable,
    input [31:0] io_imem_rw_data_out,
    output io_imem_rw_write,
    output[31:0] io_imem_rw_data_in,
    output[9:0] io_bus_addr,
    output io_bus_enable,
    input [31:0] io_bus_data_out,
    output io_bus_write,
    output[31:0] io_bus_data_in,
    input [31:0] io_addr,
    input [1:0] io_thread,
    input  io_load,
    input  io_store,
    input [3:0] io_mem_type,
    input [31:0] io_data_in,
    output[31:0] io_data_out,
    input [3:0] io_imem_protection_7,
    input [3:0] io_imem_protection_6,
    input [3:0] io_imem_protection_5,
    input [3:0] io_imem_protection_4,
    input [3:0] io_imem_protection_3,
    input [3:0] io_imem_protection_2,
    input [3:0] io_imem_protection_1,
    input [3:0] io_imem_protection_0,
    input [3:0] io_dmem_protection_7,
    input [3:0] io_dmem_protection_6,
    input [3:0] io_dmem_protection_5,
    input [3:0] io_dmem_protection_4,
    input [3:0] io_dmem_protection_3,
    input [3:0] io_dmem_protection_2,
    input [3:0] io_dmem_protection_1,
    input [3:0] io_dmem_protection_0,
    input  io_kill,
    output io_load_misaligned,
    output io_load_fault,
    output io_store_misaligned,
    output io_store_fault
);

  wire store_fault;
  wire store_misaligned;
  wire T0;
  wire T1;
  wire T2;
  wire T3;
  wire[1:0] T4;
  wire T5;
  wire T6;
  wire T7;
  wire T8;
  wire T9;
  wire load_fault;
  wire load_misaligned;
  wire T10;
  wire T11;
  wire T12;
  wire T13;
  wire[1:0] T14;
  wire T15;
  wire T16;
  wire T17;
  wire T18;
  wire T19;
  wire T20;
  wire T21;
  wire[31:0] T22;
  wire[31:0] T23;
  reg  imem_op_reg;
  wire imem_op;
  wire[2:0] T24;
  wire[31:0] T25;
  wire[31:0] T26;
  wire[31:0] T27;
  wire[31:0] T28;
  wire[31:0] T29;
  wire[4:0] T30;
  reg [1:0] addr_byte_reg;
  wire[1:0] T31;
  wire[31:0] T32;
  wire[15:0] T33;
  wire T34;
  reg [3:0] mem_type_reg;
  wire[31:0] T35;
  wire[15:0] T36;
  wire[15:0] T37;
  wire[15:0] T140;
  wire T38;
  wire T39;
  wire[31:0] T40;
  wire[7:0] T41;
  wire T42;
  wire[31:0] T43;
  wire[7:0] T44;
  wire[23:0] T45;
  wire[23:0] T141;
  wire T46;
  wire T47;
  reg  dmem_op_reg;
  wire dmem_op;
  wire[2:0] T48;
  wire T49;
  wire write;
  wire T50;
  wire T51;
  wire T52;
  wire T53;
  wire T54;
  wire T55;
  wire permission;
  wire T56;
  wire T57;
  wire T58;
  wire T59;
  wire T60;
  wire[3:0] T61;
  wire[3:0] T62;
  wire[3:0] T63;
  wire T64;
  wire[2:0] T65;
  wire[2:0] T66;
  wire[3:0] T67;
  wire T68;
  wire T69;
  wire[3:0] T70;
  wire[3:0] T71;
  wire T72;
  wire[3:0] T73;
  wire T74;
  wire T75;
  wire T76;
  wire T77;
  wire T78;
  wire[1:0] T79;
  wire T80;
  wire T81;
  wire T82;
  wire T83;
  wire[3:0] T84;
  wire[3:0] T85;
  wire[3:0] T86;
  wire T87;
  wire[2:0] T88;
  wire[2:0] T89;
  wire[3:0] T90;
  wire T91;
  wire T92;
  wire[3:0] T93;
  wire[3:0] T94;
  wire T95;
  wire[3:0] T96;
  wire T97;
  wire T98;
  wire T99;
  wire T100;
  wire T101;
  wire[1:0] T102;
  wire T103;
  wire bus_op;
  wire[1:0] T104;
  wire T105;
  wire T106;
  wire[9:0] T107;
  wire[7:0] T108;
  wire T109;
  wire T110;
  wire T111;
  wire[11:0] T142;
  wire[9:0] T112;
  wire[31:0] T113;
  wire[31:0] T114;
  wire[31:0] T115;
  wire[15:0] T116;
  wire T117;
  wire[31:0] T118;
  wire[15:0] T119;
  wire[7:0] T120;
  wire T121;
  wire T122;
  wire[4:0] T123;
  wire[4:0] T143;
  wire[3:0] T124;
  wire[4:0] T125;
  wire[4:0] T126;
  wire[4:0] T144;
  wire[3:0] T127;
  wire T128;
  wire[4:0] T129;
  wire[1:0] T130;
  wire T131;
  wire[4:0] T145;
  wire[3:0] T132;
  wire T133;
  wire T134;
  wire T135;
  wire T136;
  wire T137;
  wire T138;
  wire[11:0] T139;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    imem_op_reg = {1{$random}};
    addr_byte_reg = {1{$random}};
    mem_type_reg = {1{$random}};
    dmem_op_reg = {1{$random}};
  end
// synthesis translate_on
`endif

`ifndef SYNTHESIS
// synthesis translate_off
//  assign io_imem_r_enable = {1{$random}};
//  assign io_imem_r_addr = {1{$random}};
// synthesis translate_on
`endif
  assign io_store_fault = store_fault;
  assign store_fault = 1'h0;
  assign io_store_misaligned = store_misaligned;
  assign store_misaligned = T0;
  assign T0 = io_store & T1;
  assign T1 = T6 | T2;
  assign T2 = T5 & T3;
  assign T3 = T4 != 2'h0;
  assign T4 = io_addr[1'h1:1'h0];
  assign T5 = io_mem_type == 4'ha;
  assign T6 = T9 & T7;
  assign T7 = T8 != 1'h0;
  assign T8 = io_addr[1'h0:1'h0];
  assign T9 = io_mem_type == 4'h9;
  assign io_load_fault = load_fault;
  assign load_fault = 1'h0;
  assign io_load_misaligned = load_misaligned;
  assign load_misaligned = T10;
  assign T10 = io_load & T11;
  assign T11 = T16 | T12;
  assign T12 = T15 & T13;
  assign T13 = T14 != 2'h0;
  assign T14 = io_addr[1'h1:1'h0];
  assign T15 = io_mem_type == 4'h2;
  assign T16 = T19 & T17;
  assign T17 = T18 != 1'h0;
  assign T18 = io_addr[1'h0:1'h0];
  assign T19 = T21 | T20;
  assign T20 = io_mem_type == 4'h5;
  assign T21 = io_mem_type == 4'h1;
  assign io_data_out = T22;
  assign T22 = dmem_op_reg ? T25 : T23;
  assign T23 = imem_op_reg ? io_imem_rw_data_out : io_bus_data_out;
  assign imem_op = T24 == 3'h0;
  assign T24 = io_addr[5'h1f:5'h1d];
  assign T25 = T47 ? T43 : T26;
  assign T26 = T42 ? T40 : T27;
  assign T27 = T39 ? T35 : T28;
  assign T28 = T34 ? T32 : T29;
  assign T29 = io_dmem_data_out >> T30;
  assign T30 = {addr_byte_reg, 3'h0};
  assign T31 = io_addr[1'h1:1'h0];
  assign T32 = {16'h0, T33};
  assign T33 = T29[4'hf:1'h0];
  assign T34 = mem_type_reg == 4'h5;
  assign T35 = {T37, T36};
  assign T36 = T29[4'hf:1'h0];
  assign T37 = 16'h0 - T140;
  assign T140 = {15'h0, T38};
  assign T38 = T29[4'hf:4'hf];
  assign T39 = mem_type_reg == 4'h1;
  assign T40 = {24'h0, T41};
  assign T41 = T29[3'h7:1'h0];
  assign T42 = mem_type_reg == 4'h4;
  assign T43 = {T45, T44};
  assign T44 = T29[3'h7:1'h0];
  assign T45 = 24'h0 - T141;
  assign T141 = {23'h0, T46};
  assign T46 = T29[3'h7:3'h7];
  assign T47 = mem_type_reg == 4'h0;
  assign dmem_op = T48 == 3'h1;
  assign T48 = io_addr[5'h1f:5'h1d];
  assign io_bus_data_in = io_data_in;
  assign io_bus_write = T49;
  assign T49 = bus_op & write;
  assign write = T51 & T50;
  assign T50 = io_kill ^ 1'h1;
  assign T51 = T53 & T52;
  assign T52 = store_fault ^ 1'h1;
  assign T53 = T55 & T54;
  assign T54 = store_misaligned ^ 1'h1;
  assign T55 = io_store & permission;
  assign permission = T56;
  assign T56 = T57 | bus_op;
  assign T57 = T81 | T58;
  assign T58 = imem_op & T59;
  assign T59 = T77 & T60;
  assign T60 = T61 != 4'hc;
  assign T61 = T76 ? T70 : T62;
  assign T62 = T69 ? T67 : T63;
  assign T63 = T64 ? io_imem_protection_1 : io_imem_protection_0;
  assign T64 = T65[1'h0:1'h0];
  assign T65 = T66;
  assign T66 = io_addr[4'hd:4'hb];
  assign T67 = T68 ? io_imem_protection_3 : io_imem_protection_2;
  assign T68 = T65[1'h0:1'h0];
  assign T69 = T65[1'h1:1'h1];
  assign T70 = T75 ? T73 : T71;
  assign T71 = T72 ? io_imem_protection_5 : io_imem_protection_4;
  assign T72 = T65[1'h0:1'h0];
  assign T73 = T74 ? io_imem_protection_7 : io_imem_protection_6;
  assign T74 = T65[1'h0:1'h0];
  assign T75 = T65[1'h1:1'h1];
  assign T76 = T65[2'h2:2'h2];
  assign T77 = T80 | T78;
  assign T78 = T79 == io_thread;
  assign T79 = T61[1'h1:1'h0];
  assign T80 = T61 == 4'h8;
  assign T81 = dmem_op & T82;
  assign T82 = T100 & T83;
  assign T83 = T84 != 4'hc;
  assign T84 = T99 ? T93 : T85;
  assign T85 = T92 ? T90 : T86;
  assign T86 = T87 ? io_dmem_protection_1 : io_dmem_protection_0;
  assign T87 = T88[1'h0:1'h0];
  assign T88 = T89;
  assign T89 = io_addr[4'hd:4'hb];
  assign T90 = T91 ? io_dmem_protection_3 : io_dmem_protection_2;
  assign T91 = T88[1'h0:1'h0];
  assign T92 = T88[1'h1:1'h1];
  assign T93 = T98 ? T96 : T94;
  assign T94 = T95 ? io_dmem_protection_5 : io_dmem_protection_4;
  assign T95 = T88[1'h0:1'h0];
  assign T96 = T97 ? io_dmem_protection_7 : io_dmem_protection_6;
  assign T97 = T88[1'h0:1'h0];
  assign T98 = T88[1'h1:1'h1];
  assign T99 = T88[2'h2:2'h2];
  assign T100 = T103 | T101;
  assign T101 = T102 == io_thread;
  assign T102 = T84[1'h1:1'h0];
  assign T103 = T84 == 4'h8;
  assign bus_op = T104 == 2'h1;
  assign T104 = io_addr[5'h1f:5'h1e];
  assign io_bus_enable = T105;
  assign T105 = bus_op & T106;
  assign T106 = io_load | io_store;
  assign io_bus_addr = T107;
  assign T107 = {io_thread, T108};
  assign T108 = io_addr[3'h7:1'h0];
  assign io_imem_rw_data_in = io_data_in;
  assign io_imem_rw_write = T109;
  assign T109 = imem_op & write;
  assign io_imem_rw_enable = T110;
  assign T110 = imem_op & T111;
  assign T111 = io_load | io_store;
  assign io_imem_rw_addr = T142;
  assign T142 = {2'h0, T112};
  assign T112 = io_addr[4'hb:2'h2];
  assign io_dmem_data_in = T113;
  assign T113 = T121 ? T118 : T114;
  assign T114 = T117 ? T115 : io_data_in;
  assign T115 = {T116, T116};
  assign T116 = io_data_in[4'hf:1'h0];
  assign T117 = io_mem_type == 4'h9;
  assign T118 = {T119, T119};
  assign T119 = {T120, T120};
  assign T120 = io_data_in[3'h7:1'h0];
  assign T121 = io_mem_type == 4'h8;
  assign io_dmem_byte_write_0 = T122;
  assign T122 = T123[1'h0:1'h0];
  assign T123 = T125 & T143;
  assign T143 = {1'h0, T124};
  assign T124 = write ? 4'hf : 4'h0;
  assign T125 = T133 ? T145 : T126;
  assign T126 = T131 ? T129 : T144;
  assign T144 = {1'h0, T127};
  assign T127 = T128 ? 4'hf : 4'h0;
  assign T128 = io_mem_type == 4'ha;
  assign T129 = 2'h3 << T130;
  assign T130 = io_addr[1'h1:1'h0];
  assign T131 = io_mem_type == 4'h9;
  assign T145 = {1'h0, T132};
  assign T132 = 1'h1 << T130;
  assign T133 = io_mem_type == 4'h8;
  assign io_dmem_byte_write_1 = T134;
  assign T134 = T123[1'h1:1'h1];
  assign io_dmem_byte_write_2 = T135;
  assign T135 = T123[2'h2:2'h2];
  assign io_dmem_byte_write_3 = T136;
  assign T136 = T123[2'h3:2'h3];
  assign io_dmem_enable = T137;
  assign T137 = dmem_op & T138;
  assign T138 = io_load | io_store;
  assign io_dmem_addr = T139;
  assign T139 = io_addr[4'hd:2'h2];

  always @(posedge clk) begin
    imem_op_reg <= imem_op;
    addr_byte_reg <= T31;
    mem_type_reg <= io_mem_type;
    dmem_op_reg <= dmem_op;
  end
endmodule

module CSR(input clk, input reset,
    input [11:0] io_rw_addr,
    input [1:0] io_rw_thread,
    input [1:0] io_rw_csr_type,
    input  io_rw_write,
    input [31:0] io_rw_data_in,
    output[31:0] io_rw_data_out,
    input  io_rw_valid,
    output[3:0] io_slots_7,
    output[3:0] io_slots_6,
    output[3:0] io_slots_5,
    output[3:0] io_slots_4,
    output[3:0] io_slots_3,
    output[3:0] io_slots_2,
    output[3:0] io_slots_1,
    output[3:0] io_slots_0,
    output[1:0] io_tmodes_3,
    output[1:0] io_tmodes_2,
    output[1:0] io_tmodes_1,
    output[1:0] io_tmodes_0,
    input  io_kill,
    input  io_exception,
    input [31:0] io_epc,
    input [4:0] io_cause,
    output[31:0] io_evecs_3,
    output[31:0] io_evecs_2,
    output[31:0] io_evecs_1,
    output[31:0] io_evecs_0,
    input  io_sleep,
    input  io_ie,
    input  io_ee,
    output io_expire,
    input [1:0] io_dec_tid,
    input  io_sret,
    output[31:0] io_host_to_host,
    input  io_gpio_in_3,
    input  io_gpio_in_2,
    input  io_gpio_in_1,
    input  io_gpio_in_0,
    output[1:0] io_gpio_out_3,
    output[1:0] io_gpio_out_2,
    output[1:0] io_gpio_out_1,
    output[1:0] io_gpio_out_0,
    input  io_int_exts_3,
    input  io_int_exts_2,
    input  io_int_exts_1,
    input  io_int_exts_0,
    output[3:0] io_imem_protection_7,
    output[3:0] io_imem_protection_6,
    output[3:0] io_imem_protection_5,
    output[3:0] io_imem_protection_4,
    output[3:0] io_imem_protection_3,
    output[3:0] io_imem_protection_2,
    output[3:0] io_imem_protection_1,
    output[3:0] io_imem_protection_0,
    output[3:0] io_dmem_protection_7,
    output[3:0] io_dmem_protection_6,
    output[3:0] io_dmem_protection_5,
    output[3:0] io_dmem_protection_4,
    output[3:0] io_dmem_protection_3,
    output[3:0] io_dmem_protection_2,
    output[3:0] io_dmem_protection_1,
    output[3:0] io_dmem_protection_0,
    input  io_cycle,
    input  io_instret,
    output io_int_expire,
    output io_exc_expire,
    output io_int_ext,
    output io_priv_fault
);

  wire priv_fault;
  wire int_ext;
  wire T0;
  wire T1;
  wire T2;
  reg  reg_msip_0;
  wire T612;
  wire T3;
  wire T4;
  wire T5;
  wire T6;
  wire T7;
  wire T8;
  wire T9;
  wire[35:0] data_in;
  wire[35:0] T10;
  wire[35:0] T613;
  wire[31:0] T11;
  wire T12;
  wire[35:0] T13;
  wire[35:0] T614;
  wire[31:0] T14;
  wire[35:0] data_out;
  wire[35:0] T15;
  wire[35:0] T16;
  wire[35:0] T17;
  wire[35:0] T18;
  wire[35:0] T19;
  wire[35:0] T20;
  wire[35:0] T21;
  wire[35:0] T22;
  wire[35:0] T23;
  wire[35:0] T24;
  wire[35:0] T25;
  wire[35:0] T26;
  wire[35:0] T27;
  wire[35:0] T28;
  wire[35:0] T29;
  wire[35:0] T30;
  wire[35:0] T31;
  wire[35:0] T32;
  wire[35:0] T615;
  wire[31:0] T33;
  wire[31:0] T34;
  wire[31:0] T35;
  wire[31:0] T36;
  wire[31:0] T37;
  wire[15:0] T38;
  wire[7:0] T39;
  reg [3:0] reg_slots_0;
  wire[3:0] T616;
  wire[3:0] T40;
  wire[3:0] T41;
  wire T42;
  wire T43;
  wire write;
  wire T44;
  wire T45;
  wire T46;
  reg [3:0] reg_slots_1;
  wire[3:0] T617;
  wire[3:0] T47;
  wire[3:0] T48;
  wire[7:0] T49;
  reg [3:0] reg_slots_2;
  wire[3:0] T618;
  wire[3:0] T50;
  wire[3:0] T51;
  reg [3:0] reg_slots_3;
  wire[3:0] T619;
  wire[3:0] T52;
  wire[3:0] T53;
  wire[15:0] T54;
  wire[7:0] T55;
  reg [3:0] reg_slots_4;
  wire[3:0] T620;
  wire[3:0] T56;
  wire[3:0] T57;
  reg [3:0] reg_slots_5;
  wire[3:0] T621;
  wire[3:0] T58;
  wire[3:0] T59;
  wire[7:0] T60;
  reg [3:0] reg_slots_6;
  wire[3:0] T622;
  wire[3:0] T61;
  wire[3:0] T62;
  reg [3:0] reg_slots_7;
  wire[3:0] T623;
  wire[3:0] T63;
  wire[3:0] T64;
  wire T65;
  wire[31:0] T66;
  wire T67;
  wire[31:0] T68;
  wire[7:0] T69;
  wire[7:0] T70;
  wire[3:0] T71;
  reg [1:0] reg_tmodes_0;
  wire[1:0] T624;
  wire[1:0] T72;
  wire[1:0] T73;
  wire[1:0] T74;
  wire[1:0] T75;
  wire T76;
  wire T77;
  wire[1:0] T78;
  wire[1:0] T79;
  wire[1:0] T80;
  wire T81;
  wire[1:0] T82;
  wire[1:0] T83;
  reg [1:0] reg_tmodes_2;
  wire[1:0] T625;
  wire[1:0] T84;
  wire[1:0] T85;
  wire[1:0] T86;
  wire[1:0] T87;
  wire T88;
  wire T89;
  wire[3:0] T90;
  wire sleep;
  wire[1:0] T91;
  wire wake_2;
  wire T92;
  wire T93;
  wire expired_2;
  wire T94;
  wire T95;
  wire[31:0] T96;
  reg [31:0] reg_compare_2;
  wire[31:0] T97;
  wire[31:0] T98;
  wire T99;
  wire T100;
  wire[3:0] T101;
  wire[1:0] T102;
  wire T103;
  wire T104;
  wire[31:0] T105;
  reg [63:0] reg_time;
  wire[63:0] T626;
  wire[63:0] T106;
  wire T107;
  reg [1:0] reg_timer_2;
  wire[1:0] T627;
  wire[1:0] T108;
  wire[1:0] T109;
  wire[1:0] T110;
  wire[1:0] T111;
  wire[1:0] T112;
  wire[1:0] T113;
  wire[1:0] T114;
  wire T115;
  wire T116;
  wire[3:0] T117;
  wire[1:0] T118;
  wire T119;
  wire T120;
  wire T121;
  wire T122;
  wire T123;
  wire T124;
  wire expired_0;
  wire T125;
  wire T126;
  wire[31:0] T127;
  reg [31:0] reg_compare_0;
  wire[31:0] T128;
  wire T129;
  wire T130;
  wire[31:0] T131;
  wire expired_1;
  wire T132;
  wire T133;
  wire[31:0] T134;
  reg [31:0] reg_compare_1;
  wire[31:0] T135;
  wire T136;
  wire T137;
  wire[31:0] T138;
  wire T139;
  wire[1:0] T140;
  wire T141;
  wire expired_3;
  wire T142;
  wire T143;
  wire[31:0] T144;
  reg [31:0] reg_compare_3;
  wire[31:0] T145;
  wire T146;
  wire T147;
  wire[31:0] T148;
  wire T149;
  wire T150;
  wire T151;
  wire T152;
  wire[1:0] T153;
  wire[1:0] T154;
  reg [1:0] reg_timer_0;
  wire[1:0] T628;
  wire[1:0] T155;
  wire[1:0] T156;
  wire[1:0] T157;
  wire[1:0] T158;
  wire[1:0] T159;
  wire[1:0] T160;
  wire[1:0] T161;
  wire T162;
  wire T163;
  wire T164;
  wire T165;
  wire T166;
  wire T167;
  wire T168;
  wire T169;
  wire T170;
  wire T171;
  wire T172;
  wire T173;
  reg [1:0] reg_timer_1;
  wire[1:0] T629;
  wire[1:0] T174;
  wire[1:0] T175;
  wire[1:0] T176;
  wire[1:0] T177;
  wire[1:0] T178;
  wire[1:0] T179;
  wire[1:0] T180;
  wire T181;
  wire T182;
  wire T183;
  wire T184;
  wire T185;
  wire T186;
  wire T187;
  wire T188;
  wire T189;
  wire T190;
  wire[1:0] T191;
  reg [1:0] reg_timer_3;
  wire[1:0] T630;
  wire[1:0] T192;
  wire[1:0] T193;
  wire[1:0] T194;
  wire[1:0] T195;
  wire[1:0] T196;
  wire[1:0] T197;
  wire[1:0] T198;
  wire T199;
  wire T200;
  wire T201;
  wire T202;
  wire T203;
  wire T204;
  wire T205;
  wire T206;
  wire T207;
  wire T208;
  wire T209;
  wire T210;
  wire T211;
  reg [1:0] reg_tmodes_3;
  wire[1:0] T631;
  wire[1:0] T212;
  wire[1:0] T213;
  wire[1:0] T214;
  wire[1:0] T215;
  wire T216;
  wire T217;
  wire[1:0] T218;
  wire wake_3;
  wire T219;
  wire T220;
  wire T221;
  wire T222;
  wire T223;
  wire[1:0] T224;
  wire wake_0;
  wire T225;
  reg [1:0] reg_tmodes_1;
  wire[1:0] T632;
  wire[1:0] T226;
  wire[1:0] T227;
  wire[1:0] T228;
  wire[1:0] T229;
  wire T230;
  wire T231;
  wire[1:0] T232;
  wire wake_1;
  wire T233;
  wire[3:0] T234;
  wire T235;
  wire[35:0] T236;
  wire[35:0] T237;
  reg [35:0] reg_evecs_0;
  wire[35:0] T238;
  wire T239;
  wire T240;
  wire[3:0] T241;
  wire[1:0] T242;
  wire T243;
  wire T244;
  reg [35:0] reg_evecs_1;
  wire[35:0] T245;
  wire T246;
  wire T247;
  wire T248;
  wire[35:0] T249;
  reg [35:0] reg_evecs_2;
  wire[35:0] T250;
  wire T251;
  wire T252;
  reg [35:0] reg_evecs_3;
  wire[35:0] T253;
  wire T254;
  wire T255;
  wire T256;
  wire T257;
  wire T258;
  wire[35:0] T633;
  wire[31:0] T259;
  wire[31:0] T260;
  reg [31:0] reg_epcs_0;
  wire[31:0] T261;
  wire T262;
  wire T263;
  wire[3:0] T264;
  wire[1:0] T265;
  reg [31:0] reg_epcs_1;
  wire[31:0] T266;
  wire T267;
  wire T268;
  wire T269;
  wire[31:0] T270;
  reg [31:0] reg_epcs_2;
  wire[31:0] T271;
  wire T272;
  wire T273;
  reg [31:0] reg_epcs_3;
  wire[31:0] T274;
  wire T275;
  wire T276;
  wire T277;
  wire T278;
  wire T279;
  wire[35:0] T634;
  wire[31:0] T280;
  wire[30:0] T281;
  wire[3:0] T282;
  wire[4:0] T283;
  wire[4:0] T284;
  reg [4:0] reg_causes_0;
  wire[4:0] T285;
  wire T286;
  wire T287;
  wire[3:0] T288;
  wire[1:0] T289;
  reg [4:0] reg_causes_1;
  wire[4:0] T290;
  wire T291;
  wire T292;
  wire T293;
  wire[4:0] T294;
  reg [4:0] reg_causes_2;
  wire[4:0] T295;
  wire T296;
  wire T297;
  reg [4:0] reg_causes_3;
  wire[4:0] T298;
  wire T299;
  wire T300;
  wire T301;
  wire T302;
  wire T303;
  wire T304;
  wire[35:0] T305;
  wire[35:0] T306;
  reg [35:0] reg_sup0_0;
  wire[35:0] T307;
  wire T308;
  wire T309;
  wire[3:0] T310;
  wire[1:0] T311;
  wire T312;
  wire T313;
  reg [35:0] reg_sup0_1;
  wire[35:0] T314;
  wire T315;
  wire T316;
  wire T317;
  wire[35:0] T318;
  reg [35:0] reg_sup0_2;
  wire[35:0] T319;
  wire T320;
  wire T321;
  reg [35:0] reg_sup0_3;
  wire[35:0] T322;
  wire T323;
  wire T324;
  wire T325;
  wire T326;
  wire T327;
  wire[35:0] T635;
  wire[31:0] T328;
  wire T329;
  wire[35:0] T636;
  reg [31:0] reg_to_host;
  wire[31:0] T637;
  wire[35:0] T638;
  wire[35:0] T330;
  wire[35:0] T639;
  wire T331;
  wire T332;
  wire T333;
  wire[35:0] T640;
  wire[31:0] T334;
  reg  reg_gpis_0;
  wire T335;
  wire[35:0] T641;
  wire[31:0] T336;
  reg  reg_gpis_1;
  wire T337;
  wire[35:0] T642;
  wire[31:0] T338;
  reg  reg_gpis_2;
  wire T339;
  wire[35:0] T643;
  wire[31:0] T340;
  reg  reg_gpis_3;
  wire T341;
  wire[35:0] T644;
  wire[31:0] T342;
  reg [1:0] reg_gpos_0;
  wire[1:0] T645;
  wire[1:0] T343;
  wire[1:0] T344;
  wire T345;
  wire T346;
  wire T347;
  reg [3:0] reg_gpo_protection_0;
  wire[3:0] T646;
  wire[3:0] T348;
  wire[3:0] T349;
  wire T350;
  wire T351;
  wire T352;
  wire T353;
  wire[1:0] T354;
  wire T355;
  wire T356;
  wire T357;
  wire T358;
  wire[35:0] T647;
  wire[31:0] T359;
  reg [1:0] reg_gpos_1;
  wire[1:0] T648;
  wire[1:0] T360;
  wire[1:0] T361;
  wire T362;
  wire T363;
  wire T364;
  reg [3:0] reg_gpo_protection_1;
  wire[3:0] T649;
  wire[3:0] T365;
  wire[3:0] T366;
  wire T367;
  wire T368;
  wire[1:0] T369;
  wire T370;
  wire T371;
  wire T372;
  wire T373;
  wire[35:0] T650;
  wire[31:0] T374;
  reg [1:0] reg_gpos_2;
  wire[1:0] T651;
  wire[1:0] T375;
  wire[1:0] T376;
  wire T377;
  wire T378;
  wire T379;
  reg [3:0] reg_gpo_protection_2;
  wire[3:0] T652;
  wire[3:0] T380;
  wire[3:0] T381;
  wire T382;
  wire T383;
  wire[1:0] T384;
  wire T385;
  wire T386;
  wire T387;
  wire T388;
  wire[35:0] T653;
  wire[31:0] T389;
  reg [1:0] reg_gpos_3;
  wire[1:0] T654;
  wire[1:0] T390;
  wire[1:0] T391;
  wire T392;
  wire T393;
  wire T394;
  reg [3:0] reg_gpo_protection_3;
  wire[3:0] T655;
  wire[3:0] T395;
  wire[3:0] T396;
  wire T397;
  wire T398;
  wire[1:0] T399;
  wire T400;
  wire T401;
  wire T402;
  wire T403;
  wire[35:0] T656;
  wire[15:0] T404;
  wire[15:0] T405;
  wire[7:0] T406;
  wire[7:0] T407;
  wire T408;
  wire[35:0] T657;
  wire[31:0] T409;
  wire[31:0] T410;
  wire[15:0] T411;
  wire[7:0] T412;
  reg [3:0] reg_imem_protection_0;
  wire[3:0] T658;
  wire[3:0] T413;
  wire[3:0] T414;
  wire T415;
  wire T416;
  reg [3:0] reg_imem_protection_1;
  wire[3:0] T659;
  wire[3:0] T417;
  wire[3:0] T418;
  wire[7:0] T419;
  reg [3:0] reg_imem_protection_2;
  wire[3:0] T660;
  wire[3:0] T420;
  wire[3:0] T421;
  reg [3:0] reg_imem_protection_3;
  wire[3:0] T661;
  wire[3:0] T422;
  wire[3:0] T423;
  wire[15:0] T424;
  wire[7:0] T425;
  reg [3:0] reg_imem_protection_4;
  wire[3:0] T662;
  wire[3:0] T426;
  wire[3:0] T427;
  reg [3:0] reg_imem_protection_5;
  wire[3:0] T663;
  wire[3:0] T428;
  wire[3:0] T429;
  wire[7:0] T430;
  reg [3:0] reg_imem_protection_6;
  wire[3:0] T664;
  wire[3:0] T431;
  wire[3:0] T432;
  reg [3:0] reg_imem_protection_7;
  wire[3:0] T665;
  wire[3:0] T433;
  wire[3:0] T434;
  wire T435;
  wire[35:0] T666;
  wire[31:0] T436;
  wire[31:0] T437;
  wire[15:0] T438;
  wire[7:0] T439;
  reg [3:0] reg_dmem_protection_0;
  wire[3:0] T667;
  wire[3:0] T440;
  wire[3:0] T441;
  wire T442;
  wire T443;
  reg [3:0] reg_dmem_protection_1;
  wire[3:0] T668;
  wire[3:0] T444;
  wire[3:0] T445;
  wire[7:0] T446;
  reg [3:0] reg_dmem_protection_2;
  wire[3:0] T669;
  wire[3:0] T447;
  wire[3:0] T448;
  reg [3:0] reg_dmem_protection_3;
  wire[3:0] T670;
  wire[3:0] T449;
  wire[3:0] T450;
  wire[15:0] T451;
  wire[7:0] T452;
  reg [3:0] reg_dmem_protection_4;
  wire[3:0] T671;
  wire[3:0] T453;
  wire[3:0] T454;
  reg [3:0] reg_dmem_protection_5;
  wire[3:0] T672;
  wire[3:0] T455;
  wire[3:0] T456;
  wire[7:0] T457;
  reg [3:0] reg_dmem_protection_6;
  wire[3:0] T673;
  wire[3:0] T458;
  wire[3:0] T459;
  reg [3:0] reg_dmem_protection_7;
  wire[3:0] T674;
  wire[3:0] T460;
  wire[3:0] T461;
  wire T462;
  wire[35:0] T463;
  wire[35:0] T464;
  wire[35:0] status_0;
  wire[35:0] T465;
  wire[7:0] T466;
  wire[4:0] T467;
  wire[3:0] T468;
  reg  reg_ie_0;
  wire T675;
  wire T469;
  wire T470;
  wire T471;
  wire T472;
  wire T473;
  wire T474;
  wire[3:0] T475;
  wire[1:0] T476;
  wire T477;
  wire T478;
  wire[2:0] T479;
  reg [1:0] reg_prv_0;
  wire[1:0] T676;
  reg  reg_ie1_0;
  wire T677;
  wire[27:0] T480;
  wire[22:0] T481;
  wire[21:0] T482;
  reg [1:0] reg_prv1_0;
  wire[1:0] T678;
  reg  reg_mtie_0;
  wire T679;
  wire T483;
  wire T484;
  wire T485;
  wire T486;
  wire T487;
  wire T488;
  wire[3:0] T489;
  wire[1:0] T490;
  wire T491;
  wire[35:0] status_1;
  wire[35:0] T492;
  wire[7:0] T493;
  wire[4:0] T494;
  wire[3:0] T495;
  reg  reg_ie_1;
  wire T680;
  wire T496;
  wire T497;
  wire T498;
  wire T499;
  wire[2:0] T500;
  reg [1:0] reg_prv_1;
  wire[1:0] T681;
  reg  reg_ie1_1;
  wire T682;
  wire[27:0] T501;
  wire[22:0] T502;
  wire[21:0] T503;
  reg [1:0] reg_prv1_1;
  wire[1:0] T683;
  reg  reg_mtie_1;
  wire T684;
  wire T504;
  wire T505;
  wire T506;
  wire T507;
  wire T508;
  wire T509;
  wire[1:0] T510;
  wire[35:0] T511;
  wire[35:0] status_2;
  wire[35:0] T512;
  wire[7:0] T513;
  wire[4:0] T514;
  wire[3:0] T515;
  reg  reg_msip_2;
  wire T685;
  wire T516;
  wire T517;
  wire T518;
  wire T519;
  wire T520;
  wire T521;
  wire T522;
  wire[3:0] T523;
  wire[1:0] T524;
  wire T525;
  wire T526;
  wire T527;
  wire T528;
  reg  reg_ie_2;
  wire T686;
  wire T529;
  wire T530;
  wire T531;
  wire T532;
  wire[2:0] T533;
  reg [1:0] reg_prv_2;
  wire[1:0] T687;
  reg  reg_ie1_2;
  wire T688;
  wire[27:0] T534;
  wire[22:0] T535;
  wire[21:0] T536;
  reg [1:0] reg_prv1_2;
  wire[1:0] T689;
  reg  reg_mtie_2;
  wire T690;
  wire T537;
  wire T538;
  wire T539;
  wire T540;
  wire T541;
  wire[35:0] status_3;
  wire[35:0] T542;
  wire[7:0] T543;
  wire[4:0] T544;
  wire[3:0] T545;
  reg  reg_msip_3;
  wire T691;
  wire T546;
  wire T547;
  wire T548;
  wire T549;
  wire T550;
  wire T551;
  wire T552;
  wire T553;
  wire T554;
  wire T555;
  wire T556;
  reg  reg_ie_3;
  wire T692;
  wire T557;
  wire T558;
  wire T559;
  wire T560;
  wire[2:0] T561;
  reg [1:0] reg_prv_3;
  wire[1:0] T693;
  reg  reg_ie1_3;
  wire T694;
  wire[27:0] T562;
  wire[22:0] T563;
  wire[21:0] T564;
  reg [1:0] reg_prv1_3;
  wire[1:0] T695;
  reg  reg_mtie_3;
  wire T696;
  wire T565;
  wire T566;
  wire T567;
  wire T568;
  wire T569;
  wire T570;
  wire T571;
  wire T572;
  wire T573;
  wire[35:0] T574;
  wire[35:0] T697;
  wire T575;
  wire T576;
  wire T577;
  wire T578;
  wire T579;
  wire T580;
  wire T581;
  reg  reg_msip_1;
  wire T698;
  wire T582;
  wire T583;
  wire T584;
  wire T585;
  wire T586;
  wire T587;
  wire T588;
  wire T589;
  wire T590;
  wire T591;
  wire T592;
  wire T593;
  wire T594;
  wire T595;
  wire T596;
  wire T597;
  wire T598;
  wire T599;
  wire T600;
  wire T601;
  wire T602;
  wire exc_expire;
  wire int_expire;
  wire T603;
  wire T604;
  wire T605;
  wire T606;
  wire T607;
  wire T608;
  wire T609;
  wire T610;
  wire T611;
  wire[31:0] T699;
  wire[31:0] T700;
  wire[31:0] T701;
  wire[31:0] T702;
  wire[31:0] T703;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    reg_msip_0 = {1{$random}};
    reg_slots_0 = {1{$random}};
    reg_slots_1 = {1{$random}};
    reg_slots_2 = {1{$random}};
    reg_slots_3 = {1{$random}};
    reg_slots_4 = {1{$random}};
    reg_slots_5 = {1{$random}};
    reg_slots_6 = {1{$random}};
    reg_slots_7 = {1{$random}};
    reg_tmodes_0 = {1{$random}};
    reg_tmodes_2 = {1{$random}};
    reg_compare_2 = {1{$random}};
    reg_time = {2{$random}};
    reg_timer_2 = {1{$random}};
    reg_compare_0 = {1{$random}};
    reg_compare_1 = {1{$random}};
    reg_compare_3 = {1{$random}};
    reg_timer_0 = {1{$random}};
    reg_timer_1 = {1{$random}};
    reg_timer_3 = {1{$random}};
    reg_tmodes_3 = {1{$random}};
    reg_tmodes_1 = {1{$random}};
    reg_evecs_0 = {2{$random}};
    reg_evecs_1 = {2{$random}};
    reg_evecs_2 = {2{$random}};
    reg_evecs_3 = {2{$random}};
    reg_epcs_0 = {1{$random}};
    reg_epcs_1 = {1{$random}};
    reg_epcs_2 = {1{$random}};
    reg_epcs_3 = {1{$random}};
    reg_causes_0 = {1{$random}};
    reg_causes_1 = {1{$random}};
    reg_causes_2 = {1{$random}};
    reg_causes_3 = {1{$random}};
    reg_sup0_0 = {2{$random}};
    reg_sup0_1 = {2{$random}};
    reg_sup0_2 = {2{$random}};
    reg_sup0_3 = {2{$random}};
    reg_to_host = {1{$random}};
    reg_gpis_0 = {1{$random}};
    reg_gpis_1 = {1{$random}};
    reg_gpis_2 = {1{$random}};
    reg_gpis_3 = {1{$random}};
    reg_gpos_0 = {1{$random}};
    reg_gpo_protection_0 = {1{$random}};
    reg_gpos_1 = {1{$random}};
    reg_gpo_protection_1 = {1{$random}};
    reg_gpos_2 = {1{$random}};
    reg_gpo_protection_2 = {1{$random}};
    reg_gpos_3 = {1{$random}};
    reg_gpo_protection_3 = {1{$random}};
    reg_imem_protection_0 = {1{$random}};
    reg_imem_protection_1 = {1{$random}};
    reg_imem_protection_2 = {1{$random}};
    reg_imem_protection_3 = {1{$random}};
    reg_imem_protection_4 = {1{$random}};
    reg_imem_protection_5 = {1{$random}};
    reg_imem_protection_6 = {1{$random}};
    reg_imem_protection_7 = {1{$random}};
    reg_dmem_protection_0 = {1{$random}};
    reg_dmem_protection_1 = {1{$random}};
    reg_dmem_protection_2 = {1{$random}};
    reg_dmem_protection_3 = {1{$random}};
    reg_dmem_protection_4 = {1{$random}};
    reg_dmem_protection_5 = {1{$random}};
    reg_dmem_protection_6 = {1{$random}};
    reg_dmem_protection_7 = {1{$random}};
    reg_ie_0 = {1{$random}};
    reg_prv_0 = {1{$random}};
    reg_ie1_0 = {1{$random}};
    reg_prv1_0 = {1{$random}};
    reg_mtie_0 = {1{$random}};
    reg_ie_1 = {1{$random}};
    reg_prv_1 = {1{$random}};
    reg_ie1_1 = {1{$random}};
    reg_prv1_1 = {1{$random}};
    reg_mtie_1 = {1{$random}};
    reg_msip_2 = {1{$random}};
    reg_ie_2 = {1{$random}};
    reg_prv_2 = {1{$random}};
    reg_ie1_2 = {1{$random}};
    reg_prv1_2 = {1{$random}};
    reg_mtie_2 = {1{$random}};
    reg_msip_3 = {1{$random}};
    reg_ie_3 = {1{$random}};
    reg_prv_3 = {1{$random}};
    reg_ie1_3 = {1{$random}};
    reg_prv1_3 = {1{$random}};
    reg_mtie_3 = {1{$random}};
    reg_msip_1 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_priv_fault = priv_fault;
  assign priv_fault = 1'h0;
  assign io_int_ext = int_ext;
  assign int_ext = T0;
  assign T0 = T597 & T1;
  assign T1 = T596 ? T594 : T2;
  assign T2 = T593 ? reg_msip_1 : reg_msip_0;
  assign T612 = reset ? 1'h0 : T3;
  assign T3 = T581 ? 1'h1 : T4;
  assign T4 = T580 ? 1'h1 : T5;
  assign T5 = T579 ? 1'h1 : T6;
  assign T6 = T578 ? 1'h1 : T7;
  assign T7 = T576 ? T8 : reg_msip_0;
  assign T8 = T9;
  assign T9 = data_in[2'h3:2'h3];
  assign data_in = T575 ? T574 : T10;
  assign T10 = T573 ? T13 : T613;
  assign T613 = {4'h0, T11};
  assign T11 = T12 ? io_rw_data_in : io_rw_data_in;
  assign T12 = io_rw_csr_type == 2'h1;
  assign T13 = data_out & T614;
  assign T614 = {4'h0, T14};
  assign T14 = ~ io_rw_data_in;
  assign data_out = T15;
  assign T15 = T572 ? T463 : T16;
  assign T16 = T462 ? T666 : T17;
  assign T17 = T435 ? T657 : T18;
  assign T18 = T408 ? T656 : T19;
  assign T19 = T403 ? T653 : T20;
  assign T20 = T388 ? T650 : T21;
  assign T21 = T373 ? T647 : T22;
  assign T22 = T358 ? T644 : T23;
  assign T23 = T341 ? T643 : T24;
  assign T24 = T339 ? T642 : T25;
  assign T25 = T337 ? T641 : T26;
  assign T26 = T335 ? T640 : T27;
  assign T27 = T333 ? T636 : T28;
  assign T28 = T329 ? T635 : T29;
  assign T29 = T327 ? T305 : T30;
  assign T30 = T304 ? T634 : T31;
  assign T31 = T279 ? T633 : T32;
  assign T32 = T258 ? T236 : T615;
  assign T615 = {4'h0, T33};
  assign T33 = T235 ? T68 : T34;
  assign T34 = T67 ? T66 : T35;
  assign T35 = T65 ? T36 : 32'h0;
  assign T36 = T37;
  assign T37 = {T54, T38};
  assign T38 = {T49, T39};
  assign T39 = {reg_slots_1, reg_slots_0};
  assign T616 = reset ? 4'hf : T40;
  assign T40 = T42 ? T41 : reg_slots_0;
  assign T41 = data_in[2'h3:1'h0];
  assign T42 = write & T43;
  assign T43 = io_rw_addr == 12'h503;
  assign write = T45 & T44;
  assign T44 = io_kill ^ 1'h1;
  assign T45 = io_rw_write & T46;
  assign T46 = priv_fault ^ 1'h1;
  assign T617 = reset ? 4'hf : T47;
  assign T47 = T42 ? T48 : reg_slots_1;
  assign T48 = data_in[3'h7:3'h4];
  assign T49 = {reg_slots_3, reg_slots_2};
  assign T618 = reset ? 4'hf : T50;
  assign T50 = T42 ? T51 : reg_slots_2;
  assign T51 = data_in[4'hb:4'h8];
  assign T619 = reset ? 4'hf : T52;
  assign T52 = T42 ? T53 : reg_slots_3;
  assign T53 = data_in[4'hf:4'hc];
  assign T54 = {T60, T55};
  assign T55 = {reg_slots_5, reg_slots_4};
  assign T620 = reset ? 4'hf : T56;
  assign T56 = T42 ? T57 : reg_slots_4;
  assign T57 = data_in[5'h13:5'h10];
  assign T621 = reset ? 4'hf : T58;
  assign T58 = T42 ? T59 : reg_slots_5;
  assign T59 = data_in[5'h17:5'h14];
  assign T60 = {reg_slots_7, reg_slots_6};
  assign T622 = reset ? 4'hf : T61;
  assign T61 = T42 ? T62 : reg_slots_6;
  assign T62 = data_in[5'h1b:5'h18];
  assign T623 = reset ? 4'h0 : T63;
  assign T63 = T42 ? T64 : reg_slots_7;
  assign T64 = data_in[5'h1f:5'h1c];
  assign T65 = io_rw_addr == 12'h503;
  assign T66 = {30'h0, io_rw_thread};
  assign T67 = io_rw_addr == 12'h50b;
  assign T68 = {24'h0, T69};
  assign T69 = T70;
  assign T70 = {T234, T71};
  assign T71 = {reg_tmodes_1, reg_tmodes_0};
  assign T624 = reset ? 2'h0 : T72;
  assign T72 = wake_0 ? T224 : T73;
  assign T73 = T222 ? T78 : T74;
  assign T74 = T76 ? T75 : reg_tmodes_0;
  assign T75 = data_in[1'h1:1'h0];
  assign T76 = write & T77;
  assign T77 = io_rw_addr == 12'h504;
  assign T78 = T79 | 2'h1;
  assign T79 = T221 ? T83 : T80;
  assign T80 = T81 ? reg_tmodes_1 : reg_tmodes_0;
  assign T81 = T82[1'h0:1'h0];
  assign T82 = io_rw_thread;
  assign T83 = T220 ? reg_tmodes_3 : reg_tmodes_2;
  assign T625 = reset ? 2'h1 : T84;
  assign T84 = wake_2 ? T91 : T85;
  assign T85 = T88 ? T78 : T86;
  assign T86 = T76 ? T87 : reg_tmodes_2;
  assign T87 = data_in[3'h5:3'h4];
  assign T88 = sleep & T89;
  assign T89 = T90[2'h2:2'h2];
  assign T90 = 1'h1 << T82;
  assign sleep = io_sleep;
  assign T91 = reg_tmodes_2 & 2'h2;
  assign wake_2 = T92;
  assign T92 = io_int_exts_2 ? 1'h1 : T93;
  assign T93 = T107 & expired_2;
  assign expired_2 = T94;
  assign T94 = T95 == 1'h0;
  assign T95 = T96[5'h1f:5'h1f];
  assign T96 = T105 - reg_compare_2;
  assign T97 = T99 ? T98 : reg_compare_2;
  assign T98 = data_in[5'h1f:1'h0];
  assign T99 = T103 & T100;
  assign T100 = T101[2'h2:2'h2];
  assign T101 = 1'h1 << T102;
  assign T102 = io_rw_thread;
  assign T103 = write & T104;
  assign T104 = io_rw_addr == 12'h507;
  assign T105 = reg_time[5'h1f:1'h0];
  assign T626 = reset ? 64'h0 : T106;
  assign T106 = reg_time + 64'ha;
  assign T107 = reg_timer_2 == 2'h1;
  assign T627 = reset ? 2'h0 : T108;
  assign T108 = T211 ? 2'h0 : T109;
  assign T109 = T210 ? 2'h2 : T110;
  assign T110 = T121 ? 2'h0 : T111;
  assign T111 = T120 ? 2'h3 : T112;
  assign T112 = T93 ? 2'h0 : T113;
  assign T113 = T119 ? 2'h1 : T114;
  assign T114 = T115 ? 2'h0 : reg_timer_2;
  assign T115 = T103 & T116;
  assign T116 = T117[2'h2:2'h2];
  assign T117 = 1'h1 << T118;
  assign T118 = io_rw_thread;
  assign T119 = io_sleep & T116;
  assign T120 = io_ee & T116;
  assign T121 = T122 & T116;
  assign T122 = T151 & T123;
  assign T123 = T150 ? T141 : T124;
  assign T124 = T139 ? expired_1 : expired_0;
  assign expired_0 = T125;
  assign T125 = T126 == 1'h0;
  assign T126 = T127[5'h1f:5'h1f];
  assign T127 = T131 - reg_compare_0;
  assign T128 = T129 ? T98 : reg_compare_0;
  assign T129 = T103 & T130;
  assign T130 = T101[1'h0:1'h0];
  assign T131 = reg_time[5'h1f:1'h0];
  assign expired_1 = T132;
  assign T132 = T133 == 1'h0;
  assign T133 = T134[5'h1f:5'h1f];
  assign T134 = T138 - reg_compare_1;
  assign T135 = T136 ? T98 : reg_compare_1;
  assign T136 = T103 & T137;
  assign T137 = T101[1'h1:1'h1];
  assign T138 = reg_time[5'h1f:1'h0];
  assign T139 = T140[1'h0:1'h0];
  assign T140 = io_rw_thread;
  assign T141 = T149 ? expired_3 : expired_2;
  assign expired_3 = T142;
  assign T142 = T143 == 1'h0;
  assign T143 = T144[5'h1f:5'h1f];
  assign T144 = T148 - reg_compare_3;
  assign T145 = T146 ? T98 : reg_compare_3;
  assign T146 = T103 & T147;
  assign T147 = T101[2'h3:2'h3];
  assign T148 = reg_time[5'h1f:1'h0];
  assign T149 = T140[1'h0:1'h0];
  assign T150 = T140[1'h1:1'h1];
  assign T151 = io_rw_valid & T152;
  assign T152 = T153 == 2'h3;
  assign T153 = T209 ? T191 : T154;
  assign T154 = T190 ? reg_timer_1 : reg_timer_0;
  assign T628 = reset ? 2'h0 : T155;
  assign T155 = T170 ? 2'h0 : T156;
  assign T156 = T169 ? 2'h2 : T157;
  assign T157 = T168 ? 2'h0 : T158;
  assign T158 = T167 ? 2'h3 : T159;
  assign T159 = T165 ? 2'h0 : T160;
  assign T160 = T164 ? 2'h1 : T161;
  assign T161 = T162 ? 2'h0 : reg_timer_0;
  assign T162 = T103 & T163;
  assign T163 = T117[1'h0:1'h0];
  assign T164 = io_sleep & T163;
  assign T165 = T166 & expired_0;
  assign T166 = reg_timer_0 == 2'h1;
  assign T167 = io_ee & T163;
  assign T168 = T122 & T163;
  assign T169 = io_ie & T163;
  assign T170 = T171 & T163;
  assign T171 = T172 & T123;
  assign T172 = io_rw_valid & T173;
  assign T173 = T153 == 2'h2;
  assign T629 = reset ? 2'h0 : T174;
  assign T174 = T189 ? 2'h0 : T175;
  assign T175 = T188 ? 2'h2 : T176;
  assign T176 = T187 ? 2'h0 : T177;
  assign T177 = T186 ? 2'h3 : T178;
  assign T178 = T184 ? 2'h0 : T179;
  assign T179 = T183 ? 2'h1 : T180;
  assign T180 = T181 ? 2'h0 : reg_timer_1;
  assign T181 = T103 & T182;
  assign T182 = T117[1'h1:1'h1];
  assign T183 = io_sleep & T182;
  assign T184 = T185 & expired_1;
  assign T185 = reg_timer_1 == 2'h1;
  assign T186 = io_ee & T182;
  assign T187 = T122 & T182;
  assign T188 = io_ie & T182;
  assign T189 = T171 & T182;
  assign T190 = T118[1'h0:1'h0];
  assign T191 = T208 ? reg_timer_3 : reg_timer_2;
  assign T630 = reset ? 2'h0 : T192;
  assign T192 = T207 ? 2'h0 : T193;
  assign T193 = T206 ? 2'h2 : T194;
  assign T194 = T205 ? 2'h0 : T195;
  assign T195 = T204 ? 2'h3 : T196;
  assign T196 = T202 ? 2'h0 : T197;
  assign T197 = T201 ? 2'h1 : T198;
  assign T198 = T199 ? 2'h0 : reg_timer_3;
  assign T199 = T103 & T200;
  assign T200 = T117[2'h3:2'h3];
  assign T201 = io_sleep & T200;
  assign T202 = T203 & expired_3;
  assign T203 = reg_timer_3 == 2'h1;
  assign T204 = io_ee & T200;
  assign T205 = T122 & T200;
  assign T206 = io_ie & T200;
  assign T207 = T171 & T200;
  assign T208 = T118[1'h0:1'h0];
  assign T209 = T118[1'h1:1'h1];
  assign T210 = io_ie & T116;
  assign T211 = T171 & T116;
  assign T631 = reset ? 2'h1 : T212;
  assign T212 = wake_3 ? T218 : T213;
  assign T213 = T216 ? T78 : T214;
  assign T214 = T76 ? T215 : reg_tmodes_3;
  assign T215 = data_in[3'h7:3'h6];
  assign T216 = sleep & T217;
  assign T217 = T90[2'h3:2'h3];
  assign T218 = reg_tmodes_3 & 2'h2;
  assign wake_3 = T219;
  assign T219 = io_int_exts_3 ? 1'h1 : T202;
  assign T220 = T82[1'h0:1'h0];
  assign T221 = T82[1'h1:1'h1];
  assign T222 = sleep & T223;
  assign T223 = T90[1'h0:1'h0];
  assign T224 = reg_tmodes_0 & 2'h2;
  assign wake_0 = T225;
  assign T225 = io_int_exts_0 ? 1'h1 : T165;
  assign T632 = reset ? 2'h1 : T226;
  assign T226 = wake_1 ? T232 : T227;
  assign T227 = T230 ? T78 : T228;
  assign T228 = T76 ? T229 : reg_tmodes_1;
  assign T229 = data_in[2'h3:2'h2];
  assign T230 = sleep & T231;
  assign T231 = T90[1'h1:1'h1];
  assign T232 = reg_tmodes_1 & 2'h2;
  assign wake_1 = T233;
  assign T233 = io_int_exts_1 ? 1'h1 : T184;
  assign T234 = {reg_tmodes_3, reg_tmodes_2};
  assign T235 = io_rw_addr == 12'h504;
  assign T236 = T257 ? T249 : T237;
  assign T237 = T248 ? reg_evecs_1 : reg_evecs_0;
  assign T238 = T239 ? data_in : reg_evecs_0;
  assign T239 = T243 & T240;
  assign T240 = T241[1'h0:1'h0];
  assign T241 = 1'h1 << T242;
  assign T242 = io_rw_thread;
  assign T243 = write & T244;
  assign T244 = io_rw_addr == 12'h508;
  assign T245 = T246 ? data_in : reg_evecs_1;
  assign T246 = T243 & T247;
  assign T247 = T241[1'h1:1'h1];
  assign T248 = T242[1'h0:1'h0];
  assign T249 = T256 ? reg_evecs_3 : reg_evecs_2;
  assign T250 = T251 ? data_in : reg_evecs_2;
  assign T251 = T243 & T252;
  assign T252 = T241[2'h2:2'h2];
  assign T253 = T254 ? data_in : reg_evecs_3;
  assign T254 = T243 & T255;
  assign T255 = T241[2'h3:2'h3];
  assign T256 = T242[1'h0:1'h0];
  assign T257 = T242[1'h1:1'h1];
  assign T258 = io_rw_addr == 12'h508;
  assign T633 = {4'h0, T259};
  assign T259 = T278 ? T270 : T260;
  assign T260 = T269 ? reg_epcs_1 : reg_epcs_0;
  assign T261 = T262 ? io_epc : reg_epcs_0;
  assign T262 = io_exception & T263;
  assign T263 = T264[1'h0:1'h0];
  assign T264 = 1'h1 << T265;
  assign T265 = io_rw_thread;
  assign T266 = T267 ? io_epc : reg_epcs_1;
  assign T267 = io_exception & T268;
  assign T268 = T264[1'h1:1'h1];
  assign T269 = T265[1'h0:1'h0];
  assign T270 = T277 ? reg_epcs_3 : reg_epcs_2;
  assign T271 = T272 ? io_epc : reg_epcs_2;
  assign T272 = io_exception & T273;
  assign T273 = T264[2'h2:2'h2];
  assign T274 = T275 ? io_epc : reg_epcs_3;
  assign T275 = io_exception & T276;
  assign T276 = T264[2'h3:2'h3];
  assign T277 = T265[1'h0:1'h0];
  assign T278 = T265[1'h1:1'h1];
  assign T279 = io_rw_addr == 12'h502;
  assign T634 = {4'h0, T280};
  assign T280 = {T303, T281};
  assign T281 = {27'h0, T282};
  assign T282 = T283[2'h3:1'h0];
  assign T283 = T302 ? T294 : T284;
  assign T284 = T293 ? reg_causes_1 : reg_causes_0;
  assign T285 = T286 ? io_cause : reg_causes_0;
  assign T286 = io_exception & T287;
  assign T287 = T288[1'h0:1'h0];
  assign T288 = 1'h1 << T289;
  assign T289 = io_rw_thread;
  assign T290 = T291 ? io_cause : reg_causes_1;
  assign T291 = io_exception & T292;
  assign T292 = T288[1'h1:1'h1];
  assign T293 = T289[1'h0:1'h0];
  assign T294 = T301 ? reg_causes_3 : reg_causes_2;
  assign T295 = T296 ? io_cause : reg_causes_2;
  assign T296 = io_exception & T297;
  assign T297 = T288[2'h2:2'h2];
  assign T298 = T299 ? io_cause : reg_causes_3;
  assign T299 = io_exception & T300;
  assign T300 = T288[2'h3:2'h3];
  assign T301 = T289[1'h0:1'h0];
  assign T302 = T289[1'h1:1'h1];
  assign T303 = T283[3'h4:3'h4];
  assign T304 = io_rw_addr == 12'h509;
  assign T305 = T326 ? T318 : T306;
  assign T306 = T317 ? reg_sup0_1 : reg_sup0_0;
  assign T307 = T308 ? data_in : reg_sup0_0;
  assign T308 = T312 & T309;
  assign T309 = T310[1'h0:1'h0];
  assign T310 = 1'h1 << T311;
  assign T311 = io_rw_thread;
  assign T312 = write & T313;
  assign T313 = io_rw_addr == 12'h500;
  assign T314 = T315 ? data_in : reg_sup0_1;
  assign T315 = T312 & T316;
  assign T316 = T310[1'h1:1'h1];
  assign T317 = T311[1'h0:1'h0];
  assign T318 = T325 ? reg_sup0_3 : reg_sup0_2;
  assign T319 = T320 ? data_in : reg_sup0_2;
  assign T320 = T312 & T321;
  assign T321 = T310[2'h2:2'h2];
  assign T322 = T323 ? data_in : reg_sup0_3;
  assign T323 = T312 & T324;
  assign T324 = T310[2'h3:2'h3];
  assign T325 = T311[1'h0:1'h0];
  assign T326 = T311[1'h1:1'h1];
  assign T327 = io_rw_addr == 12'h500;
  assign T635 = {4'h0, T328};
  assign T328 = reg_time[5'h1f:1'h0];
  assign T329 = io_rw_addr == 12'h1;
  assign T636 = {4'h0, reg_to_host};
  assign T637 = T638[5'h1f:1'h0];
  assign T638 = reset ? 36'h0 : T330;
  assign T330 = T331 ? data_in : T639;
  assign T639 = {4'h0, reg_to_host};
  assign T331 = write & T332;
  assign T332 = io_rw_addr == 12'h51e;
  assign T333 = io_rw_addr == 12'h51e;
  assign T640 = {4'h0, T334};
  assign T334 = {31'h0, reg_gpis_0};
  assign T335 = io_rw_addr == 12'hcc0;
  assign T641 = {4'h0, T336};
  assign T336 = {31'h0, reg_gpis_1};
  assign T337 = io_rw_addr == 12'hcc1;
  assign T642 = {4'h0, T338};
  assign T338 = {31'h0, reg_gpis_2};
  assign T339 = io_rw_addr == 12'hcc2;
  assign T643 = {4'h0, T340};
  assign T340 = {31'h0, reg_gpis_3};
  assign T341 = io_rw_addr == 12'hcc3;
  assign T644 = {4'h0, T342};
  assign T342 = {30'h0, reg_gpos_0};
  assign T645 = reset ? 2'h0 : T343;
  assign T343 = T345 ? T344 : reg_gpos_0;
  assign T344 = data_in[1'h1:1'h0];
  assign T345 = T356 & T346;
  assign T346 = T352 & T347;
  assign T347 = reg_gpo_protection_0 != 4'hc;
  assign T646 = reset ? 4'h0 : T348;
  assign T348 = T350 ? T349 : reg_gpo_protection_0;
  assign T349 = data_in[2'h3:1'h0];
  assign T350 = write & T351;
  assign T351 = io_rw_addr == 12'h50d;
  assign T352 = T355 | T353;
  assign T353 = T354 == io_rw_thread;
  assign T354 = reg_gpo_protection_0[1'h1:1'h0];
  assign T355 = reg_gpo_protection_0 == 4'h8;
  assign T356 = write & T357;
  assign T357 = io_rw_addr == 12'hcc4;
  assign T358 = io_rw_addr == 12'hcc4;
  assign T647 = {4'h0, T359};
  assign T359 = {30'h0, reg_gpos_1};
  assign T648 = reset ? 2'h0 : T360;
  assign T360 = T362 ? T361 : reg_gpos_1;
  assign T361 = data_in[1'h1:1'h0];
  assign T362 = T371 & T363;
  assign T363 = T367 & T364;
  assign T364 = reg_gpo_protection_1 != 4'hc;
  assign T649 = reset ? 4'h8 : T365;
  assign T365 = T350 ? T366 : reg_gpo_protection_1;
  assign T366 = data_in[3'h7:3'h4];
  assign T367 = T370 | T368;
  assign T368 = T369 == io_rw_thread;
  assign T369 = reg_gpo_protection_1[1'h1:1'h0];
  assign T370 = reg_gpo_protection_1 == 4'h8;
  assign T371 = write & T372;
  assign T372 = io_rw_addr == 12'hcc5;
  assign T373 = io_rw_addr == 12'hcc5;
  assign T650 = {4'h0, T374};
  assign T374 = {30'h0, reg_gpos_2};
  assign T651 = reset ? 2'h0 : T375;
  assign T375 = T377 ? T376 : reg_gpos_2;
  assign T376 = data_in[1'h1:1'h0];
  assign T377 = T386 & T378;
  assign T378 = T382 & T379;
  assign T379 = reg_gpo_protection_2 != 4'hc;
  assign T652 = reset ? 4'h8 : T380;
  assign T380 = T350 ? T381 : reg_gpo_protection_2;
  assign T381 = data_in[4'hb:4'h8];
  assign T382 = T385 | T383;
  assign T383 = T384 == io_rw_thread;
  assign T384 = reg_gpo_protection_2[1'h1:1'h0];
  assign T385 = reg_gpo_protection_2 == 4'h8;
  assign T386 = write & T387;
  assign T387 = io_rw_addr == 12'hcc6;
  assign T388 = io_rw_addr == 12'hcc6;
  assign T653 = {4'h0, T389};
  assign T389 = {30'h0, reg_gpos_3};
  assign T654 = reset ? 2'h0 : T390;
  assign T390 = T392 ? T391 : reg_gpos_3;
  assign T391 = data_in[1'h1:1'h0];
  assign T392 = T401 & T393;
  assign T393 = T397 & T394;
  assign T394 = reg_gpo_protection_3 != 4'hc;
  assign T655 = reset ? 4'h8 : T395;
  assign T395 = T350 ? T396 : reg_gpo_protection_3;
  assign T396 = data_in[4'hf:4'hc];
  assign T397 = T400 | T398;
  assign T398 = T399 == io_rw_thread;
  assign T399 = reg_gpo_protection_3[1'h1:1'h0];
  assign T400 = reg_gpo_protection_3 == 4'h8;
  assign T401 = write & T402;
  assign T402 = io_rw_addr == 12'hcc7;
  assign T403 = io_rw_addr == 12'hcc7;
  assign T656 = {20'h0, T404};
  assign T404 = T405;
  assign T405 = {T407, T406};
  assign T406 = {reg_gpo_protection_1, reg_gpo_protection_0};
  assign T407 = {reg_gpo_protection_3, reg_gpo_protection_2};
  assign T408 = io_rw_addr == 12'h50d;
  assign T657 = {4'h0, T409};
  assign T409 = T410;
  assign T410 = {T424, T411};
  assign T411 = {T419, T412};
  assign T412 = {reg_imem_protection_1, reg_imem_protection_0};
  assign T658 = reset ? 4'h8 : T413;
  assign T413 = T415 ? T414 : reg_imem_protection_0;
  assign T414 = data_in[2'h3:1'h0];
  assign T415 = write & T416;
  assign T416 = io_rw_addr == 12'h505;
  assign T659 = reset ? 4'hc : T417;
  assign T417 = T415 ? T418 : reg_imem_protection_1;
  assign T418 = data_in[3'h7:3'h4];
  assign T419 = {reg_imem_protection_3, reg_imem_protection_2};
  assign T660 = reset ? 4'hc : T420;
  assign T420 = T415 ? T421 : reg_imem_protection_2;
  assign T421 = data_in[4'hb:4'h8];
  assign T661 = reset ? 4'hc : T422;
  assign T422 = T415 ? T423 : reg_imem_protection_3;
  assign T423 = data_in[4'hf:4'hc];
  assign T424 = {T430, T425};
  assign T425 = {reg_imem_protection_5, reg_imem_protection_4};
  assign T662 = reset ? 4'hc : T426;
  assign T426 = T415 ? T427 : reg_imem_protection_4;
  assign T427 = data_in[5'h13:5'h10];
  assign T663 = reset ? 4'hc : T428;
  assign T428 = T415 ? T429 : reg_imem_protection_5;
  assign T429 = data_in[5'h17:5'h14];
  assign T430 = {reg_imem_protection_7, reg_imem_protection_6};
  assign T664 = reset ? 4'hc : T431;
  assign T431 = T415 ? T432 : reg_imem_protection_6;
  assign T432 = data_in[5'h1b:5'h18];
  assign T665 = reset ? 4'hc : T433;
  assign T433 = T415 ? T434 : reg_imem_protection_7;
  assign T434 = data_in[5'h1f:5'h1c];
  assign T435 = io_rw_addr == 12'h505;
  assign T666 = {4'h0, T436};
  assign T436 = T437;
  assign T437 = {T451, T438};
  assign T438 = {T446, T439};
  assign T439 = {reg_dmem_protection_1, reg_dmem_protection_0};
  assign T667 = reset ? 4'h8 : T440;
  assign T440 = T442 ? T441 : reg_dmem_protection_0;
  assign T441 = data_in[2'h3:1'h0];
  assign T442 = write & T443;
  assign T443 = io_rw_addr == 12'h50c;
  assign T668 = reset ? 4'h8 : T444;
  assign T444 = T442 ? T445 : reg_dmem_protection_1;
  assign T445 = data_in[3'h7:3'h4];
  assign T446 = {reg_dmem_protection_3, reg_dmem_protection_2};
  assign T669 = reset ? 4'h8 : T447;
  assign T447 = T442 ? T448 : reg_dmem_protection_2;
  assign T448 = data_in[4'hb:4'h8];
  assign T670 = reset ? 4'h8 : T449;
  assign T449 = T442 ? T450 : reg_dmem_protection_3;
  assign T450 = data_in[4'hf:4'hc];
  assign T451 = {T457, T452};
  assign T452 = {reg_dmem_protection_5, reg_dmem_protection_4};
  assign T671 = reset ? 4'h8 : T453;
  assign T453 = T442 ? T454 : reg_dmem_protection_4;
  assign T454 = data_in[5'h13:5'h10];
  assign T672 = reset ? 4'h8 : T455;
  assign T455 = T442 ? T456 : reg_dmem_protection_5;
  assign T456 = data_in[5'h17:5'h14];
  assign T457 = {reg_dmem_protection_7, reg_dmem_protection_6};
  assign T673 = reset ? 4'h8 : T458;
  assign T458 = T442 ? T459 : reg_dmem_protection_6;
  assign T459 = data_in[5'h1b:5'h18];
  assign T674 = reset ? 4'h8 : T460;
  assign T460 = T442 ? T461 : reg_dmem_protection_7;
  assign T461 = data_in[5'h1f:5'h1c];
  assign T462 = io_rw_addr == 12'h50c;
  assign T463 = T571 ? T511 : T464;
  assign T464 = T509 ? status_1 : status_0;
  assign status_0 = T465;
  assign T465 = {T480, T466};
  assign T466 = {T479, T467};
  assign T467 = {reg_ie_0, T468};
  assign T468 = {reg_msip_0, 3'h0};
  assign T675 = reset ? 1'h0 : T469;
  assign T469 = io_exception ? 1'h0 : T470;
  assign T470 = T473 ? T471 : reg_ie_0;
  assign T471 = T472;
  assign T472 = data_in[3'h4:3'h4];
  assign T473 = T477 & T474;
  assign T474 = T475[1'h0:1'h0];
  assign T475 = 1'h1 << T476;
  assign T476 = io_rw_thread;
  assign T477 = write & T478;
  assign T478 = io_rw_addr == 12'h50a;
  assign T479 = {reg_ie1_0, reg_prv_0};
  assign T676 = reset ? 2'h3 : reg_prv_0;
  assign T677 = reset ? 1'h0 : reg_ie1_0;
  assign T480 = {5'h10, T481};
  assign T481 = {reg_mtie_0, T482};
  assign T482 = {20'h0, reg_prv1_0};
  assign T678 = reset ? 2'h0 : reg_prv1_0;
  assign T679 = reset ? 1'h0 : T483;
  assign T483 = T491 ? 1'h1 : T484;
  assign T484 = T487 ? T485 : reg_mtie_0;
  assign T485 = T486;
  assign T486 = data_in[5'h1a:5'h1a];
  assign T487 = T477 & T488;
  assign T488 = T489[1'h0:1'h0];
  assign T489 = 1'h1 << T490;
  assign T490 = io_rw_thread;
  assign T491 = T171 & T488;
  assign status_1 = T492;
  assign T492 = {T501, T493};
  assign T493 = {T500, T494};
  assign T494 = {reg_ie_1, T495};
  assign T495 = {reg_msip_1, 3'h0};
  assign T680 = reset ? 1'h0 : T496;
  assign T496 = io_exception ? 1'h0 : T497;
  assign T497 = T498 ? T471 : reg_ie_1;
  assign T498 = T477 & T499;
  assign T499 = T475[1'h1:1'h1];
  assign T500 = {reg_ie1_1, reg_prv_1};
  assign T681 = reset ? 2'h3 : reg_prv_1;
  assign T682 = reset ? 1'h0 : reg_ie1_1;
  assign T501 = {5'h10, T502};
  assign T502 = {reg_mtie_1, T503};
  assign T503 = {20'h0, reg_prv1_1};
  assign T683 = reset ? 2'h0 : reg_prv1_1;
  assign T684 = reset ? 1'h0 : T504;
  assign T504 = T508 ? 1'h1 : T505;
  assign T505 = T506 ? T485 : reg_mtie_1;
  assign T506 = T477 & T507;
  assign T507 = T489[1'h1:1'h1];
  assign T508 = T171 & T507;
  assign T509 = T510[1'h0:1'h0];
  assign T510 = io_rw_thread;
  assign T511 = T570 ? status_3 : status_2;
  assign status_2 = T512;
  assign T512 = {T534, T513};
  assign T513 = {T533, T514};
  assign T514 = {reg_ie_2, T515};
  assign T515 = {reg_msip_2, 3'h0};
  assign T685 = reset ? 1'h0 : T516;
  assign T516 = T528 ? 1'h1 : T517;
  assign T517 = T527 ? 1'h1 : T518;
  assign T518 = T526 ? 1'h1 : T519;
  assign T519 = T525 ? 1'h1 : T520;
  assign T520 = T521 ? T8 : reg_msip_2;
  assign T521 = T477 & T522;
  assign T522 = T523[2'h2:2'h2];
  assign T523 = 1'h1 << T524;
  assign T524 = io_rw_thread;
  assign T525 = io_int_exts_0 & T522;
  assign T526 = io_int_exts_1 & T522;
  assign T527 = io_int_exts_2 & T522;
  assign T528 = io_int_exts_3 & T522;
  assign T686 = reset ? 1'h0 : T529;
  assign T529 = io_exception ? 1'h0 : T530;
  assign T530 = T531 ? T471 : reg_ie_2;
  assign T531 = T477 & T532;
  assign T532 = T475[2'h2:2'h2];
  assign T533 = {reg_ie1_2, reg_prv_2};
  assign T687 = reset ? 2'h3 : reg_prv_2;
  assign T688 = reset ? 1'h0 : reg_ie1_2;
  assign T534 = {5'h10, T535};
  assign T535 = {reg_mtie_2, T536};
  assign T536 = {20'h0, reg_prv1_2};
  assign T689 = reset ? 2'h0 : reg_prv1_2;
  assign T690 = reset ? 1'h0 : T537;
  assign T537 = T541 ? 1'h1 : T538;
  assign T538 = T539 ? T485 : reg_mtie_2;
  assign T539 = T477 & T540;
  assign T540 = T489[2'h2:2'h2];
  assign T541 = T171 & T540;
  assign status_3 = T542;
  assign T542 = {T562, T543};
  assign T543 = {T561, T544};
  assign T544 = {reg_ie_3, T545};
  assign T545 = {reg_msip_3, 3'h0};
  assign T691 = reset ? 1'h0 : T546;
  assign T546 = T556 ? 1'h1 : T547;
  assign T547 = T555 ? 1'h1 : T548;
  assign T548 = T554 ? 1'h1 : T549;
  assign T549 = T553 ? 1'h1 : T550;
  assign T550 = T551 ? T8 : reg_msip_3;
  assign T551 = T477 & T552;
  assign T552 = T523[2'h3:2'h3];
  assign T553 = io_int_exts_0 & T552;
  assign T554 = io_int_exts_1 & T552;
  assign T555 = io_int_exts_2 & T552;
  assign T556 = io_int_exts_3 & T552;
  assign T692 = reset ? 1'h0 : T557;
  assign T557 = io_exception ? 1'h0 : T558;
  assign T558 = T559 ? T471 : reg_ie_3;
  assign T559 = T477 & T560;
  assign T560 = T475[2'h3:2'h3];
  assign T561 = {reg_ie1_3, reg_prv_3};
  assign T693 = reset ? 2'h3 : reg_prv_3;
  assign T694 = reset ? 1'h0 : reg_ie1_3;
  assign T562 = {5'h10, T563};
  assign T563 = {reg_mtie_3, T564};
  assign T564 = {20'h0, reg_prv1_3};
  assign T695 = reset ? 2'h0 : reg_prv1_3;
  assign T696 = reset ? 1'h0 : T565;
  assign T565 = T569 ? 1'h1 : T566;
  assign T566 = T567 ? T485 : reg_mtie_3;
  assign T567 = T477 & T568;
  assign T568 = T489[2'h3:2'h3];
  assign T569 = T171 & T568;
  assign T570 = T510[1'h0:1'h0];
  assign T571 = T510[1'h1:1'h1];
  assign T572 = io_rw_addr == 12'h50a;
  assign T573 = io_rw_csr_type == 2'h3;
  assign T574 = data_out | T697;
  assign T697 = {4'h0, io_rw_data_in};
  assign T575 = io_rw_csr_type == 2'h2;
  assign T576 = T477 & T577;
  assign T577 = T523[1'h0:1'h0];
  assign T578 = io_int_exts_0 & T577;
  assign T579 = io_int_exts_1 & T577;
  assign T580 = io_int_exts_2 & T577;
  assign T581 = io_int_exts_3 & T577;
  assign T698 = reset ? 1'h0 : T582;
  assign T582 = T592 ? 1'h1 : T583;
  assign T583 = T591 ? 1'h1 : T584;
  assign T584 = T590 ? 1'h1 : T585;
  assign T585 = T589 ? 1'h1 : T586;
  assign T586 = T587 ? T8 : reg_msip_1;
  assign T587 = T477 & T588;
  assign T588 = T523[1'h1:1'h1];
  assign T589 = io_int_exts_0 & T588;
  assign T590 = io_int_exts_1 & T588;
  assign T591 = io_int_exts_2 & T588;
  assign T592 = io_int_exts_3 & T588;
  assign T593 = T524[1'h0:1'h0];
  assign T594 = T595 ? reg_msip_3 : reg_msip_2;
  assign T595 = T524[1'h0:1'h0];
  assign T596 = T524[1'h1:1'h1];
  assign T597 = T602 ? T600 : T598;
  assign T598 = T599 ? reg_ie_1 : reg_ie_0;
  assign T599 = T476[1'h0:1'h0];
  assign T600 = T601 ? reg_ie_3 : reg_ie_2;
  assign T601 = T476[1'h0:1'h0];
  assign T602 = T476[1'h1:1'h1];
  assign io_exc_expire = exc_expire;
  assign exc_expire = T122;
  assign io_int_expire = int_expire;
  assign int_expire = T603;
  assign T603 = T597 & T604;
  assign T604 = T606 | T605;
  assign T605 = T171;
  assign T606 = T611 ? T609 : T607;
  assign T607 = T608 ? reg_mtie_1 : reg_mtie_0;
  assign T608 = T490[1'h0:1'h0];
  assign T609 = T610 ? reg_mtie_3 : reg_mtie_2;
  assign T610 = T490[1'h0:1'h0];
  assign T611 = T490[1'h1:1'h1];
  assign io_dmem_protection_0 = reg_dmem_protection_0;
  assign io_dmem_protection_1 = reg_dmem_protection_1;
  assign io_dmem_protection_2 = reg_dmem_protection_2;
  assign io_dmem_protection_3 = reg_dmem_protection_3;
  assign io_dmem_protection_4 = reg_dmem_protection_4;
  assign io_dmem_protection_5 = reg_dmem_protection_5;
  assign io_dmem_protection_6 = reg_dmem_protection_6;
  assign io_dmem_protection_7 = reg_dmem_protection_7;
  assign io_imem_protection_0 = reg_imem_protection_0;
  assign io_imem_protection_1 = reg_imem_protection_1;
  assign io_imem_protection_2 = reg_imem_protection_2;
  assign io_imem_protection_3 = reg_imem_protection_3;
  assign io_imem_protection_4 = reg_imem_protection_4;
  assign io_imem_protection_5 = reg_imem_protection_5;
  assign io_imem_protection_6 = reg_imem_protection_6;
  assign io_imem_protection_7 = reg_imem_protection_7;
  assign io_gpio_out_0 = reg_gpos_0;
  assign io_gpio_out_1 = reg_gpos_1;
  assign io_gpio_out_2 = reg_gpos_2;
  assign io_gpio_out_3 = reg_gpos_3;
  assign io_host_to_host = reg_to_host;
  assign io_expire = T123;
  assign io_evecs_0 = T699;
  assign T699 = reg_evecs_0[5'h1f:1'h0];
  assign io_evecs_1 = T700;
  assign T700 = reg_evecs_1[5'h1f:1'h0];
  assign io_evecs_2 = T701;
  assign T701 = reg_evecs_2[5'h1f:1'h0];
  assign io_evecs_3 = T702;
  assign T702 = reg_evecs_3[5'h1f:1'h0];
  assign io_tmodes_0 = reg_tmodes_0;
  assign io_tmodes_1 = reg_tmodes_1;
  assign io_tmodes_2 = reg_tmodes_2;
  assign io_tmodes_3 = reg_tmodes_3;
  assign io_slots_0 = reg_slots_0;
  assign io_slots_1 = reg_slots_1;
  assign io_slots_2 = reg_slots_2;
  assign io_slots_3 = reg_slots_3;
  assign io_slots_4 = reg_slots_4;
  assign io_slots_5 = reg_slots_5;
  assign io_slots_6 = reg_slots_6;
  assign io_slots_7 = reg_slots_7;
  assign io_rw_data_out = T703;
  assign T703 = data_out[5'h1f:1'h0];

  always @(posedge clk) begin
    if(reset) begin
      reg_msip_0 <= 1'h0;
    end else if(T581) begin
      reg_msip_0 <= 1'h1;
    end else if(T580) begin
      reg_msip_0 <= 1'h1;
    end else if(T579) begin
      reg_msip_0 <= 1'h1;
    end else if(T578) begin
      reg_msip_0 <= 1'h1;
    end else if(T576) begin
      reg_msip_0 <= T8;
    end
    if(reset) begin
      reg_slots_0 <= 4'hf;
    end else if(T42) begin
      reg_slots_0 <= T41;
    end
    if(reset) begin
      reg_slots_1 <= 4'hf;
    end else if(T42) begin
      reg_slots_1 <= T48;
    end
    if(reset) begin
      reg_slots_2 <= 4'hf;
    end else if(T42) begin
      reg_slots_2 <= T51;
    end
    if(reset) begin
      reg_slots_3 <= 4'hf;
    end else if(T42) begin
      reg_slots_3 <= T53;
    end
    if(reset) begin
      reg_slots_4 <= 4'hf;
    end else if(T42) begin
      reg_slots_4 <= T57;
    end
    if(reset) begin
      reg_slots_5 <= 4'hf;
    end else if(T42) begin
      reg_slots_5 <= T59;
    end
    if(reset) begin
      reg_slots_6 <= 4'hf;
    end else if(T42) begin
      reg_slots_6 <= T62;
    end
    if(reset) begin
      reg_slots_7 <= 4'h0;
    end else if(T42) begin
      reg_slots_7 <= T64;
    end
    if(reset) begin
      reg_tmodes_0 <= 2'h0;
    end else if(wake_0) begin
      reg_tmodes_0 <= T224;
    end else if(T222) begin
      reg_tmodes_0 <= T78;
    end else if(T76) begin
      reg_tmodes_0 <= T75;
    end
    if(reset) begin
      reg_tmodes_2 <= 2'h1;
    end else if(wake_2) begin
      reg_tmodes_2 <= T91;
    end else if(T88) begin
      reg_tmodes_2 <= T78;
    end else if(T76) begin
      reg_tmodes_2 <= T87;
    end
    if(T99) begin
      reg_compare_2 <= T98;
    end
    if(reset) begin
      reg_time <= 64'h0;
    end else begin
      reg_time <= T106;
    end
    if(reset) begin
      reg_timer_2 <= 2'h0;
    end else if(T211) begin
      reg_timer_2 <= 2'h0;
    end else if(T210) begin
      reg_timer_2 <= 2'h2;
    end else if(T121) begin
      reg_timer_2 <= 2'h0;
    end else if(T120) begin
      reg_timer_2 <= 2'h3;
    end else if(T93) begin
      reg_timer_2 <= 2'h0;
    end else if(T119) begin
      reg_timer_2 <= 2'h1;
    end else if(T115) begin
      reg_timer_2 <= 2'h0;
    end
    if(T129) begin
      reg_compare_0 <= T98;
    end
    if(T136) begin
      reg_compare_1 <= T98;
    end
    if(T146) begin
      reg_compare_3 <= T98;
    end
    if(reset) begin
      reg_timer_0 <= 2'h0;
    end else if(T170) begin
      reg_timer_0 <= 2'h0;
    end else if(T169) begin
      reg_timer_0 <= 2'h2;
    end else if(T168) begin
      reg_timer_0 <= 2'h0;
    end else if(T167) begin
      reg_timer_0 <= 2'h3;
    end else if(T165) begin
      reg_timer_0 <= 2'h0;
    end else if(T164) begin
      reg_timer_0 <= 2'h1;
    end else if(T162) begin
      reg_timer_0 <= 2'h0;
    end
    if(reset) begin
      reg_timer_1 <= 2'h0;
    end else if(T189) begin
      reg_timer_1 <= 2'h0;
    end else if(T188) begin
      reg_timer_1 <= 2'h2;
    end else if(T187) begin
      reg_timer_1 <= 2'h0;
    end else if(T186) begin
      reg_timer_1 <= 2'h3;
    end else if(T184) begin
      reg_timer_1 <= 2'h0;
    end else if(T183) begin
      reg_timer_1 <= 2'h1;
    end else if(T181) begin
      reg_timer_1 <= 2'h0;
    end
    if(reset) begin
      reg_timer_3 <= 2'h0;
    end else if(T207) begin
      reg_timer_3 <= 2'h0;
    end else if(T206) begin
      reg_timer_3 <= 2'h2;
    end else if(T205) begin
      reg_timer_3 <= 2'h0;
    end else if(T204) begin
      reg_timer_3 <= 2'h3;
    end else if(T202) begin
      reg_timer_3 <= 2'h0;
    end else if(T201) begin
      reg_timer_3 <= 2'h1;
    end else if(T199) begin
      reg_timer_3 <= 2'h0;
    end
    if(reset) begin
      reg_tmodes_3 <= 2'h1;
    end else if(wake_3) begin
      reg_tmodes_3 <= T218;
    end else if(T216) begin
      reg_tmodes_3 <= T78;
    end else if(T76) begin
      reg_tmodes_3 <= T215;
    end
    if(reset) begin
      reg_tmodes_1 <= 2'h1;
    end else if(wake_1) begin
      reg_tmodes_1 <= T232;
    end else if(T230) begin
      reg_tmodes_1 <= T78;
    end else if(T76) begin
      reg_tmodes_1 <= T229;
    end
    if(T239) begin
      reg_evecs_0 <= data_in;
    end
    if(T246) begin
      reg_evecs_1 <= data_in;
    end
    if(T251) begin
      reg_evecs_2 <= data_in;
    end
    if(T254) begin
      reg_evecs_3 <= data_in;
    end
    if(T262) begin
      reg_epcs_0 <= io_epc;
    end
    if(T267) begin
      reg_epcs_1 <= io_epc;
    end
    if(T272) begin
      reg_epcs_2 <= io_epc;
    end
    if(T275) begin
      reg_epcs_3 <= io_epc;
    end
    if(T286) begin
      reg_causes_0 <= io_cause;
    end
    if(T291) begin
      reg_causes_1 <= io_cause;
    end
    if(T296) begin
      reg_causes_2 <= io_cause;
    end
    if(T299) begin
      reg_causes_3 <= io_cause;
    end
    if(T308) begin
      reg_sup0_0 <= data_in;
    end
    if(T315) begin
      reg_sup0_1 <= data_in;
    end
    if(T320) begin
      reg_sup0_2 <= data_in;
    end
    if(T323) begin
      reg_sup0_3 <= data_in;
    end
    reg_to_host <= T637;
    reg_gpis_0 <= io_gpio_in_0;
    reg_gpis_1 <= io_gpio_in_1;
    reg_gpis_2 <= io_gpio_in_2;
    reg_gpis_3 <= io_gpio_in_3;
    if(reset) begin
      reg_gpos_0 <= 2'h0;
    end else if(T345) begin
      reg_gpos_0 <= T344;
    end
    if(reset) begin
      reg_gpo_protection_0 <= 4'h0;
    end else if(T350) begin
      reg_gpo_protection_0 <= T349;
    end
    if(reset) begin
      reg_gpos_1 <= 2'h0;
    end else if(T362) begin
      reg_gpos_1 <= T361;
    end
    if(reset) begin
      reg_gpo_protection_1 <= 4'h8;
    end else if(T350) begin
      reg_gpo_protection_1 <= T366;
    end
    if(reset) begin
      reg_gpos_2 <= 2'h0;
    end else if(T377) begin
      reg_gpos_2 <= T376;
    end
    if(reset) begin
      reg_gpo_protection_2 <= 4'h8;
    end else if(T350) begin
      reg_gpo_protection_2 <= T381;
    end
    if(reset) begin
      reg_gpos_3 <= 2'h0;
    end else if(T392) begin
      reg_gpos_3 <= T391;
    end
    if(reset) begin
      reg_gpo_protection_3 <= 4'h8;
    end else if(T350) begin
      reg_gpo_protection_3 <= T396;
    end
    if(reset) begin
      reg_imem_protection_0 <= 4'h8;
    end else if(T415) begin
      reg_imem_protection_0 <= T414;
    end
    if(reset) begin
      reg_imem_protection_1 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_1 <= T418;
    end
    if(reset) begin
      reg_imem_protection_2 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_2 <= T421;
    end
    if(reset) begin
      reg_imem_protection_3 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_3 <= T423;
    end
    if(reset) begin
      reg_imem_protection_4 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_4 <= T427;
    end
    if(reset) begin
      reg_imem_protection_5 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_5 <= T429;
    end
    if(reset) begin
      reg_imem_protection_6 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_6 <= T432;
    end
    if(reset) begin
      reg_imem_protection_7 <= 4'hc;
    end else if(T415) begin
      reg_imem_protection_7 <= T434;
    end
    if(reset) begin
      reg_dmem_protection_0 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_0 <= T441;
    end
    if(reset) begin
      reg_dmem_protection_1 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_1 <= T445;
    end
    if(reset) begin
      reg_dmem_protection_2 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_2 <= T448;
    end
    if(reset) begin
      reg_dmem_protection_3 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_3 <= T450;
    end
    if(reset) begin
      reg_dmem_protection_4 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_4 <= T454;
    end
    if(reset) begin
      reg_dmem_protection_5 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_5 <= T456;
    end
    if(reset) begin
      reg_dmem_protection_6 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_6 <= T459;
    end
    if(reset) begin
      reg_dmem_protection_7 <= 4'h8;
    end else if(T442) begin
      reg_dmem_protection_7 <= T461;
    end
    if(reset) begin
      reg_ie_0 <= 1'h0;
    end else if(io_exception) begin
      reg_ie_0 <= 1'h0;
    end else if(T473) begin
      reg_ie_0 <= T471;
    end
    if(reset) begin
      reg_prv_0 <= 2'h3;
    end
    if(reset) begin
      reg_ie1_0 <= 1'h0;
    end
    if(reset) begin
      reg_prv1_0 <= 2'h0;
    end
    if(reset) begin
      reg_mtie_0 <= 1'h0;
    end else if(T491) begin
      reg_mtie_0 <= 1'h1;
    end else if(T487) begin
      reg_mtie_0 <= T485;
    end
    if(reset) begin
      reg_ie_1 <= 1'h0;
    end else if(io_exception) begin
      reg_ie_1 <= 1'h0;
    end else if(T498) begin
      reg_ie_1 <= T471;
    end
    if(reset) begin
      reg_prv_1 <= 2'h3;
    end
    if(reset) begin
      reg_ie1_1 <= 1'h0;
    end
    if(reset) begin
      reg_prv1_1 <= 2'h0;
    end
    if(reset) begin
      reg_mtie_1 <= 1'h0;
    end else if(T508) begin
      reg_mtie_1 <= 1'h1;
    end else if(T506) begin
      reg_mtie_1 <= T485;
    end
    if(reset) begin
      reg_msip_2 <= 1'h0;
    end else if(T528) begin
      reg_msip_2 <= 1'h1;
    end else if(T527) begin
      reg_msip_2 <= 1'h1;
    end else if(T526) begin
      reg_msip_2 <= 1'h1;
    end else if(T525) begin
      reg_msip_2 <= 1'h1;
    end else if(T521) begin
      reg_msip_2 <= T8;
    end
    if(reset) begin
      reg_ie_2 <= 1'h0;
    end else if(io_exception) begin
      reg_ie_2 <= 1'h0;
    end else if(T531) begin
      reg_ie_2 <= T471;
    end
    if(reset) begin
      reg_prv_2 <= 2'h3;
    end
    if(reset) begin
      reg_ie1_2 <= 1'h0;
    end
    if(reset) begin
      reg_prv1_2 <= 2'h0;
    end
    if(reset) begin
      reg_mtie_2 <= 1'h0;
    end else if(T541) begin
      reg_mtie_2 <= 1'h1;
    end else if(T539) begin
      reg_mtie_2 <= T485;
    end
    if(reset) begin
      reg_msip_3 <= 1'h0;
    end else if(T556) begin
      reg_msip_3 <= 1'h1;
    end else if(T555) begin
      reg_msip_3 <= 1'h1;
    end else if(T554) begin
      reg_msip_3 <= 1'h1;
    end else if(T553) begin
      reg_msip_3 <= 1'h1;
    end else if(T551) begin
      reg_msip_3 <= T8;
    end
    if(reset) begin
      reg_ie_3 <= 1'h0;
    end else if(io_exception) begin
      reg_ie_3 <= 1'h0;
    end else if(T559) begin
      reg_ie_3 <= T471;
    end
    if(reset) begin
      reg_prv_3 <= 2'h3;
    end
    if(reset) begin
      reg_ie1_3 <= 1'h0;
    end
    if(reset) begin
      reg_prv1_3 <= 2'h0;
    end
    if(reset) begin
      reg_mtie_3 <= 1'h0;
    end else if(T569) begin
      reg_mtie_3 <= 1'h1;
    end else if(T567) begin
      reg_mtie_3 <= T485;
    end
    if(reset) begin
      reg_msip_1 <= 1'h0;
    end else if(T592) begin
      reg_msip_1 <= 1'h1;
    end else if(T591) begin
      reg_msip_1 <= 1'h1;
    end else if(T590) begin
      reg_msip_1 <= 1'h1;
    end else if(T589) begin
      reg_msip_1 <= 1'h1;
    end else if(T587) begin
      reg_msip_1 <= T8;
    end
  end
endmodule

module Datapath(input clk, input reset,
    input [2:0] io_control_dec_imm_sel,
    input [1:0] io_control_dec_op1_sel,
    input [1:0] io_control_dec_op2_sel,
    input [3:0] io_control_exe_alu_type,
    input [2:0] io_control_exe_br_type,
    input [1:0] io_control_exe_csr_type,
    input [1:0] io_control_exe_mul_type,
    input [1:0] io_control_exe_rd_data_sel,
    input [3:0] io_control_exe_mem_type,
    input [1:0] io_control_mem_rd_data_sel,
    input [1:0] io_control_next_pc_sel_3,
    input [1:0] io_control_next_pc_sel_2,
    input [1:0] io_control_next_pc_sel_1,
    input [1:0] io_control_next_pc_sel_0,
    input [1:0] io_control_next_tid,
    input  io_control_next_valid,
    input [1:0] io_control_dec_rs1_sel,
    input [1:0] io_control_dec_rs2_sel,
    input  io_control_exe_valid,
    input  io_control_exe_load,
    input  io_control_exe_store,
    input  io_control_exe_csr_write,
    input  io_control_exe_exception,
    input [4:0] io_control_exe_cause,
    input  io_control_exe_kill,
    input  io_control_exe_sleep,
    input  io_control_exe_ie,
    input  io_control_exe_ee,
    input  io_control_exe_sret,
    input  io_control_exe_cycle,
    input  io_control_exe_instret,
    input  io_control_mem_rd_write,
    output[1:0] io_control_if_tid,
    output[1:0] io_control_dec_tid,
    output[31:0] io_control_dec_inst,
    output io_control_exe_br_cond,
    output[1:0] io_control_exe_tid,
    output[4:0] io_control_exe_rd_addr,
    output io_control_exe_expire,
    output[3:0] io_control_csr_slots_7,
    output[3:0] io_control_csr_slots_6,
    output[3:0] io_control_csr_slots_5,
    output[3:0] io_control_csr_slots_4,
    output[3:0] io_control_csr_slots_3,
    output[3:0] io_control_csr_slots_2,
    output[3:0] io_control_csr_slots_1,
    output[3:0] io_control_csr_slots_0,
    output[1:0] io_control_csr_tmodes_3,
    output[1:0] io_control_csr_tmodes_2,
    output[1:0] io_control_csr_tmodes_1,
    output[1:0] io_control_csr_tmodes_0,
    output[1:0] io_control_mem_tid,
    output[4:0] io_control_mem_rd_addr,
    output[1:0] io_control_wb_tid,
    output[4:0] io_control_wb_rd_addr,
    output io_control_if_exc_misaligned,
    output io_control_if_exc_fault,
    output io_control_exe_exc_priv_inst,
    output io_control_exe_exc_load_misaligned,
    output io_control_exe_exc_load_fault,
    output io_control_exe_exc_store_misaligned,
    output io_control_exe_exc_store_fault,
    output io_control_exe_exc_expire,
    output io_control_exe_int_expire,
    output io_control_exe_int_ext,
    output[11:0] io_imem_r_addr,
    output io_imem_r_enable,
    input [31:0] io_imem_r_data_out,
    output[11:0] io_imem_rw_addr,
    output io_imem_rw_enable,
    input [31:0] io_imem_rw_data_out,
    output io_imem_rw_write,
    output[31:0] io_imem_rw_data_in,
    output[11:0] io_dmem_addr,
    output io_dmem_enable,
    input [31:0] io_dmem_data_out,
    output io_dmem_byte_write_3,
    output io_dmem_byte_write_2,
    output io_dmem_byte_write_1,
    output io_dmem_byte_write_0,
    output[31:0] io_dmem_data_in,
    output[9:0] io_bus_addr,
    output io_bus_enable,
    input [31:0] io_bus_data_out,
    output io_bus_write,
    output[31:0] io_bus_data_in,
    output[31:0] io_host_to_host,
    input  io_gpio_in_3,
    input  io_gpio_in_2,
    input  io_gpio_in_1,
    input  io_gpio_in_0,
    output[1:0] io_gpio_out_3,
    output[1:0] io_gpio_out_2,
    output[1:0] io_gpio_out_1,
    output[1:0] io_gpio_out_0,
    input  io_int_exts_3,
    input  io_int_exts_2,
    input  io_int_exts_1,
    input  io_int_exts_0
);

  reg [1:0] dec_reg_tid;
  reg [1:0] if_reg_tid;
  reg [31:0] exe_reg_pc;
  reg [31:0] dec_reg_pc;
  reg [31:0] if_reg_pc;
  wire[31:0] next_pc;
  wire[31:0] T0;
  wire[31:0] next_pcs_0;
  wire[31:0] T1;
  wire[31:0] T2;
  wire[31:0] T3;
  reg [31:0] if_reg_pcs_0;
  wire[31:0] T4;
  wire[31:0] T206;
  wire[31:0] if_pc_plus4;
  wire[31:0] T5;
  wire T6;
  wire T7;
  wire[3:0] T8;
  wire[1:0] T9;
  wire T10;
  wire[1:0] T11;
  wire[1:0] T12;
  wire T13;
  wire[1:0] T14;
  wire[1:0] T15;
  wire T16;
  wire T17;
  wire[31:0] exe_address;
  wire[31:0] exe_alu_result;
  wire[31:0] T18;
  wire[31:0] T19;
  wire[31:0] T20;
  wire[31:0] T21;
  wire[31:0] T22;
  wire[31:0] T23;
  wire[31:0] T24;
  wire[31:0] T25;
  wire[31:0] T26;
  wire[31:0] T27;
  wire[31:0] def_exe_alu_result;
  reg [31:0] exe_reg_op2;
  wire[31:0] dec_op2;
  wire[31:0] T28;
  wire[31:0] dec_imm;
  wire[31:0] T29;
  wire[31:0] T30;
  wire[31:0] T31;
  wire[31:0] T32;
  wire[31:0] T33;
  wire[31:0] dec_imm_z;
  wire[4:0] T34;
  reg [31:0] dec_reg_inst;
  wire T35;
  wire[31:0] dec_imm_i;
  wire[10:0] T36;
  wire[20:0] T37;
  wire[20:0] T207;
  wire T38;
  wire T39;
  wire[31:0] dec_imm_j;
  wire[11:0] T40;
  wire[10:0] T41;
  wire[9:0] T42;
  wire T43;
  wire[19:0] T44;
  wire[7:0] T45;
  wire[11:0] T46;
  wire[11:0] T208;
  wire T47;
  wire T48;
  wire[31:0] dec_imm_u;
  wire[19:0] T49;
  wire T50;
  wire[31:0] dec_imm_b;
  wire[10:0] T51;
  wire[4:0] T52;
  wire[3:0] T53;
  wire[5:0] T54;
  wire[20:0] T55;
  wire T56;
  wire[19:0] T57;
  wire[19:0] T209;
  wire T58;
  wire T59;
  wire[31:0] dec_imm_s;
  wire[10:0] T60;
  wire[4:0] T61;
  wire[5:0] T62;
  wire[20:0] T63;
  wire[20:0] T210;
  wire T64;
  wire T65;
  wire T66;
  wire[31:0] dec_rs2_data;
  wire[31:0] T67;
  wire[31:0] T68;
  wire[31:0] T69;
  wire[31:0] wb_rd_data;
  reg [31:0] wb_reg_rd_data;
  wire T70;
  wire[31:0] mem_rd_data;
  wire[31:0] T71;
  wire[31:0] T72;
  reg [31:0] mem_reg_rd_data;
  wire[31:0] mem_mul_result;
  wire T73;
  wire T74;
  wire T75;
  wire[31:0] exe_rd_data;
  wire[31:0] T76;
  wire[31:0] T77;
  reg [31:0] exe_reg_pc4;
  reg [31:0] dec_reg_pc4;
  wire T78;
  wire T79;
  wire T80;
  wire T81;
  reg [31:0] exe_reg_op1;
  wire[31:0] dec_op1;
  wire[31:0] T82;
  wire T83;
  wire[31:0] dec_rs1_data;
  wire[31:0] T84;
  wire[31:0] T85;
  wire[31:0] T86;
  wire T87;
  wire T88;
  wire T89;
  wire T90;
  wire[31:0] T91;
  wire[4:0] exe_alu_shift;
  wire[31:0] T92;
  wire T93;
  wire[31:0] T211;
  wire T94;
  wire T95;
  wire[31:0] T212;
  wire T96;
  wire[31:0] T97;
  wire[31:0] T98;
  wire T99;
  wire[31:0] T100;
  wire T101;
  wire[31:0] T102;
  wire T103;
  wire[31:0] T104;
  wire T105;
  wire[31:0] T106;
  wire T107;
  wire[31:0] T108;
  wire T109;
  wire[31:0] T110;
  wire[62:0] T111;
  wire T112;
  wire[31:0] T113;
  wire T114;
  wire T115;
  wire T116;
  wire[3:0] T117;
  wire[1:0] T118;
  reg [1:0] exe_reg_tid;
  wire T119;
  wire[1:0] T120;
  wire[1:0] T121;
  wire T122;
  wire[1:0] T123;
  wire[1:0] T124;
  wire T125;
  wire T126;
  wire[31:0] mem_evec;
  wire[31:0] T127;
  wire[31:0] T128;
  wire T129;
  wire[1:0] T130;
  reg [1:0] mem_reg_tid;
  wire[31:0] T131;
  wire T132;
  wire T133;
  wire T134;
  wire T135;
  wire[3:0] T136;
  wire[1:0] T137;
  wire T138;
  wire[1:0] T139;
  wire[1:0] T140;
  wire T141;
  wire[1:0] T142;
  wire[1:0] T143;
  wire T144;
  wire T145;
  wire[31:0] next_pcs_1;
  wire[31:0] T146;
  wire[31:0] T147;
  wire[31:0] T148;
  reg [31:0] if_reg_pcs_1;
  wire[31:0] T149;
  wire[31:0] T213;
  wire T150;
  wire T151;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  wire T156;
  wire[1:0] T157;
  wire[31:0] T158;
  wire[31:0] next_pcs_2;
  wire[31:0] T159;
  wire[31:0] T160;
  wire[31:0] T161;
  reg [31:0] if_reg_pcs_2;
  wire[31:0] T162;
  wire[31:0] T214;
  wire T163;
  wire T164;
  wire T165;
  wire T166;
  wire T167;
  wire T168;
  wire[31:0] next_pcs_3;
  wire[31:0] T169;
  wire[31:0] T170;
  wire[31:0] T171;
  reg [31:0] if_reg_pcs_3;
  wire[31:0] T172;
  wire[31:0] T215;
  wire T173;
  wire T174;
  wire T175;
  wire T176;
  wire T177;
  wire T178;
  wire T179;
  wire T180;
  reg [31:0] exe_csr_data;
  wire[31:0] dec_csr_data;
  wire T181;
  reg [11:0] exe_reg_csr_addr;
  wire[11:0] T182;
  reg [31:0] exe_reg_rs2_data;
  reg [4:0] mem_reg_rd_addr;
  reg [4:0] exe_reg_rd_addr;
  wire[4:0] T183;
  wire[4:0] T184;
  wire[4:0] T185;
  wire[11:0] T216;
  wire[29:0] T186;
  wire T187;
  wire[1:0] T188;
  reg [4:0] wb_reg_rd_addr;
  reg [1:0] wb_reg_tid;
  wire exe_br_cond;
  wire T189;
  wire T190;
  wire T191;
  wire T192;
  wire T193;
  wire T194;
  wire T195;
  wire T196;
  wire T197;
  wire T198;
  wire T199;
  wire T200;
  wire exe_ltu;
  reg [31:0] exe_reg_rs1_data;
  wire T201;
  wire exe_lt;
  wire[31:0] T202;
  wire[31:0] T203;
  wire T204;
  wire exe_eq;
  wire T205;
  wire[31:0] regfile_io_rs1_data;
  wire[31:0] regfile_io_rs2_data;
  wire[11:0] loadstore_io_dmem_addr;
  wire loadstore_io_dmem_enable;
  wire loadstore_io_dmem_byte_write_3;
  wire loadstore_io_dmem_byte_write_2;
  wire loadstore_io_dmem_byte_write_1;
  wire loadstore_io_dmem_byte_write_0;
  wire[31:0] loadstore_io_dmem_data_in;
  wire[11:0] loadstore_io_imem_rw_addr;
  wire loadstore_io_imem_rw_enable;
  wire loadstore_io_imem_rw_write;
  wire[31:0] loadstore_io_imem_rw_data_in;
  wire[9:0] loadstore_io_bus_addr;
  wire loadstore_io_bus_enable;
  wire loadstore_io_bus_write;
  wire[31:0] loadstore_io_bus_data_in;
  wire[31:0] loadstore_io_data_out;
  wire loadstore_io_load_misaligned;
  wire loadstore_io_load_fault;
  wire loadstore_io_store_misaligned;
  wire loadstore_io_store_fault;
  wire[31:0] csr_io_rw_data_out;
  wire[3:0] csr_io_slots_7;
  wire[3:0] csr_io_slots_6;
  wire[3:0] csr_io_slots_5;
  wire[3:0] csr_io_slots_4;
  wire[3:0] csr_io_slots_3;
  wire[3:0] csr_io_slots_2;
  wire[3:0] csr_io_slots_1;
  wire[3:0] csr_io_slots_0;
  wire[1:0] csr_io_tmodes_3;
  wire[1:0] csr_io_tmodes_2;
  wire[1:0] csr_io_tmodes_1;
  wire[1:0] csr_io_tmodes_0;
  wire[31:0] csr_io_evecs_3;
  wire[31:0] csr_io_evecs_2;
  wire[31:0] csr_io_evecs_1;
  wire[31:0] csr_io_evecs_0;
  wire csr_io_expire;
  wire[31:0] csr_io_host_to_host;
  wire[1:0] csr_io_gpio_out_3;
  wire[1:0] csr_io_gpio_out_2;
  wire[1:0] csr_io_gpio_out_1;
  wire[1:0] csr_io_gpio_out_0;
  wire[3:0] csr_io_imem_protection_7;
  wire[3:0] csr_io_imem_protection_6;
  wire[3:0] csr_io_imem_protection_5;
  wire[3:0] csr_io_imem_protection_4;
  wire[3:0] csr_io_imem_protection_3;
  wire[3:0] csr_io_imem_protection_2;
  wire[3:0] csr_io_imem_protection_1;
  wire[3:0] csr_io_imem_protection_0;
  wire[3:0] csr_io_dmem_protection_7;
  wire[3:0] csr_io_dmem_protection_6;
  wire[3:0] csr_io_dmem_protection_5;
  wire[3:0] csr_io_dmem_protection_4;
  wire[3:0] csr_io_dmem_protection_3;
  wire[3:0] csr_io_dmem_protection_2;
  wire[3:0] csr_io_dmem_protection_1;
  wire[3:0] csr_io_dmem_protection_0;
  wire csr_io_int_expire;
  wire csr_io_exc_expire;
  wire csr_io_int_ext;
  wire csr_io_priv_fault;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    dec_reg_tid = {1{$random}};
    if_reg_tid = {1{$random}};
    exe_reg_pc = {1{$random}};
    dec_reg_pc = {1{$random}};
    if_reg_pc = {1{$random}};
    if_reg_pcs_0 = {1{$random}};
    exe_reg_op2 = {1{$random}};
    dec_reg_inst = {1{$random}};
    wb_reg_rd_data = {1{$random}};
    mem_reg_rd_data = {1{$random}};
    exe_reg_pc4 = {1{$random}};
    dec_reg_pc4 = {1{$random}};
    exe_reg_op1 = {1{$random}};
    exe_reg_tid = {1{$random}};
    mem_reg_tid = {1{$random}};
    if_reg_pcs_1 = {1{$random}};
    if_reg_pcs_2 = {1{$random}};
    if_reg_pcs_3 = {1{$random}};
    exe_csr_data = {1{$random}};
    exe_reg_csr_addr = {1{$random}};
    exe_reg_rs2_data = {1{$random}};
    mem_reg_rd_addr = {1{$random}};
    exe_reg_rd_addr = {1{$random}};
    wb_reg_rd_addr = {1{$random}};
    wb_reg_tid = {1{$random}};
    exe_reg_rs1_data = {1{$random}};
  end
// synthesis translate_on
`endif

  assign next_pc = T180 ? T158 : T0;
  assign T0 = T156 ? next_pcs_1 : next_pcs_0;
  assign next_pcs_0 = T1;
  assign T1 = T134 ? mem_evec : T2;
  assign T2 = T115 ? exe_address : T3;
  assign T3 = T6 ? if_pc_plus4 : if_reg_pcs_0;
  assign T4 = 32'h0;
  assign T206 = reset ? T4 : next_pcs_0;
  assign if_pc_plus4 = T5;
  assign T5 = if_reg_pc + 32'h4;
  assign T6 = T10 & T7;
  assign T7 = T8[1'h0:1'h0];
  assign T8 = 1'h1 << T9;
  assign T9 = if_reg_tid;
  assign T10 = T11 == 2'h1;
  assign T11 = T17 ? T15 : T12;
  assign T12 = T13 ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0;
  assign T13 = T14[1'h0:1'h0];
  assign T14 = if_reg_tid;
  assign T15 = T16 ? io_control_next_pc_sel_3 : io_control_next_pc_sel_2;
  assign T16 = T14[1'h0:1'h0];
  assign T17 = T14[1'h1:1'h1];
  assign exe_address = exe_alu_result;
  assign exe_alu_result = T18;
  assign T18 = T114 ? T113 : T19;
  assign T19 = T112 ? T110 : T20;
  assign T20 = T109 ? T108 : T21;
  assign T21 = T107 ? T106 : T22;
  assign T22 = T105 ? T104 : T23;
  assign T23 = T103 ? T102 : T24;
  assign T24 = T101 ? T100 : T25;
  assign T25 = T99 ? T212 : T26;
  assign T26 = T95 ? T211 : T27;
  assign T27 = T93 ? T91 : def_exe_alu_result;
  assign def_exe_alu_result = exe_reg_op1 + exe_reg_op2;
  assign dec_op2 = T81 ? dec_rs2_data : T28;
  assign T28 = T66 ? dec_imm : 32'h0;
  assign dec_imm = T65 ? dec_imm_s : T29;
  assign T29 = T59 ? dec_imm_b : T30;
  assign T30 = T50 ? dec_imm_u : T31;
  assign T31 = T48 ? dec_imm_j : T32;
  assign T32 = T39 ? dec_imm_i : T33;
  assign T33 = T35 ? dec_imm_z : dec_imm_i;
  assign dec_imm_z = {27'h0, T34};
  assign T34 = dec_reg_inst[5'h13:4'hf];
  assign T35 = io_control_dec_imm_sel == 3'h5;
  assign dec_imm_i = {T37, T36};
  assign T36 = dec_reg_inst[5'h1e:5'h14];
  assign T37 = 21'h0 - T207;
  assign T207 = {20'h0, T38};
  assign T38 = dec_reg_inst[5'h1f:5'h1f];
  assign T39 = io_control_dec_imm_sel == 3'h4;
  assign dec_imm_j = {T44, T40};
  assign T40 = {T43, T41};
  assign T41 = {T42, 1'h0};
  assign T42 = dec_reg_inst[5'h1e:5'h15];
  assign T43 = dec_reg_inst[5'h14:5'h14];
  assign T44 = {T46, T45};
  assign T45 = dec_reg_inst[5'h13:4'hc];
  assign T46 = 12'h0 - T208;
  assign T208 = {11'h0, T47};
  assign T47 = dec_reg_inst[5'h1f:5'h1f];
  assign T48 = io_control_dec_imm_sel == 3'h3;
  assign dec_imm_u = {T49, 12'h0};
  assign T49 = dec_reg_inst[5'h1f:4'hc];
  assign T50 = io_control_dec_imm_sel == 3'h2;
  assign dec_imm_b = {T55, T51};
  assign T51 = {T54, T52};
  assign T52 = {T53, 1'h0};
  assign T53 = dec_reg_inst[4'hb:4'h8];
  assign T54 = dec_reg_inst[5'h1e:5'h19];
  assign T55 = {T57, T56};
  assign T56 = dec_reg_inst[3'h7:3'h7];
  assign T57 = 20'h0 - T209;
  assign T209 = {19'h0, T58};
  assign T58 = dec_reg_inst[5'h1f:5'h1f];
  assign T59 = io_control_dec_imm_sel == 3'h1;
  assign dec_imm_s = {T63, T60};
  assign T60 = {T62, T61};
  assign T61 = dec_reg_inst[4'hb:3'h7];
  assign T62 = dec_reg_inst[5'h1e:5'h19];
  assign T63 = 21'h0 - T210;
  assign T210 = {20'h0, T64};
  assign T64 = dec_reg_inst[5'h1f:5'h1f];
  assign T65 = io_control_dec_imm_sel == 3'h0;
  assign T66 = io_control_dec_op2_sel == 2'h0;
  assign dec_rs2_data = T67;
  assign T67 = T80 ? exe_rd_data : T68;
  assign T68 = T75 ? mem_rd_data : T69;
  assign T69 = T70 ? wb_rd_data : regfile_io_rs2_data;
  assign wb_rd_data = wb_reg_rd_data;
  assign T70 = io_control_dec_rs2_sel == 2'h3;
  assign mem_rd_data = T71;
  assign T71 = T74 ? loadstore_io_data_out : T72;
  assign T72 = T73 ? mem_mul_result : mem_reg_rd_data;
  assign mem_mul_result = mem_reg_rd_data;
  assign T73 = io_control_mem_rd_data_sel == 2'h2;
  assign T74 = io_control_mem_rd_data_sel == 2'h1;
  assign T75 = io_control_dec_rs2_sel == 2'h2;
  assign exe_rd_data = T76;
  assign T76 = T79 ? csr_io_rw_data_out : T77;
  assign T77 = T78 ? exe_reg_pc4 : exe_alu_result;
  assign T78 = io_control_exe_rd_data_sel == 2'h2;
  assign T79 = io_control_exe_rd_data_sel == 2'h1;
  assign T80 = io_control_dec_rs2_sel == 2'h1;
  assign T81 = io_control_dec_op2_sel == 2'h1;
  assign dec_op1 = T90 ? dec_rs1_data : T82;
  assign T82 = T83 ? dec_reg_pc : 32'h0;
  assign T83 = io_control_dec_op1_sel == 2'h0;
  assign dec_rs1_data = T84;
  assign T84 = T89 ? exe_rd_data : T85;
  assign T85 = T88 ? mem_rd_data : T86;
  assign T86 = T87 ? wb_rd_data : regfile_io_rs1_data;
  assign T87 = io_control_dec_rs1_sel == 2'h3;
  assign T88 = io_control_dec_rs1_sel == 2'h2;
  assign T89 = io_control_dec_rs1_sel == 2'h1;
  assign T90 = io_control_dec_op1_sel == 2'h1;
  assign T91 = $signed(T92) >>> exe_alu_shift;
  assign exe_alu_shift = exe_reg_op2[3'h4:1'h0];
  assign T92 = exe_reg_op1;
  assign T93 = io_control_exe_alu_type == 4'hd;
  assign T211 = {31'h0, T94};
  assign T94 = exe_reg_op1 < exe_reg_op2;
  assign T95 = io_control_exe_alu_type == 4'hb;
  assign T212 = {31'h0, T96};
  assign T96 = $signed(T98) < $signed(T97);
  assign T97 = exe_reg_op2;
  assign T98 = exe_reg_op1;
  assign T99 = io_control_exe_alu_type == 4'ha;
  assign T100 = exe_reg_op1 - exe_reg_op2;
  assign T101 = io_control_exe_alu_type == 4'h8;
  assign T102 = exe_reg_op1 & exe_reg_op2;
  assign T103 = io_control_exe_alu_type == 4'h7;
  assign T104 = exe_reg_op1 | exe_reg_op2;
  assign T105 = io_control_exe_alu_type == 4'h6;
  assign T106 = exe_reg_op1 >> exe_alu_shift;
  assign T107 = io_control_exe_alu_type == 4'h5;
  assign T108 = exe_reg_op1 ^ exe_reg_op2;
  assign T109 = io_control_exe_alu_type == 4'h4;
  assign T110 = T111[5'h1f:1'h0];
  assign T111 = exe_reg_op1 << exe_alu_shift;
  assign T112 = io_control_exe_alu_type == 4'h1;
  assign T113 = exe_reg_op1 + exe_reg_op2;
  assign T114 = io_control_exe_alu_type == 4'h0;
  assign T115 = T119 & T116;
  assign T116 = T117[1'h0:1'h0];
  assign T117 = 1'h1 << T118;
  assign T118 = exe_reg_tid;
  assign T119 = T120 == 2'h2;
  assign T120 = T126 ? T124 : T121;
  assign T121 = T122 ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0;
  assign T122 = T123[1'h0:1'h0];
  assign T123 = exe_reg_tid;
  assign T124 = T125 ? io_control_next_pc_sel_3 : io_control_next_pc_sel_2;
  assign T125 = T123[1'h0:1'h0];
  assign T126 = T123[1'h1:1'h1];
  assign mem_evec = T127;
  assign T127 = T133 ? T131 : T128;
  assign T128 = T129 ? csr_io_evecs_1 : csr_io_evecs_0;
  assign T129 = T130[1'h0:1'h0];
  assign T130 = mem_reg_tid;
  assign T131 = T132 ? csr_io_evecs_3 : csr_io_evecs_2;
  assign T132 = T130[1'h0:1'h0];
  assign T133 = T130[1'h1:1'h1];
  assign T134 = T138 & T135;
  assign T135 = T136[1'h0:1'h0];
  assign T136 = 1'h1 << T137;
  assign T137 = mem_reg_tid;
  assign T138 = T139 == 2'h3;
  assign T139 = T145 ? T143 : T140;
  assign T140 = T141 ? io_control_next_pc_sel_1 : io_control_next_pc_sel_0;
  assign T141 = T142[1'h0:1'h0];
  assign T142 = mem_reg_tid;
  assign T143 = T144 ? io_control_next_pc_sel_3 : io_control_next_pc_sel_2;
  assign T144 = T142[1'h0:1'h0];
  assign T145 = T142[1'h1:1'h1];
  assign next_pcs_1 = T146;
  assign T146 = T154 ? mem_evec : T147;
  assign T147 = T152 ? exe_address : T148;
  assign T148 = T150 ? if_pc_plus4 : if_reg_pcs_1;
  assign T149 = 32'h0;
  assign T213 = reset ? T149 : next_pcs_1;
  assign T150 = T10 & T151;
  assign T151 = T8[1'h1:1'h1];
  assign T152 = T119 & T153;
  assign T153 = T117[1'h1:1'h1];
  assign T154 = T138 & T155;
  assign T155 = T136[1'h1:1'h1];
  assign T156 = T157[1'h0:1'h0];
  assign T157 = io_control_next_tid;
  assign T158 = T179 ? next_pcs_3 : next_pcs_2;
  assign next_pcs_2 = T159;
  assign T159 = T167 ? mem_evec : T160;
  assign T160 = T165 ? exe_address : T161;
  assign T161 = T163 ? if_pc_plus4 : if_reg_pcs_2;
  assign T162 = 32'h0;
  assign T214 = reset ? T162 : next_pcs_2;
  assign T163 = T10 & T164;
  assign T164 = T8[2'h2:2'h2];
  assign T165 = T119 & T166;
  assign T166 = T117[2'h2:2'h2];
  assign T167 = T138 & T168;
  assign T168 = T136[2'h2:2'h2];
  assign next_pcs_3 = T169;
  assign T169 = T177 ? mem_evec : T170;
  assign T170 = T175 ? exe_address : T171;
  assign T171 = T173 ? if_pc_plus4 : if_reg_pcs_3;
  assign T172 = 32'h0;
  assign T215 = reset ? T172 : next_pcs_3;
  assign T173 = T10 & T174;
  assign T174 = T8[2'h3:2'h3];
  assign T175 = T119 & T176;
  assign T176 = T117[2'h3:2'h3];
  assign T177 = T138 & T178;
  assign T178 = T136[2'h3:2'h3];
  assign T179 = T157[1'h0:1'h0];
  assign T180 = T157[1'h1:1'h1];
  assign dec_csr_data = T181 ? dec_imm : dec_rs1_data;
  assign T181 = io_control_dec_op2_sel == 2'h0;
  assign T182 = dec_reg_inst[5'h1f:5'h14];
  assign T183 = dec_reg_inst[4'hb:3'h7];
  assign T184 = io_imem_r_data_out[5'h18:5'h14];
  assign T185 = io_imem_r_data_out[5'h13:4'hf];
  assign io_gpio_out_0 = csr_io_gpio_out_0;
  assign io_gpio_out_1 = csr_io_gpio_out_1;
  assign io_gpio_out_2 = csr_io_gpio_out_2;
  assign io_gpio_out_3 = csr_io_gpio_out_3;
  assign io_host_to_host = csr_io_host_to_host;
  assign io_bus_data_in = loadstore_io_bus_data_in;
  assign io_bus_write = loadstore_io_bus_write;
  assign io_bus_enable = loadstore_io_bus_enable;
  assign io_bus_addr = loadstore_io_bus_addr;
  assign io_dmem_data_in = loadstore_io_dmem_data_in;
  assign io_dmem_byte_write_0 = loadstore_io_dmem_byte_write_0;
  assign io_dmem_byte_write_1 = loadstore_io_dmem_byte_write_1;
  assign io_dmem_byte_write_2 = loadstore_io_dmem_byte_write_2;
  assign io_dmem_byte_write_3 = loadstore_io_dmem_byte_write_3;
  assign io_dmem_enable = loadstore_io_dmem_enable;
  assign io_dmem_addr = loadstore_io_dmem_addr;
  assign io_imem_rw_data_in = loadstore_io_imem_rw_data_in;
  assign io_imem_rw_write = loadstore_io_imem_rw_write;
  assign io_imem_rw_enable = loadstore_io_imem_rw_enable;
  assign io_imem_rw_addr = loadstore_io_imem_rw_addr;
  assign io_imem_r_enable = io_control_next_valid;
  assign io_imem_r_addr = T216;
  assign T216 = T186[4'hb:1'h0];
  assign T186 = next_pc[5'h1f:2'h2];
  assign io_control_exe_int_ext = csr_io_int_ext;
  assign io_control_exe_int_expire = csr_io_int_expire;
  assign io_control_exe_exc_expire = csr_io_exc_expire;
  assign io_control_exe_exc_store_fault = loadstore_io_store_fault;
  assign io_control_exe_exc_store_misaligned = loadstore_io_store_misaligned;
  assign io_control_exe_exc_load_fault = loadstore_io_load_fault;
  assign io_control_exe_exc_load_misaligned = loadstore_io_load_misaligned;
  assign io_control_exe_exc_priv_inst = csr_io_priv_fault;
  assign io_control_if_exc_fault = 1'h0;
  assign io_control_if_exc_misaligned = T187;
  assign T187 = T188 != 2'h0;
  assign T188 = if_reg_pc[1'h1:1'h0];
  assign io_control_wb_rd_addr = wb_reg_rd_addr;
  assign io_control_wb_tid = wb_reg_tid;
  assign io_control_mem_rd_addr = mem_reg_rd_addr;
  assign io_control_mem_tid = mem_reg_tid;
  assign io_control_csr_tmodes_0 = csr_io_tmodes_0;
  assign io_control_csr_tmodes_1 = csr_io_tmodes_1;
  assign io_control_csr_tmodes_2 = csr_io_tmodes_2;
  assign io_control_csr_tmodes_3 = csr_io_tmodes_3;
  assign io_control_csr_slots_0 = csr_io_slots_0;
  assign io_control_csr_slots_1 = csr_io_slots_1;
  assign io_control_csr_slots_2 = csr_io_slots_2;
  assign io_control_csr_slots_3 = csr_io_slots_3;
  assign io_control_csr_slots_4 = csr_io_slots_4;
  assign io_control_csr_slots_5 = csr_io_slots_5;
  assign io_control_csr_slots_6 = csr_io_slots_6;
  assign io_control_csr_slots_7 = csr_io_slots_7;
  assign io_control_exe_expire = csr_io_expire;
  assign io_control_exe_rd_addr = exe_reg_rd_addr;
  assign io_control_exe_tid = exe_reg_tid;
  assign io_control_exe_br_cond = exe_br_cond;
  assign exe_br_cond = T189;
  assign T189 = T205 ? exe_eq : T190;
  assign T190 = T204 ? exe_lt : T191;
  assign T191 = T201 ? exe_ltu : T192;
  assign T192 = T200 ? T199 : T193;
  assign T193 = T198 ? T197 : T194;
  assign T194 = T196 ? T195 : 1'h0;
  assign T195 = exe_ltu ^ 1'h1;
  assign T196 = io_control_exe_br_type == 3'h5;
  assign T197 = exe_lt ^ 1'h1;
  assign T198 = io_control_exe_br_type == 3'h3;
  assign T199 = exe_eq ^ 1'h1;
  assign T200 = io_control_exe_br_type == 3'h1;
  assign exe_ltu = exe_reg_rs1_data < exe_reg_rs2_data;
  assign T201 = io_control_exe_br_type == 3'h4;
  assign exe_lt = $signed(T203) < $signed(T202);
  assign T202 = exe_reg_rs2_data;
  assign T203 = exe_reg_rs1_data;
  assign T204 = io_control_exe_br_type == 3'h2;
  assign exe_eq = exe_reg_rs1_data == exe_reg_rs2_data;
  assign T205 = io_control_exe_br_type == 3'h0;
  assign io_control_dec_inst = dec_reg_inst;
  assign io_control_dec_tid = dec_reg_tid;
  assign io_control_if_tid = if_reg_tid;
  RegisterFile regfile(.clk(clk),
       .io_rs1_thread( if_reg_tid ),
       .io_rs1_addr( T185 ),
       .io_rs1_data( regfile_io_rs1_data ),
       .io_rs2_thread( if_reg_tid ),
       .io_rs2_addr( T184 ),
       .io_rs2_data( regfile_io_rs2_data ),
       .io_rd_thread( mem_reg_tid ),
       .io_rd_addr( mem_reg_rd_addr ),
       .io_rd_data( mem_rd_data ),
       .io_rd_enable( io_control_mem_rd_write )
  );
  LoadStore loadstore(.clk(clk),
       .io_dmem_addr( loadstore_io_dmem_addr ),
       .io_dmem_enable( loadstore_io_dmem_enable ),
       .io_dmem_data_out( io_dmem_data_out ),
       .io_dmem_byte_write_3( loadstore_io_dmem_byte_write_3 ),
       .io_dmem_byte_write_2( loadstore_io_dmem_byte_write_2 ),
       .io_dmem_byte_write_1( loadstore_io_dmem_byte_write_1 ),
       .io_dmem_byte_write_0( loadstore_io_dmem_byte_write_0 ),
       .io_dmem_data_in( loadstore_io_dmem_data_in ),
       //.io_imem_r_addr(  )
       //.io_imem_r_enable(  )
       //.io_imem_r_data_out(  )
       .io_imem_rw_addr( loadstore_io_imem_rw_addr ),
       .io_imem_rw_enable( loadstore_io_imem_rw_enable ),
       .io_imem_rw_data_out( io_imem_rw_data_out ),
       .io_imem_rw_write( loadstore_io_imem_rw_write ),
       .io_imem_rw_data_in( loadstore_io_imem_rw_data_in ),
       .io_bus_addr( loadstore_io_bus_addr ),
       .io_bus_enable( loadstore_io_bus_enable ),
       .io_bus_data_out( io_bus_data_out ),
       .io_bus_write( loadstore_io_bus_write ),
       .io_bus_data_in( loadstore_io_bus_data_in ),
       .io_addr( exe_address ),
       .io_thread( exe_reg_tid ),
       .io_load( io_control_exe_load ),
       .io_store( io_control_exe_store ),
       .io_mem_type( io_control_exe_mem_type ),
       .io_data_in( exe_reg_rs2_data ),
       .io_data_out( loadstore_io_data_out ),
       .io_imem_protection_7( csr_io_imem_protection_7 ),
       .io_imem_protection_6( csr_io_imem_protection_6 ),
       .io_imem_protection_5( csr_io_imem_protection_5 ),
       .io_imem_protection_4( csr_io_imem_protection_4 ),
       .io_imem_protection_3( csr_io_imem_protection_3 ),
       .io_imem_protection_2( csr_io_imem_protection_2 ),
       .io_imem_protection_1( csr_io_imem_protection_1 ),
       .io_imem_protection_0( csr_io_imem_protection_0 ),
       .io_dmem_protection_7( csr_io_dmem_protection_7 ),
       .io_dmem_protection_6( csr_io_dmem_protection_6 ),
       .io_dmem_protection_5( csr_io_dmem_protection_5 ),
       .io_dmem_protection_4( csr_io_dmem_protection_4 ),
       .io_dmem_protection_3( csr_io_dmem_protection_3 ),
       .io_dmem_protection_2( csr_io_dmem_protection_2 ),
       .io_dmem_protection_1( csr_io_dmem_protection_1 ),
       .io_dmem_protection_0( csr_io_dmem_protection_0 ),
       .io_kill( io_control_exe_kill ),
       .io_load_misaligned( loadstore_io_load_misaligned ),
       .io_load_fault( loadstore_io_load_fault ),
       .io_store_misaligned( loadstore_io_store_misaligned ),
       .io_store_fault( loadstore_io_store_fault )
  );
  CSR csr(.clk(clk), .reset(reset),
       .io_rw_addr( exe_reg_csr_addr ),
       .io_rw_thread( exe_reg_tid ),
       .io_rw_csr_type( io_control_exe_csr_type ),
       .io_rw_write( io_control_exe_csr_write ),
       .io_rw_data_in( exe_csr_data ),
       .io_rw_data_out( csr_io_rw_data_out ),
       .io_rw_valid( io_control_exe_valid ),
       .io_slots_7( csr_io_slots_7 ),
       .io_slots_6( csr_io_slots_6 ),
       .io_slots_5( csr_io_slots_5 ),
       .io_slots_4( csr_io_slots_4 ),
       .io_slots_3( csr_io_slots_3 ),
       .io_slots_2( csr_io_slots_2 ),
       .io_slots_1( csr_io_slots_1 ),
       .io_slots_0( csr_io_slots_0 ),
       .io_tmodes_3( csr_io_tmodes_3 ),
       .io_tmodes_2( csr_io_tmodes_2 ),
       .io_tmodes_1( csr_io_tmodes_1 ),
       .io_tmodes_0( csr_io_tmodes_0 ),
       .io_kill( io_control_exe_kill ),
       .io_exception( io_control_exe_exception ),
       .io_epc( exe_reg_pc ),
       .io_cause( io_control_exe_cause ),
       .io_evecs_3( csr_io_evecs_3 ),
       .io_evecs_2( csr_io_evecs_2 ),
       .io_evecs_1( csr_io_evecs_1 ),
       .io_evecs_0( csr_io_evecs_0 ),
       .io_sleep( io_control_exe_sleep ),
       .io_ie( io_control_exe_ie ),
       .io_ee( io_control_exe_ee ),
       .io_expire( csr_io_expire ),
       .io_dec_tid( dec_reg_tid ),
       .io_sret( io_control_exe_sret ),
       .io_host_to_host( csr_io_host_to_host ),
       .io_gpio_in_3( io_gpio_in_3 ),
       .io_gpio_in_2( io_gpio_in_2 ),
       .io_gpio_in_1( io_gpio_in_1 ),
       .io_gpio_in_0( io_gpio_in_0 ),
       .io_gpio_out_3( csr_io_gpio_out_3 ),
       .io_gpio_out_2( csr_io_gpio_out_2 ),
       .io_gpio_out_1( csr_io_gpio_out_1 ),
       .io_gpio_out_0( csr_io_gpio_out_0 ),
       .io_int_exts_3( io_int_exts_3 ),
       .io_int_exts_2( io_int_exts_2 ),
       .io_int_exts_1( io_int_exts_1 ),
       .io_int_exts_0( io_int_exts_0 ),
       .io_imem_protection_7( csr_io_imem_protection_7 ),
       .io_imem_protection_6( csr_io_imem_protection_6 ),
       .io_imem_protection_5( csr_io_imem_protection_5 ),
       .io_imem_protection_4( csr_io_imem_protection_4 ),
       .io_imem_protection_3( csr_io_imem_protection_3 ),
       .io_imem_protection_2( csr_io_imem_protection_2 ),
       .io_imem_protection_1( csr_io_imem_protection_1 ),
       .io_imem_protection_0( csr_io_imem_protection_0 ),
       .io_dmem_protection_7( csr_io_dmem_protection_7 ),
       .io_dmem_protection_6( csr_io_dmem_protection_6 ),
       .io_dmem_protection_5( csr_io_dmem_protection_5 ),
       .io_dmem_protection_4( csr_io_dmem_protection_4 ),
       .io_dmem_protection_3( csr_io_dmem_protection_3 ),
       .io_dmem_protection_2( csr_io_dmem_protection_2 ),
       .io_dmem_protection_1( csr_io_dmem_protection_1 ),
       .io_dmem_protection_0( csr_io_dmem_protection_0 ),
       .io_cycle( io_control_exe_cycle ),
       .io_instret( io_control_exe_instret ),
       .io_int_expire( csr_io_int_expire ),
       .io_exc_expire( csr_io_exc_expire ),
       .io_int_ext( csr_io_int_ext ),
       .io_priv_fault( csr_io_priv_fault )
  );

  always @(posedge clk) begin
    dec_reg_tid <= if_reg_tid;
    if_reg_tid <= io_control_next_tid;
    exe_reg_pc <= dec_reg_pc;
    dec_reg_pc <= if_reg_pc;
    if(T180) begin
      if_reg_pc <= T158;
    end else if(T156) begin
      if_reg_pc <= next_pcs_1;
    end else begin
      if_reg_pc <= next_pcs_0;
    end
    if(reset) begin
      if_reg_pcs_0 <= T4;
    end else begin
      if_reg_pcs_0 <= next_pcs_0;
    end
    if(T81) begin
      exe_reg_op2 <= dec_rs2_data;
    end else if(T66) begin
      exe_reg_op2 <= dec_imm;
    end else begin
      exe_reg_op2 <= 32'h0;
    end
    dec_reg_inst <= io_imem_r_data_out;
    wb_reg_rd_data <= mem_rd_data;
    mem_reg_rd_data <= exe_rd_data;
    exe_reg_pc4 <= dec_reg_pc4;
    dec_reg_pc4 <= if_pc_plus4;
    if(T90) begin
      exe_reg_op1 <= dec_rs1_data;
    end else if(T83) begin
      exe_reg_op1 <= dec_reg_pc;
    end else begin
      exe_reg_op1 <= 32'h0;
    end
    exe_reg_tid <= dec_reg_tid;
    mem_reg_tid <= exe_reg_tid;
    if(reset) begin
      if_reg_pcs_1 <= T149;
    end else begin
      if_reg_pcs_1 <= next_pcs_1;
    end
    if(reset) begin
      if_reg_pcs_2 <= T162;
    end else begin
      if_reg_pcs_2 <= next_pcs_2;
    end
    if(reset) begin
      if_reg_pcs_3 <= T172;
    end else begin
      if_reg_pcs_3 <= next_pcs_3;
    end
    if(T181) begin
      exe_csr_data <= dec_imm;
    end else begin
      exe_csr_data <= dec_rs1_data;
    end
    exe_reg_csr_addr <= T182;
    exe_reg_rs2_data <= dec_rs2_data;
    mem_reg_rd_addr <= exe_reg_rd_addr;
    exe_reg_rd_addr <= T183;
    wb_reg_rd_addr <= mem_reg_rd_addr;
    wb_reg_tid <= mem_reg_tid;
    exe_reg_rs1_data <= dec_rs1_data;
  end
endmodule

module Core(input clk, input reset,
    input [11:0] io_imem_addr,
    input  io_imem_enable,
    output[31:0] io_imem_data_out,
    input  io_imem_write,
    input [31:0] io_imem_data_in,
    output io_imem_ready,
    input [11:0] io_dmem_addr,
    input  io_dmem_enable,
    output[31:0] io_dmem_data_out,
    input  io_dmem_byte_write_3,
    input  io_dmem_byte_write_2,
    input  io_dmem_byte_write_1,
    input  io_dmem_byte_write_0,
    input [31:0] io_dmem_data_in,
    output[9:0] io_bus_addr,
    output io_bus_enable,
    input [31:0] io_bus_data_out,
    output io_bus_write,
    output[31:0] io_bus_data_in,
    output[31:0] io_host_to_host,
    input  io_gpio_in_3,
    input  io_gpio_in_2,
    input  io_gpio_in_1,
    input  io_gpio_in_0,
    output[1:0] io_gpio_out_3,
    output[1:0] io_gpio_out_2,
    output[1:0] io_gpio_out_1,
    output[1:0] io_gpio_out_0,
    input  io_int_exts_7,
    input  io_int_exts_6,
    input  io_int_exts_5,
    input  io_int_exts_4,
    input  io_int_exts_3,
    input  io_int_exts_2,
    input  io_int_exts_1,
    input  io_int_exts_0
);

  wire[31:0] imem_io_core_r_data_out;
  wire[31:0] imem_io_core_rw_data_out;
  wire[31:0] imem_io_bus_data_out;
  wire imem_io_bus_ready;
  wire[31:0] dmem_io_core_data_out;
  wire[31:0] dmem_io_bus_data_out;
  wire[2:0] control_io_dec_imm_sel;
  wire[1:0] control_io_dec_op1_sel;
  wire[1:0] control_io_dec_op2_sel;
  wire[3:0] control_io_exe_alu_type;
  wire[2:0] control_io_exe_br_type;
  wire[1:0] control_io_exe_csr_type;
  wire[1:0] control_io_exe_mul_type;
  wire[1:0] control_io_exe_rd_data_sel;
  wire[3:0] control_io_exe_mem_type;
  wire[1:0] control_io_mem_rd_data_sel;
  wire[1:0] control_io_next_pc_sel_3;
  wire[1:0] control_io_next_pc_sel_2;
  wire[1:0] control_io_next_pc_sel_1;
  wire[1:0] control_io_next_pc_sel_0;
  wire[1:0] control_io_next_tid;
  wire control_io_next_valid;
  wire[1:0] control_io_dec_rs1_sel;
  wire[1:0] control_io_dec_rs2_sel;
  wire control_io_exe_valid;
  wire control_io_exe_load;
  wire control_io_exe_store;
  wire control_io_exe_csr_write;
  wire control_io_exe_exception;
  wire[4:0] control_io_exe_cause;
  wire control_io_exe_kill;
  wire control_io_exe_sleep;
  wire control_io_exe_ie;
  wire control_io_exe_ee;
  wire control_io_exe_sret;
  wire control_io_exe_cycle;
  wire control_io_exe_instret;
  wire control_io_mem_rd_write;
  wire[1:0] datapath_io_control_if_tid;
  wire[1:0] datapath_io_control_dec_tid;
  wire[31:0] datapath_io_control_dec_inst;
  wire datapath_io_control_exe_br_cond;
  wire[1:0] datapath_io_control_exe_tid;
  wire[4:0] datapath_io_control_exe_rd_addr;
  wire datapath_io_control_exe_expire;
  wire[3:0] datapath_io_control_csr_slots_7;
  wire[3:0] datapath_io_control_csr_slots_6;
  wire[3:0] datapath_io_control_csr_slots_5;
  wire[3:0] datapath_io_control_csr_slots_4;
  wire[3:0] datapath_io_control_csr_slots_3;
  wire[3:0] datapath_io_control_csr_slots_2;
  wire[3:0] datapath_io_control_csr_slots_1;
  wire[3:0] datapath_io_control_csr_slots_0;
  wire[1:0] datapath_io_control_csr_tmodes_3;
  wire[1:0] datapath_io_control_csr_tmodes_2;
  wire[1:0] datapath_io_control_csr_tmodes_1;
  wire[1:0] datapath_io_control_csr_tmodes_0;
  wire[1:0] datapath_io_control_mem_tid;
  wire[4:0] datapath_io_control_mem_rd_addr;
  wire[1:0] datapath_io_control_wb_tid;
  wire[4:0] datapath_io_control_wb_rd_addr;
  wire datapath_io_control_if_exc_misaligned;
  wire datapath_io_control_if_exc_fault;
  wire datapath_io_control_exe_exc_priv_inst;
  wire datapath_io_control_exe_exc_load_misaligned;
  wire datapath_io_control_exe_exc_load_fault;
  wire datapath_io_control_exe_exc_store_misaligned;
  wire datapath_io_control_exe_exc_store_fault;
  wire datapath_io_control_exe_exc_expire;
  wire datapath_io_control_exe_int_expire;
  wire datapath_io_control_exe_int_ext;
  wire[11:0] datapath_io_imem_r_addr;
  wire datapath_io_imem_r_enable;
  wire[11:0] datapath_io_imem_rw_addr;
  wire datapath_io_imem_rw_enable;
  wire datapath_io_imem_rw_write;
  wire[31:0] datapath_io_imem_rw_data_in;
  wire[11:0] datapath_io_dmem_addr;
  wire datapath_io_dmem_enable;
  wire datapath_io_dmem_byte_write_3;
  wire datapath_io_dmem_byte_write_2;
  wire datapath_io_dmem_byte_write_1;
  wire datapath_io_dmem_byte_write_0;
  wire[31:0] datapath_io_dmem_data_in;
  wire[9:0] datapath_io_bus_addr;
  wire datapath_io_bus_enable;
  wire datapath_io_bus_write;
  wire[31:0] datapath_io_bus_data_in;
  wire[31:0] datapath_io_host_to_host;
  wire[1:0] datapath_io_gpio_out_3;
  wire[1:0] datapath_io_gpio_out_2;
  wire[1:0] datapath_io_gpio_out_1;
  wire[1:0] datapath_io_gpio_out_0;


  assign io_gpio_out_0 = datapath_io_gpio_out_0;
  assign io_gpio_out_1 = datapath_io_gpio_out_1;
  assign io_gpio_out_2 = datapath_io_gpio_out_2;
  assign io_gpio_out_3 = datapath_io_gpio_out_3;
  assign io_host_to_host = datapath_io_host_to_host;
  assign io_bus_data_in = datapath_io_bus_data_in;
  assign io_bus_write = datapath_io_bus_write;
  assign io_bus_enable = datapath_io_bus_enable;
  assign io_bus_addr = datapath_io_bus_addr;
  assign io_dmem_data_out = dmem_io_bus_data_out;
  assign io_imem_ready = imem_io_bus_ready;
  assign io_imem_data_out = imem_io_bus_data_out;
  Control control(.clk(clk), .reset(reset),
       .io_dec_imm_sel( control_io_dec_imm_sel ),
       .io_dec_op1_sel( control_io_dec_op1_sel ),
       .io_dec_op2_sel( control_io_dec_op2_sel ),
       .io_exe_alu_type( control_io_exe_alu_type ),
       .io_exe_br_type( control_io_exe_br_type ),
       .io_exe_csr_type( control_io_exe_csr_type ),
       .io_exe_mul_type( control_io_exe_mul_type ),
       .io_exe_rd_data_sel( control_io_exe_rd_data_sel ),
       .io_exe_mem_type( control_io_exe_mem_type ),
       .io_mem_rd_data_sel( control_io_mem_rd_data_sel ),
       .io_next_pc_sel_3( control_io_next_pc_sel_3 ),
       .io_next_pc_sel_2( control_io_next_pc_sel_2 ),
       .io_next_pc_sel_1( control_io_next_pc_sel_1 ),
       .io_next_pc_sel_0( control_io_next_pc_sel_0 ),
       .io_next_tid( control_io_next_tid ),
       .io_next_valid( control_io_next_valid ),
       .io_dec_rs1_sel( control_io_dec_rs1_sel ),
       .io_dec_rs2_sel( control_io_dec_rs2_sel ),
       .io_exe_valid( control_io_exe_valid ),
       .io_exe_load( control_io_exe_load ),
       .io_exe_store( control_io_exe_store ),
       .io_exe_csr_write( control_io_exe_csr_write ),
       .io_exe_exception( control_io_exe_exception ),
       .io_exe_cause( control_io_exe_cause ),
       .io_exe_kill( control_io_exe_kill ),
       .io_exe_sleep( control_io_exe_sleep ),
       .io_exe_ie( control_io_exe_ie ),
       .io_exe_ee( control_io_exe_ee ),
       .io_exe_sret( control_io_exe_sret ),
       .io_exe_cycle( control_io_exe_cycle ),
       .io_exe_instret( control_io_exe_instret ),
       .io_mem_rd_write( control_io_mem_rd_write ),
       .io_if_tid( datapath_io_control_if_tid ),
       .io_dec_tid( datapath_io_control_dec_tid ),
       .io_dec_inst( datapath_io_control_dec_inst ),
       .io_exe_br_cond( datapath_io_control_exe_br_cond ),
       .io_exe_tid( datapath_io_control_exe_tid ),
       .io_exe_rd_addr( datapath_io_control_exe_rd_addr ),
       .io_exe_expire( datapath_io_control_exe_expire ),
       .io_csr_slots_7( datapath_io_control_csr_slots_7 ),
       .io_csr_slots_6( datapath_io_control_csr_slots_6 ),
       .io_csr_slots_5( datapath_io_control_csr_slots_5 ),
       .io_csr_slots_4( datapath_io_control_csr_slots_4 ),
       .io_csr_slots_3( datapath_io_control_csr_slots_3 ),
       .io_csr_slots_2( datapath_io_control_csr_slots_2 ),
       .io_csr_slots_1( datapath_io_control_csr_slots_1 ),
       .io_csr_slots_0( datapath_io_control_csr_slots_0 ),
       .io_csr_tmodes_3( datapath_io_control_csr_tmodes_3 ),
       .io_csr_tmodes_2( datapath_io_control_csr_tmodes_2 ),
       .io_csr_tmodes_1( datapath_io_control_csr_tmodes_1 ),
       .io_csr_tmodes_0( datapath_io_control_csr_tmodes_0 ),
       .io_mem_tid( datapath_io_control_mem_tid ),
       .io_mem_rd_addr( datapath_io_control_mem_rd_addr ),
       .io_wb_tid( datapath_io_control_wb_tid ),
       .io_wb_rd_addr( datapath_io_control_wb_rd_addr ),
       .io_if_exc_misaligned( datapath_io_control_if_exc_misaligned ),
       .io_if_exc_fault( datapath_io_control_if_exc_fault ),
       .io_exe_exc_priv_inst( datapath_io_control_exe_exc_priv_inst ),
       .io_exe_exc_load_misaligned( datapath_io_control_exe_exc_load_misaligned ),
       .io_exe_exc_load_fault( datapath_io_control_exe_exc_load_fault ),
       .io_exe_exc_store_misaligned( datapath_io_control_exe_exc_store_misaligned ),
       .io_exe_exc_store_fault( datapath_io_control_exe_exc_store_fault ),
       .io_exe_exc_expire( datapath_io_control_exe_exc_expire ),
       .io_exe_int_expire( datapath_io_control_exe_int_expire ),
       .io_exe_int_ext( datapath_io_control_exe_int_ext )
  );
  Datapath datapath(.clk(clk), .reset(reset),
       .io_control_dec_imm_sel( control_io_dec_imm_sel ),
       .io_control_dec_op1_sel( control_io_dec_op1_sel ),
       .io_control_dec_op2_sel( control_io_dec_op2_sel ),
       .io_control_exe_alu_type( control_io_exe_alu_type ),
       .io_control_exe_br_type( control_io_exe_br_type ),
       .io_control_exe_csr_type( control_io_exe_csr_type ),
       .io_control_exe_mul_type( control_io_exe_mul_type ),
       .io_control_exe_rd_data_sel( control_io_exe_rd_data_sel ),
       .io_control_exe_mem_type( control_io_exe_mem_type ),
       .io_control_mem_rd_data_sel( control_io_mem_rd_data_sel ),
       .io_control_next_pc_sel_3( control_io_next_pc_sel_3 ),
       .io_control_next_pc_sel_2( control_io_next_pc_sel_2 ),
       .io_control_next_pc_sel_1( control_io_next_pc_sel_1 ),
       .io_control_next_pc_sel_0( control_io_next_pc_sel_0 ),
       .io_control_next_tid( control_io_next_tid ),
       .io_control_next_valid( control_io_next_valid ),
       .io_control_dec_rs1_sel( control_io_dec_rs1_sel ),
       .io_control_dec_rs2_sel( control_io_dec_rs2_sel ),
       .io_control_exe_valid( control_io_exe_valid ),
       .io_control_exe_load( control_io_exe_load ),
       .io_control_exe_store( control_io_exe_store ),
       .io_control_exe_csr_write( control_io_exe_csr_write ),
       .io_control_exe_exception( control_io_exe_exception ),
       .io_control_exe_cause( control_io_exe_cause ),
       .io_control_exe_kill( control_io_exe_kill ),
       .io_control_exe_sleep( control_io_exe_sleep ),
       .io_control_exe_ie( control_io_exe_ie ),
       .io_control_exe_ee( control_io_exe_ee ),
       .io_control_exe_sret( control_io_exe_sret ),
       .io_control_exe_cycle( control_io_exe_cycle ),
       .io_control_exe_instret( control_io_exe_instret ),
       .io_control_mem_rd_write( control_io_mem_rd_write ),
       .io_control_if_tid( datapath_io_control_if_tid ),
       .io_control_dec_tid( datapath_io_control_dec_tid ),
       .io_control_dec_inst( datapath_io_control_dec_inst ),
       .io_control_exe_br_cond( datapath_io_control_exe_br_cond ),
       .io_control_exe_tid( datapath_io_control_exe_tid ),
       .io_control_exe_rd_addr( datapath_io_control_exe_rd_addr ),
       .io_control_exe_expire( datapath_io_control_exe_expire ),
       .io_control_csr_slots_7( datapath_io_control_csr_slots_7 ),
       .io_control_csr_slots_6( datapath_io_control_csr_slots_6 ),
       .io_control_csr_slots_5( datapath_io_control_csr_slots_5 ),
       .io_control_csr_slots_4( datapath_io_control_csr_slots_4 ),
       .io_control_csr_slots_3( datapath_io_control_csr_slots_3 ),
       .io_control_csr_slots_2( datapath_io_control_csr_slots_2 ),
       .io_control_csr_slots_1( datapath_io_control_csr_slots_1 ),
       .io_control_csr_slots_0( datapath_io_control_csr_slots_0 ),
       .io_control_csr_tmodes_3( datapath_io_control_csr_tmodes_3 ),
       .io_control_csr_tmodes_2( datapath_io_control_csr_tmodes_2 ),
       .io_control_csr_tmodes_1( datapath_io_control_csr_tmodes_1 ),
       .io_control_csr_tmodes_0( datapath_io_control_csr_tmodes_0 ),
       .io_control_mem_tid( datapath_io_control_mem_tid ),
       .io_control_mem_rd_addr( datapath_io_control_mem_rd_addr ),
       .io_control_wb_tid( datapath_io_control_wb_tid ),
       .io_control_wb_rd_addr( datapath_io_control_wb_rd_addr ),
       .io_control_if_exc_misaligned( datapath_io_control_if_exc_misaligned ),
       .io_control_if_exc_fault( datapath_io_control_if_exc_fault ),
       .io_control_exe_exc_priv_inst( datapath_io_control_exe_exc_priv_inst ),
       .io_control_exe_exc_load_misaligned( datapath_io_control_exe_exc_load_misaligned ),
       .io_control_exe_exc_load_fault( datapath_io_control_exe_exc_load_fault ),
       .io_control_exe_exc_store_misaligned( datapath_io_control_exe_exc_store_misaligned ),
       .io_control_exe_exc_store_fault( datapath_io_control_exe_exc_store_fault ),
       .io_control_exe_exc_expire( datapath_io_control_exe_exc_expire ),
       .io_control_exe_int_expire( datapath_io_control_exe_int_expire ),
       .io_control_exe_int_ext( datapath_io_control_exe_int_ext ),
       .io_imem_r_addr( datapath_io_imem_r_addr ),
       .io_imem_r_enable( datapath_io_imem_r_enable ),
       .io_imem_r_data_out( imem_io_core_r_data_out ),
       .io_imem_rw_addr( datapath_io_imem_rw_addr ),
       .io_imem_rw_enable( datapath_io_imem_rw_enable ),
       .io_imem_rw_data_out( imem_io_core_rw_data_out ),
       .io_imem_rw_write( datapath_io_imem_rw_write ),
       .io_imem_rw_data_in( datapath_io_imem_rw_data_in ),
       .io_dmem_addr( datapath_io_dmem_addr ),
       .io_dmem_enable( datapath_io_dmem_enable ),
       .io_dmem_data_out( dmem_io_core_data_out ),
       .io_dmem_byte_write_3( datapath_io_dmem_byte_write_3 ),
       .io_dmem_byte_write_2( datapath_io_dmem_byte_write_2 ),
       .io_dmem_byte_write_1( datapath_io_dmem_byte_write_1 ),
       .io_dmem_byte_write_0( datapath_io_dmem_byte_write_0 ),
       .io_dmem_data_in( datapath_io_dmem_data_in ),
       .io_bus_addr( datapath_io_bus_addr ),
       .io_bus_enable( datapath_io_bus_enable ),
       .io_bus_data_out( io_bus_data_out ),
       .io_bus_write( datapath_io_bus_write ),
       .io_bus_data_in( datapath_io_bus_data_in ),
       .io_host_to_host( datapath_io_host_to_host ),
       .io_gpio_in_3( io_gpio_in_3 ),
       .io_gpio_in_2( io_gpio_in_2 ),
       .io_gpio_in_1( io_gpio_in_1 ),
       .io_gpio_in_0( io_gpio_in_0 ),
       .io_gpio_out_3( datapath_io_gpio_out_3 ),
       .io_gpio_out_2( datapath_io_gpio_out_2 ),
       .io_gpio_out_1( datapath_io_gpio_out_1 ),
       .io_gpio_out_0( datapath_io_gpio_out_0 ),
       .io_int_exts_3( io_int_exts_3 ),
       .io_int_exts_2( io_int_exts_2 ),
       .io_int_exts_1( io_int_exts_1 ),
       .io_int_exts_0( io_int_exts_0 )
  );
  ISpm imem(.clk(clk),
       .io_core_r_addr( datapath_io_imem_r_addr ),
       .io_core_r_enable( datapath_io_imem_r_enable ),
       .io_core_r_data_out( imem_io_core_r_data_out ),
       .io_core_rw_addr( datapath_io_imem_rw_addr ),
       .io_core_rw_enable( datapath_io_imem_rw_enable ),
       .io_core_rw_data_out( imem_io_core_rw_data_out ),
       .io_core_rw_write( datapath_io_imem_rw_write ),
       .io_core_rw_data_in( datapath_io_imem_rw_data_in ),
       .io_bus_addr( io_imem_addr ),
       .io_bus_enable( io_imem_enable ),
       .io_bus_data_out( imem_io_bus_data_out ),
       .io_bus_write( io_imem_write ),
       .io_bus_data_in( io_imem_data_in ),
       .io_bus_ready( imem_io_bus_ready )
  );
  DSpm dmem(.clk(clk),
       .io_core_addr( datapath_io_dmem_addr ),
       .io_core_enable( datapath_io_dmem_enable ),
       .io_core_data_out( dmem_io_core_data_out ),
       .io_core_byte_write_3( datapath_io_dmem_byte_write_3 ),
       .io_core_byte_write_2( datapath_io_dmem_byte_write_2 ),
       .io_core_byte_write_1( datapath_io_dmem_byte_write_1 ),
       .io_core_byte_write_0( datapath_io_dmem_byte_write_0 ),
       .io_core_data_in( datapath_io_dmem_data_in ),
       .io_bus_addr( io_dmem_addr ),
       .io_bus_enable( io_dmem_enable ),
       .io_bus_data_out( dmem_io_bus_data_out ),
       .io_bus_byte_write_3( io_dmem_byte_write_3 ),
       .io_bus_byte_write_2( io_dmem_byte_write_2 ),
       .io_bus_byte_write_1( io_dmem_byte_write_1 ),
       .io_bus_byte_write_0( io_dmem_byte_write_0 ),
       .io_bus_data_in( io_dmem_data_in )
  );
endmodule

