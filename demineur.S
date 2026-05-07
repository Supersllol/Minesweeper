HOME     EQU   $FC58
COUT     EQU   $FDED
PRBYTE   EQU   $FDDA
PRHEX    EQU   $FDE3
TABV     EQU   $FB5B
CROUT    EQU   $FD8E
CH       EQU   $24
RDKEY    EQU   $FD0C
SETTXT   EQU   $FB33
BELL     EQU   $FF3A
*
PTR      EQU   $6         ;2B
LVOISINS EQU   $50        ;8B
TEMP     EQU   $58        ;8B
COUNT    EQU   $60        ;1B
CURSOR   EQU   $61        ;1B
NFLAGS   EQU   $62        ;1B
STATE    EQU   $63        ;1B
*
GRIDCOL  EQU   $0C
GRIDLINE EQU   $03
*
         ORG   $8000
*
         LDA   #10
         STA   NBOMBS
*
_INIT    JSR   SETTXT
         LDA   #$77
         STA   CURSOR
         JSR   IBOMBS
         JSR   IGRID
         LDA   NBOMBS
         STA   NFLAGS
         LDA   #0
         STA   NEXPLORE
         STA   STATE
         JSR   HOME
         JSR   PRNAME
         JSR   PROUTL
         JSR   PRGRID
*
LOOP     JSR   RDKEY
         CMP   #"Q"
         BEQ   QUIT
         CMP   #"W"
         BEQ   INPUTW
         CMP   #"A"
         BEQ   INPUTA
         CMP   #"S"
         BEQ   INPUTS
         CMP   #"D"
         BEQ   INPUTD
         CMP   #$8D       ;ENTER
         BEQ   IREVEAL
         CMP   #$A0       ;SPACE
         BEQ   FLAG
RELOOP   JMP   LOOP
*
QUIT     JSR   HOME
         RTS
*
INPUTW   LDA   CURSOR
         SEC
         SBC   #$10
         STA   CURSOR
         JMP   INPUTEND
*
INPUTA   LDA   CURSOR
         SEC
         SBC   #$01
         STA   CURSOR
         JMP   INPUTEND
*
INPUTS   LDA   CURSOR
         CLC
         ADC   #$10
         STA   CURSOR
         JMP   INPUTEND
*
INPUTD   LDA   CURSOR
         CLC
         ADC   #$01
         STA   CURSOR
         JMP   INPUTEND
*
INPUTEND JSR   PRGRID     ;WILL RELOOP AFTER
*
IRELOOP  JMP   RELOOP     ;FOR JUMP RANGE
IREVEAL  JMP   REVEAL
*
*FLAGS CHOSEN SPOT 
FLAG     LDX   CURSOR
         LDA   GRID,X     ;SPOT
         CMP   #$10
         BCC   FLAGADD    ;ADD
         CMP   #$20
         BCC   FLAGNO     ;REMOVE
FLAGEND  JSR   PRGRID
         JSR   PRFLAG
         JMP   RELOOP
*
FLAGADD  LDY   NFLAGS
         BEQ   FLAGEND    ;NO MORE
         CLC
         ADC   #$10       ;FLAG
         STA   GRID,X
         DEC   NFLAGS
         JMP   FLAGEND
*
FLAGNO   SEC
         SBC   #$10       ;REMOVE
         STA   GRID,X
         INC   NFLAGS
         JMP   FLAGEND
*
ISOVER   JSR   PRGRID
         JSR   PRFLAG
         LDA   #0
         SEC   
         SBC   NBOMBS
         CMP   NEXPLORE
         BEQ   WIN        ;IF EXPLORED ALL
         LDA   STATE
         BNE   LOSE       ;IF BOMB FOUND
         JMP   RELOOP
*
WIN      LDA   #"W"
         JSR   COUT
         RTS
*
LOSE     JSR   PRBOMB
         LDA   #"L"
         JSR   COUT
         RTS
*
*REVEALS CHOSEN SPOT
REVEAL   LDA   #0
         STA   NEXTCNT
         LDX   CURSOR
         LDA   GRID,X
         CMP   #$10       
         BCS   IRELOOP     ;FLAG OR REVEALED
REVEAL1  JSR   EXPLORE
         LDX   NEXTCNT
         BEQ   ISOVER    ;NO MORE
         DEC   NEXTCNT
         LDX   NEXTCNT
         LDA   LNEXT,X    ;FIRST IN PILE
         TAX              ;SAVE SPOT
         JMP   REVEAL1
*
*REVEALS SPOT IN X AND ADDS UNEXPLORED
*NEIGHBORS TO LNEXT WITH NEXTCNT INC
EXPLORE  LDA   GRID,X
         CLC
         CMP   #$10
         BCC   EXPLORE2   ;NOT FLAG
         ADC   #$10
         INC   NFLAGS     ;INC COUNT
         JMP   EXPLORE3
