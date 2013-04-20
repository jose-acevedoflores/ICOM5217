/*
 * Motor.h
 *
 *  Created on: Mar 27, 2013
 *      Author: fernando
 */

enum SM{
	FULLSTEP,
	HALFSTEP,
	QUARTERSTEP,
	EIGHTHSTEP,
	SIXTEENTHSTEP,
	THIRTYSECONDTHSTEP
} stepMode;

enum DR{
	UP = 0,
	DOWN = 1
} stepDirection;

void motorStep(int numberSteps, enum DR direction){

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



// Pin 1.1 is top motor location sensor
void resetMotorToTop() {
	microSteppingMode(FULLSTEP);
	while (!(~P1IN & 0x02)) {
		// Move motor ten steps up
		motorStep(5,UP);
	}
}

// Pin 1.2 is bottom motor location sensor
void resetMotorToBottom() {
	microSteppingMode(FULLSTEP);
	while (!(~P1IN & 0x04)) {
			// Move motor ten steps down
			motorStep(5,DOWN);
		}
}

void activateMotor(){
	P2OUT &= ~(0x080);
}

void deactivateMotor(){
	P2OUT |= (0x080);
}

