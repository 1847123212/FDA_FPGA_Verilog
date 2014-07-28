`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:31 07/24/2014 
// Design Name: 
// Module Name:    DataCapture 
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
module DataCapture(
    input clk,
    input clkSlow,
    input [7:0] inputData,
    input dataCaptureStrobe,
    input dataRead,
    input rst,
	 input readyToTransmit,
    output dataReadyToRead,
	 output dataValid, 
    output dataEmpty,
    output [15:0] dataOut,
	 input [7:0] numEventsToAdd
    );
	 
	//parameter NUM_EVENTS = 8'd255;
	
	//FSM States
	parameter RESET1 = 			4'b0001;
	parameter WAIT_FOR_TRIG = 	4'b0010;
	parameter WRITE = 			4'b0100;
	parameter WAIT_FOR_EMPTY =	4'b1000;
	
	parameter RESET2 =			6'b000001;
	parameter WAIT = 				6'b000010;
	parameter READ = 				6'b000100;
	parameter INC_EVENTS = 		6'b001000;
	parameter CHECK_EVENTS = 	6'b010000;
	parameter EMPTY_FIFO =		6'b100000;


	//Registers
	reg [7:0] numEventsCnt = 8'd0;
	
	//Wires
	wire rstFSM2 = 1'b0;

	//FSM to control when the fast fifo buffer is written to
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state1 = RESET1;
	always@(posedge clk)
      if (rst) begin
         state1 <= RESET1;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state1)
			RESET1:
				state1<=WAIT_FOR_TRIG;
			WAIT_FOR_TRIG:
				if(dataCaptureStrobe)		// & sfa_empty_sync & fdt_empty_sync
					state1<=WRITE;
				else
					state1<=WAIT_FOR_TRIG;
			WRITE:
				if(ffb_almost_full)
					state1<=WAIT_FOR_EMPTY;
				else
					state1<=WRITE;
			WAIT_FOR_EMPTY:
				if(ffb_empty_sync)
					state1<=WAIT_FOR_TRIG;
				else
					state1<=WAIT_FOR_EMPTY;
			endcase
			

	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [5:0] state2 = RESET2;
	always@(posedge clkSlow)
      if (rst) begin
         state2 <= RESET2;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state2)
			RESET2:
				if(~ffb_full_sync)
					state2 <= WAIT;
				else
					state2 <= RESET2;
			WAIT:	//wait until ffb is full
				if(ffb_full_sync)
					state2<=READ;
				else
					state2<=WAIT;
			READ:	//read data from ffb to sfa
				if(ffb_almost_empty)
					state2<=INC_EVENTS;
				else
					state2<=READ;
			INC_EVENTS:	//increment the number of events captured TODO
				state2<=CHECK_EVENTS;
			CHECK_EVENTS:
				if(numEventsCnt == numEventsToAdd)
					if(readyToTransmit)			//wait until the DataStorageAcc module is ready to transmit
						state2<=EMPTY_FIFO;
					else
						state2<=CHECK_EVENTS;
				else
					state2<=WAIT;
			EMPTY_FIFO:								//empty the accumulator fifo into the transmit fifo
				if(sfa_empty)
					state2<=WAIT;
				else
					state2<=EMPTY_FIFO;
			endcase

	//fifo 1 write enable logic
	assign ffb_wr = (state1 == WRITE);

	//communication between fast fifo and accumulator fifo
	assign ffb_rd = (state2 == READ);
	assign sfa_wr = ffb_valid;

	//communication between accumululator fifo and transmit buffer fifo
	assign sfa_rd = (state2 == EMPTY_FIFO & ~fdt_full) | 
							(state2 == READ & numEventsCnt > 8'd0);
	assign fdt_wr = sfa_valid & (state2==EMPTY_FIFO);
	
	always@(posedge clkSlow)
		if(state2 == EMPTY_FIFO | state2 == RESET2)
			numEventsCnt <= 8'd0;
		else if(state2 == INC_EVENTS)
			numEventsCnt <= numEventsCnt + 1;
	
	//Clock domain crossing
	async_input_sync ffb_empty_sync_module (
		.clk(clk), 
		.async_in(ffb_empty), 
		.sync_out(ffb_empty_sync)
	);

	async_input_sync sfa_empty_sync_module (
		.clk(clk), 
		.async_in(sfa_empty), 
		.sync_out(sfa_empty_sync)
	);
	
	async_input_sync fdt_empty_sync_module (
		.clk(clk), 
		.async_in(fdt_empty), 
		.sync_out(fdt_empty_sync)
	);
	 
	async_input_sync ffb_full_sync_module (
		.clk(clkSlow), 
		.async_in(ffb_full), 
		.sync_out(ffb_full_sync)
	);

	wire [7:0] ffb_dout;
	wire [15:0] sfa_din;
	wire [15:0] sfa_dout;
	wire [15:0] fdt_din;
	wire [15:0] dataToAdd; 
	assign dataToAdd = (numEventsCnt == 8'd0) ? 16'd0 : sfa_dout;
	assign sfa_din = {8'd0,ffb_dout} + dataToAdd;
	
	FIFO_IND_CLK_8x128 fast_fifo_buffer (
	  .rst(rst), // input rst
	  .wr_clk(clk), // input wr_clk
	  .rd_clk(clkSlow), // input rd_clk
	  .din(inputData), // input [7 : 0] din
	  .wr_en(ffb_wr), // input wr_en
	  .rd_en(ffb_rd), // input rd_en
	  .dout(ffb_dout), // output [7 : 0] dout
	  .full(ffb_full), // output full
	  .almost_full(ffb_almost_full), // output almost_full
	  .empty(ffb_empty), // output empty
	  .almost_empty(ffb_almost_empty), // output almost_empty
	  .valid(ffb_valid) // output valid
	);

	FIFO_1CLK_16x128 slow_fifo_accumulator (
	  .clk(clkSlow), // input clk
	  .rst(rst), // input rst
	  .din(sfa_din), // input [15 : 0] din
	  .wr_en(sfa_wr), // input wr_en
	  .rd_en(sfa_rd), // input rd_en
	  .dout(sfa_dout), // output [15 : 0] dout
	  .full(sfa_full), // output full
	  .almost_full(sfa_almost_full), // output almost_full
	  .empty(sfa_empty), // output empty
	  .almost_empty(sfa_almost_empty), // output almost_empty
	  .valid(sfa_valid) // output valid
	);

	assign fdt_din = sfa_dout;
	assign dataReadyToRead = ~fdt_empty;
	assign dataValid = fdt_valid;

	FIFO_1CLK_16x128 fifo_data_transfer (
	  .clk(clkSlow), // input clk
	  .rst(rst), // input rst
	  .din(fdt_din), // input [15 : 0] din
	  .wr_en(fdt_wr), // input wr_en
	  .rd_en(dataRead), // input rd_en
	  .dout(dataOut), // output [15 : 0] dout
	  .full(fdt_full), // output full
	  .almost_full(fdt_almost_full), // output almost_full
	  .empty(fdt_empty), // output empty
	  .almost_empty(fdt_almost_empty), // output almost_empty
	  .valid(fdt_valid) // output valid
	);

endmodule
