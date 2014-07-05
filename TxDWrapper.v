`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:21:34 06/26/2013 
// Design Name: 
// Module Name:    TxDWrapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TxDWrapper(
	input Clock,
	input Reset,
	input [7:0] ADCData,
	input [7:0] generalData,
	input generalDataWrite,			//Should strobe once to write general data to FIFO
	input adcDataStreamingMode,	//this should be connected to ADC fifo NOT EMPTY
	input adcDataValid,				//use this txd_start signal
	output adcDataStrobe,
	output SDO
   );

	wire [7:0] TxData;
	wire fifoRd, fifoFull, fifoEmpty, fifoValid;
	wire [7:0] fifoOut;

	//Muxes for various signals to switch between adc data and general UART data
	assign fifoRd = adcDataStreamingMode ? 1'b0 : ((~fifoEmpty) && (~TxDBusy));
	assign TxData = adcDataStreamingMode ?  ADCData : fifoOut;
	assign TxDStart = adcDataStreamingMode ?  adcDataValid : fifoValid;
	assign adcDataStrobe = adcDataStreamingMode ? (~TxDBusy) : 1'b0;	
				
	async_transmitter txd (
		 .clk(Clock), 
		 .TxD_start(TxDStart), 
		 .TxD_data(TxData), 
		 .TxD(SDO), 
		 .TxD_busy(TxDBusy)
		 );
		 
	//32 byte uart tx fifo	 
	UART_FIFO uart_fifo_32 (
	  .clk(Clock), // input clk
	  .rst(1'b0), // input rst
	  .din(generalData), // input [7 : 0] din
	  .wr_en(generalDataWrite), // input wr_en
	  .rd_en(fifoRd), // input rd_en
	  .dout(fifoOut), // output [7 : 0] dout
	  .full(fifoFull), // output full
	  .empty(fifoEmpty), // output empty
	  .valid(fifoValid) // output valid
	);

endmodule