EXPLORE2 ADC   #$20
EXPLORE3 STA   GRID,X     ;UPDATE
         INC   NEXPLORE
         AND   #%00001111 ;LOW BYTE
         BEQ   ADDNEXT    ;IF EMPTY
         CMP   #$0F       ;BOMB
         BEQ   EXPLORE4
         RTS              ;IF NUMBER, OVER
EXPLORE4 LDA   NEXPLORE
         CMP   #1
         BEQ   MOVEBMB   ;IF FIRST MOVE
         LDA   #1
         STA   STATE      ;LOSE
         RTS
*
MOVEBMB  STX   TEMP+6     ;OLD SPOT
         LDX   #0
         JSR   PRBYTE
MOVEBMB1 LDA   GRID,X
         CMP   #$0F
         BCC   MOVEBMB2   ;IF CLEAR
         INX   
         JMP   MOVEBMB1
MOVEBMB2 LDA   #$0F
         STA   GRID,X     ;PUT NEW BOMB
         STX   TEMP+7     ;NEW SPOT
         JSR   REPLACE
         LDY   #1         ;WANT TO ADD 1
         JSR   NEWVOIS    ;UPDATE VOISINS
         LDA   TEMP+6
         LDY   #$FF       ;WANT TO SUB 1
         JSR   NEWVOIS
         LDA   TEMP+6
         JSR   CNTBMBS
         LDX   TEMP+6
         CLC   
         ADC   #$20
         STA   GRID,X
         CMP   #$20
         BEQ   ADDNEXT    ;IF EMPTY
         RTS
*
REPLACE  LDA   TEMP+6
         JSR   ISBOMB
         LDX   RESULT     ;POSITION
         LDA   TEMP+7
         STA   LBOMBS,X   ;REPLACE
         RTS
*
NEWVOIS  JSR   VOISINS
         STY   TEMP       ;SAVE WHAT TO ADD
         LDX   #0
NEWVOIS1 LDA   LVOISINS,X
         TAY   
         LDA   GRID,Y
         CMP   #$0F       ;IF BOMB, SKIP
         BEQ   NEWVOIS2
         CLC   
         ADC   TEMP       ;OFFSET
         STA   GRID,Y     ;UPDATE 
NEWVOIS2 INX
         CPX   RESULT
         BEQ   NEWVOIS3   ;IF DONE
         JMP   NEWVOIS1
NEWVOIS3 RTS
*
ADDNEXT  TXA
         JSR   VOISINS
         LDA   RESULT
         STA   TEMP       ;NB VOISINS
         LDX   #0         ;LOOP COUNTER
ADDNEXT1 LDA   LVOISINS,X 
         TAY    
         LDA   GRID,Y     ;LOAD CONTENTS
         CMP   #$20
         BCS   ADDNEXT2   ;ALREADY EXPLORED
         JSR   ISNEXT
         LDY   RESULT
         CPY   #$FF
         BNE   ADDNEXT2   ;ALREADY IN THERE
         LDY   NEXTCNT
         STA   LNEXT,Y    ;ADD TO LIST
         INC   NEXTCNT
ADDNEXT2 INX 
         CPX   TEMP
         BEQ   ADDNEXT3   ;DONE
         JMP   ADDNEXT1
ADDNEXT3 RTS
*
ISNEXT   LDY   #LNEXT
         STY   PTR
         LDY   #>LNEXT
         STY   PTR+1
         LDY   NEXTCNT
         STY   LEN
         LDA   LVOISINS,X
         JSR   ISIN
         RTS
*
*AFFICHE LE TITRE A L'ECRAN
PRNAME   JSR   HOME       ; ECRITURE TITRE
         LDA   #16
         STA   CH                  
         LDA   #GRIDLINE-2                  
         JSR   TABV                
         LDX   #0                  
PRNAME1  LDA   TITRE,X             
         CMP   #$AA                
         BEQ   PRNAME2                 
         JSR   COUT                
         INX                      
         BNE   PRNAME1
PRNAME2  RTS
*
*PRINTS THE GRID OUTLINE
PROUTL   LDA   #GRIDLINE-2 ;2 PARCE QUE VA INCREMENTER
         STA   TEMP       ;TEMP A LA LIGNE
PROUTL1  LDX   #0         ;CONTOUR
         INC   TEMP
         LDA   #GRIDCOL-1 ;1 DERRIERE LA GRILLE
         STA   CH
         LDA   TEMP
         JSR   TABV       ;PLACE AU PREMIER DE LA LIGNE
         LDA   COIN
         JSR   COUT
