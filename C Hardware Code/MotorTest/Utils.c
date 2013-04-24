/*
 * Utils.c
 *
 *  Created on: Apr 21, 2013
 *      Author: Piro
 */


/*
 * Utils.h
 *
 *  Created on: Mar 27, 2013
 *      Author: fernando
 */
#include "Variables.h"
#include "Utils.h"

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

//This function formats the RxBuf[] array
void formatReceivedData(char Rx[])
{
	int i = 0, start = 0;
	while (Rx[i] != ',') {
		numberOfLayers[i-1] = Rx[i++];
	}
	numberOfLayers[i] = '`';
	i++;

	start = i+1;
	while(Rx[i] != ',') {
		thickness[i-start] = Rx[i++];
	}
	thickness[(i+1)-start] = '`';
	i++;

	start = i+1;
	while(Rx[i] != '`') {
		layerFilename[i-start] = Rx[i++];
	}
	layerFilename[(i+1)-start] = '`';

}

