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
GRIDCOL  EQU   $0C
GRIDLINE EQU   $04
*
         ORG   $8000
*
         JSR   HOME
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
         SBC   #GRIDLINE
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
         SBC   #GRIDLINE
         CMP   #$10       ; A-t-on dessiné 16 lignes de murs 
         BEQ   PROUTL1    ; Si oui, on saute pour dessiner le plancher
         BNE   PRSIDE     ; Sinon, on boucle pour le prochain mur
PROUTL2  RTS
*
COIN     ASC  "+"
HAUT     ASC  "-"
COTE     ASC  "|"