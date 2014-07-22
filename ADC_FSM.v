`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:08:42 01/06/2014 
// Design Name: 
// Module Name:    ADC_FSM 
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
module ADC_FSM(
    input Clock,
    input Reset,
	 input OutToADCEnable,	//master control line to ensure proper power sequencing
	 input adcPwrOn,	//control signal from FSM
	 input adcPwrOff,	//control signal from FSM
	 input adcSleep,	//control signal from FSM
	 input adcWake,	//control signal from FSM
	 input adcRunCal,	//control signal from FSM
	 input adcEnDes,
	 input adcDisDes,
	 
	 input ADCClockLocked, //logic high when the FPGA has locked onto clock signal
	 
    output ADCPower,
	 output AnalogPower,
	 
	 //the hardware pins for ADC serial communication
    output OutSclk, 
    output OutSdata, 
    output OutSelect,
	 
	 output OutPD,
	 output OutPDQ,
	 output OutCal,
	 input InCalRunning,
	 
	 output [3:0] State,
	 output OutDCMReset
    );

	localparam 	ALL_PWR_OFF = 4'd0,
					ADC_PWR_WARMUP = 4'd1,
					ANALOG_PWR_WARMUP = 4'd2,
					CLOCK_LOCK = 4'd14,
					CLOCK_WAIT = 4'd15,
					INIT_REG_WRITE = 4'd3,
					INIT_ADC_WARMUP = 4'd4,
					CALIBRATION_REQUEST = 4'd5,
					CALIBRATION = 4'd6,
					ENABLE_DES = 4'd7,
					DES_SAMPLING = 4'd8,
					DIS_DES_FOR_LOW_PWR_IDLE = 4'd9,
					LOW_PWR_IDLE = 4'd10,
					ADC_WAKEUP = 4'd11,
					DIS_DES_FOR_CAL = 4'd12 ,
					PERIPH_PWR_SHUTDOWN = 4'd13;

`ifdef XILINX_ISIM
	//This is to avoid the long warm up period 
	reg [3:0] CurrentState = INIT_ADC_WARMUP;
	reg [3:0] NextState = INIT_ADC_WARMUP;
