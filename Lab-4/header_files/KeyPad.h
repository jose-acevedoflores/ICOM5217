#define  SCAN   P3OUT
#define  RETURN R8
#define  CurrentCode  R9

// Additions to be able to write two digits

#define DISDIGIT  R13   ; Digit to display on 7seg: 1 is digit a, 2 is digit b

      ORG       0x06200
      DW        KeyPad_INIT
        
        
KeyPad_INIT nop
            bis.b       #BIT0+BIT1+BIT2+BIT3, P3DIR     ; Intiaze P3.0 - P3.3 as output for scan code
            bic.b       #BIT7+BIT6+BIT5, P1DIR          ; Configure P1.7-1.5 as input for return code  
            mov.w       #ScanCodes, CurrentCode  
            ret  
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////              
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
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
DisplayNum  push.w        R5
            rla.b       RETURN  ; xxx00000 -> xx000000  C = x
            rlc.b       RETURN  ; xx000000 -> x000000x  C = x
            rlc.b       RETURN  ; x000000x -> 000000xx  C = x
            rlc.b       RETURN  ; 000000xx -> 00000xxx  
            mov.b       SCAN,R5
            cmp         #1, R5
            jz          Ro1
            cmp         #2, R5
            jz          Ro2
            cmp         #4, R5
            jz          Ro3
            cmp         #8, R5
            jz          Ro4
                          
EndDisp     add.w       RETURN,R5       ; Use number in RETURN as the offset               

            cmp.w       #1,DISDIGIT
            jz          DispA
            cmp.w       #2,DISDIGIT
            jz          DispB
              
DispA:      mov.b       @R5,R6         ; NUMA
            jmp         EndSub
DispB:      mov.b       @R5,R7          ; NUMB

EndSub      pop         R5
            ret

Ro1         mov.w       #Row1,R5        ; Use R5 as data pointer
            jmp         EndDisp  
Ro2         mov.w       #Row2,R5        ; Use R5 as data pointer
            jmp         EndDisp                
Ro3         mov.w       #Row3,R5        ; Use R5 as data pointer
            jmp         EndDisp                
Ro4         mov.w       #Row4,R5        ; Use R5 as data pointer
            jmp         EndDisp                
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

ScanCodes       DB      0x08, 0x04,0x02,0x01, 0x00              

Row1            DB      0x0A,3,2,0x0A,1
Row2            DB      0x0A,6,5,0x0A,4
Row3            DB      0x0A,9,8,0x0A,7
Row4            DB      0x0A,0x0E,0,0x0A,0x0F