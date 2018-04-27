package provide 3vectors 1.1

# 22 juin 2001 (FP) passage à supercomplex

package require fidev
package require supercomplex 0.2

namespace eval 3vectors {}

proc 3vectors::pScal {a b} {
    if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
     return [supercomplex add [supercomplex add\
	    [supercomplex mul $a1 $b1]\
	    [supercomplex mul $a2 $b2]]\
	    [supercomplex mul $a3 $b3]]
}

proc 3vectors::pVect {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [supercomplex sub [supercomplex mul $a2 $b3] [supercomplex mul $a3 $b2]]
    set r2 [supercomplex sub [supercomplex mul $a3 $b1] [supercomplex mul $a1 $b3]]
    set r3 [supercomplex sub [supercomplex mul $a1 $b2] [supercomplex mul $a2 $b1]]
    return [list $r1 $r2 $r3]
}

proc 3vectors::add {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [supercomplex add $a1 $b1]
    set r2 [supercomplex add $a2 $b2]
    set r3 [supercomplex add $a3 $b3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::sub {a b} {
     if {[llength $a] != 3 || [llength $b] != 3} {
	error "bad 3vector(s)"
    }
    foreach {a1 a2 a3} $a {}
    foreach {b1 b2 b3} $b {}
    set r1 [supercomplex sub $a1 $b1]
    set r2 [supercomplex sub $a2 $b2]
    set r3 [supercomplex sub $a3 $b3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::pExt {s a} {
    if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}
    set r1 [supercomplex mul $s $a1]
    set r2 [supercomplex mul $s $a2]
    set r3 [supercomplex mul $s $a3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::iMul {a} {
    if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}
    set r1 [supercomplex iMul $a1]
    set r2 [supercomplex iMul $a2]
    set r3 [supercomplex iMul $a3]
    return [list $r1 $r2 $r3]
}

proc 3vectors::carre {a} {
      if {[llength $a] != 3} {
	error "bad 3vector"
    }
    foreach {a1 a2 a3} $a {}

    return [supercomplex add [supercomplex add\
	    [supercomplex mul $a1 $a1]\
	    [supercomplex mul $a2 $a2]]\
	    [supercomplex mul $a3 $a3]]
}

proc 3vectors::racineDuCarre {a} {
    return [supercomplex sqrt [3vectors::carre $a]]
}

