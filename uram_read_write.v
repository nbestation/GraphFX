`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2017 03:37:28 PM
// Design Name: 
// Module Name: uram_read_write
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


module uram_read_write(
input               clk,
input               rst,
input   	[15:0]	addra,
input		[71:0]  dina,
output  reg	[71:0]	douta,
input		[15:0]	addrb,
input		[71:0]	dinb,
output 	reg [71:0]	doutb,
input		[2:0]	mode,
input		[0:0]	valid,
output	reg	[0:0]	validout
);

reg		[15:0]		addra_delay1;
reg		[71:0]		dina_delay1;
reg		[2:0]		mode_delay1;

always @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
	end
	else
	begin
		addra_delay1		<=	addra;
		dina_delay1			<=	dina;
		mode_delay1			<=	mode;		
	end
end


wire				dst_ram_clk;
wire				dst_ram_rst;
reg		[15:0]		dst_ram_addra;
reg		[0:0]		dst_ram_wea;
reg		[71:0]		dst_ram_dina;
wire	[71:0]		dst_ram_douta;
reg		[15:0]		dst_ram_addrb;
reg		[0:0]		dst_ram_web;
reg		[71:0]		dst_ram_dinb;
wire	[71:0]		dst_ram_doutb;

assign dst_ram_clk = clk;
assign dst_ram_rst = ~rst;

always @(*)
begin
	if (valid)
	begin
		/*case (mode)
		
		3'b000://idle
		begin
			if (mode_delay1 == 3'b010)
			begin
				dst_ram_addra	=	addra_delay1;
				dst_ram_wea		=	1'b1;
				dst_ram_dina	=	dst_ram_doutb + dina_delay1;//update function			
			end
			else
			begin
				dst_ram_wea		=	1'b0;
				dst_ram_web		=	1'b0;
			end
		end
		
		3'b001://initialize dst ram
		begin
			dst_ram_addra	=	addra;
			dst_ram_wea		=	1'b1;
			dst_ram_dina	=	dina;
			dst_ram_addrb	=	addrb;
			dst_ram_web		=	1'b1;
			dst_ram_dinb	=	dinb;
		end
		
		3'b010://update dst ram
		begin
			dst_ram_addra	=	addra_delay1;
			dst_ram_wea		=	1'b1;
			dst_ram_dina	=	dst_ram_doutb + dina_delay1;//update function
			dst_ram_addrb	= 	addra;
			dst_ram_web		=	1'b0;			
		end
		
		3'b011://read dst ram
		begin
			dst_ram_addra	=	addra;
			dst_ram_wea		=	1'b0;
			douta			=	dst_ram_douta;
			dst_ram_addrb	=	addrb;
			dst_ram_web		=	1'b0;
			doutb			=	dst_ram_doutb;
		end
		
		endcase*/
		case (mode)
		
			3'b000://idle
			begin
				dst_ram_web		=	1'b0;
			end
					
			3'b001://initialize dst ram
			begin

				dst_ram_addrb	=	addrb;
				dst_ram_web		=	1'b1;
				dst_ram_dinb	=	dinb;
			end
			
			3'b010://update dst ram
			begin
				dst_ram_addrb	= 	addra;
				dst_ram_web		=	1'b0;
			end
			
			3'b011://read dst ram
			begin
				dst_ram_addrb	=	addrb;
				dst_ram_web		=	1'b0;
				doutb			=	dst_ram_doutb;
			end
		
		endcase
		
		casex ({mode,mode_delay1})
		
			6'b000000,6'b000001,6'b000011:
			begin
				dst_ram_wea		=	1'b0;
			end
			
			6'b001xxx:
			begin
				dst_ram_addra	=	addra;
				dst_ram_wea		=	1'b1;
				dst_ram_dina	=	dina;		
			end
			
			6'b010010,6'b000010,6'b010000:
			begin
				dst_ram_addra	=	addra_delay1;
				if (mode_delay1 == 3'b010)
				begin
					dst_ram_wea		=	1'b1;
				end
				else
				begin
					dst_ram_wea		=	1'b0;
				end
				dst_ram_dina	=	dst_ram_doutb + dina_delay1;//update function			
			end
			
			6'b011xxx:
			begin
				dst_ram_addra	=	addra;
				dst_ram_wea		=	1'b0;
				douta			=	dst_ram_douta;			
			end
		
		endcase
	end
end

uram_basic DST_RAM( 
.clk(dst_ram_clk),
.rst(dst_ram_rst),
.addra(dst_ram_addra),
.wea(dst_ram_wea),
.dina(dst_ram_dina),
.douta(dst_ram_douta),
.addrb(dst_ram_addrb),
.web(dst_ram_web),
.dinb(dst_ram_dinb),
.doutb(dst_ram_doutb)
);

endmodule
