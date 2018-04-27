# Syteme d'alignement avec croix et viseur de 80 microns
# =======================================================

namespace eval tpg {

Struct::new croix80x4_1
setLayer 1
setDose 4                                     ;# Dose pour traits de 4 microns
   set c [Chemin::newFromString {x=-20 y=-20;v380;I>40;E^380;>380;I^40;E<380;^380;I<40;Ev380;<380;Iv40;E>380;}]
   bfc $c
   set c [Chemin::translated 800 0 $c]
   bfc $c
   set c [Chemin::translated 0 -800 $c]
   bfc $c
   set c [Chemin::translated -800 0 $c]
   bfc $c
setDose 0                                     ;# Dose par defaut
# displayWinStruct croix80x4_1 0.1


Struct::new cadre80x4_1
setLayer 1
setDose 0                       ;# Dose pour blocs espacees de 4 a 6 microns
    set c [Chemin::new 100 0]                  ;# Point en bas a gauche
    Chemin::appendArc c E 180 90 6 400 0 100
    Chemin::appendPoint c I 400 400
    Chemin::appendPoint c I 100 400
    Chemin::appendArc c E 0 -90 6   0 400 100
    Chemin::appendPoint c I 0 100
    Chemin::appendArc c E 90  0 6   0   0 100
    Chemin::appendPoint c I 100 0
    Chemin::supprimeDoubles c

    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
setDose 0                                     ;# Dose par defaut
# # displayWinStruct cadre80x4_1 0.1

Struct::new anti_cadre80x4_1
setLayer 1
setDose 4                                     ;# Dose pour traits de 4 microns
    set c [Chemin::new 0 350]
    Chemin::appendPoint c I 10 350
    Chemin::appendPoint c I 10 400
    Chemin::appendArc c E 0 -90 6 0 400 100
    Chemin::appendPoint c E 0 300
    Chemin::appendPoint c E 0 100
    Chemin::appendArc c E 90 0 6 0 0 100
    Chemin::appendPoint c E 100  0
    Chemin::appendPoint c E 300  0
    Chemin::appendArc c E 180 90 6 400 0 100
    Chemin::appendPoint c I 400 10
    Chemin::appendPoint c I 350 10
    Chemin::appendPoint c I 350  0
    Chemin::appendPoint c I 75  0
    Chemin::appendArc c I 0 90 6 0 0 75
    Chemin::appendPoint c I 0 350
    Chemin::supprimeDoubles c

    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
setDose 0                                      ;# Dose par defaut
# displayWinStruct anti_cadre80x4_1 0.1

Struct::new trait80x4_1
setDose 9
   
