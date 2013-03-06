#include "msp430.h"                     ; #define controlled include file
#include "../header_files/lcd.h"
#include "../header_files/util.h"
#include  "timer.h"
#define STATUS    R7
    
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
        
        
        ORG     0x0FFDE
        DW      BPIR                    ; Init interrupt vector for button (P1.6 Track A and P1.7 Track B)
        
        ORG     0x02c00
DIR     DB      0                       ; Place in ram to store the current direction (Forward = 1 or backward= 0 )        
INTID   DB      0                       ; Place in ram to store the interrupt id (if it's the first or second)
REVTIME DW      0
RPMRES  DW      0
TEMPC   DW      0
EVEN
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        call    #InitPort               ; Initialize ports
        call    #INIT_LCD               ; Initialize LCD
        call    #InitTimer
        clr.b     STATUS
        clr.b     DIR
        clr.b     INTID
        
        mov.w   #SpeedLabel, STR
        call    #WRITESTR
        
loop    eint                             ; Infinite loop for waiting interrupt
        jmp loop
///////////////////////////////////////////////////////////////////////////////
LookUPT mov.w   #JMPTABL, R5
        add.w   STATUS, R5              
        mov.b   @R5, R5                 ; Save LUT value in R5
        cmp.b   #00000001b, R5          ; check if the look up table returned 1
        jz      FORWARD                 ; CCW
        cmp.b   #00000010b, R5          ; check if the look up table returned 2
        jz      BACKWARD                ; CW
        
RPMCODE mov.w   #2560,Dividend         ; CalculateRPM
        mov.w   REVTIME, Divisor
        call    #DIV1
        mov.w   Result,REVTIME
        
        mov.b       #0x87,COM_ARGS		; Start editing RPM number
        call        #WRITECOM		; 
        
        call    #DisplayRPM
        
        mov.w   #RPMLabel, STR
        call    #WRITESTR
        jmp     loop

FORWARD cmp.b   #1, DIR
        jz      loop
        mov.b   #1, DIR
        mov.b   #0xC0,COM_ARGS		; New Line
        call    #WRITECOM		; 
        mov.w   #ForwardLabel, STR
        call    #WRITESTR
        jmp     RPMCODE
        
BACKWARD cmp.b  #0,DIR
         jz     loop 
         mov.b  #0,DIR
         mov.b  #0xC0,COM_ARGS		; New Line
         call   #WRITECOM		; 
         mov.w  #BackwardLabel,STR
         call   #WRITESTR
         jmp    RPMCODE
///////////////////////////////////////////////////////////////////////////////
//Light Interrupt Service Routine
///////////////////////////////////////////////////////////////////////////////        
BPIR    push.w  R5                      ; Save R5 to use it as a temp variable
        cmp.b   #1,INTID                ; Check if this is the first edge interrupt
        jnz     SaveTim                ; If it is, go to Save timer and exit ISR
        mov.w   TA0R, R5                ; If it's not then save timer 
        sub.b   REVTIME,R5              ; Substract Last value from the first one saved
        mov.w   R5, REVTIME             ; Move the result of the subtraction to REVTIME 
        clr.b   INTID                   ; Clear interrupt id
        
Some    bit.b   #BIT7,P1IFG 	        ; check if 1.7  generated the flag
        jnz     TOG7
        bit.b   #BIT6,P1IFG 	        ; check if 1.6 generated the flag
        jnz     TOG6
        jmp     GOBACK          	; Something else generated the interrupt

SaveTim mov.w   TA0R,REVTIME            ; Save First value of the timer
        inc.b   INTID                   ; Increment Interrupt ID 
        jmp     Some
        
TOG7    xor.b   #BIT7,P1IES  
        jmp     Rotate
TOG6    xor.b   #BIT6, P1IES
        
Rotate  push.b  P1IN
        mov.w   STATUS,R5               ; Save status in R5
        rla.b   R5
        rla.b   R5                      ; Rotate Bnew to Bold position and Anew to Aold
        bic.b   #11110011b,R5           ; set all bits to zero except Bold and Aold
        bic.b   #00001100b, STATUS      ; Clear Bold and Aold in STATUS
        add.b   R5,STATUS               ; Move Bnew to Bold and Anew to Aold in Status 
        pop     R5
        bic.b   #00111111b,R5           ; Clear all PINs except PIN1.7 and P1.6
        rla.b   R5                      ; xx000000 -> x0000000 C = x
        rlc.b   R5                      ; x0000000 -> 0000000x C = x
        rlc.b   R5                      ; xx000000 -> 000000xx move PIN1.7 to Bnew position
        bic.b   #00000011b,STATUS       ; Clear Bnew and Anew in status
        add.b   R5,STATUS               ; Save P1.7 IN in Anew and P1.6 in Bnew 
        bic.b   #BIT7+BIT6, P1IFG       ; Clear Interrupt flag
        pop     R5                      ; Recuperate R5 contents
        cmp.b   #1,INTID
        jz      NOUP8  
        
GOBACK  mov.w   #LookUPT, 2(SP)   	; Modify the new return address
        bic.b   #GIE, 0(SP)             ; Disale interrupts 
        clr     STATUS
        reti        

NOUP8   reti

///////////////////////////////////////////////////////////////////////////////
// Initialize port functions 
///////////////////////////////////////////////////////////////////////////////
InitPort nop
        mov.b   #0x0FF, P10DIR       ; Set P10 as output for LCD Data lines
        mov.b   #0x0FF, P8DIR        ; Set P8 as output for P8.5 and P8.6 ENABLE and RS lines
        bic.b   #BIT7+BIT6, P1DIR       ; Set P1.6 and P1.7 as inputs
        bis.b   #BIT7+BIT6, P1IE        ; Enable interrupt for P1.6 and P1.7
        bic.b   #BIT7+BIT6, P1IES       ; Set P1.4 and P1.7 to generate an interrupt in a High To Low transition
        ret
///////////////////////////////////////////////////////////////////////////////
//RPM formatting function
///////////////////////////////////////////////////////////////////////////////
DisplayRPM      nop
        mov.w   #10,Divisor
        mov.w   REVTIME,Dividend
        clr     TEMPC
EXTRACT_DIGIT      call    #DIV1
        push.w  Remainder
        inc.w   TEMPC
        mov.w   Result,Dividend
        cmp.w   #0,Result
        jnz     EXTRACT_DIGIT  
        
DISPLAY_DIGIT        pop     DATA_ARGS               ; Restore a digit in the correct order
        bis.b   #00110000b,DATA_ARGS    ; Add ASCII format
        call    #WRITECHAR 
        dec.w   TEMPC
        jnz     DISPLAY_DIGIT 
        ret

JMPTABL DB      0,1,2,0,2,0,0,1,1,0,0,2,0,2,1,0 
ForwardLabel  DB     'Forward ^'
BackwardLabel DB     'Backward ^'
SpeedLabel    DB     'Speed =^'
RPMLabel      DB     ' RPM^'     
        END