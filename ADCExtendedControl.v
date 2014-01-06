`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	Schuyler Senft-Grupp
// 
// Create Date:    18:38:12 12/23/2013 
// Design Name: 
// Module Name:    ADCExtendedControl 
// Project Name: 	 FDA
// Target Devices: Spartan 6 LX9
// Tool versions: 
// Description: This module provides the serial communication with the ADC. The 
//		data to be sent to the ADC is stored on a ROM. The three types of data to
//		send to the ADC are an initial write of all 8 registers, a single register
//		write to initial dual edge sampling (DES), and a single register write to
//		disable DES. To initiate sending the data, a 1 clock pulse must be applied
//		to the proper input - init, des_enable, or des_disable. 
// 	
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ADCExtendedControl(
	input clk,
	input init,
	input des_enable,
	input des_disable,
	
	output sclk,
	output sdata,
	output select
    );
	
	wire [31:0] ROMData;
	wire [3:0] ROMAddress;
	
	wire [3:0] SClkOut;
	
	wire EnAddrCount, EnBitCount, EnSClkCounter;
	wire ClrBitC, ClrSclkC, ClrAddrC;
	wire [4:0] BitNumber;

	reg [3:0] InitAddrValue = 4'b0000;

	//Counter to slow the main clock down by a factor of 16
	Counter_4Bit SClkCounter (
	  .clk(clk), // input clk
	  .ce(EnSClkCounter),
	  .sclr(ClrSclkC), // input sclr
	  .q(SClkOut) // output [3 : 0] q
	);
	
	//Counter to store the ROM address to be read
	//This is initally loaded by the state machine
	//It is incremented (enabled) once every cycle of the BitCounter 
	CounterUp_4BitLoadable AddressCounter (
	  .clk(clk), // input clk
	  .ce(EnAddrCount), // input ce
	  .sclr(ClrAddrC), // input sclr
	  .load(LoadAddr), // input load
	  .l(InitAddrValue), // input [3 : 0] l
	  .q(ROMAddress) // output [3 : 0] q
	);
	
	//Counter to store the bit to send
	Counter_5Bit BitCounter(
	  .clk(clk), // input clk
	  .ce(EnBitCount), // input ce
	  .sclr(ClrBitC), // input sclr
	  .q(BitNumber) // output [4 : 0] q
	);
	
	//ROM to hold register values
	ADC_ROM ADCRegisterValues (
		.a(ROMAddress), // input [3 : 0] a
		.spo(ROMData) // output [19 : 0] spo
	);
		
	//The state machine
	localparam IDLE = 		3'b000,
				  LOADINIT = 	3'b101, 
				  LOADDESEN = 	3'b110,
				  LOADDESDIS = 3'b111,
				  INITIAL = 	3'b001,
				  ENABLE_DES = 3'b010,
				  DISABLE_DES= 3'b011;

	reg [2:0] CurrentState = IDLE;
	reg [2:0] NextState = IDLE;
				  
	always @(posedge clk) begin
		CurrentState <= NextState;
	end
	
	always @(*) begin
		NextState = CurrentState;
		InitAddrValue = 4'b0000;
		case(CurrentState) 
			IDLE:begin
				if(init) NextState = LOADINIT;
				else if (des_enable) NextState = LOADDESEN;
				else if (des_disable) NextState = LOADDESDIS;
			end
			LOADINIT: begin
				InitAddrValue = 4'b0000;
				NextState = INITIAL;
			end
			LOADDESEN: begin
				InitAddrValue = 4'b1000;
				NextState = ENABLE_DES;
			end
			LOADDESDIS: begin
				InitAddrValue = 4'b0101;	//This is the same as the standard initial write
				NextState = DISABLE_DES;
			end
			INITIAL:begin
				if(ROMAddress == 4'd8)
					NextState = IDLE;
			end
			ENABLE_DES:begin
				if(ROMAddress == 4'd9)
					NextState = IDLE;
			end
			DISABLE_DES: begin
				if(ROMAddress == 4'd6)
					NextState = IDLE;
			end
		endcase	
	end
	
//logic
	//Initalize counters and memory address for ROM
	assign ClrBitCount = (CurrentState[2] == 1);
	assign ClrClkCount = (CurrentState[2] == 1);	
	assign LoadAddr = (CurrentState[2] == 1);
	
	//increment the bit every negative transition on clk
	assign EnBitCount = (SClkOut == 4'd15);	
	
	reg [1:0] AddrTransition;
	always@(posedge clk) begin
		AddrTransition[1:0] = {AddrTransition[0], BitNumber[4]};
	end
	
	//increment the address when all bits are read
	assign EnAddrCount = ((AddrTransition[1] == 1) && (AddrTransition[0] == 0)) || LoadAddr; 
	
	assign sclk = SClkOut[3];
	
	//a large mux
	assign sdata = ROMData[BitNumber];
	assign select = (CurrentState == IDLE); //select is inverted signal
	assign EnSClkCounter = (CurrentState != IDLE);
	
endmodule
