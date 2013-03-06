#define DIVISOR     R5
#define DIVCNT      R9
#define RANDVAL     R7
#define Dividend    R9
#define Divisor     R10
#define Result      R11
#define Remainder   R12
  ORG   06800h
  DW    MOD10
    
    

//////////////////////////////////////////////////////////////////////////////
// Modulus 10 subroutine
// Parameters: RANDVAL (R7): Number to divide, dividend
//             DIVISOR (R5): Number that divides the dividend
// Result:     RANDVAL (R7): Residue of randval/divisor
//////////////////////////////////////////////////////////////////////////////

MOD10:  nop
        mov.b   #10,DIVISOR     ; Initialize divisor in 10
        push.b  RANDVAL
        sub.w   DIVISOR,RANDVAL ; Check if divisor is larger than randval
        jlo     endDv1          ; Place result as 0
        
        pop.b   RANDVAL
dvStrt: add.w   #10,DIVISOR     ; Multiply divisor
        push.b  RANDVAL
        sub.w   DIVISOR,RANDVAL ; Check if RANDVAL > DIVISOR
        jlo     endDv           ; If not, end division and return residue
        pop.b   RANDVAL
        jge     dvStrt          ; Else, continue multiplying

endDv1: mov.w   #0,RANDVAL      ; Put 0 residue on RANDVAL
        jmp     endDv2          ; Return           
        
endDv:  pop     RANDVAL
        bic.w   #0x0FF00,RANDVAL
        sub.w   #0x000A,DIVISOR ; Subtract 10 from divisor
        sub.w   DIVISOR,RANDVAL ; Get residue
endDv2: ret

;------------------------------------------------------------------------------
;          Division Subroutine
;               
;------------------------------------------------------------------------------
DIV1       mov.w #016, R5               ;Store 8 for loop
           CLR  Remainder               ;Clear register for remainder
           CLR  Result                  ;Clear register for result
           
DIVLOOP    RLC.w Dividend               ;Shift to the left through carry
           RLC.w Remainder              ;
           PUSH.W Remainder             ;Push temporary remainder
           SUB.w Divisor, Remainder
           JN  NEGATIVE
POSITIVE   SETC                         ;Set carry
           POP R14                      ;Trash bin
           JMP CONT
NEGATIVE   POP Remainder                ;Pop previous remainder
           CLRC                         ;Clear carry  
CONT       RLC.w Result                 ;Shift result
           
           DEC R5
           JNZ DIVLOOP
           ret