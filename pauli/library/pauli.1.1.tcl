package provide pauli 1.0

package require fidev
package require complexes 1.0
package require 3vectors 1.0

namespace eval pauli {
    variable I [list 1.0 0.0 0.0 1.0]
    variable X [list 0.0 1.0 1.0 0.0]
    variable Y [list 0.0 [complexes::newXY 0.0 -1.0] [complexes::newXY 0.0 1.0] 0.0] 
    variable X [list 1.0 0.0 0.0 -1.0]
}

set ::pauli::demos {
    set a11 [complexes::newXY 1.1 3.1]
    set a12 [complexes::newXY 4.2 8.1]
    set a21 [complexes::newRTpi 3.6 1.2]
    set a22 [complexes::newXY -1.5 6.1]
    set a [list $a11 $a12 $a21 $a22]
    set pa [pauli::canonToPauli $a]
    set an [pauli::pauliToCanon $pa]
    set a21n [complexes::toXY $a21]

    set b11 [complexes::newRTpi 1.01 1.99]
    set b12 [complexes::newRTpi 4.02 -1.01]
    set b21 [complexes::newXY 3.06 1.02]
    set b22 [complexes::newRTpi 1.05 0.01]
    set b [list $b11 $b12 $b21 $b22]
    set pb [pauli::canonToPauli $b]
    set bn [pauli::pauliToCanon $pb]
    set b21n [complexes::toRTpi $b21]

    set pc [pauli::mul $pa $pb]
    set c [pauli::pauliToCanon $pc]
    
    set c11 [complexes::add [complexes::mul $a11 $b11] [complexes::mul $a12 $b21]]
    set c12 [complexes::add [complexes::mul $a11 $b12] [complexes::mul $a12 $b22]]
    set c21 [complexes::add [complexes::mul $a21 $b11] [complexes::mul $a22 $b21]]
    set c22 [complexes::add [complexes::mul $a21 $b12] [complexes::mul $a22 $b22]]
    
    set pcInv [pauli::inv $pc]
    set unite1 [pauli::mul $pc $pcInv]
    set unite2 [pauli::mul $pcInv $pc]
    puts $unite1
    puts $unite2
}

