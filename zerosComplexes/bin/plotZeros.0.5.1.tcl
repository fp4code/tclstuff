#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

# 20 juin 2001 (FP) plotZeros.0.5.tcl
# 21 mai 2002 (FP) plotZeros.0.5.1.tcl

package require fidev
package require superWidgetsScroll
package require supercomplex 0.2

puts OK1
package require blasObj
puts OK2
package require eqvp 0.4
puts OK3

frame .f
pack .f -fill both -expand 1 -side left
frame .f2
frame .f3
button .f2.bp2 -text "x2" -command zp2
button .f2.bs2 -text "/2" -command zs2
button .f2.print -text "print" -command {exec lp << [.f.c postscript]}
button .f2.eps -text "eps" -command {set f [open ~/Z/au.eps w]; puts $f [.f.c postscript]; close $f}
button .f2.plot -text "plot" -command plotAll
button .f2.stop -text "stop" -command {set STOP 1}
pack .f3 -fill x -side top
pack .f2 -fill x -side bottom
pack .f2.bp2 -side left
pack .f2.bs2 -side left


pack .f2.stop -side right
pack .f2.plot -side right

pack .f2.print .f2.eps

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

foreach {e1 w1 e2 w2} {polar 6 DZwarn 6 lambda 6 d1 6 d2 6 kx0N 6 XNm 6 XNp 6 YNm 6 YNp 6 DYMIN 6 divOfPeriod 6 DZM1 6 DZM2 6 dl 6 dtheta 6} {
    label .f3.l$e1 -text $e1
    entry .f3.e$e1 -width $w1 -textvariable $e1
    label .f3.l$e2 -text $e2
    entry .f3.e$e2 -width $w2 -textvariable $e2
    grid configure .f3.l$e1 .f3.e$e1 .f3.l$e2 .f3.e$e2 -sticky news
}

set polar TM
set DZwarn 1e-4
set eps1 [supercomplex create xy 1.0 0.0]
set eps2 [supercomplex create xy -598.4 127.92]
set lambda 4.0
set d1 0.5
set d2 3.0
set kx0N 0.0
set XNm -5.0 
set XNp 15.0
set YNm -5.0
set YNp 25.0
set NDMAX 100
set DYMIN 1e-4
set DZM1 1e-4
set DZM2 1e-12
set divOfPeriod 10
set dl 0.1
set dtheta 0.02
set ZOOM 8
set RACINES 1

set C [canvas .f.c -width 400 -height 600]
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
#    set dz [supercomplex create xy 0.000001 0.000003]
    set dz [supercomplex create xy 0.000000 0.000001]
    set z0 [supercomplexes sub $z1 $dz]
    set z2 [supercomplex add $z1 $dz]
    
    foreach {u0 v0 w0} [c $z0] {}
    foreach {u1 v1 w1} [c $z1] {}
    foreach {u2 v2 w2} [c $z2] {}
    
    set du01 [supercomplex sub $u1 $u0]
    set du12 [supercomplex sub $u2 $u1]
    
    set v01 [supercomplex div $du01 $dz]
    set v12 [supercomplex div $du12 $dz]
    
    # vérification de la dérivée
    
    set erra [supercomplex module [supercomplex div $v01 $v1]]
    set errb [supercomplex module [supercomplex div $v12 $v1]]
    
    # vérification de la dérivée seconde
    
    set ddu [supercomplex sub $v12 $v01]
    set wa1 [supercomplex div $ddu $dz]
    
    set errc [supercomplex module [supercomplex div $wa1 $w1]]

    puts [list $u1 $v1 $w1 erreurs sur dérivées 1 et 2 en $kappayN : $errb, $errc]
}    

set verifs {

    verif [supercomplex create xy 0.45 1.1]
    verif [supercomplex create xy 10.1 1.1]
    verif [supercomplex create xy 10.1 -1.1]
    verif [supercomplex create xy 10.1 -10.1]
    verif [supercomplex create xy 0.2 -10.1]
}
    #

