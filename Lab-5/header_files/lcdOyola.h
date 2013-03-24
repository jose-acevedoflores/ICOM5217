#define    COM_ARG     R6
#define    DATA_ARG    R12     
#define    CHAR_ARG    R6         
    ORG   0x06400
    DW    INITS_LCD
    
;------------------------------------------------------------------------------
;            Initialization Sequence
;------------------------------------------------------------------------------
INITS_LCD   BIS.b  #0FFh, &P6DIR             ;Set Port 6 as output
            BIS.b  #011b, &P5DIR         ;Set Port 5 Pins 0,1 as output
            BIC.b  #0FFh, &P6OUT             ;Clearing Data pins
            BIC.b  #011b, &P5OUT              ;Clearing control pins
            
       
            
            mov.b  #038h, R6             ;Function Set
            CALL   #CMDWR                     ;Enable LCD
            
            mov.b  #008h, R6            ;Display Control
            CALL   #CMDWR                     ;Enable LCD
         
            mov.b  #001h, R6             ;Clear Display
            CALL   #CMDWR                     ;Enable LCD
          
            
            mov.b  #006h, R6             ;Entry Mode Set
            CALL   #CMDWR                     ;Enable LCD
            
            mov.b  #00Fh, R6             ;Display Control
            CALL   #CMDWR                     ;Enable LCD
            ret
          
          
;------------------------------------------------------------------------------
;            Wait Subroutine
;------------------------------------------------------------------------------
WAITS       mov.w  #0F0h, R5                  ; Store delay constant in R5
DECS        dec.w  R5                         ; Decrement delay constant
            jnz    DECS                       ; Continue decrementing?
            ret                               ;

;------------------------------------------------------------------------------
;           Enable Subroutine
;------------------------------------------------------------------------------
LCDEN       BIS.b  #010b, &P5OUT         ;Enable LCD
            CALL   #WAITS                     ;Wait 
            BIC.b  #010b, &P5OUT         ;Disable LCD
            ret                          ;   
        
;------------------------------------------------------------------------------
;          Command Write Subroutine
;------------------------------------------------------------------------------
CMDWR      BIC.b #01b, &P5OUT            ;Set RS to 0
           mov.b R6, &P6OUT               ; Send command
           CALL  #WAITS                       ;Wait
           CALL   #LCDEN                     ;Enable LCD
           call    #WAITS  
           ret                                ;
;------------------------------------------------------------------------------
;            Character Write Subroutine
;------------------------------------------------------------------------------
CHWR       BIS.b #01b, &P5OUT            ;Set RS to 1
           mov.b R6, &P6OUT               ; Send Character
           CALL  #WAITS                       ;Wait
           CALL   #LCDEN                     ;Enable LCD
           ret                              ;

           
;------------------------------------------------------------------------------
;            Line Write Subroutine
;------------------------------------------------------------------------------
LNWR       mov.b @R12+, R6                  ;
           CMP  #060h, R6                       ;
           JZ   Endline
           CALL #CHWR
           
           JMP  LNWR
Endline    ret      


