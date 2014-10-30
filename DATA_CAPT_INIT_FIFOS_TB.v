`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:25:01 10/28/2014
// Design Name:   DataCaptureInitialFIFOs
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_CAPT_INIT_FIFOS_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataCaptureInitialFIFOs
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_CAPT_INIT_FIFOS_TB;

	// Inputs
	wire [31:0] DataIn;
	reg FastTrigger;
	reg EnableDataCapture;
	reg RdEn;
	reg DataClk;
	reg SysClk;
	reg Reset;
	reg [7:0] inputData;

	// Outputs
	wire [31:0] s1DataOut;
	wire DataReady;
	wire DataValid;
	
	assign DataIn = {inputData, inputData, inputData, inputData};

	// Instantiate the Unit Under Test (UUT)
	DataCaptureInitialFIFOs uut (
		.DataIn(DataIn), 
		.FastTrigger(FastTrigger), 
		.EnableDataCapture(EnableDataCapture), 
		.RdEn(RdEn), 
		.DataClk(DataClk), 
		.SysClk(SysClk), 
		.Reset(Reset), 
		.s1DataOut(s1DataOut), 
		.DataReady(DataReady), 
		.DataValid(DataValid)
	);

	initial begin
		// Initialize Inputs
		//DataIn = 0;
		FastTrigger = 0;
		EnableDataCapture = 1;
		RdEn = 0;
		DataClk = 0;
		SysClk = 0;
		Reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
      Reset = 0;
		#50 FastTrigger = 1;
		#4 FastTrigger = 0;
		#700 RdEn = 1;
		
		// Add stimulus here

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



endmodule

