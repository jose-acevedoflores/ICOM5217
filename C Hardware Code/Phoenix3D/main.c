#include <msp430.h> 
#include "Variables.h"
#include "Utils.h"
#include "Motor.h"
#include "LCD.h"
/*
 * main.c
 */

void main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

<<<<<<< HEAD
	/* Stepper Motor Port setup */
	P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
	P3OUT |= 0x01F;
	P2DIR |= (0x080);
	P2OUT |= (0x080);
=======
    /*Reed Switch Port setup*/
    P1DIR &= ~(0x01F);//Set P1.0 for reed switch interrupt and limit buttons
>>>>>>> dff422609256dc62bf6c6c804b4c91bf2cd6ac97

	/*Reed Switch Port setup*/
	P1DIR &= ~(0x01);//Set P1.0 for reed switch interrupt

	/*Buzzer and LED Port setup*/
	P1DIR |= (0X060);//Set P1.5 and P1.6 for buzzer and LED outputs
	P1OUT &= ~(0x020); //Turn off LED initially.

	/*LCD Port setup*/
	P5DIR |= 0x03;//Set Port 5.0, 5.1 as outputs for LCD
	P6DIR |= 0x0FF;//Set Port 6 as outputs for LCD Data

<<<<<<< HEAD
	/*Timer A0 setup*/
	UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
	TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
	TA0CCR0 |= 0; //Store 0 in terminal count register.
	TA0CCTL0 |= CCIE; //Enable TA0 count 0 interrupts
	TA0CCR1 |= 32767; //Set terminal count to 32767 to know a second has passed
	TA0CCTL1 |= CCIE; //Enable TA0 count 1 interrupts
=======
    P1IE |= 0x01F; //Enable Port 1.0 and P1.1 interrupts.
    P1IES |= 0x01F; //Port 1.0 and 1.1 edge selector H -> L
>>>>>>> dff422609256dc62bf6c6c804b4c91bf2cd6ac97

	P1IE |= 0x03; //Enable Port 1.0 and P1.1 interrupts.
	P1IES |= 0x03; //Port 1.0 and 1.1 edge selector H -> L

	currentTime = 0; // Initialize time variable
	totalTime = resinDryTime * layerQuantity; // Calculate total estimated time

<<<<<<< HEAD
	__bis_SR_register(GIE); //Enable global interrupts.
=======
    lineWrite(line1, LINE_1);
    P2OUT &= ~(0x080);
    resetMotorToTop();
    resetMotorToBottom();
>>>>>>> dff422609256dc62bf6c6c804b4c91bf2cd6ac97

	char line1[20] = "Test complete`";
	initializeLCD();

	lineWrite(line1, LINE_1);
	P2OUT &= ~(0x080);
	resetMotorToTop();

	//microSteppingMode(FULLSTEP);
	//motorStep(4000, 1);

}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void){
	if (TA0CCR0 == 15) {
		P1OUT ^= (0x040);//Toggle Buzzer
		counterLED++;
		if(counterLED == 1024){
			P1OUT ^= 0x020;
			counterLED = 0;
		}
		TA0CCTL0 &= ~(0x01);
	}
	else if (TA0CCR1 == 32767){
		currentTime++;
	}
}

#pragma vector=PORT1_VECTOR
__interrupt void PORT1_ISR(void){
	//P1.0 Requested the interrupt
	if((P1IFG & 0x01) == 1){
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
	if((P1IFG & 0x02) == 1){
		P2OUT |= (0x080);
		P1IFG &= ~(0x02);
	}

	//P1.2 Requested the interrupt
		if((P1IFG & 0x04) == 1){
			P2OUT |= (0x080);
			P1IFG &= ~(0x04);
		}
}
