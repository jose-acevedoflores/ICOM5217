#include <msp430.h> 

/*
 * main.c
 */
void wait(int delay){
	volatile unsigned int i = 0;
			for( ; i < delay; i++);
}
void main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
	P1DIR = 0x020;

	while(1){
		P1OUT ^= 0x020;
	    wait(10000);
	}
}


