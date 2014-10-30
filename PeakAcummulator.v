`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:02:41 10/25/2014 
// Design Name: 
// Module Name:    PeakAcummulator 
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
module PeakAcummulator(
    input Clk,
    input [7:0] DataIn,
    input DataStreaming,
    output ReadData,
    output AccumulationReadyToSend,
    input StrobeDataToSend,
    input [7:0] DataOut,
	 input rst
    );
	 
	reg [511:0] TimeCounter = 512b'1;
	reg [7:0] AccCounter = 0;
	reg [7:0] D1 = 0;
	reg [7:0] D2 = 0;
	reg [7:0] D3 = 0;
	
	wire [8192-1: 0] AccumOutputs;
	
	parameter WAIT_FOR_DATA = 4'b0001;
   parameter READING_DATA = 4'b0010;
   parameter SEND_DATA = 4'b0100;
   parameter <state4> = 4'b1000;

   (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state = WAIT_FOR_DATA;
   always@(posedge clk)
      if (rst) begin
         state <= WAIT_FOR_DATA;
			AccumulationCounter <= 8'd0;
			D1 <= 0;
			D2 <= 0;
			D3 <= 0;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            WAIT_FOR_DATA : begin
               if (<DataStreaming>) begin
                  state <= READING_DATA;
						D1 <= DataIn;		//Immediately start storing the data
					end
               else
                  state <= WAIT_FOR_DATA;
            end
				READING_DATA: begin
               if (TimeCounter[511] == 1 && AccumulationCounter < 255) begin
                  state <= WAIT_FOR_DATA;
						AccumulationCounter <= AccumulationCounter + 1;
					end
               else if (TimeCounter[511] == 1)
                  state <= <next_state>;
					end
               else
                  state <= READING_DATA;
					D3 <= D2;
					D2 <= D1;
					D1 <= DataIn;
					TimeCounter <= TimeCounter << 1;
            end
            SEND_DATA : begin
               if (<condition>)
                  state <= <next_state>;
               else if (<condition>)
                  state <= <next_state>;
               else
                  state <= <next_state>;
               <outputs> <= <values>;
            end
         endcase
	
	wire peakDetected;
	PeakDetector instance_name (
    .D1(D1), 
    .D2(D2), 
    .D3(D3), 
    .Level(8'd110), 
    .Detected(peakDetected)
    );

   genvar index;
   generate
      for (index = 0; index < 512; index = index + 1) 
      begin: gen_accumulators
			Accumulator16Bit accum_inst (
			  .b(D2), // input [7 : 0] b
			  .clk(clk), // input clk
			  .ce(TimeCounter(index) && state == READING_DATA && peakDetected), // input ce
			  .sclr(sclr), // input sclr
			  .q(AccumOutputs((index*16+15:index*16) // output [15 : 0] q
			);
      end
   endgenerate
		

endmodule
