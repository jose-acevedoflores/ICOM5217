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
unsigned int layerThickness;
unsigned int layerQuantity;
unsigned int resinDryTime;
unsigned int currentLayer;
unsigned int totalTime;

// Array of strings that contain up to 1500 filenames of maximum 31 characters each
unsigned char layerFilenames[1500][31];

// The following global variables may not be needed.
unsigned long startTime;
unsigned long currentTime;

enum PRINTER_STATUS {
	READY,
	PRINTING,
	CANCELLING,
	DONE_PRINTING
};