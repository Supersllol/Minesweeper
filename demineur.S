HOME     EQU   $FC58
COUT     EQU   $FDED
TABV     EQU   $FB5B
CROUT    EQU   $FD8E
CH       EQU   $24
RDKEY    EQU   $FD0C
SETTXT   EQU   $FB33
BELL     EQU   $FF3A
WAIT     EQU   $FCA8
GETLN    EQU   $FD6F
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
VALMIN   EQU   15         ;VAL MIN
VALMAX   EQU   205        ;VAL MAX
*
         ORG   $8000
*
* #-------------------------------
* # WINDOW 1 - TITLE SCREEN
* #-------------------------------
*
_W1      JSR   HOME       ;E. VIDE
*
_DE0     LDA   #10
         JSR   DELAI
*
_TEXT1   LDA   #2         ;COL. 2
         STA   CH
         LDA   #10        ;LIG. 10
         JSR   TABV       
         LDA   #MSG1
         STA   PTR
         LDA   #>MSG1
         STA   PTR+1
         JSR   PRINT
*
_DE1     LDA   #20
         JSR   DELAI
*
_TEXT2   LDA   #2         ;COL. 2
         STA   CH
         LDA   #11        ;LIG. 11
         JSR   TABV       
         LDA   #MSG2
         STA   PTR
         LDA   #>MSG2
         STA   PTR+1
         JSR   PRINT
*
_DE2     LDA   #20
         JSR   DELAI
*
* #-------------------------------
* # WINDOW 2 - HISTOIRE
* #-------------------------------
*
_W2      JSR   HOME       ;E. VIDE
*
_DE3     LDA   #05
         JSR   DELAI
*
_TEXT3   LDA   #2         ;COL. 2
         STA   CH
         LDA   #9        ;LIG. 9
         JSR   TABV       
         LDA   #MSG3
         STA   PTR
         LDA   #>MSG3
         STA   PTR+1
         JSR   PRINT
*
_DE4     LDA   #25
         JSR   DELAI
*
_TEXT4   LDA   #2         ;COL. 2
         STA   CH
         LDA   #10        ;LIG. 10
         JSR   TABV       
         LDA   #MSG4
         STA   PTR
         LDA   #>MSG4
         STA   PTR+1
         JSR   PRINT
*
_DE5     LDA   #25
         JSR   DELAI
*
_TEXT5   LDA   #2         ;COL. 2
         STA   CH
         LDA   #11        ;LIG. 11
         JSR   TABV       
         LDA   #MSG5
         STA   PTR
         LDA   #>MSG5
         STA   PTR+1
         JSR   PRINT
*
_DE6     LDA   #25
         JSR   DELAI
*
_TEXT6   LDA   #2         ;COL. 2
         STA   CH
         LDA   #12        ;LIG. 12
         JSR   TABV       
         LDA   #MSG6
         STA   PTR
         LDA   #>MSG6
         STA   PTR+1
         JSR   PRINT
*
_DE7     LDA   #25
         JSR   DELAI
*
* #-------------------------------
* # WINDOW 3 - BOMBES
* #-------------------------------
*
_W3      JSR   HOME       ;E. VIDE
*
_DE8     LDA   #05
         JSR   DELAI         
*
ASK      JSR   HOME
         LDA   #2         ;COL. 2
         STA   CH
         LDA   #10        ;LIG. 10
         JSR   TABV       
         LDA   #MSG7
         STA   PTR
         LDA   #>MSG7
         STA   PTR+1
         JSR   PRINT
*
_DE9     LDA   #05
         JSR   DELAI
*
_PLACE   LDA   #2         ;COL. 2
         STA   CH
         LDA   #11        ;LIG. 11
         JSR   TABV       
*
         JSR   GETLN  
_LEN     CPX   #0
         BEQ   ECHEC       ;=0
         CPX   #4
         BCS   ECHEC       ;>= 4
         STX   MAX
*
         LDX   #0
         STX   VAL
CONVERT  LDA   VAL
         CMP   #26
         BCS   ECHEC      ;OVERFLOW
         JSR   MUL10
         STA   VAL        ;VAL*=10
         LDA   $200,X
         SEC
         SBC   #$B0
         CMP   #$0A
         BCS   ECHEC      ;NOT NUM
         CLC
         ADC   VAL
         BCS   ECHEC      ;OVERFLOW
         STA   VAL        ;+=ACC
         INX   
         CPX   MAX        
         BNE   CONVERT    ;NO DONE
*
_VERIF   LDA   VAL
         CMP   #VALMIN
         BCC   ECHEC      ;<MIN
*
         CMP   #VALMAX+1
         BCS   ECHEC      ;>MAX
         STA   NBOMBS
         LDA   PLAYED
         BEQ   VERIF1       
         JMP   INIT       ;SKIP INTRO
