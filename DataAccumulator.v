`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:19:41 07/03/2014 
// Design Name: 
// Module Name:    DataAccumulator 
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
module DataAccumulator(
    input clk,
	 input clkSlow,
    input [7:0] inputData,
	 input dataCaptureStrobe,
	 input dataRead,
	 input rst,
	 output dataReadyToRead,
	 output dataEmpty,
	 output [15:0] dataOut
    );
	
	parameter ADDER_WIDTH = 16;
	
	wire [ADDER_WIDTH-1:0] adderNewData;
   wire [ADDER_WIDTH-1:0] adderPrevData;
   wire [ADDER_WIDTH-1:0] adderSum;
	wire [ADDER_WIDTH-1:0] fifoDataOut;
	
	wire eventCounterRst, dataCounterRst;
	wire eventCounterEn, dataCounterEn;
	wire fifoRst, fifoEmpty;
	
	wire f2sWrEn, f2sRdEn, f2sRst, f2sFull, f2sEmpty;
	wire [15:0] f2sDataOut;
	
	reg notFirstEvent = 0;
	
	
	//counter to count the number of events captured
	//this is used to signal when the data should be read out for transmission
	reg [7:0] eventCounter = 0;
   
   always @(posedge clk)
      if (eventCounterRst)
         eventCounter <= 0;
      else if (eventCounterEn)
         eventCounter <= eventCounter + 1;
	
	//counter used to count the amount of data read in this event
	reg [7:0] dataCounter = 0;
   
   always @(posedge clk)
      if (dataCounterRst)
         dataCounter <= 0;
      else if (dataCounterEn)
         dataCounter <= dataCounter + 1;
			
	//state machine
	parameter RESET = 				7'b0000001;
	parameter FILL_FIFO =			7'b0000010;
	parameter WAIT_FOR_EVENT = 	7'b0000100;
	parameter READ_IN_DATA = 		7'b0001000;
	parameter INC_EVENT_COUNT = 	7'b0010000;
	parameter CHECK_EVENT_NUM = 	7'b0100000;
	parameter READ_OUT_FIFO = 		7'b1000000;
	
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [6:0] state = RESET;

	always@(posedge clk)
      if (rst) begin
         state <= RESET;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            RESET : begin
               if (rst == 1'b0)
                  state <= WAIT_FOR_EVENT;
               else
                  state <= RESET;
            end
            WAIT_FOR_EVENT : begin
               if (dataCaptureStrobe)
                  state <= READ_IN_DATA;
               else
                  state <= WAIT_FOR_EVENT;
            end
            READ_IN_DATA : begin
               if (dataCounter == 8'd128)	//this value is one less than the fifo size - this allows for
														//simultaneous read/writes 
                  state <= INC_EVENT_COUNT;
               else
                  state <= READ_IN_DATA;
            end
            INC_EVENT_COUNT : begin
					state <= WAIT_FOR_EVENT;
            end
//				CHECK_EVENT_NUM : begin
//               if (eventCounter == 10'd3) //10'd1023) set to 3 for SIM
//                  state <= READ_OUT_FIFO;
//               else
//                  state <= WAIT_FOR_EVENT;
//            end
//				READ_OUT_FIFO : begin
//               if (fifoEmpty)
//                  state <= RESET;
//               else
//                  state <= READ_OUT_FIFO;
//            end
         endcase
	
	wire wr_en = (state == READ_IN_DATA);
	wire rd_en = (state == READ_IN_DATA) & notFirstEvent;
	assign fifoRst = rst | (state == RESET);
	assign dataOut = f2sDataOut;
	assign dataReadyToRead = ~f2sEmpty;
	assign dataCounterEn = (state == READ_IN_DATA);
	assign eventCounterEn = (state == INC_EVENT_COUNT);
	assign dataCounterRst = (state == RESET) | (state == INC_EVENT_COUNT);
	assign eventCounterRst = (state == RESET) | ((state == INC_EVENT_COUNT) & (eventCounter == 8'd50)); 
	
	assign adderNewData = {8'b0, inputData};
	assign adderPrevData = fifoDataOut;
   assign adderSum = (eventCounter == 8'd0) ? adderNewData : adderNewData + adderPrevData;
	
	assign f2sWrEn = (state == READ_IN_DATA) & (eventCounter == 16'd0) & notFirstEvent;
	assign dataEmpty = f2sEmpty;
	assign f2sRdEn = dataRead;
	
	//This is to monitor if this is the first time that the data fifo is being filled after a reset
	always @(posedge clk) 
		if(state == RESET)
			notFirstEvent <= 0;
		else if (state == INC_EVENT_COUNT)
			notFirstEvent <= 1;
	
	
	//fifo write depth is 128
	//fifo is first-word-fall-through
	Fifo_adder fifo (
	  .clk(clk), // input clk
	  .rst(fifoRst), // input rst
	  .din(adderSum), // input [15 : 0] din
	  .wr_en(wr_en), // input wr_en
	  .rd_en(rd_en), // input rd_en
	  .dout(fifoDataOut), // output [15 : 0] dout
	  .full(full), 	// output full
	  .empty(fifoEmpty) // output empty
	);


	assign f2sRst = fifoRst;
	
	FifoFast2Slow fast2slow (
	  .rst(f2sRst), // input rst
	  .wr_clk(clk), // input wr_clk
	  .rd_clk(clkSlow), // input rd_clk
	  .din(fifoDataOut), // input [15 : 0] din
	  .wr_en(f2sWrEn), // input wr_en
	  .rd_en(f2sRdEn), // input rd_en
	  .dout(f2sDataOut), // output [15 : 0] dout
	  .full(f2sFull), // output full
	  .empty(f2sEmpty) // output empty
	);

	

endmodule
