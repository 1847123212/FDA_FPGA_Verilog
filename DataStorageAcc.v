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
	 output reg [7:0] DataOut = 8'd0,
    input FastTrigger,
    input ReadEnable,
    input WriteClock,
    input ReadClock,
    input Reset,
    output reg DataReady = 1'b0,
	 input [7:0] numEvents,
	 input [9:0] dataLength
    );

	reg byteNumber; //read high (1) or low byte (0) 
	reg [3:0] fifoNumber = 4'b0001;
	reg [7:0] GenDataOut = 8'b0;
	wire [15:0] dataOutDQD;
	wire [15:0] dataOutDID;
	wire [15:0] dataOutDQ;
	wire [15:0] dataOutDI;
	
//	reg [10:0] readCounts = 11'd0; //this is 10 bits - 512 data points * 2 bytes each
	
	parameter WAIT_TO_TRANSMIT = 8'b00000001;
	parameter START				= 8'b00000010;
	parameter DQD_READ			= 8'b00000100;
	parameter DID_READ			= 8'b00001000;
	parameter DQ_READ				= 8'b00010000;
	parameter DI_READ 			= 8'b00100000;
	parameter CHECK_FOR_DATA 	= 8'b01000000;
	parameter END					= 8'b10000000;
	
	
	//Wait until data is available on all fifos
	wire dataReadyFromAcc = dataReadyToReadDI | dataReadyToReadDID | dataReadyToReadDQ | dataReadyToReadDQD;
	
	always@(posedge ReadClock) begin
		if(state == WAIT_TO_TRANSMIT) begin
			byteNumber <= 0;
		end
		else if (ReadEnable) begin
			if(numEvents == 8'd1)	//in the case where we only collect 1 trigger of data, we only need 1 byte
				byteNumber <= 1;
			else
				byteNumber <= ~byteNumber;
		end
	end
	
	reg dqRd = 0, dqdRd = 0, diRd = 0, didRd = 0;
	
	//note: the read signals should only pulse high for 1 clock cycle
	//after the current data has already been read
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [7:0] state = WAIT_TO_TRANSMIT;
	always@(posedge ReadClock)
      if (Reset) begin
         state <= WAIT_TO_TRANSMIT;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
			WAIT_TO_TRANSMIT: begin
				dqRd  <= 0;
				dqdRd <= 0;
				diRd  <= 0;
				didRd <= 0;
				DataReady <=0;
				if(dataReadyFromAcc)
					state <= START;
				else
					state <=WAIT_TO_TRANSMIT;
			end
			START: begin
				dqRd  <= 0;
				diRd  <= 0;
				didRd <= 0;
				DataReady <=1;
				if(ReadEnable & byteNumber) begin
					dqdRd <= 1;
					state <= DQD_READ;
				end
				else begin
					dqdRd <= 0;
					state <= START;
				end
			end
			DQD_READ: begin
				dqRd  <= 0;
				diRd  <= 0;
				dqdRd <= 0;
				DataReady <=1;
				if(ReadEnable & (byteNumber)) begin
					state <= DID_READ;
					didRd <= 1;
				end
				else begin
					state <=DQD_READ;
					didRd <= 0;
				end			
			end
			DID_READ: begin
				dqdRd <= 0;
				didRd  <= 0;
				diRd <= 0;
				DataReady <=1;
				if(ReadEnable & (byteNumber)) begin
					state <= DQ_READ;
					dqRd <= 1;
				end
				else begin
					state <=DID_READ;
					dqRd <= 0;
				end			
			end			
			DQ_READ: begin
				dqdRd <= 0;
				dqRd  <= 0;
				didRd <= 0;
				DataReady <=1;
				if(ReadEnable & (byteNumber)) begin
					state <= DI_READ;
					diRd <= 1;
				end
				else begin
					state <=DQ_READ;
					diRd <= 0;
				end
			end
			DI_READ: begin
				diRd <= 0;
				dqRd  <= 0;
				didRd <= 0;
				DataReady <=1;
				if(ReadEnable & (byteNumber)) begin
					dqdRd <= 1;
					state <= CHECK_FOR_DATA;	//move to next state
				end
				else begin
					state <=DI_READ; 	//stay at this state
					dqdRd <= 0;
				end
			end
			CHECK_FOR_DATA:begin
				DataReady <=0;
				diRd <= 0;
				dqRd  <= 0;
				didRd <= 0;
				dqdRd <=0;
				if(dataReadyFromAcc)
					state <= DQD_READ;
				else
					state <= END;
			end
			END: begin
				DataReady <=1;
				dqRd  <= 0;
				diRd  <= 0;
				didRd <= 0;
				dqdRd <= 0;
				if(ReadEnable & byteNumber)
					state <= WAIT_TO_TRANSMIT;
				else 					
					state <= END;
			end
		endcase
			
	//Mux for selecting output		
	wire [8:0] muxIn;
	assign muxIn = {state, byteNumber};
	always @(posedge ReadClock)
      case (muxIn)
         {START, 1'b0}: 	DataOut = 8'b10000000;
         {START, 1'b1}: 	DataOut = 8'b00000010;
         {DQD_READ, 1'b0}: DataOut = dataOutDQD[15:8];
         {DQD_READ, 1'b1}: DataOut = dataOutDQD[7:0];
         {DID_READ, 1'b0}: DataOut = dataOutDID[15:8];
         {DID_READ, 1'b1}: DataOut = dataOutDID[7:0];
         {DQ_READ, 1'b0}:  DataOut = dataOutDQ[15:8];
         {DQ_READ, 1'b1}:  DataOut = dataOutDQ[7:0];
			{DI_READ, 1'b0}:  DataOut = dataOutDI[15:8];
			{DI_READ, 1'b1}:  DataOut = dataOutDI[7:0];
         {END, 1'b0}: 	DataOut = 8'b10000000;
         {END, 1'b1}: 	DataOut = 8'b00000001;
      endcase
		
	wire readyToTransmit = (state == WAIT_TO_TRANSMIT);
			
//fifos 
DataCapture DI (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[31:24]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(diRd), 
    .rst(Reset),
	 .readyToTransmit(readyToTransmit),
    .dataReadyToRead(dataReadyToReadDI), 
    .dataEmpty(dataEmptyDI), 
    .dataOut(dataOutDI),
	 .dataValid(dataValidDI),
	 .numEventsToAdd(numEvents),
	 .dataLength(dataLength)
    );
	 
DataCapture DID (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[23:16]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(didRd), 
    .rst(Reset), 
	 .readyToTransmit(readyToTransmit),
    .dataReadyToRead(dataReadyToReadDID), 
    .dataEmpty(dataEmptyDID), 
    .dataOut(dataOutDID),
	 .dataValid(dataValidDID),
	 .numEventsToAdd(numEvents),
	 .dataLength(dataLength)
    );
	 
DataCapture DQ (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[15:8]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(dqRd), 
    .rst(Reset), 
	 .readyToTransmit(readyToTransmit),
    .dataReadyToRead(dataReadyToReadDQ), 
    .dataEmpty(dataEmptyDQ), 
    .dataOut(dataOutDQ),
	 .dataValid(dataValidDQ),
	 .numEventsToAdd(numEvents),
	 .dataLength(dataLength)
    );
	 
DataCapture DQD (
    .clk(WriteClock),
    .clkSlow(ReadClock), 
    .inputData(DataIn[7:0]), 
    .dataCaptureStrobe(FastTrigger), 
    .dataRead(dqdRd), 
    .rst(Reset), 
	 .readyToTransmit(readyToTransmit),
    .dataReadyToRead(dataReadyToReadDQD), 
    .dataEmpty(dataEmptyDQD), 
    .dataOut(dataOutDQD),
	 .dataValid(dataValidDQD),
	 .numEventsToAdd(numEvents),
	 .dataLength(dataLength)
    );
	 

endmodule
