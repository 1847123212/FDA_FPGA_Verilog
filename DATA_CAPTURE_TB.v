`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:25:44 07/24/2014
// Design Name:   DataCapture
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_CAPTURE_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataCapture
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_CAPTURE_TB;

	// Inputs
	reg clk;
	reg clkSlow;
	reg [7:0] inputData;
	reg dataCaptureStrobe;
	reg dataRead;
	reg rst;

	// Outputs
	wire dataReadyToRead;
	wire dataValid;
	wire dataEmpty;
	wire [15:0] dataOut;

	// Instantiate the Unit Under Test (UUT)
	DataCapture uut (
		.clk(clk), 
		.clkSlow(clkSlow), 
		.inputData(inputData), 
		.dataCaptureStrobe(dataCaptureStrobe), 
		.dataRead(dataRead), 
		.rst(rst), 
		.dataReadyToRead(dataReadyToRead), 
		.dataValid(dataValid), 
		.dataEmpty(dataEmpty), 
		.dataOut(dataOut)
	);

	initial begin
		// Initialize Inputs
		inputData = 0;
		dataCaptureStrobe = 0;
		dataRead = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
        
		// Add stimulus here

	end
      
	initial begin
		dataCaptureStrobe = 0;
		#2
		forever begin
			#1000 dataCaptureStrobe = 1;
			#4 dataCaptureStrobe = 0;
		end
	end

	always@(posedge clk) begin
		if(dataCaptureStrobe)
			inputData <= 8'd0;
		else
			inputData <= inputData + 1;
	end
	
	reg [1:0] cnt = 2'b00;
	
	always@(posedge clkSlow) begin
		cnt<=cnt+1;
		if(dataReadyToRead & cnt == 2'b11)
			dataRead <= 1'b1;
		else
			dataRead <= 1'b0;
	end
	

	initial begin
	  clk = 0;
	  forever begin
		 #2 clk = ~clk;
	  end
	end	
		
	initial begin
	  clkSlow = 0;
	  forever begin
		 #5 clkSlow = ~clkSlow;
	  end
	end		
		
endmodule

