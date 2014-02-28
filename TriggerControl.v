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
	 input clk,
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
	reg triggered_r = 1'b0;
	reg [1:0] reset_requested = 2'b0;
	assign triggered = triggered_r;

	IBUFDS #(
      .DIFF_TERM("FALSE"),   // Differential Termination
      .IOSTANDARD("LVPECL_33") // Specify the input I/O standard
   ) IBUFDS_trigger (
      .O(t_out),  // Buffer output
      .I(t_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(t_n) // Diff_n buffer input (connect directly to top-level port)
   );
	
   OBUFT #(
      .DRIVE(24),   // Specify the output drive strength
      .IOSTANDARD("LVCMOS33"), // Specify the output I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) OBUFT_t_reset_h (
      .O(comp_reset_high),     // Buffer output (connect directly to top-level port)
      .I(1'b1),     // Buffer input
      .T(reset_signal)      // 3-state enable input 
   );

   OBUFT #(
      .DRIVE(24),   // Specify the output drive strength
      .IOSTANDARD("LVCMOS33"), // Specify the output I/O standard
      .SLEW("SLOW") // Specify the output slew rate
   ) OBUFT_t_reset_l (
      .O(comp_reset_low),     // Buffer output (connect directly to top-level port)
      .I(1'b0),     				// Buffer input
      .T(reset_signal)      	// 3-state enable input 
   );

	assign reset_signal =  ~(reset_requested[1] == 0 && reset_requested[0] == 1);	 //only do reset if high
	
	//Synchronize trigger with clock
	always@(posedge clk) begin
		reset_requested [1:0] = {reset_requested [0], t_reset};
		if(t_reset)
			triggered_r <= 1'b0;
		else if(armed)
			triggered_r <= t_out;
	end
	
endmodule
