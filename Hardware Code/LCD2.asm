;------------------------------------------------------------------------------
#include "msp430.h"                     ; #define controlled include file

            ORG  05000h                 ; at RAM
LINE1       DB 'Fernando R. Lopez`'
LINE2       DB 'Urb. Monterey`'
LINE3       DB 'Calle Boriquen 541`'
LINE4       DB 'Mayaguez, PR 00680`' 
            
            
;------------------------------------------------------------------------------
            ORG  05400h                 ; Program Start
            
;------------------------------------------------------------------------------
RESET      mov.w  #04400h,SP                 ; Initialize Stackpointer
STOPWDT    MOV.W  #WDTPW+WDTHOLD,&WDTCTL     ; Stop Watchdog Timer
           
           
           BIS.b  #0FFh, &P6DIR              ; Set Port 6 as output for data
           BIS.b  #011b, &P5DIR              ; Set Port 5.0, 5.1 for R/W and EN
           
           CALL #INITS
           CALL #UPDATELCD
          
Finish     BIS.b #LPM4, SR                   ; Sleep
;------------------------------------------------------------------------------
;              Initialization Subroutine
;------------------------------------------------------------------------------
INITS      CALL #IWAITS
           mov.b #030h, R6
           CALL #CMDWR
           CALL #IWAITS;
           CALL #CMDWR;
           CALL #WAITS;
           CALL #CMDWR;
           CALL #WAITS;
           
           mov.b #01h, R6
           CALL #CMDWR
           ;mov.b #08h, R6
           ;CALL #CMDWR
           mov.b #038h, R6
           CALL #CMDWR
           mov.b #0Eh, R6
           CALL #CMDWR
           mov.b #06h, R6
           CALL #CMDWR
           ret;
           
;------------------------------------------------------------------------------
;              Enable Subroutine
;------------------------------------------------------------------------------
LCDEN      BIS.b #01b, &P5OUT                ;
           CALL #WAITS                       ;
           BIC.b #01b, &P5OUT                ;
           CALL #WAITS
           ret ;
;------------------------------------------------------------------------------
;              Command Write Subroutine
;------------------------------------------------------------------------------
CMDWR     BIC.b #010b, &P5OUT   
          CALL #WAITS
          mov.b R6, &P6OUT
          CALL #WAITS
          CALL #LCDEN
          ret;
;------------------------------------------------------------------------------
;              Character Write Subroutine
;------------------------------------------------------------------------------
CHRWR     BIS.b #010b, &P5OUT   
          CALL #WAITS
          mov.b R6, &P6OUT
          CALL #WAITS
          CALL #LCDEN
          ret;     
;------------------------------------------------------------------------------
;              Line Write Subroutine
;------------------------------------------------------------------------------ 
LNWR      mov.b #20, R4
L3        mov.b @R7+, R6
          CMP.b #'`', R6
          JZ Finish2
          CALL #CHRWR
          DEC R4
          JNZ L3
Finish2   ret;          
;------------------------------------------------------------------------------
;              Update Display Subroutine
;------------------------------------------------------------------------------
UPDATELCD   mov.b #080h, R6             ;Move cursor Line1
            CALL #CMDWR
            mov.w #LINE1, R7
            CALL #LNWR                  ;Write Line1
            
            mov.b #0C0h, R6             ;Move cursor Line2
            CALL #CMDWR
            mov.w #LINE2, R7
            CALL #LNWR                  ;Write Line2
            
            mov.b #094h, R6             ;Move cursor Line3
            CALL #CMDWR
            mov.w #LINE3, R7
            CALL #LNWR                  ;Write Line3
            
            mov.b #0D4h, R6             ;Move cursor Line4
            CALL #CMDWR
            mov.w #LINE4, R7
            CALL #LNWR                  ;Write Line4
            
            ret;
;------------------------------------------------------------------------------
;               Wait Subroutine
;------------------------------------------------------------------------------
WAITS    mov.w #280, R5
L1       DEC R5
         JNZ L1
         ret;
;------------------------------------------------------------------------------
;               Initialization Wait Subroutine
;------------------------------------------------------------------------------
IWAITS    mov.w #9000, R5
L2       nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         nop
         DEC R5
         JNZ L2
         ret;
;------------------------------------------------------------------------------
;               Interrupt Vectors
;------------------------------------------------------------------------------
            ORG  0FFFEh                 ; MSP430F5438 Reset Vector
            DW   RESET                  ;
            END                         ;