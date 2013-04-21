
void turnUVOn(void)
{
	P5OUT |= 0x04; // Assign to P5.2 the value 1
}

void turnUVOff(void)
{
	P5OUT &=(~ 0x04); // Assign to P5.2 the value 0
}
