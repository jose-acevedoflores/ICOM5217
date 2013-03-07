#include "msp430.h"                     ; #define controlled include file

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
        
        bis.b   #BIT5,P8DIR             ; Set P8.5 as output for buzzer
        bis.b   #BIT5,P8OUT             ; Send high signal to buzzer
        bis.b   #BIT0,P1DIR             ; Set P1.0 as output for LED
        bis.b   #BIT0,P1OUT             ; Turn LED on
        
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer source to ACLK (8KHz), count mode up and divide freq. by 8
        mov.w   #1, &TA0CCR0                    ; Count up to 1 (since frequency is already set to 1 KHz)
        
poll:   bit.w   #TAIFG, &TA0CTL         ; Check if overflow ocurred (timer interrupt flag)
        jz      poll

toggle: xor.b   #BIT5,P8OUT             ; Switch bit for the square signal being output to buzzer
        bic.w   #TAIFG, &TA0CTL         ; Clear timer interrupt flag
        jmp     poll
      
        nop
        END
       