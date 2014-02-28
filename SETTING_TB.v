`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:46:03 02/27/2014
// Design Name:   SystemSetting
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/SETTING_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SystemSetting
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SETTING_TB;

	// Inputs
	reg clk;
	reg turnOn;
	reg turnOff;
	reg toggle;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	SystemSetting uut (
		.clk(clk), 
		.turnOn(turnOn), 
		.turnOff(turnOff), 
		.toggle(toggle), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		turnOn = 0;
		turnOff = 0;
		toggle = 0;

		// Wait 100 ns for global reset to finish
		#100; 
		//Test turning on
		turnOn = 1;
		#10 turnOn = 0;
		
		//Test turn on while already on
		#50 turnOn = 1;
		#10 turnOn = 0;
		//test turn off from on state
		#50 turnOff = 1;
		#10 turnOff = 0;
		//Test turn off when off
		#50 turnOff = 1;
		#10 turnOff = 0;
		//Test toggle to on
		#50 toggle = 1;
		#10 toggle = 0;
		//Test toggle to off
		#50 toggle = 1;
		#10 toggle = 0;
	end
      
	always
		#5 clk = ~clk;
		
endmodule

