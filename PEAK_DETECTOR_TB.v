`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:58:02 10/27/2014
// Design Name:   PeakDetector
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/PEAK_DETECTOR_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PeakDetector
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module PEAK_DETECTOR_TB;

	// Inputs
	reg clk;
	reg [7:0] DIn;
	reg [7:0] minLevel;
	reg rst;
	reg enable;

	// Outputs
	wire pkDetected;
	wire [7:0] DOut;

	// Instantiate the Unit Under Test (UUT)
	PeakDetector uut (
		.clk(clk), 
		.DIn(DIn), 
		.minLevel(minLevel), 
		.rst(rst), 
		.enable(enable), 
		.pkDetected(pkDetected), 
		.DOut(DOut)
	);

	initial begin
		// Initialize Inputs
		DIn = 0;
		minLevel = 128;
		rst = 1;
		enable = 1;

		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		rst = 0;
		#10 DIn = 130;
		#10 DIn = 130;
		#10 DIn = 130;
		#10 DIn = 125;
		#10 DIn = 100;
		#10 DIn = 110;
		#10 DIn = 120;
		#10 DIn = 130; 
		#10 DIn =130;
		#10 DIn =50;
		#10 DIn =130;

	end
      
	initial begin
	  clk = 0;
	  forever begin
		 #5 clk = ~clk;
	  end
	end	
		
endmodule

