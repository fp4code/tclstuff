#!/usr/local/bin/tclsh


namespace eval polyM2 {}

set HELP(polyM2) {
    Un polynome modulo2 est une liste de 0 et de 1.
    a0 + a1*x + a2*x*x + a3*x*x*x => [list a0 a1 a2 a3]
    Le dernier élément est supposé être 1
}

set HELP(polyM2::isSet) {
    retourne le coefficient (0 ou 1) de pow(x, $puissance) du polynome $poly
}

proc polyM2::isSet {poly puissance} {
    if {$puissance >= [llength $poly]} {
	return 0
    }
    return [expr {[lindex $poly $puissance] != 0}]
}


set HELP(polyM2::add) {
    somme modulo 2 de deux polynomes modulo 2
    Le dernier élément de la liste retournée est toujours 1,
    sauf pour le polynome 0
}

proc polyM2::add {p1 p2} {
    set pr [list]
    set dr -1 ;# degré de pr
    set l1 [llength $p1]
    set l2 [llength $p2]
    if {$l1 < $l2} {
        set pa $p1
	set pb $p2
        set la $l1
	set lb $l2
    } elseif {$l1 > $l2} {
        set pa $p2
	set pb $p1
        set la $l2
	set lb $l1
    } else {
        set i 0
	foreach e1 $p1 e2 $p2 {
	    if {$e1 + $e2 == 1} {
		lappend pr 1
		set dr $i
	    } else {
		lappend pr 0
	    }
	    incr i
	}
	if {$dr == -1} {
	    return [list 0]
	}
	return [lrange $pr 0 $dr]
    }
    foreach ea $pa eb [lrange $pb 0 [expr {$la - 1}]] {
	if {$ea + $eb == 1} {
	    lappend pr 1
	} else {
	    lappend pr 0
	}
    }
    return [concat $pr [lrange $pb $la end]]
}

set HELP(polyM2::rawxMul) {
    retourne x*$poly
}

proc polyM2::rawxMul {poly} {
    return [concat 0 $poly]
}

set HELP(polyM2::rawxNMul) {
    retourne pow(x,$N)*$poly
}

proc polyM2::rawxNMul {poly N} {
    if {$N < 0} {
	error "N < 0"
    }
    set ret [list]
    for {set i 0} {$i < $N} {incr i} {
	lappend ret 0
    }
    return [concat $ret $poly]
}

set HELP(polyM2::xDiv) {
    retourne le quotient euclidien de $poly par x
}

proc polyM2::xDiv {poly} {
    set ret [lrange $poly 1 end]
    if {$ret == {}} {
	set ret [list 0]
    }
    return $ret
}

set HELP(polyM2::compare) {
    retourne -1, 0 ou 1 selon que $pa est plus petit, égal ou plus grand que $pb
}

proc polyM2::compare {pa pb} {
    set la [llength $pa]
    set lb [llength $pb]
    if {$la < $lb} {
	return -1
    } elseif {$la > $lb} {
	return 1
    }
    for {set i [expr {$la - 1}]} {$i >= 0} {incr i -1} {
	set ea [lindex $pa $i]
	set eb [lindex $pb $i]
# puts "$i $ea $eb"
	if {$ea < $eb} {
	    return -1
	} elseif {$ea > $eb} {
	    return 1
	}
    }
    return 0
} 

set HELP(polyM2::rawmul) {
    retourne le produit des polynomes modulo2 $pa et $pb
    Le résultat est toujours un bon polynome, c'est à dire que le dernier élément de la liste
    est 1
a0 a1 a2 a3 a4 a5
b0 b1 b2 b3

r0 a0b0
r1 a0b1 ... a1b0
r2 a0b2 ... a2b0
r3 a0b3 ... a3b0

r4 a1b3 ... a4b0
r5 a2b3 ... a5b0
r6 a3b3 ... a5b1
r7 a4b3 ... a5b2
r8 a5b3

a0 a1 a2 a3
b0 b1 b2 b3 b4 b5


r0 a0b0
r1 a0b1 ... a1b0
r2 a0b2 ... a2b0
r3 a0b3 ... a3b0
r4 a0b4 ... a3b1
r5 a0b5 ... a3b1

r6 a1b5 ... a3b2
r7 a2b5 ... a3b3
r8 a3b5

}

