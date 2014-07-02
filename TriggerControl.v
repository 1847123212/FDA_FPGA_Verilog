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
	 input module_reset,
	 input manual_reset,
	 input auto_reset,
    output triggered,
    output comp_reset_high,
    output comp_reset_low,
	 output [3:0] state_w
    );

	wire t_out, manual_reset_sync;
	wire reset_signal;
	
	//State machine for trigger
	
	parameter IDLE = 4'b0001;
	parameter ARMED = 4'b0010;
	parameter TRIGGERED = 4'b0100;
	parameter RESET = 4'b1000;

	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state = IDLE;
	always@(posedge clk or posedge module_reset)
      if (module_reset) begin
         state <= IDLE;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            IDLE : begin
               if (armed)
                  state <= ARMED;
					else if (manual_reset_sync)
						state <= RESET;
               else
                  state <= IDLE;
            end
            ARMED : begin
               if (triggered)
                  state <= TRIGGERED;
					else if (armed == 1'b0)
						state <= IDLE;
               else
                  state <= ARMED;
            end
            TRIGGERED : begin
               if (triggerCounter[2] & (manual_reset_sync | auto_reset))
                  state <= RESET;
               else
                  state <= TRIGGERED;
            end
            RESET : begin
					state <= IDLE;
            end
         endcase

	assign state_w = state;

	// use triggerCounter to delay the trigger reset by 4 clock cycles
	reg [2:0] triggerCounter = 3'b1;
	always@(posedge clk) begin
		if(state != TRIGGERED)
			triggerCounter <= 3'b0;
		else if(~triggerCounter[2])
			triggerCounter <= triggerCounter + 1;
	end

	//trigger input logic to synchronize signal
	(* ASYNC_REG="TRUE" *) reg [1:0] sreg;                                                                           
   always @(posedge clk) begin
		if(state != ARMED)
			sreg <= 2'b00;
		else
			sreg <= {sreg[0], t_out};
   end

	assign triggered = sreg[1];

	// Logic for for trigger reset
	// The trigger reset lines should only ever be asserted if
	// a reset is requested AND the trigger input is high.
	// reset_signal is asserted LOW to do reset - that is why the logic is inverted
	assign reset_signal =  ~((state == RESET) & t_out);
	
	async_input_sync manual_reset_sync_module (
    .clk(clk), 
    .async_in(manual_reset), 
    .sync_out(manual_reset_sync)
    );

	IBUFDS #(
      .DIFF_TERM("FALSE"),   // Differential Termination
      .IOSTANDARD("LVPECL_33") // Specify the input I/O standard
   ) IBUFDS_trigger (
      .O(t_out),  // Buffer output
      .I(t_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(t_n) // Diff_n buffer input (connect directly to top-level port)
   );

	
	//Output buffers for the comparator reset logic
	//The T enable pin is active low - that is, when T is high,
	//the output is Z or high impedance. When T is low, the output
	// is I.

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

