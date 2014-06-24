`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:15:30 06/23/2014 
// Design Name: 
// Module Name:    SelfTriggerState 
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
module SelfTriggerState(
    input clk,
    input selfTriggerMode,
    input recordDataCommand,
    input triggered,
    output waitForTrigger,
	 output holdTrigger
    );

localparam 	IDLE = 2'b00,
				WAIT_FOR_RECORD = 2'b01,
				WAIT_FOR_TRIGGER = 2'b10,
				LOCK_READ = 2'b11;

reg [1:0] CurrentState = IDLE;
reg [1:0] NextState = IDLE;

assign waitForTrigger = (CurrentState == WAIT_FOR_TRIGGER);
assign holdTrigger = (CurrentState == LOCK_READ);

always@(posedge clk) begin
	CurrentState <= NextState;
end

always@(*) begin
	NextState = CurrentState;
	case(CurrentState)
		IDLE: if(selfTriggerMode) NextState = WAIT_FOR_RECORD;
		WAIT_FOR_RECORD: begin
			if(recordDataCommand) 
				NextState = WAIT_FOR_TRIGGER;
			else if (~selfTriggerMode)
				NextState = IDLE;
		end
		WAIT_FOR_TRIGGER: begin
			if(triggered)
				NextState = LOCK_READ;
			else if(~selfTriggerMode)
				NextState = IDLE;
		end
		LOCK_READ: NextState = WAIT_FOR_RECORD;
	endcase
end


endmodule
