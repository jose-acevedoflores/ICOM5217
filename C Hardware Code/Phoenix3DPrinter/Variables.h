/*
 * Variables.h
 *
 * This file contains all the global variables that are to be used by
 * the software of the MPU for the printing operation.
 *
 * Created on: Mar 27, 2013
 * 		Author: hfranqui
 */

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

// DT stands for Drying Time . Drying time for the different thicknesses. The value is the amount in SECONDS.
enum DT{
	DRY_TIME_15 = 60,
	DRY_TIME_10 = 60,
	DRY_TIME_05 = 5
} dryingTimeConstants;

// SPT stands for Stepping Per Thickness . The values represents the predefine step sizes for three different thicknesses.
enum SPT{
	STEP_15 = 189,
	STEP_10 = 126,
	STEP_05 = 63
}steppingConstants;
