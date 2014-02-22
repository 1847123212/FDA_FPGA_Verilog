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
	output ADC_CAL,
	output ADC_PD,
	output ADC_SDATA,
	output ADC_SCLK,
	output ADC_SCS,
	output ADC_PDQ,
	
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
	output SCL,
	inout SDA,
	
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
  
//------------------------------------------------------------------------------
// UART and device settings/state machines 
//------------------------------------------------------------------------------
wire [7:0] StoredDataOut;

`ifndef XILINX_ISIM
	wire [7:0] DataRxD;
	wire [7:0] OtherDataOut;
	wire DataAvailable, ClearData;
	wire OtherDataLatch;
	wire ArmTrigger, TriggerReset, EchoChar;
	wire FIFOTransmitBusy, OtherTransmitBusy;
	assign OtherTransmitBusy = 1'b0;
	assign OtherDataOut = 8'b0;
	assign OtherDataLatch = 1'b0;
	
	RxDWrapper RxD (
		 .Clock(clk), 
		 .ClearData(ClearData), 
		 .SDI(USB_RS232_RXD), 
		 .CurrentData(DataRxD), 
		 .DataAvailable(DataAvailable)
		 );

	TxDWrapper TxD (
		.Clock(clk), 
		.Reset(1'b0), 
		.Data({StoredDataOut, OtherDataOut}), 
		.LatchData({DataValid, OtherDataLatch}), 
		.Busy({FIFOTransmitBusy, OtherTransmitBusy}), 
		.SDO(USB_RS232_TXD)
	);
	
	assign ReadEnable = ~FIFOTransmitBusy & DataReadyToSend;
`endif

EchoCharFSM EchoSetting (
    .Clock(clk),
    .Reset(1'b0), 
    .Cmd(DataRxD), 
    .EchoChar(EchoChar)
    );
	 
wire Red, Green, Blue;

RGBFSM RGBControl(
	.Clock(clk),
	.Reset(1'b0),
	.NewCmd(DataAvailable),
	.Cmd(DataRxD),
	.RGB({Red, Green, Blue})
	);

wire [6:0] I2Caddr;
wire [15:0] I2Cdata;
wire I2Cbytes, I2Cr_w, I2C_load, I2CBusy, I2CDataReady;

DACControlFSM DAC (
    .clk(clk), 
    .UART_Rx(DataRxD), 
    .UART_DataReady(DataAvailable), 
    .UART_Tx(OtherDataOut), 
    .I2Caddr(I2Caddr), 
    .I2Cdata(I2Cdata), 
    .I2Cbytes(I2Cbytes), 
    .I2Cr_w(I2Cr_w), 
    .I2C_load(I2C_load), 
    .I2CBusy(I2CBusy), 
    .I2CDataReady(I2CDataReady)
    );

I2C_Comm I2C (
    .clk(clk), 
    .SDA(SDA), 
    .SCL(SCL), 
    .data(I2Cdata), 
    .load(I2C_load), 
    .addr(I2Caddr), 
    .numBytes(I2Cbytes), 
    .rd_wr(I2Cr_w), 
    .busy(I2CBusy), 
    .dataReady(I2CDataReady)
    );

//------------------------------------------------------------------------------
// ADC communication and control
//------------------------------------------------------------------------------
//All pins connected to ADC should be high impedance (or low)
//when this wire is low.
//This wire is only high when the ADC has been powered and PWR_INT
//is high
wire OutToADCEnable, ADCSleep, ADCWake; 
assign OutToADCEnable = (PWR_INT == 1 && ADC_PWR_EN == 1);
assign ADCSleep = 0;
assign ADCWake = 0;
wire [3:0] ADC_State;

ADC_FSM ADC_controller (
    .Clock(clk), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
	 .NewCmd(DataAvailable),
    .OutToADCEnable(OutToADCEnable), 
    .Sleep(ADCSleep), 
    .WakeUp(ADCWake), 
    .ADCPower(ADC_PWR_EN), 
    .AnalogPower(ANALOG_PWR_EN), 
    .OutSclk(ADC_SCLK), 
    .OutSdata(ADC_SDATA), 
    .OutSelect(ADC_SCS), 
    .OutPD(ADC_PD), 
    .OutPDQ(ADC_PDQ), 
    .OutCal(ADC_CAL), 
    .InCalRunning(ADC_CALRUN),
	 .State(ADC_State)
    );

//------------------------------------------------------------------------------
// ADC Data Clock
//------------------------------------------------------------------------------
wire ClkADC2DCM, ADCClock, ADCClockDelayed, ADCClockLocked;
// Create the ADC input clock buffer and send the signal to the DCM
IBUFGDS #(
      .DIFF_TERM("TRUE"), 		// Differential Termination
      .IOSTANDARD("LVDS_33") 	// Specifies the I/O standard for this buffer
   ) IBUFGDS_adcClock (
      .O(ClkADC2DCM),  			// Clock buffer output
      .I(ADC_CLK_P),  			// Diff_p clock buffer input
      .IB(ADC_CLK_N) 			// Diff_n clock buffer input
   );
	
ADC_Clk_Manager ADC_Clock
   (// Clock in ports
    .CLK_IN1(ClkADC2DCM),      // IN
    // Clock out ports
    .CLK_OUT1(ADCClock),     // OUT
    .CLK_OUT2(ADCClockDelayed),     // OUT
    // Status and control signals
    .RESET(1'b0),// IN
    .LOCKED(ADCClockLocked));      // OUT

assign GPIO[1] = 0;
assign GPIO[0] = ADC_State[2];	//Red;					//red
assign GPIO[2] = ADC_State[0];		//(ADCClockLocked); //green
assign GPIO[3] = ADC_State[1];		//(ClockLogic); //blue

reg [1:0] InputClockOn = 2'b00;
wire ClockLogic;
assign ClockLogic = (InputClockOn[1] != InputClockOn[0]); 
always@(posedge ADCClock) begin
	InputClockOn <= {InputClockOn[0], ClkADC2DCM};
end

//------------------------------------------------------------------------------
// ADC Data Input Registers
//------------------------------------------------------------------------------
wire [31:0] ADCRegDataOut;		//DQD, DQ, DID, DI
ADCDataInput ADC_Data_Capture (
    .DataInP(ADC_DATA_P), 
    .DataInN(ADC_DATA_N), 
    .ClockIn(ADCClock), 
    .ClockInDelayed(ADCClockDelayed), 
    .DataOut(ADCRegDataOut)
    );

//------------------------------------------------------------------------------
// Data FIFOs 
//------------------------------------------------------------------------------
wire FifoNotFull; 

DataStorage Fifos (
    .DataIn(ADCRegDataOut), 
    .DataOut(StoredDataOut), 
    .WriteStrobe(EchoChar),			//For now, store and transmit data when EchoChar set 
    .ReadEnable(ReadEnable), 
    .WriteClock(ADCClock), 
    .WriteClockDelayed(ADCClockDelayed), 
    .ReadClock(clk), 
    .Reset(1'b0), 
    .DataValid(DataValid), 
    .FifoNotFull(FifoNotFull), 
    .DataReadyToSend(DataReadyToSend)
    );

endmodule
