E_HIGH  EQU     00100000b               ; Used with bis.b to Set bit 5 of port 8 (P8.5) to 1. This is done to call E_LOW and trigger the falling edge 
E_LOW   EQU     00100000b               ; Used with bic.b to set bit 5 of port 8 (P8.5) to 0. 
COMMAND EQU     01000000b               ; Used with bic.b to set bit 6 of port 8 (P8.6) to 0. This tells the LCD controller that a command will be sent
DATA    EQU     01000000b               ; Used with bis.b to set bit 6 of port 8 (P8.6) to 1. This tells the LCD controller that data will be sent

#define LCDDB   P10OUT                  ; Name Port P10 as LCDDB (LCD Data Bus) to facilitate code reading.
#define E       P8OUT                   ; Name Port P8.5 as E (enable ) 
#define D_C     P8OUT                   ; Name Port P8.6 as D_C (Data or Command)

#define DELAY_ARG   R5
#define STR         R6
#define COM_ARGS    R8
#define DATA_ARGS   R8


      ORG       06f00h
      DW        INIT_LCD
/*------------------------------------------LCD Portion -------------------------------------------*/      
INIT_LCD    nop
            mov.b       #0x01,COM_ARGS		; Clear LCD
            call        #WRITECOM		; 
            mov.b       #0x038, COM_ARGS	; Enable 8 bit / 2 lines
            call        #WRITECOM
            mov.b       #0x0e, COM_ARGS		; Turn on Underline cursor
            call        #WRITECOM
            mov.b       #0x06,COM_ARGS		; Entry Mode 
            call        #WRITECOM
            ret  

//;Uses Register R8 to pass command to write.
WRITECOM    nop
            bic.b #COMMAND, D_C         ; Clear bit P8.6 (ready the controller for a command)
            mov.b COM_ARGS, LCDDB       ; Load data to be sent to LCD Controller 
            bis.b #E_HIGH, E            ; Set enable pin P8.5 to high
            mov.w #0x0f00, DELAY_ARG    ; Load delay arguments
            call  #DELAY                ; Call delay to let LCD controller read the high E
            bic.b #E_LOW, E             ; Set Controller Enable (E) to low to trigger falling edge
            ret

//;Uses R9 to pass character data
WRITECHAR   nop
            bis.b  #DATA, D_C           ; Set Bit P8.6 (ready the controller for data)
            mov.b  DATA_ARGS, LCDDB     ; Load Data to be sent to LCD Controller
            bis.b  #E_HIGH, E           ; Set Enable pin P8.5 to high
            mov.w  #0x0f00,DELAY_ARG    ; Load delay arguments 
            call   #DELAY               ; Call delay to let LCD controller read the high E
            bic.b  #E_LOW, E            ; Set Controller Enable (E) to low to trigger falling edge
            ret
            
WRITESTR    nop
NextChar    mov.b  @STR+, DATA_ARGS     ; Use STR as pointer to String to print
            cmp.b  #'^', DATA_ARGS
            jz     endWS     
            call   #WRITECHAR
            jmp    NextChar
endWS       ret            
/*------------------------------------------LCD Portion -------------------------------------------*/      
 
/*------------------------------------------Delay Function ----------------------------------------*/      
//;Uses Register R5 as Delay counter
DELAY   nop
DLOOP   dec.w   R5
        jnz     DLOOP
        ret
/*------------------------------------------Delay Function ----------------------------------------*/    