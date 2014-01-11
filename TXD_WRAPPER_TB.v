`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:04:44 01/08/2014
// Design Name:   TxDWrapper
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/TXD_WRAPPER_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TxDWrapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TXD_WRAPPER_TB;

	// Inputs
	reg Clock;
	reg Reset;
	reg [15:0] Data;
	wire [1:0] LatchData;

	reg LatchA;
	// Outputs
	wire [1:0] Busy;
	wire SDO;

	// Instantiate the Unit Under Test (UUT)
	TxDWrapper uut (
		.Clock(Clock), 
		.Reset(Reset), 
		.Data(Data), 
		.LatchData(LatchData), 
		.Busy(Busy), 
		.SDO(SDO)
	);

	initial begin
		// Initialize Inputs
		Clock = 0;
		Reset = 0;
		Data = 16'b1111000010101010;
		//LatchData = 0;
		LatchA = 1;

		// Wait 100 ns for global reset to finish
		#100;
		
		#500 LatchA = 0;
        
		// Add stimulus here

	end
    	
	always 
		#5 Clock = ~Clock;
		
	assign LatchData[1] = (~Busy[1] & LatchA);	
	assign LatchData[0] = (~Busy[0] & ~LatchA);
		
endmodule

