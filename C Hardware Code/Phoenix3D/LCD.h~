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
int status = 0;

// Describes the current status of the LCD
enum LCD_STATUS {
	SHOW_LAYERS_AMOUNT = 0,
	SHOW_TIME_ELAPSED = 1,
	SHOW_TIME_REMAINING = 2,
	SHOW_CURRENT_LAYER_FILENAME = 3
};

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
	for (; i < 20; i++) {
		if (line[i] == '`' ) //If current character is the endline, break
			break;
		else characterWrite(line[i]); //Else write character on the screen
	}
}

void updateDisplay(void) {
	lineWrite(line1, LINE_1); //Update line1
	lineWrite(line2, LINE_2); //Update line2
	lineWrite(line3, LINE_3); //Update line3
	lineWrite(line4, LINE_4); //Update line4
}

void updateDisplayStatus(enum LCD_STATUS status) {
	switch(status) {
	case SHOW_LAYERS_AMOUNT: {
		char temp[20] = "";

		//sprintf(temp, " %d of %d `", currentLayer, layerQuantity);

		lineWrite("    Printing layer`", LINE_2);
		lineWrite(temp, LINE_3);
		status = SHOW_TIME_ELAPSED;
		break;
	}
	case SHOW_TIME_ELAPSED: {
		//int elapsedTime = currentTime - startTime;
		int elapsedTime = 23456;
		char temp[20] = "";

		sprintf(temp, "%d`", currentTime);
		lineWrite(temp, LINE_1);
		struct realTime t = getTimeFromSeconds(elapsedTime);

		sprintf(temp, " %dh %dm %ds elapsed`", t.hours, t.minutes, t.seconds);

		lineWrite("   Approximately`", LINE_2);
		lineWrite(temp, LINE_3);
		status = SHOW_TIME_REMAINING;
		break;
	}
	case SHOW_TIME_REMAINING: {
		int elapsedTime = currentTime - startTime;
		int remainingTime = totalTime - elapsedTime;

		char temp[20] = "";
		struct realTime t = getTimeFromSeconds(remainingTime);
		//sprintf(temp, "Approx. %dh %dm %ds", t.hours, t.minutes, t.seconds);

		lineWrite(temp, LINE_2);
		lineWrite(" remaining.`", LINE_3);
		status = SHOW_CURRENT_LAYER_FILENAME;
		break;
	}
	case SHOW_CURRENT_LAYER_FILENAME: {

		//lineWrite("   Printing file`", LINE_2);
		//lineWrite(layerFilenames[currentLayer], LINE_3);
		status = SHOW_LAYERS_AMOUNT;
		break;
	}
	}
}


//__no_operation();
//char arreglotest[20] = "pipisito 09`";
