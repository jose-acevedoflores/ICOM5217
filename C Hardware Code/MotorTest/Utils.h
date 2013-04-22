/*
 * Utils.h
 *
 *  Created on: Mar 27, 2013
 *      Author: fernando
 */
#ifndef UTILS_H_
#define UTILS_H_

struct realTime {
	int seconds;
	int minutes;
	int hours;
};

void wait(int delay);
struct realTime getTimeFromSeconds(int time);

void formatReceivedData(char Rx[]);
#endif /* UTILS_H_ */