proc ps {eps1 eps2 d1N d2N kappayN} {

# angle nul

# approximations _a kappayN grand

    set kyN2 [supercomplex mul $kappayN $kappayN]
    set k1xN [supercomplex toXY [supercomplex sqrt [supercomplex sub $eps1 $kyN2]]]
    set k2xN [supercomplex toXY [supercomplex sqrt [supercomplex sub $eps2 $kyN2]]]

    set k1xN_a [supercomplex iMul [supercomplex mul\
	    $kappayN [supercomplex add 1.0 [supercomplex realMul -0.5\
	    [supercomplex div $eps1 $kyN2]]]]]
    set k2xN_a [supercomplex iMul [supercomplex mul\
	    $kappayN [supercomplex add 1.0 [supercomplex realMul -0.5\
	    [supercomplex div $eps2 $kyN2]]]]]

    set p1N [supercomplex div $k1xN $eps1]
    set p2N [supercomplex div $k2xN $eps2]

    set P [supercomplex realMul 0.5 [supercomplex add\
	    [supercomplex div $p1N $p2N] [supercomplex div $p2N $p1N]]]

    set P_a [supercomplex realMul 0.5 [supercomplex add\
	    [supercomplex div $eps1 $eps2] [supercomplex div $eps2 $eps1]]]
    
    set k1xd1f2N [supercomplex realMul [expr {2.0*$d1N}] $k1xN]
    set k2xd2f2N [supercomplex realMul [expr {2.0*$d2N}] $k2xN]

    set argplus  [supercomplex add $k1xd1f2N $k2xd2f2N]
    set argmoins [supercomplex sub $k1xd1f2N $k2xd2f2N]

    set cplus  [supercomplex cospi $argplus]
    set cmoins [supercomplex cospi $argmoins]

    set XN [supercomplex re $kappayN]
    set YN [supercomplex im $kappayN]

    global DEUXPI

    set cplus_a [supercomplex create xy [expr {cospi(2.0*$YN*($d1N+$d2N))*cosh($DEUXPI*$XN*($d1N+$d2N))}]\
	                            [expr {sinpi(2.0*$YN*($d1N+$d2N))*sinh($DEUXPI*$XN*($d1N+$d2N))}]]

    set tcplus  [supercomplex mul [supercomplex add [supercomplex realMul -0.5 $P] -0.5] $cplus]
    set tcmoins [supercomplex mul [supercomplex add [supercomplex realMul  0.5 $P] -0.5] $cmoins]

    set ps [supercomplex add $tcplus $tcmoins]

    set psautre [supercomplex add\
	    [complexes::mul -1.0 [complexes::mul [supercomplex cospi $k1xd1f2N] [supercomplex cospi $k2xd2f2N]]]\
	    [complexes::mul $P   [complexes::mul [supercomplex sinpi $k1xd1f2N] [supercomplex sinpi $k2xd2f2N]]]]
    
# approximations loin de l'axe imaginaire

    set cte [supercomplex add -0.25 [supercomplex realMul -0.125 [supercomplex add\
	[supercomplex div $eps2 $eps1] [supercomplex div $eps2 $eps1]]]]
    if {$XN < 0.0} {
	set XN [expr {-$XN}]
	set YN [expr {-$YN}]
    }

    set approx [supercomplex mul\
	    $cte [supercomplex newRTpi [expr {exp($XN*$DEUXPI*($d1N+$d2N))}] [expr {$YN*2.0*($d1N+$d2N)}]]]

    return $ps
}



proc deriv1_a {commande z dz} {
    set demi [supercomplex realMul 0.5 $dz]
    set c1 [concat $commande [list [supercomplex sub $z $demi]]]
    set c2 [concat $commande [list [supercomplex add $z $demi]]]
    set f1 [eval $c1]
    set f2 [eval $c2]
    return [supercomplex div [supercomplex sub $f2 $f1] $dz]
}

