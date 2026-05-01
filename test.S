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
TEMP     EQU   $58        ;8B
COUNT    EQU   $60        ;1B
CURSOR   EQU   $61        ;1B
*
         ORG   $8000
*
         JSR   HOME
         LDA   #0
         STA   CURSOR
         LDA   #$1F
         STA   GRID
         LDA   #$2F
         STA   GRID+1
         LDA   #$28
         STA   GRID+2
         LDA   #$20
         STA   GRID+3
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
         JSR   TABV       ;MOVE CURSOR
         LDA   TEMP
         CLC   
         ADC   TEMP+1
         TAX
         JSR   GRIDCH
         CPX   CURSOR     ;IF SELECTED
         BNE   PRGRID3
         SEC   
         SBC   #$40       ;FLASH
PRGRID3  JSR   COUT
         LDA   TEMP+1
         CMP   #$0F       ;END OF ROW
         BEQ   PRGRID4
         INC   TEMP+1
         JMP   PRGRID2    ;NEXT ELEMENT
PRGRID4  JSR   CROUT
         LDA   TEMP
         CMP   #$F0      ;END OF GRID
         BEQ   PRGRID5
         CLC   
         ADC   #$10
         STA   TEMP
         JMP   PRGRID1    ;RESET COLUMN
PRGRID5  RTS
*
*PUTS IN ACC THE CHAR REPRESENTING
*THE GRID POS IN X 
GRIDCH   LDA   GRID,X
         CMP   #$10
         BCC   GRIDCH1    ;HIDDEN
         CMP   #$20
         BCC   GRIDCH2    ;FLAG
         CMP   #$2F
         BNE   GRIDCH3
         LDA   #$A1       ;BOMB
         RTS
GRIDCH1  LDA   #$A3       
         RTS
GRIDCH2  LDA   #$BF
         RTS
GRIDCH3  AND   #%00001111
         BEQ   GRIDCH4
         CLC
         ADC   #$B0       ;NUMBER
         RTS
GRIDCH4  LDA   #$A0
         RTS
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
GRIDCOL  HEX   0C
GRIDLINE HEX   05
LEN      DS    1
RESULT   DS    1
GRID     DS    256
NBOMBS   DS    1
*               
* END OF PROGRAM SINCE SIZE IS UNKWOWN
LBOMBS   DS    1          