`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:04:24 01/07/2014 
// Design Name: 
// Module Name:    ADCDataInput 
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
module ADCDataInput(
	input [31:0] DataInP,
	input [31:0] DataInN,
	input ClockIn,
	input ClockInDelayed,
	output [31:0] DataOut
	);

	wire [31:0] DataConnection;
	wire ClockEnable = 1'b1;

	//Create the data logic
	//1. Connect the physical pins to the input buffer
	//2. Wire input buffer to registers
	//Depending on physical location, use ClockIn or ClockDelayed
	genvar pin_count;
	generate for (pin_count = 0; pin_count < 32; pin_count = pin_count + 1) begin: pins
    // Instantiate the buffers
    ////------------------------------
    // Instantiate a buffer for every bit of the data bus
	 
	 if(pin_count  < 16)
		IBUFDS_DIFF_OUT #(
			.DIFF_TERM("TRUE"),   // Differential Termination, "TRUE"/"FALSE" 
			.IOSTANDARD("LVDS_33") // Specify the input I/O standard
		) IBUFDS_DIFF_OUT_inst (
			.O(DataConnection[pin_count]),   // Buffer diff_p output
			.OB(OB), // Buffer diff_n output
			.I(DataInP  [pin_count]),   // Diff_p buffer input (connect directly to top-level port)
			.IB(DataInN  [pin_count])  // Diff_n buffer input (connect directly to top-level port)
		);
	else
		IBUFDS_DIFF_OUT #(
			.DIFF_TERM("TRUE"),   // Differential Termination, "TRUE"/"FALSE" 
			.IOSTANDARD("LVDS_33") // Specify the input I/O standard
		) IBUFDS_DIFF_OUT_inst (
			.O(O),   // Buffer diff_p output
			.OB(DataConnection[pin_count]), // Buffer diff_n output
			.I(DataInP  [pin_count]),   // Diff_p buffer input (connect directly to top-level port)
			.IB(DataInN  [pin_count])  // Diff_n buffer input (connect directly to top-level port)
		);
		
	if((pin_count  > 10 && pin_count < 16) || (pin_count > 25)) //Normal Clock
		// Pack the registers into the IOB
		(* IOB = "true" *)	
		FDRE FDRE_inst (
			.Q(DataOut[pin_count]),      		// 1-bit Data output
			.C(ClockIn),      					// 1-bit Clock input
			.CE(ClockEnable),    				// 1-bit Clock enable input
			.R(Reset),      						// 1-bit Synchronous reset input
			.D(DataConnection[pin_count])  	// 1-bit Data input
		);
	else				//Delayed Clock
		(* IOB = "true" *)	
		FDRE FDRE_inst (
			.Q(DataOut[pin_count]),      	// 1-bit Data output
			.C(ClockInDelayed),      		// 1-bit Clock input
			.CE(ClockEnable),    			// 1-bit Clock enable input
			.R(Reset),      					// 1-bit Synchronous reset input
			.D(DataConnection[pin_count]) // 1-bit Data input
		);
  end
  endgenerate
endmodule
