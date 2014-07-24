`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:37:12 07/02/2014
// Design Name:   TriggerControl
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/TRIGGER_CONTROL_TB.v
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

module TRIGGER_CONTROL_TB;

	// Inputs
	reg clk;
	reg t_p;
	reg t_n;
	reg armed;
	reg module_reset;
	reg manual_reset;
	reg manual_trigger;
	reg auto_reset;

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
		.module_reset(module_reset), 
		.manual_reset(manual_reset), 
		.auto_reset(auto_reset),
		.manual_trigger(manual_trigger),
		.triggered_out(triggered), 
		.comp_reset_high(comp_reset_high), 
		.comp_reset_low(comp_reset_low)
	);

	initial begin
		// Initialize Inputs
		t_p = 0;
		t_n = 1;
		armed = 0;
		module_reset = 1;
		manual_reset = 0;
		auto_reset = 0;
		manual_trigger = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
		module_reset = 0;
		#50
		t_p = 1;
		t_n = 0;
		#12
		manual_reset = 1;
		#10
		manual_reset = 0;
		#12
		t_p = 0;
		t_n = 1;
		#12 armed = 1;
		#12 t_p = 1;
		t_n = 0;
		#28 manual_reset = 1;
		#4
		manual_reset = 0;
		#12
		t_p = 0;
		t_n = 1;
		#24 auto_reset = 1;
		#12 t_p = 1;
		t_n = 0;
      
		
		// Add stimulus here
	end
	
	initial begin
	  clk = 0;
	  #100;
	  forever begin
		 #2 clk = ~clk;
	  end
	end

	
	
endmodule

