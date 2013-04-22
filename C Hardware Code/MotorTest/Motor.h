/*
 * Motor.h
 *
 *  Created on: Mar 27, 2013
 *      Author: fernando
 */

#include "Utils.h"
#include <msp430.h>

#ifndef MOTOR_H_
#define MOTOR_H_

enum SM{
	FULLSTEP,
	HALFSTEP,
	QUARTERSTEP,
	EIGHTHSTEP,
	SIXTEENTHSTEP,
	THIRTYSECONDTHSTEP
};

enum DR{
	UP = 0,
	DOWN = 1
};

void motorStep(int numberSteps, enum DR direction);
void microSteppingMode(enum SM stepMode);
// Pin 1.1 is top motor location sensor
void resetMotorToTop();

// Pin 1.2 is bottom motor location sensor
void resetMotorToBottom();

void activateMotor();

void deactivateMotor();

#endif /* MOTOR_H_ */
