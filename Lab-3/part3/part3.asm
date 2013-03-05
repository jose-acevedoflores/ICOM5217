#include "msp430.h"
#include "../header_files/lcd.h"
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
 
/*-------------------------------------------------- -------------------------------------------*/      
     
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
        mov.w   #ToWrite, STR
        call    #WRITESTR               ; Write the String at STR
        bic.w   #0x0ff00,RANDVAL        ; Discard the 8 most significant bits 
        call    #MOD10                  ; Obtain residue of RANDVAL
        
        add.b   #48,RANDVAL             ; Convert to ASCII character
        mov.b   RANDVAL, DATA_ARGS      ; Put number to be written to LCD
        call    #WRITECHAR              ; Write number into LCD
        ret
/*------------------------------------------------------------------------------------------*/    


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
 
 