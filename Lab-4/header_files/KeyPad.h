#define  SCAN   P3OUT
#define  RETURN R7
#define  CurrentCode  R6
      ORG       0x06000
      DW        KeyPad_INIT
        
        
KeyPad_INIT nop
            bis.b       #BIT0+BIT1+BIT2+BIT3, P3DIR     ; Intiaze P3.0 - P3.3 as output for scan code
            bic.b       #BIT7+BIT6+BIT5, P1DIR          ; Configure P1.7-1.5 as input for return code  
            mov.w       #ScanCodes, CurrentCode  
            ret  
              
SendScanCode mov.b      @CurrentCode+, SCAN     ; Load output with scan code
            mov.b       P1IN, RETURN            ; Save return code
            bic.b       #00011111b,RETURN       ; Clean all the other inputs from port 1 
            push.w      R5
            mov.b       @CurrentCode, R5        ; Save Current Scan code in R5
            cmp         #0, R5                  ; Check if current scan code is 0 (delimiter to signal start over)
            jz          Circular                ; If it's zero then we need to go back the first scan code
Cont        pop         R5              
            ret
Circular    mov.w       #ScanCodes,CurrentCode  ; Load the first scan code         
            jmp         Cont    
              
              
ScanCodes       DB      0x08, 0x04,0x02,0x01, 0x00              