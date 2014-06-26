`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:19 02/22/2014 
// Design Name: 
// Module Name:    TriggerControl 
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
module TriggerControl(
	 input clk,	//this is the ADC clock
    input t_p,
    input t_n,
    input armed,
	 input t_reset,
    output triggered,
    output comp_reset_high,
    output comp_reset_low
    );

	wire t_out;
	wire reset_signal;
	reg triggered_out = 1'b0;
	reg [1:0] reset_requested = 2'b0;
	
	assign reset_signal =  ~(reset_requested[1] == 0 & reset_requested[0] == 1);	 //only do reset if high
	
	always@(posedge clk) begin
		reset_requested [1:0] = {reset_requested [0], t_reset & triggered};
	end

   (* ASYNC_REG="TRUE" *) reg [1:0] sreg;                                                                           
   always @(posedge clk) begin
		//sync_out <= sreg[1];
		if(t_reset)
			sreg <= 2'b00;
		else if (armed)
			sreg <= {sreg[0], t_out};
   end

	assign triggered = sreg[1];

	IBUFDS #(
      .DIFF_TERM("FALSE"),   // Differential Termination
      .IOSTANDARD("LVPECL_33") // Specify the input I/O standard
   ) IBUFDS_trigger (
      .O(t_out),  // Buffer output
      .I(t_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(t_n) // Diff_n buffer input (connect directly to top-level port)
   );

/**
	//signal is clocked in by the ADC clock
	//CE is controlled by the armed input
	(* IOB = "true" *)	
	FDRE FDRE_inst (
		.Q(triggered_r),  // 1-bit Data output
		.C(clk),      		// 1-bit Clock input
		.CE(armed),    	// 1-bit Clock enable input
		.R(t_reset),      // 1-bit Synchronous reset input
		.D(t_out) 			// 1-bit Data input
	);
**/	
   OBUFT #(
      .DRIVE(24),   // Specify the output drive strength
      .IOSTANDARD("LVCMOS33"), // Specify the output I/O standard
      .SLEW("FAST") // Specify the output slew rate
   ) OBUFT_t_reset_h (
      .O(comp_reset_high),     // Buffer output (connect directly to top-level port)
      .I(1'b1),     // Buffer input
      .T(reset_signal)      // 3-state enable input 
   );

   OBUFT #(
      .DRIVE(24),   // Specify the output drive strength
      .IOSTANDARD("LVCMOS33"), // Specify the output I/O standard
      .SLEW("FAST") // Specify the output slew rate
   ) OBUFT_t_reset_l (
      .O(comp_reset_low),     // Buffer output (connect directly to top-level port)
      .I(1'b0),     				// Buffer input
      .T(reset_signal)      	// 3-state enable input 
   );

endmodule

