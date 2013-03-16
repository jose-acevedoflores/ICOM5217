#include "msp430.h"                     ; #define controlled include file
#include "../header_files/uartAsync.h"
#include "../header_files/lcdOyola.h"

#define RxPtr   R11

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFF0h    
        DW      CHAR_Rx
        
        ORG     0x02c00
Rx      DS8     16          
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        call    #INITS_LCD
        call    #INIT_UART
        mov.w   #Rx,RxPtr
        
        eint
 
        
        jmp     $
        nop

///////////////////////////////////////////////////////////////////////////////
// Char Received through UART ISR
//////////////////////////////////////////////////////////////////////////////
CHAR_Rx mov.b   UCA0RXBUF, 0(RxPtr)
        inc     RxPtr
        cmp.b   #'`', UCA0RXBUF
        jz      CallLineW
        bic.b   #UCRXIFG,&UCA0IFG            
        reti
CallLineW  mov.b  #001h, R6             ;Clear Display
           CALL   #CMDWR                     ;Enable LCD  

        mov.w   #Rx,DATA_ARG
        call    #LNWR
        bic.b   #UCRXIFG,&UCA0IFG
        mov.w   #Rx,RxPtr
        reti 
        
        
        END