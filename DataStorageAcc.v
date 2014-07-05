`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIT
// Engineer: Schuyler Senft-Grupp
// 
// Create Date:    14:30:37 07/04/2014 
// Design Name: 
// Module Name:    DataStorageAcc 
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
module DataStorageAcc(
    input [31:0] DataIn,
    output reg [7:0] DataOut,
    input FastTrigger,
    input ReadEnable,
    input WriteClock,
    input ReadClock,
    input Reset,
    output reg DataReady = 0
    );


	reg byteNumber; //read high (1) or low byte (0) 
	reg [3:0] fifoNumber = 4'b0001; 
	wire [15:0] dataOutDQD;
	wire [15:0] dataOutDID;
	wire [15:0] dataOutDQ;
	wire [15:0] dataOutDI;
	
	parameter WAIT_TO_TRANSMIT = 5'b00001;
	parameter DQD_READ		= 5'b00010;
	parameter DID_READ		= 5'b00100;
	parameter DQ_READ			= 5'b01000;
	parameter DI_READ 		= 5'b10000;
	
	
	//Wait until data is available on all fifos
	wire dataReadyFromAcc = dataReadyToReadDI & dataReadyToReadDID & dataReadyToReadDQ & dataReadyToReadDQD;
	
	reg [9:0] readCounts = 0; //this is 10 bits - 512 data points * 2 bytes each
	
	always@(posedge ReadClock) begin
		DataReady <= (state != WAIT_TO_TRANSMIT);
		if(state == WAIT_TO_TRANSMIT) begin
			byteNumber <= 0;
			readCounts <= 0;
		end
		else if (ReadEnable) begin
			byteNumber <= ~byteNumber;
			readCounts <= readCounts + 1;
		end
	end
	
	reg dqRd = 0, dqdRd = 0, diRd = 0, didRd = 0;
	
	wire fsmReset = (readCounts == 10'b1111111111) | Reset;
	
	//note: the read signals should only pulse high for 1 clock cycle
	//after the current data has already been read
	
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [4:0] state = WAIT_TO_TRANSMIT;
	always@(posedge ReadClock)
      if (fsmReset) begin
         state <= WAIT_TO_TRANSMIT;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
			WAIT_TO_TRANSMIT: begin
				dqRd  <= 0;
				dqdRd <= 0;
				diRd  <= 0;
				didRd <= 0;
				if(dataReadyFromAcc)
					state <= DQD_READ;
				else
					state <=WAIT_TO_TRANSMIT;
			end
			DQD_READ: begin
				dqRd  <= 0;
				diRd  <= 0;
				didRd <= 0;
				if(ReadEnable & (byteNumber)) begin
					state <= DID_READ;
					dqdRd <= 1;
				end
				else begin
					state <=DQD_READ;
					dqdRd <= 0;
				end
				if(byteNumber)
					DataOut <= dataOutDQD[7:0];
				else
					DataOut <= dataOutDQD[15:8];				
			end
			DID_READ: begin
				dqdRd <= 0;
				dqRd  <= 0;
				diRd <= 0;
				if(ReadEnable & (byteNumber)) begin
					state <= DQ_READ;
					didRd <= 1;
				end
				else begin
					state <=DID_READ;
					didRd <= 0;
				end
				if(byteNumber)
					DataOut <= dataOutDID[7:0];
				else
					DataOut <= dataOutDID[15:8];				
			end			
			DQ_READ: begin
				dqdRd <= 0;
				diRd  <= 0;
				didRd <= 0;
				
				if(ReadEnable & (byteNumber)) begin
					state <= DI_READ;
					dqRd <= 1;
				end
				else begin
					state <=DQ_READ;
					dqRd <= 0;
				end
				
				if(byteNumber)
					DataOut <= dataOutDQ[7:0];
				else
					DataOut <= dataOutDQ[15:8];
			end
			DI_READ: begin
				dqdRd <= 0;
				dqRd  <= 0;
				didRd <= 0;
				
				if(ReadEnable & (byteNumber)) begin
					state <= DQD_READ;	//move to next state
					diRd <= 1;
				end
				else begin
					state <=DI_READ; 	//stay at this state
					diRd <= 0;
				end
				
				if(byteNumber)
					DataOut <= dataOutDI[7:0];
				else
					DataOut <= dataOutDI[15:8];
			end
		endcase
			
			
//fifos 
DataAccumulator DI (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[31:24]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(diRd), 
    .rst(Reset), 
    .dataReadyToRead(dataReadyToReadDI), 
    .dataEmpty(dataEmptyDI), 
    .dataOut(dataOutDI)
    );
	 
DataAccumulator DID (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[23:16]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(didRd), 
    .rst(Reset), 
    .dataReadyToRead(dataReadyToReadDID), 
    .dataEmpty(dataEmptyDID), 
    .dataOut(dataOutDID)
    );
	 
DataAccumulator DQ (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[15:8]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(dqRd), 
    .rst(Reset), 
    .dataReadyToRead(dataReadyToReadDQ), 
    .dataEmpty(dataEmptyDQ), 
    .dataOut(dataOutDQ)
    );
	 
DataAccumulator DQD (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[7:0]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(dqdRd), 
    .rst(Reset), 
    .dataReadyToRead(dataReadyToReadDQD), 
    .dataEmpty(dataEmptyDQD), 
    .dataOut(dataOutDQD)
    );
	 

endmodule
