`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:35:42 10/27/2014 
// Design Name: 
// Module Name:    DataPeakStage2Buffer 
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
module DataPeakStage2Buffer(
    input [31:0] DataIn,
    input FastTrigger,
    input DataClk,	//ADC data clock ~250mhz
    input SysClk,		//System clock ~100mhz
    input Reset,
	 input DataRead,
    output DataAvailable,
	 output DataValid,
	 output [7:0] DataOut	 
    );
	 
	 wire [31:0] s1DataOut;
	 wire [7:0] s2DataOut;
	 wire s2Full;
	 wire s2Empty;
	 wire s2Valid;
	 wire s2WrEn, s2RdEn;
	 wire s2AlmostFull, s2AlmostEmpty;
	 
	 wire s1RdEn, s1DataReady, s1DataValid;
	 
	 //Automatically transfer data to stage 2 when ready
	 assign s1RdEn = s1DataReady;
	 assign s2WrEn = s1DataValid;
	 assign s2RdEn = DataRead;
	 assign DataOut = s2DataOut;
	 assign DataAvailable = ~s2Empty;
	 assign DataValid = s2Valid;
		
	 //Slow FIFO data width converter from 4 parallel bytes to 1 byte
	 //second fifo stage - i.e. s2
	 Fifo32x128and8x512 fifo_stage_2 (
	  .rst(Reset), // input rst
	  .wr_clk(SysClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(s1DataOut), // input [31 : 0] din
	  .wr_en(s2WrEn), // input wr_en
	  .rd_en(s2RdEn), // input rd_en
	  .dout(s2DataOut), // output [7 : 0] dout
	  .full(s2Full), // output full
	  .almost_full(s2AlmostFull), // output almost_full
	  .empty(s2Empty), // output empty
	  .almost_empty(s2AlmostEmpty), // output almost_empty
	  .valid(s2Valid) // output valid
	 );
	 
	 DataCaptureInitialFIFOs fifos_stage_1 (
     .DataIn(DataIn), 
     .FastTrigger(FastTrigger), 
     .EnableDataCapture(s2Empty), 
     .RdEn(s1RdEn), 
     .DataClk(DataClk), 
     .SysClk(SysClk), 
     .Reset(Reset), 
     .s1DataOut(s1DataOut), 
     .DataReady(s1DataReady), 
     .DataValid(s1DataValid)
    );
		
endmodule
