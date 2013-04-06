/*
 * LCD.h
 *
 *  Created on: Mar 27, 2013
 *      Author: joseoyola and hfranqui
 */

char line1[20] = "";
char line2[20] = "";
char line3[20] = "";
char line4[20] = "";

// Global variable used to write spaces before any text in the function lineWrite(). Used to center text
int spaceBefore = 0;
// Global variable that specifies the status of the LCD.
int status = 0;

enum LINE {
	LINE_1,
	LINE_2,
	LINE_3,
	LINE_4
};

void enableLCD(void) {
	P5OUT |= 0x01; //Set enable pin
	wait(500);
	P5OUT &= ~(0x01); //Clear enable pin
	wait(500);
}

void commandWrite(int command) {
	P5OUT &= ~(0x02); //Clear RS pin
	wait(500);
	P6OUT = command; //Move data to data pins
	wait(500);
	enableLCD(); //Send command to LCD
}

void characterWrite(int character) {
	P5OUT |= 0x02; //Set RS pin
	wait(500);
	P6OUT = character; //Move data to data pins
	wait(500);
	enableLCD(); //Send command to LCD
}

void initializeLCD(void) {
	wait(10000);
	commandWrite(0x030);
	wait(10000);
	commandWrite(0x030);
	wait(500);
	commandWrite(0x030);
	wait(500);

	commandWrite(0x01);
	commandWrite(0x08);
	commandWrite(0x038);
	commandWrite(0x0E);
	commandWrite(0x06);
}

void lineWrite(char line[], enum LINE lineNumber) {
	switch(lineNumber) { //Move cursor to current line
	case LINE_1:
		commandWrite(0x080);
		break;
	case LINE_2:
		commandWrite(0x0C0);
		break;
	case LINE_3:
		commandWrite(0x094);
		break;
	case LINE_4:
		commandWrite(0x0D4);
		break;
	}
	volatile unsigned int i = 0;
	for (; i < 20 + spaceBefore; i++) {
		if (line[i-spaceBefore] == '`' ) //If current character is the endline, break
			break;
		// Addition: begins to write in an specific place in the line, given by spaceBefore
		else if (i >= spaceBefore) characterWrite(line[i - spaceBefore]); // Change: write character if spaces are already written
		else characterWrite(' '); // Else put a space before
	}
	// Resets space before
	spaceBefore = 0;
}

void updateDisplay(void) {
	lineWrite(line1, LINE_1); //Update line1
	lineWrite(line2, LINE_2); //Update line2
	lineWrite(line3, LINE_3); //Update line3
	lineWrite(line4, LINE_4); //Update line4
}

void clearDisplay(void) {
	lineWrite("                    ", LINE_1);
	lineWrite("                    ", LINE_2);
	lineWrite("                    ", LINE_3);
	lineWrite("                    ", LINE_4);
}

void updateDisplayStatus(int status) {
	switch(status) {
	case 0: {
		char temp[20] = "";

		sprintf(temp, "%d of %d`", currentLayer, layerQuantity);
		int i = 0;
		for (; temp[i] != '`'; i++);

		lineWrite("   Printing layer`", LINE_2);
		spaceBefore = (20 - i)/2;
		lineWrite(temp, LINE_3);

		break;
	}
	case 1: {
		//int elapsedTime = currentTime - startTime;
		int elapsedTime = currentTime - startTime;
		char temp[20] = "";
		struct realTime t = getTimeFromSeconds(elapsedTime);

		sprintf(temp, "%dh %dm %ds`", t.hours, t.minutes, t.seconds);

		int i = 0;
		for (; temp[i] != '`'; i++);

		lineWrite("   Approximately`", LINE_2);
		spaceBefore = (20 - i)/2;
		lineWrite(temp, LINE_3);
		lineWrite("      elapsed`", LINE_4);

		break;
	}
	case 2: {
		int elapsedTime = currentTime - startTime;
		int remainingTime = totalTime - elapsedTime;

		char temp[20] = "";
		struct realTime t = getTimeFromSeconds(remainingTime);
		sprintf(temp, "%dh %dm %ds`", t.hours, t.minutes, t.seconds);

		int i = 0;
		for (; temp[i] != '`'; i++);

		lineWrite("   Approximately`", LINE_2);
		spaceBefore = (20 - i)/2;
		lineWrite(temp, LINE_3);
		lineWrite("     remaining`", LINE_4);

		break;
	}
	case 3: {

		lineWrite("   Printing file`", LINE_2);
		//lineWrite(layerFilenames[currentLayer], LINE_3);

		break;
	}
	}
}

//__no_operation();
//char arreglotest[20] = "pipisito 09`";

