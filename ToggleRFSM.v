`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:17:08 12/23/2013 
// Design Name: 
// Module Name:    ToggleRFSM 
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
module ToggleRFSM(
	input wire Clock,
	input wire Reset,
	input wire [7:0] Cmd,
	output wire R_LED
    );

localparam R_ON = 1'b0,
			  R_OFF = 1'b1;
	
reg CurrentState = R_ON ;
reg NextState = R_ON ;

assign R_LED = ~(CurrentState == R_ON );

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clock) begin
	if(Reset) CurrentState <= R_ON ;
	else CurrentState <= NextState;
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	case (CurrentState)
		R_ON : begin
			if (Cmd == 114) NextState = R_OFF; //'e'
		end
		R_OFF: begin
			if (Cmd == 82) NextState = R_ON ; //'E'
		end
	endcase
end


endmodule

