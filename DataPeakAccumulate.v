`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:55:56 10/27/2014 
// Design Name: 
// Module Name:    DataPeakAccumulate 
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
module DataPeakAccumulate(
    input [31:0] DataIn,
    input FastTrigger,
    input TxEnable,
    input DataClk,
    input SysClk,
    input Reset,
    output DataReady,
	 output DataValid,
	 output [7:0] DataOut
	 );

	 reg [7:0] NumDataPts = 0;
	 
	 wire s2DataAvailable;
	 wire [7:0] s2DataOut;
	 wire accEmpty;
	 wire pkDetEnable, pkDetected;
	 wire [7:0] pkDataOut;
	 wire [15:0] accDataIn;
	 wire [15:0] accDataOut;
	 
	 wire txWrEn, txRdEn, txValid, txFull, txEmpty;
	 wire [7:0] txDataOut;
	 wire [15:0] txDataIn;
	 
	 
	 parameter IDLE = 8'b00000001;//1
    parameter READ = 8'b00000010;//2
    parameter INCR = 8'b00000100;//4
    parameter CHECK_COUNT = 8'b00001000; //8
    parameter CHECK_TX_READY = 8'b00010000; //10
    parameter WRITE_START = 8'b00100000; //20
    parameter TX = 8'b01000000;//40
    parameter WRITE_STOP = 8'b10000000;//80

   (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [7:0] state = IDLE;

    always@(posedge SysClk)
      if (Reset) begin
         state <= IDLE;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            IDLE : begin
               if (s2DataAvailable)
                  state <= READ;
               else
                  state <= IDLE;
            end
            READ : begin
               if (~s2DataAvailable)
                  state <= INCR;
               else
                  state <= READ;
            end
            INCR : state <= CHECK_COUNT;
            CHECK_COUNT : begin
					`ifdef XILINX_ISIM			//If we are simulating, then just collect 4 trigger pulses
					if (NumDataPts == 8'h04)
					`else
               if (NumDataPts == 8'hFF)	//Normally collect 255 samples - this is the maximum amount to prevent overflow with a 16bit wide fifo
					`endif
                  state <= CHECK_TX_READY;
               else
                  state <= IDLE;
            end
            CHECK_TX_READY : begin
               if (txEmpty)
                  state <= WRITE_START;
               else
                  state <= CHECK_TX_READY;
            end
            WRITE_START : state <= TX;
            TX : begin
					if (accAlmostEmpty)
                  state <= WRITE_STOP;
               else
                  state <= TX;
				end
            WRITE_STOP : state <= IDLE;
         endcase
	 
	 assign pkDetEnable = s2DataValid;
	 assign s2DataRead = (state == READ);
	 // Two scenarios to read from the accumulator buffer
	 // 1) Actively accumulating values and it's not the first set of data (i.e. NumDataPts > 0)
	 // 2) Transmitting to tx_fifo. In this case we lose the first and last data words.
	 assign accRdEn = (s2DataRead & s2DataAvailable & NumDataPts > 0) | (state == TX | state == WRITE_START | state == WRITE_STOP);
	 assign accWrEn = s2DataValid;
	 
	 //Peak detector
	 PeakDetector peak_detector (
     .clk(SysClk), 
     .DIn(s2DataOut), 
     .minLevel(8'd110), //Typical average level is 122 so 110 is an effective minimum peak height of 10-12
     .rst(Reset | (state == IDLE)),	//reset the minimum peak level each time 
     .enable(pkDetEnable), 
     .pkDetected(pkDetected), 
     .DOut(pkDataOut)
     );


	 //Increment the number of data points using clock enable
	 always@(posedge SysClk) begin
		if(Reset | state == TX)
			NumDataPts <= 8'd0;
		else if(state == INCR)
			NumDataPts <= NumDataPts + 1;
	 end
	 
	 //reg [15:0] accDataOutDelay1;
	 
	 //We need to delay the output from the ACC FIFO to get the accumulator data to line up correctly in time
	 //always@(posedge SysClk)
	//	accDataOutDelay1 <= accDataOut;
	 
	 assign accDataIn = accDataOut + {8'h00, pkDataOut};

	 DataPeakStage2Buffer stage_2_buffer (
     .DataIn(DataIn), 
     .FastTrigger(FastTrigger), 
     .DataClk(DataClk), 
     .SysClk(SysClk), 
     .Reset(Reset), 
     .DataRead(s2DataRead), //rd enable for second stage fifo
     .DataAvailable(s2DataAvailable), 
     .DataValid(s2DataValid), 
     .DataOut(s2DataOut)
     );
	  
	 Fifo16x512 accumulator_fifo (
	   .clk(SysClk), // input clk
	   .rst(state == WRITE_STOP), // input rst
	   .din(accDataIn), // input [15 : 0] din
	   .wr_en(accWrEn), // input wr_en
	   .rd_en(accRdEn), // input rd_en
	   .dout(accDataOut), // output [15 : 0] dout
	   .full(accFull), // output full
	   .almost_full(accAlmostFull), // output almost_full
	   .empty(accEmpty), // output empty
	   .almost_empty(accAlmostEmpty), // output almost_empty
	   .valid(accValid) // output valid
	 );
	 
	 assign txWrEn = (state == TX | state == WRITE_START | state == WRITE_STOP);// & accValid);
	 assign DataReady = ~txEmpty | txValid;
	 assign txRdEn = TxEnable;
	 assign DataValid = txValid;
	 assign DataOut = txDataOut;
	 
	 //Assign allows for a start and stop word to be queued on the tx_fifo
	 assign txDataIn = (state == TX) ? accDataOut : {8'hFF, state};
	 
	 Fifo16x512x8 tx_fifo (
	  .rst(Reset), // input rst
	  .wr_clk(SysClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(txDataIn), // input [15 : 0] din
	  .wr_en(txWrEn), // input wr_en
	  .rd_en(txRdEn), // input rd_en
	  .dout(txDataOut), // output [7 : 0] dout
	  .full(txFull), // output full
	  .empty(txEmpty), // output empty
	  .valid(txValid) // output valid
	 );

endmodule