*
PRTOP    LDA   HAUT   
         JSR   COUT       ; 1. On affiche le tiret '-'
         INX              ; 2. On augmente le compteur X
         CPX   #16       ; 3. On regarde si on a atteint 16
         BNE   PRTOP       ; 4. On boucle (BNE regarde directement le CPX !)
* 
         LDA   COIN
         JSR   COUT       ; On affiche le '+' de droite
* 
         LDA   TEMP
         SEC
         SBC   #GRIDLINE-1
         CMP   #$11       ; Est-ce qu'on vient de dessiner le bas
         BEQ   PROUTL2     ; SI OUI LE CONTOUR EST FINI
*
PRSIDE   INC   TEMP
         LDA   #GRIDCOL-1
         STA   CH
         LDA   TEMP
         JSR   TABV       ;PLACE AU PREMIER DE LA LIGNE
         LDA   COTE
         JSR   COUT
         LDA   #GRIDCOL-1
         CLC
         ADC   #$11       ; $11 en hex = 17 en décimal (largeur de votre grille)
         STA   CH
         LDA   TEMP
         JSR   TABV       ;PLACE AU PREMIER DE LA LIGNE
         LDA   COTE
         JSR   COUT
         LDA   TEMP
         SEC
         SBC   #GRIDLINE-1
         CMP   #$10       ; A-t-on dessiné 16 lignes de murs 
         BEQ   PROUTL1    ; Si oui, on saute pour dessiner le plancher
         BNE   PRSIDE     ; Sinon, on boucle pour le prochain mur
PROUTL2  RTS
*
*PRINTS THE GRID TO THE SCREEN
PRGRID   LDA   #00
         STA   TEMP       ;ROW
PRGRID1  LDA   #00
         STA   TEMP+1     ;COLUMN              
PRGRID2  LDA   TEMP+1
         CLC   
         ADC   #GRIDCOL    ;OFFSET
         STA   CH         ;COLUMN
         LDA   TEMP
         JSR   TOLOW      ;LOW BYTE
         CLC   
         ADC   #GRIDLINE   ;OFFSET
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
PRFLAG   RTS
*
*REVEALS ALL BOMBS AND REPRINTS THE GRID
PRBOMB   LDX   #0
PRBOMB1  LDA   GRID,X
         AND   #%00001111 ;LOW BYTE
         CMP   #$0F
         BNE   PRBOMB2
         CLC
         ADC   #$20       ;REVEAL
         STA   GRID,X     ;UPDATE
PRBOMB2  INX
         BEQ   PRBOMB3    ;IF OVERFLOWED
         JMP   PRBOMB1
PRBOMB3  JSR   PRGRID
         RTS
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
         LDY   RESULT
         CPY   #$FF
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
*LOAD BOMB COUNT AROUND ACC SPOT TO ACC
CNTBMBS  JSR   VOISINS    ;LOAD LIST, AND NUMBER TO RESULT
         LDA   RESULT
         STA   TEMP+1
         LDX   #0
         STX   TEMP
CNTBMBS1 LDA   LVOISINS,X
         JSR   ISBOMB
         LDY   RESULT
         CPY   #$FF
         BEQ   CNTBMBS2   ;NO BOMB
         INC   TEMP       ;BOMB COUNTER++
CNTBMBS2 INX
         CPX   TEMP+1     ;CHECK IF VISITED ALL
         BEQ   CNTBMBS3
         JMP   CNTBMBS1
CNTBMBS3 LDA   TEMP
         RTS
*
*STORE VOISINS OF ACC SPOT IN LVOISINS,
*NUMBER IN RESULT
VOISINS  STA   TEMP+5     ;TEMP+5 HAS ORIGINAL SPOT
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
         STA   RESULT
VOISINS5 LDA   TEMP+5
         CLC   
         ADC   TEMP
         CLC
         ADC   TEMP+4
         CMP   TEMP+5     
         BEQ   VOISINS6   ;IF NEW SPOT IS ORIGINAL SPOT
         LDX   RESULT
         STA   LVOISINS,X ;SAVE TO LIST
         INC   RESULT
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
*POS OR $FF IF NOT FOUND IN RESULT
ISBOMB   LDY   #LBOMBS
         STY   PTR
         LDY   #>LBOMBS
         STY   PTR+1
         LDY   NBOMBS
         STY   LEN
         JSR   ISIN
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
IRANDOM  LDA   $4E
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
COIN     ASC  "+"
HAUT     ASC  "-"
COTE     ASC  "|"
TITRE    ASC  "DEMINEUR*"
*                 
LEN      DS    1
RESULT   DS    1
GRID     DS    256
LNEXT    DS    256
NEXTCNT  DS    1
NBOMBS   DS    1
NEXPLORE DS    1
* END OF PROGRAM SINCE SIZE IS UNKWOWN
LBOMBS   DS    1