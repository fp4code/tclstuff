#!/usr/local/bin/wish

 set tcl_traceExec 0
 set tcl_traceCompile 0
source tpg.tcl
# source tbs.tcl
# source 50ohm.tcl


# Liste des chapitres
# ====================
# Numerotation des blocs
# Copyrights : Nom du masque, date, CNRS...
# Motifs de pre-alignement : Grand L et barre a 45 degres
# Syteme d'alignement avec croix et viseur de 80 microns
# Systeme d'aligmenent avec croix et viseur de 40 microns
# Motifs de test
# Mesures des epaisseurs : base, emetteur, mesa d'isolation
# Croix de Van der Pauw
# Lignes TLM (Modele SGT) pour contacts de base
# Lignes TLM (Modele SGT) pour contacts d'emetteur
# Transistors Bipolaires a heterojonction
# Ensemble du masque TBS2
# Corrections dues a la techno
# Structures pour la conversion -> Jeol


# Liste des doses
# ================
# 1 : dose pour traits de 1.5 microns
# 2 : dose pour traits de 2 microns
# 3 : dose pour traits de 3 microns
# 4 : dose pour traits de 4 microns
# 5 : dose pour traits de 6 microns
# 6 : dose pour traits de 8 microns
# 8 : dose pour traits de 0.5 micron
# 9 : dose pour blocs espacees de 4 a 6 microns


# set good {

    setLayer 6
    source font.tcl
# Caracteres de 35 um de haut par 25 um de large

    tpg::Struct::dilate 5 font {}

    source s_numeros.tcl
    source s_copyrights.tcl
    source s_prealignement.tcl
    source s_aligne_80.tcl
    source s_aligne_40.tcl
    source s_test.tcl
    source s_epais.tcl
    source s_hall.tcl
# }
    source s_sgt.tcl

tpg::displayWinStruct2 test100x100 0 0 0.1

    source s_tbs.tcl


namespace eval tpg {

  Struct::new bloc_test_croix       ;# ou viseurs
    sref aligne40 9500 15500        ;# Systeme de pre-alignement croix-viseur de 40 microns
    sref aligne_test_80 11500 15500 ;# Systeme d'alignement croix-viseur de 80 microns
  displayWinStruct2 bloc_test_croix 0 0 0.1
}

exit

namespace eval tpg {
  Struct::new bloc_test_motifs
    sref epais      5500 15500      ;# Motifs de mesures des epaisseurs
    sref copyrights    0 16000      ;# Nom du masque, Date ...
    sref sgt_emetcc  500 13000      ;# Court-circuit emetteur
    sref hall_emet  2000 11500      ;# Croix Van der Pauw emetteur
    sref sgt_emetli 4000 10500      ;# Lignes SGT emetteur
    sref sgt_basecc  500  8000      ;# Court-circuit base
    sref hall_base  2000  6500      ;# Croix Van der Pauw base
    sref sgt_baseli 4000  5500      ;# Lignes SGT base
    sref test_tot  10000  2800      ;# Motifs de test
  displayWinStruct bloc_test_motifs 0.1

  Struct::new bloc_test
   setLayer 0                                  ;# Niveau de debugging (a ne pas fabriquer)
    brxy 0 0 20000 20000 
    sref bloc_test_motifs 0 0
    sref bloc_test_croix 0 0
  displayWinStruct bloc_test 0.1

# Ensemble du masque TBS2
# =========================

  Struct::new masque
    set x 0
    set y 0
                   sref bloc_tbs $x $y ;# 1ere ligne (en bas)
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 2eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 3eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 4eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 5eme ligne
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 6eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 7eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 8eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_test $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    set x 0
    incr y 20000
                   sref bloc_tbs $x $y ;# 9eme ligne
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y
    incr x 20000 ; sref bloc_tbs $x $y

    sref numeros 0 0                   ;# Numerotation des blocs

    displayWinStruct2 masque 0 0 0.001

}

