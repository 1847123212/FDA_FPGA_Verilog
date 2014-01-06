`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:		Schuyler Senft-Grupp 
// 
// Create Date:    19:10:08 01/05/2014 
// Design Name: 
// Module Name:    AnalogPowerFSM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 	FSM for the analog power enable pin. Power can only be on if
//						the power enable pin is high. Power automatically turns off
//						if power enable pin goes low.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AnalogPowerFSM(
    input Clock,
    input Reset,
    input [7:0] Cmd,
    input OutputEnable,
    output AnalogPowerEnable
    );

	localparam POWER_OFF = 1'b0,
				  POWER_ON = 1'b1;
		
	reg CurrentState = POWER_OFF;
	reg NextState = POWER_OFF;

	assign AnalogPowerEnable = (OutputEnable && (CurrentState == POWER_ON));

	//--------------------------------------------
	//Synchronous State Transition
	//--------------------------------------------
	always@(posedge Clock) begin
		if(Reset) CurrentState <= POWER_OFF;
		else CurrentState <= NextState;
	end

	//------------------------------------------
	//Conditional State Transition
	//------------------------------------------
	always@(*) begin
		NextState = CurrentState;
		case (CurrentState) 
			POWER_ON: begin
				if ((Cmd == 8'd112) || (OutputEnable == 0)) NextState = POWER_OFF; //'p'
			end
			POWER_OFF: begin
				if ((Cmd == 8'd80) && (OutputEnable == 1)) NextState = POWER_ON; //'P'
			end
		endcase
	end
endmodule
