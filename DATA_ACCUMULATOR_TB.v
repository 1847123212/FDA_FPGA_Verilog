`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:07:31 07/03/2014
// Design Name:   DataAccumulator
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_ACCUMULATOR_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataAccumulator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_ACCUMULATOR_TB;

	// Inputs
	reg clk, clkSlow;
	reg [7:0] inputData;
	reg dataCaptureStrobe;
	reg dataRead;
	reg rst;

	// Outputs
	wire dataReadyToRead, dataEmpty;
	wire [17:0] dataOut;

	// Instantiate the Unit Under Test (UUT)
	DataAccumulator uut (
		.clk(clk), 
		.clkSlow(clkSlow), 
		.inputData(inputData), 
		.dataCaptureStrobe(dataCaptureStrobe), 
		.dataRead(dataRead), 
		.rst(rst), 
		.dataReadyToRead(dataReadyToRead),
		.dataEmpty(dataEmpty), 
		.dataOut(dataOut)
	);

	initial begin
		// Initialize Inputs
		inputData = 0;
		dataRead = 0;
		rst = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
		rst = 1;
		#4 rst = 0;
		// Add stimulus here

	end
      
	always@(posedge clk) begin
		if(dataCaptureStrobe)
			inputData <= 8'd0;
		else
			inputData <= inputData + 1;
	end

	always@(posedge clk)
		if(~dataReadyToRead)
			dataRead <= 0;
		else 
			dataRead <= 1;
		
	initial begin
	  clk = 0;
	  //#100;
	  forever begin
		 #2 clk = ~clk;
	  end
	end	
		
	initial begin
	  clkSlow = 0;
	  //#100;
	  forever begin
		 #5 clkSlow = ~clkSlow;
	  end
	end		
		
	initial begin
		dataCaptureStrobe = 0;
		forever begin
			#1000 dataCaptureStrobe = 1;
			#4 dataCaptureStrobe = 0;
		end
	end
endmodule

