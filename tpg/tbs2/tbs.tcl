source gds2.tcl

# ********************************
# Choses spécifiques au transistor
# ********************************

set w 0
set l 0

# nom du transistor adresse et longueur

VARIABLE nom 30 ALLOT
set lnom 0

# modifie nom et lnom, utilise l et w

: cree.nom ( a u -- )
   TO lnom nom lnom CMOVE
   nom lnom
   l 10 / s>" "cat
   S" x" "cat
   w 10 / s>" "cat
   TO lnom DROP
;

VARIABLE nspragma 40 ALLOT
0 VALUE lnspragma
S" new.struct " nspragma SWAP DUP TO lnspragma CMOVE

: niveau.lxw.old ( n -- )    \ largeur x Longueur
   LOCALS| n | n set.layer
   nspragma lnspragma nom lnom "cat
   S" _" "cat
   n s>" "cat
   EVALUATE
;

: niveau.lxw ( n -- )    \ largeur x Longueur
   LOCALS| n | n set.layer
   nom lnom 
   S" _" "cat
   n s>" "cat
   ['] new.struct PARSE_FROM_STRING 
;