VERIF1   JMP   _W4        ;W4
*
ECHEC    JMP   ASK        ;RESTART
*
* #-------------------------------
* # WINDOW 4 - COMMANDES
* #-------------------------------
*
_W4      JSR   HOME       ;E. VIDE
*
_DE10    LDA   #05
         JSR   DELAI
*
_TEXT8   LDA   #2         ;COL. 2
         STA   CH
         LDA   #9        ;LIG. 9
         JSR   TABV       
         LDA   #MSG8
         STA   PTR
         LDA   #>MSG8
         STA   PTR+1
         JSR   PRINT
*
_TEXT9   LDA   #2         ;COL. 2
         STA   CH
         LDA   #10        ;LIG. 10
         JSR   TABV       
         LDA   #MSG9
         STA   PTR
         LDA   #>MSG9
         STA   PTR+1
         JSR   PRINT
*
_TEXT10  LDA   #2         ;COL. 2
         STA   CH
         LDA   #11        ;LIG. 11
         JSR   TABV       
         LDA   #MSG10
         STA   PTR
         LDA   #>MSG10
         STA   PTR+1
         JSR   PRINT
*
_TEXT11  LDA   #2         ;COL. 2
         STA   CH
         LDA   #12        ;LIG. 12
         JSR   TABV       
         LDA   #MSG11
         STA   PTR
         LDA   #>MSG11
         STA   PTR+1
         JSR   PRINT
*
_DE11    LDA   #50
         JSR   DELAI
*
* #-------------------------------
* # WINDOW 5 - LANCEMENT
* #-------------------------------
*
_W5      JSR   HOME       ;E. VIDE
*
_DE12    LDA   #05
         JSR   DELAI         
*
_TEXT12  LDA   #2         ;COL. 2
         STA   CH
         LDA   #10        ;LIG. 10
         JSR   TABV       
         LDA   #MSG12
         STA   PTR
         LDA   #>MSG12
         STA   PTR+1
         JSR   PRINT
*
_DE13    LDA   #30
         JSR   DELAI
*
_TEXT13  LDA   #2         ;COL. 2
         STA   CH
         LDA   #11        ;LIG. 11
         JSR   TABV       
         LDA   #MSG13
         STA   PTR
         LDA   #>MSG13
         STA   PTR+1
         JSR   PRINT
*
_DE14    LDA   #30
         JSR   DELAI
*
INIT     JSR   SETTXT
         LDA   #$77
         STA   CURSOR     ;RESET CURSOR
         JSR   IBOMBS
         JSR   IGRID
         LDA   NBOMBS
         STA   NFLAGS     ;INIT FLAG COUNT
         JSR   DECFLAG    ;CHANGE LES FLAGS HEX EN DEC
         LDA   #0
         STA   NEXPLORE
         STA   STATE
         JSR   HOME
         JSR   PRNAME
         JSR   PROUTL
         JSR   PRGRID
         JSR   PRFLAG
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
         BEQ   JREVEAL
         CMP   #$A0       ;SPACE
         BEQ   JFLAG
RELOOP   JMP   LOOP
*
QUIT     JSR   HOME
         RTS
*
JREVEAL  JMP   REVEAL     ;FOR RANGE
JFLAG    JMP   FLAG       ;FOR RANGE
*
INPUTW   LDA   CURSOR
         SEC
         SBC   #$10
         STA   CURSOR
         JMP   INPUTEND
*
INPUTA   LDA   CURSOR
         AND   #%00001111
         BEQ   SPCA
         LDA   CURSOR
         SEC
         SBC   #$01
         STA   CURSOR
         JMP   INPUTEND
SPCA     LDA   CURSOR
         CLC
         ADC   #$10
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
         AND   #%00001111
         CMP   #$0F
         BEQ   SPCD
         LDA   CURSOR
         CLC
         ADC   #$01
         STA   CURSOR
         JMP   INPUTEND
SPCD     LDA   CURSOR
         SEC
         SBC   #$10
         CLC
         ADC   #$01
         STA   CURSOR
         JMP   INPUTEND
*
INPUTEND JSR   PRGRID
         JMP   RELOOP
*
JASK     JMP   ASK       ; FOR RANGE
*
*ASKS THE USER TO REPLAY OR QUIT
REPLAY   LDA   #1
         STA   PLAYED
         LDA   #0
         STA   CH                  
         LDA   #GRIDLINE+19
         JSR   TABV                
         LDA   #TXTREPL
         STA   PTR
         LDA   #>TXTREPL
         STA   PTR+1
         JSR   PRINT
REPLAY1  JSR   RDKEY
         CMP   #"Q"
         BNE   NOTQ       ;ERREUR INTÉRESSANTE ON PEUT PAS BRANCH EN HAUT DE 128
         JMP   QUIT       ;JMP LUI EST ABSOLU
