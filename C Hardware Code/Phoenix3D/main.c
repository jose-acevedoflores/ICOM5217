#include <msp430.h>
#include <stdio.h>
#include "Variables.h"
#include "Utils.h"
#include "Motor.h"
#include "LCD.h"
#include "UART.h"
/*
 * main.c
 */

void main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

	/* Stepper Motor Port setup */
	P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
	P3OUT |= 0x01F;
	P2DIR |= (0x080);
	P2OUT |= (0x080);

	/*Reed Switch Port setup*/
	P1DIR &= ~(0x01F);//Set P1.0 for reed switch interrupt and limit buttons

	/*Buzzer and LED Port setup*/
	P1DIR |= (0X060);//Set P1.5 and P1.6 for buzzer and LED outputs
	P1OUT &= ~(0x020); //Turn off LED initially.

	/*Interface Buttons Port setup*/
	P1DIR &= ~(0x018);//Set P1.3 and P1.4 as inputs for interface buttons

	/*LCD Port setup*/
	P5DIR |= 0x03;//Set Port 5.0, 5.1 as outputs for LCD
	P6DIR |= 0x0FF;//Set Port 6 as outputs for LCD Data

	/*Timer A0 setup*/
	UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
	TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TA0CCR0 |= 0; //Store 0 in terminal count register.
	TA0CCTL0 |= CCIE; //Enable TA0 count 0 interrupts

	TB0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TB0CCR0 = 32767; //Set terminal count to 32767 to know a second has passed
	TB0CCTL0 |= CCIE; //Enable TA0 count 1 interrupts

	P1IE |= 0x01F; //Enable Port 1.0 and P1.1 interrupts.
	P1IES |= 0x01F; //Port 1.0 and 1.1 edge selector H -> L

//	P1IE |= 0x03; //Enable Port 1.0 and P1.1 interrupts.
//	P1IES |= 0x03; //Port 1.0 and 1.1 edge selector H -> L

	// For debug purposes only
	resinDryTime = 120;
	layerQuantity = 1200;

	currentTime = 0; // Initialize time variable
	totalTime = resinDryTime * layerQuantity; // Calculate total estimated time

	__bis_SR_register(GIE); //Enable global interrupts.
	//lineWrite(line1, LINE_1);
	deactivateMotor();
	//	resetMotorToTop();

	initializeLCD();
	//char line5[20] = "Test complete`";
	//lineWrite(line5, LINE_1);

	// Below is a testing routine for the updateDisplayStatus() function
	startTime = currentTime; // Set startTime
	//status = 0;

	//resetMotorToTop();
	initializeUART();
	lineWrite("Filename: cube.stl`",LINE_1);
	lineWrite("Num of layers: 1273`",LINE_2);
	lineWrite("Layer Thickness: 0.5mm`",LINE_3);
	lineWrite("1/4`",LINE_4);

	while (1);

	//microSteppingMode(FULLSTEP);
	//motorStep(4000, 1);

}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void){
	P1OUT ^= (0x040);//Toggle Buzzer
	counterLED++;
	if(counterLED == 1024){
		P1OUT ^= 0x020;
		counterLED = 0;
	}
	TA0CCTL0 &= ~(0x01);

}

#pragma vector=TIMER0_B0_VECTOR
__interrupt void TIMER0_B0_VECTOR_ISR(void) {
	currentTime++;

	if (currentTime % 5 == 0) {
		//clearDisplay();
		//updateDisplayStatus(status);
		status = currentTime % 4;
		TA0CCTL0 &= ~(0x01);
	}
}

#pragma vector=PORT1_VECTOR
__interrupt void PORT1_ISR(void){
	//P1.0 Requested the interrupt
	if((P1IFG & 0x01) != 0){
		if((P1IN & 0x01) == 0){
			TA0CCR0 = 15; //Store 15 in terminal count register.
		}
		else{
			TA0CCR0 = 0; // Halt timer
			P1OUT &= ~(0x020); // Turn off LED.
		}

		P1IES ^= 0x01;
		P1IFG &= ~(0x01);
	}
	//P1.1 Requested the interrupt
	else if((P1IFG & 0x02) != 0){
		P2OUT |= (0x080);//Disable Motor driver
		P1IFG &= ~(0x02);
	}

	//P1.2 Requested the interrupt
	else if((P1IFG & 0x04) != 0){
		P2OUT |= (0x080);//Disable Motor driver
		P1IFG &= ~(0x04);
	}

	//P1.3 Requested the interrupt
	else if((P1IFG & 0x08) != 0){
		cancelPrint();
		P1IFG &= ~(0x08);
		}
	//P1.4 Requested the interrupt
	else if((P1IFG & 0x010) != 0){
		if(cancelRequest){
			P2OUT |= (0x080);//Disable Motor driver
			cancelRequest = false;
		}
		else{
			status = (status+1)%4;
			updateDisplayStatus(status);
		}
		P1IFG &= ~(0x010);
			}
}
//UART RX ISR
#pragma vector=USCI_A1_VECTOR
__interrupt void USCI_A1_ISR(void){

	if(UCA1RXBUF != '`')
		RxBuf[receivedIndex++] = UCA1RXBUF;

	else
	{
		formatReceivedData(RxBuf);
		receivedIndex = 0;
	}

	UCA1IFG &= ~(UCRXIFG); // Clear Interrupt flag
}
