#include "msp430.h"                     ; #define controlled include file
#include "../header_files/KeyPad.h"
#include "../header_files/7seg.h"

#define DIGIT1  R14
#define DIGIT2  R15
#define SWITCH  R12

        NAME    main                    ; module name

        PUBLIC  main                    ; make the main label vissible

                                        ; outside this module
////////////////////////////////////////////////////////////////////////////////
// RESET and ISR vectors
////////////////////////////////////////////////////////////////////////////////

        ORG     0FFFEh
        DC16    init                    ; set reset vector to 'init' label
       
        ORG     0FFECh
        DW      TOG_TIMER
        ;DW      TIMER_IR
        
        ;ORG     0FFEAh
        ;DW      TOG_TIMER
        
////////////////////////////////////////////////////////////////////////////////
        
        RSEG    CSTACK                  ; pre-declaration of segment
        RSEG    CODE                    ; place program in 'CODE' segment

init:   MOV     #SFE(CSTACK), SP        ; set up stack

main:   NOP                             ; main program
        MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
        
        bis.b   #BIT6+BIT5,P8DIR
        mov.b   #0x0ff, P10DIR          ; Set p10 as output
        bic.b   #BIT6,P8OUT             ; Enable Digit 1
        ;bis.b   #BIT5,P8OUT             ; Disable Digit 2
        
        call    #INIT_T
        //call    #INIT_T2
        
        mov.w   #0,DIGIT1         ; Initialize digit1 register
        mov.w   #0,DIGIT2         ; Initialize digit2 register
        mov.w   #0x0FF,NUMA
        mov.w   #0x0FF,NUMB
        mov.w   #0,DISDIGIT             ; Initialize register that controls what character is displayed
        mov.w   #1,SWITCH
        
        call    #KeyPad_INIT       
        
        eint
        
KScan   mov.w   #0x04FFF,R10
dloop:  dec     R10
        jnz     dloop
        
        call    #SendScanCode           ; Cycle through the scan codes
        cmp     #0,RETURN               ; Check if we have a valid number to display from scan
        jnz     Display                 ; If not zero then there was a button press
                                        ; Use return code to get the pressed number
        jmp     KScan                   ; Keep sending scan codes
        
Display nop
        cmp.w   #0x0FF,NUMB              ; Check if there's no previous number in digit 1
        jnz     Digit2
        mov.w   #2,DISDIGIT
dis:    call    #DisplayNum
        jmp     KScan
        
Digit2: ;cmp.w   #0,NUMA
        ;jz      dis2
        mov.w   NUMB,NUMA
dis2:   mov.w   #2,DISDIGIT
        jmp     dis

////////////////////////////////////////////////////////////////////////////////
// Subroutines
////////////////////////////////////////////////////////////////////////////////
INIT_T  nop
        bis.w   #SELA_2,&UCSCTL4                ; Set AMCLK source to REFOCLOCK    
        bis.w   #TASSEL_1 + MC_1 + ID_0,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL0                ; Disable interrupt on compare
        bis.w   #200, &TA0CCR0                  ; Count up to FFFF
        bis.w   #TAIDEX_1, &TA0EX0              ; Divide input signal by 2
        ret
        
INIT_T2 nop
        bis.w   #SELA_2,&UCSCTL4                ; Set AMCLK source to REFOCLOCK 
        bis.w   #TASSEL_1 + MC_1 + ID_3,&TA0CTL ; Set timer, AMCLK source, Up count operation and divide input signal by 8
        bis.w   #CCIE, &TA0CCTL1                ; Disable interrupt on compare
        bis.w   #155, &TA0CCR1                  ; Count up to FFFF
        bis.w   #TAIDEX_7, &TA0EX0 
        ret

////////////////////////////////////////////////////////////////////////////////
// Interrupt Service Routines
////////////////////////////////////////////////////////////////////////////////
//TIMER_IR nop     
//        ;eint    ;Enable interrupts in this routine
//        inc.b   NUMB
//        cmp     #16,NUMB
//        jz      ClearB
//Cont    reti
//  
//ClearB  clr     NUMB
//       inc.b   NUMA
//        cmp     #16, NUMA
//        jz      ClearA   
//        jmp     Cont
//        
//ClearA  clr     NUMA
//        jmp     Cont
    
TOG_TIMER       nop
        cmp.w   #1,SWITCH
        jz      Turn1
        cmp.w   #2,SWITCH
        jz      Turn2
        
Turn1:  bis.b   #BIT5+BIT6, P8OUT  ; Disable digit B and A
        call    #ChNumA                 
        bic.b   #BIT6,P8OUT    ; Enable Digit A (2)
        mov.w   #2,SWITCH
        jmp     EndI
        
Turn2:  bis.b   #BIT5+BIT6, P8OUT  ; Disable digit B and A
        call    #ChNumB
        bic.b   #BIT5,P8OUT           ; Enable Digit A (1)
        mov.w   #1,SWITCH
EndI:   reti
        
        nop     
        END