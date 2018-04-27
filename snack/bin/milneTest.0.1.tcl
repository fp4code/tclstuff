#!/bin/sh

# \
exec wish "$0" ${1+"$@"}

package require fidev
package require blasObj
package require blasmath
package require hsplot

set HELP(milneTest.0.1.tcl) {
    # 23 décembre 2001 (FP)

    Vecteur d'état y = [list $x $v]

    équation
    
    \dot{x} = v
    \dot{v} = \Omega^2 \left(1 + \frac{1}{2 Q^2}\right)\left(\eta - x\right) - \Omega v

}

set fEch 44100.
set tEch [expr {1.0/$fEch}]

set N 20000
set PI [expr {atan2(0.0, -1.0)}]
set t [blas::vector create double -length $N]

set fEta 110
set omegaEta [expr {2.0*$PI*$fEta}]
blas::mathsvop t fill1 0 $tEch
set etaV $t ; set rien rien
blas::mathsvop etaV *scal $omegaEta
blas::mathsvop etaV sin

canvas .c -width 700
pack .c

proc plot {f color} {
    global t
    global xy
   
    set n [blas::vector length $t]
    if {[blas::vector length $f] != $n} {
	return -code error "size mismatch"
    }
    set xy [blas::vector create short -length [expr {2*$n}]]
    set x [blas::subvector create 1 2 $n from xy]
    set y [blas::subvector create 2 2 $n from xy]

    set xr $t
    set yr $f

    set w [.c cget -width]
    set h [.c cget -height]

    set min [blas::mathop min $xr]
    blas::mathsvop xr +scal [expr {-$min}]
    set max [blas::mathop max $xr]
    blas::mathsvop xr *scal [expr {($w-1)/$max}]

    set max [blas::mathop max $yr]
    blas::mathsvop yr +scal [expr {-$max}]
    set min [blas::mathop min $yr]
    blas::mathsvop yr *scal [expr {($h-1)/$min}]

    blas::mathsvop x <-double $xr
    blas::mathsvop y <-double $yr

    blas::mathsvop x ddiff
    blas::mathsvop y ddiff

    .c create hsplot 0 0 $w $h -xyblas xy -fill $color
}  


set eq {
     x'' = A (eta-x) - B x'

     v' = A (eta-x) - B v
     x' = v

}

plot $etaV red

set xV [blas::vector create double -length $N]
set vV [blas::vector create double -length $N]
set gV [blas::vector create double -length $N]


proc milneOscV3 {xName vName gName etaName it A B tEch} {

# 39.3035

    upvar $xName xV  ;# position
    upvar $vName vV   ;# vitesse
    upvar $gName gV   ;# accélération
    upvar $etaName etaV ;# force sur masse

# 98.8790

    
    if {$it < 5} {
	return -code error "it should be >= 5"
    }

    set i [expr {$it - 4}]

# 98.1697

    set xm3 [blas::vector get $xV $i]
    set vm3 [blas::vector get $vV $i]
    set gm3 [blas::vector get $gV $i]
    incr i
    set xm2 [blas::vector get $xV $i]
    set vm2 [blas::vector get $vV $i]
    set gm2 [blas::vector get $gV $i]

# 171.1909

    incr i
    set xm1 [blas::vector get $xV $i]
    set vm1 [blas::vector get $vV $i]
    set gm1 [blas::vector get $gV $i]
    incr i
    set xm0 [blas::vector get $xV $i]
    set vm0 [blas::vector get $vV $i]
    set gm0 [blas::vector get $gV $i]

    set eta1 [blas::vector get $etaV $it]

# 247.4329

# v' = A (eta-x) - B v
# x' = v

    # predicted v and x
    set v1p [expr {$vm3 + (4./3.)*$tEch*(2.0*$gm2 - $gm1 + 2.0*$gm0)}]
    set x1p [expr {$xm3 + (4./3.)*$tEch*(2.0*$vm2 - $vm1 + 2.0*$vm0)}]

    # eq. diff
    set g1p [expr {$A*($eta1 - $x1p) - $B*$v1p}]

    # 3 points fitted v and x
    set v1c [expr {$vm1 + (1/3.)*$tEch*($gm1 + 4.0*$gm0 + $g1p)}]
    # 3 points fitted x
    set x1c [expr {$xm1 + (1/3.)*$tEch*($vm1 + 4.0*$vm0 + $v1c)}]
     # eq. diff
    set g1c [expr {$A*($eta1 - $x1c) - $B*$v1c}]

# 332.2660
   
    blas::vector set xV $it $x1c 
    blas::vector set vV $it $v1c 
    blas::vector set gV $it $g1c 

    return [expr {abs($v1p-$v1c)/20./abs($v1c)}]

# 386.5939
}

