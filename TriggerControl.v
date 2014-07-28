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
// Description: TriggerControl handles the external input trigger and creates a 
//	synchronized trigger signal usable by the FPGA logic.
//	Two FSMs handle the module behavior. The first is for actually reading in the
//	the external signal, and resetting the external comparator.
//	The second is used to decide if the received trigger signal should be passed
//	from the module to any external modules.
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
	 input manual_trigger,	//"artificial" trigger
    output triggered_out,
    output comp_reset_high,
    output comp_reset_low
    );

	wire t_out, manual_rst_sync, auto_rst_sync, armed_sync, manual_trigger_sync;
	wire reset_signal;
	
	//State machine for external trigger
	parameter IDLE = 				4'b0001;
	parameter TRIGGERED = 		4'b0010;
	parameter RESET = 			4'b0100;
	parameter CHECK_FOR_RST = 	4'b1000;

	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state = IDLE;
	//needs asynchronous reset because clk may not be running
	always@(posedge clk or posedge module_reset)
      if (module_reset) begin
         state <= IDLE;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            IDLE:
               if (triggered)
                  state <= TRIGGERED;
               else
                  state <= IDLE;
            TRIGGERED:
               if (triggerCounter[2])
                  state <= RESET;
               else
                  state <= TRIGGERED;
            RESET: begin
					state <= IDLE;
            end
				CHECK_FOR_RST: begin
					if(t_out)
						state <= RESET;
					else
						state <= IDLE;
				end
         endcase


	//Second FSM to determine if trigger is enabled
	parameter OFF = 				3'b001;
	parameter T_EN = 				3'b010;
	parameter WAIT_FOR_RST = 	3'b100;
	
	reg trig_out_en = 1'b0;	//this could just be implemented as teState[1]
	
	(* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [2:0] teState = OFF;
	always@(posedge clk)
		if (1'b0)
         teState <= OFF;
		else
			(* FULL_CASE, PARALLEL_CASE *) case (teState)
			OFF: begin
				trig_out_en <= 1'b0;
				if(armed_sync & ~triggered)	//include ~triggered so that we can just test for triggered in T_EN
					teState <= T_EN;
				else
					teState <= OFF;
			end
			T_EN: begin
				trig_out_en <= 1'b1;
				if(triggered)
					if(auto_rst_sync)
						teState <= OFF;	//go back to off to check if has been de-armed, and wait for trigger to de-assert	
					else
						teState <= WAIT_FOR_RST;
				else if(~armed_sync)			//if trigger is de-armed before receiving trigger signal
					teState <= OFF;
				else
					teState <= T_EN;
			end
			WAIT_FOR_RST: begin
				trig_out_en <= 1'b0;
				if(manual_rst_sync | ~armed_sync)
					teState <= OFF;
				else
					teState <= WAIT_FOR_RST;
			end
			endcase

	// Use triggerCounter to delay the trigger reset by 4 clock cycles 
	// Do this so that we don't re-trigger on the same signal input trigger immediately 
	reg [2:0] triggerCounter = 3'b000;
	always@(posedge clk) begin
		if(state != TRIGGERED)
			triggerCounter <= 3'b0;
		else if(state == TRIGGERED)
			triggerCounter <= triggerCounter + 1;
	end

	//Trigger input logic to synchronize signal
	//We have plenty of time because of the ADC 30 ns buffer
	//so double buffer
	(* ASYNC_REG="TRUE" *) reg [2:0] sreg = 3'b000;                                                                           
   always @(posedge clk) begin
		sreg <= {sreg[1:0], t_out};
   end

	assign triggered = sreg[2]; 
	assign triggered_out = (sreg[2] & trig_out_en) | manual_trigger_sync;	//only allow output trigger if enabled

	// Logic for for trigger reset
	// The trigger reset lines should only ever be asserted if
	// a reset is requested AND the trigger input is high.
	// reset_signal is asserted LOW to do reset - that is why the logic is inverted
	assign reset_signal =  ~((state == RESET) & t_out);
	
	//Cross clock domain synchronization for "slow" input signals
	async_input_sync manual_reset_sync_module (
    .clk(clk), 
    .async_in(manual_reset), 
    .sync_out(manual_rst_sync)
    );
	 
	 async_input_sync auto_reset_sync_module (
    .clk(clk), 
    .async_in(auto_reset), 
    .sync_out(auto_rst_sync)
    );

	 async_input_sync armed_sync_module (
    .clk(clk), 
    .async_in(armed), 
    .sync_out(armed_sync)
    );
	 
	 async_input_sync manual_trig_sync_module (
    .clk(clk), 
    .async_in(manual_trigger), 
    .sync_out(manual_trigger_sync)
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

