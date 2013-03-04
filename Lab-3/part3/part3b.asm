#include "msp430.h"   
#include "lcd.h"
#include "game.h"
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
        
Stay    eint       
        jmp      $
Start   call    #GetRand
        mov.w   #0x0ffff,DELAY_ARG
        call    #DELAY                  
        call    #StartGame
        bic.b   #BIT7+BIT6, P2IFG            ;Clear flag after delay to eliminate bouncing
        jmp     Stay
        
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
//Here we already have a timer generated value (RANDVAL R7) 
GetRand nop
        
        bic.w   #0x0ff00, RANDVAL       ; Discard the 8 most significant bits 
//        call    #DIV10
//temp
        bic.b   #11110000b,RANDVAL
        bis.b   #00110000b, RANDVAL
//temp

        ret
/*------------------------------------------------------------------------------------------*/    
/*------------------------------------------Divition by ten ----------------------------------------*/  
DIV10   nop
        push.w    R5
        cmp.b   #10, RANDVAL    ; Check if RANFVAL is bigger than 10
        jnc     DIVend          ; If it is, end division
        
        mov.b   #10,R5          ; Load R5 with dividend 10
        
Rot10   rla.b   R5              ; Rotate R5 left
        cmp.b   R5,RANDVAL      ; Check if RandVal is still bigger than R5
        jnc     Rot10           ; If it's not, keep rotating
        
        
        
DIVend  pop     R5
        ret
/*----------------------------------------------------- ----------------------------------------*/  


///////////////////////////////////////////////////////////////////////////////////////
//ISR Section
///////////////////////////////////////////////////////////////////////////////////////

/*------------------------------------------Button Press ISR ----------------------------------------*/    
Button  nop      
        
        bit.b   #BIT7,P2IFG      ; Check if P2.7 is pressed
        jc      CheckButton2  
        mov.w   #0x0ffff,DELAY_ARG
        call    #DELAY          ; Delay a bit to allow the detection of the two button press
        bit.b   #BIT6,P2IFG      ; Check if P2.6 is pressed
        jc      DOWN
        
CheckButton2 nop
        bit.b   #BIT6,P2IFG      ; Check if P2.6 is pressed
        jnc     UP              ; If P2.6 is not pressed, UP counter( only P2.7 is pressed)
        //Both buttons pressed, take random value
        mov.w   TA0R, RANDVAL   ; read the timer counter register
        mov.w   #Start, 2(SP)   ; jump to start game
        bic.w   #GIE,0(SP)      
        reti
        
        
UP      inc.b   USRCOUNT        
        mov.w   #UP8LCD, 2(SP)
        bic.w   #GIE,0(SP)   
        reti
DOWN    dec.b   USRCOUNT        
        mov.w   #UP8LCD, 2(SP)
        bic.w   #GIE,0(SP)   
        reti        
/*------------------------------------------Button Press ISR ----------------------------------------*/    

              
        
        END
 
 