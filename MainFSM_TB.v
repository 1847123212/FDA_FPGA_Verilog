`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:56:11 02/27/2014
// Design Name:   Main_FSM
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/MainFSM_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Main_FSM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MainFSM_TB;

	// Inputs
	reg [7:0] Cmd;
	reg clk;
	reg NewCmd;

	// Outputs
	wire echoOn;
	wire echoOff;

	// Instantiate the Unit Under Test (UUT)
	Main_FSM uut (
		.Cmd(Cmd), 
		.clk(clk), 
		.NewCmd(NewCmd), 
		.echoOn(echoOn), 
		.echoOff(echoOff)
	);

	initial begin
		// Initialize Inputs
		Cmd = 0;
		clk = 1;
		NewCmd = 0;

		// Wait 100 ns for global reset to finish
		#100;
      Cmd = "E";
		NewCmd = 1;
		#10 NewCmd = 0;
		#50 Cmd = "E";
		NewCmd = 1;
		#10 NewCmd = 0;
		#50 Cmd = "e";
		NewCmd = 1;
		#10 NewCmd = 0;
		#50 Cmd = "e";
		NewCmd = 1;
		#10 NewCmd = 0;
	end
   
	always
		#5 clk = ~clk;
		
endmodule

