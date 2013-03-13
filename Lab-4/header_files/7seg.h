#define   NUMA  R6
#define   NUMB  R7
#define   TO7SEG P10OUT

    ORG   0x06000
    DW    SevenSeg  
      
SevenSeg        nop
////////////////////////////////////////////////////////////////////////////////
//P8.6 = BJT for number A (Digit 1)
ChNumA  push.b  R5              ; Save R5
        mov.w   #LUT,R5          ; Load the Look Up Table in R5
        add.w   NUMA,R5
        mov.b   @R5, TO7SEG ; Add the number you want to display to R5 (LUT) to turn on the appropiate bits on the 7 segment
        pop R5                  ; Recover R5
        ret  
////////////////////////////////////////////////////////////////////////////////
//P8.5 = BJT for number B (Digit 2)
ChNumB  push.b  R5              ; Save R5
        mov.w   #LUT,R5          ; Load the Look Up Table in R5
        add.w   NUMB,R5
        mov.b   @R5, TO7SEG ; Add the number you want to display to R5 (LUT) to turn on the appropiate bits on the 7 segment
        pop R5                  ; Recover R5
        ret  


LUT     DB      0x040,0x079,0x024,0x030,0x019,0x012,0x002,0x78,0x000,0x010, 0x08,0x03,0x46,0x21,0x06,0x0E


