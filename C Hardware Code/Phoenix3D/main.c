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
	
    /* Stepper Motor Port setup */
    P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
    P3OUT |= 0x01F;
    P2DIR |= (0x080);
    P2OUT |= (0x080);

    /*Reed Switch Port setup*/
    P1DIR &= ~(0x01);//Set P1.0 for reed switch interrupt

    /*Buzzer and LED Port setup*/
    P1DIR |= (0X060);//Set P1.5 and P1.6 for buzzer and LED outputs
    P1OUT &= ~(0x020); //Turn off LED initially.

    /*LCD Port setup*/
    P5DIR |= 0x03;//Set Port 5.0, 5.1 as outputs for LCD
    P6DIR |= 0x0FF;//Set Port 6 as outputs for LCD Data

    /*Timer A0 setup*/
    UCSCTL4 |= SELA_2; //Choose ACLK source as Real Time CLK
    TA0CTL |= TASSEL_1 | ID_0 | MC_1;//Set prescaler, UP Mode.
    TA0CCR0 |= 0; //Store 0 in terminal count register.
    TA0CCTL0 |= CCIE; //Enable TA0 interrupts.

    P1IE |= 0x03; //Enable Port 1.0 and P1.1 interrupts.
    P1IES |= 0x03; //Port 1.0 and 1.1 edge selector H -> L

    __bis_SR_register(GIE); //Enable global interrupts.

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
	P1OUT ^= (0x040);//Toggle Buzzer
	counterLED++;
	if(counterLED == 1024){
		P1OUT ^= 0x020;
		counterLED = 0;
	}
	TA0CCTL0 &= ~(0x01);
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
}