set rien {


# Structures pour la conversion -> Jeol et Corrections dues a la techno
# ========================================================================

Struct::new TEST_1
# NELLE_STRUCT anc_struct layer_select x0 y0 STRUCTURE.eclatee
TEST_1 bloc_test 1 0 0 STRUCTURE.eclatee
# On empate en meme temps les croix qui sont des croix
TEST_1 -5 999 STRUCTURE.empate

Struct::new TEST_2
TEST_2 bloc_test_motifs 2 0 0 STRUCTURE.eclatee
TEST_2 -5 999 STRUCTURE.empate
# On n'empate plus les croix qui sont en fait des viseurs !!!
TEST_2 bloc_test_croix 2 0 0 STRUCTURE.eclatee

Struct::new TEST_3
TEST_3 bloc_test_motifs 3 0 0 STRUCTURE.eclatee
TEST_3 7 999 STRUCTURE.empate
TEST_3 bloc_test_croix 3 0 0 STRUCTURE.eclatee

Struct::new TEST_4
TEST_4 bloc_test_motifs 4 0 0 STRUCTURE.eclatee
TEST_4 -5 999 STRUCTURE.empate
TEST_4 bloc_test_croix 4 0 0 STRUCTURE.eclatee

Struct::new TEST_5
TEST_5 bloc_test_motifs 5 0 0 STRUCTURE.eclatee
# pas d'empattement
TEST_5 bloc_test_croix 5 0 0 STRUCTURE.eclatee

Struct::new TEST_6
TEST_6 bloc_test_motifs 6 0 0 STRUCTURE.eclatee
TEST_6 -3 999 STRUCTURE.empate
TEST_6 bloc_test_croix 6 0 0 STRUCTURE.eclatee

Struct::new TBS_1
TBS_1 bloc_tbs 1 0 0 STRUCTURE.eclatee
# On empate en meme temps les croix qui sont des croix
TBS_1 -5 999 STRUCTURE.empate

Struct::new TBS_3
TBS_3 bloc_tbs_transistors 3 0 0 STRUCTURE.eclatee
TBS_3 7 999 STRUCTURE.empate
# On n'empate plus les croix qui sont en fait des viseurs !!!
TBS_3 bloc_tbs_croix 3 0 0 STRUCTURE.eclatee

Struct::new TBS_4
TBS_4 bloc_tbs_transistors 4 0 0 STRUCTURE.eclatee
TBS_4 -5 999 STRUCTURE.empate
TBS_4 bloc_tbs_croix 4 0 0 STRUCTURE.eclatee

Struct::new TBS_5
TBS_5 bloc_tbs_transistors 5 0 0 STRUCTURE.eclatee
# On n'empate pas
TBS_5 bloc_tbs_croix 5 0 0 STRUCTURE.eclatee

Struct::new TBS_6
TBS_6 bloc_tbs_transistors 6 0 0 STRUCTURE.eclatee
TBS_6 -3 999 STRUCTURE.empate
TBS_6 bloc_tbs_croix 6 0 0 STRUCTURE.eclatee

Struct::new TBS_6B # attention, masque niveau 6 layer 7
TBS_6B bloc_tbs_transistors 7 0 0 STRUCTURE.eclatee
TBS_6B -3 -5 ( faisceau ) + 999 STRUCTURE.empate

Struct::new TBS_7
TBS_7 bloc_tbs_transistors 7 0 0 STRUCTURE.eclatee
TBS_7 -3 -5 ( faisceau ) + 999 STRUCTURE.empate
TBS_7 bloc_tbs_croix 7 0 0 STRUCTURE.eclatee

Struct::new LIGNE_6
LIGNE_6 lig_des_num_col 6 0 0 STRUCTURE.eclatee
LIGNE_6 -3 999 STRUCTURE.empate

Struct::new COLONNE_6
COLONNE_6 col_des_num_lig 6 0 0 STRUCTURE.eclatee
COLONNE_6 -3 999 STRUCTURE.empate

Struct::new EXTRA_0
EXTRA_0 barre_a_45 10 120000 120000 STRUCTURE.eclatee
EXTRA_0 grand_l    10 120000 120000 STRUCTURE.eclatee

# verifie.tout

masque     100 999 STRUCTURE.dilate             # Facteur d'echelle
barre_a_45 100 999 STRUCTURE.dilate
grand_l    100 999 STRUCTURE.dilate

Struct::new tout
0 0 sref TEST_1
0 0 sref TEST_2
0 0 sref TEST_3
0 0 sref TEST_4
0 0 sref TEST_5
0 0 sref TEST_6
20000 0 sref TBS_1
20000 0 sref TBS_3
20000 0 sref TBS_4
20000 0 sref TBS_5
20000 0 sref TBS_6
20000 0 sref TBS_6B
20000 0 sref TBS_7
0 0 sref LIGNE_6
0 0 sref COLONNE_6
0 0 sref EXTRA_0

tout    100 999 STRUCTURE.dilate
verifie.tout

gdsout tbs2.gds2
BELL BELL BELL
BYE

} ; puts fini

