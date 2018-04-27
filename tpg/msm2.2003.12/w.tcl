#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

# 2003-12-18 copie de ../msm.2002.04/w3.tcl
# modifs à faire : 
# remettre les vraies grilles de transition
# ne mettre que des réseaux
# introduire des 5x5 et des 3x3
# 
# 


set tcl_traceExec 1
set tcl_traceCompile 1
set SCRIPT [info script]
set DIROUT ~fab/W/Z/msm2.2003.12

# unité finale = 0.1 nm ; unité intermédiaire = 1 nm 

# 



###############################################
# grillesAcces :
# c = 10 ou 20
# pas = 150 ou 200
# x1
# Marge_o Marge optique
#
#
#


proc grillesAcces {c pas x1} {
    global Marge_o U Ls2 Xc Yc

    set Nx [expr {int(ceil(double($Marge_o)/double($U($pas)+2*$Ls2($pas))))}]
    set Lx [expr {$Nx*($U($pas)+2*$Ls2($pas))}]
    set Ny [expr {int(floor(double(2*$Yc($c)-2*$Ls2($pas))/double($U($pas)+2*$Ls2($pas))))}]
    set Lys2 [expr {$Ny*($U($pas)+2*$Ls2($pas))/2+$Ls2($pas)}]
    set x2 [expr {$x1+$Lx}]
    for {set iy 0} {$iy < $Ny} {incr iy} {
        set y1 [expr {-$Lys2 + $iy*($U($pas)+2*$Ls2($pas))}]
        set y2 [expr {$y1+2*$Ls2($pas)}]
        tpg::boundary "x=$x1 y=$y2;y=$y1;x=$x2;y=$y2;x=$x1;"
        tpg::boundary "x=-$x2 y=$y2;y=$y1;x=-$x1;y=$y2;x=-$x2;"
        for {set ix 0} {$ix < $Nx} {incr ix} {
            set xx1 [expr {$x1+$U($pas)+$ix*($U($pas)+2*$Ls2($pas))}]
            set xx2 [expr {$xx1 + 2*$Ls2($pas)}]
            set yy1 [expr {$y1 + 2*$Ls2($pas)}]
            set yy2 [expr {$yy1 + $U($pas)}]
            tpg::boundary "x=$xx1 y=$yy2;y=$yy1;x=$xx2;y=$yy2;x=$xx1;"
            set xx1 [expr {-$x2+$ix*($U($pas)+2*$Ls2($pas))}]
            set xx2 [expr {$xx1 + 2*$Ls2($pas)}]
            tpg::boundary "x=$xx1 y=$yy2;y=$yy1;x=$xx2;y=$yy2;x=$xx1;"
        }
    }
    set y1 [expr {-$Lys2 + $iy*($U($pas)+2*$Ls2($pas))}]
    set y2 [expr {$y1+2*$Ls2($pas)}]
    tpg::boundary "x=$x1 y=$y2;y=$y1;x=$x2;y=$y2;x=$x1;"
    tpg::boundary "x=-$x2 y=$y2;y=$y1;x=-$x1;y=$y2;x=-$x2;"
}


proc grillesAcces.faussesEtRapides {c pas x1} {
    global Marge_o U Ls2 Xc Yc

puts stderr "ATTENTION, FAUSSES GRILLES FAUSSES GRILLES FAUSSES GRILLES"

    set Nx [expr {int(ceil(double($Marge_o)/double($U($pas)+2*$Ls2($pas))))}]
    set Lx [expr {$Nx*($U($pas)+2*$Ls2($pas))}]
    set Ny [expr {int(floor(double(2*$Yc($c)-2*$Ls2($pas))/double($U($pas)+2*$Ls2($pas))))}]
    set Lys2 [expr {$Ny*($U($pas)+2*$Ls2($pas))/2+$Ls2($pas)}]
    set x2 [expr {$x1+$Lx}]
    for {set iy 0} {$iy < $Ny} {incr iy} {
        set y1 [expr {-$Lys2 + $iy*($U($pas)+2*$Ls2($pas))}]
        set y2 [expr {$y1+2*$Ls2($pas)}]
        tpg::boundary "x=$x1 y=$y2;y=$y1;x=$x2;y=$y2;x=$x1;"
        tpg::boundary "x=-$x2 y=$y2;y=$y1;x=-$x1;y=$y2;x=-$x2;"
    }
    set y1 [expr {-$Lys2 + $iy*($U($pas)+2*$Ls2($pas))}]
    set y2 [expr {$y1+2*$Ls2($pas)}]
    tpg::boundary "x=$x1 y=$y2;y=$y1;x=$x2;y=$y2;x=$x1;"
    tpg::boundary "x=-$x2 y=$y2;y=$y1;x=-$x1;y=$y2;x=-$x2;"
}

