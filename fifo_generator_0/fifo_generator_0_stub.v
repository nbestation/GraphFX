// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Thu Sep 14 16:18:20 2017
// Host        : DESKTOP-L9D9D0V running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Users/Tianhao
//               Huang/Documents/src/Verilog/UltraRAM/UltraRAM.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_stub.v}
// Design      : fifo_generator_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu13p-flga2577-1-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_4,Vivado 2017.2" *)
module fifo_generator_0(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  data_count, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[95:0],wr_en,rd_en,dout[95:0],full,empty,data_count[3:0],wr_rst_busy,rd_rst_busy" */;
  input clk;
  input srst;
  input [95:0]din;
  input wr_en;
  input rd_en;
  output [95:0]dout;
  output full;
  output empty;
  output [3:0]data_count;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
