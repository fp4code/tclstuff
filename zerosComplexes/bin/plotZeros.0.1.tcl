#!/usr/local/bin/wish

package require fidev
package require superWidgetsScroll
package require complexes 1.1

puts OK1
package require blas
puts OK2
package require eqvp
puts OK3

frame .f
pack .f -fill both -expand 1 -side left
frame .f2
frame .f3
button .f2.bp2 -text "x2" -command zp2
button .f2.bs2 -text "/2" -command zs2
button .f2.plot -text "plot" -command plotAll
button .f2.stop -text "stop" -command {set STOP 1}
pack .f3 -fill x -side top
pack .f2 -fill x -side bottom
pack .f2.bp2 -side left
pack .f2.bs2 -side left
pack .f2.stop -side right
pack .f2.plot -side right

frame .f3.d1
frame .f3.d2
frame .f3.d3
frame .f3.d4

grid configure .f3.d1 .f3.d2 .f3.d3 .f3.d4 -sticky news

foreach {e w} {eps1 30 eps2 30} {
    label .f3.l$e -text $e
    entry .f3.e$e -width $w -textvariable $e
    grid configure .f3.l$e .f3.e$e - - -sticky news
}

foreach {e1 w1 e2 w2} {polar 6 DZwarn 6 lambda 6 d 6 r 6 kx0N 6 XNm 6 XNp 6 YNm 6 YNp 6 DYMIN 6 divOfPeriod 6 DZM1 6 DZM2 6 dl 6 dtheta 6} {
    label .f3.l$e1 -text $e1
    entry .f3.e$e1 -width $w1 -textvariable $e1
    label .f3.l$e2 -text $e2
    entry .f3.e$e2 -width $w2 -textvariable $e2
    grid configure .f3.l$e1 .f3.e$e1 .f3.l$e2 .f3.e$e2 -sticky news
}

set polar TM
set DZwarn 1e-4
set eps1 [::complexes::newXY 12.5254 0.5593]
set eps2 [::complexes::newXY -140.4 3.555]
set lambda 1.55
set d 1.549
set r 0.70
set kx0N 0.0
set XNm -8.0 
set XNp 8.0
set YNm -6.0
set YNp 20.0
set NDMAX 100
set DYMIN 1e-6
set DZM1 1e-6
set DZM2 1e-12
set divOfPeriod 20
set dl 0.05
set dtheta 0.01
set ZOOM 64
set RACINES 1

set C [canvas .f.c]
widgets::gridWithXYScrollbars .f c

set xmin 0
set ymin 0
set width 201
set height 881
set w $width
set h $height
set xmax [expr {$xmin+$width-1}]
set ymax [expr {$ymin+$height-1}]
$C configure -scrollregion [list $xmin $ymin $xmax $ymax]
$C configure -borderwidth 2 -relief sunken

# Cf. man pgm ou ou man ppm
# autorisés : P5 et P6
# -channel et -data ne fonctionnent pas
proc testPlot {w xmin xmax h ymin ymax} {
    set data {}
    set fx [expr {double($xmax - $xmin)/double($w-1)}]
    set fy [expr {double($ymax - $ymin)/double($h-1)}]
    for {set ypix 0} {$ypix < $h} {incr ypix} {
	set y [expr {$ymax - $fy*$ypix}]  
	
	for {set xpix 0} {$xpix < $w} {incr xpix} {
	    set x [expr {$xmin + $fx*$xpix}]  
	    
	    set r [expr {sqrt($x*$x + $y*$y)}]
	    if {$r != 0.0} {
		set v [expr {sin($r)/$r}]
	    } else {
		set v 1.0
	    }
	    set v [expr {int(round($v*255.))}]
	    set v [binary format c $v]
	    append data $v$v$v
	}
	puts $ypix
    }
    return $data
}