# Raccord intégré au masque optique

proc raccordAcces {c pas x1} {
    global Marge_o U Ls2 Xc Yc

    set Nx [expr {int(ceil(double($Marge_o)/double($U($pas)+2*$Ls2($pas))))}]
    set Lx [expr {$Nx*($U($pas)+2*$Ls2($pas))}]
    set Ny [expr {int(floor(double(2*$Yc($c)-2*$Ls2($pas))/double($U($pas)+2*$Ls2($pas))))}]
    set Lys2 [expr {$Ny*($U($pas)+2*$Ls2($pas))/2+$Ls2($pas)}]
    set x2 [expr {$x1+$Lx}]
    set xm [expr {$x1+($x2-$x1)/2}]
    set y1 [expr {-$Lys2}]
    set y2 [expr {-$Lys2 + $Ny*($U($pas)+2*$Ls2($pas)) + 2*$Ls2($pas)}]
    tpg::boundary "x=$xm y=$y2;y=$y1;x=150000 y=-110000;y=110000; x=$xm y=$y2;"
    tpg::boundary "x=-$xm y=$y2;x=-150000 y=110000;y=-110000;x=-$xm y=$y1;y=$y2;"
}


proc inJeolChip {subfield chipx chipy xo yo transform jeolname origname} {
    # xo yo : coordonnées actuelles du coin haut-gauche
    if {$chipx % $subfield || $chipy % $subfield} {
        return -code error {Chipsize doit être (pour l'instant) un multiple de 10um}
    }
    tpg::Struct::new $jeolname
    ::tpg::Struct::eclateIn+transform $jeolname $origname [expr {$xo}] [expr {-$yo}] $transform
    tpg::setLayer 63 ;# sous-champs
    for {set x 0} {$x < $chipx} {incr x $subfield} {
        tpg::setDose 63
        for {set y 0} {$y > -$chipy} {incr y -$subfield} {
            tpg::boundary "x=$x y=$y;v$subfield;>$subfield;^$subfield;<$subfield;"
        }
    }
}

button .b -text commande -command {
    package require fidev
    catch {package forget fidev; package forget tpg}
    package require fidev
    package require trig_sun
    package require tpg
    raise .

    set DEBUG 0
    tpg::setLayer 0

    set quadrillage {
        dose réseau(métal=L, air=I) = L/(I+L)
        dose quadrillage (métal=L, air=U) = (2*U*L+L^2)/((U+L)^2)
        => U^2 - 2*L*U - I*L = 0
        => U = I*(1+sqrt(1+L/I))
    }


    set Is2(150) 475
    set Ls2(150) 275
    set U(150)  2100 ;# rendu multiple pair de 25

    set Is2(200) 600
    set Ls2(200) 400
    set U(200)  2750 ;# rendu rendu multiple pair de 25

    set Ya     120000

    set Xc(20) 100000
    set Xc(10)  50000
    set Xc(5)   25000
    set Xc(3)   15000
    set Yc(20) 100000
    set Yc(10)  50000
    set Yc(5)   25000
    set Yc(3)   15000

    set Marge_o 40000 ;# Marge optique

    set Marge_i  2000 ;# marge libre interdigités
    
    foreach c {3 5 10 20} {
	
	set cc [format %02d $c]
        #        tpg::Struct::new centre${cc}_cc
        #        tpg::setDose 0
        #        tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c);x=$Xc($c);x=$Xa y=-$Ya;y=$Ya;x=$Xc($c) y=$Yc($c);x=-$Yc($c);x=-$Xa y=$Ya;"
        
        tpg::setDose 0
        foreach pas {150 200} {
            set pasA [expr {$pas*10}]
            if {$pasA != 2*($Is2($pas)+$Ls2($pas))} {
                return -code error "pasA = $pasA, Is2($pas) = $Is2($pas), Ls2($pas) = $Ls2($pas)"
            }

	    tpg::Struct::new centre${cc}_i_$pas
            set Nys2 [expr {int(floor(double($Yc($c) - $Is2($pas) - 2*$Ls2($pas))/double($pasA)))}]
            set Xm [expr {$Xc($c) - $Marge_i}]
            set Xr [expr {$Xc($c)}]
            for {set iy 0} {$iy <= 2*$Nys2} {incr iy 2} {
                set y1 [expr {- $Is2($pas) - 2*$Ls2($pas) + ($iy - $Nys2)*($pasA)}]
                set y2 [expr {$y1 + 2*$Ls2($pas)}]
                tpg::boundary "x=-$Xr y=$y2;y=$y1;x=$Xm;y=$y2;x=-$Xr;"
                incr y1 $pasA; incr y2 $pasA
                tpg::boundary "x=-$Xm y=$y2;y=$y1;x=$Xr;y=$y2;x=-$Xm;"
            }
            set xm [expr {$Xr+2*$Ls2($pas)}]
            tpg::boundary "x=$Xr y=$Yc($c);y=-$Yc($c);x=$xm;y=$Yc($c);x=$Xr;"
            tpg::boundary "x=-$xm y=$Yc($c);y=-$Yc($c);x=-$Xr;y=$Yc($c);x=-$xm;"
            grillesAcces $c $pas $xm

            tpg::Struct::new raccord${cc}_i_$pas
            raccordAcces $c $pas $xm
        }
    }

    tpg::Struct::new croix80_
    tpg::setLayer 0
    tpg::setDose 0
    tpg::boundary "x=-20000 y=400000;y=20000;x=-400000;y=-20000;x=-20000;y=-400000;x=20000;y=-20000;x=400000;y=20000;x=20000;y=400000;x=-20000;"

    foreach c {3 5 10 20} {
	set cc [format %02d $c]
        foreach pas {150 200} {
	    inJeolChip 100000 300000 300000 -150000 150000 rotation90 [string toupper centre${cc}mip$pas] centre${cc}_i_$pas
        }
    }

    inJeolChip 100000 800000 800000 -400000 400000 rotation90 CROIX80 croix80_

set fichiers {
 [1,3]STEPH601D.LTL;1     12.        24-APR-02 16:37
[gian]STEPH402A.LTL;2     9.         29-APR-02 12:42
 [fab]STEPH402A.LTL;2     9.         16-MAY-02 11:11
 [fab]STEPHOPT3.LTL;2     1.         03-JUN-02 17:11
 [fab]STEPHOPT4.LTL;1     1.         03-JUN-02 17:01




}


#steph402a.ltl    
        
    set PN(1)  CENTRE05MIP150
    set PN(2)  CENTRE10MIP150
    set PN(3)  CENTRE03MIP150
    set PN(4)  CENTRE05MIP150
    set PN(5)  CENTRE10MIP150
    set PN(6)  CENTRE20MIP150
    set PN(7)  CENTRE03MIP150
    set PN(8)  CENTRE05MIP150
    set PN(9)  CENTRE10MIP150
    set PN(10) CENTRE10MIP150

    set PN(11) CENTRE05MIP200
    set PN(12) CENTRE10MIP200
    set PN(13) CENTRE03MIP200
    set PN(14) CENTRE05MIP200
    set PN(15) CENTRE10MIP200
    set PN(16) CENTRE20MIP200
    set PN(17) CENTRE03MIP200
    set PN(18) CENTRE05MIP200
    set PN(19) CENTRE10MIP200
    set PN(20) CENTRE10MIP200

    set PN(21) CROIX80

    set ltl {
		PN(1)-> ((1,1),SHOT0);
		PN(2)-> ((1,2),SHOT0);
		PN(3)-> ((1,3),SHOT0);
		PN(4)-> ((1,4),SHOT0);
		PN(5)-> ((1,5),SHOT0);
		PN(6)-> ((1,6),SHOT0);
		PN(7)-> ((1,7),SHOT0);
		PN(8)-> ((1,8),SHOT0);
		PN(9)-> ((1,9),SHOT0);
		PN(10)-> ((1,10),SHOT0);
                PN(21)-> ((1,11),SHOT0);
		PN(11)-> ((2,1),SHOT10);
		PN(12)-> ((2,2),SHOT10);
		PN(13)-> ((2,3),SHOT10);
		PN(14)-> ((2,4),SHOT10);
		PN(15)-> ((2,5),SHOT10);
		PN(16)-> ((2,6),SHOT10);
		PN(17)-> ((2,7),SHOT10);
		PN(18)-> ((2,8),SHOT10);
		PN(19)-> ((2,9),SHOT10);
		PN(20)-> ((2,10),SHOT10);
		PN(1)-> ((3,1),SHOT1);
		PN(2)-> ((3,2),SHOT1);
		PN(3)-> ((3,3),SHOT1);
		PN(4)-> ((3,4),SHOT1);
		PN(5)-> ((3,5),SHOT1);
		PN(6)-> ((3,6),SHOT1);
		PN(7)-> ((3,7),SHOT1);
		PN(8)-> ((3,8),SHOT1);
		PN(9)-> ((3,9),SHOT1);
		PN(10)-> ((3,10),SHOT1);
                PN(21)-> ((3,11),SHOT0);
		PN(11)-> ((4,1),SHOT11);
		PN(12)-> ((4,2),SHOT11);
		PN(13)-> ((4,3),SHOT11);
		PN(14)-> ((4,4),SHOT11);
		PN(15)-> ((4,5),SHOT11);
		PN(16)-> ((4,6),SHOT11);
		PN(17)-> ((4,7),SHOT11);
		PN(18)-> ((4,8),SHOT11);
		PN(19)-> ((4,9),SHOT11);
		PN(20)-> ((4,10),SHOT11);
		PN(1)-> ((5,1),SHOT2);
		PN(2)-> ((5,2),SHOT2);
		PN(3)-> ((5,3),SHOT2);
		PN(4)-> ((5,4),SHOT2);
		PN(5)-> ((5,5),SHOT2);
		PN(6)-> ((5,6),SHOT2);
		PN(7)-> ((5,7),SHOT2);
		PN(8)-> ((5,8),SHOT2);
		PN(9)-> ((5,9),SHOT2);
		PN(10)-> ((5,10),SHOT2);
                PN(21)-> ((5,11),SHOT0);
		PN(11)-> ((6,1),SHOT12);
		PN(12)-> ((6,2),SHOT12);
		PN(13)-> ((6,3),SHOT12);
		PN(14)-> ((6,4),SHOT12);
		PN(15)-> ((6,5),SHOT12);
		PN(16)-> ((6,6),SHOT12);
		PN(17)-> ((6,7),SHOT12);
		PN(18)-> ((6,8),SHOT12);
		PN(19)-> ((6,9),SHOT12);
		PN(20)-> ((6,10),SHOT12);
		PN(1)-> ((7,1),SHOT3);
		PN(2)-> ((7,2),SHOT3);
		PN(3)-> ((7,3),SHOT3);
		PN(4)-> ((7,4),SHOT3);
		PN(5)-> ((7,5),SHOT3);
		PN(6)-> ((7,6),SHOT3);
		PN(7)-> ((7,7),SHOT3);
		PN(8)-> ((7,8),SHOT3);
		PN(9)-> ((7,9),SHOT3);
		PN(10)-> ((7,10),SHOT3);
                PN(21)-> ((7,11),SHOT0);
		PN(11)-> ((8,1),SHOT13);
		PN(12)-> ((8,2),SHOT13);
		PN(13)-> ((8,3),SHOT13);
		PN(14)-> ((8,4),SHOT13);
		PN(15)-> ((8,5),SHOT13);
		PN(16)-> ((8,6),SHOT13);
		PN(17)-> ((8,7),SHOT13);
		PN(18)-> ((8,8),SHOT13);
		PN(19)-> ((8,9),SHOT13);
		PN(20)-> ((8,10),SHOT13);
		PN(1)-> ((9,1),SHOT4);
		PN(2)-> ((9,2),SHOT4);
		PN(3)-> ((9,3),SHOT4);
		PN(4)-> ((9,4),SHOT4);
		PN(5)-> ((9,5),SHOT4);
		PN(6)-> ((9,6),SHOT4);
		PN(7)-> ((9,7),SHOT4);
		PN(8)-> ((9,8),SHOT4);
		PN(9)-> ((9,9),SHOT4);
		PN(10)-> ((9,10),SHOT4);
                PN(21)-> ((9,11),SHOT0);
		PN(11)-> ((10,1),SHOT14);
		PN(12)-> ((10,2),SHOT14);
		PN(13)-> ((10,3),SHOT14);
		PN(14)-> ((10,4),SHOT14);
		PN(15)-> ((10,5),SHOT14);
		PN(16)-> ((10,6),SHOT14);
		PN(17)-> ((10,7),SHOT14);
		PN(18)-> ((10,8),SHOT14);
		PN(19)-> ((10,9),SHOT14);
		PN(20)-> ((10,10),SHOT14);
		PN(1)-> ((11,1),SHOT5);
		PN(2)-> ((11,2),SHOT5);
		PN(3)-> ((11,3),SHOT5);
		PN(4)-> ((11,4),SHOT5);
		PN(5)-> ((11,5),SHOT5);
		PN(6)-> ((11,6),SHOT5);
		PN(7)-> ((11,7),SHOT5);
		PN(8)-> ((11,8),SHOT5);
		PN(9)-> ((11,9),SHOT5);
		PN(10)-> ((11,10),SHOT5);
                PN(21)-> ((11,11),SHOT0);
		PN(11)-> ((12,1),SHOT15);
		PN(12)-> ((12,2),SHOT15);
		PN(13)-> ((12,3),SHOT15);
		PN(14)-> ((12,4),SHOT15);
		PN(15)-> ((12,5),SHOT15);
		PN(16)-> ((12,6),SHOT15);
		PN(17)-> ((12,7),SHOT15);
		PN(18)-> ((12,8),SHOT15);
		PN(19)-> ((12,9),SHOT15);
		PN(20)-> ((12,10),SHOT15);
		PN(1)-> ((13,1),SHOT6);
		PN(2)-> ((13,2),SHOT6);
		PN(3)-> ((13,3),SHOT6);
		PN(4)-> ((13,4),SHOT6);
		PN(5)-> ((13,5),SHOT6);
		PN(6)-> ((13,6),SHOT6);
		PN(7)-> ((13,7),SHOT6);
		PN(8)-> ((13,8),SHOT6);
		PN(9)-> ((13,9),SHOT6);
		PN(10)-> ((13,10),SHOT6);
                PN(21)-> ((13,11),SHOT0);
		PN(11)-> ((14,1),SHOT16);
		PN(12)-> ((14,2),SHOT16);
		PN(13)-> ((14,3),SHOT16);
		PN(14)-> ((14,4),SHOT16);
		PN(15)-> ((14,5),SHOT16);
		PN(16)-> ((14,6),SHOT16);
		PN(17)-> ((14,7),SHOT16);
		PN(18)-> ((14,8),SHOT16);
		PN(19)-> ((14,9),SHOT16);
		PN(20)-> ((14,10),SHOT16);
    }
    
    # pdl dx = 250, dy = 500
    
    proc place {s chipx chipy li co} {
        global OFFX OFFY PASX PASY

# puts stderr "place $s $chipx $chipy $li $co"

        tpg::sref $s [expr {$OFFX + $PASX*($co-1) - $chipx/2}] [expr {$OFFY - $PASY*($li-1) + $chipy/2}]
    }

    tpg::Struct::new centres
    tpg::setLayer 0
    tpg::setDose  0

    set OFFX 0 ;# -11250000
    set OFFY 0 ;# 32500000
    set PASX 2500000
    set PASY 5000000

    for {set li 1} {$li <= 14} {incr li} {
        place CENTRE05MIP150 300000 300000 $li 1
        place CENTRE10MIP150 300000 300000 $li 2
        place CENTRE03MIP150 300000 300000 $li 3
        place CENTRE05MIP150 300000 300000 $li 4
        place CENTRE10MIP150 300000 300000 $li 5
        place CENTRE20MIP150 300000 300000 $li 6
        place CENTRE03MIP150 300000 300000 $li 7
        place CENTRE05MIP150 300000 300000 $li 8
        place CENTRE10MIP150 300000 300000 $li 9
        place CENTRE20MIP150 300000 300000 $li 10

        place CROIX80        800000 800000 $li 11                     

        incr li

        place CENTRE05MIP200 300000 300000 $li 1
        place CENTRE10MIP200 300000 300000 $li 2
        place CENTRE03MIP200 300000 300000 $li 3
        place CENTRE05MIP200 300000 300000 $li 4
        place CENTRE10MIP200 300000 300000 $li 5
        place CENTRE20MIP200 300000 300000 $li 6
        place CENTRE03MIP200 300000 300000 $li 7
        place CENTRE05MIP200 300000 300000 $li 8
        place CENTRE10MIP200 300000 300000 $li 9
        place CENTRE20MIP200 300000 300000 $li 10
    }

    puts stderr centresRedresses...
    ::tpg::Struct::copieAllWithPrefix+transform rotation90 r90 centres
    ::tpg::Struct::copieAllWithPrefix+transform miroir.axex m r90centres
    puts stderr ...done

#    tpg::displayWinStruct2 mr90centres 0 0 0.0001

###############################

    tpg::setLayer 0
    tpg::setDose 0

    tpg::Struct::new pads
    tpg::boundary "x=-1600000 y=1250000;y=960000;x=-100000 y=240000;x=100000;x=1600000 y=960000; y=1250000;x=-1600000;"
    tpg::boundary "x=1600000 y=-1250000;y=-960000;x=100000 y=-240000;x=-100000;x=-1600000 y=-960000; y=-1250000;x=1600000;"
    tpg::boundary "x=-1600000 y=400000;y=-400000;x=-150000 y=-110000;y=110000;x=-1600000 y=400000;"
    tpg::boundary "x=1600000 y=-400000;y=400000;x=150000 y=110000;y=-110000;x=1600000 y=-400000;"
    
    tpg::Struct::new extra_pad_bas
    tpg::boundary "x=-1600000 y=-1250000; y=-1500000;x=1600000;y=-1250000;x=-1600000;"

    tpg::Struct::new extra_pad_haut
    tpg::boundary "x=1600000 y=1250000; y=1500000;x=-1600000;y=1250000;x=1600000;"

    tpg::Struct::new viseur
    tpg::boundary "  x=40000  y=-400000;>60000;^200000;<60000;v200000;"
    tpg::boundary "x=-100000  y=-400000;>60000;^200000;<60000;v200000;"
    tpg::boundary "x=-100000   y=200000;>60000;^200000;<60000;v200000;"
    tpg::boundary "  x=40000   y=200000;>60000;^200000;<60000;v200000;"

    tpg::boundary "x=-400000   y=40000;>200000;^60000;<200000;v60000;"
    tpg::boundary "x=-400000  y=-100000;>200000;^60000;<200000;v60000;"
    tpg::boundary " x=200000   y=40000;>200000;^60000;<200000;v60000;"
    tpg::boundary " x=200000  y=-100000;>200000;^60000;<200000;v60000;"

    tpg::boundary "  x=60000    y=40000;^20000;<120000;v20000;>120000;"
    tpg::boundary "  x=60000   y=-60000;^20000;<120000;v20000;>120000;"
    tpg::boundary "  x=40000    y=40000;v80000;>20000;^80000;<20000;"
    tpg::boundary " x=-60000    y=40000;v80000;>20000;^80000;<20000;"

    tpg::Struct::new contacts

    set ybas [expr {-50000000 + 500000}]
    for {set ix 0} {$ix < 2} {incr ix} {
        set x [expr {$ix*5000000}]
        tpg::sref extra_pad_bas $x $ybas
        for {set iy 0} {$iy < 10} {incr iy} {
            set y [expr {$ybas + $iy*2500000}]
            tpg::sref pads $x $y
        }
        tpg::sref extra_pad_haut $x $y
    }

    set OFFX   150000
    set OFFY -27150000
    set PASX 5000000
    set PASY 2500000

    place raccord05_i_150 300000 300000 1 1
    place raccord10_i_150 300000 300000 2 1
    place raccord03_i_150 300000 300000 3 1
    place raccord05_i_150 300000 300000 4 1
    place raccord10_i_150 300000 300000 5 1
    place raccord20_i_150 300000 300000 6 1
    place raccord03_i_150 300000 300000 7 1
    place raccord05_i_150 300000 300000 8 1
    place raccord10_i_150 300000 300000 9 1
    place raccord20_i_150 300000 300000 10 1

    tpg::sref viseur [expr {$OFFX - 150000}] [expr {$OFFY - 25000000 + 150000}]

    place raccord05_i_200 300000 300000 1 2
    place raccord10_i_200 300000 300000 2 2
    place raccord03_i_200 300000 300000 3 2
    place raccord05_i_200 300000 300000 4 2
    place raccord10_i_200 300000 300000 5 2
    place raccord20_i_200 300000 300000 6 2
    place raccord03_i_200 300000 300000 7 2
    place raccord05_i_200 300000 300000 8 2
    place raccord10_i_200 300000 300000 9 2
    place raccord20_i_200 300000 300000 10 2

    ###############

    tpg::Struct::new lb
    tpg::boundary "x=0 y=500000;>80000000;^100000;<80000000;v100000;"

    tpg::Struct::new lg
    tpg::boundary "x=400000 y=29500000;y=0;>100000; y=29500000;<100000;"

    inJeolChip 1000000 10000000 30000000 1600000 -25500000 identite CONTACTS contacts
    inJeolChip 1000000 80000000 1000000  0  1000000 identite LB lb
    inJeolChip 1000000 1000000  30000000 0 30000000 identite LG lg



    tpg::Struct::new toutinverse

    tpg::sref mr90centres -32400000 13500000

    set OFFX -29000000
    set OFFY  0
    set PASX  10000000
    set PASY  30000000

    place CONTACTS 10000000 30000000 1 1
    place CONTACTS 10000000 30000000 1 2
    place CONTACTS 10000000 30000000 1 3
    place CONTACTS 10000000 30000000 1 4
    place CONTACTS 10000000 30000000 1 5
    place CONTACTS 10000000 30000000 1 6
    place CONTACTS 10000000 30000000 1 7

    set OFFX 0
    set OFFY 20000000
    set PASX 80000000
    set PASY 1000000
    
    place LB 80000000 1000000 1 1

    set OFFX -39900000
    set OFFY  5500000
    set PASX  1000000
    set PASY 30000000

    place LG 1000000 30000000 1 1


    tpg::displayWinStruct2 toutinverse 0 0 0.0001

    set time [file mtime $SCRIPT]

    tpg::displayWinStruct2 CONTACTS 0 0 0.0001


    tpg::outGds2 CONTACTS CONTACTS $DIROUT $time 1 1e-10
    tpg::outGds2 LB LB $DIROUT $time 1 1e-10
    tpg::outGds2 LG LG $DIROUT $time 1 1e-10


    tpg::displayWinStruct2 CROIX80 0 0 0.001
    tpg::outGds2 croix80 croix80 $DIROUT $time 1 1e-10

    if {1} {

    foreach c {10 20 3 5} {
	set cc [format %02d $c]
        foreach pas {150 200} {
	    tpg::displayWinStruct2 CENTRE${cc}MIP$pas 0 0 0.001
	    tpg::outGds2 CENTRE${cc}MIP$pas CENTRE${cc}MIP$pas $DIROUT $time 1 1e-10
        }
    }
}
    
}
pack .b


set toj01 {

    ATTENTION, gds2tojeol01 ne marche que sur yoko ou xan (décembre 2003)

    cd ~/W/Z/msm2.2003.12
    foreach f [glob *.gds] {
        set s [string range $f 0 end-4]
        /home/fab/C/fidev-SparcSolarisForte7-optim/c/gds2/src/gds2tojeol01 -e25 -C -y -j$s.j01 -r$s -l0 $s.gds
    }
    bash$ for s in CONTACTS LB LG
          do /home/fab/C/fidev-SparcSolarisForte7-optim/c/gds2/src/gds2tojeol01 -e25 -C -y -j$s.j01 -r$s -l0 $s.gds
          done


}



    set rien {
        tpg::Struct::new croix40_1
        tpg::setLayer 0
            tpg::setDose 0
            set b [tpg::boundary ";Iv350;E>50;^100;>100;^100;>100;^100;>100;^50;I<350;"]
        set c [tpg::getChemin $b]
        tpg::Chemin::transform c miroir.axex
        tpg::bfc $c
        tpg::Chemin::transform c miroir.axey
        tpg::bfc $c
        tpg::Chemin::transform c miroir.axex
        tpg::bfc $c
    }
    

