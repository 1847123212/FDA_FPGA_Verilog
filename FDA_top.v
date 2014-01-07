`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIT Hemond Lab
// Engineer: Schuyler Senft-Grupp
// 
// Create Date:    13:12:43 12/22/2013 
// Design Name: 
// Module Name:    FDA_top 
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
module FDA_top(
	//ADC control and status
	input ADC_CAL,
	input ADC_PD,
	input ADC_SDATA,
	input ADC_SCLK,
	input ADC_SCS,
	input ADC_PDQ,
	
	input ADC_CALRUN,
	
	//ADC clock and data
	input ADC_CLK_P,
	input ADC_CLK_N,
	input [31:0] ADC_DATA_P,
	input [31:0] ADC_DATA_N,

	//power enable pins
	output ANALOG_PWR_EN,
	output ADC_PWR_EN,
	
	//I2C
	input SCL,
	input SDA,
	
	//Fast trigger 
	input TRIGGER_RST_P,
	input TRIGGER_RST_N,
	input DATA_TRIGGER_N,
	input DATA_TRIGGER_P,
	
	//main FGPA clock
	input	CLK_100MHZ,

	//System power control
	input PWR_INT,
	input PWR_KILL,

	//Asynchronous serial communication
	input USB_RS232_RXD,
	output USB_RS232_TXD,
	input CTS,
	
`ifdef XILINX_ISIM
	input [7:0] DataRxD,
`endif	
	
	//GPIO
	output [3:0] GPIO				// 0, 2, and 3 connected to LEDs
   );

  wire clk;
  wire clknub;
  wire clk_enable;
  
  assign clk_enable = 1'b1;

  DCM_SP DCM_SP_INST(
    .CLKIN(CLK_100MHZ),
    .CLKFB(clk),
    .RST(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSCLK(1'b0),
    .DSSEN(1'b0),
    .CLK0(clknub),
    .CLK90(),
    .CLK180(),
    .CLK270(),
    .CLKDV(),
    .CLK2X(),
    .CLK2X180(),
    .CLKFX(),
    .CLKFX180(),
    .STATUS(),
    .LOCKED(),
    .PSDONE());
  defparam DCM_SP_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
  defparam DCM_SP_INST.CLKIN_PERIOD = 10.000;

  BUFGCE  BG (.O(clk), .CE(clk_enable), .I(clknub));
  
  assign GPIO[1] = 1'b1;
  
//------------------------------------------------------------------------------
// UART and device settings/state machines 
//------------------------------------------------------------------------------
`ifndef XILINX_ISIM
	wire [7:0] DataRxD;
	wire [7:0] FIFODataOut;
	wire [7:0] OtherDataOut;
	wire DataAvailable, ClearData;
	wire FIFORequestToSend, OtherRequestToSend, FIFODataReceived, OtherDataReceived;
	wire ArmTrigger, TriggerReset, EchoChar;

	RxDWrapper RxD (
		 .Clock(clk), 
		 .ClearData(ClearData), 
		 .SDI(USB_RS232_RXD), 
		 .CurrentData(DataRxD), 
		 .DataAvailable(DataAvailable)
		 );

	assign OtherRequestToSend = (EchoChar) ? (DataAvailable & !OtherDataReceived) : 1'b0;
	assign OtherDataOut = DataRxD;

	reg [1:0] DataHist = 2'b00;
	always@(posedge clk) begin
		DataHist[1] <= DataHist[0];
		DataHist[0] <= DataAvailable;	
	end
	assign ClearData = DataHist[1];

	TxDWrapper TxD (
		 .Clock(clk), 
		 .Reset(1'b0), 
		 .Data({FIFODataOut, OtherDataOut}), 
		 .RequestToSend({FIFORequestToSend, OtherRequestToSend}),
		 .DataReceivedOut({FIFODataReceived, OtherDataReceived}), 
		 .SDO(USB_RS232_TXD)
		 );
`endif

EchoCharFSM EchoSetting (
    .Clock(clk),
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .EchoChar(EchoChar)
    );	 

RGBFSM RGBControl(
	.Clock(clk),
	.Reset(1'b0),
	.Cmd(DataRxD),
	.RGB({GPIO[0], GPIO[2], GPIO[3]})
	);

//------------------------------------------------------------------------------
// ADC communication and control
//------------------------------------------------------------------------------
//All pins connected to ADC should be high impedance (or low)
//when this wire is low.
//This wire is only high when the ADC has been powered and PWR_INT
//is high
wire OutToADCEnable; 
assign OutToADCEnable = (PWR_INT == 1 && ADC_PWR_EN == 1);

ADC_FSM ADC_fsm (
    .Clock(clk), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .OutToADCEnable(OutToADCEnable), 
    .ADCPower(ADC_PWR_EN), 
    .AnalogPower(ANALOG_PWR_EN)
    );

endmodule
