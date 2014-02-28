`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:27:20 02/22/2014
// Design Name:   DACControlFSM
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DAC_Controller_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DACControlFSM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DAC_Controller_TB;

	// Inputs
	reg clk;
	reg [7:0] UART_Rx;
	reg UART_DataReady;
	reg I2CBusy;
	reg I2CDataReady;

	// Outputs
	wire [7:0] UART_Tx;
	wire [6:0] I2Caddr;
	wire [15:0] I2Cdata;
	wire I2Cbytes;
	wire I2Cr_w;
	wire I2C_load;

	// Instantiate the Unit Under Test (UUT)
	DACControlFSM uut (
		.clk(clk), 
		.UART_Rx(UART_Rx), 
		.UART_DataReady(UART_DataReady), 
		.UART_Tx(UART_Tx), 
		.I2Caddr(I2Caddr), 
		.I2Cdata(I2Cdata), 
		.I2Cbytes(I2Cbytes), 
		.I2Cr_w(I2Cr_w), 
		.I2C_load(I2C_load), 
		.I2CBusy(I2CBusy), 
		.I2CDataReady(I2CDataReady)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		UART_Rx = 0;
		UART_DataReady = 0;
		I2CBusy = 0;
		I2CDataReady = 0;

		// Wait 100 ns for global reset to finish
		#100; 
		// Add stimulus here
		UART_Rx = "V";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "1";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "0";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "1";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "0";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "1";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "0";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "1";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "0";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "1";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;
		#50
		UART_Rx = "0";
		UART_DataReady = 1;
		#10
		UART_DataReady = 0;		
	end
	
always
	#5 clk = ~clk;
      
endmodule

