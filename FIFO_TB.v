`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:32:34 01/08/2014
// Design Name:   DataStorage
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FIFO_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataStorage
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FIFO_TB;

	// Inputs
	reg [7:0] DQ;
	reg [7:0] DQD;
	reg [7:0] DI;
	reg [7:0] DID;
	wire [31:0] DataIn;
	wire WriteEnable;
	reg ReadEnable;
	reg WriteClock;
	reg WriteClockDelayed;
	reg ReadClock;
	reg Reset;

	// Outputs
	wire [7:0] DataOut;
	wire DataValid;
	wire FifoNotFull;
	wire DataReadyToSend;

	// Instantiate the Unit Under Test (UUT)
	DataStorage uut (
		.DataIn(DataIn), 
		.DataOut(DataOut), 
		.WriteEnable(FifoNotFull), 
		.ReadEnable(ReadEnable), 
		.WriteClock(WriteClock), 
		.WriteClockDelayed(WriteClockDelayed), 
		.ReadClock(ReadClock), 
		.Reset(Reset), 
		.DataValid(DataValid), 
		.FifoNotFull(FifoNotFull), 
		.DataReadyToSend(DataReadyToSend)
	);

	assign DataIn = {DI, DID, DQ, DQD};
	assign WriteEnable = 1;
	
	initial begin
		// Initialize Inputs
//		WriteEnable = 0;
		ReadEnable = 1;
		WriteClock = 0;
		WriteClockDelayed = 0;
		ReadClock = 0;
		Reset = 0;
		DQ = 8'd2;
		DI = 8'd3;
		DQD = 8'd0;
		DID = 8'd1;

		// Wait 100 ns for global reset to finish
		#100;
		#500;	//FIFOS take a while 
		
	end
      
	always begin
		#2 WriteClock = ~WriteClock;
		WriteClockDelayed = WriteClock;
	end
	
	always
		#5 ReadClock = ~ReadClock;

	always@(posedge ReadClock) begin
		ReadEnable = ~ReadEnable;
	end 


endmodule

