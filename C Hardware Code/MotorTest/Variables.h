/*
 * Variables.h
 *
 * This file contains all the global variables that are to be used by
 * the software of the MPU for the printing operation.
 *
 * Created on: Mar 27, 2013
 * 		Author: hfranqui
 */

#ifndef VARIABLES_H_
#define VARIABLES_H_

// Global variables
unsigned int counterLED = 0;

// Global variables received through communication
int layerThickness = 0;
int layerQuantity = 0;
int resinDryTime = 0;
int currentLayer = 0;
int totalTime = 0;

// Array of strings that contain up to 1500 filenames of maximum 31 characters each
char layerFilename[21];

// The following global variables may not be needed.
int startTime = 0;
int currentTime = 0;

typedef short PRINTER_STATUS;
#define ready 0
#define printing 1
#define cancelling 2
#define done_printing 3

volatile PRINTER_STATUS jobStatus = ready;

typedef int bool;
#define true 1
#define false 0

volatile bool cancelRequest = false;
volatile bool checkIfDoPrintStep = false;
volatile bool doPrintSetup = false;

// Array used to save the characters received from the UART
char RxBuf[200] = "";
int receivedIndex = 0;
char numberOfLayers[5] = "";
char thickness[6]= "";
char pageNumber[2] = "";

// UART Ack variable
volatile bool uartACK= false;
volatile bool UARTReady= false;
#endif /* VARIABLES_H_ */