proc verif {kappayN} {

    set z1 $kappayN
#    set dz [::complexes::newXY 0.000001 0.000003]
    set dz [::complexes::newXY 0.000000 0.000001]
    set z0 [::complexes::sub $z1 $dz]
    set z2 [::complexes::add $z1 $dz]
    
    foreach {u0 v0 w0} [c $z0] {}
    foreach {u1 v1 w1} [c $z1] {}
    foreach {u2 v2 w2} [c $z2] {}
    
    set du01 [::complexes::sub $u1 $u0]
    set du12 [::complexes::sub $u2 $u1]
    
    set v01 [::complexes::div $du01 $dz]
    set v12 [::complexes::div $du12 $dz]
    
    # vérification de la dérivée
    
    set erra [::complexes::module [::complexes::div $v01 $v1]]
    set errb [::complexes::module [::complexes::div $v12 $v1]]
    
    # vérification de la dérivée seconde
    
    set ddu [::complexes::sub $v12 $v01]
    set wa1 [::complexes::div $ddu $dz]
    
    set errc [::complexes::module [::complexes::div $wa1 $w1]]

    puts [list $u1 $v1 $w1 erreurs sur dérivées 1 et 2 en $kappayN : $errb, $errc]
}    

set verifs {

    verif [::complexes::newXY 0.45 1.1]
    verif [::complexes::newXY 10.1 1.1]
    verif [::complexes::newXY 10.1 -1.1]
    verif [::complexes::newXY 10.1 -10.1]
    verif [::complexes::newXY 0.2 -10.1]
}
    #

proc ps {eps1 eps2 d1N d2N kappayN} {

# angle nul

# approximations _a kappayN grand

    set kyN2 [::complexes::mul $kappayN $kappayN]
    set k1xN [::complexes::toXY [::complexes::sqrt [::complexes::sub $eps1 $kyN2]]]
    set k2xN [::complexes::toXY [::complexes::sqrt [::complexes::sub $eps2 $kyN2]]]

    set k1xN_a [::complexes::iMul [::complexes::mul\
	    $kappayN [::complexes::add 1.0 [::complexes::realMul -0.5\
	    [::complexes::div $eps1 $kyN2]]]]]
    set k2xN_a [::complexes::iMul [::complexes::mul\
	    $kappayN [::complexes::add 1.0 [::complexes::realMul -0.5\
	    [::complexes::div $eps2 $kyN2]]]]]

    set p1N [::complexes::div $k1xN $eps1]
    set p2N [::complexes::div $k2xN $eps2]

    set P [::complexes::realMul 0.5 [::complexes::add\
	    [::complexes::div $p1N $p2N] [::complexes::div $p2N $p1N]]]

    set P_a [::complexes::realMul 0.5 [::complexes::add\
	    [::complexes::div $eps1 $eps2] [::complexes::div $eps2 $eps1]]]
    
    set k1xd1f2N [::complexes::realMul [expr {2.0*$d1N}] $k1xN]
    set k2xd2f2N [::complexes::realMul [expr {2.0*$d2N}] $k2xN]

    set argplus  [::complexes::add $k1xd1f2N $k2xd2f2N]
    set argmoins [::complexes::sub $k1xd1f2N $k2xd2f2N]

    set cplus  [::complexes::cospi $argplus]
    set cmoins [::complexes::cospi $argmoins]

    set XN [::complexes::re $kappayN]
    set YN [::complexes::im $kappayN]

    global DEUXPI

    set cplus_a [::complexes::newXY [expr {cospi(2.0*$YN*($d1N+$d2N))*cosh($DEUXPI*$XN*($d1N+$d2N))}]\
	                            [expr {sinpi(2.0*$YN*($d1N+$d2N))*sinh($DEUXPI*$XN*($d1N+$d2N))}]]

    set tcplus  [::complexes::mul [::complexes::add [::complexes::realMul -0.5 $P] -0.5] $cplus]
    set tcmoins [::complexes::mul [::complexes::add [::complexes::realMul  0.5 $P] -0.5] $cmoins]

    set ps [::complexes::add $tcplus $tcmoins]

    set psautre [::complexes::add\
	    [complexes::mul -1.0 [complexes::mul [::complexes::cospi $k1xd1f2N] [::complexes::cospi $k2xd2f2N]]]\
	    [complexes::mul $P   [complexes::mul [::complexes::sinpi $k1xd1f2N] [::complexes::sinpi $k2xd2f2N]]]]
    
# approximations loin de l'axe imaginaire

    set cte [::complexes::add -0.25 [::complexes::realMul -0.125 [::complexes::add\
	[::complexes::div $eps2 $eps1] [::complexes::div $eps2 $eps1]]]]
    if {$XN < 0.0} {
	set XN [expr {-$XN}]
	set YN [expr {-$YN}]
    }

    set approx [::complexes::mul\
	    $cte [::complexes::newRTpi [expr {exp($XN*$DEUXPI*($d1N+$d2N))}] [expr {$YN*2.0*($d1N+$d2N)}]]]

    return $ps
}



