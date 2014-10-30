`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:32 10/28/2014
// Design Name:   DataPeakStage2Buffer
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_PEAK_S2_BUFFER_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataPeakStage2Buffer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_PEAK_S2_BUFFER_TB;

	// Inputs
	wire [31:0] DataIn;
	reg FastTrigger;
	reg DataClk;
	reg SysClk;
	reg Reset;
	reg DataRead;
	reg [7:0] inputData;
	assign DataIn = {inputData, inputData, inputData, inputData};

	// Outputs
	wire DataAvailable;
	wire DataValid;
	wire [7:0] DataOut;

	// Instantiate the Unit Under Test (UUT)
	DataPeakStage2Buffer uut (
		.DataIn(DataIn), 
		.FastTrigger(FastTrigger), 
		.DataClk(DataClk), 
		.SysClk(SysClk), 
		.Reset(Reset), 
		.DataRead(DataRead), 
		.DataAvailable(DataAvailable), 
		.DataValid(DataValid), 
		.DataOut(DataOut)
	);

	initial begin
		// Initialize Inputs
		FastTrigger = 0;
		DataClk = 0;
		SysClk = 0;
		Reset = 1;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		Reset = 0;
		#50 FastTrigger = 1;
		#4 FastTrigger = 0;
		
	end
      
	initial begin
	  SysClk = 0;
	  forever begin
		 #5 SysClk = ~SysClk;
	  end
	end

	initial begin
	  DataClk = 0;
	  forever begin
		 #2 DataClk = ~DataClk;
	  end
	end
	
	always@(posedge DataClk) begin
		if(FastTrigger)
			inputData <= 8'd0;
		else
			inputData <= inputData + 1;
	end
	
	always@(posedge SysClk)
		DataRead <= DataAvailable;
	
endmodule