proc polyM2::rawmul {pA pB} {
    set dA [polyM2::degre $pA]
    set dB [polyM2::degre $pB]
    if {$dA == -1 || $dB == -1} {
	return 0
    }
    set dR [expr {$dA + $dB}]
    set pR [list]
    set dRt -1
    for {set iR 0} {$iR <= $dB} {incr iR} {
# puts "(1) iR=$iR"
        set r 0
        for {set iA 0; set iB $iR}\
		{$iA <= $dA && $iB >= 0}\
		{incr iA; incr iB -1} {
# puts "iA=$iA iB = $iB"
	    set r [expr {$r ^ ([lindex $pA $iA] & [lindex $pB $iB])}]
	}
	lappend pR $r
	if {$r != 0} {
	    set dRt $iR
	}
    }
    for {set iA0 1} {$iR <= $dR} {incr iR; incr iA0} {
# puts "(2) iR=$iR"
	set r 0
	for {set iA $iA0; set iB $dB}\
		{$iA <= $dA && $iB >= 0}\
		{incr iA; incr iB -1} {
# puts "iA=$iA iB = $iB"
	    set r [expr {$r ^ ([lindex $pA $iA] & [lindex $pB $iB])}]
# puts "[lindex $pA $iA] * [lindex $pB $iB] = [expr {[lindex $pA $iA] * [lindex $pB $iB]}] -> $r"
	}
	lappend pR $r
	if {$r != 0} {
	    set dRt $iR
	}
    }
    return [lrange $pR 0 $dRt]
}

proc polyM2::degre {poly} {
    if {$poly == 0} {
	return -1
    }
    return [expr {[llength $poly] - 1}]
}

proc polyM2::modulo {poly Pp} {
    set dMax [polyM2::degre $Pp]
    set dPoly [polyM2::degre $poly]
    while {$poly != 0 && [set N  [expr {[polyM2::degre $poly] - $dMax}]] >= 0} {
	# add == sub modulo2
	set poly [polyM2::add $poly [polyM2::rawxNMul $Pp $N]]
    }
    return $poly
}

proc polyM2::mul {p1 p2 Pp} {
    return [polyM2::modulo [polyM2::rawmul $p1 $p2] $Pp]
}

proc polyM2::rawdiv {p1 p2} {
    set q [list]
    while {[polyM2::compare $p1 $p2] >= 0} {
	set N [expr {[polyM2::degre $p1] - [polyM2::degre $p2]}]
	lappend q $N
	set p1 [polyM2::add $p1 [polyM2::rawxNMul $p2 $N]]
    }
    set newq [list]
    set i 0
    for {set iq [expr {[llength $q] - 1}]} {$iq>=0} {incr iq -1} {
	while {$i < $iq} {
	    lappend newq 0
	    incr i
	}
	lappend newq 1
	incr i
    }
    return [list $newq $p1]
}

proc polyM2::inv_Direct {p Pp} {
    foreach {q r} [polyM2::rawdiv $Pp $p] {}
    if {$r != 1} {
	error "inv $p $Pp -> $q, $r!=1"
    }
    return $q
} 

set HELP(polyM2::generate_gf) {

    Construit le tableau $alphaPVar des puissances de "x"
    et le tableau inverse $indexOfVar

    Cf. generate_gf de rs.c

    On rajoute x^infini = {}

}

proc polyM2::generate_gf {alphaPVar indexOfVar Pp} {
    upvar $alphaPVar alphaP
    upvar $indexOfVar indexOf
    set MM [polyM2::degre $Pp]
    set NN [expr {(1<<$MM) - 1}]

    set mask [list 1]
    set alphaP($MM) 0
    for {set i 0} {$i < $MM} {incr i} {
	set alphaP($i) $mask
	set indexOf($mask) $i
	if {[polyM2::isSet $Pp $i]} {
	    set alphaP($MM) [polyM2::add $alphaP($MM)  $mask]
	}
	set mask [polyM2::rawxMul $mask]
    }
    
    set indexOf($alphaP($MM)) $MM
    
    set mask [polyM2::xDiv $mask]
    
    for {set i [expr {$MM + 1}]} {$i < $NN} {incr i} {
	set im1 [expr {$i - 1}]
	if {[polyM2::compare $alphaP($im1) $mask] >=0} {
	    set alphaP($i) [polyM2::add $alphaP($MM) [polyM2::rawxMul [polyM2::add $alphaP($im1) $mask]]]
	} else {
	    set alphaP($i) [polyM2::rawxMul $alphaP($im1)]
	}
	set indexOf($alphaP($i)) $i
    }
    # infini
    set indexOf(0) $NN 
    set alphaP($NN) 0
}

