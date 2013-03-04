#include "msp430.h"                     ; #define controlled include file
#define DELAY_ARGS      R5


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

        
        bis.w   #SELA_2,&UCSCTL4       ; Set AMCLK source to REFOCLOCK
        
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL0                ; Enable interrupt on compare
        bis.w   #0FFFFh, &TA0CCR0                ; Count up to FFFF
        bis.w   #TAIDEX_2, &TA0EX0              ; Divide input signal by 2
        eint
        
loop:   nop                             ; Infinite loop for waiting interrupt
        jmp loop
        
///////////////////////////////////////////////////////////////////////////////
// Timer Interrupt Service Routine
///////////////////////////////////////////////////////////////////////////////

timer:  nop
        
        bic.w   #BIT0,TA0CTL            ; Clear interrupt flag
        reti
                                                
        END
        