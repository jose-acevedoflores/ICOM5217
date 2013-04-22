#include <msp430.h> 
#include "Motor.h"

/*
 * main.c
 */
void main(void) {
    WDTCTL = WDTPW + WDTHOLD;	// Stop watchdog timer
    P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output for motor stepper driver
   	P3OUT |= 0x01F;
    P2DIR |= (0x080);
   	P2OUT |= (0x080);

   	while(1) {
		deactivateMotor();
   		microSteppingMode(FULLSTEP);
		motorStep(1000, DOWN);
   		activateMotor();
		wait(10000);
		wait(10000);
		wait(10000);
		wait(10000);
		wait(10000);

   	}

	//while(1);
}
