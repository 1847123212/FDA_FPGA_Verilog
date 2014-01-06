`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:52:50 01/05/2014 
// Design Name: 
// Module Name:    ADCPowerFSM_TB 
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
module ADCPowerFSM_TB(
    );

	reg clk;
	reg [7:0] DataRxD;
	wire ADCPower;

	ADCPowerFSM DUT (
    .Clock(clk), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .ADCPower(ADCPower)
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
		#55 DataRxD <= 8'd79;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd79;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd111;
		#10 DataRxD <= 8'bzzzzzzzz;
		#50 DataRxD <= 8'd79;
		#10 DataRxD <= 8'bzzzzzzzz;
	end



endmodule
