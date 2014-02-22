`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:38 12/22/2013 
// Design Name: 
// Module Name:    RGBFSM 
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
module RGBFSM(
	input wire Clock,
	input wire Reset,
	input wire [7:0] Cmd,
	input wire NewCmd,
	output reg [2:0] RGB
    );

localparam 	nnn = 3'b111,
				rnn = 3'b011,
				rgn = 3'b001,
				rnb = 3'b010,
				rgb = 3'b000,
				ngn = 3'b101,
				ngb = 3'b100,
				nnb = 3'b110;
			  
reg [2:0] CurrentState = 3'b111;
reg [2:0] NextState = 3'b111;

//--------------------------------------------
//Synchronous State Transition
//--------------------------------------------
always@(posedge Clock) begin
	if(Reset) CurrentState <= 3'b111;
	else CurrentState <= NextState;
end

//------------------------------------------
//Conditional State Transition
//------------------------------------------
always@(*) begin
	NextState = CurrentState;
	case (CurrentState)
		nnn: begin
				if(NewCmd && Cmd==82) NextState = rnn;
				else if(NewCmd && Cmd==71) NextState = ngn;
				else if(NewCmd && Cmd==66) NextState = nnb;
			end
		rnn: begin
				if(NewCmd && Cmd==82) NextState = nnn;
				else if(NewCmd && Cmd==71) NextState = rgn;
				else if(NewCmd && Cmd==66) NextState = rnb;
			end
		rgn: begin
				if(NewCmd && Cmd==82) NextState = ngn;
				else if(NewCmd && Cmd==71) NextState = rnn;
				else if(NewCmd &&Cmd==66) NextState = rgb;
			end
		rnb: begin
				if(NewCmd && Cmd==82) NextState = nnb;
				else if(NewCmd && Cmd==71) NextState = rgb;
				else if(NewCmd && Cmd==66) NextState = rnn;
			end
		rgb: begin
				if(NewCmd && Cmd==82) NextState = ngb;
				else if(NewCmd && Cmd==71) NextState = rnb;
				else if(NewCmd && Cmd==66) NextState = rgn;
			end
		ngn: begin
				if(NewCmd && Cmd==82) NextState = rgn;
				else if(NewCmd && Cmd==71) NextState = nnn;
				else if(NewCmd && Cmd==66) NextState = ngb;
			end
		ngb: begin
				if(NewCmd && Cmd==82) NextState = rgb;
				else if(NewCmd && Cmd==71) NextState = nnb;
				else if(NewCmd && Cmd==66) NextState = ngn;
			end
		nnb: begin
				if(NewCmd && Cmd==82) NextState = rnb;
				else if(NewCmd && Cmd==71) NextState = ngb;
				else if(NewCmd && Cmd==66) NextState = nnn;
			end
	endcase
end

always @(*) begin
	RGB = 3'b111;
	case (CurrentState)
		nnn: RGB = 3'b111;
		rnn: RGB = 3'b011;
		rgn: RGB = 3'b001;
		rnb: RGB = 3'b010;
		rgb: RGB = 3'b000;
		ngn: RGB = 3'b101;
		ngb: RGB = 3'b100;
		nnb: RGB = 3'b110;
	endcase
end

endmodule
