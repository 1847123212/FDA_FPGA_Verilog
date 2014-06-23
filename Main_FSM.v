`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:30:38 02/27/2014 
// Design Name: 
// Module Name:    Main_FSM 
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
module Main_FSM(
	 input clk,
	 
	 //state machine inputs
    input [7:0] Cmd,
    input NewCmd,
	 input echoChar,
	 input [3:0] adcState,
	 input [1:0] fifoState,
	 input adcClockLock,
	 
	 //output FSM control signals
	 output echoOn,
	 output echoOff,
	 output adcPwrOn,
	 output adcPwrOff,
	 output adcSleep,
	 output adcEnDes,
	 output adcDisDes,
	 output recordData,
	 output triggerOn,
	 output triggerOff,
	 output triggerReset,
	 output setTriggerV,
	 output setTriggerV_1,
	 output setTriggerV_0,
	 output adcWake,
	 output adcRunCal,
	 output resetTrigV,
	 output enAutoTrigReset,
	 output disAutoTrigReset,
	 output resetDCM,
	 output reg [7:0] selfTriggerValue,
	 output enSelfTrigger,
	 output disSelfTrigger,
	 
	 //uart output
	 output reg [7:0] txData,
	 output reg txDataWr
    );
	 
	reg [5:0] State = 0;
	reg [5:0] NextState = 0;
	 
	reg [3:0] trigVoltageCounter = 0;
	
	reg [3:0] selfTriggerCounter = 0;
	
	localparam IDLE = 0,
					ECHO_ON = 1,
					ECHO_OFF = 2,
					ADC_PWR_ON = 3,
					ADC_PWR_OFF = 4,
					ADC_SLEEP = 5,	
					TRIGGER_ON = 6,
					TRIGGER_OFF = 7,
					SET_TRIGGER_VOLTAGE = 8,
					SET_TV_0 = 9,
					SET_TV_1 = 10,
					ADC_WAKE = 11,
					ERROR_IN1 = 12,
					ADC_RUN_CAL = 13,
					ADC_ENABLE_DES = 14,
					ADC_DISABLE_DES = 15,
					TRIGGER_RESET = 16, 
					COMMAND_ACK = 17,
					RECORD_DATA = 18,
					ERROR_IN2 = 19, 
					RETURN_ADC_1 = 20,
					RETURN_ADC_2 = 21,
					FIFO_STATE1 = 22,
					FIFO_STATE2 = 23, 
					ENABLE_AUTO_TRIG_RESET = 24,
					DISABLE_AUTO_TRIG_RESET = 25,
					RESET_DCM1 = 26,
					RESET_DCM2 = 27,
					RETURN_CLOCK_LOCK1 = 28,
					RETURN_CLOCK_LOCK2 = 29, 
					SET_SELF_TRIGGER = 30,
					SET_SV_0 = 31,
					SET_SV_1 = 32, 
					ENABLE_SELF_TRIGGER = 33,
					DISABLE_SELF_TRIGGER = 34;
	 
	//Logic for FSM outputs 
	assign echoOn = (State == ECHO_ON);
	assign echoOff = (State == ECHO_OFF);
	assign adcPwrOn = (State == ADC_PWR_ON);
	assign adcPwrOff = (State == ADC_PWR_OFF);
	assign adcSleep = (State == ADC_SLEEP);
	assign triggerOn = (State == TRIGGER_ON);
	assign triggerOff = (State == TRIGGER_OFF);
	assign setTriggerV = (State == SET_TRIGGER_VOLTAGE);
	assign setTriggerV_1 = (State == SET_TV_1);
	assign setTriggerV_0 = (State == SET_TV_0);
	assign adcWake = (State == ADC_WAKE);
	assign adcRunCal = (State == ADC_RUN_CAL);
	assign resetTrigV = (State == ERROR_IN1);
	assign adcEnDes = (State == ADC_ENABLE_DES);
	assign adcDisDes = (State == ADC_DISABLE_DES);
	assign triggerReset = (State == TRIGGER_RESET);
	assign recordData = (State == RECORD_DATA);
	assign enAutoTrigReset = (State == ENABLE_AUTO_TRIG_RESET);
	assign disAutoTrigReset = (State == DISABLE_AUTO_TRIG_RESET);
	assign resetDCM = (State == RESET_DCM1 || State == RESET_DCM2);
	assign enSelfTrigger = (State == ENABLE_SELF_TRIGGER);
	assign disSelfTrigger = (State == DISABLE_SELF_TRIGGER);
	
	
	always@(posedge clk) begin
		if(NewCmd && Cmd == "R")	//ability to reset state with R command
			State <= IDLE;
		else
			State <= NextState;
	 end
	 
	 //Logic for UART output
	 always@(posedge clk) begin
		//Echo the received command when Echo is on
		if(echoChar && NewCmd) begin
			txData <= Cmd;
			txDataWr <= 1'b1;
		end
		//Send ACK character
		else if(State == COMMAND_ACK)begin
			txData <= "*";
			txDataWr <= 1'b1;
		end
		//Send an error character
		else if(State == ERROR_IN2)begin
			txData <= "!";
			txDataWr <= 1'b1;
		end
		//Send the State of the ADC FSM
		else if (State == RETURN_ADC_2)begin
			txData <= adcState + 8'd48;
			txDataWr <= 1'b1;
		end
		//Send the State of the FIFO FSM
		else if (State == FIFO_STATE2)begin
			txData <= fifoState + 8'd48;
			txDataWr <= 1'b1;
		end
		//send the status of adc clock lock
		else if (State == RETURN_CLOCK_LOCK2) begin
			txData <= adcClockLock + 8'd48;
			txDataWr <= 1'b1;
		end
		//Deassert the Tx Write signal
		else begin
			txData <= 8'b0;
			txDataWr <= 1'b0;
		end
	 end
	 
	 //Count the number of bits received for setting the trigger DAC voltage
	 always@(posedge clk) begin
		if(State == IDLE)
			trigVoltageCounter <= 4'b0;
		else if(State == SET_TRIGGER_VOLTAGE && NewCmd)
			trigVoltageCounter <= trigVoltageCounter + 1; 
	 end
	
	 //Count the number of bits recieved for setting the self trigger level	 
	 always@(posedge clk) begin
		if(State == IDLE)
			selfTriggerCounter <= 3'b0;
		else if(State == SET_SELF_TRIGGER & NewCmd) begin
			selfTriggerCounter <= selfTriggerCounter + 1;
			if(Cmd == "0")
				selfTriggerValue <= {selfTriggerValue[6:0], 1'b0};
			else if(Cmd == "1")
				selfTriggerValue <= {selfTriggerValue[6:0], 1'b1};
		end
	 end
	
	 always@(*) begin
		NextState = State;
		case (State)
			IDLE: begin
				if(NewCmd)
					case (Cmd)
						"A": NextState = RETURN_ADC_1;
						"B": NextState = ENABLE_AUTO_TRIG_RESET;
						"b": NextState = DISABLE_AUTO_TRIG_RESET;						
						"D": NextState = ADC_ENABLE_DES;
						"d": NextState = ADC_DISABLE_DES;
						"C": NextState = ADC_RUN_CAL;
						"E": NextState = ECHO_ON;
						"e": NextState = ECHO_OFF;
						"F": NextState = FIFO_STATE1;
						"O": NextState = ADC_PWR_ON;
						"o": NextState = ADC_PWR_OFF;
						"L": NextState = RETURN_CLOCK_LOCK1;
						//"R": global reset of this FSM
						"r": NextState = RESET_DCM1;
						"S": NextState = ADC_SLEEP;
						"T": NextState = TRIGGER_ON;
						"t": NextState = TRIGGER_OFF;
						"U": NextState = TRIGGER_RESET;	//manually reset the trigger
						"V": NextState = SET_TRIGGER_VOLTAGE;
						"W": NextState = ADC_WAKE;	
						"X": NextState = RECORD_DATA;
						"Y": NextState = SET_SELF_TRIGGER;
						"Z": NextState = ENABLE_SELF_TRIGGER;
						"z": NextState = DISABLE_SELF_TRIGGER;
					endcase
			end
			ADC_RUN_CAL: NextState = COMMAND_ACK;
			ADC_ENABLE_DES: NextState = COMMAND_ACK;
			ADC_DISABLE_DES: NextState = COMMAND_ACK;
			ECHO_ON: NextState = COMMAND_ACK;
			ECHO_OFF: NextState = COMMAND_ACK;
			ADC_PWR_ON: NextState = COMMAND_ACK;
			ADC_PWR_OFF: NextState = COMMAND_ACK;
			ADC_SLEEP: NextState = COMMAND_ACK;	
			TRIGGER_ON: NextState = COMMAND_ACK;
			TRIGGER_OFF: NextState = COMMAND_ACK;
			TRIGGER_RESET: NextState = COMMAND_ACK;
			SET_TRIGGER_VOLTAGE: begin
				if(trigVoltageCounter == 4'd10)
					NextState = COMMAND_ACK;
				else if(NewCmd)
					if(Cmd == "0")
						NextState = SET_TV_0;
					else if(Cmd == "1")
						NextState = SET_TV_1;
					else
						NextState = ERROR_IN1;
			end
			SET_TV_0: NextState = SET_TRIGGER_VOLTAGE;
			SET_TV_1: NextState = SET_TRIGGER_VOLTAGE;
			SET_SELF_TRIGGER: begin
				if(selfTriggerCounter == 4'd8)
					NextState = COMMAND_ACK;
			end
			ENABLE_SELF_TRIGGER: NextState = COMMAND_ACK;
			DISABLE_SELF_TRIGGER: NextState = COMMAND_ACK;
			ADC_WAKE: NextState = COMMAND_ACK;
			ADC_RUN_CAL: NextState = COMMAND_ACK;
			RECORD_DATA: NextState = COMMAND_ACK;
			RETURN_ADC_1: NextState = RETURN_ADC_2;
			RETURN_ADC_2: NextState = IDLE;
			FIFO_STATE1: NextState = FIFO_STATE2;
			FIFO_STATE2: NextState = IDLE;
			ENABLE_AUTO_TRIG_RESET: NextState = COMMAND_ACK;
			DISABLE_AUTO_TRIG_RESET: NextState = COMMAND_ACK;
			RESET_DCM1: NextState = RESET_DCM2;
			RESET_DCM2: NextState = IDLE;
			RETURN_CLOCK_LOCK1: NextState = RETURN_CLOCK_LOCK2;
			RETURN_CLOCK_LOCK2: NextState = IDLE;
			ERROR_IN1: NextState = ERROR_IN2;
			ERROR_IN2: NextState = IDLE;						//Need two error states, because the FSM is transmitting hte received character during the first one
			COMMAND_ACK: NextState = IDLE;
		endcase 
	 end
endmodule
