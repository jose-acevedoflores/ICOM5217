#include "msp430.h"                     ; #define controlled include file
E_HIGH  EQU     00100000b               ; Used with bis.b to Set bit 5 of port 8 (P8.5) to 1. This is done to call E_LOW and trigger the falling edge 
E_LOW   EQU     00100000b               ; Used with bic.b to set bit 5 of port 8 (P8.5) to 0. 
COMMAND EQU     01000000b               ; Used with bic.b to set bit 6 of port 8 (P8.6) to 0. This tells the LCD controller that a command will be sent
DATA    EQU     01000000b               ; Used with bis.b to set bit 6 of port 8 (P8.6) to 1. This tells the LCD controller that data will be sent

#define LCDDB   P10OUT                  ; Name Port P10 as LCDDB (LCD Data Bus) to facilitate code reading.
#define E       P8OUT                   ; Name Port P8.5 as E (enable ) 
#define D_C     P8OUT                   ; Name Port P8.6 as D_C (Data or Command)

#define DELAY_ARG   R5
#define COM_ARGS    R8
#define DATA_ARGS   R9
#define L1        R10
#define L2        R11 
#define PREV      R12
#define STATUS    R7

;Set data segment
        ORG     0x02C00
ARR     DS16    17      ; Store 17 places to serve as pointers to the first letters of the TOPRINT data segment
ENDAD	DC16	0	; Reserve a place to store the END ADDRESS of the array
STARTAD	DC16	0	; Reserve a place to store the START ADDRESS of the array
;#define STARTAD R7

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0x0FFDE
        DW      BPIR                    ; Init interrupt vector for button (P1.6 Track A and P1.7 Track B)
        
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        mov.b   #0x0FF, P10DIR          ; Set P10 as output
        mov.b   #0x0FF, P8DIR           ; Set P8 as output
        
        bic.b   #BIT7+BIT6, P1DIR       ; Set P1.6 and P1.7 as inputs
        bis.b   #BIT7+BIT6, P1IE        ; Enable interrupt for P1.6 and P1.7
        bic.b   #BIT7+BIT6, P1IES       ; Set P1.4 and P1.7 to generate an interrupt in a High To Low transition
        clr     STATUS
        
; Initialize some key address values
	mov.w	#ARR, STARTAD
	add.w	#32, STARTAD		; Add 32 to force R5 to be the last element in the array ';' in this case
	mov.w	STARTAD, ENDAD 		; Store the END ADDRESS for later use
	mov.w	#ARR, STARTAD		; Store the START ADDRESS for later use
	
        call    #INITARR
        call    #INIT_LCD
        
; Initializing word pointers
	mov.w	STARTAD, PREV	; Initialize previous pointer to the first word in the array
	mov.w	STARTAD, R5	; Store the START ADDRESS in R5 to add ab offset and start from a different location
	add	#2,R5	
       	mov.w	R5, L1		; Initialize L1 to the second word in the array
	add	#2,R5
	mov.w	R5, L2		; Initialize L2 to the third word in the array
	
        jmp     FIN	
        
;LCD Writting portion
WriteToLCD      nop
LINE1   push.w 	L1			; Save L1 word pointer in the stack
	mov.w	@L1, L1 		; Take the data pointed by L1 (first letter to the word) and Store that address in L1 for printing
LINE1X	mov.b   @L1+, DATA_ARGS    	; Use L1 as pointer to the letters in the word
        cmp     #'^', DATA_ARGS
        jz      LINE2
        call    #WRITECHAR
        jmp     LINE1X
          
LINE2   mov.b   #0xC0, COM_ARGS 	;Move cursor to 2'nd line
        call    #WRITECOM
	pop	L1			; Recuparate L1 word pointer 
	push.w	L2			; Save L2 word pointer in the stack 
	mov.w	@L2,L2			; Take the data pointed by L2 (first letter to the word) and Store that address in L2 for printing 
LINE2X  mov.b   @L2+, DATA_ARGS 	; Use L2 as pointer to the letters in the word
        cmp     #'^', DATA_ARGS		
        jz      RECU			; Jump to recuperate our L2 word pointer 
        call    #WRITECHAR      
        jmp     LINE2X
