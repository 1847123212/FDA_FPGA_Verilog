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
    input [7:0] UART_Rx,
	 input UART_DataReady,
	 output [7:0] UART_Tx,
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
		else if(State!= TRANSMIT && UART_DataReady)
			DataReg[15:2] <= {DataReg[14:2], UART_Rx[0]}; //last two bits are always 0;
	end		
		
	always@(posedge clk) begin
		State <= NextState;
	end
	
	always@(*) begin
		NextState = State;
		case(State)
			IDLE: begin
				if(UART_Rx == 8'd86) 
					NextState = RECB9;
//				else if (UART_Rx == "v") 
//					NextState = GETDACVAL;
			end
			RECB9: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49))) ? RECB8 : IDLE;
			RECB8: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB7 : IDLE;	
			RECB7: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB6 : IDLE;	
			RECB6: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB5 : IDLE;
			RECB5: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB4 : IDLE;
			RECB4: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB3 : IDLE;
			RECB3: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49))) ? RECB2 : IDLE;
			RECB2: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB1 : IDLE;
			RECB1: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? RECB0 : IDLE;
			RECB0: NextState = (UART_DataReady && ((UART_Rx == 8'd48) || (UART_Rx == 8'd49)))  ? TRANSMIT : IDLE;
			TRANSMIT: NextState = IDLE;
		endcase
	end


endmodule
