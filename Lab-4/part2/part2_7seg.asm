#include "msp430.h"                     ; #define controlled include file
#include  "../header_files/7seg.h"  
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
       
        ORG     0FFECh
        DW      TIMER_IR
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        
        
        bis.b   #BIT6,P8DIR
        bis.b   #BIT6,P8OUT
        mov.b   #0x0ff, P10DIR  ; Set p10 as output
        call    #INIT_TIMER
        clr     NUMA
        
        bic.b   #BIT6,P8OUT             ; Enable Digit 1
        eint
        jmp     $
        
INIT_TIMER nop
        bis.w   #SELA_2,&UCSCTL4                ; Set AMCLK source to REFOCLOCK    
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL0                ; Disable interrupt on compare
        bis.w   #511, &TA0CCR0                  ; Count up to FFFF
        bis.w   #TAIDEX_7, &TA0EX0              ; Divide input signal by 2
        ret
;ISR for timer         
TIMER_IR nop 
        cmp     #16,NUMA
        jz      Clear
Cont    call    #ChNumA
        inc.b   NUMA
        reti
Clear   clr     NUMA
        jmp     Cont
        
        END