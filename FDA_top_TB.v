`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:19:55 01/06/2014
// Design Name:   FDA_top
// Module Name:   C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FDA_top_TB.v
// Project Name:  FDA_FPGA_Verilog
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FDA_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FDA_top_TB;

	// Inputs
	reg ADC_CAL;
	reg ADC_PD;
	reg ADC_SDATA;
	reg ADC_SCLK;
	reg ADC_SCS;
	reg ADC_PDQ;
	reg ADC_CALRUN;
	reg ADC_CLK_P;
	reg ADC_CLK_N;
	reg [31:0] ADC_DATA_P;
	reg [31:0] ADC_DATA_N;
	reg SCL;
	reg SDA;
	reg TRIGGER_RST_P;
	reg TRIGGER_RST_N;
	reg DATA_TRIGGER_N;
	reg DATA_TRIGGER_P;
	reg CLK_100MHZ;
	reg PWR_INT;
	reg PWR_KILL;
	reg USB_RS232_RXD;
	reg CTS;
	reg [7:0] DataRxD;

	// Outputs
	wire ADC_PWR_EN;
	wire ANALOG_PWR_EN;
	wire USB_RS232_TXD;
	wire [3:0] GPIO;

	// Instantiate the Unit Under Test (UUT)
	FDA_top uut (
		.ADC_CAL(ADC_CAL), 
		.ADC_PD(ADC_PD), 
		.ADC_SDATA(ADC_SDATA), 
		.ADC_SCLK(ADC_SCLK), 
		.ADC_SCS(ADC_SCS), 
		.ADC_PDQ(ADC_PDQ), 
		.ADC_CALRUN(ADC_CALRUN), 
		.ADC_CLK_P(ADC_CLK_P), 
		.ADC_CLK_N(ADC_CLK_N), 
		.ADC_DATA_P(ADC_DATA_P), 
		.ADC_DATA_N(ADC_DATA_N), 
		.ANALOG_PWR_EN(ANALOG_PWR_EN), 
		.ADC_PWR_EN(ADC_PWR_EN), 
		.SCL(SCL), 
		.SDA(SDA), 
		.TRIGGER_RST_P(TRIGGER_RST_P), 
		.TRIGGER_RST_N(TRIGGER_RST_N), 
		.DATA_TRIGGER_N(DATA_TRIGGER_N), 
		.DATA_TRIGGER_P(DATA_TRIGGER_P), 
		.CLK_100MHZ(CLK_100MHZ), 
		.PWR_INT(PWR_INT), 
		.PWR_KILL(PWR_KILL), 
		.USB_RS232_RXD(USB_RS232_RXD), 
		.USB_RS232_TXD(USB_RS232_TXD), 
		.CTS(CTS), 
		.GPIO(GPIO),
		.DataRxD(DataRxD)
	);

	initial begin
		// Initialize Inputs
		ADC_CAL = 0;
		ADC_PD = 0;
		ADC_SDATA = 0;
		ADC_SCLK = 0;
		ADC_SCS = 0;
		ADC_PDQ = 0;
		ADC_CALRUN = 0;
		ADC_CLK_P = 0;
		ADC_CLK_N = 0;
		ADC_DATA_P = 0;
		ADC_DATA_N = 0;
		SCL = 0;
		SDA = 0;
		TRIGGER_RST_P = 0;
		TRIGGER_RST_N = 0;
		DATA_TRIGGER_N = 0;
		DATA_TRIGGER_P = 0;
		CLK_100MHZ = 0;
		PWR_INT = 1;
		PWR_KILL = 1;
		USB_RS232_RXD = 0;
		CTS = 0;

		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here	
		#50 DataRxD = "O";
		#200 DataRxD = "P";
		#40 DataRxD = "p";
		#100 DataRxD = "o";
	end

	always
		#5 CLK_100MHZ = !CLK_100MHZ; 
      
endmodule

