void turnUVOn(void)
{
	P2OUT |= BIT0; // Assign to P5.2 the value 1
}

void turnUVOff(void)
{
	P2OUT &=(~ BIT0); // Assign to P5.2 the value 0
}

void initLCr(void)
{
	P2DIR |= BIT0+BIT1; //
}
