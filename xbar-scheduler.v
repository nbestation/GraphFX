`timescale 1ns/1ps

/*module xbar_scheduler #(
    parameter IN_NUM = 8,
    parameter IN_WIDTH = 4
) (
    data_counts,
    sched_one_hot
    );
    input wire [IN_NUM*IN_WIDTH-1:0]    data_counts;
    output wire [IN_NUM-1:0]            sched_one_hot;
    
    genvar comp_i, range_i;
    wire [IN_NUM-1] comp_result[IN_NUM];
    generate
    endgenerate
    assign sched_one_hot =  {(IN_NUM-1){1'b0}} + 1'b1;
endmodule*/

module xbar_scheduler #
(
    LEN_WIDTH   =   32'd10,
    ID_WIDTH    =   32'd5
)
(
    //input   [power(ID_WIDTH)*DATA_WIDTH		- 1 :0] data,
    input   [power(ID_WIDTH)*LEN_WIDTH		- 1 :0] len,
    input   [power(ID_WIDTH)*ID_WIDTH       - 1 :0] id,
    output	[LEN_WIDTH						- 1 :0]	len_out,
	output	[ID_WIDTH						- 1 :0]	id_out
);

    function integer power (input integer width);
    integer i;
    begin
        power = 1;
        for (i = 0; i < width; i=i+1)
            power = power * 2;
    end
    endfunction
    
    wire    [(LEN_WIDTH+ID_WIDTH)*power(ID_WIDTH)-1 : 0] connect [ID_WIDTH : 0];
    
    generate
        genvar	ii;
        for (ii = 0; ii < power(ID_WIDTH); ii = ii + 1)
        begin: input_signal
            assign	connect[ID_WIDTH][ii*(LEN_WIDTH+ID_WIDTH)+LEN_WIDTH-1 :ii*(LEN_WIDTH+ID_WIDTH)] = len[(ii+1)*LEN_WIDTH-1 :ii*LEN_WIDTH];
            assign	connect[ID_WIDTH][ii*(LEN_WIDTH+ID_WIDTH)+LEN_WIDTH+ID_WIDTH-1 :ii*(LEN_WIDTH+ID_WIDTH)+LEN_WIDTH] = id[(ii+1)*ID_WIDTH-1 :ii*ID_WIDTH];
        end
    endgenerate
    
    assign	len_out = connect[0][LEN_WIDTH				- 1 :0];
    assign	id_out 	= connect[0][LEN_WIDTH + ID_WIDTH	- 1 :LEN_WIDTH];
    
    generate
        genvar i, j;
        for (i = ID_WIDTH; i > 0; i = i - 1)
        begin: level
            for (j = 0; j < power(i-1); j = j + 1)
            begin: row
                comparator #
                (
                    .LEN_WIDTH(LEN_WIDTH),
                    .ID_WIDTH(ID_WIDTH)
                )
                UUT
                (
                    .len1(connect[i][j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH				- 1 :j*2*(LEN_WIDTH+ID_WIDTH)]),
                    .len2(connect[i][j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH*2 + ID_WIDTH	- 1 :j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH + ID_WIDTH]),
                    .id1(connect[i][j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH + ID_WIDTH		- 1 :j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH]),
                    .id2(connect[i][j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH*2 + ID_WIDTH*2	- 1 :j*2*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH*2 + ID_WIDTH]),
                    .len(connect[i-1][j*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH				- 1 :j*(LEN_WIDTH+ID_WIDTH)]),
                    .id(connect[i-1][j*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH + ID_WIDTH		- 1 :j*(LEN_WIDTH+ID_WIDTH) + LEN_WIDTH])
                );
            end
        end
    endgenerate

endmodule