# devient apparemment instable à t long
proc milneOscV1 {xName vName gName etaName it A B tEch} {
    upvar $xName xV   ;# position
    upvar $vName vV   ;# vitesse
    upvar $gName gV   ;# accélération
    upvar $etaName etaV ;# force sur masse
    
    if {$it < 5} {
	return -code error "it should be >= 5"
    }

    set i [expr {$it - 4}]
    set xm3 [blas::vector get $xV $i]
    set vm3 [blas::vector get $vV $i]
    set gm3 [blas::vector get $gV $i]
    incr i
    set xm2 [blas::vector get $xV $i]
    set vm2 [blas::vector get $vV $i]
    set gm2 [blas::vector get $gV $i]
    incr i
    set xm1 [blas::vector get $xV $i]
    set vm1 [blas::vector get $vV $i]
    set gm1 [blas::vector get $gV $i]
    incr i
    set xm0 [blas::vector get $xV $i]
    set vm0 [blas::vector get $vV $i]
    set gm0 [blas::vector get $gV $i]

    set eta1 [blas::vector get $etaV $it]

    # predicted v
    set v1p [expr {$vm3 + (4./3.)*$tEch*(2.0*$gm2 - $gm1 + 2.0*$gm0)}]
    # 3 points fitted x
    set x1p [expr {$xm1 + (1/3.)*$tEch*($vm1 + 4.0*$vm0 + $v1p)}]

    # eq. diff
    set g1p [expr {$A*($eta1 - $x1p) - $B*$v1p}]

    # 3 points fitted v
    set v1c [expr {$vm1 + (1/3.)*$tEch*($gm1 + 4.0*$gm0 + $g1p)}]
    # 3 points fitted x
    set x1c [expr {$xm1 + (1/3.)*$tEch*($vm1 + 4.0*$vm0 + $v1c)}]
     # eq. diff
    set g1c [expr {$A*($eta1 - $x1c) - $B*$v1c}]
   
    blas::vector set xV $it $x1c 
    blas::vector set vV $it $v1c 
    blas::vector set gV $it $g1c 

    return [expr {abs($v1p-$v1c)/20./abs($v1c)}]
}

# devient apparemment instable à t long
# Version avec liste 
proc milneOscV2 {xvgName eta1 A B tEch} {
    upvar $xvgName xvgList

    set i [expr {[llength $xvgList] - 12}]
    set xm3 [lindex $xvgList $i] ; incr i
    set vm3 [lindex $xvgList $i] ; incr i
    set gm3 [lindex $xvgList $i] ; incr i
    set xm2 [lindex $xvgList $i] ; incr i
    set vm2 [lindex $xvgList $i] ; incr i
    set gm2 [lindex $xvgList $i] ; incr i
    set xm1 [lindex $xvgList $i] ; incr i
    set vm1 [lindex $xvgList $i] ; incr i
    set gm1 [lindex $xvgList $i] ; incr i
    set xm0 [lindex $xvgList $i] ; incr i
    set vm0 [lindex $xvgList $i] ; incr i
    set gm0 [lindex $xvgList $i] ; incr i

    # predicted v
    set v1p [expr {$vm3 + (4./3.)*$tEch*(2.0*$gm2 - $gm1 + 2.0*$gm0)}]
    # 3 points fitted x
    set x1p [expr {$xm1 + (1/3.)*$tEch*($vm1 + 4.0*$vm0 + $v1p)}]

    # eq. diff
    set g1p [expr {$A*($eta1 - $x1p) - $B*$v1p}]

    # 3 points fitted v
    set v1c [expr {$vm1 + (1/3.)*$tEch*($gm1 + 4.0*$gm0 + $g1p)}]
    # 3 points fitted x
    set x1c [expr {$xm1 + (1/3.)*$tEch*($vm1 + 4.0*$vm0 + $v1c)}]
     # eq. diff
    set g1c [expr {$A*($eta1 - $x1c) - $B*$v1c}]
   
    lappend xvgList $x1c $v1c $g1c 

    return [expr {abs($v1p-$v1c)/20./abs($v1c)}]
}

