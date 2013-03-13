#include "msp430.h"                     ; #define controlled include file
#include  "../header_files/7seg.h"  
        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible
                                        ; outside this module
        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
       
        ORG     0FFECh
        DW      TIMER_IR
        
        ORG     0FFEAh
        DW      TOG_TIMER
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        
        
        bis.b   #BIT6+BIT5,P8DIR
        bis.b   #BIT6,P8OUT             ; Disable Digit 1
        bic.b   #BIT5,P8OUT             ; Enable Digit 2        
        
        mov.b   #0x0ff, P10DIR  ; Set p10 as output
        
        call    #INIT_TIMER
        call    #INIT_TIMER2
        
        clr     NUMA
        clr     NUMB

        eint
        jmp     $
        
INIT_TIMER nop
        bis.w   #SELA_2,&UCSCTL4                ; Set AMCLK source to REFOCLOCK    
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL0                ; Disable interrupt on compare
        bis.w   #511, &TA0CCR0                  ; Count up to FFFF
        bis.w   #TAIDEX_7, &TA0EX0              ; Divide input signal by 2
        ret
INIT_TIMER2 nop
        ;bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL1                ; Disable interrupt on compare
        bis.w   #255, &TA0CCR1                  ; Count up to FFFF
       ; bis.w   #TAIDEX_7, &TA0EX0 
       ret
/////////////////////////////////////////////////////////////////////////////       
;ISR for timer         
//////////////////////////////////////////////////////////////////////////////             
TIMER_IR nop     
        ;eint    ;Enable interrupts in this routine
        inc.b   NUMB
        cmp     #16,NUMB
        jz      ClearB
Cont    reti
  
ClearB  clr     NUMB
        inc.b   NUMA
        cmp     #16, NUMA
        jz      ClearA   
        jmp     Cont
        
ClearA  clr     NUMA
        jmp     Cont
 //////////////////////////////////////////////////////////////////////////////       
; Toggles         
//////////////////////////////////////////////////////////////////////////////
TOG_TIMER  bis.b  #BIT5+BIT6, P8OUT  ; Disable digit B and A
        call    #ChNumB                 
        bic.b   #BIT5, P8OUT    ; Enable Digit B (2)
        bis.b   #BIT5,P8OUT     ; Disable Digit b (2)  
        call    #ChNumA
        bic.b   #BIT6,P8OUT           ; Enable Digit A (1)
        reti
        END