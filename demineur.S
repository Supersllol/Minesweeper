HOME     EQU   $FC58
COUT     EQU   $FDED
PRBYTE   EQU   $FDDA
PRHEX    EQU   $FDE3
TABV     EQU   $FB5B
SETINV   EQU   $FE80
SETNORM  EQU   $FE84
*
PTR      EQU   $6         ;2B
*
         ORG   $8000
*
         LDA   #10
         STA   NBOMBS
         JSR   INIT
         RTS
*
INIT     JSR   HOME
         JSR   IBOMBS
         JSR   IGRID
         RTS
*
*CREE LA LISTE DE BOMBES
IBOMBS   JSR   IRANDOM
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
         STA   LBOMBS,X   ;SAVE NEW BOMB
         JSR   PRBYTE
         INX
IBOMBS2  JMP   IBOMBS1
IBOMBS3  RTS
*
*INITIALISE LA GRILLE
IGRID    LDX   #0
IGRID1   TXA              ;LOAD CURRENT SPOT
         JSR   ISBOMB
         BEQ   IGRID2     ;IF NOT BOMB
         LDA   #$0F
         STA   GRID,X
         JMP   IGRIDNXT
IGRID2   JMP   IGRIDNXT
IGRIDNXT CPX   #$FF
         BEQ   IGRIDEND   ;IF $FF, FILLED ALL SPOTS
         INX
         JMP   IGRID1
IGRIDEND RTS
*
*CHECK IF POS IN ACC IS BOMB,
*1 OR 0 IN RESULT
ISBOMB   LDY   #LBOMBS
         STY   PTR
         LDY   #>LBOMBS
         STY   PTR+1
         LDY   NBOMBS
         STY   LEN
         JSR   ISIN
         LDY   RESULT
         CPY   #$FF       
         BEQ   ISBOMB1    ;IF NOT FOUND
         LDY   #1
         JMP   ISBOMB2
ISBOMB1  LDY   #0
ISBOMB2  STY   RESULT
         RTS
*
*CHECK IF ACC IN LIST PTR
*OF LEN, RESULT HAS POS
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
IRANDOM     LDA   $4E
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