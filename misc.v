`timescale 1ns / 1ps

module decoder_for_xbar #(
    parameter DIN_WIDTH     = 3,
    parameter DOUT_WIDTH    = f_pow2(DIN_WIDTH))
(
    fifo_state,
    din_en,
    din,
    one_hot
);

    function integer f_pow2 (input integer x);
    integer acc, pow_out;
    begin
      acc=0;
      pow_out=1;
      while (acc < x) begin
        acc = acc + 1;
        pow_out = pow_out * 2;
      end
      f_pow2 = pow_out;
    end
    endfunction

    input wire [DOUT_WIDTH-1:0]   fifo_state;
    input wire                    din_en;
    input wire [DIN_WIDTH-1:0]    din;
    output reg [DOUT_WIDTH-1:0]   one_hot;
    
    integer i;
    always @* begin
        one_hot = {DOUT_WIDTH {1'b0}};
        if (~fifo_state[din] & din_en) begin
            one_hot[din] = 1'b1;
        end 
    end
endmodule

module comparator #
(
    parameter   LEN_WIDTH   = 32'd10,
    parameter   ID_WIDTH    = 32'd5
)
(
    input       [LEN_WIDTH  - 1 :0]   len1,
    input       [LEN_WIDTH  - 1 :0]   len2,
    input       [ID_WIDTH   - 1 :0]   id1,
    input       [ID_WIDTH   - 1 :0]   id2,
    input                             privil1,
    input                             privil2,
    output  reg [LEN_WIDTH  - 1 :0]   len,
    output  reg [ID_WIDTH   - 1 :0]   id,
    output  reg                       privil
);


    always@ (*) begin
        if (privil1 == privil2) begin
            privil      = privil2;
            if (len1 > len2)
            begin
                len     =   len1;
                id      =   id1;
            end else
            begin
                len     =   len2;
                id      =   id2;    
            end
        end else begin
            privil      =   1'b1;
            if (privil1) begin
                len     =   len1;
                id      =   id1;
            end
            else if(privil2) begin
                len     =   len2;
                id      =   id2;
            end
        end
    end

endmodule