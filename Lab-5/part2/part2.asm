#include "msp430.h"                     ; #define controlled include file
#include "../header_files/uartAsync.h"
#include "../header_files/lcdOyola.h"

#define RxPtr   R11
#define TxPtr   R13
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFF0h    
        DW      CHAR_Rx
        
        ORG     0x02c00
Rx      DS8     16          
Tx      DS8     16

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        call    #INITS_LCD
        call    #INIT_UART
        mov.w   #Rx,RxPtr
        
        eint
 
        
Loop    jmp     $
        nop
ToUpper mov.w   #Tx, TxPtr
        push.w  R5
Cont    mov.b   @RxPtr+, R5
        cmp     #'`', R5
        jz      endU
        bic.b   #BIT5, R5
        mov.b   R5,0(TxPtr)
        inc     TxPtr
        jmp     Cont
endU    pop R5
        mov.w   #Tx, STR
        mov.w   #'`', 0(TxPtr)
        call    #PrintLine
        mov.w   #Rx,RxPtr               ; Reset RxPtr for incoming transmissions
        jmp     Loop 
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
        mov.w   #Rx,RxPtr                ; Reset RxPtr for incoming transmissions
        mov.w   #ToUpper, 2(SP)
        reti 
        
        
        END