   set c [Chemin::new 350 -5]
   Chemin::appendPoint c E 400 -5
   Chemin::appendPoint c I 400  5
   Chemin::appendPoint c E 350  5
   Chemin::appendPoint c E 350 -5
   bfc $c
   Chemin::transform c miroir.axey
   bfc $c
   set c [list]
   set c [Chemin::new -5 350]
   Chemin::appendPoint c E  5 350
   Chemin::appendPoint c E  5 400
   Chemin::appendPoint c I -5 400
   Chemin::appendPoint c E -5 350
   bfc $c
   Chemin::transform c miroir.axex
   bfc $c
setDose 0
# displayWinStruct trait80x4_1 1

Struct::new e0_cercle80x4_1          ;# Petit anneau rayon int. 35 rayon ext. 40
  setDose 8                        ;# Dose pour traits de 0.5 micron
   anneau 35 40 0 0 16
  setDose 0                        ;# Dose par defaut
# displayWinStruct e0_cercle80x4_1 1

Struct::new e1_cercle80x4_1          ;# Petit anneau rayon int. 30 rayon ext. 35
  setDose 8                        ;# Dose pour traits de 0.5 micron
   anneau 30 35 0 0 16
  setDose 0                        ;# Dose par defaut
# displayWinStruct e1_cercle80x4_1 1

Struct::new e2_cercle80x4_1          ;# Petit anneau rayon int. 40 rayon ext. 45
  setDose 8                        ;# Dose pour traits de 0.5 micron
   anneau 40 45 0 0 16
  setDose 0                        ;# Dose par defaut
# displayWinStruct e2_cercle80x4_1 1

Struct::new e3_cercle80x4_1          ;# Petit anneau rayon int. 25 rayon ext. 30
  setDose 8                        ;# Dose pour traits de 0.5 micron
   anneau 25 30 0 0 16
  setDose 0                        ;# Dose par defaut
# displayWinStruct e3_cercle80x4_1 1

Struct::copieWithPrefix e0_ cadre80x4_1
Struct::copieWithPrefix e1_ cadre80x4_1
Struct::copieWithPrefix e2_ cadre80x4_1
Struct::copieWithPrefix e3_ cadre80x4_1

Struct::empate -30 e0_cadre80x4_1
Struct::empate -25 e1_cadre80x4_1
Struct::empate -35 e2_cadre80x4_1
Struct::empate -20 e3_cadre80x4_1

# displayWinStruct e0_cadre80x4_1 1
# displayWinStruct e1_cadre80x4_1 1
# displayWinStruct e2_cadre80x4_1 1
# displayWinStruct e3_cadre80x4_1 1

Struct::copieWithPrefix e0_ anti_cadre80x4_1
Struct::copieWithPrefix e1_ anti_cadre80x4_1
Struct::copieWithPrefix e2_ anti_cadre80x4_1
Struct::copieWithPrefix e3_ anti_cadre80x4_1

puts "On empate anti_cadre80x4_1 qui ne sera plus utilise"
puts "Pour ne pas avoir de BOUNDARY debile dans GDS-2"
Struct::empate 10 anti_cadre80x4_1

Struct::empate 30 e0_anti_cadre80x4_1
Struct::empate 25 e1_anti_cadre80x4_1
Struct::empate 35 e2_anti_cadre80x4_1
Struct::empate 20 e3_anti_cadre80x4_1

# displayWinStruct e0_anti_cadre80x4_1 1
# displayWinStruct e1_anti_cadre80x4_1 1
# displayWinStruct e2_anti_cadre80x4_1 1
# displayWinStruct e3_anti_cadre80x4_1 1

Struct::new anti_viseur80x4_1
sref e0_anti_cadre80x4_1   0    0 
sref e1_anti_cadre80x4_1 800    0 
sref e2_anti_cadre80x4_1   0 -800 
sref e3_anti_cadre80x4_1 800 -800 

# displayWinStruct anti_viseur80x4_1 1

Struct::new viseur80x4_1
sref e0_cadre80x4_1    0    0
sref e0_cercle80x4_1   0    0 
sref trait80x4_1       0    0 
sref e1_cadre80x4_1  800    0
sref e1_cercle80x4_1 800    0
sref trait80x4_1     800    0 
sref e2_cadre80x4_1    0 -800
sref e2_cercle80x4_1   0 -800
sref trait80x4_1       0 -800
sref e3_cadre80x4_1  800 -800
sref e3_cercle80x4_1 800 -800
sref trait80x4_1     800 -800

# displayWinStruct viseur80x4_1 0.1


Struct::new protege_test_80x4_3
setLayer 3
    boundary {;>8000;^4000;<4000;v2000;<2000;^2000;<2000;v4000;}

Struct::copieAllWithPrefix n2_ viseur80x4_1
Struct::setLayer n2_viseur80x4_1 2

# apparemment c'est bien un antiviseur
Struct::copieAllWithPrefix n3_ anti_viseur80x4_1
Struct::setLayer n3_anti_viseur80x4_1 3

Struct::copieAllWithPrefix n4_ viseur80x4_1
Struct::setLayer n4_viseur80x4_1 4

Struct::copieAllWithPrefix n5_ viseur80x4_1
Struct::setLayer n5_viseur80x4_1 5

Struct::copieAllWithPrefix n6_ viseur80x4_1
Struct::setLayer n6_viseur80x4_1 6

Struct::copieAllWithPrefix n7_ viseur80x4_1
Struct::setLayer n7_viseur80x4_1 7

Struct::copieAllWithPrefix n8_ viseur80x4_1
Struct::setLayer n8_viseur80x4_1 8

Struct::copieAllWithPrefix n9_ viseur80x4_1
Struct::setLayer n9_viseur80x4_1 9


# Assemblage des croix et viseurs pour bloc test

Struct::new aligne_test_80_1
    # Croix 80x4 pour niveau #2 à #9
for {set i 0} {$i<4} {incr i} {
    sref croix80x4_1 [expr 600 + 2000*$i] 3400
}
for {set i 0} {$i<4} {incr i} {
    sref croix80x4_1 [expr 600 + 2000*$i] 1400
}


# displayWinStruct aligne_test_80_1 0.1

set x 600
set y 3400
Struct::new aligne_test_80_2
sref n2_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_test_80_3
sref n3_anti_viseur80x4_1 $x $y
sref protege_test_80x4_3 0 0

incr x 2000
Struct::new aligne_test_80_4
sref n4_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_test_80_5
sref n5_viseur80x4_1 $x $y

set x 600
set y 1400
Struct::new aligne_test_80_6
sref n6_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_test_80_7
sref n7_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_test_80_8
sref n8_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_test_80_9
sref n9_viseur80x4_1 $x $y


Struct::new aligne_test_80
setLayer 0                        ;# Niveau de debugging (a ne pas fabriquer)
brxy 0 0 8000 4000
sref aligne_test_80_1 0 0
sref aligne_test_80_2 0 0
sref aligne_test_80_3 0 0
sref aligne_test_80_4 0 0
sref aligne_test_80_5 0 0
sref aligne_test_80_6 0 0
sref aligne_test_80_7 0 0
sref aligne_test_80_8 0 0
sref aligne_test_80_9 0 0

# displayWinStruct aligne_test_80 0.1

# Assemblage des croix et viseurs pour bloc tbs

Struct::new aligne_tbs_80_1
set x 600
set y 1400
for {set i 2} {$i<=9} {incr i; incr x 2000} {
    sref croix80x4_1 $x $y          ;# Croix 80x4 pour niveau $i
}

# displayWinStruct aligne_tbs_80_1 0.1

Struct::new protege_tbs_80x4_3
setLayer 3
  brxy 0 0 2000 2000
  brxy 4000 0 12000 2000


set x 600
set y 1400
Struct::new aligne_tbs_80_2
sref n2_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_3
sref n3_anti_viseur80x4_1 $x $y
sref protege_tbs_80x4_3 0 0

incr x 2000
Struct::new aligne_tbs_80_4
sref n4_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_5
sref n5_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_6
sref n6_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_7
sref n7_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_8
sref n8_viseur80x4_1 $x $y

incr x 2000
Struct::new aligne_tbs_80_9
sref n9_viseur80x4_1 $x $y

Struct::new aligne_tbs_80
setLayer 0                ;# Niveau de debugging (a ne pas fabriquer)
brxy 0 0 16000 2000
sref aligne_tbs_80_1 0 0
sref aligne_tbs_80_2 0 0
sref aligne_tbs_80_3 0 0
sref aligne_tbs_80_4 0 0
sref aligne_tbs_80_5 0 0
sref aligne_tbs_80_6 0 0
sref aligne_tbs_80_7 0 0
sref aligne_tbs_80_8 0 0
sref aligne_tbs_80_9 0 0

# displayWinStruct aligne_tbs_80 0.1

}
