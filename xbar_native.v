`timescale 1ns/1ps

// TODO: 1. Change FIFO to FWFT mode and then remove dout_en delay
//       2. When the written FIFO is full, upper-layer logic should wait until not full. It's not decoder's responsibility
module xbar_native #(
    parameter XBAR_NUM_IN       = 64,
    parameter XBAR_NUM_OUT      = XBAR_NUM_IN,
    parameter XBAR_ID_WIDTH     = 32,
    parameter XBAR_DATA_WIDTH   = 64,
    parameter XBAR_ID_CHUNK     = 32'H100000,                  // Default: id of 0 ~ 2^20=1 will fall into the same output port
                                                                // din_id[XBAR_ID_HIGH-1:XBAR_ID_LOW] is the output port
    parameter XBAR_ID_OUTBITS   = f_ceil_log2(XBAR_NUM_OUT),
    parameter XBAR_ID_LOW       = f_ceil_log2(XBAR_ID_CHUNK),
    parameter XBAR_ID_HIGH      = XBAR_ID_LOW + XBAR_ID_OUTBITS
) (
    clk,
    rst,
    din_id,
    din_data,
    din_en,
    drain_all,
    
    dout_id,
    dout_data,
    dout_en,
    ready,
    empty
);
    function integer f_ceil_log2 (input integer x);
        integer acc;
        begin
          acc=0;
          while ((2**acc) < x)
            acc = acc + 1;
          f_ceil_log2 = acc;
        end
    endfunction

    input clk, rst;
    input wire [XBAR_NUM_IN*XBAR_ID_WIDTH-1:0]      din_id;
    input wire [XBAR_NUM_IN*XBAR_DATA_WIDTH-1:0]    din_data;
    input wire [XBAR_NUM_IN-1:0]                    din_en;
    input wire                                      drain_all;
    output reg [XBAR_NUM_OUT*XBAR_ID_WIDTH-1:0]     dout_id;
    output reg [XBAR_NUM_OUT*XBAR_DATA_WIDTH-1:0]   dout_data;
    output reg [XBAR_NUM_OUT-1:0]                   dout_en;
    output wire                                     ready;
    output reg                                      empty;

    wire  [XBAR_NUM_OUT*XBAR_ID_WIDTH-1:0]          dout_id_i;
    wire  [XBAR_NUM_OUT*XBAR_DATA_WIDTH-1:0]        dout_data_i;
    reg   [XBAR_NUM_OUT-1:0]                        dout_en_i;
    wire                                            ready_i, empty_i;

    localparam  FIFO_DEPTH          =   16;
    localparam  FIFO_DEPTH_BITS     =   f_ceil_log2(FIFO_DEPTH);
    localparam  FIFO_ID_WIDTH       =   f_ceil_log2(XBAR_NUM_IN);
    wire [XBAR_NUM_IN*XBAR_ID_WIDTH-1:0]                fifo_wr_id;
    wire [XBAR_NUM_IN*XBAR_DATA_WIDTH-1:0]              fifo_wr_data;
    wire [XBAR_NUM_IN*XBAR_NUM_OUT-1:0]                 fifo_wr_en;                     // determined by din_id
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*XBAR_ID_WIDTH-1:0]   fifo_rd_id;
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*XBAR_DATA_WIDTH-1:0] fifo_rd_data;
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*1-1:0]               fifo_rd_en;                     // determined by scheduler
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*FIFO_DEPTH_BITS-1:0] fifo_data_count;
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*1-1:0]               xbar_fifo_full, xbar_fifo_empty;
    assign  fifo_wr_id      =   din_id;
    assign  fifo_wr_data    =   din_data;

    wire [XBAR_NUM_IN*FIFO_ID_WIDTH-1:0]                fixed_fifo_id;
    wire [XBAR_NUM_OUT*FIFO_ID_WIDTH-1:0]               sched_fifo_id;
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*1-1:0]               sched_fifo_empty;   // fifo empty signals per column
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*FIFO_DEPTH_BITS-1:0] sched_data_count;   // input data counts for scheduler per column
    wire [XBAR_NUM_IN*XBAR_NUM_OUT*1-1:0]               sched_rd_en;        // outputs from scheduler per column
    reg  [XBAR_NUM_OUT*FIFO_ID_WIDTH-1:0]               output_id_select;
    reg  [XBAR_NUM_IN*XBAR_NUM_OUT-1:0]                 output_en;          // enable for each output port

    reg [1:0]               wait_count;
    wire                    allow_write;
    assign  allow_write =   (wait_count > 2'd2);
    assign  ready_i     =   allow_write;
    assign  ready       =   ready_i;
    // XXX: it doesn't work (all_empty_i always HIGH)
    assign  all_empty_i =   ~(&dout_en_i);
    
    always @(posedge clk) begin
        if (!rst) begin
            wait_count  <=  2'd0;
        end else begin
            if (wait_count  <= 2'd2)
                wait_count  <=  wait_count  + 1'd1;
        end
    end
    
    integer one_hot_i;
    genvar fifo_id_i, xbar_in_i, xbar_out_i;
    generate
        for(fifo_id_i = 0; fifo_id_i < XBAR_NUM_IN; fifo_id_i = fifo_id_i + 1) begin
            assign fixed_fifo_id[fifo_id_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH]  =   fifo_id_i;
        end
        
        // Generate fifos, aggregate signals
        for (xbar_in_i = 0; xbar_in_i < XBAR_NUM_IN; xbar_in_i = xbar_in_i + 1) begin: xbar_fifo_row
            for (xbar_out_i = 0; xbar_out_i < XBAR_NUM_OUT; xbar_out_i = xbar_out_i + 1) begin: xbar_fifo_col

                assign sched_fifo_empty[xbar_out_i*XBAR_NUM_IN+xbar_in_i]
                    =   xbar_fifo_empty[xbar_in_i*XBAR_NUM_OUT+xbar_out_i]; 
                assign sched_data_count[(xbar_out_i*XBAR_NUM_IN+xbar_in_i) * FIFO_DEPTH_BITS +: FIFO_DEPTH_BITS]
                    =   fifo_data_count[(xbar_in_i*XBAR_NUM_OUT+xbar_out_i) * FIFO_DEPTH_BITS +: FIFO_DEPTH_BITS];
                assign fifo_rd_en[xbar_in_i*XBAR_NUM_OUT+xbar_out_i]
                    =   sched_rd_en[xbar_out_i*XBAR_NUM_IN+xbar_in_i];
                    
                fifo_generator_0 xbar_fifo (
                    .clk    (clk),
                    .srst   (!rst),
                    .din    ({fifo_wr_id[xbar_in_i*XBAR_ID_WIDTH +: XBAR_ID_WIDTH], fifo_wr_data[xbar_in_i*XBAR_DATA_WIDTH +: XBAR_DATA_WIDTH]}),
                    .wr_en  (fifo_wr_en[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]),
                    .rd_en  (fifo_rd_en[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]),
                    .dout   ({fifo_rd_id[(xbar_in_i*XBAR_NUM_OUT + xbar_out_i) * XBAR_ID_WIDTH +: XBAR_ID_WIDTH], fifo_rd_data[(xbar_in_i*XBAR_NUM_OUT + xbar_out_i)*XBAR_DATA_WIDTH +: XBAR_DATA_WIDTH]}),
                    .full   (xbar_fifo_full[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]),
                    .empty  (xbar_fifo_empty[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]),
                    .data_count (fifo_data_count[(xbar_in_i*XBAR_NUM_OUT + xbar_out_i)*FIFO_DEPTH_BITS +: FIFO_DEPTH_BITS]),
                    // what do these two signals mean?
                    .wr_rst_busy(),
                    .rd_rst_busy()
                    );

                always @(posedge clk) begin
                    if (!rst)
                        output_en[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]  <= 1'b0;
                    else
                        // TODO: not efficient. Add a `valid` output to decoder module.
                        output_en[xbar_in_i*XBAR_NUM_OUT + xbar_out_i]  <= sched_rd_en[xbar_in_i*XBAR_NUM_OUT + xbar_out_i];
                end
            end
        end

        // Generate input decoders
        for (xbar_in_i = 0; xbar_in_i < XBAR_NUM_IN; xbar_in_i = xbar_in_i + 1) begin: xbar_decoder_gen
            decoder_for_xbar #(.DIN_WIDTH(XBAR_ID_OUTBITS)) decoder
            (
                .fifo_state (xbar_fifo_full[xbar_in_i*XBAR_NUM_OUT +: XBAR_NUM_OUT]),
                .din_en     (ready & din_en[xbar_in_i]),
                .din        (fifo_wr_id[xbar_in_i*XBAR_ID_WIDTH+XBAR_ID_LOW +: XBAR_ID_OUTBITS]),
                .one_hot    (fifo_wr_en[xbar_in_i*XBAR_NUM_OUT +: XBAR_NUM_OUT])
            );
        end

        // Generate schedulers
        for (xbar_out_i = 0; xbar_out_i < XBAR_NUM_OUT; xbar_out_i = xbar_out_i + 1) begin: xbar_scheduler_gen
            xbar_scheduler #(
                .LEN_WIDTH(4),
                .ID_WIDTH(FIFO_ID_WIDTH)
            ) sched (
                .len        (sched_data_count[xbar_out_i*XBAR_NUM_IN*FIFO_DEPTH_BITS +: XBAR_NUM_IN*FIFO_DEPTH_BITS]),
                .id         (fixed_fifo_id),
                .len_out    (),
                .id_out     (sched_fifo_id[xbar_out_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH])
            );
            
            decoder_for_xbar #(.DIN_WIDTH(FIFO_ID_WIDTH))
            sched_decoder (
                // It should be replaced by fifo_empty signals from this column
                .fifo_state (sched_fifo_empty[xbar_out_i*XBAR_NUM_IN +: XBAR_NUM_IN]),
                .din_en     (ready),
                .din        (sched_fifo_id[xbar_out_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH]),
                .one_hot    (sched_rd_en[xbar_out_i*XBAR_NUM_IN +: XBAR_NUM_IN])
            );
            
            // True output enable signal has one cycles delay
            always @(*) begin
                if (!rst)
                    dout_en_i[xbar_out_i] =  1'b0;
                else
                    dout_en_i[xbar_out_i] =  |output_en[xbar_out_i * XBAR_NUM_IN +: XBAR_NUM_IN];
            end
            
            always @(posedge clk) begin
                if (!rst) begin
                    output_id_select[xbar_out_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH] <=  {FIFO_ID_WIDTH {1'b0}};
                end else begin
                    output_id_select[xbar_out_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH] <=  sched_fifo_id[xbar_out_i*FIFO_ID_WIDTH +: FIFO_ID_WIDTH];
                end
            end

            assign  dout_id_i[xbar_out_i*XBAR_ID_WIDTH +: XBAR_ID_WIDTH]          =
                    fifo_rd_id[(output_id_select[xbar_out_i*FIFO_ID_WIDTH+:FIFO_ID_WIDTH]*XBAR_NUM_OUT+xbar_out_i)*XBAR_ID_WIDTH +: XBAR_ID_WIDTH];
            assign  dout_data_i[xbar_out_i*XBAR_DATA_WIDTH +: XBAR_DATA_WIDTH]    =
                    fifo_rd_data[(output_id_select[xbar_out_i*FIFO_ID_WIDTH+:FIFO_ID_WIDTH]*XBAR_NUM_OUT+xbar_out_i)*XBAR_DATA_WIDTH +: XBAR_DATA_WIDTH];

        end
        
    endgenerate
    
endmodule
