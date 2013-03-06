#define NUMTRIES    R10
#define USRCOUNT    R11    
      ORG       05f00h
      DW        WelcomeMsg


WelcomeMsg   nop
        mov.w   #Guess,STR
        call    #WRITESTR
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ; New Line  
        mov.w   #Guess2,STR
        call    #WRITESTR
        ret  

StartGame nop
        mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ; Clear LCD 
        mov.w   #TurnNum,STR
        call    #WRITESTR 
        bis.b   #00110000b,NUMTRIES     ; Format NUMTRIES to display it on LCD
        mov.b   NUMTRIES, DATA_ARGS     ; Store Number of tries in DATA_ARGS. TEST: 1(NUMTRIES)
        inc.b   DATA_ARGS               ; Increment DATA_ARGS to present the user with a number between 1-3   
        call    #WRITECHAR  
        call    #UpdateCount  
        ret
          
UpdateCount nop
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ; Stay on second line
        mov.w   #Rand,STR
        call    #WRITESTR   
        bis.b   #00110000b,USRCOUNT     ; Format USRCOUNT to display it on LCD
        mov.b   USRCOUNT, DATA_ARGS
        call    #WRITECHAR  
        ret
          
WaitForStart nop
        push.w    R5            ; Save R5
Temp    mov.b   P2IN,R5         ; Temporarily store P2IN in R5
        bic.b   #00111111b,R5   ; Save only the status of P2.6 and P2.7
        cmp.b   #11000000b,R5   ; Check if both buttons are pressed
        jz      TwoPres         ; If they are pressed, then they are equal and the result of compare is zero
        jmp     Temp            ; If they are not equal then one of the buttons was not pressed, keep checking       
TwoPres pop     R5              ; Recuperate R5 
        ret

          
Rand    DB      'User guess ^'          
Guess   DB      'Press the two^'
Guess2  DB      'buttons^'
TurnNum  DB     'Turn number ^'



