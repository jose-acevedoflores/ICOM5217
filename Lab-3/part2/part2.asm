#include "msp430.h"                     ; #define controlled include file

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0x0FFEC                 
        DC16    timer                   ; Set timer ISR

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer

        bis.b   #BIT5,P8DIR             ; Set P8.5 as output for buzzer
        bis.b   #BIT5,P8OUT             ; Send high signal to buzzer
        
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; AMCLK source (8KHz), Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL0                ; Enable interrupt for timer on compare
        bis.w   #1, &TA0CCR0                    ; Count up to 1 (because frequency is already 1024Hz)
        eint                                    ; Enable interrupts
        
loop:   nop                             ; Infinite loop for waiting interrupt
        jmp loop
        
///////////////////////////////////////////////////////////////////////////////
// Timer Interrupt Service Routine
///////////////////////////////////////////////////////////////////////////////

timer:  nop
        xor.b   #BIT5,P8OUT             ; Switch bit for the square signal being output to buzzer
        bic.w   #BIT0,TA0CTL            ; Clear interrupt flag
        reti
                                                
        END
        