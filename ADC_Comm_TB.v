`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:00:30 12/23/2013 
// Design Name: 
// Module Name:    ADC_Comm_TB 
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
module ADC_Comm_TB(
    );

reg clk, init, des_en, des_dis;

wire sclk, sdata, select;

ADCExtendedControl DUT (
    .clk(clk), 
	 .init(init),
	 .des_enable(des_en),
	 .des_disable(des_dis),
    .sclk(sclk), 
    .sdata(sdata), 
    .select(select)
    );
	
	initial
	begin
		clk = 0;
		init = 0;
		des_en = 0;
		des_dis = 0;
		#100 des_en = 1;
		#10 des_en = 0;
		#6000 des_dis = 1;
		#10 des_dis = 0;
	end

	always
		#5 clk = !clk;

endmodule
