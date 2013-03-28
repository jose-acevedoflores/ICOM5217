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
enum LCD_STATUS status = SHOW_LAYERS_AMOUNT;

// Describes the current status of the LCD
enum LCD_STATUS {
	SHOW_LAYERS_AMOUNT,
	SHOW_TIME_ELAPSED,
	SHOW_TIME_REMAINING,
	SHOW_CURRENT_LAYER_FILENAME
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

void updateDisplayStatus(void) {
	switch(status) {
	case SHOW_LAYERS_AMOUNT:
		volatile char temp[20] = "";
		sprintf(temp, " %d of %d", currentLayer, layerQuantity);

		lineWrite("    Printing layer    ", LINE_2);
		lineWrite(temp, LINE_3);
		status = SHOW_TIME_ELAPSED;
		break;
	case SHOW_TIME_ELAPSED:
		volatile unsigned long elapsedTime = currentTime - startTime;
		char temp[20] = "";
		volatile struct realTime t;
		t = getTimeFromSeconds(elapsedTime);
		sprintf(temp, " %d h %d m %d s elapsed", t.hours, t.minutes, t.seconds);
		lineWrite("   Approximately    ", LINE_2);
		lineWrite(temp, LINE_3);
		status = SHOW_TIME_REMAINING;
		break;
	case SHOW_TIME_REMAINING:
		volatile unsigned long elapsedTime = currentTime - startTime;
		volatile unsigned long remainingTime = totalTime - elapsedTime;


		break;
	case SHOW_CURRENT_LAYER_FILENAME:
		break;

	}
}



//__no_operation();
//char arreglotest[20] = "pipisito 09`";
