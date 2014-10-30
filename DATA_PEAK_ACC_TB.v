`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:43:21 10/27/2014
// Design Name:   DataPeakAccumulate
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_PEAK_ACC_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataPeakAccumulate
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_PEAK_ACC_TB;

	// Inputs
	reg [31:0] DataIn;
	reg FastTrigger;
	reg TxEnable;
	reg DataClk;
	reg SysClk;
	reg Reset;
	reg [7:0] inputData = 8'd0;

	// Outputs
	wire [7:0] DataOut;
	wire DataReady;

	//assign DataIn = {inputData, inputData, inputData, inputData};

	// Instantiate the Unit Under Test (UUT)
	DataPeakAccumulate uut (
		.DataIn(DataIn), 
		.FastTrigger(FastTrigger), 
		.TxEnable(TxEnable), 
		.DataClk(DataClk), 
		.SysClk(SysClk), 
		.Reset(Reset),
		.DataReady(DataReady),
		.DataValid(DataValid),
		.DataOut(DataOut)
	);	
	
//	reg [31:0] [0:127]storedData;
	integer i;
	integer array[0:127];
	initial begin
		for (i = 0; i < 128; i = i + 1) begin
			array[i] = $random;
		end
	end

	initial begin
		// Initialize Inputs
		FastTrigger = 0;
		TxEnable = 0;
		Reset = 1;

		// Wait 100 ns for global reset to finish
		#100 Reset = 0;
		// Add stimulus here

	end
	
	initial begin
	FastTrigger = 0;
	forever begin
		#6000 FastTrigger = 1;
		#4 FastTrigger = 0;
		end
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

	reg [7:0] indexCount; 

	always@(posedge DataClk) begin
		if(FastTrigger) begin
			indexCount <= 0;
			DataIn <= 8'd0;
		end
		else begin
			indexCount <= indexCount + 1;
			DataIn <= array[indexCount]; //$random; //inputData + 1;
		end
	end
	
	always@(posedge DataClk) begin
		TxEnable <= DataReady;
	end

      
endmodule

