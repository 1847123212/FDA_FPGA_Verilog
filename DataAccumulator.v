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
    input signed [7:0] inputData,
	 input dataCaptureStrobe,
	 input dataRead,
	 input rst,
	 output dataReadyToRead,
	 output dataEmpty,
	 output signed [15:0] dataOut
    );
	
	parameter ADDER_WIDTH = 16;
	
	reg signed [ADDER_WIDTH-1:0] adderNewData = 16'd0;
   reg signed [ADDER_WIDTH-1:0] adderPrevData = 16'd0;
   reg signed [ADDER_WIDTH-1:0] adderSum = 16'd0;
	wire signed [ADDER_WIDTH-1:0] fifoDataOut;
	
	wire eventCounterRst, dataCounterRst;
	wire eventCounterEn, dataCounterEn;
	wire fifoRst, fifoEmpty;
	
	wire f2sWrEn, f2sRdEn, f2sRst, f2sFull, f2sEmpty;
	wire [15:0] f2sDataOut;
	
	reg notFirstEvent = 0;
	reg signed [7:0] offset;
	
	//counter to count the number of events captured
	//this is used to signal when the data should be read out for transmission
	reg [7:0] eventCounter = 8'd0;
	reg wr_en, rd_en;
   
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
	parameter DELAY_ONE_CLK_RD	=	7'b0000010;
	parameter WAIT_FOR_EVENT = 	7'b0000100;
	parameter READ_FRONT_FIFO = 	7'b0001000;
	parameter READ_IN_DATA = 		7'b0010000;
	parameter DELAY_ONE_CLK_WR = 	7'b0100000;
	parameter INC_EVENT_COUNT = 	7'b1000000;
	
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
						
					wr_en <= 1'b0;
					rd_en <= 1'b0;
            end
            WAIT_FOR_EVENT : begin
               if (dataCaptureStrobe) begin //remove f2sempty when done with single event capture
                  state <= DELAY_ONE_CLK_RD;
						rd_en <= notFirstEvent;
					end
               else begin
                  state <= WAIT_FOR_EVENT;
						rd_en <= 1'b0;
					end
					
					wr_en <= 1'b0;
            end
				//We need to read the first element of the fifo to be added to the first data point
				//i.e. assert read enable, but don't assert write enable for 1 clock cycle
				DELAY_ONE_CLK_RD: begin
					state <= READ_FRONT_FIFO;
					wr_en <= 1'b0;
					rd_en <= notFirstEvent;
				end
				READ_FRONT_FIFO: begin
					state <= READ_IN_DATA;
					wr_en <= 1'b1;
					rd_en <= notFirstEvent;
				end
            READ_IN_DATA : begin
					wr_en <= 1'b1;
               if (dataCounter == 8'd124)	begin //This value is one less than the fifo size - this allows for
														//simultaneous read/writes 
														//It is also an additional 2 less to write the sum of the previous read and input data 
                  state <= DELAY_ONE_CLK_WR;
						rd_en <= 1'b0;
					end
               else begin
                  state <= READ_IN_DATA;
						rd_en <= notFirstEvent;
					end
            end
				DELAY_ONE_CLK_WR: begin
					state <= INC_EVENT_COUNT;
					wr_en <= 1'b1;
					rd_en <= 1'b0;
				end
            INC_EVENT_COUNT : begin
					state <= WAIT_FOR_EVENT;
					wr_en <= 1'b0;
					rd_en <= 1'b0;
            end
         endcase
	
	assign fifoRst = rst | (state == RESET);
	assign dataOut = f2sDataOut;
	assign dataReadyToRead = ~f2sEmpty;
	assign dataCounterEn = (state == READ_IN_DATA);
	assign eventCounterEn = (state == INC_EVENT_COUNT);
	assign dataCounterRst = (state == RESET) | (state == INC_EVENT_COUNT);
	assign eventCounterRst = (state == RESET) | ((state == INC_EVENT_COUNT) & (eventCounter == 8'd3)); //(eventCounter == 8'd255)
	
	localparam signed [7:0] MIDVALUE = 8'd0;
		
	always@(posedge clk)
		if (state == RESET)
			offset <= 8'd0;
		else if (state == WAIT_FOR_EVENT)
			offset <= MIDVALUE - inputData;
	
	wire signed [15:0] sInputData;
	wire signed [15:0] sOffset;
	
	assign sInputData [15:7] = {inputData[7], inputData[7], inputData[7], inputData[7], inputData[7], inputData[7], inputData[7], inputData[7], inputData[7]};
	assign sInputData [6:0] = inputData[6:0];
	assign sOffset [15:7] = {offset[7], offset[7], offset[7], offset[7], offset[7], offset[7], offset[7], offset[7], offset[7]};
	assign sOffset[6:0] = offset[6:0];
	
	always@(posedge clk) begin
		adderNewData <= sInputData + sOffset;
	end
	
	always@(posedge clk)
		if(eventCounter == 8'd0)
			adderPrevData <= 16'd0;
		else
			adderPrevData <= fifoDataOut;
			
//	assign adderPrevData = fifoDataOut; //(eventCounter == 8'd0) ? 16'd0 : fifoDataOut;
//   assign adderSum = (eventCounter == 8'd0) ? adderNewData : adderNewData + adderPrevData;
	always@(posedge clk)
		if(~adderNewData[7])
			adderSum <= adderPrevData; //16'd0;
		else
			adderSum <= adderNewData + adderPrevData;
		
	reg bufNotFirstEvent = 0;	
	assign f2sWrEn = ((state == READ_IN_DATA) | (state == READ_FRONT_FIFO) | (state == DELAY_ONE_CLK_RD)) & (eventCounter == 8'd0) & bufNotFirstEvent;
	assign dataEmpty = f2sEmpty;
	assign f2sRdEn = dataRead;
	
	//This is to monitor if this is the first time that the data fifo is being filled after a reset
	always @(posedge clk) 
		if(state == RESET)
			notFirstEvent <= 0;
		else if (state == INC_EVENT_COUNT)
			notFirstEvent <= 1;
			
	always @(posedge clk) 
		if(state == RESET)
			bufNotFirstEvent <= 0;
		else
			bufNotFirstEvent <= notFirstEvent;
	
	
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
