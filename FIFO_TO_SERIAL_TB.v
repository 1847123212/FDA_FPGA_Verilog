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

module FIFO_TO_SERIAL_TB;

	//inputs
	reg [31:0] ADCRegDataOut;
	reg fifoRecord;
	reg ADCClock;
	reg ADCClockDelayed;
	reg clk;
	reg txData;
	reg txDataWr;

	
	//UUT connectors
	wire [7:0] StoredDataOut;
	wire adcDataRead;
	wire DataValid;
	wire FifoNotFull;
	wire DataReadyToSend;
	wire fifoState;

	// Outputs
	wire USB_RS232_TXD;
	
	// Instantiate the Unit Under Test (UUT)
	DataStorage UUT1 (
    .DataIn(ADCRegDataOut), 
    .DataOut(StoredDataOut), 
    .WriteStrobe(fifoRecord),
    .ReadEnable(adcDataRead), 
    .WriteClock(ADCClock), 
    .WriteClockDelayed(ADCClockDelayed), 
    .ReadClock(clk), 
    .Reset(1'b0), 
    .DataValid(DataValid), 
    .FifoNotFull(FifoNotFull), 
    .DataReadyToSend(DataReadyToSend),
	 .State(fifoState)
    );

	TxDWrapper UUT2 (
		 .Clock(clk), 
		 .Reset(1'b0), 
		 .ADCData(StoredDataOut), 
		 .generalData(txData), 
		 .generalDataWrite(txDataWr), 
		 .adcDataStreamingMode(DataReadyToSend),  //input equal to adc fifo not empty
		 .adcDataValid(DataValid), 					//input to UART Start signal
		 .adcDataStrobe(adcDataRead),					//output to adc FIFO 
		 .SDO(USB_RS232_TXD)
		 );
	
	initial begin
		ADCRegDataOut = 32'd0;
		fifoRecord = 0;
		ADCClock = 1;
		ADCClockDelayed = 1;
		clk = 1;
		txData = 0;
		txDataWr =0;
		// Wait 100 ns for global reset to finish
		#100;
		#500;	//FIFOS take a while 
		fifoRecord = 1;
	end
      
	always begin
		#2 ADCClock = ~ADCClock;
			ADCClockDelayed = ADCClock;
	end
	
	always
		#5 clk = ~clk;
	
	always@(posedge 
		#4 ADCRegDataOut[31:24] = 8'b00110010; //ADCRegDataOut[31:24] + 1;
			ADCRegDataOut[23:16] = 8'b10101010; //ADCRegDataOut[23:16] + 1;
			ADCRegDataOut[15:8] = 8'b11001100; //ADCRegDataOut[15:8] + 1;
			ADCRegDataOut[7:0] = 8'b11110000; //ADCRegDataOut[7:0] + 1;
	end
	
endmodule