proc deriv2_a {commande z dz} {
    set c0 [concat $commande [list [supercomplex sub $z $dz]]]
    set c1 [concat $commande [list $z]]
    set c2 [concat $commande [list [supercomplex add $z $dz]]]
    set f0 [eval $c0]
    set f1 [eval $c1]
    set f2 [eval $c2]
    set db [supercomplex div [supercomplex sub $f2 $f1] $dz]
    set da [supercomplex div [supercomplex sub $f1 $f0] $dz]
    return [supercomplex div [supercomplex sub $db $da] $dz]
}

set rien {

    foreach {u v w} [c $kappayN] {}
    set dz [supercomplex create xy 0.000001 0.000003]
    
    set u
    ps $eps1 $eps2 $d1N $d2N $kappayN
    
    set v
    deriv1_a [list ps $eps1 $eps2 $d1N $d2N] $kappayN $dz
    
    set w
    deriv2_a [list ps $eps1 $eps2 $d1N $d2N] $kappayN $dz
}

proc d {Y} {
    foreach {u v w} [c [supercomplex create xy 10.0 $Y]] {}
    return [supercomplex arg $u]
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
	set z [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] 0]
	if {[supercomplex module $z] == 0.0} {
	    set a 0.0
	} else {
	    set a [supercomplex arg $z]
	}
	puts $gp "$YRac $a"
    }
    puts $gp e
    
    set XN [expr {-$XN}]
    for {set i 0} {$i <= $NINTERVALLES} {incr i} {
	set YRac [expr {$dYRac * $i + $YRacMin}]
	set YN [expr {$YRac/(2.0*($d1N+$d2N))}]
	set z [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] 0]
	if {[supercomplex module $z] == 0.0} {
	    set a 0.0
	} else {
	    set a [supercomplex arg $z]
	}
	puts $gp "$YRac $a" 
    }
    puts $gp e
}

#################################################################################


# plotMarges $eps1 $eps2 $d1N $d2N $kx0N 10.0 0.0 50.0


proc f {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    return [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] 0]
}

proc f1 {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    set l [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]]
    puts $l
    return [lindex $l 1]
}

proc f2 {XN YN} {
    global eps1 eps2 d1N d2N kx0N
    set l [::zerosComplexes::eqvp 2 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]]
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
    set f [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] 0]
    foreach {t x y} [supercomplex toXY $f] {}
    while {$YN <= $YNmax} {
	incr i
	set YNold $YN
	set xold $x
	set yold $y
	set YN [expr {$YNmin+$i*$interv}]
	set f [lindex [::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] 0]
	foreach {t x y} [supercomplex toXY $f] {}
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
    foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YN]] {}
    puts [list $f $f1]
    set dY [expr {-[supercomplex im $f]/[supercomplex re $f1]}]
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
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YNold]] {}
	set dy [expr {-[supercomplex im $f]/[supercomplex re $f1]}]
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
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N [supercomplex create xy $XN $YNold]] {}
	set dy [expr {[supercomplex re $f]/[supercomplex im $f1]}]
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
    foreach {t fr fi} [supercomplex toXY $f] {}
    foreach {t f1r f1i} [supercomplex toXY $f1] {}
    set f1m [expr {sqrt($f1r*$f1r+$f1i*$f1i)}]
    foreach {t f2r f2i} [supercomplex toXY $f2] {}
    set K [expr {((-$f1r*$f1r+$f1i*$f1i)*$f2i + 2*$f1r*$f1i*$f2r)/($f1m*$f1m*$f1m)}]
    set t [expr {abs($thetamax/$K)}]
    if {$t < $dl} {
	# puts "rayon de courbure en ($Z) = [expr {1.0/$K}]"
	set dl $t
    }
    set dz [supercomplex realMul\
	    [expr {$sens*$dl/$f1m}]\
	    [complexes::mul\
	      [complexes::newXY 1.0 [expr {0.5*$K*$dl}]]\
	      [supercomplex conj $f1]]]
    set Z [supercomplex add $Z $dz]
    # puts $Z
    
    for {set i 0} {$i < 50} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
	set dz [supercomplex div\
		[supercomplex create xy 0.0 [expr {-[supercomplex im $f]}]]\
		$f1]
	set dzm [supercomplex module $dz]
	if {$dzm > $dl} {
	    error "rattrapage trop grand"
	}
	if {$dzm < $DZM} break
	set Z [supercomplex add $Z $dz]
	# puts $Z
    }
    if {$i >= 50} {
	puts stderr "rattrapage trop long"
    }
    if {$sens*[supercomplex re $f] > 0} {
	return {}
    }
    return $Z
}