proc deriv1_a {commande z dz} {
    set demi [::complexes::realMul 0.5 $dz]
    set c1 [concat $commande [list [::complexes::sub $z $demi]]]
    set c2 [concat $commande [list [::complexes::add $z $demi]]]
    set f1 [eval $c1]
    set f2 [eval $c2]
    return [::complexes::div [::complexes::sub $f2 $f1] $dz]
}

proc deriv2_a {commande z dz} {
    set c0 [concat $commande [list [::complexes::sub $z $dz]]]
    set c1 [concat $commande [list $z]]
    set c2 [concat $commande [list [::complexes::add $z $dz]]]
    set f0 [eval $c0]
    set f1 [eval $c1]
    set f2 [eval $c2]
    set db [::complexes::div [::complexes::sub $f2 $f1] $dz]
    set da [::complexes::div [::complexes::sub $f1 $f0] $dz]
    return [::complexes::div [::complexes::sub $db $da] $dz]
}

set rien {

    foreach {u v w} [c $kappayN] {}
    set dz [::complexes::newXY 0.000001 0.000003]
    
    set u
    ps $eps1 $eps2 $d1N $d2N $kappayN
    
    set v
    deriv1_a [list ps $eps1 $eps2 $d1N $d2N] $kappayN $dz
    
    set w
    deriv2_a [list ps $eps1 $eps2 $d1N $d2N] $kappayN $dz
}

proc d {Y} {
    foreach {u v w} [c [::complexes::newXY 10.0 $Y]] {}
    return [::complexes::arg $u]
}

#######################################################################
# démontre que pour une partie réel grande de kappay, les lignes 


proc plotMarges {eps1 eps2 d1N d2N kx0N XN YRacMin YRacMax} {
# les Y sont normalisés à l'indice de racine

    set NINTERVALLES 2000
    set dYRac [expr {($YRacMax - $YRacMin)/$NINTERVALLES}]

    set gp [open "|gnuplot 2>@ stderr" w]
    fconfigure $gp -buffering line
    
    puts $gp {set yrange [0:10.]}
    puts $gp {plot "-" using ($1):($2) with lines , "-" using ($1):($2) with lines}
    
    for {set i 0} {$i <= $NINTERVALLES} {incr i} {
	set YRac [expr {$dYRac * $i + $YRacMin}]
	set YN [expr {$YRac/(2.0*($d1N+$d2N))}]
	set z [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] 0]
	if {[::complexes::module $z] == 0.0} {
	    set a 0.0
	} else {
	    set a [::complexes::arg $z]
	}
	puts $gp "$YRac $a"
    }
    puts $gp e
    
    set XN [expr {-$XN}]
    for {set i 0} {$i <= $NINTERVALLES} {incr i} {
	set YRac [expr {$dYRac * $i + $YRacMin}]
	set YN [expr {$YRac/(2.0*($d1N+$d2N))}]
	set z [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] 0]
	if {[::complexes::module $z] == 0.0} {
	    set a 0.0
	} else {
	    set a [::complexes::arg $z]
	}
	puts $gp "$YRac $a" 
    }
    puts $gp e
}

