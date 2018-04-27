package provide 3vectors 1.0

package require fidev
package require complexes 1.0

namespace eval 3vectors {}

proc 3vectors::pScal {a b} {
    if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
     return [complexes::add [complexes::add\
	    [complexes::mul $a1 $b1]\
	    [complexes::mul $a2 $b2]]\
	    [complexes::mul $a3 $b3]]
}

proc 3vectors::pVect {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [complexes::sub [complexes::mul $a2 $b3] [complexes::mul $a3 $b2]]
    set r2 [complexes::sub [complexes::mul $a3 $b1] [complexes::mul $a1 $b3]]
    set r3 [complexes::sub [complexes::mul $a1 $b2] [complexes::mul $a2 $b1]]
    return [list $r1 $r2 $r3]
}

proc 3vectors::add {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [complexes::add $a1 $b1]
    set r2 [complexes::add $a2 $b2]
    set r3 [complexes::add $a3 $b3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::sub {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [complexes::sub $a1 $b1]
    set r2 [complexes::sub $a2 $b2]
    set r3 [complexes::sub $a3 $b3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::pExt {s a} {
    if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}
    set r1 [complexes::mul $s $a1]
    set r2 [complexes::mul $s $a2]
    set r3 [complexes::mul $s $a3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::iMul {a} {
    if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}
    set r1 [complexes::iMul $a1]
    set r2 [complexes::iMul $a2]
    set r3 [complexes::iMul $a3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::carre {a} {
      if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}

    return [complexes::add [complexes::add\
	    [complexes::mul $a1 $a1]\
	    [complexes::mul $a2 $a2]]\
	    [complexes::mul $a3 $a3]]
}

proc 3vectors::racineDuCarre {a} {
    return [complexes::sqrt [3vectors::carre $a]]
}

