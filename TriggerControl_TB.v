`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:37:09 02/22/2014
// Design Name:   TriggerControl
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/TriggerControl_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TriggerControl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TriggerControl_TB;

	// Inputs
	reg clk;
	reg t_p;
	reg t_n;
	reg armed;
	reg t_reset;

	// Outputs
	wire triggered;
	wire comp_reset_high;
	wire comp_reset_low;

	// Instantiate the Unit Under Test (UUT)
	TriggerControl uut (
		.clk(clk), 
		.t_p(t_p), 
		.t_n(t_n), 
		.armed(armed), 
		.t_reset(t_reset), 
		.triggered(triggered), 
		.comp_reset_high(comp_reset_high), 
		.comp_reset_low(comp_reset_low)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		t_p = 0;
		t_n = 1;
		armed = 0;
		t_reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
      armed = 1;
		#50 t_p = 1;
		t_n = 0;
		#50 t_reset = 1;
		#20 t_reset = 0;
		  
		// Add stimulus here

	end
      
	always
		#2 clk = ~clk; 
		
endmodule

