


    ORG         0x06000
    DW          InitTimer
///////////////////////////////////////////////////////////////////////////////
//Initialize Timer Function
///////////////////////////////////////////////////////////////////////////////      
InitTimer       nop

      bis.w   #SELA_2,&UCSCTL4       ; Set AMCLK source to REFOCLOCK  
      bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
      bis.w   #CCIE, &TA0CCTL0                ; Enable interrupt on compare
      bis.w   #0FFFFh, &TA0CCR0                ; Count up to FFFF
      bis.w   #TAIDEX_2, &TA0EX0              ; Divide input signal by 2
      ret
        
///////////////////////////////////////////////////////////////////////////////
//Timer Interrupt Service Routine
///////////////////////////////////////////////////////////////////////////////

timer:  nop
        
        bic.w   #BIT0,TA0CTL            ; Clear interrupt flag
        reti
                