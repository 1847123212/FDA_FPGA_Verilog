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
    input WriteStrobe,	// Assumed to be synchronous with ReadClock
	 input FastTrigger, 	// Assumed to be synchronous with WriteClock	
    input ReadEnable,
    input WriteClock,
    input ReadClock,
    input Reset,
	 input [11:0] ProgFullThresh,
    output DataValid,
    output DataReadyToSend,
	 output [3:0] State
    ); 

wire FifoReadEn;
wire fullDI, emptyDI, validDI, fullDID, emptyDID, validDID, fullDQ, emptyDQ, validDQ, fullDQD, emptyDQD, validDQD;
wire progFullDI, progFullDID, progFullDQ, progFullDQD;
wire [31:0] FifoDataOut;	//This data is in chronological order: [31:25] is DQD (oldest), 
									// [24:16] is DID, [8:15] is DQ, [7:0] is DI 
wire ConverterFull, ConverterEmpty;
wire FifosValid = (validDI & validDID & validDQ & validDQD);
wire FifosEmpty = (emptyDI | emptyDID | emptyDQ | emptyDQD);
wire ConverterEmpty_wrClk, FifosEmpty_wrClk, FastTrigger_rdClk;
wire WriteEnable, WriteStrobe_wrClk;


reg FifosFull = 0;//(fullDI | fullDID | fullDQ | fullDQD);	

always@(posedge WriteClock) begin
	FifosFull <= (progFullDI | progFullDID | progFullDQ | progFullDQD);
end

assign DataReadyToSend = ~ConverterEmpty;

parameter RESET = 4'b0001;
parameter READY_TO_STORE = 4'b0010;
parameter STORING_DATA = 4'b0100;
parameter SENDING_DATA = 4'b1000;

(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] stateWr = RESET;

always@(posedge WriteClock)
      if (Reset) begin
         stateWr <= RESET;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (stateWr)
            RESET : begin
               if (Reset == 1'b0)
                  stateWr <= READY_TO_STORE;
               else
                  stateWr <= RESET;
            end
            READY_TO_STORE : begin
               if (WriteStrobe_wrClk | FastTrigger)
                  stateWr <= STORING_DATA;
               else
                  stateWr <= READY_TO_STORE;
            end
            STORING_DATA : begin
               if (FifosFull)
                  stateWr <= SENDING_DATA;
               else
                  stateWr <= STORING_DATA;
            end
            SENDING_DATA : begin
               if (ConverterEmpty_wrClk & FifosEmpty_wrClk)
                  stateWr <= READY_TO_STORE;
               else
                  stateWr <= SENDING_DATA;
            end
         endcase

assign WriteEnable = stateWr[2]; //equivalent to "STORING_DATA"


/*********************************************************
/ Synchronize for clock domain crossing
**********************************************************/
//WriteStrobe is synchronous to ReadClock 
async_input_sync write_strobe_sync (
    .clk(WriteClock), 
    .async_in(WriteStrobe), 
    .sync_out(WriteStrobe_wrClk)
    );
	 
//ConverterEmpty is synchronous to ReadClock
async_input_sync conv_empty_sync (
    .clk(WriteClock), 
    .async_in(ConverterEmpty), 
    .sync_out(ConverterEmpty_wrClk)
    );
	 
//FifosEmpty is synchronous to ReadClock
async_input_sync fifos_empty_sync (
    .clk(WriteClock), 
    .async_in(FifosEmpty), 
    .sync_out(FifosEmpty_wrClk)
    );
	 
//FastTrigger is synchronous with WriteClock but held high for more than 2 periods of ReadClock
async_input_sync fast_trigger_sync (
    .clk(ReadClock), 
    .async_in(FastTrigger), 
    .sync_out(FastTrigger_rdClk)
    );

assign State = stateWr;

//FifoDataOut data is in chronological order: [31:25] is DQD (oldest), 
// [24:16] is DID, [8:15] is DQ, [7:0] is DI 

//The input is in the order: DI, DID, DQ, DQD

wire fifoReset;
assign fifoReset = stateWr[0] | Reset;	//add reset because if write clock isn't running, we should hold fifo in reset

Fifi_8_bit DI_Fifo (
  .rst(fifoReset), // input rst
  .wr_clk(WriteClock), // input wr_clk
  .rd_clk(ReadClock), // input rd_clk
  .din(DataIn[31:24]), // input [7 : 0] din
  .wr_en(WriteEnable), // input wr_en
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
  .wr_en(WriteEnable), // input wr_en
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
  .wr_en(WriteEnable), // input wr_en
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
  .wr_en(WriteEnable), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout(FifoDataOut[31:24]), // output [7 : 0] dout
  .full(fullDQD), // output full
  .empty(emptyDQD), // output empty
  .valid(validDQD), // output valid
  .prog_full_thresh(ProgFullThresh), // input [11 : 0] prog_full_thresh
  .prog_full(progFullDQD) // output prog_full
);

wire ConverterAlmostFull;
reg [31:0] FirstWord = 32'b11111111100000000111111100000000;
wire [31:0] dwcInput;
wire dwcWrEn;

parameter RESET_DWC 				= 5'b00001;
parameter READY_TO_STORE_DWC	= 5'b00010;
parameter LOAD_FIRST_WORD 		= 5'b00100;
parameter WAIT_FOR_DATA 		= 5'b01000;
parameter SENDING_DATA_DWC 	= 5'b10000;

(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [4:0] stateDWC = RESET;

always@(posedge ReadClock)
      if (Reset) begin
         stateDWC <= RESET_DWC;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (stateDWC)
            RESET : begin
               if (Reset == 1'b0)
                  stateDWC <= READY_TO_STORE_DWC;
               else
                  stateDWC <= RESET;
            end
            READY_TO_STORE_DWC : begin
               if (WriteStrobe | FastTrigger_rdClk)
                  stateDWC <= LOAD_FIRST_WORD;
               else
                  stateDWC <= READY_TO_STORE_DWC;
            end
            LOAD_FIRST_WORD : begin
                  stateDWC <= WAIT_FOR_DATA;
            end
				WAIT_FOR_DATA : begin
					if(~FifosEmpty)
						stateDWC <= SENDING_DATA_DWC;
					else
						stateDWC <= WAIT_FOR_DATA;
				end
            SENDING_DATA_DWC: begin
               if (ConverterEmpty & FifosEmpty)
                  stateDWC <= READY_TO_STORE_DWC;
               else
                  stateDWC <= SENDING_DATA_DWC;
            end
         endcase


// Read from FIFOs into DWC when the converter is not full and the FIFOs are not empty and SENDING_DATA_DWC
assign FifoReadEn = (~ConverterAlmostFull & ~FifosEmpty & stateDWC[4]);

//These assignments should mean that the first 4 bytes are the signature "FirstWord" to denote the start of data transfer
assign dwcInput = (stateDWC[2]) ? FirstWord : FifoDataOut[31:0];	//stateDWC[2] is "LOAD_FIRST_WORD"
assign dwcWrEn =  (stateDWC[2]) ? 1'b1 : FifosValid;

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