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
  wire clk_enable;
  
  assign clk_enable = 1'b1;

  wire ClkADC2DCM, ADCClock, ADCClockDelayed, ADCClockOn;

//  DCM_SP DCM_SP_INST(
//    .CLKIN(CLK_100MHZ),
//    .CLKFB(clk),
//    .RST(1'b0),
//    .PSEN(1'b0),
//    .PSINCDEC(1'b0),
//    .PSCLK(1'b0),
//    .DSSEN(1'b0),
//    .CLK0(clknub),
//    .CLK90(),
//    .CLK180(),
//    .CLK270(),
//    .CLKDV(),
//    .CLK2X(),
//    .CLK2X180(),
//    .CLKFX(),
//    .CLKFX180(),
//    .STATUS(),
//    .LOCKED(),
//    .PSDONE());
//  defparam DCM_SP_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
//  defparam DCM_SP_INST.CLKIN_PERIOD = 10.000;
//
//  BUFGCE  BG (.O(clk), .CE(clk_enable), .I(clknub));
  
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
wire [1:0] fifoState;
wire [7:0] selfTriggerValue;

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
	 .disSelfTrigger(disSelfTrigger)
    );


//Control whether to echo received characters or not
SystemSetting EchoSetting (
    .clk(clk), 
    .turnOn(echoOn), 
    .turnOff(echoOff), 
    .toggle(1'b0), 
    .out(echoChar)
    );

wire selfTriggerMode;
SystemSetting SelfTriggerSetting (
    .clk(clk), 
    .turnOn(enSelfTrigger), 
    .turnOff(disSelfTrigger), 
    .toggle(1'b0), 
    .out(selfTriggerMode)
    );
	 	
wire selfTriggerWaitToRecord;		
SystemSetting SelfTriggerWaitingToRecord (
    .clk(clk), 
    .turnOn(recordData & selfTriggerMode), 
    .turnOff(selfTriggerRecord), 
    .toggle(1'b0), 
    .out(selfTriggerWaitToRecord)
    );

wire triggerArmed;
SystemSetting TriggerArmSetting (
    .clk(clk), 
    .turnOn(triggerOn), 
    .turnOff(triggerOff), 
    .toggle(1'b0), 
    .out(triggerArmed)
    );
	 
wire autoTriggerReset;
SystemSetting TriggerAutoResetSetting (
    .clk(clk), 
    .turnOn(enAutoTrigReset), 
    .turnOff(disAutoTrigReset), 
    .toggle(1'b0), 
    .out(autoTriggerReset)
    );
	 
wire Red, Green, Blue;

//------------------------------------------------------------------------------
// Trigger
//------------------------------------------------------------------------------
wire triggered;
reg [3:0] fifoStateChange = 4'b0;
wire allowArmed, t_reset;
assign allowArmed = (fifoStateChange == 4'b0);
assign t_reset = autoTriggerReset & (fifoStateChange == 4'b1000);	//if auto trigger reset is enabled, reset when the fifo
																						//state changes from Sending Data to Ready

always@(posedge clk) begin
	fifoStateChange[3:0] <= {fifoStateChange[1:0], fifoState[1:0]};
end

TriggerControl TriggerController (
    .clk(clk), 
    .t_p(DATA_TRIGGER_P), 
    .t_n(DATA_TRIGGER_N), 
    .armed(triggerArmed & allowArmed),	//trigger is de-armed when storing or sending data				 
    .t_reset(triggerReset | t_reset),		//reset the trigger manually or automatically
    .triggered(triggered), 	
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
wire NewClockDetect;

assign ADCClockOn = ((InputClockCheck[7:5] != 3'b111) &  (InputClockCheck[7:5] != 3'b000) & 
									(InputClockCheck[2:0] != 3'b111) &  (InputClockCheck[2:0] != 3'b000)); 

assign NewClockDetect = (ClockDetect == 2'b01);

always@(posedge ClkADC2DCM) begin
	InputClockCounter <= InputClockCounter + 1;
end

always@(posedge clk) begin
	InputClockCheck <= {InputClockCheck[6:0], InputClockCounter[2]};	//InputClockCounter[2] changes at 62mhz
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

assign DITrigger = (ADCRegDataOut[7:0] < selfTriggerValue);
assign DIDTrigger = (ADCRegDataOut[15:8] < selfTriggerValue);
assign DQTrigger = (ADCRegDataOut[23:16] < selfTriggerValue);
assign DQDTrigger = (ADCRegDataOut[31:24] < selfTriggerValue);

assign selfTriggerRecord = DITrigger | DIDTrigger | DQTrigger | DQDTrigger;

//------------------------------------------------------------------------------
// Data FIFOs 
//------------------------------------------------------------------------------
wire FifoNotFull;
wire fifoRecord;

// Data is recorded either with the serial command "X", or a trigger event
// and only when there is a lock on the ADC clock
assign fifoRecord =  (selfTriggerMode) ? (selfTriggerRecord & selfTriggerWaitToRecord) : recordData;// ADCClockOn &  | triggered);

//Test debugging code
reg [7:0] DI = 8'b0;
reg [7:0] DId = 8'b0;
reg [7:0] DQ = 8'b0;
reg [7:0] DQd = 8'b0;

//async reset
/**
always @(posedge ClkADC2DCM or posedge fifoRecord) begin
	//DI[0] <= ClkADC2DCM;
	if(fifoRecord) begin
		DI 	<= 8'd0;
		DId 	<= 8'd0;
		DQ 	<= 8'd0;
		DQd 	<= 8'd0;
	end 
	else begin
		DI 	<= DI + 1;
		DId 	<= DId + 1;
		DQ 	<= DQ + 1;
		DQd 	<= DQd + 1;
	end
end
**/

reg [11:0] ProgFullThresh = 12'd256;

DataStorage Fifos (
    .DataIn(ADCRegDataOut), //ADCRegDataOut),
    .DataOut(StoredDataOut), 
    .WriteStrobe(fifoRecord),
    .ReadEnable(adcDataRead), 
    .WriteClock(ClkADC2DCM), //ClkADC2DCM
    .WriteClockDelayed(ClkADC2DCM), //ADCClockDelayed
    .ReadClock(clk), 
    .Reset(1'b0),//~ADCClockOn), 
    .DataValid(DataValid), 
    .DataReadyToSend(DataReadyToSend),
	 .State(fifoState),
	 .ProgFullThresh(ProgFullThresh)
    );

//output test clock
//wire outputTestClk;
//   ODDR2 #(

//      .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
//      .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
//      .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
//   ) clock_forward_inst (
//      .Q(outputTestClk),     // 1-bit DDR output data
//      .C0(ADCClockOn),  // 1-bit clock input
//      .C1(~ADCClockOn), // 1-bit clock input
//      .CE(1'b1),      // 1-bit clock enable input
//      .D0(1'b0), // 1-bit data input (associated with C0)
//      .D1(1'b1), // 1-bit data input (associated with C1)
//      .R(1'b0),   // 1-bit reset input
//      .S(1'b0)   // 1-bit set input
//   );



//------------------------------------------------------------------------------
// GPIO - The LEDs are inverted - so 0 is on, 1 is off
//------------------------------------------------------------------------------
assign GPIO[1] = (fifoState[0]);  //ClkADC2DCM; fifoRecord | DataReadyToSend | 
assign GPIO[0] = ADCClockOn;		//red
assign GPIO[2] = ~selfTriggerMode; 			//green
assign GPIO[3] = DITrigger;			//blue

endmodule