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
         LDA   #30
         STA   NBOMBS
         LDA   #$77
         STA   CURSOR
         JSR   INIT
         JSR   PRGRID
         RTS
*
INIT     JSR   HOME
         JSR   IBOMBS
         JSR   IGRID
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
IGRID    LDA   #0
         STA   COUNT
IGRID1   LDA   COUNT      ;LOAD CURRENT SPOT
         JSR   ISBOMB
         BEQ   IGRID2     ;IF NOT BOMB
         LDA   #$0F
         JMP   IGRIDNXT
IGRID2   JSR   CNTBMBS    ;LOAD BOMB NEIGHBORS
IGRIDNXT LDX   COUNT
         STA   GRID,X
         CPX   #$FF
         BEQ   IGRIDEND   ;IF $FF, FILLED ALL SPOTS
         INC   COUNT
         JMP   IGRID1
IGRIDEND RTS
*
*LOAD BOMB COUNT AROUND SPOT TO ACC
CNTBMBS  JSR   VOISINS    ;LOAD LIST, AND NUMBER TO RESULT
         LDA   RESULT
         STA   TEMP+1
         LDX   #0
         STX   TEMP
CNTBMBS1 LDA   LVOISINS,X
         JSR   ISBOMB
         BEQ   CNTBMBS2   ;NO BOMB
         INC   TEMP       ;BOMB COUNTER++
CNTBMBS2 INX
         CPX   TEMP+1     ;CHECK IF VISITED ALL
         BEQ   CNTBMBS3
         JMP   CNTBMBS1
CNTBMBS3 LDA   TEMP
         RTS
*
*STORE VOISINS OF SPOT IN LVOISINS,
*NUMBER IN RESULT
VOISINS  STA   RESULT     ;RESULT HAS ORIGINAL SPOT
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
VOISINS8 LDA   LEN
         STA   RESULT
         RTS
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
*MOVES ACC HIGH BYTE TO LOW BYTE
*USES X
TOLOW    LDX   #4
TOLOW1   LSR
         DEX
         BEQ   TOLOW2
         JMP   TOLOW1
TOLOW2   RTS
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
*
RNDSEED  HEX   CAFE
GRIDCOL  HEX   0C
GRIDLINE HEX   04
*                 
LEN      DS    1
RESULT   DS    1
GRID     DS    256
NBOMBS   DS    1
* END OF PROGRAM SINCE SIZE IS UNKWOWN
LBOMBS   DS    1       