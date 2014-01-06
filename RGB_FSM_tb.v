`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:26 12/23/2013 
// Design Name: 
// Module Name:    RGB_FSM_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RGB_FSM_tb(
    );

reg clk;
reg [7:0] DataRxD;
wire [2:0] rgb;

RGBFSM RGBControl(
	.Clock(clk),
	.Reset(1'b0),
	.Cmd(DataRxD),
	.RGB(rgb)
	);


	initial
	begin
		clk = 0;
		DataRxD = 0;
	end
	
	always
		#5 clk = !clk;
		
	initial
	begin
		#50 DataRxD <= 8'd82;
		#50 DataRxD <= 8'd82;
		#50 DataRxD = 8'd71;
		#50 DataRxD = 8'd71;
		#50 DataRxD = 8'd66;
		#50 DataRxD = 8'd66;
	end

endmodule
