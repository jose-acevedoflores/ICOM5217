/*
 * Motor.h
 *
 *  Created on: Mar 27, 2013
 *      Author: Piro
 */

enum SM{
	FULLSTEP,
	HALFSTEP,
	QUARTERSTEP,
	EIGHTHSTEP,
	SIXTEENTHSTEP,
	THIRTYSECONDTHSTEP
} stepMode;

void motorStep(int numberSteps, int direction){
	P2OUT &= ~(0x080);
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
