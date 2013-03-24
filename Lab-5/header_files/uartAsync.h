#define   ToSend    R7
#define   STR       R8
      ORG       0x06000
      DW        UART_ASYNC
        
UART_ASYNC nop
          
INIT_UART bis.b #BIT4+BIT3 , P3SEL      ; Configure P3.3 and P3.4 to use module and not GPIO
          
          bis.b #UCSWRST, UCA0CTL1      ; Reset UART module state
          bis.b #UCSSEL_2, UCA0CTL1    ; Select SMCLK for BRCLK
          bic.b #UCPEN+UC7BIT+UCSYNC, UCA0CTL0        ; Parity disable, transmit 8 bit data in ASYNC mode
          bis.b #UCMODE_0, UCA0CTL0    ; Set UART mode
          
          bis.b #UCBRF_0+UCBRS_2, UCA0MCTL    ; Set baud rate parameters
          bis.b #109,UCA0BR0            ; Set baud rate parameters
            
          bic.b #UCSWRST, UCA0CTL1      ; Restart UART module state
          bis.b #UCRXIE, UCA0IE  
          ret  
////////////////////////////////////////////////////////////////////////////////
// Send data function                                                        //
//      Uses Register R7 to pass the byte that will be transferred           //             
///////////////////////////////////////////////////////////////////////////////            
SendData  bit.b   #UCTXIFG,&UCA0IFG      ; Tx Buffer ready ?
          jnc   SendData  

          mov.b ToSend, UCA0TXBUF       ; Initialize transmission  
          
          ret

////////////////////////////////////////////////////////////////////////////////
// Send data function                                                        //
//      Uses Register R7 to pass the byte that will be transferred           //             
///////////////////////////////////////////////////////////////////////////////      
PrintLine 
Print     mov.b @STR+, ToSend
          cmp.b #'`', ToSend  
          jz    stop  
          call  #SendData 
          jmp   Print 
stop      ret
////////////////////////////////////////////////////////////////////////////////
// Uart ISR                                                                  //
//      Uses Register R7 to pass the byte that will be transferred           //             
///////////////////////////////////////////////////////////////////////////////       
UART_ISR  bit.b   #UCTXIFG,&UCA0IFG      ; Tx Buffer ready ?
          jnc   UART_ISR  

          mov.b ToSend, UCA0TXBUF       ; Initialize transmission  
          bic.b   #UCRXIFG,&UCA0IFG            
    
          reti

LineToPrint     DB      'Hello World!`'            