RECU	pop	L2			; Recuparate L2 word pointer        	

;Looping wait part
FIN     nop
        eint                            ; enable interrupts
        jmp     $

LookUPT mov.w   #JMPTABL, R5
        add.w   STATUS, R5              
        mov.b   @R5, R5                 ; Save LUT value in R5
        cmp.b   #00000001b, R5          ; check if the look up table returned 1
        jz      UP                      ; CCW
        cmp.b   #00000010b, R5          ; check if the look up table returned 2
        jz      DOWN                    ; CW
        jmp     FIN
;End 

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

;Up and Down scrolling
UP      mov.b   #0x01,COM_ARGS      	;Clear LCD
        call    #WRITECOM    
	
	add	#2, PREV		; Increment PREV	
	add	#2, L1			; Increment L1
	add	#2, L2			; Increment L2	
	cmp	ENDAD, PREV		; Check if PREV went over the END ADDRESS
	jz	SETPREVLOW	        ; If zero PREV is at the END ADDRESS, go to SETPREVLOW to set PREV to the START ADDRESS
	cmp	ENDAD, L1		; Check if L1 went over the END ADDRESS
	jz	SETL1LOW		; If zero L1 is at the END ADDRESS, go to SETL1LOW to set L1 to the START ADDRESS
	cmp	ENDAD, L2		; Check if L2 went over the END ADDRESS
	jz	SETL2LOW		; If zero L2 is at the END ADDRESS, go to SETL2LOW to set L2 to the START ADDRESS	
	
        jmp     WriteToLCD
        
DOWN    mov.b   #0x01,COM_ARGS      	; Clear LCD
        call    #WRITECOM    

	sub	#2, PREV		; Decrement PREV	
	sub	#2, L1			; Decrement L1
	sub	#2, L2			; Decrement L2	
	cmp	PREV, STARTAD		; Check if PREV went below the START ADDRESS
	jnz	SETPREVHIGH	        ; If zero PREV is at the START ADDRESS, go to SETPREVHIGH to set PREV to the END ADDRESS
NOCarr	cmp	L1, STARTAD		; Check if L1 went below the START ADDRESS
	jnz	SETL1HIGH		; If zero L1 is at the START ADDRESS, go to SETL1HIGH to set L1 to the END ADDRESS
NOCarr2	cmp	L2, STARTAD		; Check if L2 went below the END ADDRESS
	jnz	SETL2HIGH		; If zero L2 is at the START ADDRESS, go to SETL2HIGH to set L2 to the END ADDRESS	
       
        jmp     WriteToLCD
        
SETPREVLOW	mov.w   STARTAD,PREV
	jmp	WriteToLCD
SETL1LOW        mov.w   STARTAD,L1
	jmp	WriteToLCD
SETL2LOW        mov.w   STARTAD,L2
	jmp	WriteToLCD

SETPREVHIGH	jnc      NOCarr 
        mov.w   ENDAD,PREV             ; If we get here then STARTAD > PREV c= 1 z = 0
        sub     #2,PREV                ; Save END ADDRESS in PREV, then substract 2. This is done because ENDAD = ';' (The last element)
        jmp	WriteToLCD                 ; After substracting now prev will point to 
	
SETL1HIGH       jnc      NOCarr2   
        mov.w   ENDAD,L1                ; If we get here then STARTAD > L1 c= 1 z = 0
        sub.w   #2,L1                   ; Save END ADDRESS in L1, then substract 2. This is done because ENDAD = ';' (The last element) 
	jmp	WriteToLCD
        
SETL2HIGH       jnc      WriteToLCD         
        mov.w   ENDAD,L2                ; If we get here then STARTAD > L2 c= 1 z = 0 
        sub.w   #2,L2                   ; Save END ADDRESS in L2, then substract 2. This is done because ENDAD = ';' (The last element) 
	jmp	WriteToLCD
               

