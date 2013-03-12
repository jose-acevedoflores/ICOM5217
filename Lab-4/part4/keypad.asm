#include "msp430.h"                     ; #define controlled include file
#include "../header_files/KeyPad.h"
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
       
 //       ORG     0FFECh
 //       DW      TIMER_IR
        
 //       ORG     0FFEAh
  //      DW      TOG_TIMER
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        
        call    #KeyPad_INIT
        
        
KScan   call    #SendScanCode           ; Cycle through the scan codes
        cmp     #0,RETURN               ; Check if we have a valid number to display from scan
        jnz     Display                 ; If not zero then there was a button press
                                        ; Use return code to get the pressed number
        jmp     KScan                   ; Keep sending scan codes
        
Display call    #DisplayNum        
        jmp     KScan                   ; Keep sending scan codes
        nop     
        END