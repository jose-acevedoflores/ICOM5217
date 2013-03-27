#include <msp430.h> 
#include "Utils.h"
#include "Motor.h"
/*
 * main.c
 */


void main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    /* Stepper Motor Port setup */
    P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
    P3OUT |= 0x01F;

    /*Reed Switch Port setup*/
    P1DIR &= ~(0x01);//Set P1.0 for reed switch interrupt

    /*Buzzer and LED Port setup*/
    P1DIR |= (0X060);//Set P1.5 and P1.6 for buzzer and LED outputs
    P1OUT &= ~(0x020); //Turn off LED initially.

    /*Timer A0 setup*/
    UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
    TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
    TA0CCR0 |= 32767; //Store 0 in terminal count register.
    TA0CCTL0 |= CCIE; //Enable TA0 interrupts.

    P1IE |= 0x01; //Enable Port 1 interrupts.
    P1IES |= 0x01; //Port 1 edge selector H -> L

    __bis_SR_register(GIE); //Enable global interrupts.

    microSteppingMode(FULLSTEP);
    motorStep(4000, 1);
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void){
	P1OUT ^= 0x020;
}
