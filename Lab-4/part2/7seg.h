#define   NUMA  R6
#define   NUMB  R7
#define   TO7SEG P10OUT

    ORG   0x06000
    DW    SevenSeg  
      
SevenSeg        nop

ChNumA  push.b  R5              ; Save R5
        mov.w   #LUT,R5          ; Load the Look Up Table in R5
        add.w   NUMA,R5
        mov.b   @R5, TO7SEG ; Add the number you want to display to R5 (LUT) to turn on the appropiate bits on the 7 segment
        pop R5                  ; Recover R5
        ret  


LUT     DB      0x040,0x079,0x024,0x04F,0x066,0x06D,0x07D,0x007,0x07F,0x06F


