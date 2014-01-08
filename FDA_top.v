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
wire OutToADCEnable, ADCSleep, ADCWake; 
assign OutToADCEnable = (PWR_INT == 1 && ADC_PWR_EN == 1);

ADC_FSM ADC_controller (
    .Clock(clk), 
    .Reset(1'b0), 
    .Cmd(DataRxD), 
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
    .InCalRunning(ADC_CALRUN)
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

//------------------------------------------------------------------------------
// ADC Data Input 
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
wire FifoRst = 1'b0;
wire FifoReadEn, FifoWriteEn;
wire SideFull, TopFull, BottomFull; 
wire SideEmpty, TopEmpty, BottomEmpty;
wire SideValid, TopValid, BottomValid;
wire [31:0] FifoDataOut;	//This data is in chronological order: [31:25] is DQD (oldest), 
									// [24:16] is DID, [8:15] is DQ, [7:0] is DI 

FIFO_11bit FIFO_Side_Inputs (
  .rst(FifoRst), // input rst
  .wr_clk(ADCClock), // input wr_clk
  .rd_clk(clk), // input rd_clk
  .din({ADCRegDataOut[31:26], ADCRegDataOut[15:11]}), // input [10 : 0] din
  .wr_en(FifoWriteEn), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout({FifoDataOut[7:2], FifoDataOut[15:11]}), // output [10 : 0] dout
  .full(SideFull), // output full
  .empty(SideEmpty), // output empty
  .valid(SideValid) // output valid
);

FIFO_11bit FIFO_Bottom_Inputs (
  .rst(FifoRst), // input rst
  .wr_clk(ADCClockDelayed), // input wr_clk
  .rd_clk(clk), // input rd_clk
  .din(ADCRegDataOut[10:0]), // input [10 : 0] din
  .wr_en(FifoWriteEn), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout({FifoDataOut[10:8], FifoDataOut [31:24]}), // output [10 : 0] dout
  .full(BottomFull), // output full
  .empty(BottomEmpty), // output empty
  .valid(BottomValid) // output valid
);

FIFO_10bit FIFO_Top_Inputs (
  .rst(FifoRst), // input rst
  .wr_clk(ADCClockDelayed), // input wr_clk
  .rd_clk(clk), // input rd_clk
  .din(ADCRegDataOut[25:16]), // input [9 : 0] din
  .wr_en(FifoWriteEn), // input wr_en
  .rd_en(FifoReadEn), // input rd_en
  .dout({FifoDataOut[1:0], FifoDataOut[23:16]}), // output [9 : 0] dout
  .full(TopFull), // output full
  .empty(TopEmpty), // output empty
  .valid(TopValid) // output valid
);



endmodule
