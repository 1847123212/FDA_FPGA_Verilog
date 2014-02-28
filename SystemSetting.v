`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:43:32 02/27/2014 
// Design Name: 
// Module Name:    SystemSetting 
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
module SystemSetting(
    input clk,
    input turnOn,
    input turnOff,
    input toggle,
    output out
    );

	reg Value = 0;
	assign out = Value;
	
	always@(posedge clk) begin
		if(turnOff)
			Value <= 1'b0;
		else if(turnOn)
			Value <= 1'b1;
		else if(toggle)
			Value <= ~Value;
	end
	
	
endmodule
