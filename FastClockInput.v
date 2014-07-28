`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:44:55 07/26/2014 
// Design Name: 
// Module Name:    FastClockInput 
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
module FastClockInput(
    input clk_pin_p,
    input clk_pin_n,
    input sys_clk,
    output clk_out,
    output clk_valid
    );
	 
	 
	//Initialize the actual clock 
	wire ClkIO2Bufg;
	IBUFGDS #(
      .DIFF_TERM("TRUE"), 		// Differential Termination
      .IOSTANDARD("LVDS_33") 	// Specifies the I/O standard for this buffer
   ) IBUFGDS_adcClock (
      .O(ClkIO2Bufg),  			// Clock buffer output
      .I(clk_pin_p),  			// Diff_p clock buffer input
      .IB(clk_pin_n) 			// Diff_n clock buffer input
   );
	
	BUFG clk_out_bufg (
		.O(clk_out), // 1-bit output: Clock buffer output
		.I(ClkIO2Bufg)  // 1-bit input: Clock buffer input
	);
	
	//Check to see if input clock is detected and valid
	reg [2:0] InputClockCounter = 3'b000;
	reg [7:0] InputClockCheck = 8'b00000000;
	wire clk_check_100mhz;

	assign clk_valid = ((InputClockCheck[7:5] != 3'b111) &  (InputClockCheck[7:5] != 3'b000) & 
										(InputClockCheck[2:0] != 3'b111) &  (InputClockCheck[2:0] != 3'b000)); 

	always@(posedge clk_out) begin
		InputClockCounter <= InputClockCounter + 1;
	end

	async_input_sync input_clk_counter_sync (
		 .clk(sys_clk), 
		 .async_in(InputClockCounter[2]), //InputClockCounter[2] changes at 62mhz
		 .sync_out(clk_check_100mhz)
		 );

	always@(posedge sys_clk) begin
		InputClockCheck <= {InputClockCheck[6:0], clk_check_100mhz};
	end

endmodule
