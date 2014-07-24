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
	reg signed [7:0] inputData;
	reg dataCaptureStrobe;
	reg dataRead;
	reg rst;
	reg capturingData;

	// Outputs
	wire dataReadyToRead, dataEmpty;
	wire signed [15:0] dataOut;

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

	reg goingDown;
      
	always@(posedge clk) begin
		if(~capturingData)
			inputData <= -8'd3;
		else if(goingDown)
			inputData <= inputData - 1;
		else
			inputData <= inputData + 1;
	end

	always@(posedge clkSlow)
		if(~dataReadyToRead)
			dataRead <= 0;
		else if(drCount == 3'd0)
				dataRead <= 1;
			else
				dataRead <= 0;
			
	reg [2:0] drCount = 3'd0;
	always@(posedge clkSlow)
		drCount <= drCount + 1;
		
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
		capturingData = 0;
		goingDown = 1;
		forever begin
			#1002 dataCaptureStrobe = 1;
			capturingData = 1;
			goingDown = 1;
			#4 dataCaptureStrobe = 0;
			#40 goingDown = 0;
			#468 capturingData = 0;
		end
	end
endmodule

