`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:01:46 02/21/2014
// Design Name:   I2C_Comm
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/I2C_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: I2C_Comm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module I2C_TB;

	// Inputs
	reg clk;
	reg load;
	reg [6:0] addr;
	reg numBytes;
	reg rd_wr;

	// Outputs
	wire SCL;
	wire busy;
	wire dataReady;

	// Bidirs
	wire SDA;
	wire [15:0] data;

	//Regs
	reg [15:0] wrData;

	// Instantiate the Unit Under Test (UUT)
	I2C_Comm uut (
		.clk(clk), 
		.SDA(SDA), 
		.SCL(SCL), 
		.data(data), 
		.load(load), 
		.addr(addr), 
		.numBytes(numBytes), 
		.rd_wr(rd_wr), 
		.busy(busy), 
		.dataReady(dataReady)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		load = 0;
		addr = 7'b1010101;
		numBytes = 0;
		rd_wr = 1;
		wrData = 16'b1010101010101010;

		#100;
		// Wait 100 ns for global reset to finish
      load = 1;
		#10
		load = 0;		

	end
    
	assign data = (load ==1) ? wrData : 16'bz; 
	always
		#5 clk = !clk;	 
		
endmodule