set HELP(polyM2::::generate_gf_Direct) {
    idem polyM2::::generate_gf, par un calcul direct
}

proc polyM2::::generate_gf_Direct {alphaPVar indexOfVar Pp} {
    upvar $alphaPVar alphaP
    upvar $indexOfVar indexOf
    set MM [degre $Pp]
    set NN [expr {(1<<$MM) - 1}]
    
    set aP [list 1]
    set alphaP(0) $aP
    set indexOf($aP) 0
    
    set alpha [list 0 1]
    for {set i 1} {$i < $NN} {incr i} {
	set aP [polyM2::mul $aP $alpha $Pp]
	set alphaP($i) $aP
	set indexOf($aP) $i
    }
    if {[polyM2::mul $aP $alpha $Pp] != [list 1]} {
	error "Non cyclique"
    }
    
    # infini
    set indexOf(0) $NN 
    set alphaP($NN) 0
}

set Pp [list 1 0 1 1 1 0 0 0 1] ;# Primitive Polynomial pour MM = 8
# MM = 8, NN = 255


polyM2::generate_gf alphaP indexOf $Pp
polyM2::generate_gf_Direct alphaP_Direct indexOf_Direct $Pp

for {set i 0} {$i <= 255} {incr i} {
    set aP $alphaP($i)
    puts -nonewline "[format %3d $i] "
    if {$aP != $alphaP_Direct($i) || $indexOf($aP) != $i || $indexOf_Direct($aP) != $i} {
	error "i = $i, $aP != $alphaP_Direct($i) || $indexOf($aP) != $i || $indexOf_Direct($aP) != $i"
    }
    puts [list $aP]
}


