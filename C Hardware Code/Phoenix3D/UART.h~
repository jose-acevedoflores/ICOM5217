/*
 * UART.h
 *
 *  Created on: Apr 6, 2013
 *      Author: Jose Acevedo
 */
#include <msp430.h>

void initializeUART(void){
	P4SEL |= BIT4 + BIT5;
	UCA1CTL1 |=  UCSWRST;	// Reset UART module state
	UCA1CTL1 |= UCSSEL_2;	// Select SMCLK for BRCLK
	UCA1CTL0 &= ~(UCPEN + UC7BIT + UCSYNC);	// Parity Disable , transmit 8 bit data in ASYNC mode
	UCA1CTL0 |= UCMODE_0;	// Set UART mode

	UCA0MCTL |= UCBRF_0 + UCBRS_2; // Set baud rate parameters
	UCA1BR0 |= 109;		// Set baud rate parameters

	UCA1CTL1 &=~(UCSWRST);	// Restart UART module state
	UCA1IE |= UCRXIE;		// Set Interrupt for this port

}

void send(int character)
{
	while(!(UCA1IFG&UCTXIFG));
	UCA1TXBUF = character;
}