#################################################################################


# plotMarges $eps1 $eps2 $d1N $d2N $kx0N 10.0 0.0 50.0


proc f {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    return [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] 0]
}

proc f1 {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    set l [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]]
    puts $l
    return [lindex $l 1]
}

proc f2 {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    set l [::zerosComplexes::eqvp 2 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]]
    puts $l
    return [lindex $l 1]
}

proc ::zerosComplexes::listOfIntervalles {eps1 eps2 d1N d2N kx0N XN YNmin YNmax divOfPeriod} {
    # divOfPeriod = 20 semble honnête
    # Une période vaut $d1N+$d2N
    set xpList [list]
    set ypList [list]
    set xmList [list]
    set ymList [list]

   set interv [expr {1.0/($divOfPeriod*($d1N+$d2N))}]
    set YN $YNmin
    set i 0
    set erreur "erreur de subdivision"
    set f [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] 0]
    foreach {t x y} [::complexes::toXY $f] {}
    while {$YN <= $YNmax} {
	incr i
	set YNold $YN
	set xold $x
	set yold $y
	set YN [expr {$YNmin+$i*$interv}]
	set f [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] 0]
	foreach {t x y} [::complexes::toXY $f] {}
	if {($xold <= 0 && $x >= 0) || ($xold >= 0 && $x <= 0)} {
	    if {$y < 0 && $yold < 0} {
		lappend ymList [list $YNold $YN]
	    } elseif {$y > 0 && $yold > 0} {
		lappend ypList [list $YNold $YN]
	    } else {
		error $erreur
	    }
	}
	if {($yold <= 0 && $y >= 0) || ($yold >= 0 && $y <= 0)} {
	    if {$x < 0 && $xold < 0} {
		lappend xmList [list $YNold $YN]
	    } elseif {$x > 0 && $xold > 0} {
		lappend xpList [list $YNold $YN]
    } else {
		error $erreur
	    }
	}
    }
    return [list $xpList $ypList $xmList $ymList]
}

proc nearImZero {eps1 eps2 d1N d2N kx0N XN YN} {
    foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YN]] {}
    puts [list $f $f1]
    set dY [expr {-[::complexes::im $f]/[::complexes::re $f1]}]
    return [expr {$YN + $dY}]
}

proc ::zerosComplexes::findImZeroWithCteZr {eps1 eps2 d1N d2N kx0N XN YN1 YN2 NDMAX DYMIN} {
    if {$YN2 < $YN1} {
	set YN $YN1
	set YN1 $YN2
	set YN2 $YN
    }

    set YNold [expr {0.5*($YN1+$YN2)}]
    for {set i 0} {$i < $NDMAX} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YNold]] {}
	set dy [expr {-[::complexes::im $f]/[::complexes::re $f1]}]
	if {abs($dy) < $DYMIN} break
	set YN [expr {$YNold + $dy}]
	# puts "$i $YN"
	if {$YN < $YN1} {
	    set YN $YN1
	} elseif {$YN > $YN2} {
	    set YN $YN2
	}
	if {($YN == $YN1 || $YN == $YN2) && ($YNold == $YN1 || $YNold == $YN2)} {
	    error "La recherche de zero sort du cadre"
	}
	set YNold $YN
    }
    return $YN
}

proc ::zerosComplexes::findReZeroWithCteZr {eps1 eps2 d1N d2N kx0N XN YN1 YN2 NDMAX DYMIN} {
    if {$YN2 < $YN1} {
	set YN $YN1
	set YN1 $YN2
	set YN2 $YN
    }

    set YNold [expr {0.5*($YN1+$YN2)}]
    for {set i 0} {$i < $NDMAX} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [::complexes::newXY $XN $YNold]] {}
	set dy [expr {[::complexes::re $f]/[::complexes::im $f1]}]
	if {abs($dy) < $DYMIN} break
	set YN [expr {$YNold + $dy}]
