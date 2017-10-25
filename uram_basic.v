`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/08 15:19:51
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uram_basic( 
input               clk,
input               rst,
input   [15:0]      addra,
input   [0:0]       wea,
input   [71:0]      dina,
output  [71:0]      douta,
input   [15:0]      addrb,
input   [0:0]       web,
input   [71:0]      dinb,
output  [71:0]      doutb
);


xpm_memory_tdpram # (

  // Common module parameters
  .MEMORY_SIZE        (2949120),            //positive integer
  .MEMORY_PRIMITIVE   ("ultra"),          //string; "auto", "distributed", "block" or "ultra";
  .CLOCKING_MODE      ("common_clock"),  //string; "common_clock", "independent_clock" 
  .MEMORY_INIT_FILE   ("none"),          //string; "none" or "<filename>.mem" 
  .MEMORY_INIT_PARAM  (""),          //string;
  .USE_MEM_INIT       (0),               //integer; 0,1
  .WAKEUP_TIME        ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin" 
  .MESSAGE_CONTROL    (0),               //integer; 0,1
  .ECC_MODE           ("no_ecc"),        //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode" 
  .AUTO_SLEEP_TIME    (0),               //Do not Change

  // Port A module parameters
  .WRITE_DATA_WIDTH_A (72),              //positive integer
  .READ_DATA_WIDTH_A  (72),              //positive integer
  .BYTE_WRITE_WIDTH_A (72),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
  .ADDR_WIDTH_A       (16),               //positive integer
  .READ_RESET_VALUE_A ("0"),             //string
  .READ_LATENCY_A     (1),               //non-negative integer
  .WRITE_MODE_A       ("no_change"),     //string; "write_first", "read_first", "no_change" 

  // Port B module parameters
  .WRITE_DATA_WIDTH_B (72),              //positive integer
  .READ_DATA_WIDTH_B  (72),              //positive integer
  .BYTE_WRITE_WIDTH_B (72),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
  .ADDR_WIDTH_B       (16),               //positive integer
  .READ_RESET_VALUE_B ("0"),             //vector of READ_DATA_WIDTH_B bits
  .READ_LATENCY_B     (1),               //non-negative integer
  .WRITE_MODE_B       ("no_change")      //string; "write_first", "read_first", "no_change" 

) xpm_memory_tdpram_inst (

  // Common module ports
  .sleep          (1'b0),

  // Port A module ports
  .clka           (clk),
  .rsta           (rst),
  .ena            (1'b1),
  .regcea         (1'b1),
  .wea            (wea),
  .addra          (addra),
  .dina           (dina),
  .injectsbiterra (1'b0),
  .injectdbiterra (1'b0),
  .douta          (douta),
  .sbiterra       (),
  .dbiterra       (),

  // Port B module ports
  .clkb           (clk),
  .rstb           (rst),
  .enb            (1'b1),
  .regceb         (1'b1),
  .web            (web),
  .addrb          (addrb),
  .dinb           (dinb),
  .injectsbiterrb (1'b0),
  .injectdbiterrb (1'b0),
  .doutb          (doutb),
  .sbiterrb       (),
  .dbiterrb       ()

);
endmodule
