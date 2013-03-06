#include "msp430.h"   
#include "../header_files/lcd.h"
#include "../header_files/game.h"
#include "../header_files/util.h"
#define RANDVAL     R7

        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFD4h
        DW      Button
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        clr     USRCOUNT
        clr     NUMTRIES
        
        call    #InitPort
        call    #InitTimer
        call    #INIT_LCD               ; Initialize LCD
        
        call    #WelcomeMsg
        call    #WaitForStart           ; Poll buttons for two simultaneous button presses
        
Start   call    #GetRand             
        call    #StartGame
        bic.b   #BIT7+BIT6, P2IFG            ;Clear flags to eliminate any pending interrupt 
        
Stay    eint       
        jmp      $

        
UP8LCD  call    #UpdateCount  
        bic.b   #BIT7+BIT6, P2IFG            ;Clear flag after delay to eliminate bouncing
        jmp     Stay
       
       
///////////////////////////////////////////////////////////////////////////////////////
//Functions Section
/////////////////////////////////////////////////////////////////////////////////////    
/*------------------------------------------Init timer ----------------------------------------*/    
InitTimer nop
        bis.w   #SELA_2,&UCSCTL4       ; Set AMCLK source to REFOCLOCK
        
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bic.w   #CCIE, &TA0CCTL0                ; Disable interrupt on compare
        bis.w   #0FFFFh, &TA0CCR0                ; Count up to FFFF
        bis.w   #TAIDEX_2, &TA0EX0              ; Divide input signal by 2
        ret
/*--------------------------------------------------------------------------------------------*/    
/*------------------------------------------Init Ports ----------------------------------------*/    

InitPort nop
        mov.b   #0x0FF, P10DIR          ; Set P10 as output for LCD Data lines
        mov.b   #0x0FF, P8DIR           ; Set P8 as output for P8.5 and P8.6 ENABLE and RS lines
        bic.b   #BIT7+BIT6,P2DIR     ; configure P2.7 and P2.6 as input
        bis.b   #BIT7+BIT6,P2IE      ; configure interrupt enable on 
        bis.b   #BIT7+BIT6,P2REN     ; Resistor enable
        bis.b   #BIT7+BIT6,P2OUT     ; Resistor pull up
        bis.b   #BIT7+BIT6, P2IES    ; Interrupt generate on high to low transition
        
        ret
/*------------------------------------------Init Ports ----------------------------------------*/    
/*------------------------------------------Form num ----------------------------------------*/  
GetRand nop      
        mov.w   TA0R, RANDVAL   ; read the timer counter register
        bic.w   #0x0ff00, RANDVAL       ; Discard the 8 most significant bits 
        call    #MOD10
        ret
/*------------------------------------------------------------------------------------------*/   

///////////////////////////////////////////////////////////////////////////////////////
//ISR Section
///////////////////////////////////////////////////////////////////////////////////////

/*------------------------------------------Button Press ISR ----------------------------------------*/    
Button  nop      
        
        bit.b   #BIT7,P2IFG      ; Check if P2.7 is pressed
        jc      UP  
        bit.b   #BIT6,P2IFG      ; Check if P2.6 is pressed
        jc      DOWN
        bic.b   #0FFh, P2IFG    ; Clear the flags that might have generated the interrupt
        reti                     ; Go to main
        
UP      inc.b   USRCOUNT        
        mov.w   #UP8LCD, 2(SP)  ; Move to the PC stored in the stack a new return address
        bic.w   #GIE,0(SP)      ; Disable GIE when returning from this interrupt
        reti                    ; Go to UP8LCD
DOWN    dec.b   USRCOUNT        
        mov.w   #UP8LCD, 2(SP)  ; Move to the PC stored in the stack a new return address
        bic.w   #GIE,0(SP)      ; Disable GIE when returning from this interrupt
        reti                    ; Go to UP8LCD
/*------------------------------------------Button Press ISR ----------------------------------------*/    

              
        
        END
 
 