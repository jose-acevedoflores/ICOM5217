#include <msp430.h>
#include <stdio.h>
#include <stdlib.h>
#include "Variables.h"
#include "Utils.h"
#include "Motor.h"
#include "LCD.h"
#include "UART.h"
#include "UVLed.h"
/*
 * main.c
 */



void stopPrintJob() {
	jobStatus = done_printing;
	deactivateMotor();
	turnUVOff();
	clearDisplay();
	lineWrite("   Done printing`", LINE_2);
	__bis_SR_register(LPM1);
}
void startPrintingProcess();
/*
 void main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

	// Stepper Motor Port setup
	P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
	P3OUT |= 0x01F;
	P2DIR |= (0x080);
	P2OUT |= (0x080);

	//Reed Switch Port setup
	P1DIR &= ~(BIT0);//Set P1.0 for reed switch interrupt and limit buttons
	P1IE |= BIT0; //Enable Port 1.0 interrupts
	P1IES |= BIT0; //Port 1.0 edge selector H -> L

	//Buzzer and LED Port setup
	P1DIR |= (BIT5+BIT6);//Set P1.5 and P1.6 for buzzer and LED outputs
	P1OUT &= ~(BIT5); //Turn off LED initially.

	//Limit sensor Port setup
	P1DIR &= ~(BIT1 + BIT2); // Set P1.1 and P1.2 as input
	//P1IES |= BIT1 + BIT2; //Port 1.1 and 1.2 edge selector H -> L
	P1IES |= BIT2;
	P1IES &= ~BIT1;
	P1IE  |= BIT1 + BIT2;// Enable interrupt on P1.1 and P1.2

	//Interface Buttons Port setup
	P1DIR &= ~(BIT4+BIT3);//Set P1.3 and P1.4 as inputs for interface buttons
	P1IE |= BIT3+BIT4; //Enable Port 1.3 and P1.4 interrupts.
	P1IES |= BIT3+BIT4; //Port 1.3 and 1.4 edge selector H -> L

	//LCD Port setup
	P5DIR |= 0x03;//Set Port 5.0, 5.1 as outputs for LCD
	P6DIR |= 0x0FF;//Set Port 6 as outputs for LCD Data

	//Timer A0 setup
	UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
	TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TA0CCR0 |= 0; //Store 0 in terminal count register.
	TA0CCTL0 |= CCIE; //Enable TA0 count 0 interrupts

	//Timer B0 setup
	TB0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TB0CCR0 = 32767; //Set terminal count to 32767 to know a second has passed

	//UV setup
	initLCr();

	status = 0;

	// For debug purposes only
	//resinDryTime = 600;
	currentTime = 0; // Initialize time variable

	initializeLCD();
	lineWrite("       Ready`", LINE_2);

//Testing
//		activateMotor();
//		resetMotorToTop();
//		deactivateMotor();
	activateMotor();
	//resetMotorToBottom();
	deactivateMotor();

	turnUVOn();

	initializeUART();

	P1IE = 0; //Testing purposes, turning off all interrupts from port 1

	__bis_SR_register(GIE );//+ LPM3); //Enable global interrupts.

	while (1) {
			if (jobStatus == printing && checkIfDoPrintStep) {

				if (jobStatus == printing && currentLayer != 0 && currentLayer == layerQuantity) {
					stopPrintJob();
				}

				if ((jobStatus == printing) && (currentTime % resinDryTime == 0)) {
					int steps = 126; //1.0mm
					resinDryTime = 1200;
					if (layerThickness == 1) { //0.5mm

						steps = 63;
						resinDryTime = 60;
					}
					if (layerThickness == 3) { //1.5mm
						steps = 189;
						resinDryTime = 1800;
					}
					currentLayer++;

					__disable_interrupt();

					clearDisplay();
					status = (status + 1) % 4;
					updateDisplayStatus(status);

					turnUVOff();

					activateMotor();
					motorStep(steps, UP);
					deactivateMotor();

					// Added code
					/*P2OUT |= (BIT1); // Trigger P2.1
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					wait(10000);
					P2OUT &= ~(BIT1);

					turnUVOn();

					TB0CCTL0 &= ~(0x01);
					__enable_interrupt();
					checkIfDoPrintStep = false;
				}
			}

			if (doPrintSetup) {
				layerQuantity = atoi(numberOfLayers);
				resinDryTime = 10;
				//resinDryTime = 1200;

				if (thickness == "1.5`") {
					layerThickness = 3;

				}
				else if (thickness == "1.0`") {
					layerThickness = 2;

				}
				else if (thickness == "0.5`") {
					layerThickness = 1;

				}

				totalTime = resinDryTime * layerQuantity; // Calculate total estimated time
				startTime = currentTime; // Set startTime
				receivedIndex = 0;

				microSteppingMode(FULLSTEP);
				activateMotor();		// Turn on motor
				jobStatus = printing;	// Set printer status to printing
				UCA1IE &= UCRXIE;		// Deactivate UART interrupts
				doPrintSetup = false;
			}
			//microSteppingMode(FULLSTEP);
			//motorStep(4000, 1);

			if (jobStatus == done_printing) {
				stopPrintJob();
			}
		}
//	while(1) {
//		if (doPrintSetup) {
//			doPrintSetup = false;
//
//			// For debug purposes
//			lineWrite(layerFilename, LINE_1);
//			lineWrite(numberOfLayers, LINE_2);
//			lineWrite(thickness, LINE_3);
//
//
//		}
//	}
}
 */
