`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:21:34 06/26/2013 
// Design Name: 
// Module Name:    TxDWrapper 
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
module TxDWrapper(
	input Clock,
	input Reset,
	input [15:0] Data,
	input [1:0] LatchData,
	output [1:0] Busy,
	output SDO
   );

//No more than one external device at a time is told that Transmitter is not busy
reg [3:0] BusyReg = 4'b1011;
wire TxDBusy;

assign Busy[1] = BusyReg[2] | TxDBusy;
assign Busy[0] = BusyReg[0] | TxDBusy;

always@(posedge Clock) begin
	BusyReg[0] <= BusyReg [3];
	BusyReg[3:1] <= BusyReg [2:0];
end

wire [7:0] TxData; 

assign TxData = (BusyReg[3] == 0 | BusyReg[2] == 0) ? Data[15:8] : Data[7:0]; 
assign TxDStart = (BusyReg[3] == 0 | BusyReg[2] == 0) ? LatchData[1] : LatchData[0];

async_transmitter txd (
    .clk(Clock), 
    .TxD_start(TxDStart), 
    .TxD_data(TxData), 
    .TxD(SDO), 
    .TxD_busy(TxDBusy)
    );
endmodule

