`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:05:12 10/25/2014 
// Design Name: 
// Module Name:    PeakDetector 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Given three values in time, determine if value D2 is a peak by 
// comparing it to its neighbors along with a general threshold.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PeakDetector(
    input clk,
	 input [7:0] DIn,
    input [7:0] minLevel,
	 input rst,
	 input enable,
    output reg pkDetected,
	 output reg [7:0] DOut
    );
	 
	 reg [7:0] D1 = 8'hFF;
	 reg [7:0] D2 = 8'hFF;
	 reg [7:0] D3 = 8'hFF;
	 
	 reg [7:0] pkValue;
	 reg [9:0] timeSincePk;	//value from 0 to 512 - if we can collect more than 512 ns of data, this needs to be increased
	 reg [1:0] timer;
	 reg [7:0] threshold = 8'd0;
	 reg [7:0] thresholdChange = 8'd0;
	 
	 //Read in and shift the data
	 always@(posedge clk) begin
		if(rst == 1'b1) begin
			D1 <= 8'hFF;
			D2 <= 8'hFF;
			D3 <= 8'hFF;		
			end
		else if(enable) begin
			D1 <= DIn;
			D2 <= D1;
			D3 <= D2;
		end
	 end
	 
	 //Check for peak and set outputs
	 always@(posedge clk) begin
		if ((D2 < threshold) & (D2 < D1) & (D2 <= D3)) begin
			pkDetected <= 1;
			DOut <= 8'd122 - D2;	//accumulate the difference between the signal and the mean signal
			end
		else begin
			pkDetected <= 0;
			DOut <= 8'b0;	 
		end
	 end
	 
	 //Constantly update what the peak threashold should be 
	 //It is dependent on the previous peak that was detected
	 //By changing the thresholdChange by dividing by 8 is approx.
	 //equivalent to an exponential decrease with a half life of 6 clock cycles
	 always@(posedge clk) begin
		if(rst == 1'b1)
			threshold <= minLevel;
		else if (enable)
			if((D2 < threshold) & (D2 < D1) & (D2 <=D3))
				threshold <= D2;
			else
				threshold <= threshold + thresholdChange;
	 end
	 
	 //Constantly update amount to change threshold by
	 always@(posedge clk) begin
		if((D2 < threshold) & (D2 < D1) & (D2 <=D3))
			thresholdChange <= ((minLevel - D2) + 8'd7) >> 8'd3 ;
		else
			thresholdChange <= ((minLevel - threshold) + 8'd7) >> 8'd3 ;
	 end
	 
	 
		
endmodule
