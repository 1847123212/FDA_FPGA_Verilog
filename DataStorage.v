`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:30 01/08/2014 
// Design Name: 
// Module Name:    DataStorage 
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
module DataStorage(
    input [31:0] DataIn,
    output [7:0] DataOut,
    input WriteStrobe,
    input ReadEnable,
    input WriteClock,
    input WriteClockDelayed,
    input ReadClock,
    input Reset,
	 input [11:0] ProgFullThresh,
    output DataValid,
    output DataReadyToSend,
	 output [1:0] State
    ); 

wire FifoReadEn;
wire fullDI, emptyDI, validDI, fullDID, emptyDID, validDID, fullDQ, emptyDQ, validDQ, fullDQD, emptyDQD, validDQD;
wire progFullDI, progFullDID, progFullDQ, progFullDQD;
wire [31:0] FifoDataOut;	//This data is in chronological order: [31:25] is DQD (oldest), 
									// [24:16] is DID, [8:15] is DQ, [7:0] is DI 
wire ConverterWriteEn, ConverterFull, ConverterEmpty, ConverterValid;
wire FifosValid = (validDI & validDID & validDQ & validDQD);
wire FifosEmpty = (emptyDI | emptyDID | emptyDQ | emptyDQD);
reg FifosFull = 0;//(fullDI | fullDID | fullDQ | fullDQD);	
reg StoringData;

always@(posedge ReadClock)
	FifosFull <= (progFullDI | progFullDID | progFullDQ | progFullDQD);

assign DataReadyToSend = ~ConverterEmpty;

localparam 	RESET = 2'b00,
				READY_TO_STORE = 2'b01,
				STORING_DATA = 2'b10,
				SENDING_DATA = 2'b11;

reg [1:0] CurrentState = RESET;
reg [1:0] NextState = RESET;

assign State = CurrentState;

reg [1:0] WriteEnableEdgeFast = 2'b00;
reg [1:0] WriteEnableEdgeSlow = 2'b00;

reg WriteEnableDI, WriteEnableDID, WriteEnableDQ, WriteEnableDQD;

always@(posedge ReadClock) begin
	if(CurrentState == STORING_DATA) begin		
		WriteEnableDI <= 1'b1;
		WriteEnableDID <=1'b1;
		WriteEnableDQ <= 1'b1;
		WriteEnableDQD <= 1'b1;
	end
	else begin
		WriteEnableDI <= 1'b0;
		WriteEnableDID <= 1'b0;
		WriteEnableDQ <= 1'b0;
		WriteEnableDQD <= 1'b0;
	end
end

//WriteStrobe is synchronous to ReadClock

//Should add reset in here
always@(posedge WriteClock ) begin
	CurrentState <= NextState;		
	WriteEnableEdgeFast <= {WriteEnableEdgeFast[0], WriteStrobe};
end

always@(posedge ReadClock ) begin
	WriteEnableEdgeSlow <= {WriteEnableEdgeSlow[0], WriteStrobe};
end

always@(*) begin
	NextState = CurrentState;
	case (CurrentState)
		RESET: begin
			if(Reset == 1'b0) NextState = READY_TO_STORE;
		end
		READY_TO_STORE: begin
			if(WriteEnableEdgeFast == 2'b01) NextState = STORING_DATA;
		end
		STORING_DATA:begin
			if(FifosFull) NextState = SENDING_DATA;
		end
		SENDING_DATA:begin
			if(ConverterEmpty) NextState = READY_TO_STORE;
		end
	endcase
end

//FifoDataOut data is in chronological order: [31:25] is DQD (oldest), 
// [24:16] is DID, [8:15] is DQ, [7:0] is DI 

//The input is in the order 
//DI, DID, DQ, DQD
wire fifoReset;
assign fifoReset = (CurrentState == RESET) | Reset;

Fifi_8_bit DI_Fifo (
  .rst(fifoReset), // input rst
  .wr_clk(WriteClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(DataIn[31:24]), // input [7 : 0] din
  .wr_en(WriteEnableDI), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout(FifoDataOut[7:0]), // output [7 : 0] dout
  .full(fullDI), // output full
  .empty(emptyDI), // output empty
  .valid(validDI), // output valid
  .prog_full_thresh(ProgFullThresh), // input [11 : 0] prog_full_thresh
  .prog_full(progFullDI) // output prog_full
);

Fifi_8_bit DID_Fifo (
  .rst(fifoReset), // input rst
  .wr_clk(WriteClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(DataIn[23:16]), // input [7 : 0] din
  .wr_en(WriteEnableDID), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout(FifoDataOut[23:16]), // output [7 : 0] dout
  .full(fullDID), // output full
  .empty(emptyDID), // output empty
  .valid(validDID), // output valid
  .prog_full_thresh(ProgFullThresh), // input [11 : 0] prog_full_thresh
  .prog_full(progFullDID) // output prog_full
);

Fifi_8_bit DQ_Fifo (
  .rst(fifoReset), // input rst
  .wr_clk(WriteClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(DataIn[15:8]), // input [7 : 0] din
  .wr_en(WriteEnableDQ), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout(FifoDataOut[15:8]), // output [7 : 0] dout
  .full(fullDQ), // output full
  .empty(emptyDQ), // output empty
  .valid(validDQ), // output valid
  .prog_full_thresh(ProgFullThresh), // input [11 : 0] prog_full_thresh
  .prog_full(progFullDQ) // output prog_full
);

Fifi_8_bit DQD_Fifo (
  .rst(fifoReset), // input rst
  .wr_clk(WriteClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(DataIn[7:0]), // input [7 : 0] din
  .wr_en(WriteEnableDQD), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout(FifoDataOut[31:24]), // output [7 : 0] dout
  .full(fullDQD), // output full
  .empty(emptyDQD), // output empty
  .valid(validDQD), // output valid
  .prog_full_thresh(ProgFullThresh), // input [11 : 0] prog_full_thresh
  .prog_full(progFullDQD) // output prog_full
);

wire ConverterAlmostFull;
assign FifoReadEn = (~ConverterAlmostFull &  ~FifosEmpty);	// Read from FIFOs when the converter is not full and the FIFOs are not empty
reg [31:0] FirstWord = 32'b11111111100000000111111100000000;
wire [31:0] dwcInput;
wire dwcWrEn;

//These assignments should mean that the first 4 bytes are the signature "FirstWord" to denote the start of data transfer
assign dwcInput = (WriteEnableEdgeSlow == 2'b01) ? FirstWord : FifoDataOut[31:0];
//assign dwcInput = (WriteStrobe) ? FirstWord : FifoDataOut[31:0];
assign dwcWrEn =  (WriteEnableEdgeSlow == 2'b01) ? 1'b1 : FifosValid;
//assign dwcWrEn =  (WriteStrobe) ? 1'b1 : FifosValid;

FIFO_32to8 DataWidthConverter (
  .rst(fifoReset), // input rst
  .wr_clk(ReadClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(dwcInput), // input [31 : 0] din
  .wr_en(dwcWrEn), // input wr_en
  .rd_en(ReadEnable), // input rd_en
  .dout(DataOut), // output [7 : 0] dout
  .full(ConverterFull), // output full
  .almost_full(ConverterAlmostFull),
  .empty(ConverterEmpty), // output empty
  .valid(DataValid) // output valid
);

endmodule