#	puts $YN
	if {$YN < $YN1} {
	    set YN $YN1
	} elseif {$YN > $YN2} {
	    set YN $YN2
	}
	if {($YN == $YN1 || $YN == $YN2) && ($YNold == $YN1 || $YNold == $YN2)} {
	    error "La recherche de zero sort du cadre"
	}
	set YNold $YN
    }
    return $YN
}


proc nextOnCurveRe {eps1 eps2 d1N d2N kx0N Z sens dl thetamax DZM} {
    foreach {f f1 f2} [::zerosComplexes::eqvp 2 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
    foreach {t fr fi} [::complexes::toXY $f] {}
    foreach {t f1r f1i} [::complexes::toXY $f1] {}
    set f1m [expr {sqrt($f1r*$f1r+$f1i*$f1i)}]
    foreach {t f2r f2i} [::complexes::toXY $f2] {}
    set K [expr {((-$f1r*$f1r+$f1i*$f1i)*$f2i + 2*$f1r*$f1i*$f2r)/($f1m*$f1m*$f1m)}]
    set t [expr {abs($thetamax/$K)}]
    if {$t < $dl} {
	# puts "rayon de courbure en ($Z) = [expr {1.0/$K}]"
	set dl $t
    }
    set dz [::complexes::realMul\
	    [expr {$sens*$dl/$f1m}]\
	    [complexes::mul\
	      [complexes::newXY 1.0 [expr {0.5*$K*$dl}]]\
	      [::complexes::conj $f1]]]
    set Z [::complexes::add $Z $dz]
    # puts $Z
    
    for {set i 0} {$i < 50} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
	set dz [::complexes::div\
		[::complexes::newXY 0.0 [expr {-[::complexes::im $f]}]]\
		$f1]
	set dzm [::complexes::module $dz]
	if {$dzm > $dl} {
	    error "rattrapage trop grand"
	}
	if {$dzm < $DZM} break
	set Z [::complexes::add $Z $dz]
	# puts $Z
    }
    if {$i >= 50} {
	puts stderr "rattrapage trop long"
    }
    if {$sens*[::complexes::re $f] > 0} {
	return {}
    }
    return $Z
}

proc nextOnCurveIm {eps1 eps2 d1N d2N kx0N Z sens dl thetamax DZM} {
    foreach {f f1 f2} [::zerosComplexes::eqvp 2 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
    foreach {t fr fi} [::complexes::toXY $f] {}
    foreach {t f1r f1i} [::complexes::toXY $f1] {}
    set f1m [expr {sqrt($f1r*$f1r+$f1i*$f1i)}]
    foreach {t f2r f2i} [::complexes::toXY $f2] {}
    set K [expr {((-$f1r*$f1r+$f1i*$f1i)*$f2r - 2*$f1r*$f1i*$f2i)/($f1m*$f1m*$f1m)}]
    set t [expr {abs($thetamax/$K)}]
    if {$t < $dl} {
	# puts "rayon de courbure en ($Z) = [expr {1.0/$K}]"
	set dl $t
    }
    set dz [::complexes::realMul\
	    [expr {$sens*$dl/$f1m}]\
	    [complexes::mul\
	      [complexes::newXY [expr {-0.5*$K*$dl}] 1.0]\
	      [::complexes::conj $f1]]]
    set Z [::complexes::add $Z $dz]
    # puts $Z
    
    for {set i 0} {$i < 50} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
	set dz [::complexes::div\
		[::complexes::newXY [expr {-[::complexes::re $f]}] 0.0]\
		$f1]
	set dzm [::complexes::module $dz]
	if {$dzm > $dl} {
	    error "rattrapage trop grand"
	}
	# puts [list Z= $Z f= $f f1= $f1 dz=$dz]
	if {$dzm < $DZM} break
	set Z [::complexes::add $Z $dz]
    }
    if {$i >= 50} {
	puts stderr "rattrapage trop long"
    }
    if {$sens*[::complexes::im $f] > 0} {
	return {}
    }
    return $Z
}

