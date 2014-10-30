`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:20:11 10/27/2014 
// Design Name: 
// Module Name:    DataCaptureInitialFIFOs 
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
module DataCaptureInitialFIFOs(
	 input [31:0] DataIn,
    input FastTrigger,	//Signal synchronous with DataClk
    input EnableDataCapture,
	 input RdEn,
    input DataClk,	//ADC data clock ~250mhz
    input SysClk,		//System clock ~100mhz
    input Reset,
	 output [31:0] s1DataOut,	 
    output DataReady,
	 output DataValid
    );


//	 wire [31:0] s1DataOut; //Wires from first stage FIFOs to 32-->8 data width converter FIFO
	 wire [3:0] s1Full;
	 wire [3:0] s1Empty;
	 wire [3:0] s1Valid;
	 wire s1WrEn, s1RdEn;
	 wire allFull, allEmpty, allValid;

	 wire allEmptyFast, dataReadyFast, enableDataCaptureFast;	//wires for signals synchronized to DataClk
	 
	 assign allFull = s1Full[3] & s1Full[2] & s1Full[1] & s1Full[0];
	 assign allEmpty = s1Empty[3] & s1Empty[2] & s1Empty[1] & s1Empty[0];
	 assign DataValid = s1Valid[3] & s1Valid[2] & s1Valid[1] & s1Valid[0];
	 assign s1RdEn = RdEn;


	 //FSM States
	 parameter RESET = 			4'b0001;
	 parameter WAIT_FOR_TRIG = 4'b0010;
	 parameter WRITE = 			4'b0100;
	 parameter WAIT_FOR_EMPTY= 4'b1000;

	 //FSM to control when the stage 1 fast fifo buffer is written to
	 //A trigger signal starts this process
	 (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] s1State = RESET;
	 always@(posedge DataClk)
		if (Reset) begin
			s1State <= RESET;
		end
		else
			(* FULL_CASE, PARALLEL_CASE *) case (s1State)
			RESET:
				s1State <= WAIT_FOR_TRIG;
			WAIT_FOR_TRIG:
				if(FastTrigger & enableDataCaptureFast)
					s1State <= WRITE;
				else
					s1State <= WAIT_FOR_TRIG;
			WRITE:
				if(allFull)
					s1State <= WAIT_FOR_EMPTY;
				else
					s1State <= WRITE;
			WAIT_FOR_EMPTY:
				if(allEmptyFast)
					s1State<=WAIT_FOR_TRIG;
				else
					s1State<=WAIT_FOR_EMPTY;
			endcase

	 
	 assign dataReadyFast = (s1State == WAIT_FOR_EMPTY);
	 assign s1WrEn = (s1State == WRITE);
	 
	 //Synchronize signals across clock domains
	 async_input_sync data_ready_sync (
		.clk(SysClk),					//slow clock 
		.async_in(dataReadyFast),	//slow signal 
		.sync_out(DataReady)	//synchronized fast signal
	 );
	 
	 async_input_sync all_empty_sync (
		.clk(DataClk), 
		.async_in(allEmpty),	//slow signal 
		.sync_out(allEmptyFast)	//synchronized fast signal
	 );
	 
	 async_input_sync enable_data_capture_sync (
		.clk(DataClk), 
		.async_in(EnableDataCapture),	//slow signal 
		.sync_out(enableDataCaptureFast)	//synchronized fast signal
	 );	 

	 //Fast Data Capture FIFOs
	 Fifo8x128_2clks fifoDI (
	  .rst(Reset), // input rst
	  .wr_clk(DataClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(DataIn[31:24]), // input [7 : 0] din
	  .wr_en(s1WrEn), // input wr_en
	  .rd_en(s1RdEn), // input rd_en
	  .dout(s1DataOut[7:0]), // output [7 : 0] dout
	  .full(s1Full[3]), // output full
	  .empty(s1Empty[3]), // output empty
	  .valid(s1Valid[3]) // output valid
		);
	 
	 Fifo8x128_2clks fifoDID (
	  .rst(Reset), // input rst
	  .wr_clk(DataClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(DataIn[23:16]), // input [7 : 0] din
	  .wr_en(s1WrEn), // input wr_en
	  .rd_en(s1RdEn), // input rd_en
	  .dout(s1DataOut[23:16]), // output [7 : 0] dout
	  .full(s1Full[2]), // output full
	  .empty(s1Empty[2]), // output empty
	  .valid(s1Valid[2]) // output valid
		);
	
	 Fifo8x128_2clks fifoDQ (
	  .rst(Reset), // input rst
	  .wr_clk(DataClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(DataIn[15:8]), // input [7 : 0] din
	  .wr_en(s1WrEn), // input wr_en
	  .rd_en(s1RdEn), // input rd_en
	  .dout(s1DataOut[15:8]), // output [7 : 0] dout
	  .full(s1Full[1]), // output full
	  .empty(s1Empty[1]), // output empty
	  .valid(s1Valid[1]) // output valid
		);
		
	 Fifo8x128_2clks fifoDQD (
	  .rst(Reset), // input rst
	  .wr_clk(DataClk), // input wr_clk
	  .rd_clk(SysClk), // input rd_clk
	  .din(DataIn[7:0]), // input [7 : 0] din
	  .wr_en(s1WrEn), // input wr_en
	  .rd_en(s1RdEn), // input rd_en
	  .dout(s1DataOut[31:24]), // output [7 : 0] dout
	  .full(s1Full[0]), // output full
	  .empty(s1Empty[0]), // output empty
	  .valid(s1Valid[0]) // output valid
		);

endmodule
