`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:39:40 02/21/2014 
// Design Name: 
// Module Name:    DACControlFSM 
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
module DACControlFSM(
    input clk,
    input setV,
	 input setV_1,
	 input setV_0,
	 input resetTrigV,
    output [6:0] I2Caddr,
    output [15:0] I2Cdata,
	 output I2Cbytes,
	 output I2Cr_w,
	 output I2C_load,
    input I2CBusy,
    input I2CDataReady
    );

	localparam IDLE = 4'd0,
					RECB9 = 4'd1,
					RECB8 = 4'd2,
					RECB7 = 4'd3,
					RECB6 = 4'd4,
					RECB5 = 4'd5,
					RECB4 = 4'd6,
					RECB3 = 4'd7,
					RECB2 = 4'd8,
					RECB1 = 4'd9,
					RECB0 = 4'd10,
					TRANSMIT = 4'd11;
					
	reg [6:0] Addr_r = 7'b0001101;
	wire OutEnable;
	assign OutEnable = (State == TRANSMIT);
	
	assign I2Caddr = Addr_r;
	assign I2Cdata = DataReg;
	assign I2Cr_w = 1'b0;
	assign I2Cbytes = 1'b1 ;
	assign I2C_load = (OutEnable) ? 1'b1 : 1'b0;
	
	reg [15:0] DataReg = 16'b0;
					
	reg [3:0] State = IDLE;
	reg [3:0] NextState = IDLE;				
				
	//0 - 48, 1 - 49			
	always@(posedge clk)
	begin
		if(State == IDLE)
			DataReg[15:0] <= 16'b0;
		else if(State!= TRANSMIT && setV_1)
			DataReg[15:2] <= {DataReg[14:2], 1'b1}; //last two bits are always 0;
		else if(State!= TRANSMIT && setV_0)
			DataReg[15:2] <= {DataReg[14:2], 1'b0}; //last two bits are always 0;
	end		
		
	always@(posedge clk) begin
		if(resetTrigV)
			State <= IDLE;
		else
			State <= NextState;
	end
	
	always@(*) begin
		NextState = State;
		case(State)
			IDLE: begin
				if(setV)
					NextState = RECB9;
//				else if (UART_Rx == "v") 
//					NextState = GETDACVAL;
			end
			RECB9: if(setV_1 || setV_0) NextState = RECB8;
			RECB8: if(setV_1 || setV_0) NextState = RECB7;
			RECB7: if(setV_1 || setV_0) NextState = RECB6;
			RECB6: if(setV_1 || setV_0) NextState = RECB5;
			RECB5: if(setV_1 || setV_0) NextState = RECB4;
			RECB4: if(setV_1 || setV_0) NextState = RECB3;
			RECB3: if(setV_1 || setV_0) NextState = RECB2;
			RECB2: if(setV_1 || setV_0) NextState = RECB1;
			RECB1: if(setV_1 || setV_0) NextState = RECB0;
			RECB0: if(setV_1 || setV_0) NextState = TRANSMIT;
			TRANSMIT: NextState = IDLE;
		endcase
	end


endmodule
