`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:07:37 01/06/2014
// Design Name:   ADC_FSM
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ADC_FSM_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ADC_FSM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ADC_FSM_TB;

	// Inputs
	reg Clock;
	reg Reset;
	reg [7:0] Cmd;
	reg OutToADC;

	// Outputs
	wire ADCPower;
	wire AnalogPower;
	
	wire OutToADCEnable = (OutToADC && ADCPower);
	// Instantiate the Unit Under Test (UUT)
	ADC_FSM uut (
		.Clock(Clock), 
		.Reset(1'b0), 
		.Cmd(Cmd), 
		.OutToADCEnable(OutToADCEnable), 
		.ADCPower(ADCPower), 
		.AnalogPower(AnalogPower)
	);

	initial begin
		// Initialize Inputs
		Clock = 1;
		Reset = 0;
		Cmd = 0;
		OutToADC = 1;

		// Wait 100 ns for global reset to finish
		#100;
		#20 Cmd = "O";
		#10 Cmd = 8'bzzzzzzzz;
		#60 Cmd = "o";		
		#10 Cmd = 8'bzzzzzzzz;
		#20 Cmd = "O";
		#10 Cmd = 8'bzzzzzzzz;
		#20 Cmd = "P";
		#10 Cmd = 8'bzzzzzzzz;
		#100 Cmd = "P";
		#10 Cmd = 8'bzzzzzzzz;
		#20 Cmd = "p";
		#10 Cmd = 8'bzzzzzzzz;
		#20 Cmd = "P";
		#10 Cmd = 8'bzzzzzzzz;
		#7 OutToADC = 0;
		#20 Cmd = "o";		
		#10 Cmd = 8'bzzzzzzzz;
	end
	
	always 
		#5 Clock = !Clock;
      
endmodule