set eqP {
     a0*w0 +  a0*w1 +...+  a0*w27 + a0*q0 + a0*q1 + a0*q2 + a0*q3 = 0
    a31*w0 + a30*w1 +...+  a4*w27 + a3*q0 + a2*q1 + a1*q2 + a0*q3 = 0 
    a62*w0 + a60*w1 +...+  a8*w27 + a6*q0 + a4*q1 + a2*q2 + a0*q3 = 0 
    a93*w0 + a90*w1 +...+ a12*w27 + a9*q0 + a6*q1 + a3*q2 + a0*q3 = 0 

soit (modulo 2)

    a0*q0 + a0*q1 + a0*q2 + a0*q3 =  a0*w0 +  a0*w1 +...+  a0*w27 = r0
    a3*q0 + a2*q1 + a1*q2 + a0*q3 = a31*w0 + a30*w1 +...+  a4*w27 = r1
    a6*q0 + a4*q1 + a2*q2 + a0*q3 = a62*w0 + a60*w1 +...+  a8*w27 = r2
    a9*q0 + a6*q1 + a3*q2 + a0*q3 = a93*w0 + a90*w1 +...+ a12*w27 = r3

    a0*q0 = a0*q1 + a0*q2 + a0*q3 + r0

    (a3+a2)*q1 + (a3+a1)*q2 + (a3+a0)*q3 = a3*r0 + r1
    (a6+a4)*q1 + (a6+a2)*q2 + (a6+a0)*q3 = a6*r0 + r2
    (a9+a6)*q1 + (a9+a3)*q2 + (a9+a0)*q3 = a9*r0 + r3

    (a3+a2)*q1 = (a3+a1)*q2 + (a3+a0)*q3 + a3*r0 + r1

    (a6+a4)*(a3+a2)*q1 + (a6+a4)*(a3+a1)*q2 + (a6+a4)*(a3+a0)*q3 = (a6+a4)*a3*r0 + (a6+a4)*r1
    (a3+a2)*(a6+a4)*q1 + (a3+a2)*(a6+a2)*q2 + (a3+a2)*(a6+a0)*q3 = (a3+a2)*a6*r0 + (a3+a2)*r2
    (a9+a6)*(a3+a2)*q1 + (a9+a6)*(a3+a1)*q2 + (a9+a6)*(a3+a0)*q3 = (a9+a6)*a3*r0 + (a9+a6)*r1
    (a3+a2)*(a9+a6)*q1 + (a3+a2)*(a9+a3)*q2 + (a3+a2)*(a9+a0)*q3 = (a3+a2)*a9*r0 + (a3+a2)*r3

      (a9+a8+a7+a6)*q1 +         (a9+a5)*q2 +   (a9+a7+a6+a4)*q3 =   (a9+a7)*r0 + (a6+a4)*r1
      (a9+a8+a7+a6)*q1 +   (a9+a8+a5+a4)*q2 +   (a9+a8+a3+a2)*q3 =   (a9+a8)*r0 + (a3+a2)*r2
    (a12+a11+a9+a8)*q1 + (a12+a10+a9+a7)*q2 +        (a12+a6)*q3 =  (a12+a9)*r0 + (a9+a6)*r1
    (a12+a11+a9+a8)*q1 + (a12+a11+a6+a4)*q2 + (a12+a11+a3+a2)*q3 = (a12+a11)*r0 + (a3+a2)*r3

                  (a8+a4)*q2 + (a8+a7+a6+a4+a3+a2)*q3 =  (a8+a7)*r0 + (a6+a4)*r1 + (a3+a2)*r2
    (a11+a10+a9+a7+a6+a4)*q2 +      (a11+a6+a3+a2)*q3 = (a11+a9)*r0 + (a9+a6)*r1 + (a3+a2)*r3

                (a6+a2)*q2 + (a6+a5+a4+a3+a2+a0)*q3 = (a6+a5)*r0 + (a4+a2)*r1 + (a1+a0)*r2
    (a9+a8+a7+a5+a4+a2)*q2 +       (a9+a4+a1+a0)*q3 = (a9+a7)*r0 + (a7+a4)*r1 + (a1+a0)*r3

                (a6+a2)*q2 = (a6+a5+a4+a3+a2+a0)*q3 + (a6+a5)*r0 + (a4+a2)*r1 + (a1+a0)*r2

    (a9+a8+a7+a5+a4+a2)*(a6+a2)*q2 + (a9+a8+a7+a5+a4+a2)*(a6+a5+a4+a3+a2+a0)*q3 =\
        (a9+a8+a7+a5+a4+a2)*(a6+a5)*r0 + (a9+a8+a7+a5+a4+a2)*(a4+a2)*r1 + (a9+a8+a7+a5+a4+a2)*(a1+a0)*r2
    (a6+a2)*(a9+a8+a7+a5+a4+a2)*q2 + (a6+a2)*(a9+a4+a1+a0)*q3 = \
        (a6+a2)*(a9+a7)*r0 + (a6+a2)*(a7+a4)*r1 + (a6+a2)*(a1+a0)*r3



}


