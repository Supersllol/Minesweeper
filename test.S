HOME     EQU   $FC58
COUT     EQU   $FDED
PRBYTE   EQU   $FDDA
PRHEX    EQU   $FDE3
TABV     EQU   $FB5B
SETINV   EQU   $FE80
SETNORM  EQU   $FE84
CROUT    EQU   $FD8E
CH       EQU   $24
*
PTR      EQU   $6         ;2B
LVOISINS EQU   $50        ;8B
TEMP     EQU   $58        ;5B
COUNT    EQU   $63        ;1B
*
         ORG   $8000
*
         JSR   HOME
         JSR   PRGRID
         RTS
*
*PRINTS THE GRID TO THE SCREEN
PRGRID   LDA   #00
         STA   TEMP       ;ROW
PRGRID1  LDA   #00
         STA   TEMP+1     ;COLUMN              
PRGRID2  LDA   TEMP+1
         CLC   
         ADC   GRIDCOL    ;OFFSET
         STA   CH         ;COLUMN
         LDA   TEMP
         JSR   TOLOW      ;LOW BYTE
         CLC   
         ADC   GRIDLINE   ;OFFSET
         JSR   TABV       ;CURSOR
         LDA   TEMP
         CLC   
         ADC   TEMP+1
         TAX
         LDA   GRID,X
         JSR   PRHEX
         LDA   TEMP+1
         CMP   #$0F       ;END OF ROW
         BEQ   PRGRID3
         INC   TEMP+1
         JMP   PRGRID2    ;NEXT ELEMENT
PRGRID3  JSR   CROUT
         LDA   TEMP
         CMP   #$F0      ;END OF GRID
         BEQ   PRGRID4
         CLC   
         ADC   #$10
         STA   TEMP
         JMP   PRGRID1    ;RESET COLUMN
PRGRID4  RTS
*
*PUTS IN ACC THE CHAR REPRESENTING
*THE GRID POS IN X 
GRIDCHAR NOP
*
*MOVES ACC HIGH BYTE TO LOW BYTE
*USES X
TOLOW    LDX   #4
TOLOW1   LSR
         DEX
         BEQ   TOLOW2
         JMP   TOLOW1
TOLOW2   RTS
*       
LEN      DS    1
RESULT   DS    1
GRID     DS    256
NBOMBS   DS    1
GRIDCOL  HEX   0C
GRIDLINE HEX   05
*               
* END OF PROGRAM SINCE SIZE IS UNKWOWN
LBOMBS   DS    1          