/*********************************************************************************************************/
//New Code

void main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

	// Stepper Motor Port setup
	P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
	P3OUT |= 0x01F;
	P2DIR |= (0x080);
	P2OUT |= (0x080);

	//Reed Switch Port setup
	P1DIR &= ~(BIT0);//Set P1.0 for reed switch interrupt and limit buttons
	P1IE |= BIT0; //Enable Port 1.0 interrupts
	P1IES |= BIT0; //Port 1.0 edge selector H -> L

	//Buzzer and LED Port setup
	P1DIR |= (BIT5+BIT6);//Set P1.5 and P1.6 for buzzer and LED outputs
	P1OUT &= ~(BIT5); //Turn off LED initially.

	//Limit sensor Port setup
	P1DIR &= ~(BIT1 + BIT2); // Set P1.1 and P1.2 as input
	//P1IES |= BIT1 + BIT2; //Port 1.1 and 1.2 edge selector H -> L
	P1IES |= BIT2;
	P1IES &= ~BIT1;
	P1IE  |= BIT1 + BIT2;// Enable interrupt on P1.1 and P1.2

	//Interface Buttons Port setup
	P1DIR &= ~(BIT4+BIT3);//Set P1.3 and P1.4 as inputs for interface buttons
	P1IE |= BIT3+BIT4; //Enable Port 1.3 and P1.4 interrupts.
	P1IES |= BIT3+BIT4; //Port 1.3 and 1.4 edge selector H -> L

	//LCD Port setup
	P5DIR |= 0x03;//Set Port 5.0, 5.1 as outputs for LCD
	P6DIR |= 0x0FF;//Set Port 6 as outputs for LCD Data

	//Timer A0 setup
	UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
	TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TA0CCR0 |= 0; //Store 0 in terminal count register.
	TA0CCTL0 |= CCIE; //Enable TA0 count 0 interrupts

	//Timer B0 setup
	TB0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TB0CCR0 = 32767; //Set terminal count to 32767 to know a second has passed

	//UV setup
	initLCr();

	status = 0;

	// For debug purposes only
	//resinDryTime = 600;
	currentTime = 0; // Initialize time variable

	initializeLCD();
	lineWrite("       Ready`", LINE_2);

	//Testing
	//		activateMotor();
	//		resetMotorToTop();
	//		deactivateMotor();
	activateMotor();
	//resetMotorToBottom();
	deactivateMotor();

	turnUVOn();

	initializeUART();

	//P1IE = 0; //Testing purposes, turning off all interrupts from port 1

	__bis_SR_register(GIE );//+ LPM3); //Enable global interrupts.
	//thickness = "0.5`";
	//layerFilename = "Test1`";
	numberOfLayers[0] = '2';
	numberOfLayers[1] = '5';
//
	layerThickness = 1; // Represents 0.5 layerThickness
	layerFilename[0] = 'T';
	layerFilename[1] = 'e';
	layerFilename[2] = 's';
	layerFilename[3] = '`';


	startPrintingProcess();

	stopPrintJob();

}

/************************************************************************************************************************
 * Port 1 ISR
 **************************************************************************************************************************/
