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
	
`ifdef XILINX_ISIM
	input [7:0] DataRxD,
`endif	
	
	//GPIO
	output [3:0] GPIO				// 0, 2, and 3 connected to LEDs
   );

  wire clk;
  wire clknub;

  wire ClkADC2DCM, ADCClock, ADCClockDelayed, ADCClockOn;

  wire Red, Green, Blue;
  
//------------------------------------------------------------------------------
// UART and device settings/state machines 
//------------------------------------------------------------------------------
wire [7:0] StoredDataOut;

`ifndef XILINX_ISIM
	wire [7:0] DataRxD;
	wire [7:0] txData;
	wire [7:0] Cmd;
	wire DataAvailable, ClearData;
	wire OtherDataLatch;
	wire ArmTrigger, TriggerReset, EchoChar;
	wire FIFOTransmitBusy;
	wire adcDataRead, DataReadyToSend;
	
	assign ClearData = 1'b0;
	
	RxDWrapper RxD (
		 .Clock(clk), 
		 .ClearData(ClearData), 
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
		 .adcDataValid(DataValid), 					//input to UART Start signal
		 .adcDataStrobe(adcDataRead),					//output to adc FIFO 
		 .SDO(USB_RS232_TXD)
		 );
	
`endif

wire recordData, adcPwrOn;
wire [3:0] adcState;
wire [3:0] fifoState;
wire [7:0] selfTriggerValue;
wire [13:0] ProgFullThresh;

//Main FSM for handling UART I/O
Main_FSM SystemFSM (
    .clk(clk), 
    .Cmd(Cmd), 
    .NewCmd(NewCmd), 
	 .adcState(adcState),
	 .fifoState(fifoState),
	 .adcClockLock(ADCClockOn),
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
	 .storageAmount(ProgFullThresh)
    );


