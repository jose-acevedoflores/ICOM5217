#include <msp430.h> 
#include "Utils.h"
#include "Motor.h"
/*
 * main.c
 */


void main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output
    P3OUT |= 0x01F;

    microSteppingMode(FULLSTEP);
    motorStep(4000, 1);
}

