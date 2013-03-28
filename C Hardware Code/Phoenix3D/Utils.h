/*
 * Utils.h
 *
 *  Created on: Mar 27, 2013
 *      Author: Piro
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
struct realTime getTimeFromSeconds(long time) {

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

// Converts an integer to a character array
void *changeIntegerToChar(int integer, char result[]) {

    int int4 = 0, int3 = 0, int2 = 0, int1 = 0;

    if (integer > 1000) {
        int4 = integer / 1000;
        integer = integer % 1000;
    }
    if (integer > 100) {
        int3 = integer / 100;
        integer = integer % 100;
    }
    if (integer > 10) {
        int2 = integer / 10;
        int1 = integer % 10;
    }

    result[4] = '\0';
    result[3] = (char) (int1 + 48);
    result[2] = (char) (int2 + 48);
    result[1] = (char) (int3 + 48);
    result[0] = (char) (int4 + 48);

    return;
}

void *concatenateIntToString(char string[], int strLen, char integer[], int intLen, char result[]) {

    int i = 0;
    while (integer[i] == '0') {
        i++;
    }

    memcpy(result, string, strLen);
    memcpy(&result[strLen],&integer[i],intLen);

    return;
}
