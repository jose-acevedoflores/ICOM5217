#define NUMTRIES    R10
#define USRCOUNT    R11    
      ORG       05f00h
      DW        WelcomeMsg


WelcomeMsg   nop
        mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ; Clear LCD 
        mov.w   #Guess,STR
        call    #WRITESTR
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ; New Line  
        mov.w   #Guess2,STR
        call    #WRITESTR
        ret  
/*--------------------------------------------------------------------------------------------*/
StartGame nop
        mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ; Clear LCD 
        mov.w   #TurnNum,STR
        call    #WRITESTR               ; Write the number 
        bis.b   #00110000b,NUMTRIES     ; Format NUMTRIES to display it on LCD
        mov.b   NUMTRIES, DATA_ARGS     ; Store Number of tries in DATA_ARGS. TEST: 1(NUMTRIES)
        inc.b   DATA_ARGS               ; Increment DATA_ARGS to present the user with a number between 1-3   
        call    #WRITECHAR  
        call    #UpdateCount  
        ret
/*--------------------------------------------------------------------------------------------*/          
UpdateCount nop
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ; Stay on second line
        mov.w   #Rand,STR
        call    #WRITESTR   
        bis.b   #00110000b,USRCOUNT     ; Format USRCOUNT to display it on LCD
        mov.b   USRCOUNT, DATA_ARGS
        call    #WRITECHAR  
        ret
                    
/*--------------------------------------------------------------------------------------------*/        
WaitForStart nop
        push.w  R5            ; Save R5
Temp    mov.b   P2IN,R5         ; Temporarily store P2IN in R5
        bic.b   #00111111b,R5   ; Save only the status of P2.6 and P2.7
        cmp.b   #0,R5           ; Check if both buttons are pressed (pull up resistor means they are normally high)
        jz      TwoPres         ; If they are pressed, then they are equal and the result of compare is zero
        jmp     Temp            ; If they are not equal then one of the buttons was not pressed, keep checking       
TwoPres pop     R5              ; Recuperate R5 
        ret
/*--------------------------------------------------------------------------------------------*/
UserMove nop
        mov.w   #0x0f00,R14          ; Loop 5 times to allow the user to press the two buttons
CkAgain mov.b   P2IN,R5         ; Temporarily store P2IN in R5
        bic.b   #00111111b,R5   ; Save only the status of P2.6 and P2.7
        cmp.b   #0,R5           ; Check if both buttons are pressed (pull up resistor means they are normally high)
        jz      Accept          ; If they are pressed, then they are equal and the result of compare is zero
        dec.w   R14             ; Decrease counter
        jnz     CkAgain         ; If it's not zero check another time 
        mov.b   #0,R5           ; If they are not equal after 0x0f00 polls then one of the buttons was not pressed
        ret                     ; retrun 0       
Accept  mov.w   #1,R5           ; If they are equal set R5 to 1 to notify main
        ret
/*--------------------------------------------------------------------------------------------*/
UserWon mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ; Clear LCD
        mov.w   #WinMesg,STR
        call    #WRITESTR       ; Write Message at WinMesg 
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ; New Line    
        mov.w   #WinMesg2,STR
        call    #WRITESTR       ; Write Message at WinMesg2 
          
        ret
/*--------------------------------------------------------------------------------------------*/    
GameOver nop
        mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ; Clear LCD
        mov.w   #GameOvM,STR
        call    #WRITESTR       ; Write Message at WinMesg 
        ret
       
/*--------------------------------------------------------------------------------------------*/       
Rand    DB      'User guess ^'          
Guess   DB      'Press the two^'
Guess2  DB      'buttons^'
TurnNum DB      'Turn number ^'
WinMesg DB      'Congratulations!^'
WinMesg2 DB     'You Won ^'
GameOvM DB     'You LOST >:)^'

