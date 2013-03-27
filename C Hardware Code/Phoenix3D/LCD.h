/*
 * LCD.h
 *
 *  Created on: Mar 27, 2013
 *      Author: joseoyola
 */

char line1[20];
char line2[20];
char line3[20];
char line4[20];

enum LINE {
	LINE_1,
	LINE_2,
	LINE_3,
	LINE_4
} lineNumber;

void enableLCD(void) {
	P5OUT |= 0x01; //Set enable pin
	wait(280);
	P5OUT &= ~(0x01); //Clear enable pin
	wait(280);
}

void commandWrite(char command) {
	P5OUT &= ~(0x02); //Clear RS pin
	wait(280);
	P6OUT = command; //Move data to data pins
	wait(280);
	enableLCD(); //Send command to LCD
}

void characterWrite(char character) {
	P5OUT |= 0x02; //Set RS pin
	wait(280);
	P6OUT = character; //Move data to data pins
	wait(280);
	enableLCD(); //Send command to LCD
}

void initializeLCD(void) {
	wait(10000);
	commandWrite(0x030);
	wait(10000);
	commandWrite(0x030);
	wait(280);
	commandWrite(0x030);
	wait(280);

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

	for (int i = 0; i < 20; i++) {
		if (line[i] == "`") //If current character is the endline, break
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



//__no_operation();
//char arreglotest[20] = "pipisito 09`";
