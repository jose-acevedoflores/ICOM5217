/*
 * Utils.h
 *
 *  Created on: Mar 27, 2013
 *      Author: fernando
 */

struct realTime {
	int seconds;
	int minutes;
	int hours;
};

void wait(int delay){
	volatile unsigned int i = 0;
	for( ; i < delay; i++);
}

// Returns an structure with the first element as seconds, the second element as minutes, the third as hours
struct realTime getTimeFromSeconds(int time) {

	struct realTime t;

	t.minutes = time / 60;
	if (t.minutes >= 60) {
		t.hours = t.minutes / 60;
		t.minutes = t.minutes % 60;
	}

	t.seconds = time % 60;
	if (t.seconds >= 60) {
		t.minutes = t.minutes + (t.seconds / 60);
		t.seconds = t.seconds % 60;
	}

	return t;
}


