`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:34:24 07/04/2014
// Design Name:   DataStorageAcc
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_STORAGE_ACC_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DataStorageAcc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module DATA_STORAGE_ACC_TB;

	// Inputs
	reg [7:0] inputData;
	reg dataCaptureStrobe;
	reg WriteClock;
	reg ReadClock;
	reg Reset;

	// Outputs
	wire [7:0] DataOut;
	wire DataReady, ReadEnable;
	reg [7:0] txData = 8'd0;
	reg txDataWr = 1'b1;
	
	// Instantiate the Unit Under Test (UUT)
	TxDWrapper UUT2 (
		 .Clock(ReadClock), 
		 .Reset(Reset), 
		 .ADCData(DataOut), 
		 .generalData(txData), 
		 .generalDataWrite(txDataWr), 
		 .adcDataStreamingMode(DataReady),  //input equal to adc fifo not empty
		 .adcDataValid(DataReady), 					//input to UART Start signal
		 .adcDataStrobe(ReadEnable),					//output to adc FIFO 
		 .SDO(USB_RS232_TXD)
		 );
	

	// Instantiate the Unit Under Test (UUT)
	DataStorageAcc uut (
		.DataIn({inputData, inputData, inputData, inputData}), 
		.DataOut(DataOut), 
		.FastTrigger(dataCaptureStrobe), 
		.ReadEnable(ReadEnable), 
		.WriteClock(WriteClock), 
		.ReadClock(ReadClock), 
		.Reset(Reset), 
		.DataReady(DataReady)
	);

	initial begin
		// Initialize Inputs
		dataCaptureStrobe = 0;
		Reset = 0;

		// Wait 100 ns for global reset to finish
		#100 Reset = 1;
		#10 Reset = 0;
		// Add stimulus here

	end
      
	initial begin
	  WriteClock = 0;
	  //#100;
	  forever begin
		 #2 WriteClock = ~WriteClock;
	  end
	end	
		
	initial begin
	  ReadClock = 0;
	  //#100;
	  forever begin
		 #5 ReadClock = ~ReadClock;
	  end
	end		
		
	initial begin
		dataCaptureStrobe = 0;
		forever begin
			#2000 dataCaptureStrobe = 1;
			#4 dataCaptureStrobe = 0;
		end
	end
	
	always@(posedge WriteClock) begin
		if(dataCaptureStrobe)
			inputData <= 8'd0;
		else
			inputData <= inputData + 1;
	end
		
//	reg [1:0] count = 0;	
//	always@(posedge ReadClock) begin
//		ReadEnable <= (count[0] == 1'b1);
//		if(~DataReady)
//			count <= 0;
//		else
//			count <= count + 1;
//	end
		
endmodule

