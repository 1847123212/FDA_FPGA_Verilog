`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:33:41 01/12/2014 
// Design Name: 
// Module Name:    I2C_Comm 
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
module I2C_Comm(
	input clk,
	inout SDA,
	output SCL,
	input [15:0] data,  //MSB, LSB - for only 1 byte of data, use MSB
	input load,
	input [6:0] addr,
	input numBytes,	//1 is 2 bytes, 0 is 1
	input rd_wr,			//1 is read, 0 is write
	output busy,
	output dataReady
	);

	reg [4:0] State;
	reg [4:0] NextState;
	localparam 	IDLE =  5'b00000,
					LOAD =  5'b00001, 
					ADDR6 = 5'b00010,
					ADDR5 = 5'b00011,
					ADDR4 = 5'b00100,
					ADDR3 = 5'b00101,
					ADDR2 = 5'b00110,
					ADDR1 = 5'b00111,
					ADDR0 = 5'b01000,
					R_W =   5'b01001,
				  ADDR_ACK=5'b01010,
					B1_7 =  5'b01011,
					B1_6 =  5'b01100,
					B1_5 =  5'b01101,
					B1_4 =  5'b01110,
					B1_3 =  5'b01111,
					B1_2 =  5'b10000,
					B1_1 =  5'b10001,
					B1_0 =  5'b10010,
					B1_ACK =5'b10011,
					B2_7 =  5'b10100,
					B2_6 =  5'b10101,
					B2_5 =  5'b10110,
					B2_4 =  5'b10111,
					B2_3 =  5'b11000,
					B2_2 =  5'b11001,
					B2_1 =  5'b11010,
					B2_0 =  5'b11011,
					B2_ACK =5'b11100,
					STOP =  5'b11101; //29
					
`ifdef XILINX_ISIM
	parameter counterVal = 4;
`else
	parameter counterVal = 8;
`endif
	parameter tickVal = 2 ** (counterVal-1);	//signal for shifting
	parameter tockVal = 0;	//signal for reading 
	
	reg [counterVal-1:0] Counter = 8'b0;	//want this clock at 1/250 of 100 MHz for 400 kHz - 1/256 is close enough
	wire Tick, Tock;
	assign Tick = (Counter == tickVal);	//For one clock cycle, every 256 clock cycles, this asserts high
	assign SCL = ~((State != IDLE) && (Counter[counterVal-1] ^ Counter[counterVal-2]));	//Clock is delayed by 90 degrees from tick
	assign Tock = (Counter == tockVal);
	
	reg [27:0] ShiftReg = 28'h0;		//
	reg twoBytes = 1'b1;					//stores whether 1 or 2 byte read
	
	wire sdataReady;

	//assign data [15:0] = dataReady ? {ShiftReg[16:9], ShiftReg[7:0]} : 16'bz;	//unless data is ready, data is an input

	//data is ready when we are performing a read operation and current state is ACK
	assign dataReady = ((rd_wr == 1) && ((twoBytes == 0 && State == B1_ACK) || (State == B2_ACK))) ? 1'b1 : 1'b0;
	
	//logic for when SDA is an input
	assign SDA = ~((State == IDLE  || ShiftReg[27] == 1) && (State != STOP)) ? 1'b0 : 1'bz;	//SDA is only ever driven low

	reg BitRead = 1'b0;
	assign busy = (State == IDLE) ? 1'b0 : 1'b1;
	
/**
   inout <SDA>;
   
   wire <output_enable_signal>, <output_signal>;
   reg  <input_reg>;
   
   assign <top_level_port> = <output_enable_signal> ? <output_signal> : 1'bz;
   
   always @(posedge <clock>)
      if (<reset>)
         <input_reg>  <= 1'b0;
      else
         <input_reg>  <= <top_level_port>;	
**/
	
	//Shift register synchronous clocking
	//Data is shifted on "tick", but data is read on "tock"
	always@(posedge clk) begin
		if (load & !busy)
		begin
			ShiftReg[27] 		<= 0;	//Start bit
			ShiftReg[26:19] 	<= {addr, rd_wr};
			ShiftReg[18] 		<= 1'b1;	//high impedance output for addr acknowledge
			twoBytes		 		<= numBytes;
			
			if(rd_wr == 1) begin	//reading so high impedance output
				//Byte 1
				ShiftReg[17:10] 	<= 8'b11111111;
				ShiftReg[8:1] 		<= 8'b11111111;
				if(numBytes == 1)	//two byte read
				begin
					ShiftReg[9] <= 1'b0;	//ACK reading byte1
					ShiftReg[0] <= 1'b1;	//NACK to end transmission
				end 					
				else begin
					ShiftReg[9] <= 1'b1;	//NACK to end communication
				end
			end else begin				//writing so load data
				ShiftReg[17:10] 	<= data[15:8];	//byte 1
				ShiftReg[8:1] 	 	<= data[7:0];		//byte 2
				ShiftReg[9] 		<= 1'b1;	//Read ACK from slave device
				ShiftReg[0] 		<= 1'b1;		//Read ACK from slave device				
			end
		end
		else if(Tick)
			ShiftReg <= {ShiftReg[26:0], BitRead};

		//read the SDA value on the rising edge of SCL at the midpoint of it being high
		if(Tock)
			BitRead <= SDA;
	end

	//SCL Clock counter
	always@(posedge clk)
	begin
		if(load & !busy)
			Counter <= 0;
		else if(State != IDLE)
			Counter <= Counter + 1;
	end

	//FSM synchronous logic
	always@(posedge clk)
	begin
		State <= NextState;
	end
					
	always@(*) begin
		NextState = State;
		case(State)
			IDLE: if(load) NextState = LOAD;
			LOAD:	if(Tick) NextState = ADDR6;
			ADDR6: if(Tick) NextState = ADDR5;
			ADDR5: if(Tick) NextState = ADDR4;
			ADDR4: if(Tick) NextState = ADDR3;
			ADDR3: if(Tick) NextState = ADDR2;
			ADDR2: if(Tick) NextState = ADDR1;
			ADDR1: if(Tick) NextState = ADDR0;
			ADDR0: if(Tick) NextState = R_W;
			R_W:	 if(Tick) NextState = ADDR_ACK;
			ADDR_ACK: if(Tick) NextState = B1_7;
			B1_7: if(Tick) NextState = B1_6;
			B1_6: if(Tick) NextState = B1_5;
			B1_5: if(Tick) NextState = B1_4;
			B1_4: if(Tick) NextState = B1_3;
			B1_3: if(Tick) NextState = B1_2;
			B1_2: if(Tick) NextState = B1_1;
			B1_1: if(Tick) NextState = B1_0;
			B1_0: if(Tick) NextState = B1_ACK;
			B1_ACK: begin
				if(Tick && twoBytes) NextState = B2_7;
				else if(Tick) NextState = STOP;
			end
			B2_7: if(Tick) NextState = B2_6;
			B2_6: if(Tick) NextState = B2_5;
			B2_5: if(Tick) NextState = B2_4;
			B2_4: if(Tick) NextState = B2_3;
			B2_3: if(Tick) NextState = B2_2;
			B2_2: if(Tick) NextState = B2_1;
			B2_1: if(Tick) NextState = B2_0;
			B2_0: if(Tick) NextState = B2_ACK;
			B2_ACK: if(Tick) NextState = STOP;
			STOP: if(Counter == 8'b0) NextState = IDLE;
			default: NextState = IDLE;
		endcase
	end

endmodule
