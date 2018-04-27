#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

set tcl_traceExec 0
set tcl_traceCompile 0

set SCRIPT [info script]


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


    set Is2(150) 47
    set Ls2(150) 28
    set U(150)  213

    set Is2(200) 60
    set Ls2(200) 40
    set U(200)  275

#    set Xa     20000
    set Ya     12000

#    set Xc(20) 10000
#    set Xc(10)  5000
#    set Yc(20) 10000
#    set Yc(10)  5000

    set Marge_o 4000 ;# Marge optique

    set Marge_i  200 ;# marge libre interdigités
#    set Marge_b  200 ;# marge pour bien dessiner une linite de gros tas
#    set Marge_r   50 ;# marge recouvrement interdigités

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

        foreach pas {150 200} {
            tpg::Struct::new centre${c}_1_$pas
            tpg::setDose 0
            set xb $Is2($pas)
            set xm [expr {$xb+$Marge_b}]
            tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c);x=-$xm;y=$Yc($c);x=-$Yc($c);x=-$Xa y=$Ya;"
            tpg::boundary "x=$Xa y=-$Ya;y=$Ya; x=$Xc($c)  y=$Yc($c); x=$xm;y=-$Yc($c); x=$Yc($c); x=$Xa y=-$Ya;"

            tpg::boundary "x=-$xm y=$Yc($c);y=-$Yc($c);x=-$xb;y=$Yc($c);x=-$xm;"
            tpg::boundary "x=$xm y=-$Yc($c);y=$Yc($c);x=$xb;y=-$Yc($c);x=$xm;"

            tpg::Struct::new centre${c}_2_$pas
            set xb [expr {2*$Is2($pas) + 2*$Ls2($pas)}]
            set xm [expr {$xb + $Marge_b}]
            tpg::setDose 0
            tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c);x=-$xm;y=$Yc($c);x=-$Yc($c);x=-$Xa y=$Ya;"
            tpg::boundary "x=$Xa y=-$Ya;y=$Ya; x=$Xc($c)  y=$Yc($c); x=$xm;y=-$Yc($c); x=$Yc($c); x=$Xa y=-$Ya;"
            tpg::setDose 1
            tpg::boundary "x=-$xm        y=$Yc($c);y=-$Yc($c);x=-$xb;      y=$Yc($c);x=-$xm;"
            tpg::boundary "x=-$Ls2($pas) y=$Yc($c);y=-$Yc($c);x=$Ls2($pas);y=$Yc($c);x=-$Ls2($pas);"
            tpg::boundary "x=$xb         y=$Yc($c);y=-$Yc($c);x=$xm;       y=$Yc($c);x=$xb;"

            tpg::Struct::new centre${c}_3_$pas
            set x2 [expr {-3*$Is2($pas) - 2*$Ls2($pas)}]
            puts -nonewline stderr "$x2 -> "
            tpg::setDose 0
            set xm [expr {$x2-$Marge_b}]
            tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c);x=$xm;y=$Yc($c);x=-$Yc($c);x=-$Xa y=$Ya;"
            tpg::setDose 1
            tpg::boundary "x=$xm y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$xm;"            
            incr x2 $pas
            set x1 [expr {$x2 - 2*$Ls2($pas)}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            incr x1 $pas
            incr x2 $pas
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            incr x1 $pas
            set xm [expr {$x1+$Marge_b}]
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$xm;y=$Yc($c);x=$x1;"
            tpg::setDose 0
            tpg::boundary "x=$Xa y=-$Ya;y=$Ya; x=$Xc($c)  y=$Yc($c); x=$xm;y=-$Yc($c); x=$Yc($c); x=$Xa y=-$Ya;"
            puts stderr "$x1"

            tpg::Struct::new centre${c}_n_$pas
            set x2 [expr {3*$Is2($pas) + 2*$Ls2($pas)}]
            set x2 [expr {-($x2 + (($Xc($c) - $x2)/$pas)*$pas)}]
            tpg::setDose 0
            set xm [expr {$x2-$Marge_b}]
            tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=$xm y=-$Yc($c);y=$Yc($c);x=-$Xa y=$Ya;"
            tpg::setDose 2
            tpg::boundary "x=$xm y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$xm;"
            puts -nonewline stderr "$x2 -> "
            tpg::setDose 3
            for {incr x2 $pas; set x1 [expr {$x2 - 2*$Ls2($pas)}]} {$x1+$pas <= $Xc($c)} {incr x1 $pas; incr x2 $pas} {
                tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$x2;y=$Yc($c);x=$x1;"
            }
            puts stderr $x1
            set xm [expr {$x1+$Marge_b}]
            tpg::setDose 2
            tpg::boundary "x=$x1 y=$Yc($c);y=-$Yc($c);x=$xm;y=$Yc($c);x=$x1;"
            tpg::setDose 0
            tpg::boundary "x=$Xa y=-$Ya;y=$Ya; x=$xm y=$Yc($c); y=-$Yc($c); x=$Xa y=-$Ya;"

            tpg::Struct::new centre${c}_i_$pas
            tpg::setDose 0
            tpg::boundary "x=-$Xa y=$Ya;y=-$Ya;x=-$Xc($c) y=-$Yc($c); y=$Yc($c);x=-$Xa y=$Ya;"
            tpg::boundary "x=$Xa y=-$Ya;y=$Ya; x=$Xc($c)  y=$Yc($c); y=-$Yc($c);x=$Xa y=-$Ya;"
            set y2 [expr {3*$Is2($pas) + 2*$Ls2($pas)}]
            set y2 [expr {-($y2 + (($Yc($c) - $y2)/$pas)*$pas)}]
            puts -nonewline stderr "$y2 -> "
            set Xm [expr {$Xc($c) - $Marge_i}]
            set Xr [expr {$Xc($c) + $Marge_r}]
            tpg::setDose 3
            for {incr y2 $pas; set y1 [expr {$y2 - 2*$Ls2($pas)}]} {$y1+$pas <= $Yc($c)} {incr y1 $pas; incr y2 $pas} {
                tpg::boundary "x=-$Xr y=$y2;y=$y1;x=$Xm;y=$y2;x=-$Xr;"
                incr y1 $pas; incr y2 $pas
                tpg::boundary "x=-$Xm y=$y2;y=$y1;x=$Xr;y=$y2;x=-$Xm;"
            }
            puts stderr $y1


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
    
    tpg::Struct::new croix80
    tpg::setLayer 0
    tpg::setDose 4
    tpg::boundary "x=-2000 y=40000;y=2000;x=-40000;y=-2000;x=-2000;y=-40000;x=2000;y=-2000;x=40000;y=2000;x=2000;y=40000;x=-2000;"

    tpg::Struct::new croix
    tpg::sref croix80     0 0
    tpg::sref croix80     0 80000
    tpg::sref croix80 80000 0
    tpg::sref croix80 80000 80000
    tpg::sref croix80 160000 0
    tpg::sref croix80 160000 80000
    
    tpg::Struct::new centres
    tpg::sref centre20_cc         0       0
    tpg::sref centre20_1_150      0  250000
    tpg::sref centre20_1_200      0  500000
    tpg::sref centre20_2_150      0  750000
    tpg::sref centre20_2_200      0 1000000
    tpg::sref centre20_3_150      0 1250000
    tpg::sref centre20_3_200      0 1500000
    tpg::sref centre20_n_150      0 1750000
    tpg::sref centre20_n_200      0 2000000
    tpg::sref centre20_i_150      0 2250000
    tpg::sref centre20_i_200      0 2500000

    tpg::sref centre10_cc    500000       0
    tpg::sref centre10_1_150 500000  250000
    tpg::sref centre10_1_200 500000  500000
    tpg::sref centre10_2_150 500000  750000
    tpg::sref centre10_2_200 500000 1000000
    tpg::sref centre10_3_150 500000 1250000
    tpg::sref centre10_3_200 500000 1500000
    tpg::sref centre10_n_150 500000 1750000
    tpg::sref centre10_n_200 500000 2000000
    tpg::sref centre10_i_150 500000 2250000
    tpg::sref centre10_i_200 500000 2500000

    tpg::sref croix -120000 2750000
    tpg::sref croix  460000 2750000


    tpg::setLayer 1
    tpg::setDose 0

    tpg::Struct::new pads
    tpg::boundary "x=-160000 y=125000;y=96000;x=-10000 y=24000;x=10000;x=160000 y=96000; y=125000;x=-160000;"
    tpg::boundary "x=160000 y=-125000;y=-96000;x=10000 y=-24000;x=-10000;x=-160000 y=-96000; y=-125000;x=160000;"
    tpg::boundary "x=-160000 y=40000;y=-40000;x=-15000 y=-11000;y=11000;x=-160000 y=40000;"
    tpg::boundary "x=160000 y=-40000;y=40000;x=15000 y=11000;y=-11000;x=160000 y=-40000;"

    tpg::Struct::new extra_pad1
    tpg::boundary "x=-160000 y=-125000; y=-150000;x=160000;y=-125000;x=-160000;"

    tpg::Struct::new extra_pad2
    tpg::boundary "x=160000 y=125000; y=150000;x=-160000;y=125000;x=160000;"

    tpg::Struct::new puce
    tpg::sref centres 0 0
    tpg::sref centres 1000000 0

    for {set ix 0} {$ix < 4} {incr ix} {
        set x [expr {$ix*500000}]
        tpg::sref extra_pad1 $x 0
        for {set iy 0} {$iy < 11} {incr iy} {
            set y [expr {$iy*250000}]
            tpg::sref pads $x $y
        }
        tpg::sref extra_pad2 $x $y
    }

    tpg::Struct::new puces
    for {set ix 0} {$ix < 20} {incr ix} {
        set x [expr {$ix*2000000}]
        for {set iy 0} {$iy < 5} {incr iy} {
            set y [expr {$iy*3500000}]
            tpg::sref puce $x $y
        }
    }


    tpg::displayWinStruct2 puces 0 0 0.01

    set time [file mtime $SCRIPT]
    tpg::outGds2 puces puces ~fab/Z $time 1 1e-9
}
pack .b