proc polyM2::calculeP {alphaPName Pp} {
    upvar $alphaPName alphaP
    set l0 [list]
    set l1 [list]
    set l2 [list]
    set l3 [list]
    for {set i0 0; set i1 31; set i2 62; set i3 93} {$i1>=0} {incr i1 -1; incr i2 -2 ; incr i3 -3} {
	lappend l0 $alphaP($i0)
	lappend l1 $alphaP($i1)
	lappend l2 $alphaP($i2)
	lappend l3 $alphaP($i3)
    }

    set l1new [list]
    set l2new [list]
    set l3new [list]
    set l0_0 [lindex $l0 28]
    set l1_0 [lindex $l1 28]
    set l2_0 [lindex $l2 28]
    set l3_0 [lindex $l3 28]

    foreach a0 $l0 a1 $l1 a2 $l2 a3 $l3 {
	lappend l1new [polyM2::add [polyM2::mul $a0 $l1_0 $Pp] [polyM2::mul $a1 $l0_0 $Pp]]
	lappend l2new [polyM2::add [polyM2::mul $a0 $l2_0 $Pp] [polyM2::mul $a2 $l0_0 $Pp]]
	lappend l3new [polyM2::add [polyM2::mul $a0 $l3_0 $Pp] [polyM2::mul $a3 $l0_0 $Pp]]
    }

    set l1 $l1new
    set l2 $l2new
    set l3 $l3new

    unset l1new l0_0 l1_0 l2_0 l3_0 a0 a1 a2 a3
    set l2new [list]
    set l3new [list]
    set l1_1 [lindex $l1 29]
    set l2_1 [lindex $l2 29]
    set l3_1 [lindex $l3 29]

    foreach a1 $l1 a2 $l2 a3 $l3 {
	lappend l2new [polyM2::add [polyM2::mul $a1 $l2_1 $Pp] [polyM2::mul $a2 $l1_1 $Pp]]
	lappend l3new [polyM2::add [polyM2::mul $a1 $l3_1 $Pp] [polyM2::mul $a3 $l1_1 $Pp]]
    }

    set l2 $l2new
    set l3 $l3new

    unset l2new l1_1 l2_1 l3_1 a1 a2 a3
    set l3new [list]
    set l2_2 [lindex $l2 30]
    set l3_2 [lindex $l3 30]

    foreach a2 $l2 a3 $l3 {
	lappend l3new [polyM2::add [polyM2::mul $a2 $l3_2 $Pp] [polyM2::mul $a3 $l2_2 $Pp]]
    }

    set l3 $l3new

    unset l3new l2_2 l3_2 a2 a3
    set l2new [list]
    set l2_3 [lindex $l2 31]
    set l3_3 [lindex $l3 31]
    foreach a2 $l2 a3 $l3 {
	lappend l2new [polyM2::add [polyM2::mul $a2 $l3_3 $Pp] [polyM2::mul $a3 $l2_3 $Pp]]
    }

    set l2 $l2new
    unset l2new l2_3 l3_3 a2 a3
    set l1new [list]
    set l1_2 [lindex $l1 30]
    set l1_3 [lindex $l1 31]
    set l2_2 [lindex $l2 30]
    set l3_3 [lindex $l3 31]
    set l1f [polyM2::mul $l2_2 $l3_3 $Pp]
    set l2f [polyM2::mul $l1_2 $l3_3 $Pp]
    set l3f [polyM2::mul $l1_3 $l2_2 $Pp]
    foreach a1 $l1 a2 $l2 a3 $l3 {
	lappend l1new [polyM2::add [polyM2::mul $a1 $l1f $Pp]\
		                   [polyM2::add [polyM2::mul $a2 $l2f $Pp] [polyM2::mul $a3 $l3f $Pp]]]
    }

    set l1 $l1new
    unset l1new l1_2 l1_3 a1 a2 a3
    set l0new [list]
    set l0_1 [lindex $l0 29]
    set l0_2 [lindex $l0 30]
    set l0_3 [lindex $l0 31]
    set l1_1 [lindex $l1 29]
    set l0f [polyM2::mul $l1_1 [polyM2::mul $l2_2 $l3_3 $Pp] $Pp]
    set l1f [polyM2::mul $l0_1 [polyM2::mul $l2_2 $l3_3 $Pp] $Pp]
    set l2f [polyM2::mul $l0_2 [polyM2::mul $l1_1 $l3_3 $Pp] $Pp]
    set l3f [polyM2::mul $l0_3 [polyM2::mul $l1_1 $l2_2 $Pp] $Pp]
    foreach a0 $l0 a1 $l1 a2 $l2 a3 $l3 {
	lappend l0new [polyM2::add [polyM2::add [polyM2::mul $a0 $l0f $Pp] [polyM2::mul $a1 $l1f $Pp]]\
		                   [polyM2::add [polyM2::mul $a2 $l2f $Pp] [polyM2::mul $a3 $l3f $Pp]]]
    }


    set l0 $l0new

    foreach a0 $l0 a1 $l1 a2 $l2 a3 $l3 {
	puts [list $a0 $a1 $a2 $a3]
    }
}

polyM2::calculeP alphaP $Pp

