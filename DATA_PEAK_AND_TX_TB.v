`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:18:13 10/29/2014
// Design Name:   DataPeakAccumulate
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/DATA_PEAK_AND_TX_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: Test bench for verifying how DataPeakAccumulate works with the serial communication module
// TxDWrapper.
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

module DATA_PEAK_AND_TX_TB;

	// Inputs
	reg triggered;		//Trigger signal to start collecting data
	reg AdcClk;
	reg clk;
	reg [7:0] txData;
	reg txDataWr;
	reg [31:0] ADCRegDataOut;		//DQD, DQ, DID, DI

	// Outputs
	wire DataValid;
	wire DataReadyToSend;
	wire [7:0] StoredDataOut;	//data from ADC fifos
	wire USB_RS232_TXD;
	wire adcDataRead;
	
	wire DataReadEnable;
	assign DataReadEnable = adcDataRead & (~DataValid);

	// Instantiate the Unit Under Test (UUT)
	DataPeakAccumulate data_acc_uut (
		.DataIn(ADCRegDataOut), 
		.FastTrigger(triggered), 
		.TxEnable(DataReadEnable), 
		.DataClk(AdcClk), 
		.SysClk(clk), 
		.Reset(1'b0), 
		.DataReady(DataReadyToSend), 
		.DataValid(DataValid), 
		.DataOut(StoredDataOut)
	);
	
	// Instantiate the module
	TxDWrapper tx_uut (
    .Clock(clk), 
    .Reset(1'b0), 
    .ADCData(StoredDataOut), 
    .generalData(txData), 
    .generalDataWrite(txDataWr), 
    .adcDataStreamingMode(DataReadyToSend), 
    .adcDataValid(DataValid), 
    .adcDataStrobe(adcDataRead), 
    .SDO(USB_RS232_TXD)
    );

	initial begin
		// Initialize Inputs
		txData = 8'd0;
		txDataWr = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#6000 triggered = 1;
		#4 triggered = 0;
		#6000 triggered = 1;
		#4 triggered = 0;
		#6000 triggered = 1;
		#4 triggered = 0;
		#6000 triggered = 1;
		#4 triggered = 0;
		#6000 triggered = 1;
		#4 triggered = 0;
		#6000 triggered = 1;
		#4 triggered = 0;

	end
   
	//Create random, repeating data stream to simulate ADC data
	integer i;
	integer array[0:127];
	initial begin
		for (i = 0; i < 128; i = i + 1) begin
			array[i] = $random;
		end
	end	
	
/**	initial begin
	triggered = 0;
	forever begin
		#6000 triggered = 1;
		#4 triggered = 0;
		end
	end
**/	
	initial begin
	  clk = 0;
	  forever begin
		 #5 clk = ~clk;
	  end
	end

	initial begin
	  AdcClk = 0;
	  forever begin
		 #2 AdcClk = ~AdcClk;
	  end
	end

	reg [7:0] indexCount; 

	always@(posedge AdcClk) begin
		if(triggered) begin
			indexCount <= 1;
			ADCRegDataOut <= array[0];
		end
		else begin
			indexCount <= indexCount + 1;
			ADCRegDataOut <= array[indexCount]; //$random; //inputData + 1;
		end
	end
		
endmodule

