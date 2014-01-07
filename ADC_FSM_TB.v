`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:44:00 01/07/2014
// Design Name:   ADC_FSM
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/ADC_FSM_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ADC_FSM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ADC_FSM_TB;

	// Inputs
	reg Clock;
	reg Reset;
	reg [7:0] Cmd;
	reg OutToADCEnable;
	reg Sleep;
	reg WakeUp;
	reg InCalRunning;

	// Outputs
	wire ADCPower;
	wire AnalogPower;
	wire OutSclk;
	wire OutSdata;
	wire OutSelect;
	wire OutPD;
	wire OutPDQ;
	wire OutCal;

	// Instantiate the Unit Under Test (UUT)
	ADC_FSM uut (
		.Clock(Clock), 
		.Reset(Reset), 
		.Cmd(Cmd), 
		.OutToADCEnable(OutToADCEnable && ADCPower), 
		.Sleep(Sleep), 
		.WakeUp(WakeUp), 
		.ADCPower(ADCPower), 
		.AnalogPower(AnalogPower), 
		.OutSclk(OutSclk), 
		.OutSdata(OutSdata), 
		.OutSelect(OutSelect), 
		.OutPD(OutPD), 
		.OutPDQ(OutPDQ), 
		.OutCal(OutCal), 
		.InCalRunning(InCalRunning)
	);

	initial begin
		// Initialize Inputs
		Clock = 0;
		Reset = 0;
		Cmd = 0;
		OutToADCEnable = 1;
		Sleep = 0;
		WakeUp = 0;
		InCalRunning = 0;

		// Wait 100 ns for global reset to finish
		#100;
      #100 Cmd[7:0] = "o";
		#10 Cmd[7:0] = 8'bzzzzzzzz;
		
	end
	
	always 
		#5 Clock = ~Clock;
      
	always @(posedge Clock) begin
		if(OutCal == 1) begin
			#40 InCalRunning = 1;
			#100 InCalRunning = 0;
		end
	end
endmodule

