package provide m22c 0.1

package require fidev
package require complexes

namespace eval m22c {}

proc ::m22c::testIfGood {m} {
    if {[llength $m] != 4} {
	error [list Bad 22matrix : $m]
    }
}

proc ::m22c::trace {m} {
    ::m22c::testIfGood $m
    foreach {m11 m12 m21 m22} $m {}
    return [::complexes::add $m11 $m22]
}

proc ::m22c::add {a b} {
    ::m22c::testIfGood $a
    ::m22c::testIfGood $b
    foreach {a11 a12 a21 a22} $a {}
    foreach {b11 b12 b21 b22} $b {}
    return [list\
	    [complexes::add $a11 $b11]\
	    [complexes::add $a12 $b12]\
	    [complexes::add $a21 $b21]\
	    [complexes::add $a22 $b22]]
}

proc ::m22c::sub {a b} {
    ::m22c::testIfGood $a
    ::m22c::testIfGood $b
    foreach {a11 a12 a21 a22} $a {}
    foreach {b11 b12 b21 b22} $b {}
    return [list\
	    [::complexes::sub $a11 $b11]\
	    [::complexes::sub $a12 $b12]\
	    [::complexes::sub $a21 $b21]\
	    [::complexes::sub $a22 $b22]]
}

proc ::m22c::mul {a b} {
    ::m22c::testIfGood $a
    ::m22c::testIfGood $b
    foreach {a11 a12 a21 a22} $a {}
    foreach {b11 b12 b21 b22} $b {}
    return [list\
	    [complexes::add [complexes::mul $a11 $b11] [complexes::mul $a12 $b21]]\
	    [complexes::add [complexes::mul $a11 $b12] [complexes::mul $a12 $b22]]\
	    [complexes::add [complexes::mul $a21 $b11] [complexes::mul $a22 $b21]]\
	    [complexes::add [complexes::mul $a21 $b12] [complexes::mul $a22 $b22]]]
}

proc ::m22c::det {a} {
    ::m22c::testIfGood $a
    foreach {a11 a12 a21 a22} $a {}
    return [complexes::sub [complexes::mul $a11 $a22] [complexes::mul $a12 $a21]]
}

proc ::m22c::inv {a} {
    ::m22c::testIfGood $a
    foreach {a11 a12 a21 a22} $a {}
    set det [m22c::det $a]
    if {[complexes::moduleCarre $det] == 0.0} {
	error [list matrice non inversible : $a]
    }
    return [m22c::pExt [complexes::inv $det] [list $a22 [complexes::neg $a12]\
	    [complexes::neg $a21] $a11]]
}


proc ::m22c::pExt {x a} {
    foreach {a11 a12 a21 a22} $a {}
    return [list\
	    [complexes::mul $x $a11]\
	    [complexes::mul $x $a12]\
	    [complexes::mul $x $a21]\
	    [complexes::mul $x $a22]]
}

proc ::m22c::expApprox {m n} {
    set un [list 1.0 0.0 0.0 1.0]
    set exp $un
    for {set i $n} {$i > 0} {incr i -1} {
	set exp [m22c::mul [m22c::pExt [expr {1.0/$i}] $m] $exp]
	set exp [m22c::add $un $exp]
    }
    return $exp
}

proc ::m22c::toRTpi {a} {
    ::m22c::testIfGood $a
    foreach {a11 a12 a21 a22} $a {}
    return [list\
	    [complexes::toRTpi $a11]\
	    [complexes::toRTpi $a12]\
	    [complexes::toRTpi $a21]\
	    [complexes::toRTpi $a22]]
}

