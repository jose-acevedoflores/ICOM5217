#define NUMTRIES    R10
#define USRCOUNT    R11    
      ORG       05f00h
      DW        WelcomeMsg


WelcomeMsg   nop
        mov.w   #Guess,STR
        call    #WRITESTR
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ;New Line  
        mov.w   #Guess2,STR
        call    #WRITESTR
        ret  

StartGame nop
        mov.w   #0x01, COM_ARGS
        call    #WRITECOM               ;Clear LCD 
        mov.w   #TurnNum,STR
        call    #WRITESTR
        bis.b   #00110000b,NUMTRIES     ; Format NUMTRIES to display it on LCD
        mov.b   NUMTRIES, DATA_ARGS
        call    #WRITECHAR  
        ret
          
UpdateCount nop
        mov.w   #0x0C0, COM_ARGS
        call    #WRITECOM               ;Stay on second line
        mov.w   #Rand,STR
        call    #WRITESTR   
        bis.b   #00110000b,USRCOUNT     ; Format USRCOUNT to display it on LCD
        mov.b   USRCOUNT, DATA_ARGS
        call    #WRITECHAR  

        ret

Rand    DB      'User guess ^'          
Guess   DB   'Press the two^'
Guess2  DB      'buttons^'
TurnNum  DB      'Turn number ^'