proc aCurveRe {polar eps1 eps2 d1N d2N kx0N XNm XNp Z sens dl thetamax DZM fact} {
    set pts [list]
    set npts 0

    set X [::complexes::re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[::complexes::im $Z]}]
    incr npts

    set Z [::zerosComplexes::nextOnCurveInC Re $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
    if {$Z == {}} {
	error "erreur de sens"
    }
    set X [::complexes::re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[::complexes::im $Z]}]
    incr npts

    while {$X > $XNm && $X < $XNp} {
	set Z [::zerosComplexes::nextOnCurveInC Re $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
	if {$Z == {}} {
	    # puts stderr break
	    break
	}
	set X [::complexes::re $Z]
	lappend pts [expr {$fact*$X}] 
	lappend pts [expr {-$fact*[::complexes::im $Z]}]
	incr npts
	if {$npts >= 1000} {
	    puts stderr [list ARRET BRUTAL de aCurveIm en $Z]
	    break
	}
    }
# puts stderr "npts = $npts"
    return $pts
}

proc aCurveIm {polar eps1 eps2 d1N d2N kx0N XNm XNp Z sens dl thetamax DZM fact} {
    set pts [list]
    set npts 0

    set X [::complexes::re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[::complexes::im $Z]}]
    incr npts

    set Z [::zerosComplexes::nextOnCurveInC Im $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
    if {$Z == {}} {
	error "erreur de sens"
    }
    set X [::complexes::re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[::complexes::im $Z]}]
    incr npts

    while {$X > $XNm && $X <$XNp} {
	set Z [::zerosComplexes::nextOnCurveInC Im $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
	if {$Z == {}} break
	# puts $Z
	set X [::complexes::re $Z]
	lappend pts [expr {$fact*$X}] 
	lappend pts [expr {-$fact*[::complexes::im $Z]}]
	incr npts
	if {$npts >= 1000} {
	    puts stderr [list ARRET BRUTAL de aCurve en $Z]
	    break
	}
    }
    return $pts
}


################################
#                              #
# fonction principale de trace #
#                              #
################################