proc ABMOsc {xName vName gName etaName it A B tEch} {

    upvar $xName xV   ;# position
    upvar $vName vV   ;# vitesse
    upvar $gName gV   ;# accélération
    upvar $etaName etaV ;# force sur masse

    if {$it < 5} {
	return -code error "it should be >= 5"
    }

    set i [expr {$it - 4}]

    set xm3 [blas::vector get $xV $i]
    set vm3 [blas::vector get $vV $i]
    set gm3 [blas::vector get $gV $i]
    incr i
    set xm2 [blas::vector get $xV $i]
    set vm2 [blas::vector get $vV $i]
    set gm2 [blas::vector get $gV $i]
    incr i
    set xm1 [blas::vector get $xV $i]
    set vm1 [blas::vector get $vV $i]
    set gm1 [blas::vector get $gV $i]
    incr i
    set xm0 [blas::vector get $xV $i]
    set vm0 [blas::vector get $vV $i]
    set gm0 [blas::vector get $gV $i]

    set eta1 [blas::vector get $etaV $it]

# v' = A (eta-x) - B v
# x' = v

    # predicted v and x
    set v1p [expr {$vm0 + (1./24.)*$tEch*(55.0*$gm0 - 59.0*$gm1 + 37.0*$gm2 - 9.0*$gm3)}]
    set x1p [expr {$xm3 + (1./24.)*$tEch*(55.0*$vm0 - 59.0*$vm1 + 37.0*$vm2 - 9.0*$vm3)}]

    # eq. diff
    set g1p [expr {$A*($eta1 - $x1p) - $B*$v1p}]

    # 3 points fitted v and x
    set v1c [expr {$vm0 + (1/24.)*$tEch*(9.0*$g1p + 19.0*$gm0 - 5.0*$gm1 + $gm2)}]
    # 3 points fitted x
    set x1c [expr {$xm0 + (1/24.)*$tEch*(9.0*$v1p + 19.0*$vm0 - 5.0*$vm1 + $vm2)}]
     # eq. diff
    set g1c [expr {$A*($eta1 - $x1c) - $B*$v1c}]

    blas::vector set xV $it $x1c 
    blas::vector set vV $it $v1c 
    blas::vector set gV $it $g1c 

    return [expr {abs($v1p-$v1c)/20./abs($v1c)}]

}


set Omega [expr {0.2*$omegaEta}]
set Q 76

set A [expr {$Omega*$Omega*(1.0 + 0.5/($Q*$Q))}]
set B [expr {$Omega/$Q}]


set debug {
  Où l'on voit (26/12/2001) que blas::vector get est anormalement long

    setenv FIDEV_EXPERIMENTAL /home/fab/C/fidev-unknown-Linux-2.2.16-3-cc-debug/lib
    xxgdb /prog/Tcl/tk8.3.2/unix-debug/wish &
    run
    source milneTest.0.1.tcl
    Ctrl/C
    break TclBlas_vectorCmd
    cont
    blas::vector get $etaV 1

  Manifestement, on duplique le vecteur, parce qu'il est partagé

Corrigé dans fidevObj/src/fidevObj.0.2.c

}

