#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

set tcl_traceExec 0
set tcl_traceCompile 0

set SCRIPT [info script]

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


proc inJeolChip {chipsize xo yo jeolname origname} {
    # xo yo : coordonnées actuelles du coin haut-gauche
    if {$chipsize % 100000} {
        return -code error {Chipsize doit être (pour l'instant) un multiple de 10um}
    }
    set moitie [expr {$chipsize/2}]
    tpg::Struct::new $jeolname
    ::tpg::Struct::eclateIn+transform $jeolname $origname [expr {$xo}] [expr {-$yo}] rotation90
    tpg::setLayer 63 ;# sous-champs
    for {set x 0} {$x < $chipsize} {incr x 100000} {
        tpg::setDose 63
        for {set y 0} {$y > -$chipsize} {incr y -100000} {
            tpg::boundary "x=$x y=$y;v100000;>100000;^100000;<100000;"
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
    set Yc(20) 100000
    set Yc(10)  50000

    set Marge_o 40000 ;# Marge optique

    set Marge_i  2000 ;# marge libre interdigités
    
    set doses {
        0 normale
        1 bord très entouré
        2 bord entouré moitié 100%, moitié 50%
        3 bord entouré 50%
        4 croix
    }
    
    foreach c {10 20} {
        

        #        tpg::Struct::new centre${c}_cc
        #        tpg::setDose 0
        #        tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c);x=$Xc($c);x=$Xa y=-$Ya;y=$Ya;x=$Xc($c) y=$Yc($c);x=-$Yc($c);x=-$Xa y=$Ya;"
        
        tpg::setDose 0
        foreach pas {150 200} {
            set pasA [expr {$pas*10}]
            if {$pasA != 2*($Is2($pas)+$Ls2($pas))} {
                return -code error "pasA = $pasA, Is2($pas) = $Is2($pas), Ls2($pas) = $Ls2($pas)"
            }

            tpg::Struct::new centre${c}_1_$pas
            set x1 $Is2($pas)
            set x2 [expr {$x1+2*$Ls2($pas)}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            tpg::boundary "x=-$x1 y=-$Yc($c);y=$Yc($c);x=-$x2;y=-$Yc($c);x=-$x1;"
            grillesAcces $c $pas $x2

            tpg::Struct::new centre${c}_2_$pas
            set xb [expr {2*$Is2($pas) + 2*$Ls2($pas)}]
            set xm [expr {$xb + 2*$Ls2($pas)}]
            tpg::boundary "x=-$xm        y=$Yc($c);y=-$Yc($c);x=-$xb;      y=$Yc($c);x=-$xm;"
            tpg::boundary "x=-$Ls2($pas) y=$Yc($c);y=-$Yc($c);x=$Ls2($pas);y=$Yc($c);x=-$Ls2($pas);"
            tpg::boundary "x=$xb         y=$Yc($c);y=-$Yc($c);x=$xm;       y=$Yc($c);x=$xb;"
            grillesAcces $c $pas $xm

            tpg::Struct::new centre${c}_3_$pas
            set x2 [expr {-3*$Is2($pas) - 2*$Ls2($pas)}]
            set xm [expr {$x2-2*$Ls2($pas)}]
            tpg::boundary "x=$xm y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$xm;"            
            incr x2 $pasA
            set x1 [expr {$x2 - 2*$Ls2($pas)}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            incr x1 $pasA
            incr x2 $pasA
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            incr x1 $pasA
            set xm [expr {$x1+2*$Ls2($pas)}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$xm;y=$Yc($c);x=$x1;"
            grillesAcces $c $pas $xm

            tpg::Struct::new centre${c}_n_$pas
            set x2 [expr {3*$Is2($pas) + 2*$Ls2($pas)}]
            set x2 [expr {-($x2 + (($Xc($c) - $x2)/$pasA)*$pasA)}]
            set xm [expr {$x2-2*$Ls2($pas)}]
            tpg::boundary "x=$xm y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$xm;"
            puts -nonewline stderr "$x2 -> "
            for {incr x2 $pasA; set x1 [expr {$x2 - 2*$Ls2($pas)}]} {$x1+$pasA <= $Xc($c)} {incr x1 $pasA; incr x2 $pasA} {
                tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            }
            puts stderr $x1
            set xm [expr {$x1+2*$Ls2($pas)}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$xm;y=$Yc($c);x=$x1;"
            grillesAcces $c $pas $xm

            tpg::Struct::new centre${c}_i_$pas
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
        }
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
    
    tpg::Struct::new croix80_
    tpg::setLayer 0
    tpg::setDose 0
    tpg::boundary "x=-20000 y=400000;y=20000;x=-400000;y=-20000;x=-20000;y=-400000;x=20000;y=-20000;x=400000;y=20000;x=20000;y=400000;x=-20000;"

    tpg::Struct::new 6croix
    tpg::sref croix80_     0 0
    tpg::sref croix80_     0 800000
    tpg::sref croix80_ 800000 0
    tpg::sref croix80_ 800000 800000
    tpg::sref croix80_ 1600000 0
    tpg::sref croix80_ 1600000 800000

    foreach c {10 20} {
        foreach pas {150 200} {
            foreach type {1 2 3 n i} {
                inJeolChip 300000 -150000 150000 centre${c}m${type}p$pas centre${c}_${type}_$pas
            }
        }
    }

    inJeolChip 800000 -400000 400000 croix80 croix80_
    
#    tpg::sref 6croix -120000 2750000
#    tpg::sref 6croix  460000 2750000


    
    tpg::Struct::new centres
#   tpg::sref centre20_cc         0       0
    tpg::sref centre20m1p150      0  2500000
    tpg::sref centre20m1p200      0  5000000
    tpg::sref centre20m2p150      0  7500000
    tpg::sref centre20m2p200      0 10000000
    tpg::sref centre20m3p150      0 12500000
    tpg::sref centre20m3p200      0 15000000
    tpg::sref centre20mnp150      0 17500000
    tpg::sref centre20mnp200      0 20000000
    tpg::sref centre20mip150      0 22500000
    tpg::sref centre20mip200      0 25000000

#    tpg::sref centre10_cc    500000       0
    tpg::sref centre10m1p150 5000000  2500000
    tpg::sref centre10m1p200 5000000  5000000
    tpg::sref centre10m2p150 5000000  7500000
    tpg::sref centre10m2p200 5000000 10000000
    tpg::sref centre10m3p150 5000000 12500000
    tpg::sref centre10m3p200 5000000 15000000
    tpg::sref centre10mnp150 5000000 17500000
    tpg::sref centre10mnp200 5000000 20000000
    tpg::sref centre10mip150 5000000 22500000
    tpg::sref centre10mip200 5000000 25000000

    tpg::setLayer 1
    tpg::setDose 0

    tpg::Struct::new pads
    tpg::boundary "x=-1600000 y=1250000;y=960000;x=-100000 y=240000;x=100000;x=1600000 y=960000; y=1250000;x=-1600000;"
    tpg::boundary "x=1600000 y=-1250000;y=-960000;x=100000 y=-240000;x=-100000;x=-1600000 y=-960000; y=-1250000;x=1600000;"
    tpg::boundary "x=-1600000 y=400000;y=-400000;x=-150000 y=-110000;y=110000;x=-1600000 y=400000;"
    tpg::boundary "x=1600000 y=-400000;y=400000;x=150000 y=110000;y=-110000;x=1600000 y=-400000;"

    tpg::Struct::new extra_pad1
    tpg::boundary "x=-1600000 y=-1250000; y=-1500000;x=1600000;y=-1250000;x=-1600000;"

    tpg::Struct::new extra_pad2
    tpg::boundary "x=1600000 y=1250000; y=1500000;x=-1600000;y=1250000;x=1600000;"

    tpg::Struct::new puce
    tpg::sref centres 0 0
    tpg::sref centres 10000000 0

    for {set ix 0} {$ix < 4} {incr ix} {
        set x [expr {$ix*5000000}]
        tpg::sref extra_pad1 $x 0
        for {set iy 0} {$iy < 11} {incr iy} {
            set y [expr {$iy*2500000}]
            tpg::sref pads $x $y
        }
        tpg::sref extra_pad2 $x $y
    }

    tpg::Struct::new puces
    for {set ix 0} {$ix < 20} {incr ix} {
        set x [expr {$ix*20000000}]
        for {set iy 0} {$iy < 5} {incr iy} {
            set y [expr {$iy*35000000}]
            tpg::sref puce $x $y
        }
    }

    tpg::displayWinStruct2 puces 0 0 0.01

    set time [file mtime $SCRIPT]
#    tpg::outGds2 puces puces ~fab/Z $time 1 1e-9


    if {0} {
    tpg::displayWinStruct2 croix80 0 0 0.001
    tpg::outGds2 croix80 croix80 ~fab/W/Z/msm $time 1 1e-10

    foreach c {10 20} {
        foreach pas {150 200} {
            foreach type {1 2 3 n i} {
                tpg::displayWinStruct2 centre${c}m${type}p$pas 0 0 0.001
                tpg::outGds2 centre${c}m${type}p$pas centre${c}m${type}p$pas ~fab/W/Z/msm $time 1 1e-10
            }
        }
    }
}
    
}
pack .b


set toj01 {
    cd ~/W/Z/msm
    foreach f [glob *.gds] {
        set s [string range $f 0 end-4]
        /home/fab/C/fidev-SparcSolarisForte7-optim/c/gds2/src/gds2tojeol01 -e25 -C -y -j$s.j01 -r$s -l0 $s.gds
    }
}