;Light received interrupt    
BPIR    push.w    R5                      ; Save R5 to use it as a temp variable
        ;mov.b   P1IN, R5
        ;push.w    R5
        bit.b   #BIT7,P1IFG 	        ; check if 1.7  generated the flag
     ;   jnz     TrakB                 	; Button 1.7 was pressed if bit test returns 1
        jnz     TOG7
        bit.b   #BIT6,P1IFG 	        ; check if 1.6 generated the flag
      ;  jnz     TrakA                	; Button 1.6 was pressed if bit test returns 1
        jnz     TOG6
        ;jmp     GOBACK          	; Something else generated the interrupt
        
TOG7    xor.b   #BIT7,P1IES  
        jmp     TrakB
TOG6    xor.b     #BIT6, P1IES
        
TrakB   nop
        mov.w   STATUS,R5               ; Save status in R5
        rla.b   R5
        rla.b   R5                      ; Rotate Bnew to Bold position
        bic.b   #11111011b,R5           ; set all bits to zero except Bold
        ;bic.b   #00000100b, STATUS      ; Clear Bold in STATUS 
        bic.b   #00000100b, STATUS      ; Clear Bold in STATUS
        add.b   R5,STATUS               ; Move Bnew to Bold
        ;pop     R5                      ; Save PIN in R5
        ;mov.b   P1IES,R5
        mov.b   P1IN,R5
        ;xor.b   #BIT7, R5
        bic.b   #01111111b,R5           ; Clear all PINs except PIN1.7
        rla.b   R5
        rlc.b   R5                      ; x0000000 -> 0000000x move PIN1.7 to Bnew position
        bic.b   #00000001b,STATUS       ; Clear Bnew 
        add.b   R5,STATUS               ; Save P1.7 IN in Bnew
        bic.b   #BIT7, P1IFG            ; Clear Interrupt flag
        
TrakA   nop
        mov.w   STATUS,R5               ; Save status in R5
        rla.b   R5
        rla.b   R5                      ; Rotate Anew to Aold position
        bic.b   #11110111b,R5           ; set all bits to zero except Aold
        ;bic.b   #00001000b, STATUS      ; Clear Aold in STATUS 
        bic.b   #00001000b, STATUS      ; Clear Aold in STATUS 
        add.b   R5,STATUS               ; Move Anew to Aold
        ;pop     R5                      ; Save PIN in R5
        ;mov.b   P1IES,R5
        mov.b   P1IN,R5
        ;xor.b   #BIT6, R5
        bic.b   #10111111b,R5           ; Clear all PINs except PIN1.6
        rla.b   R5                      ; 0x000000 -> x0000000 move PIN1.6 to Anew position
        rla.b   R5
        rlc.b   R5                      ; x0000000 -> 0000000x
        rla.b   R5                      ; 0000000x -> 000000x0
        bic.b   #00000010b,STATUS       ; Clear Anew 
        add.b     R5,STATUS               ; Save PIN1.6 in Anew 
        bic.b   #BIT6, P1IFG            ; Clear Interrupt flag

GOBACK  pop     R5                      ; Recuperate R5 contents
        mov.w   #LookUPT, 2(SP)   	    ; Modify the new return address
        bic.b   #GIE, 0(SP)             ; Disale interrupts 
        reti
      
;Array Initialization function
INITARR mov.w   #TOPRINT, R13        	; R13 will serve as pointer to letters in TOPRINT
        mov.w   #ARR,R14                ; R14 holds the RAM direction
NWORD   mov.w   R13, 0(R14)
        add.w   #2, R14
KEEP    mov.b   @R13+, DATA_ARGS    	; Use ?DPTR as pointer to the data
        cmp     #'^', DATA_ARGS         ; Word end
        jnz     KEEP
        
        cmp.b   #';', 0(R13)       	; Array end
        jz      ARRINITIALIZED
        jmp     NWORD
        
ARRINITIALIZED nop
        mov.w    R13,0(R14) 		;Last ';' Character
        ret
        
TOPRINT DB      'Hello^World^Test^OMGGGG^HORY SHET^k ase^o k ase^son las 2am^me^canse^y tengo^hambre^y tu?^:P^:D^ultima^;'          
JMPTABL DB      0,1,2,0,2,0,0,1,1,0,0,2,0,2,1,0
        END





