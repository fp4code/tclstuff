# RCS: @(#) $Id: complexes.1.1.tcl,v 1.3 2002/06/25 08:42:51 fab Exp $

# hypothèse : antan2pi retourne a avec -1<a<=1
package require trig_sun 1.0

fidev_load ../src/libtclcomplexes complexes

set EXEMPLE {
    set un 1.0
    set pipi [complexes::newXY 3.14 0.002]
}

proc floatToBinar {d} {
    binary scan [binary format d $d] B* v
    set sign [string index $v 0]
    set exponent [string range $v 1 11]
    set mantissa [string range $v 12 end]
    return [list $sign $mantissa $exponent]
}

proc binarToFloat {sign mantissa exponent} {
    if {$sign != "0" && $sign != "1"} {
	error "bad sign \"$sign\""
    }
    if {[string length $mantissa] != 52} {
	error "bad mantissa \"$mantissa\""
    }
    if {[string length $exponent] != 11} {
	error "bad exponent \"$exponent\""
    }
    set v [binary format B64 $sign$exponent$mantissa]
    binary scan $v d v
    return $v
}

proc precisionUltime {} {
}

namespace eval complexes {
}

proc complexes::errorNotComplex {c} {
    error [list $c n'est pas un complexe]
}

proc complexes::privateSumArgs {ta tb} {
    set t [expr {$ta + $tb}]
    if {$t > 1.0} {
	return [expr {$t - 2.0}]
    } elseif {$t <= -1.0} {
	return [expr {$t + 2.0}]
    } else {
	return $t
    }
}

     #################
     # constructeurs #
     #################

proc complexes::newXY {x y} {
    return [list "ComplexXY" $x $y]
}

# L'angle est sensé être -1 < t <= 1
proc complexes::newRTpi {r t} {
    if {$r < 0.0} {
	error "complexes::newRTpi : (\$r = $r) < 0.0"
    }
    set t [expr {$t - 2.0*ceil(0.5 * ($t - 1.0))}]
    return [list "ComplexRTpi" $r $t]
}

     ###################
     # procedures RTpi #
     ###################

proc complexes::toRTpi {c} {
    set len [llength $c]
    if {$len == 1} {
	if {$c >= 0} {
	    return [complexes::newRTpi $c 0.0]
	} else {
	    return [complexes::newRTpi [expr {-$c}] 1.0]
	}
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexRTpi" {
	    return $c
	}
	"ComplexXY" {
	    if {$v1 == 0.0 && $v2 == 0.0} {
		return [complexes::newRTpi 0.0 0.0]
	    } else {
		set r [expr {sqrt($v1*$v1 + $v2*$v2)}]
		set t [expr {atan2pi($v2, $v1)}]
		return [complexes::newRTpi $r $t]
	    }
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::module {c} {
    set len [llength $c]
    if {$len == 1} {
	return [expr {abs($c)}]
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexRTpi" {
	    return $v1
	}
	"ComplexXY" {
	    return [expr {sqrt($v1*$v1 + $v2*$v2)}]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::moduleCarre {c} {
    set len [llength $c]
    if {$len == 1} {
	return [expr {$c*$c}]
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexRTpi" {
	    return [expr {$v1*$v1}]
	}
	"ComplexXY" {
	    return [expr {$v1*$v1 + $v2*$v2}]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}


proc complexes::arg {c} {
    set len [llength $c]
    if {$len == 1} {
	if {$c >= 0} {
	    return 0.0
	} else {
	    return 1.0
	}
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexRTpi" {
	    return $v2
	}
	"ComplexXY" {
	    # 0 pour 0
	    return [expr {atan2pi($v2, $v1)}]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::inv {c} {
    set len [llength $c]
    if {$len == 1} {
	if {$c == 0.0} {
	    error "complexes::inv : argument nul"
	} else {
	    return [expr {1.0/$c}]
	}
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexRTpi" {
	    if {$v2 != 1.0} {
		set v2 [expr {-$v2}]
	    }
	    if {$v1 == 0.0} {
		error "complexes::inv : argument nul"
	    }
	    return [complexes::newRTpi [expr {1.0/$v1}] $v2]
	}
	"ComplexXY" {
	    if {abs($v2) < abs($v1)} {
		set f [expr {$v2/$v1}]
		set x [expr {1.0 / ($v1 + $v2 * $f)}]
		set y [expr {-$f * $x}] 
	    } elseif {$v2 != 0.0} {
		set f [expr {$v1/$v2}]
		set y [expr {-1.0 / ($v2 + $v1 * $f)}]
		set x [expr {-$f * $y}]
	    } else {
		error "complexes::inv : argument nul"
	    }
	    return [complexes::newXY $x $y]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::sqrt {a} {
    set alen [llength $a]
    if {$alen == 1} {
	if {$a >= 0.0} {
	    return [expr {sqrt($a)}]
	} else {
	    return [complexes::newXY 0.0 [expr {sqrt(-$a)}]]
	}
    }
    
    set a [complexes::toRTpi $a]
    foreach {taga r t} $a {}
    set r [expr {sqrt($r)}]
    # partie imaginaire positive
    if {$t >= 0} {
	set t [expr {0.5*$t}]
    } else {
	set t [expr {1.0 + 0.5*$t}]
    }
    return [complexes::newRTpi $r $t]
}    

     #################
     # procedures XY #
     #################

proc complexes::toXY {c} {
    set len [llength $c]
    if {$len == 1} {
	return [complexes::newXY $c 0.0]
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return $c
	}
	"ComplexRTpi" {
	    set x [expr {$v1*cospi($v2)}]
	    set y [expr {$v1*sinpi($v2)}]
	    return [complexes::newXY $x $y]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

set HELP(::complexes::toStandard) {
    transforme le complexe en liste {Re Im}
}
proc ::complexes::toStandard {c} {
    set len [llength $c]
    if {$len == 1} {
	return [list $c 0.0]
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return [lrange $c 1 2]
	}
	"ComplexRTpi" {
	    set x [expr {$v1*cospi($v2)}]
	    set y [expr {$v1*sinpi($v2)}]
	    return [list $x $y]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::re {c} {
    set len [llength $c]
    if {$len == 1} {
	return $c
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return $v1
	}
	"ComplexRTpi" {
	    return [expr {$v1*cospi($v2)}]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::im {c} {
    set len [llength $c]
    if {$len == 1} {
	return 0.0
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return $v2
	}
	"ComplexRTpi" {
	    return [expr {$v1*sinpi($v2)}]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::neg {c} {
    set len [llength $c]
    if {$len == 1} {
	return [expr {-$c}]
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return [complexes::newXY [expr {-$v1}] [expr {-$v2}]]
	}
	"ComplexRTpi" {
	    if {$v2 <= 0.0} {
		set v2 [expr {$v2 + 1.0}]
	    } else {
		set v2 [expr {$v2 - 1.0}]
	    }
	    return [complexes::newRTpi $v1 $v2]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::conj {c} {
    set len [llength $c]
    if {$len == 1} {
	return $c
    } elseif {$len != 3} {
	complexes::errorNotComplex $c
    }
    foreach {tag v1 v2} $c {}
    switch -exact --  $tag {
	"ComplexXY" {
	    return [complexes::newXY [expr {$v1}] [expr {-$v2}]]
	}
	"ComplexRTpi" {
	    if {$v2 != 1.0} {
		set v2 [expr {-$v2}]
	    }
	    return [complexes::newRTpi $v1 $v2]
	}
	default {
	    complexes::errorNotComplex $c
	}
    }
}

proc complexes::add {a b} {
    foreach {taga xa ya} [complexes::toXY $a] {}
    foreach {tagb xb yb} [complexes::toXY $b] {}
    return [complexes::newXY [expr {$xa + $xb}] [expr {$ya + $yb}]]
}

proc complexes::sub {a b} {
    foreach {taga xa ya} [complexes::toXY $a] {}
    foreach {tagb xb yb} [complexes::toXY $b] {}
    return [newXY [expr {$xa - $xb}] [expr {$ya-$yb}]]
}    

proc complexes::mul {a b} {
    set alen [llength $a]
    set blen [llength $b]
    if {$alen == 1} {
	if {$blen == 1} {
	    return [expr {$a*$b}]
	} else {
	    return [complexes::realMul $a $b]
	}
    } elseif {$alen != 3} {
	complexes::errorNotComplex $c
    }
    if {$blen == 1} {
	return [complexes::realMul $b $a]
    }
    
    foreach {taga v1a v2a} $a {}
    foreach {tagb v1b v2b} $b {}
    if {$taga == "ComplexRTpi" || $tagb == "ComplexRTpi"} {
	foreach {taga ra ta} [complexes::toRTpi $a] {}
	foreach {tagb rb tb} [complexes::toRTpi $b] {}
	set t [complexes::privateSumArgs $ta $tb]
	return [complexes::newRTpi [expr {$ra*$rb}] $t]
    } else {
	set x [expr {$v1a * $v1b - $v2a * $v2b}]
	set y [expr {$v1a * $v2b + $v2a * $v1b}]
	return [complexes::newXY $x $y]
    }
}    

proc complexes::div {a b} {
    return [complexes::mul $a [complexes::inv $b]]
}

proc complexes::realMul {lambda a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [expr {$lambda * $a}]
    }
    
    foreach {taga v1a v2a} $a {}
    if {$taga == "ComplexRTpi"} {
	if {$lambda >= 0.0} {
	    return [complexes::newRTpi [expr {$lambda*$v1a}] $v2a]
	} else {
	    set t [complexes::privateSumArgs $v2a 1.0]
	    return [newRTpi [expr {abs($lambda)*$v1a}] $t]
	}
    } elseif {$taga == "ComplexXY"} {
	return [complexes::newXY [expr {$lambda*$v1a}] [expr {$lambda*$v2a}]]
    } else {
	complexes::errorNotComplex $c
    }
}    

proc complexes::iMul {a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [complexes::newXY 0.0 $a]
    }
    
    foreach {taga v1a v2a} $a {}
    if {$taga == "ComplexRTpi"} {
	return [complexes::newRTpi $v1a [expr {$v2a + 0.5}]]
    } elseif {$taga == "ComplexXY"} {
	return [complexes::newXY [expr {-$v2a}] $v1a]
    } else {
	complexes::errorNotComplex $c
    }
}    

# retourne une partie imaginaire positive, ou un réel positif

proc complexes::cos {a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [expr {cos($a)}]
    }
    
    set a [complexes::toXY $a]
    foreach {taga a b} $a {}
    set x [expr {cos($a)*cosh($b)}]
    set y [expr {-sin($a)*sinh($b)}]
    return [complexes::newXY $x $y]
}    

proc complexes::sin {a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [expr {cos($a)}]
    }
    
    set a [toXY $a]
    foreach {taga a b} $a {}
    set x [expr {sin($a)*cosh($b)}]
    set y [expr {cos($a)*sinh($b)}]
    return [complexes::newXY $x $y]
}

proc complexes::exp {a} {
    set a [complexes::toXY $a]
    foreach {taga a b} $a {}
    set expa [expr {exp($a)}]
    if {$b == 0.0} {
	return $expa
    }
    
    set c [expr {$expa*cos($b)}]
    set s [expr {$expa*sin($b)}]
    return [complexes::newXY $c $s]
}
    
proc complexes::cosh_old {a} {
    set ep [exp $a]
    set em [exp [neg $a]]
    set c [complexes::add $ep $em]
    return [complexes::realMul 0.5 $c]
}

proc complexes::sinh_old {a} {
    set ep [exp $a]
    set em [exp [neg $a]]
    set c [sub $ep $em]
    return [complexes::realMul 0.5 $c]
}

proc complexes::cosh {a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [expr {cosh($a)}]
    }
    
    set a [toXY $a]
    foreach {taga a b} $a {}
    set x [expr {cosh($a)*cos($b)}]
    set y [expr {sinh($a)*sin($b)}]
    return [complexes::newXY $x $y]
}

proc complexes::sinh {a} {
    set alen [llength $a]
    if {$alen == 1} {
	return [expr {sinh($a)}]
    }
    
    set a [toXY $a]
    foreach {taga a b} $a {}
    set x [expr {sinh($a)*cos($b)}]
    set y [expr {cosh($a)*sin($b)}]
    return [complexes::newXY $x $y]
}

package provide complexes 1.1