# passage d'une liste "m11 m12 m21 m11" représentant une matrice 2x2 (m11 m12) 
#                                                                    (m21 m22)
# à une liste "uI uX uY uZ" décomposition selon la base des matrices de Pauli
# 
proc ::pauli::canonToPauli {matrice} {
    if {[llength $matrice] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {a11 a12 a21 a22} $matrice {}
    set uI [complexes::add $a11 $a22]
    set uI [complexes::realMul 0.5 $uI]
    set uX [complexes::add $a12 $a21]
    set uX [complexes::realMul 0.5 $uX]
    set uY [complexes::sub $a12 $a21]
    set uY [complexes::realMul 0.5 $uY]
    set uY [complexes::iMul $uY]
    set uZ [complexes::sub $a11 $a22]
    set uZ [complexes::realMul 0.5 $uZ]
    return [list $uI $uX $uY $uZ]
}

# Transformation inverse de canonToPauli
proc ::pauli::pauliToCanon {pauli} {
    if {[llength $pauli] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {uI uX uY uZ} $pauli {}
    set iuY [complexes::iMul $uY]
    set a11 [complexes::add $uI $uZ]
    set a12 [complexes::sub $uX $iuY]
    set a21 [complexes::add $uX $iuY]
    set a22 [complexes::sub $uI $uZ]
    return [list $a11 $a12 $a21 $a22]
}

# déterminant de la matrice donnée par sa décomposition de Pauli
proc ::pauli::det {pauli} {
    if {[llength $pauli] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $pauli 0]
    set U [lrange $pauli 1 3]
    return [complexes::sub [complexes::mul $u $u] [3vectors::carre $U]] 
}

# inverse de la matrice
proc ::pauli::inv {pauli} {
    if {[llength $pauli] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $pauli 0]
    set U [lrange $pauli 1 3]
    set fact [complexes::inv [::pauli::det $pauli]]
    set w [complexes::mul $fact $u]
    set W [3vectors::pExt [complexes::neg $fact] $U]
    return [concat [list $w] $W]
}

# Produit de matrices
proc ::pauli::mul {uU vV} {
    if {[llength $uU] != 4 || [llength $vV] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]
    set v [lindex $vV 0]
    set V [lrange $vV 1 3]

    set w [complexes::add [complexes::mul $u $v] [3vectors::pScal $U $V]]
    set W [3vectors::add\
	    [3vectors::add\
	    [3vectors::pExt $u $V]\
	    [3vectors::pExt $v $U]]\
	    [3vectors::iMul [3vectors::pVect $U $V]]]
    return [concat [list $w] $W]
}

# somme de matrices
proc ::pauli::add {uU vV} {
    if {[llength $uU] != 4 || [llength $vV] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]
    set v [lindex $vV 0]
    set V [lrange $vV 1 3]

    set w [complexes::add $u $v]
    set W [3vectors::add $U $V]

    return [concat [list $w] $W]
}

# différence de matrices
proc ::pauli::sub {uU vV} {
    if {[llength $uU] != 4 || [llength $vV] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]
    set v [lindex $vV 0]
    set V [lrange $vV 1 3]

    set w [complexes::sub $u $v]
    set W [3vectors::sub $U $V]

    return [concat [list $w] $W]
}

# produit par un scalaire
proc ::pauli::pExt {x uU} {
    if {[llength $uU] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]

    set w [complexes::mul $x $u]
    set W [3vectors::pExt $x $U]

    return [concat [list $w] $W]
}

# 
proc ::pauli::conj {uU} {
    if {[llength $uU] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set w [lindex $uU 0]
    set U [lrange $uU 1 3]

    set W [3vectors::pExt -1.0 $U]

    return [concat [list $w] $W]
}

# Exponentielle de matrice
proc ::pauli::exp {uU} {
    if {[llength $uU] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]

    set eu [::complexes::exp $u]
    set mU [::3vectors::racineDuCarre $U]

    if {[::complexes::moduleCarre $mU] == 0.0} {
	return [list $eu 0.0 0.0 0.0]
    }

    set w [::complexes::mul $eu [complexes::cosh $mU]]
    set W [::3vectors::pExt\
               [::complexes::div [::complexes::mul $eu [complexes::sinh $mU]] $mU]\
	       $U]
    return [concat [list $w] $W]
}

# produit d'une matrice et d'un 2vector
proc ::pauli::mulVect {pauli v} {
    set matrice [pauliToCanon $pauli]
    if {[llength $v] != 2} {
	error "Le vecteur $v n'a pas 2 éléments"
    }
    foreach {a11 a12 a21 a22} $matrice {}
    foreach {v1 v2} $v {}
    set r1 [complexes::mul $a11 $v1]
    set r1 [complexes::add $r1 [complexes::mul $a12 $v2]]
    set r2 [complexes::mul $a21 $v1]
    set r2 [complexes::add $r2 [complexes::mul $a22 $v2]]
    return [list $r1 $r2]
}

# vérification du produit d'exponentielles
proc ::pauli::prodExpV1 {uU vV} {
    if {[llength $uU] != 4 || [llength $vV] != 4} {
	error "On attend la liste des 4 valeurs de la matrice"
    }
    set u [lindex $uU 0]
    set U [lrange $uU 1 3]
    set v [lindex $vV 0]
    set V [lrange $vV 1 3]

    set rcU [::3vectors::racineDuCarre $U]
    set rcV [::3vectors::racineDuCarre $V]
    set cU [::complexes::cosh $rcU]
    set cV [::complexes::cosh $rcV]
    set sU [::complexes::sinh $rcU]
    set sV [::complexes::sinh $rcV]

    set w [::complexes::mul $cU $cV]
    set W [list 0.0 0.0 0.0]

    set UisNot0 [expr {[::complexes::moduleCarre $rcU] != 0.0}]
    set VisNot0 [expr {[::complexes::moduleCarre $rcV] != 0.0}]

    if {$UisNot0} {
	set Un [::3vectors::pExt [::complexes::inv $rcU] $U]
	set W [::3vectors::add $W [::3vectors::pExt [::complexes::mul $sU $cV] $Un]]
    }
    if {$VisNot0} {
	set Vn [::3vectors::pExt [::complexes::inv $rcV] $V]
	set W [::3vectors::add $W [::3vectors::pExt [::complexes::mul $sV $cU] $Vn]]
    }
    if {$UisNot0 && $VisNot0} {
	set w [::complexes::add $w [::complexes::mul\
		[::complexes::mul $sU $sV]\
		[::3vectors::pScal $Un $Vn]]]
	set W [::3vectors::add $W [::3vectors::pExt\
		[::complexes::iMul [::complexes::mul $sU $sV]]\
		[::3vectors::pVect $Un $Vn]]]
    }

    set euv [::complexes::exp [::complexes::add $u $v]]
    set w [::complexes::mul $euv $w]
    set W [::3vectors::pExt $euv $W]

    return [concat [list $w] $W]
}