NOTQ     CMP   #"R"
         BEQ   JASK
         JMP   REPLAY1
*
*FLAGS CHOSEN SPOT 
DECFLAG  LDA   NFLAGS
         LDX   #0         ; COMPTEUR CENTAINES
CENT     CMP #100
         BCC   DIZAINE    ; SI A MOINS QUE 100 DIZAINE
         SBC #100       ; SINON CONTINU
         INX
         JMP   CENT
DIZAINE  STX   CEN        ; CENTAINES
         LDX   #0         ; COMPTEUR DIZAINE
DIZ      CMP   #10
         BCC   UNITE      ; SI A MOINS QUE 10 FINI
         SBC   #10        ; SINON CONTINU
         INX
         JMP   DIZ 
UNITE    STX   DEC        ; DIZAINE
         STA   UN         ; RESTE UNITE
         RTS
*
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
         JSR   DECFLAG
         JMP   FLAGEND
*
FLAGNO   SEC
         SBC   #$10       ;REMOVE
         STA   GRID,X
         INC   NFLAGS
         JSR   DECFLAG
         JMP   FLAGEND
*
ISOVER   JSR   PRGRID
         JSR   PRFLAG
         LDA   STATE
         BNE   LOSE       ;IF BOMB FOUND
         LDA   #0
         SEC   
         SBC   NBOMBS
         CMP   NEXPLORE
         BEQ   WIN        ;IF EXPLORED ALL
         JMP   RELOOP
*
WIN      LDA   #0
         STA   CH                  
         LDA   #GRIDLINE+18
         JSR   TABV                
         LDA   #TXTWIN
         STA   PTR
         LDA   #>TXTWIN
         STA   PTR+1
         JSR   PRINT      ;WIN MSG
         LDA   #10
         JSR   DELAI
         JMP   REPLAY
*
LOSE     JSR   BELL
         LDA   #0
         STA   CH                  
         LDA   #GRIDLINE+18
         JSR   TABV                
         LDA   #TXTLOSE
         STA   PTR
         LDA   #>TXTLOSE
         STA   PTR+1
         JSR   PRINT      ;LOSE MSG
         LDA   #10
         JSR   DELAI
         JSR   PRBOMB
         JMP   REPLAY
*
IRELOOP  JMP   RELOOP     ;FOR JUMP RANGE
*REVEALS CHOSEN SPOT
REVEAL   LDA   #0
         STA   NEXTCNT
         LDX   CURSOR     ;CURRENT SPOT
         LDA   GRID,X
         CMP   #$10       
         BCS   IRELOOP    ;FLAG OR REVEALED
REVEAL1  JSR   EXPLORE
         LDX   NEXTCNT
         BEQ   ISOVER     ;NO MORE
         DEC   NEXTCNT
         LDX   NEXTCNT
         LDA   LNEXT,X    ;FIRST IN PILE
         TAX              ;SAVE SPOT IN X
         JMP   REVEAL1
*
*REVEALS SPOT IN X AND ADDS UNEXPLORED
*NEIGHBORS TO LNEXT WITH NEXTCNT INC
EXPLORE  LDA   GRID,X
         CMP   #$10
         BCC   EXPLORE2   ;NOT FLAG
         CLC
         ADC   #$10
         INC   NFLAGS     ;INC COUNT
         JMP   EXPLORE3
EXPLORE2 CLC
         ADC   #$20
EXPLORE3 STA   GRID,X     ;UPDATE
         INC   NEXPLORE
         AND   #%00001111 ;LOW BYTE
         BEQ   ADDNEXT    ;IF EMPTY
         CMP   #$0F       ;BOMB
         BEQ   EXPLORE4
         RTS              ;IF NUMBER, OVER
EXPLORE4 LDA   NEXPLORE
         CMP   #1
         BEQ   MOVEBMB    ;IF FIRST MOVE
         LDA   #1
         STA   STATE      ;LOSE
         RTS
*
MOVEBMB  STX   TEMP+6     ;OLD SPOT
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
         JSR   CNTBMBS    ;NEW COUNT FOR OLD SPOT
         LDX   TEMP+6
         CLC   
         ADC   #$20       ;REVEAL IT
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
         BNE   ADDNEXT2   ;ALREADY IN NEXT
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
         LDA   #TITRE
         STA   PTR
         LDA   #>TITRE
         STA   PTR+1
         JSR   PRINT
         RTS
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
*PRINT AT LINE GRIDLINE+17
PRFLAG   LDA   #GRIDCOL-9
         STA   CH
         LDA   #GRIDLINE+18
         JSR   TABV
         LDA   #TXTFLAG
         STA   PTR
         LDA   #>TXTFLAG
         STA   PTR+1
         JSR   PRINT
         LDA   CEN
         CLC
         ADC   #$B0
         CMP   #$B0
         BEQ   NOCEN
         JSR   COUT
         LDA   DEC
         CLC
         ADC   #$B0
         JSR   COUT
         JMP   PRUN
