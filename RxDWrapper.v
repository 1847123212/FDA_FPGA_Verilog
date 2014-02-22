`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:37:53 06/27/2013 
// Design Name: 
// Module Name:    RxDWrapper 
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
module RxDWrapper(
	input Clock,
	input ClearData,
	input SDI,
	output reg [7:0] CurrentData,
	output reg DataAvailable
   );

wire RxD_data_ready, dataReady;
wire [7:0] RxD_data;

async_receiver rxd (
    .clk(Clock), 
    .RxD(SDI), 
    .RxD_data_ready(dataReady), 
    .RxD_data(RxD_data) 
    );

always@(posedge Clock) begin
	if(dataReady) begin
		CurrentData <= RxD_data;
		DataAvailable <= 1'b1;
	end else
		DataAvailable <= 0;
end

/**
CURRENTLY JUST PASSING DATA THROUGH.>> MAYBE ADD BUFFERING LATER

assign DataAvailable = (CurrentData > 8'b0);

//-------------------------------------------------
//Synchronous transition of data and reset
//-------------------------------------------------
always@(posedge Clock) begin
	if(ClearData) begin
		CurrentData <= 8'b0;
	end else
		CurrentData <= NewData;
end

//-------------------------------------------------
//New data stored if available
//-------------------------------------------------
always@(*) begin
	NewData = CurrentData;
	if(RxD_data_ready == 1) 
		NewData[7:0] = RxD_data[7:0];
	else
		NewData = 8'bzzzzzzzz;
end

**/

endmodule