proc tV2.1.1 {} {
    global N etaV A B tEch
    set xvgList [list]
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    for {set it 5} {$it <= $N} {incr it} {
	set eta1 [blas::vector get $etaV $it]
	if {[milneOscV2 xvgList $eta1 $A $B $tEch] > 1.0} break
    }
    
    set xvgV [blas::vector create double $xvgList] ; set i
    plot [blas::vector create -copy [blas::subvector create 1 3 $N $xvgV]] black
}

proc tV2.1.2 {} {
    global N etaV
    set xvgList [list]
    set etaVbis $etaV
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    for {set it 5} {$it <= $N} {incr it} {
	set eta1 [blas::vector get $etaVbis $it]
#	if {[milneOscV2 xvgList $eta1 $A $B $tEch] > 1.0} break
    }
    
#    set xvgV [blas::vector create double $xvgList] ; set i
#    plot [blas::vector create -copy [blas::subvector create 1 3 $N $xvgV]] black
}

proc tV2.1.3 {} {
    global N etaV
    set xvgList [list]
    set etaVbis [blas::vector create -copy $etaV]
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    for {set it 5} {$it <= $N} {incr it} {
	set eta1 [blas::vector get $etaVbis $it]
#	if {[milneOscV2 xvgList $eta1 $A $B $tEch] > 1.0} break
    }
    
#    set xvgV [blas::vector create double $xvgList] ; set i
#    plot [blas::vector create -copy [blas::subvector create 1 3 $N $xvgV]] black
}


proc tV2.1.4 {etaV} {
    global N
    set xvgList [list]
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    for {set it 5} {$it <= 7} {incr it} {
	set eta1 [blas::vector get $etaV $it]
    }
}

proc tV2.2 {} {
    global N etaV
    set etaList [lrange $etaV 1 end]
    set xvgList [list]
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    foreach eta1 [lrange $etaList 4 end] {
#	if {[milneOscV2 xvgList $eta1 $A $B $tEch] > 1.0} break
    }
    
#    set xvgV [blas::vector create double $xvgList] ; set i
#    plot [blas::vector create -copy [blas::subvector create 1 3 $N $xvgV]] black
}

proc tV2.3 {} {
    global N etaV A B tEch
    set etaList [lrange $etaV 5 end]
    set xvgList [list]
    for {set i 0} {$i < 12} {incr i} {lappend xvgList [expr {0.0}]}
    foreach eta1 $etaList {
	if {[milneOscV2 xvgList $eta1 $A $B $tEch] > 1.0} break
    }
    
    set xvgV [blas::vector create double $xvgList] ; set i
    plot [blas::vector create -copy [blas::subvector create 1 3 $N $xvgV]] black
}

proc tV3 {} {
    global N xV vV gV etaV Omega Q tEch
    set A [expr {$Omega*$Omega*(1.0 + 0.5/($Q*$Q))}]
    set B [expr {$Omega/$Q}]
    for {set it 5} {$it <= $N} {incr it} {
	if {[milneOscV3 xV vV gV etaV $it $A $B $tEch] > 1.0} break
    }
    plot $xV black
}

proc tV1 {} {
    global N xV vV gV etaV A B tEch
    for {set it 5} {$it <= $N} {incr it} {
	if {[milneOscV1 xV vV gV etaV $it $A $B $tEch] > 1.0} break
    }
    plot $xV black
}

# Bien stable : Adams-Bashfort-Moulton

proc tABM {} {
    global N xV vV gV etaV Omega Q tEch
    set A [expr {$Omega*$Omega*(1.0 + 0.5/($Q*$Q))}]
    set B [expr {$Omega/$Q}]
    for {set it 5} {$it <= $N} {incr it} {
	if {[ABMOsc xV vV gV etaV $it $A $B $tEch] > 1.0} break
    }
    plot $xV black
}

set Omega [expr {(1.0+0.5/$Q)*$omegaEta}]
set Q 10

tABM


#     x'' = A (eta-x) - B x'
