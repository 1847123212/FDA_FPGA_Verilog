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
	output TRIGGER_RST_P,
	output TRIGGER_RST_N,
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
	
	//GPIO
	output [3:0] GPIO				// 0, 2, and 3 connected to LEDs
   );

	wire clk, AdcClk, AdcClkValid;
	wire Red, Green, Blue;
	wire triggered, TriggerReset;
	wire recordData, adcPwrOn;
	wire [3:0] adcState;
	wire [7:0] selfTriggerValue;
	wire [7:0] eventsToAdd;
  
//------------------------------------------------------------------------------
// UART and device settings/state machines 
//------------------------------------------------------------------------------
	wire [7:0] StoredDataOut;	//data from ADC fifos

	wire [7:0] txData;
	wire [7:0] Cmd;
	wire adcDataRead, DataReadyToSend;
	
	RxDWrapper RxD (
		 .Clock(clk), 
		 .ClearData(1'b0), 
		 .SDI(USB_RS232_RXD), 
		 .CurrentData(Cmd), 
		 .DataAvailable(NewCmd)
		 );
		 
	TxDWrapper TxD (
		 .Clock(clk), 
		 .Reset(1'b0), 
		 .ADCData(StoredDataOut), 
		 .generalData(txData), 
		 .generalDataWrite(txDataWr), 
		 .adcDataStreamingMode(DataReadyToSend),  //input equal to adc fifo not empty
		 .adcDataValid(DataReadyToSend), 			//input to UART Start signal
		 .adcDataStrobe(adcDataRead),					//output to adc FIFO 
		 .SDO(USB_RS232_TXD)
		 );

//Main FSM for handling UART I/O
Main_FSM SystemFSM (
    .clk(clk), 
    .Cmd(Cmd), 
    .NewCmd(NewCmd), 
	 .adcState(adcState),
	 .fifoState(2'b00),
	 .adcClockLock(AdcClkValid),
    .echoChar(echoChar), 
    .echoOn(echoOn), 
    .echoOff(echoOff), 
    .adcPwrOn(adcPwrOn), 
    .adcPwrOff(adcPwrOff), 
    .adcSleep(adcSleep), 
    .adcEnDes(adcEnDes), 
    .adcDisDes(adcDisDes), 
    .recordData(recordData), 
    .triggerOn(triggerOn), 
    .triggerOff(triggerOff), 
    .triggerReset(triggerReset), 
    .setTriggerV(setTriggerV), 
    .setTriggerV_1(setTriggerV_1), 
    .setTriggerV_0(setTriggerV_0), 
    .adcWake(adcWake), 
    .adcRunCal(adcRunCal), 
    .resetTrigV(resetTrigV),
	 .enAutoTrigReset(enAutoTrigReset),
	 .disAutoTrigReset(disAutoTrigReset),
	 .resetDCM(resetDCM),
    .txData(txData), 
    .txDataWr(txDataWr),
	 .selfTriggerValue(selfTriggerValue),
	 .enSelfTrigger(enSelfTrigger),
	 .disSelfTrigger(disSelfTrigger),
	 .storageAmount(eventsToAdd)
    );


//Control whether to echo received characters or not
SystemSetting EchoSetting (
    .clk(clk), 
    .turnOn(echoOn), 
    .turnOff(echoOff), 
    .toggle(1'b0), 
    .out(echoChar)
    );

wire triggerArmed, autoTriggerReset;
SystemSetting TriggerArmSetting (
    .clk(clk), 
    .turnOn(triggerOn),
    .turnOff(triggerOff ), 
    .toggle(1'b0), 
    .out(triggerArmed)
    );
	 
SystemSetting TriggerAutoResetSetting (
    .clk(clk), 
    .turnOn(enAutoTrigReset), 
    .turnOff(disAutoTrigReset), 
    .toggle(1'b0), 
    .out(autoTriggerReset)
    );

//------------------------------------------------------------------------------
// Trigger
//------------------------------------------------------------------------------
TriggerControl TriggerModule (
    .clk(AdcClk), 
    .t_p(DATA_TRIGGER_P), 
    .t_n(DATA_TRIGGER_N), 
    .armed(triggerArmed), 
    .module_reset(~AdcClkValid), 
    .manual_reset(triggerReset), 
    .auto_reset(autoTriggerReset), 
    .manual_trigger(recordData), 
    .triggered_out(triggered), 
    .comp_reset_high(TRIGGER_RST_P), 
    .comp_reset_low(TRIGGER_RST_N)
    );

//------------------------------------------------------------------------------
// I2C Communication and Devices
//------------------------------------------------------------------------------
wire [6:0] I2Caddr;
wire [15:0] I2Cdata;
wire I2Cbytes, I2Cr_w, I2C_load, I2CBusy, I2CDataReady;

DACControlFSM DAC (
    .clk(clk),
    .setV(setTriggerV), 
    .setV_1(setTriggerV_1), 
    .setV_0(setTriggerV_0), 
    .resetTrigV(resetTrigV),
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
wire OutToADCEnable; 
assign OutToADCEnable = (PWR_INT == 1'b1) & (ADC_PWR_EN == 1'b1);

ADC_FSM ADC_fsm (
    .Clock(clk), 
    .Reset(1'b0), 
    .OutToADCEnable(OutToADCEnable), 
    .adcPwrOn(adcPwrOn), 
    .adcPwrOff(adcPwrOff), 
    .adcSleep(adcSleep), 
    .adcWake(adcWake), 
    .adcRunCal(adcRunCal), 
    .adcEnDes(adcEnDes), 
    .adcDisDes(adcDisDes),
	 .ADCClockLocked(AdcClkValid),
    .ADCPower(ADC_PWR_EN), 
    .AnalogPower(ANALOG_PWR_EN), 
    .OutSclk(ADC_SCLK), 
    .OutSdata(ADC_SDATA), 
    .OutSelect(ADC_SCS), 
    .OutPD(ADC_PD), 
    .OutPDQ(ADC_PDQ), 
    .OutCal(ADC_CAL), 
    .InCalRunning(ADC_CALRUN), 
	 .OutDCMReset(OutDCMReset),
    .State(adcState)
    );

//------------------------------------------------------------------------------
// Clocks
//------------------------------------------------------------------------------
ClockBuffer Clock100MhzDCM
   (// Clock in ports
    .CLK_IN1(CLK_100MHZ),      // IN
    // Clock out ports
    .CLK_OUT1(clk));    // OUT

FastClockInput ADC_clock_module (
    .clk_pin_p(ADC_CLK_P), 
    .clk_pin_n(ADC_CLK_N), 
    .sys_clk(clk), 
    .clk_out(AdcClk), 
    .clk_valid(AdcClkValid)
    );

/**------------------------------------------------------------------------------
 ADC Data Input Registers
------------------------------------------------------------------------------**/
wire [31:0] ADCRegDataOut;		//DQD, DQ, DID, DI
ADCDataInput ADC_Data_Capture (
    .DataInP(ADC_DATA_P), 
    .DataInN(ADC_DATA_N), 
    .ClockIn(AdcClk), 
    .ClockInDelayed(AdcClk), 
    .DataOut(ADCRegDataOut)
    );

//------------------------------------------------------------------------------
// Data FIFOs with accumulation of triggered data
//------------------------------------------------------------------------------

//// Data is recorded either with the serial command "X", or a trigger event
//// and only when there is a lock on the ADC clock.
//// The triggered signal comes from the external trigger
DataStorageAcc DataFIFOS (
    .DataIn(ADCRegDataOut), 
    .DataOut(StoredDataOut), 
    .FastTrigger(triggered), 
    .ReadEnable(adcDataRead), 
    .WriteClock(AdcClk), 
    .ReadClock(clk), 
    .Reset(1'b0), 
    .DataReady(DataReadyToSend),
	 .numEvents(eventsToAdd[7:0])
    );

//------------------------------------------------------------------------------
// GPIO - The LEDs are inverted - so 0 is on, 1 is off
//------------------------------------------------------------------------------

//Code to make LED turn on for at least 100ms when AdcClkValid goes off
reg [23:0] countdelay = 0;
always@(posedge clk) begin
	if(~AdcClkValid)
		countdelay <= 24'b0;
	else if(~countdelay[23])
		countdelay <= countdelay + 1;	
end

assign GPIO[1] = 1'b0; 
assign GPIO[0] = countdelay[23];					//red
assign GPIO[2] = ~triggerArmed; 					//green
assign GPIO[3] = ~autoTriggerReset;				//blue

endmodule