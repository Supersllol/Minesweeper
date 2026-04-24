HOME     EQU   $FC58
COUT     EQU   $FDED
PRBYTE   EQU   $FDDA
PRHEX    EQU   $FDE3
TABV     EQU   $FB5B
SETINV   EQU   $FE80
SETNORM  EQU   $FE84
*
PTR      EQU   $6         ;2B
LVOISINS EQU   $50        ;8B
TEMP     EQU   $58        ;5B
*
         ORG   $8000
*
         LDA   #$55
         JSR   VOISINS
         RTS
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
IGRID2   JSR   CNTBMBS
         STA   GRID,X
         JMP   IGRIDNXT
IGRIDNXT CPX   #$FF
         BEQ   IGRIDEND   ;IF $FF, FILLED ALL SPOTS
         INX
         JMP   IGRID1
IGRIDEND RTS
*
*LOAD BOMB COUNT AROUND SPOT TO ACC
CNTBMBS  RTS
*
*STORE VOISINS OF SPOT IN LVOISINS,
*NUMBER IN LEN
VOISINS  STA   RESULT
         CMP   #$10
         BCS   VOISINSA   
         LDX   #$FF       ;SKIP MINUS ROW IF ROW 0
         STX   TEMP       ;TEMP HAS ROW COUNTER
VOISINS1 LDX   #$0F
VOISINS2 STX   TEMP+2     ;TEMP+2 HAS MAX ROW COUNTER
         AND   #%00001111
         BNE   VOISINSB   
         LDX   #1         ;SKIP MINUS COLUMN IF COLUMN 0
         STX   TEMP+1     ;TEMP+1 HAS START COLUMN COUNTER
         STX   TEMP+4     ;TEMP+4 HAS COLUMN COUNTER
VOISINS3 LDX   #2
VOISINS4 STX   TEMP+3     ;TEMP+3 HAS MAX COLUMN COUNTER
         LDA   #0
         STA   LEN
VOISINS5 LDA   RESULT
         CLC   
         ADC   TEMP
         CLC
         ADC   TEMP+4
         CMP   RESULT     
         BEQ   VOISINS6   ;IF NEW SPOT IS ORIGINAL SPOT
         LDX   LEN
         STA   LVOISINS,X ;SAVE TO LIST
         INC   LEN
VOISINS6 LDA   TEMP+4
         CMP   TEMP+3
         BEQ   VOISINS7   ;IF AT MAX COLUMN
         INC   TEMP+4     ;NEXT COLUMN
         JMP   VOISINS5
VOISINS7 LDA   TEMP
         CMP   TEMP+2     
         BEQ   VOISINS8   ;IF AT MAX ROW
         CLC
         ADC   #$10       ;NEXT ROW
         STA   TEMP
         LDA   TEMP+1     
         STA   TEMP+4     ;RESTART COLUMN COUNTER
         JMP   VOISINS5
VOISINS8 RTS
*
VOISINSA LDX   #$EF
         STX   TEMP
         CMP   #$F0
         BCC   VOISINS1
         LDX   #$FF       ;SKIP PLUS ROW IF ROW F
         JMP   VOISINS2
*
VOISINSB LDX   #0
         STX   TEMP+1
         STX   TEMP+4
         CMP   #$0F
         BNE   VOISINS3
         LDX   #1         ;SKIP PLUS COLUMN IF COLUMN F
         JMP   VOISINS4
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