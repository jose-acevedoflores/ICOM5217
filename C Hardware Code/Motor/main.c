#include <msp430.h> 

/*
 * main.c
 */

enum SM{
	FULLSTEP,
	HALFSTEP,
	QUARTERSTEP,
	EIGHTHSTEP,
	SIXTEENTHSTEP,
	THIRTYSECONDTHSTEP
} stepMode;

void wait(int delay){
	volatile unsigned int i = 0;
			for( ; i < delay; i++);
}
void motorStep(int numberSteps, int direction){
	if(direction == 0){
		P3OUT &= ~(0x01);
	}
	else{
		P3OUT |= 0x01;
	}

    volatile unsigned int i = 0;
    for(; i < numberSteps; i++){
    	P3OUT |= 0x02;
    	wait(500);
    	P3OUT &= ~(0x02);
    	wait(500);
    }
}

void microSteppingMode(enum SM stepMode){
	switch(stepMode){
	case FULLSTEP:
		P3OUT &= ~(0x01C);
		break;
	case HALFSTEP:
		P3OUT |= 0x010;
		P3OUT &= ~(0x0C);
		break;
	case QUARTERSTEP:
		P3OUT |= 0x08;
		P3OUT &= ~(0x14);
		break;
	case EIGHTHSTEP:
		P3OUT |= 0x018;
		P3OUT &= ~(0x04);
		break;
	case SIXTEENTHSTEP:
		P3OUT |= 0x04;
		P3OUT &= ~(0x18);
		break;
	case THIRTYSECONDTHSTEP:
		P3OUT |= 0x01C;
		break;
	}
}
void main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    P3DIR |= 0x01F; //Set P3.0, P3.1, P3.2, P3.3, P3.4 as output
    P3OUT |= 0x01F;

    microSteppingMode(FULLSTEP);
    motorStep(4000, 1);
}

