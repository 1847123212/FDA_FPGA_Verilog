`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:33:49 01/05/2014 
// Design Name: 
// Module Name:    ADCPowerFSM 
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
module ADCPowerFSM(
    input Clock,
    input Reset,
    input [7:0] Cmd,
    output ADCPower
    );

	localparam POWER_OFF = 1'b0,
				  POWER_ON = 1'b1;
		
	reg CurrentState = POWER_OFF;
	reg NextState = POWER_OFF;

	assign ADCPower = (CurrentState == POWER_ON);

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
				if (Cmd == 111) NextState = POWER_OFF; //'o'
			end
			POWER_OFF: begin
				if (Cmd == 79) NextState = POWER_ON; //'O'
			end
		endcase
	end
endmodule
