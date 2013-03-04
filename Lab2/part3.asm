#include "msp430.h"                     ; #define controlled include file
E_HIGH  EQU     00100000b               ; Used with bis.b to Set bit 5 of port 8 (P8.5) to 1. This is done to call E_LOW and trigger the falling edge 
E_LOW   EQU     00100000b               ; Used with bic.b to set bit 5 of port 8 (P8.5) to 0. 
COMMAND EQU     01000000b               ; Used with bic.b to set bit 6 of port 8 (P8.6) to 0. This tells the LCD controller that a command will be sent
DATA    EQU     01000000b               ; Used with bis.b to set bit 6 of port 8 (P8.6) to 1. This tells the LCD controller that data will be sent

P1_7    EQU     10000000b               ; 
P1_6	EQU	01000000b

#define LCDDB   P10OUT                  ; Name Port P10 as LCDDB (LCD Data Bus) to facilitate code reading.
#define E       P8OUT                   ; Name Port P8.5 as E (enable ) 
#define D_C     P8OUT                   ; Name Port P8.6 as D_C (Data or Command)

#define DELAY_ARG   R5
#define COM_ARGS    R8
#define DATA_ARGS   R9
#define COUNTER     R10
#define UNITS	    R6
#define TENS	    R7
#define PUSH_FLAG   R11

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        ORG     0FFDEh
        DW      ISR

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        mov.b   #0x0FF, P10DIR          ; Set P10 as output (LCDDB)
        mov.b   #0x0FF, P8DIR           ; Set P8 as output      (E and RS)
        bic.b   #P1_7+P1_6, P1DIR       ; Set P1.7 and P1_6 as input
        bis.b   #P1_7+P1_6, P1IE
        bis.b   #P1_7+P1_6, P1IES
        clr     COUNTER      
	    clr	PUSH_FLAG
        call    #INIT_LCD
        eint
        jmp     SLEEP
        
WriteLCD        nop
        mov.b       #0x01,COM_ARGS		; Clear LCD
        call        #WRITECOM	
        
        mov.w   COUNTER, DATA_ARGS
        call    #BIN2BCD                    ; Convert Counter to BCD to access the two digits individually        
        
  
       	mov.b   TENS, DATA_ARGS
        call    #WRITECHAR
               
      	mov.b   UNITS, DATA_ARGS
        call    #WRITECHAR
        
SLEEP   nop
	    bit.b	#1,PUSH_FLAG
        jnc     SLEEP 			       ; If PUSH_FLAG is not zero the button was not pressed so keep looping
	
	    mov.w   #0x0FFFF, DELAY_ARG    ; Software Delay Debounce
        call    #DELAY
        bit.b   #4,PUSH_FLAG            ; Decrement
        jc      D
	    inc     COUNTER                 ; If the push button generated the interrupt increment COUNTER
	    jmp     RE
D       dec	COUNTER
	
RE      mov.b   #0,PUSH_FLAG
	    jmp	WriteLCD

; Initialize LCD function                      
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

;Uses Register R5 as Delay counter
DELAY   nop
DLOOP   dec.w   R5
        jnz     DLOOP
        ret
; ISR for the push button        
ISR     bit.b   #P1_7, P1IFG            ; Check if P1.7 button generated the interrupt
        jc     	INCREMENT			
	    bit.b	#P1_6, P1IFG		; Check if P1.6 button generated the interrupt
	    jc	DECREMENT
	    jmp	GOBACK			; Neither P1_7 or P1_6 generated the interrupt
INCREMENT nop
	    bis.b	#3,PUSH_FLAG
        bic.b   #P1_7, P1IFG            ; REset port interrupt flag     
	    jmp	GOBACK
DECREMENT nop
	bis.b   #5,PUSH_FLAG
	bic.b   #P1_6, P1IFG
	
GOBACK  nop
	    reti

; Binary to BCD function
BIN2BCD    push.w R15                   ;R15 being used as counter
	   push.w DATA_ARGS			
           mov  #8,R15                  ; Initialize counter
       	   clr  UNITS                   ; initialize result to 0.
Conv       rla.b  DATA_ARGS             ; capture msb by rotating
           dadd UNITS,UNITS             ; Decimal  2X+bit
       	   dec R15                      ; repeat
           jnz Conv                     ; until all bits considered
	   
	   push.w	UNITS		; save UNITS
	   mov  #4,R15			; Initialize counter
	   clr TENS			; clear TENS register
Shift      rla.b UNITS			; capture msb by rotating
	   rlc.b TENS			; save msb in TENS
	   dec R15			
	   jnz Shift			; Do this four times
	   pop UNITS 			; Recover UNITS
	   
   ; Prep UNITS and TENS to be readable by the LCD
	   bic.b #11110000b, UNITS	; Clear upper part (this part is the TENS)
	   bis.b #00110000b, UNITS	; Add upper part that enables the numbers to be displayed in the LCD
	   
	   bis.b #00110000b, TENS	; Add upper part that enables the numbers to be displayed in the LCD
	   
	   pop DATA_ARGS
           pop R15                         ; Recover R15   
           ret                             ;return to caller. 	
	
        END
