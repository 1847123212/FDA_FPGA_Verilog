`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:16:05 01/05/2014 
// Design Name: 
// Module Name:    AnalogPowerFSM_TB 
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
module AnalogPowerFSM_TB(
    );

	reg clk;
	reg [7:0] DataRxD;
	reg OutputEnable;
	wire AnalogPowerOut;

AnalogPowerFSM DUT (
    .Clock(clk), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .OutputEnable(OutputEnable), 
    .AnalogPowerEnable(AnalogPowerOut)
    );
	 
	initial
	begin
		clk = 0;
		DataRxD = 0;
		OutputEnable = 0;
	end
	
	always
		#5 clk = !clk;
		
	initial
	begin
		//enable is low
		#55 DataRxD <= 8'd80;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd112;
		#10 DataRxD <= 8'bzzzzzzzz;
		//enable is high
		#10 OutputEnable = 1;
		#50 DataRxD <= 8'd80;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd112;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd80;
		#10 DataRxD <= 8'bzzzzzzzz;
		#13 OutputEnable = 0;
	end
endmodule
