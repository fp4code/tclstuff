# 28 février 2001 (FP)

set env(FIDEV_EXPERIMENTAL) /home/fab/C/fidev-sparc-SunOS-5.7-cc-debug/lib
package require fidev
package require blasObj
package require port3_nl2opt
package require blasmath
package require dblas1

# /home/fab/C/fidev-sparc-SunOS-5.7-cc-debug/Tcl/port3_nl2opt/src/psh

set O [blas::vector create double {1 0}] 
proc fx {x} {
    global O
    set tmp $x
    blas::mathsvop tmp - $O
    set r [::blas::dnrm2 $tmp]
    return [expr {$r*$r}]
}

set x [blas::vector create double {2 3}]
set b [blas::vector create double {-1 5 -2 10}]
set d [blas::vector create double {1 1}]
set p [blas::vector length $x]
set liv [expr {59 + $p}]
set lv [expr {77 + ($p*($p+23))/2}]

set alg 2
if {$alg == 1} {
    if {$liv < 82} {
        set liv 82
    }
    if {$lv < 98} {
        set lv 98
    }
}

set iv [blas::vector create long -length $liv]
set v [blas::vector create double -length $lv]

set x {double 4 5}
port3::divset $alg iv v
while {[lindex $iv 1] == 1 || [lindex $iv 1] == 2 || [lindex $iv 1] == 12} {
    puts $x
    port3::drmnfb $b $d [fx $x] iv v x
}

set O1 [blas::vector create double {1 0}] 
set O2 [blas::vector create double {-1 0}] 
proc fx2 {x} {
    global O1 O2
    set tmp $x
    blas::mathsvop tmp - $O1
    set r1 [::blas::dnrm2 $tmp]
    set tmp $x
    blas::mathsvop tmp - $O2
    set r2 [::blas::dnrm2 $tmp]
    return [expr {$r1*$r2}]
}

set x [blas::vector create double {0.9 2}]
set b [blas::vector create double {-2 0.95 -2 10}]
set d [blas::vector create double {1 1}]
set p [blas::vector length $x]
set liv [expr {59 + $p}]
set lv [expr {77 + ($p*($p+23))/2}]
set alg 2

port3::divset $alg iv v
while {[lindex $iv 1] == 1 || [lindex $iv 1] == 2 || [lindex $iv 1] == 12} {
    puts "**** $x"
    port3::drmnfb $b $d [fx $x] iv v x
}

set example(nlsb) {
    proc fx {x} {

        set tmp $x
        blas::mathsvop tmp +scal -10.0
        blas::mathsvop tmp pow_scal 2
        set ii [blas::vector create double -length [blas::vector length $tmp]]
        blas::mathsvop ii fill1 1.0 1.0
        blas::mathsvop tmp * $ii
        
        set f [expr {0.1*pow([blas::mathop sum $x],4) + [blas::mathop sum $tmp]}]
        return $f
    }

    set iv [blas::vector create long -length 68]
    set b [blas::vector create double {1 3 -2 10 1 21}]
    set d [blas::vector create double {1 2 3}]
    set v [blas::vector create double -length 132]
    set x [blas::vector create double {2 30 9}]

    #  ***  SET IV(1) TO 0 TO USE ALL DEFAULT INPUTS...
    blas::mathsvop iv set@ 1 0

# ... WE COULD HAVE MNHB INITIALIZE THE SCALE VECTOR D TO ALL ONES
# ... BY SETTING V(DINIT) TO 1.0 .  WE WOULD DO THIS BY REPLACING
# ... THE ABOVE ASSIGNMENT OF 0 TO IV(1) WITH THE FOLLOWING TWO LINES...
#
#     port3::divset 2 iv v
#     blas::mathsvop v set@ 38 1.0

# *** SOLVE THE PROBLEM -- MNHB WILL PRINT THE SOLUTION FOR US...
 
    port3::drmnfb $b $d [fx $x] iv v x
    set iv1 [blas::mathop get@ $iv 1]
    while {$iv1 == 1 || $iv1 == 2} {
        puts "--------- $iv1 $x -> [fx $x]"
        port3::drmnfb $b $d [fx $x] iv v x
        set iv1 [blas::mathop get@ $iv 1]
    }

}