;------------------------------------------------------------------------------
#include "msp430.h"                     ; #define controlled include file            
;------------------------------------------------------------------------------
            ORG  05400h                 ; Program Start           
;------------------------------------------------------------------------------
RESET      mov.w  #04400h,SP                 ; Initialize Stackpointer
STOPWDT    MOV.W  #WDTPW+WDTHOLD,&WDTCTL     ; Stop Watchdog Timer
        
           BIC.b  #01b, &P1DIR                ;Set P1.0 for reed switch interrupt
           BIS.b  #01100000b, &P1DIR         ;Set P1.5 1.6 for buzzer output
           BIC.b  #0100000b, &P1OUT; 
           bis.w  #SELA_2,&UCSCTL4         ; Set ACLK source as Real-Time-CLK
           bis.w  #TASSEL_1+ID_0+MC_1,&TA0CTL  ; Set prescaler to div by 8
          ;bis.w  #TAIDEX_0,&TA0EX0            ; Set ext. prescaler to div by 1
           bis.w  #0,&TA0CCR0
          
           bis.w  #CCIE, &TA0CCTL0          ;Enable Timer interrupt
          
           
           bis.b  #01b, &P1IE           ;Enable interrupts for P1.0 
           bis.b  #01b, &P1IES         ;Set Interrupt Edge select for H->L
           EINT 
          
Finish     jmp $
;------------------------------------------------------------------------------
;               Reed Sensor Subroutine
;------------------------------------------------------------------------------ 
REEDISR    mov.b &P1IN, R5
           and.b #0000001b, R5
           CMP.b #0, R5          ;Check reed sensor status
           JZ   LIDOPEN                 ;TRUST
LIDCLOSE   mov.w  #0,&TA0CCR0         ;Halt buzzer
           BIC.b  #0100000b, &P1OUT
           jmp Finish2
LIDOPEN    mov.w #15,&TA0CCR0         ;Trigger buzzer 
           MOV.b #0, R7
Finish2    xor.b  #01b, &P1IES         ;Toggle Interrupt Edge select
           BIC.b  #01b, &P1IFG
           reti         
;------------------------------------------------------------------------------
;               Buzzer Subroutine
;------------------------------------------------------------------------------ 
BUZISR     xor.b #01000000b, &P1OUT     ;Toggle buzzer
           INC  R7
           CMP.w #1024, R7
           JNZ  Finish3
           xor.b #0100000b, &P1OUT     ;Toggle LED
           CLR R7
Finish3    BIC.w  #01b, &TA0CCTL0            ;
           reti;

;------------------------------------------------------------------------------
;               Wait Subroutine
;------------------------------------------------------------------------------ 
WAITS     mov.w #2000, R6
L2        DEC R6
          jnz L2     
          ret;
;------------------------------------------------------------------------------
;               Interrupt Vectors
;------------------------------------------------------------------------------
            ORG  0FFFEh                 ; MSP430F5438 Reset Vector
            DW   RESET                  ;
            ORG  0FFDEh                 ;Port 1 Interrupt Vector
            DW   REEDISR
            ORG  0FFEAh                 ;TA0 CCR0
            DW   BUZISR
            END                         ;