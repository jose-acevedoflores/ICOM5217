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
char layerFilenames[1500][21];

// The following global variables may not be needed.
int startTime = 0;
int currentTime = 0;

enum PRINTER_STATUS {
	READY,
	PRINTING,
	CANCELLING,
	DONE_PRINTING
};

typedef int bool;
#define true 1
#define false 0

bool cancelRequest = false;
