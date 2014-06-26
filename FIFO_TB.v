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
	reg WriteStrobe;
	reg [11:0] ProgFullThresh;
	reg FastTrigger;
	
	// Outputs
	wire [7:0] DataOut;
	wire DataValid;
	wire DataReadyToSend;
	wire [1:0] State;
	

	// Instantiate the Unit Under Test (UUT)
	DataStorage uut (
		.DataIn(DataIn), 
		.DataOut(DataOut), 
		.WriteStrobe(WriteStrobe),
		.ReadEnable(ReadEnable), 
		.WriteClock(WriteClock),
		.ReadClock(ReadClock), 
		.Reset(Reset), 
		.DataValid(DataValid), 
		.DataReadyToSend(DataReadyToSend),
		.State(State),
		.ProgFullThresh(ProgFullThresh),
		.FastTrigger(FastTrigger)
	);
	
	assign DataIn = {DI, DID, DQ, DQD};
	assign WriteEnable = 1;
	
	initial begin
		// Initialize Inputs
//		WriteEnable = 0;
		ReadEnable = 1;
		ReadClock = 0;
		Reset = 1;
		DQ = 8'd2;
		DI = 8'd3;
		DQD = 8'd0;
		DID = 8'd1;
		ProgFullThresh = 12'd32;
	end
      
	initial begin
		WriteStrobe = 0;
		#1005 WriteStrobe = 1;
		#10 WriteStrobe = 0;
	end
	
	initial begin
	  WriteClock = 0;
	  #500;
	  forever begin
		 #2 WriteClock = ~WriteClock;
		 WriteClockDelayed = WriteClock;
	  end
	end
	
	initial begin
		#580
		Reset = 0;
	end
	
	always
		#5 ReadClock = ~ReadClock;

	always@(posedge ReadClock) begin
		ReadEnable = ~ReadEnable;
	end 

	always@(posedge WriteClock) begin
		DQ = DQ + 4;
		DI = DI + 4;
		DQD = DQD + 4;
		DID = DID + 4;
	end
endmodule

