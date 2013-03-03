#include "msp430.h"                     ; #define controlled include file
#define DELAY_ARGS      R5


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
        
        mov.w   #SELA_2+SELS_2,&UCSCTL4       ; Set SMCLK source to REFOCLOCK
        
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, SMCLK source, Up count operation and divide input signal by 4
        mov.w   #0001h, &TA0CCR0                ; Count up to FFFF
        ;bis.w   #CAP, &TA0CCTL0
        mov.w   #TAIDEX_2, &TA0EX0              ; Divide input signal by 4
        
poll:   bit.w   #CCIFG, &TA0CCTL0         ; Check if overflow ocurred
        jnc     poll
toggle: xor.b   #BIT5,P8OUT
        bic.w   #CCIFG, &TA0CCTL0
        jmp     poll
      
        nop
        END
       