#pragma vector=PORT1_VECTOR
__interrupt void PORT1_ISR(void){
	//Reed Switch interrupt
	//P1.0 Requested the interrupt
	if((P1IFG & BIT0) ){
		if (!(jobStatus == done_printing)) {
			if(!(P1IN & BIT0)){ // If reed sensor is open
				clearDisplay();
				lineWrite(" Please close the`", LINE_2);
				lineWrite("  lid to continue!`", LINE_3);
				TA0CCR0 = 15; //Store 15 in terminal count register.
				//jobStatus = ready;	// Halt printing status
			}
			else{ // If reed sensor is closed
				clearDisplay();
				updateDisplayStatus(status);
				TA0CCR0 = 0; // Halt timer buzzer timer
				P1OUT &= ~(0x020); // Turn off LED.
				//jobStatus = printing; // Set printer status to printing
			}

			P1IES ^= 0x01;
			P1IFG &= ~(0x01);
		}

	}
	// UP and DOWN limit sensor
	//P1.1 or P1.2 Requested the interrupt
	else if((P1IFG & BIT1) | (P1IFG & BIT2)){
		deactivateMotor();//Disable Motor driver
		P1IFG &= ~(BIT1 + BIT2);
	}

	//P1.3 Requested the interrupt
	else if((P1IFG & BIT3)){
		if(!cancelRequest){
			jobStatus = cancelling;
			cancelLCDPrompt();
		}
		else{
			cancelRequest = false;
			jobStatus = printing;
			status = (status ) % 4;
			updateDisplayStatus(status);

		}
		P1IFG &= ~(BIT3);
	}

	//P1.4 Requested the interrupt
	else if((P1IFG & BIT4)){
		if(cancelRequest){
			stopPrintJob();
			deactivateMotor();//Disable Motor driver
			jobStatus = done_printing;
			cancelRequest = false;
		}
		else{
			status = (status + 1) % 4;
			updateDisplayStatus(status);
		}
		P1IFG &= ~(BIT4);
	}
}

/************************************************************************************************************************
 * Timer A0 ISR
 **************************************************************************************************************************/
#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void){
	P1OUT ^= (BIT6);//Toggle Buzzer
	counterLED++;
	if(counterLED == 1024){
		P1OUT ^= BIT5;
		counterLED = 0;
	}
	TA0CCTL0 &= ~(BIT0);

}

/************************************************************************************************************************
 * Timer B0 ISR
 **************************************************************************************************************************/

#pragma vector=TIMER0_B0_VECTOR
__interrupt void TIMER0_B0_VECTOR_ISR(void) {
	currentTime++;
	if (jobStatus == printing) {
		//checkIfDoPrintStep = true;
		if(currentTime % resinDryTime == 0)
			checkIfDoPrintStep = true;
	}
	TB0CCTL0 &= ~(BIT0);
}


/************************************************************************************************************************
 * UART ISR
 **************************************************************************************************************************/
#pragma vector=USCI_A1_VECTOR
__interrupt void USCI_A1_ISR(void){


	if('<' == UCA1RXBUF) // Verify if a legitimate transaction is about to start
	{
		uartACK = true;
		return;
	}

	if(uartACK )
	{
		if( UCA1RXBUF == '>')
			UARTReady = true;	// UART is ready to receive legitimate characters

		uartACK = false;  // Reset UART ACK to false
		return;
	}


	if(UCA1RXBUF != '`' && UARTReady )
		RxBuf[receivedIndex++] = UCA1RXBUF;

	else
	{
		RxBuf[receivedIndex++] = '`';

		formatReceivedData(RxBuf);
		doPrintSetup = true;
		lineWrite("Information received.`",LINE_3);
		deactivateUART();
		//TB0CCTL0 |= CCIE; //Enable TB0 count 1 interrupts
		//P1IE = BIT0 + BIT1 + BIT2 + BIT3 + BIT4; //Testing purposes, turning on
		__bic_SR_register_on_exit(LPM3); // Activate CPU upon ending interrupt

	}

	UCA1IFG &= ~(UCRXIFG); // Clear Interrupt flag
}
//PRECONDITION : UART is NOT messed up
void startPrintingProcess()
{
	unsigned int steps = 0;
	if(layerThickness == 3)
	{
		thickness[0] = '1';
		thickness[1] = '.';
		thickness[2] = '5';
		thickness[3] = '`';
		resinDryTime = DRY_TIME_15;
		steps = STEP_15;
	}
	else if(layerThickness == 2)
	{
		thickness[0] = '1';
		thickness[1] = '.';
		thickness[2] = '0';
		thickness[3] = '`';
		resinDryTime = DRY_TIME_10;
		steps = STEP_10;
	}
	else if(layerThickness == 1)
	{
		thickness[0] = '0';
		thickness[1] = '.';
		thickness[2] = '5';
		thickness[3] = '`';
		resinDryTime = DRY_TIME_05;
		steps = STEP_05;
	}

	jobStatus = printing ;
	TB0CCTL0 |= CCIE; //Enable TB0 count 0 interrupts

	layerQuantity = atoi(numberOfLayers); // numberOfLayers is a variable that is received through UART. In here this variable is changed to an int
	for(;currentLayer < layerQuantity ; currentLayer++)
	{
		while(!checkIfDoPrintStep);
		checkIfDoPrintStep = false;

		turnUVOff();
		microSteppingMode(FULLSTEP);
		activateMotor();
		motorStep(steps, UP);
		deactivateMotor();
		//TODO trigger lightCrafter
		turnUVOn();

		//__bis_SR_register(LPM3); // Send the MCU to sleep mode until a period of DryingTime has passed.



	}


}
