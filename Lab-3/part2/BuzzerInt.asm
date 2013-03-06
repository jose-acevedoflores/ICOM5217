;------------------------------------------------------------------------------
#include "msp430.h"                     ; #define controlled include file
            
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFD4h
        DW      Button
        
        ORG     0x0FFEC                 
        DC16    TIMER                   ; Set timer ISR


        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer

           bis.w  #SELA_2,&UCSCTL4         ; Set ACLK source as Real-Time-CLK
           bis.w  #TASSEL_1+ID_0+MC_1,&TA0CTL  ; Set prescaler to div by 8
           ;bis.w  #TAIDEX_0,&TA0EX0            ; Set ext. prescaler to div by 1
           bis.w  #15,&TA0CCR0
           bis.w  #CCIE, &TA0CCTL0      ;Enable Timer interrupt
           bis.b   #BIT5, &P8DIR    ;Set P8.5 as output
           bic.b   #BIT7+BIT6,P2DIR     ; configure P2.7 and P2.6 as input
           bis.b   #BIT7+BIT6,P2IE      ; configure interrupt enable on 
           bis.b   #BIT7+BIT6,P2REN     ; Resistor enable
           bis.b   #BIT7+BIT6,P2OUT     ; Resistor pull up
           bis.b   #BIT7+BIT6, P2IES    ; Interrupt generate on high to low transition 
          
           EINT                              ;
            
F1      nop                               ;

            JMP  F1                       ;
            nop;
  
;------------------------------------------------------------------------------
;          Division Subroutine
;------------------------------------------------------------------------------
DIV10      mov.w &TA0CCR0, R7           ;Store dividend 
           inc R7
           mov.W #0Ah, R8               ;Store divisor
           mov.W #16, R5                ;Store 8 for loop
           CLR  R9                      ;Clear register for remainder
           CLR  R10                     ;Clear register for result
           
DIVLOOP    RLC.w R7                     ;Shift to the left through carry
           RLC.w R9                     ;
           PUSH.W R9                    ;Push temporary remainder
           SUB.w R8, R9
           JN  NEGATIVE
POSITIVE   SETC                         ;Set carry
           POP R14                      ;Trash bin
           JMP CONT
NEGATIVE   POP R9                       ;Pop previous remainder
           CLRC                         ;Clear carry  
CONT       RLC.w R10                    ;Shift result
           
           DEC R5
           JNZ DIVLOOP
           inc R10
           MOV.W R10,&TA0CCR0
FinishDiv  ret  
;------------------------------------------------------------------------------
;          Multiplication Subroutine
;------------------------------------------------------------------------------
MULT10     MOV.W &TA0CCR0,R7
           inc   R7
           MOV.W R7,R10
           RLA.W R7
           RLA.W R7
           RLA.W R7
           RLA.W R10
           ADD.W R7,R10
           dec R10
           MOV.W R10,&TA0CCR0
           ret
           

;------------------------------------------------------------------------------
;               Button Interrupt Service Routine
;------------------------------------------------------------------------------
Button     BIT.b #BIT6, &P2IFG                  ;Check if user wants to decrement
           JC DECButton

INCButton  CALL #DIV10
           ;MOV.W R10,&TA0CCR0                 ; Multiply frequency by 10
           JMP Finish2
           
DECButton  CALL #MULT10
           ;MOV.W R10,&TA0CCR0


Finish2     ;BIS.b  #011b, &P1IE                 ;Enable interrupts of P1
            BIC.b  #BIT7+BIT6, &P2IFG        ; Clear interrupt flags for P2
            
            reti                        ;
;------------------------------------------------------------------------------
;               Interrupt Service Routine
;------------------------------------------------------------------------------
TIMER       XOR.b  #BIT5, &P8OUT         ; Send signal to buzzer
            BIC.w  #01b, &TA0CTL         ; Clear Timer Interrupt flag
            reti                        ;
;------------------------------------------------------------------------------
;               Interrupt Vectors
;------------------------------------------------------------------------------

            END                         ;