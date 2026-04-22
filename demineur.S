HOME     EQU   $FC58
COUT     EQU   $FDED
PRBYTE   EQU   $FDDA
TABV     EQU   $FB5B
SETINV   EQU   $FE80
SETNORM  EQU   $FE84
*
PTR      EQU   $6         ;2B
TEMP     EQU   $50
*
         ORG   $8000
*
         JSR   HOME
         LDA   #10
         STA   NBOMBS
         JSR   IBOMBS
         RTS
*
*CREE LA LISTE DE BOMBES
IBOMBS   JSR   INIT
         LDA   #LBOMBS
         STA   PTR
         LDA   #>LBOMBS
         STA   PTR+1
         LDX   #0
IBOMBS1  CPX   NBOMBS    
         BEQ   IBOMBS3    ;FINI
         JSR   RND16      ;NEXT
         STX   LEN
         JSR   ISIN       
         LDY   RESULT
         CPY   #$FF       ;MAKE SURE NOT ALREADY IN IT
         BNE   IBOMBS2
         STA   LBOMBS,X
         INX
IBOMBS2  JMP   IBOMBS1
IBOMBS3  RTS
*
*CHECK IF ACC IN LIST PTR
*OF LEN, POS IN RESULT
*IF FOUND, ELSE $FF
ISIN     LDY   #0
ISIN1    CPY   LEN
         BEQ   ISIN2
         CMP   (PTR),Y
         BEQ   ISIN3
         INY
         JMP   ISIN1
ISIN2    LDY   #$FF
ISIN3    STY   RESULT
         RTS
*
LEN      DS    1
RESULT   DS    1
GRID     DS    256
NBOMBS   DS    1
*
*RANDOM GENERATION
INIT     LDA   $4E
         ORA   #$1
         STA   RNDSEED
         LDA   $4F
         STA   RNDSEED+1
RND16    LDY   #8
         LDA   RNDSEED
RND1     ASL
         ROL   RNDSEED+1
         BCC   RND2
         EOR   #$39
RND2     DEY
         BNE   RND1
         STA   RNDSEED
         RTS
RNDSEED  HEX   CAFE                   
*                 
* END OF PROGRAM SINCE SIZE IS UNKWOWN
LBOMBS   DS    1          