proc plotAll {} {
    global eps1 eps2 lambda d r kx0N XNm XNp YNm YNp divOfPeriod NDMAX DYMIN DZM1 DZM2 ZOOM dl dtheta DZwarn polar
    global STOP RACINES
    set STOP 0

    set DEUXPI [expr {8.0*atan(1.0)}]
    set k0 [expr {$DEUXPI/$lambda}]

    # Valeurs normalisées à k0
    set dN [expr {$d/$lambda}]
    set r2 $r
    set r1 [expr {1.0 - $r2}]
    set d1N [expr {$r1*$dN}]
    set d2N [expr {$r2*$dN}]

    puts [list eps1 = $eps1]
    puts [list eps2 = $eps2]
    puts [list d1N = $d1N]
    puts [list d2N = $d2N]
    puts [list kx0N = $kx0N]
    

    # calcul des listes $al(xpp), $al(ypm),... des points de départ

    ::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN

    .f.c delete all
    .f.c create line 0 [expr {-2.0*$YNp*$ZOOM}] 0 [expr {-2.0*$YNm*$ZOOM}]  -fill green
    .f.c create line [expr {$XNm*$ZOOM}] 0 [expr {$XNp*$ZOOM}] 0 -fill green

    # 

    if {$RACINES} {
	set racines [::zerosComplexes::zeros al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn]
	set ir [llength $racines]
	for {incr ir -1} {$ir >= 0} {incr ir -1} {
	    puts [list $ir [lindex $racines $ir]]
	}
    }

# puts $al(ymm)
    foreach YN $al(ymm) {
	set Z [::complexes::newXY $XNm $YN]
# puts "   -> $Z"
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill red -width 0 -tags ym
	update
	if {$STOP} return
    }
    
# puts $al(ymp)
    foreach YN $al(ymp) {
	set Z [::complexes::newXY $XNp $YN]
# puts "   -> $Z"
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill red -width 0 -tag ym
	update
	if {$STOP} return
    }
    
    foreach YN $al(xmm) {
	set Z [::complexes::newXY $XNm $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill black -width 0 -tags xm
	update
	if {$STOP} return
    }
    
    foreach YN $al(xmp) {
	set Z [::complexes::newXY $XNp $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl  $dtheta $DZM1 $ZOOM] -fill black -width 0 -tags xm 
	update
	if {$STOP} return
    }
    
    foreach YN $al(xpm) {
	set Z [::complexes::newXY $XNm $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill blue -width 0 -tags xp
	update
	if {$STOP} return
    }
    
    foreach YN $al(xpp) {
	set Z [::complexes::newXY $XNp $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill blue -width 0 -tag xp
	update
	if {$STOP} return
    }
    
    foreach YN $al(ypm) {
	set Z [::complexes::newXY $XNm $YN]
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill orange -width 0 -tag yp
	update
	if {$STOP} return
    }
    
    foreach YN $al(ypp) {
	set Z [::complexes::newXY $XNp $YN]
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill orange -width 0 -tag yp
	update
	if {$STOP} return
    }
}

proc zp2 {} {
    global ZOOM XNm XNp YNm YNp
    .f.c scale all 0 0 2. 2.
    set ZOOM [expr {2.0*$ZOOM}]
    foreach {c1 c2} [.f.c xview] {}
    set x [expr {0.75*$c1 + 0.25*$c2}]
    foreach {c1 c2} [.f.c yview] {}
    set y [expr {0.75*$c1 + 0.25*$c2}]
    .f.c configure -scrollregion [list [expr {2.0*$XNm*$ZOOM}] [expr {-2.0*$YNp*$ZOOM}] [expr {2.0*$XNp*$ZOOM}] [expr {-2.0*$YNm*$ZOOM}]]
    .f.c xview moveto $x
    .f.c yview moveto $y
}

proc zs2 {} {
    global ZOOM XNm XNp YNm YNp
    .f.c scale all 0 0 0.5 0.5
    set ZOOM [expr {0.5*$ZOOM}]
    foreach {c1 c2} [.f.c xview] {}
    set x [expr {1.5*$c1 - 0.5*$c2}]
    foreach {c1 c2} [.f.c yview] {}
    set y [expr {1.5*$c1 - 0.5*$c2}]
    .f.c configure -scrollregion [list [expr {2.0*$XNm*$ZOOM}] [expr {-2.0*$YNp*$ZOOM}] [expr {2.0*$XNp*$ZOOM}] [expr {-2.0*$YNm*$ZOOM}]]
    .f.c xview moveto $x
    .f.c yview moveto $y
}

proc ici {win xwin ywin} {
    global ZOOM
    set xwin [$win canvasx $xwin]
    set ywin [$win canvasy $ywin]
    set x [expr {$xwin/$ZOOM}]
    set y [expr {-$ywin/$ZOOM}]
#    $win delete coords
    $win create text [expr $xwin + 5] [expr $ywin - 5] -anchor sw -text [format {(%.3f, %.3f)} $x $y] -tags coords 
}

bind .f.c <Button-1> {ici %W %x %y}
bind .f.c <Button-3> {%W delete coords}
.f.c configure -cursor tcross
.f.c configure -scrollregion [list [expr {2.0*$ZOOM}] [expr {-2.0*$YNp*$ZOOM}] [expr {2.0*$XNp*$ZOOM}] [expr {-2.0*$YNm*$ZOOM}]]

plotAll

