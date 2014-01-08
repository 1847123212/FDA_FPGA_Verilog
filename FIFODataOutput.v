`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:46:34 01/07/2014 
// Design Name: 
// Module Name:    FIFODataOutput 
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
module FIFODataOutput(
    input [31:0] FifoData,
    input Clock,
	 input DataValid,
	 input ReadyToSend,
    output [7:0] DataOut
    );


	reg NextState, CurrentState;

	reg [31:0] DataBuffer;
	reg [1:0] Head;
	
	//--------------------------------------------
	//Synchronous State Transition
	//--------------------------------------------
	always@(posedge Clock) begin
		if(Reset) begin
			CurrentState <= READY;
			DataBuffer <= 31'd0;
			Head <= 2'b11;
		end
		else begin
			CurrentState <= NextState;
			DataBuffer [31:8] <= DataBuffer [23:0];
			DataBuffer [7:0] <= DataBuffer [31:24];
		end
	end

	//------------------------------------------
	//Conditional State Transition
	//------------------------------------------
	always@(*) begin
		NextState = CurrentState;
		case (CurrentState)
			READY: 
				if (DataValid) NextState = WAIT_TO_SEND;
			WAIT_TO_SEND:
				if (ReadyToSend) NextState = Send;
				
		endcase
	end

endmodule
