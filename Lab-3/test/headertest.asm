#include "msp430.h"   
#include  "lcd.h"
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label

        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer

        mov.b   #0x0FF, P10DIR          ; Set P10 as output for LCD Data lines
        mov.b   #0x0FF, P8DIR           ; Set P8 as output for P8.5 and P8.6 ENABLE and RS lines
        
        call     #INIT_LCD               ; Initialize LCD
       
        call     #WRITESTR               ; Write first string
        mov.w    #0x0C0, COM_ARGS        ; Type in new line
        call     #WRITECOM               
        call     #NextChar               ; Write second string
       
       jmp      $
       nop

               
ToWrite DB      'This is a str^And it is cool^'
        
        
        END
 
 