NOCEN    LDA   DEC
         CLC
         ADC   #$B0
         CMP   #$B0
         BEQ   PRUN
         JSR   COUT
PRUN     LDA   UN
         CLC
         ADC   #$B0
         JSR   COUT
         LDA   #$A0
         JSR   COUT
         LDA   #$A0
         JSR   COUT
         RTS
*
*REVEALS ALL BOMBS AND REPRINTS THE GRID
PRBOMB   LDY   #0
PRBOMB1  CPY   CURSOR
         BEQ   PRBOMB2    ;IF CURRENT BOMB, SKIP
         LDA   GRID,Y
         AND   #%00001111 ;LOW BYTE
         CMP   #$0F
         BNE   PRBOMB2    ;SKIP IF NOT BOMB
         CLC
         ADC   #$20       ;REVEAL
         STA   GRID,Y     ;UPDATE
         LDA   #15
         JSR   WAIT
         JSR   PRGRID
PRBOMB2  INY
         BEQ   PRBOMB3    ;IF OVERFLOWED
         JMP   PRBOMB1
PRBOMB3  RTS
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
IGRID2   JSR   CNTBMBS    ;LOAD BOMB NEIGHBOR COUNT
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
         STA   TEMP+1     ;NUMBER OF NEIGHBORS
         LDX   #0
         STX   TEMP       ;BOMB COUNTER
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
         ADC   TEMP+4     ;ADD BOTH OFFSETS
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
*PRINTS MESSAGE STARTING IN PTR
*UP TO * CHAR, ASSUMES CURSOR IN RIGHT SPOT
PRINT    LDY   #0
PRINT1   LDA   (PTR),Y
         CMP   #"*"
         BEQ   PRINT2
         JSR   COUT
         INY
         JMP   PRINT1
PRINT2   RTS
*MOVES ACC HIGH BYTE TO LOW BYTE
*USES X
TOLOW    LDX   #4
TOLOW1   LSR              ;/2
         DEX
         BEQ   TOLOW2
         JMP   TOLOW1
TOLOW2   RTS              ;/2^4
*
* ACC *= 10
MUL10   ASL         ;*2
        STA TEMP
        ASL         ;*4
        ASL         ;*8
        CLC
        ADC TEMP    ;*8 + *2 = *10
        RTS
*
DIXIEME  LDA   #197
         JSR   WAIT
         RTS
*
*ATTEND ACC DIXIEMES DE SECONDE
DELAI    STA   TEMP
DIXI     JSR   DIXIEME
         DEC   TEMP
         BNE   DIXI
         RTS
*
*RANDOM GENERATION
IRANDOM  LDA   $4E
         ORA   #$1
         STA   RNDSEED
         LDA   $4F
         STA   RNDSEED+1
         RTS
*
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
TITRE    ASC "DEMINEUR*"
TXTLOSE  ASC "BOUM! T'ES EN MIETTES    *"
TXTWIN   ASC "BRAVO! TU AS REUSSI      *"
TXTREPL  ASC "Q POUR QUITTER, R POUR REJOUER *"
TXTFLAG  ASC "NOMBRE DE DRAPEAUX: *"
MSG1     ASC   "LE DEMINEUR*"
MSG2     ASC   "UN JEU DE SIMON, ETIENNE ET HANS*"
*
MSG3     ASC   "DES MINES SONT CACHEES DANS LE SOL.*"
MSG4     ASC   "CHAQUE CASE CACHEE PEUT ETRE UN PIEGE.*"
MSG5     ASC   "LES CHIFFRES TE DONNENT DES INDICES.*"
MSG6     ASC   "EVITE LES PIEGES ET GAGNE.*"
*
MSG7     ASC   "DITES LE NOMBRE DE MINES [15-205].*"
*
MSG8     ASC   "[WASD] POUR SE DEPLACER.*"
MSG9     ASC   "[ESPACE] POUR PLACER UN DRAPEAU.*"
MSG10    ASC   "[ENTREE] POUR REVELER UNE CASE.*"
MSG11    ASC   "[Q] POUR QUITTER LE JEU.*"
*
MSG12    ASC   "LANCEMENT DU DEMINEUR...*"
MSG13    ASC   "BONNE CHANCE. LE MONDE COMPTE SUR TOI.*"
UN       HEX   00
DEC      HEX   00
CEN      HEX   00
*                 
LEN      DS    1
RESULT   DS    1
GRID     DS    256
LNEXT    DS    256
LBOMBS   DS    256
NEXTCNT  DS    1
NBOMBS   DS    1
NEXPLORE DS    1
VAL      DS    1
MAX      DS    1
PLAYED   DS    1