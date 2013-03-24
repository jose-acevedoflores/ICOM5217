#include "msp430.h"                     ; #define controlled include file
#include "../header_files/uartAsync.h"
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFF0h    
        DW      UART_ISR
        
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        
        call    #INIT_UART
     
        mov.b   #'J', ToSend
        eint
       ; call    #SendData
        mov.w   #LineToPrint,STR
        call    #PrintLine
        
        jmp     $
        nop
        END