`else
	reg [3:0] CurrentState = ALL_PWR_OFF;
	reg [3:0] NextState = ALL_PWR_OFF;
`endif
	
	assign State = CurrentState;
	
	wire TimerEnable, TimerClear;
	wire [26:0] TimerOut;
	
	wire StartInit, StartDESEnable, StartDESDisable, RegWriteDone;
	wire Sclk, Sdata, Select; 
	
	//Prevent voltage on pins when ADC is not powered or is powering down
	assign OutSclk = (OutToADCEnable) ? Sclk : 1'bz;
	assign OutSdata = (OutToADCEnable) ? Sdata : 1'bz;
	assign OutSelect = (OutToADCEnable) ? Select : 1'bz;
	
	//OutPD 
	//Trying with always low - need to change to be able to put in low power mode
	assign OutPD = ((~OutToADCEnable) | (CurrentState == ALL_PWR_OFF | CurrentState == LOW_PWR_IDLE 
							| CurrentState == ADC_PWR_WARMUP | CurrentState == ANALOG_PWR_WARMUP)) ? 1'bz : 1'b0;
	
	assign OutPDQ = 1'b0;	//PDQ is always low for now
	assign OutCal = (OutToADCEnable & (CurrentState != CALIBRATION_REQUEST)) ? 1'b0 : 1'bz;
	
	assign ADCPower = (CurrentState != ALL_PWR_OFF);
	assign AnalogPower = (OutToADCEnable) ? 
				((CurrentState !=  ALL_PWR_OFF) && (CurrentState != ADC_PWR_WARMUP) && (CurrentState != PERIPH_PWR_SHUTDOWN)) : 1'b0;
	
	assign TimerEnable = (CurrentState == ADC_PWR_WARMUP || 
									CurrentState == ANALOG_PWR_WARMUP ||
									CurrentState == INIT_ADC_WARMUP ||
									CurrentState == PERIPH_PWR_SHUTDOWN ||
									CurrentState == ADC_WAKEUP ||
									CurrentState == CLOCK_WAIT);
	assign TimerClear = ~TimerEnable;
	assign StartInit = (CurrentState == INIT_REG_WRITE);
	assign StartDESEnable = (CurrentState == ENABLE_DES);
	assign StartDESDisable = ((CurrentState == DIS_DES_FOR_LOW_PWR_IDLE) || 
											(CurrentState == DIS_DES_FOR_CAL));
	assign OutDCMReset = (CurrentState == ALL_PWR_OFF || CurrentState == ADC_PWR_WARMUP || CurrentState == ANALOG_PWR_WARMUP);
	
	//------------------------------------------
	//Conditional State Transition
	//------------------------------------------
	always@(*) begin
		NextState = CurrentState;
		case (CurrentState)
			ALL_PWR_OFF: if(adcPwrOn) NextState = ADC_PWR_WARMUP;
			ADC_PWR_WARMUP: if(TimerOut[20]) NextState = ANALOG_PWR_WARMUP;	//delay the turn on of the peripheral power
			ANALOG_PWR_WARMUP: if(TimerOut[26]) NextState = CLOCK_LOCK; //Clock can take 10ms to stabilize
			CLOCK_LOCK: if(ADCClockLocked) NextState = CLOCK_WAIT;
			CLOCK_WAIT: if(TimerOut[26]) NextState = INIT_REG_WRITE;	//wait once the clock is locked
			INIT_REG_WRITE: if (RegWriteDone) NextState = INIT_ADC_WARMUP;
			INIT_ADC_WARMUP: if(TimerOut[7]) NextState = CALIBRATION_REQUEST;	//take out of PD mode and wait ~500ns - automatically do calibration after power on
			CALIBRATION_REQUEST: if(InCalRunning) NextState = CALIBRATION;
			CALIBRATION: if(~InCalRunning) NextState = ENABLE_DES; //&& adcEnDes
			ENABLE_DES: if(RegWriteDone) NextState = DES_SAMPLING;
			DES_SAMPLING: begin
				if(adcPwrOff || ~OutToADCEnable) NextState = PERIPH_PWR_SHUTDOWN;
				else if (adcSleep) NextState = DIS_DES_FOR_LOW_PWR_IDLE;
				else if (adcRunCal) NextState = DIS_DES_FOR_CAL;
			end
			DIS_DES_FOR_LOW_PWR_IDLE: if(RegWriteDone) NextState = LOW_PWR_IDLE;
			LOW_PWR_IDLE: begin
				if(adcPwrOff || ~OutToADCEnable) NextState = PERIPH_PWR_SHUTDOWN;
				else if(adcWake) NextState = ADC_WAKEUP;
			end
			ADC_WAKEUP: if(TimerOut[7]) NextState = ENABLE_DES; 	//~500ns
			DIS_DES_FOR_CAL: if(RegWriteDone) NextState = CALIBRATION_REQUEST;
			PERIPH_PWR_SHUTDOWN: if(TimerOut[8]) NextState = ALL_PWR_OFF; //slightly delay the turn off of the ADC power
		endcase
	end

	//--------------------------------------------
	//Synchronous State Transition
	//--------------------------------------------
	always@(posedge Clock) begin
		if(Reset) CurrentState <= ALL_PWR_OFF;
		else CurrentState <= NextState;
	end

	//Counter used for timing
	Counter24Bit_Up timer (
	  .clk(Clock), // input clk
	  .ce(TimerEnable), // input ce
	  .sclr(TimerClear), // input sclr
	  .q(TimerOut) // output [27 : 0] q
	);

	//Module to generate serial output for the ADC
	ADCExtendedControl ADC_Serial_Comm (
		 .clk(Clock), 
		 .init(StartInit), 
		 .des_enable(StartDESEnable), 
		 .des_disable(StartDESDisable), 
		 .sclk(Sclk), 
		 .sdata(Sdata), 
		 .select(Select), 
		 .done(RegWriteDone)
		 );

endmodule
