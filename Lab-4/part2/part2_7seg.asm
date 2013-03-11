#include "msp430.h"                     ; #define controlled include file
#include  "7seg.h"  
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
       

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        bis.b   #BIT6,P8DIR
        bis.b   #BIT6,P8OUT
        mov.b   #0x0ff, P10DIR  ; Set p10 as output
        mov.b    #2, NUMA
        call    #ChNumA

        bic.b   #BIT6,P8OUT             ; Enable Digit 1
       

        
        
         jmp     $
        nop
        
        END