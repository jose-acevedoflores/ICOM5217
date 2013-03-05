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
#define DIVISOR     R5
#define DIVCNT      R9


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
        
Stay    eint                            ; Enable interrupts
        nop
        jmp      $
ModProc call    #FORMNUM                ; Get random number
        mov.w   #0x0ffff,DELAY_ARG      
        call    #DELAY                  ; Perform a small delay
        bic.b   #BIT7, P2IFG            ; Clear flag after delay to eliminate bouncing
        jmp     Stay                    ; Return to continous loop

       
       
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
//Here we already have a timer generated value (RANDVAL R7) 
FORMNUM nop

        mov.b   #0x01, COM_ARGS         ; Clear LCD command 
        call    #WRITECOM               ; Clear LCD
        call    #WRITESTR               ; Write the String at ToWrite
        bic.w   #0x0ff00,RANDVAL        ; Discard the 8 most significant bits 
        call    #MOD10                  ; Obtain residue of RANDVAL
        
        add.b   #48,RANDVAL             ; Convert to ASCII character
        mov.b   RANDVAL, DATA_ARGS      ; Put number to be written to LCD
        call    #WRITECHAR              ; Write number into LCD
        ret
/*------------------------------------------------------------------------------------------*/    
//////////////////////////////////////////////////////////////////////////////
// Modulus 10 subroutine
// Parameters: RANDVAL (R7): Number to divide, dividend
//             DIVISOR (R5): Number that divides the dividend
// Result:     RANDVAL (R7): Residue of randval/divisor
//////////////////////////////////////////////////////////////////////////////

MOD10:  nop
        mov.b   #10,DIVISOR     ; Initialize divisor in 10
        push.b  RANDVAL
        sub.w   DIVISOR,RANDVAL ; Check if divisor is larger than randval
        jlo     endDv1          ; Place result as 0
        
        pop.b   RANDVAL
dvStrt: add.w   #10,DIVISOR     ; Multiply divisor
        push.b  RANDVAL
        sub.w   DIVISOR,RANDVAL ; Check if RANDVAL > DIVISOR
        jlo     endDv           ; If not, end division and return residue
        pop.b   RANDVAL
        jge     dvStrt          ; Else, continue multiplying

endDv1: mov.w   #0,RANDVAL      ; Put 0 residue on RANDVAL
        jmp     endDv2          ; Return           
        
endDv:  pop     RANDVAL
        bic.w   #0x0FF00,RANDVAL
        sub.w   #0x000A,DIVISOR ; Subtract 10 from divisor
        sub.w   DIVISOR,RANDVAL ; Get residue
endDv2: ret

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

               
ToWrite DB      'Random Value: ^'
             
        END
 
 