#include "msp430.h"   
E_HIGH  EQU     00100000b               ; Used with bis.b to Set bit 5 of port 8 (P8.5) to 1. This is done to call E_LOW and trigger the falling edge 
E_LOW   EQU     00100000b               ; Used with bic.b to set bit 5 of port 8 (P8.5) to 0. 
COMMAND EQU     01000000b               ; Used with bic.b to set bit 6 of port 8 (P8.6) to 0. This tells the LCD controller that a command will be sent
DATA    EQU     01000000b               ; Used with bis.b to set bit 6 of port 8 (P8.6) to 1. This tells the LCD controller that data will be sent

#define LCDDB   P10OUT                  ; Name Port P10 as LCDDB (LCD Data Bus) to facilitate code reading.
#define E       P8OUT                   ; Name Port P8.5 as E (enable ) 
#define D_C     P8OUT                   ; Name Port P8.6 as D_C (Data or Command)

#define DELAY_ARG   R5
#define STR         R6
#define COM_ARGS    R8
#define DATA_ARGS   R8
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

        mov.b   #0x0FF, P10DIR          ; Set P10 as output for LCD Data lines
        mov.b   #0x0FF, P8DIR           ; Set P8 as output for P8.5 and P8.6 ENABLE and RS lines
        
        call    #InitPort
        call    #InitTimer
        call    #INIT_LCD               ; Initialize LCD
       
Stay    eint       
        jmp      $
ModProc call    #FORMNUM
        mov.w   #0x0ffff,DELAY_ARG
        call    #DELAY                  
        bic.b   #BIT7, P2IFG            ;Clear flag after delay to eliminate bouncing
        jmp     Stay

       
       
///////////////////////////////////////////////////////////////////////////////////////
//Functions Section
/////////////////////////////////////////////////////////////////////////////////////   
 /*------------------------------------------LCD Portion -------------------------------------------*/      
INIT_LCD    nop
            mov.b       #0x01,COM_ARGS		; Clear LCD
            call        #WRITECOM		; 
            mov.b       #0x038, COM_ARGS	; Enable 8 bit / 2 lines
            call        #WRITECOM
            mov.b       #0x0e, COM_ARGS		; Turn on Underline cursor
            call        #WRITECOM
            mov.b       #0x06,COM_ARGS		; Entry Mode 
            call        #WRITECOM
            ret  

;Uses Register R8 to pass command to write.
WRITECOM    nop
            bic.b #COMMAND, D_C         ; Clear bit P8.6 (ready the controller for a command)
            mov.b COM_ARGS, LCDDB       ; Load data to be sent to LCD Controller 
            bis.b #E_HIGH, E            ; Set enable pin P8.5 to high
            mov.w #0x0f00, DELAY_ARG    ; Load delay arguments
            call  #DELAY                ; Call delay to let LCD controller read the high E
            bic.b #E_LOW, E             ; Set Controller Enable (E) to low to trigger falling edge
            ret

;Uses R9 to pass character data
WRITECHAR   nop
            bis.b  #DATA, D_C           ; Set Bit P8.6 (ready the controller for data)
            mov.b  DATA_ARGS, LCDDB     ; Load Data to be sent to LCD Controller
            bis.b  #E_HIGH, E           ; Set Enable pin P8.5 to high
            mov.w  #0x0f00,DELAY_ARG    ; Load delay arguments 
            call   #DELAY               ; Call delay to let LCD controller read the high E
            bic.b  #E_LOW, E            ; Set Controller Enable (E) to low to trigger falling edge
            ret
            
WRITESTR    nop
            mov.w  #ToWrite,STR   ; Use DIR as pointer to String to print
NextChar    mov.b  @STR+, DATA_ARGS
            cmp.b  #'^', DATA_ARGS
            jz     endWS     
            call   #WRITECHAR
            jmp    NextChar
endWS       ret            
/*-------------------------------------------------- -------------------------------------------*/      
 
/*------------------------------------------Delay Function ----------------------------------------*/      
;Uses Register R5 as Delay counter
DELAY   nop
DLOOP   dec.w   R5
        jnz     DLOOP
        ret
/*----------------------------------------------------- ----------------------------------------*/      
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
        bic.b   #BIT7,P2DIR     ; configure P2.7 as input
        bis.b   #BIT7,P2IE      ; configure interrupt enable on 
        bis.b   #BIT7,P2REN     ; Resistor enable
        bis.b   #BIT7,P2OUT     ; Resistor pull up
        bis.b   #BIT7, P2IES    ; Interrupt generate on high to low transition
        ret
/*------------------------------------------Init Ports ----------------------------------------*/    
/*------------------------------------------Form num ----------------------------------------*/  
//Here we already have a tiomer generated value (RANDVAL R7) 
FORMNUM nop
        
         
        mov.b   #0x01, COM_ARGS 
        call    #WRITECOM        ; Clear LCD
        call    #WRITESTR        ; Write the String at ToWrite
        bic.w   #0x0ff00, RANDVAL       ; Discard the 8 most significant bits 
//        call    #DIV10
//temp
        bic.b   #11110000b,RANDVAL
        bis.b   #00110000b, RANDVAL
//temp
        mov.b   RANDVAL, DATA_ARGS
        call    #WRITECHAR
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
        bic.b   #BIT7, P2IFG
        mov.w   TA0R, RANDVAL   ; read the timer counter register
        mov.w   #ModProc, 2(SP)
        bic.w   #GIE,0(SP)
        reti

/*------------------------------------------Button Press ISR ----------------------------------------*/    

               
ToWrite DB      'Random V ^'
             
        END
 
 