proc nextOnCurveIm {eps1 eps2 d1N d2N kx0N Z sens dl thetamax DZM} {
    foreach {f f1 f2} [::zerosComplexes::eqvp 2 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
    foreach {t fr fi} [supercomplex toXY $f] {}
    foreach {t f1r f1i} [supercomplex toXY $f1] {}
    set f1m [expr {sqrt($f1r*$f1r+$f1i*$f1i)}]
    foreach {t f2r f2i} [supercomplex toXY $f2] {}
    set K [expr {((-$f1r*$f1r+$f1i*$f1i)*$f2r - 2*$f1r*$f1i*$f2i)/($f1m*$f1m*$f1m)}]
    set t [expr {abs($thetamax/$K)}]
    if {$t < $dl} {
	# puts "rayon de courbure en ($Z) = [expr {1.0/$K}]"
	set dl $t
    }
    set dz [supercomplex realMul\
	    [expr {$sens*$dl/$f1m}]\
	    [complexes::mul\
	      [complexes::newXY [expr {-0.5*$K*$dl}] 1.0]\
	      [supercomplex conj $f1]]]
    set Z [supercomplex add $Z $dz]
    # puts $Z
    
    for {set i 0} {$i < 50} {incr i} {
	foreach {f f1} [::zerosComplexes::eqvp 1 TM $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
	set dz [supercomplex div\
		[supercomplex create xy [expr {-[supercomplex re $f]}] 0.0]\
		$f1]
	set dzm [supercomplex module $dz]
	if {$dzm > $dl} {
	    error "rattrapage trop grand"
	}
	# puts [list Z= $Z f= $f f1= $f1 dz=$dz]
	if {$dzm < $DZM} break
	set Z [supercomplex add $Z $dz]
    }
    if {$i >= 50} {
	puts stderr "rattrapage trop long"
    }
    if {$sens*[supercomplex im $f] > 0} {
	return {}
    }
    return $Z
}

proc aCurveRe {polar eps1 eps2 d1N d2N kx0N XNm XNp Z sens dl thetamax DZM fact} {
    set pts [list]
    set npts 0

    set X [supercomplex re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[supercomplex im $Z]}]
    incr npts

    set Z [::zerosComplexes::nextOnCurveInC Re $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
    if {$Z == {}} {
	error "erreur de sens"
    }
    set X [supercomplex re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[supercomplex im $Z]}]
    incr npts

    while {$X > $XNm && $X < $XNp} {
	set Z [::zerosComplexes::nextOnCurveInC Re $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
	if {$Z == {}} {
	    # puts stderr break
	    break
	}
	set X [supercomplex re $Z]
	lappend pts [expr {$fact*$X}] 
	lappend pts [expr {-$fact*[supercomplex im $Z]}]
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

    set X [supercomplex re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[supercomplex im $Z]}]
    incr npts

    set Z [::zerosComplexes::nextOnCurveInC Im $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
    if {$Z == {}} {
	error "erreur de sens"
    }
    set X [supercomplex re $Z]
    lappend pts [expr {$fact*$X}] 
    lappend pts [expr {-$fact*[supercomplex im $Z]}]
    incr npts

    while {$X > $XNm && $X <$XNp} {
	set Z [::zerosComplexes::nextOnCurveInC Im $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens $dl $thetamax $DZM]
	if {$Z == {}} break
	# puts $Z
	set X [supercomplex re $Z]
	lappend pts [expr {$fact*$X}] 
	lappend pts [expr {-$fact*[supercomplex im $Z]}]
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
    global eps1 eps2 lambda d1 d2 kx0N XNm XNp YNm YNp divOfPeriod NDMAX DYMIN DZM1 DZM2 ZOOM dl dtheta DZwarn polar
    global STOP RACINES
    set STOP 0

    set DEUXPI [expr {8.0*atan(1.0)}]
    set k0 [expr {$DEUXPI/$lambda}]

    # Valeurs normalisées à k0
    set d1N [expr {$d1/$lambda}]
    set d2N [expr {$d2/$lambda}]

    puts [list eps1 = $eps1]
    puts [list eps2 = $eps2]
    puts [list d1N = $d1N]
    puts [list d2N = $d2N]
    puts [list kx0N = $kx0N]
    

    # calcul des listes $al(xpp), $al(ypm),... des points de départ

    ::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN

    .f.c delete all
    .f.c create line 0 [expr {-30*$ZOOM}] 0 [expr {15*$ZOOM}]  -fill green -width 1
    .f.c create oval [expr {-$ZOOM}] [expr {-$ZOOM}] [expr {$ZOOM}] [expr {$ZOOM}] -outline green -width 1
    .f.c create line [expr {$XNm*$ZOOM}] 0 [expr {$XNp*$ZOOM}] 0 -fill green -width 1

    # 

    if {$RACINES} {
	catch {::zerosComplexes::zeros ym al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_ym
	catch {::zerosComplexes::zeros yp al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_yp
	catch {::zerosComplexes::zeros xm al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_xm
	catch {::zerosComplexes::zeros xp al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_xp

        puts "\nRACINES :"
        set ir 0
	foreach r_ym $racines_ym  r_xp $racines_xm  r_yp $racines_yp r_xm $racines_xm {
            incr ir
	    puts [list $ir $r_ym $r_xp $r_yp $r_xm]
	}

        puts "\nPHASES (double traversée) :"
        set ir 0
	foreach r_ym $racines_ym  r_xp $racines_xm  r_yp $racines_yp r_xm $racines_xm {
            incr ir
            set lp [list]
            foreach r [list $r_ym $r_xp $r_yp $r_xm] {
              if [catch {set p [supercomplex mul $r $r]}] {
                lappend lp {}
              }
              set p [supercomplex sub $eps1 $p]
              set p [supercomplex sqrt $p]
              set p [supercomplex mul $p [expr {2.0*$d1N}]]
              lappend lp $p
            }
            puts $lp
	}        
    }

# puts $al(ymm)
    foreach YN $al(ymm) {
	set Z [supercomplex create xy $XNm $YN]
# puts "   -> $Z"
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill red -width 0 -tags ym
	update
	if {$STOP} return
    }
    
# puts $al(ymp)
    foreach YN $al(ymp) {
	set Z [supercomplex create xy $XNp $YN]
# puts "   -> $Z"
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill red -width 0 -tag ym
	update
	if {$STOP} return
    }
    
    foreach YN $al(xmm) {
	set Z [supercomplex create xy $XNm $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl $dtheta $DZM1 $ZOOM] -fill black -width 0 -tags xm
	update
	if {$STOP} return
    }
    
    foreach YN $al(xmp) {
	set Z [supercomplex create xy $XNp $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z 1 $dl  $dtheta $DZM1 $ZOOM] -fill black -width 0 -tags xm 
	update
	if {$STOP} return
    }
    
    foreach YN $al(xpm) {
	set Z [supercomplex create xy $XNm $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill blue -width 0 -tags xp
	update
	if {$STOP} return
    }
    
    foreach YN $al(xpp) {
	set Z [supercomplex create xy $XNp $YN]
	eval .f.c create line [aCurveRe $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill blue -width 0 -tag xp
	update
	if {$STOP} return
    }
    
    foreach YN $al(ypm) {
	set Z [supercomplex create xy $XNm $YN]
	eval .f.c create line [aCurveIm $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $Z -1 $dl $dtheta $DZM1 $ZOOM] -fill orange -width 0 -tag yp
	update
	if {$STOP} return
    }
    
    foreach YN $al(ypp) {
	set Z [supercomplex create xy $XNp $YN]
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

