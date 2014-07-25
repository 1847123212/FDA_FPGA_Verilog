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
    output [15:0] dataOut
    );
	 
	parameter NUM_EVENTS = 1'b1;
	
	//FSM States
	parameter RESET = 			4'b0001;
	parameter WAIT_FOR_TRIG = 	4'b0010;
	parameter WRITE = 			4'b0100;
	parameter WAIT_FOR_EMPTY =	4'b1000;
	
	parameter WAIT = 				5'b00001;
	parameter READ = 				5'b00010;
	parameter INC_EVENTS = 		5'b00100;
	parameter CHECK_EVENTS = 	5'b01000;
	parameter EMPTY_FIFO =		5'b10000;


	//Registers
	reg numEvents = 1'b1;	//Will eventually be more
	
	//Wires
	wire rstFSM2 = 1'b0;

	//FSM to control when the fast fifo buffer is written to
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state1 = RESET;
	always@(posedge clk)
      if (rst) begin
         state1 <= RESET;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state1)
			RESET:
				if(~ffb_full)	//this will be high when in FIFO is resetting mode
					state1<=WAIT_FOR_TRIG;
				else
					state1<=RESET;
			WAIT_FOR_TRIG:
				if(dataCaptureStrobe)
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
			

	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [4:0] state2 = WAIT;
	always@(posedge clkSlow)
      if (rstFSM2) begin
         state2 <= WAIT;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state2)
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
				if(numEvents == NUM_EVENTS)
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
	assign sfa_rd = (state2 == EMPTY_FIFO & ~fdt_full);
	assign fdt_wr = sfa_valid & (state2==EMPTY_FIFO);
	
	async_input_sync ffb_empty_sync_module (
		.clk(clk), 
		.async_in(ffb_empty), 
		.sync_out(ffb_empty_sync)
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
	assign sfa_din = {8'd0,ffb_dout};
	
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