//Control whether to echo received characters or not
SystemSetting EchoSetting (
    .clk(clk), 
    .turnOn(echoOn), 
    .turnOff(echoOff), 
    .toggle(1'b0), 
    .out(echoChar)
    );

/**
wire selfTriggerMode;
SystemSetting SelfTriggerSetting (
    .clk(clk), 
    .turnOn(enSelfTrigger), 
    .turnOff(disSelfTrigger), 
    .toggle(1'b0), 
    .out(selfTriggerMode)
    );
**/

wire triggered;

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
wire [3:0] triggerState;

TriggerControl TriggerController (
    .clk(ClkADC2DCM),
    .t_p(DATA_TRIGGER_P),
    .t_n(DATA_TRIGGER_N),
    .armed(triggerArmed),						//trigger is de-armed when storing or sending data				 
    .module_reset(~ADCClockOn),
	 .manual_reset(triggerReset), 
    .auto_reset(autoTriggerReset), 
    .triggered(triggered),
    .comp_reset_high(TRIGGER_RST_P), 
    .comp_reset_low(TRIGGER_RST_N),
	 .state_w(triggerState)
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
	 .ADCClockLocked(ADCClockOn),
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
// ADC Data Clock
//------------------------------------------------------------------------------
// Create the ADC input clock buffer and send the signal to the DCM

wire ClkIO2Bufg;

IBUFGDS #(
      .DIFF_TERM("TRUE"), 		// Differential Termination
      .IOSTANDARD("LVDS_33") 	// Specifies the I/O standard for this buffer
   ) IBUFGDS_adcClock (
      .O(ClkIO2Bufg),  			// Clock buffer output
      .I(ADC_CLK_P),  			// Diff_p clock buffer input
      .IB(ADC_CLK_N) 			// Diff_n clock buffer input
   );
	
BUFG BUFG_adc_clk (
	.O(ClkADC2DCM), // 1-bit output: Clock buffer output
	.I(ClkIO2Bufg)  // 1-bit input: Clock buffer input
);	
	

wire testRESET, testLOCKED, clk250mhz;

ClockTest mainClk
   (// Clock in ports
    .CLK_IN1(CLK_100MHZ),      // IN
    // Clock out ports
    .CLK_OUT1(clk),     // OUT
    .CLK_OUT2(clk250mhz),     // OUT
    // Status and control signals
    .RESET(1'b0),// IN
    .LOCKED(testLOCKED));

reg [2:0] InputClockCounter = 3'b000;
reg [7:0] InputClockCheck = 8'b00000000;
reg [1:0] ClockDetect = 2'b00;
wire clk_check_100mhz;

assign ADCClockOn = ((InputClockCheck[7:5] != 3'b111) &  (InputClockCheck[7:5] != 3'b000) & 
									(InputClockCheck[2:0] != 3'b111) &  (InputClockCheck[2:0] != 3'b000)); 

always@(posedge ClkADC2DCM) begin
	InputClockCounter <= InputClockCounter + 1;
end

async_input_sync input_clk_counter_sync (
    .clk(clk), 
    .async_in(InputClockCounter[2]), //InputClockCounter[2] changes at 62mhz
    .sync_out(clk_check_100mhz)
    );

always@(posedge clk) begin
	InputClockCheck <= {InputClockCheck[6:0], clk_check_100mhz};
	ClockDetect <= {ClockDetect[0], ADCClockOn};
end


/**------------------------------------------------------------------------------
 ADC Data Input Registers
------------------------------------------------------------------------------**/
wire [31:0] ADCRegDataOut;		//DQD, DQ, DID, DI
ADCDataInput ADC_Data_Capture (
    .DataInP(ADC_DATA_P), 
    .DataInN(ADC_DATA_N), 
    .ClockIn(ClkADC2DCM), 
    .ClockInDelayed(ClkADC2DCM), 
    .DataOut(ADCRegDataOut)
    );

/**
assign DITrigger = (ADCRegDataOut[7:0] < selfTriggerValue);
assign DIDTrigger = (ADCRegDataOut[15:8] < selfTriggerValue);
assign DQTrigger = (ADCRegDataOut[23:16] < selfTriggerValue);
assign DQDTrigger = (ADCRegDataOut[31:24] < selfTriggerValue);

assign selfTriggerRecord = DITrigger | DIDTrigger | DQTrigger | DQDTrigger;
**/

//------------------------------------------------------------------------------
// Data FIFOs 
//------------------------------------------------------------------------------
wire FifoNotFull;
wire fifoRecord;
wire waitForTrigger, holdTrigger;

/**
SelfTriggerState selfTriggerState (
    .clk(ClkADC2DCM), 
    .selfTriggerMode(selfTriggerMode), 
    .recordDataCommand(recordData), 
    .triggered(selfTriggerRecord), 
    .waitForTrigger(waitForTrigger),
	 .holdTrigger(holdTrigger)
    );
**/

// Data is recorded either with the serial command "X", or a trigger event
// and only when there is a lock on the ADC clock.
// The triggered signal comes from the external trigger

DataStorage Fifos (
    .DataIn(ADCRegDataOut), //ADCRegDataOut),
    .DataOut(StoredDataOut), 
    .WriteStrobe(recordData),
	 .FastTrigger(triggered),
    .ReadEnable(adcDataRead), 
    .WriteClock(ClkADC2DCM), //ClkADC2DCM
    .ReadClock(clk), 
    .Reset(~ADCClockOn),
    .DataValid(DataValid), 
    .DataReadyToSend(DataReadyToSend),
	 .State(fifoState),
	 .ProgFullThresh(ProgFullThresh)
    );


//------------------------------------------------------------------------------
// GPIO - The LEDs are inverted - so 0 is on, 1 is off
//------------------------------------------------------------------------------

reg [23:0] countdelay = 0;

always@(posedge clk) begin
	if(~ADCClockOn)
		countdelay <= 24'b0;
	else if(~countdelay[23])
		countdelay <= countdelay + 1;
		
end

assign GPIO[1] = (fifoState[0]);  //ClkADC2DCM; fifoRecord | DataReadyToSend | 
assign GPIO[0] = countdelay[23];					//red
assign GPIO[2] = ~triggerArmed; 					//green
assign GPIO[3] = ~triggerState[2];						//blue

endmodule