#!/usr/local/bin/tclsh

package require fidev
package require blas

if {[string compare test [info procs test]] == 1} then {source /prog/Tcl/tcl/tests/defs}

########
# asum #
########

test blas1-asum.1 {} {
    set v [::blas::newVector float {1 2 3 4}]
    set r [::blas::asum $v]
} {10.0}

test blas1-asum.2 {} {
    set v [::blas::newVector double {1 2 3 4}]
    set r [::blas::asum $v]
} {10.0}

test blas1-asum.3 {} {
    set v [::blas::newVector complex {{1 1} {2 2} {3 3} {4 4}}]
    set r [::blas::asum $v]
} {20.0}

test blas1-asum.4 {} {
    set v [::blas::newVector doublecomplex {{1 1} {2 2} {3 3} {4 4}}]
    set r [::blas::asum $v]
} {20.0}

########
# axpy #
########

test blas1-axpy.1 {} {
    set v [::blas::newVector float {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set x10 [::blas::getAtIndex [list $v 1 3 3] 0]
    set x00 [::blas::getAtIndex [list $v 0 3 3] 0]
    set scale [expr {-$x10/$x00}]
    ::blas::axpy $scale [list $v 0 3 3] [list $v 1 3 3]
    set r [::blas::getVector $v]
} {5.0 0.0 1.0 4.0 1.0 1.5 3.0 2.0 2.0}

test blas1-axpy.2 {} {
    set v [::blas::newVector double {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set x10 [::blas::getAtIndex [list $v 1 3 3] 0]
    set x00 [::blas::getAtIndex [list $v 0 3 3] 0]
    set scale [expr {-$x10/$x00}]
    ::blas::axpy $scale [list $v 0 3 3] [list $v 1 3 3]
    set r [::blas::getVector $v]
} {5.0 0.0 1.0 4.0 1.0 1.5 3.0 2.0 2.0}

test blas1-axpy.3 {} {
    set v [::blas::newVector complex {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set x10 [::blas::getAtIndex [list $v 1 3 3] 0]
    set x00 [::blas::getAtIndex [list $v 0 3 3] 0]
    set scale -2.0
    ::blas::axpy $scale [list $v 0 3 3] [list $v 1 3 3]
    set r [::blas::getVector $v]
} {{5.0 0.0} {-7.5 0.0} {1.0 0.0} {4.0 0.0} {-5.0 0.0} {1.5 0.0} {3.0 0.0} {-2.5 0.0} {2.0 0.0}}

test blas1-axpy.3 {} {
    set v [::blas::newVector doublecomplex {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set x10 [::blas::getAtIndex [list $v 1 3 3] 0]
    set x00 [::blas::getAtIndex [list $v 0 3 3] 0]
    set scale -2.0
    ::blas::axpy $scale [list $v 0 3 3] [list $v 1 3 3]
    set r [::blas::getVector $v]
} {{5.0 0.0} {-7.5 0.0} {1.0 0.0} {4.0 0.0} {-5.0 0.0} {1.5 0.0} {3.0 0.0} {-2.5 0.0} {2.0 0.0}}

########
# copy #
########

test blas1-copy.1 {} {
    set v [::blas::newVector float {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set nv [::blas::newVector float -length 3]
    ::blas::copy $nv [list $v 0 3 3]
    set r [::blas::getVector $nv]
} {5.0 4.0 3.0}

test blas1-copy.2 {} {
    set v [::blas::newVector double {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set nv [::blas::newVector double -length 3]
    ::blas::copy $nv [list $v 0 3 3]
    set r [::blas::getVector $nv]
} {5.0 4.0 3.0}

test blas1-copy.3 {} {
    set v [::blas::newVector complex {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set nv [::blas::newVector complex -length 3]
    ::blas::copy $nv [list $v 0 3 3]
    set r [::blas::getVector $nv]
} {{5.0 0.0} {4.0 0.0} {3.0 0.0}}

test blas1-copy.4 {} {
    set v [::blas::newVector doublecomplex {5.0 2.5 1.0 4.0 3.0 1.5 3.0 3.5 2.0}]
    set nv [::blas::newVector doublecomplex -length 3]
    ::blas::copy $nv [list $v 0 3 3]
    set r [::blas::getVector $nv]
} {{5.0 0.0} {4.0 0.0} {3.0 0.0}}


#######
# dot #
#######

test blas1-dot.1 {} {
    set x [::blas::newVector float {1 2 3}]
    set y [::blas::newVector float {3 0 -1}]
    set r [::blas::dot $x $y]
} 0.0

test blas1-dot.2 {} {
    set x [::blas::newVector double {1 2 3}]
    set y [::blas::newVector double {3 0 -1}]
    set r [::blas::dot $x $y]
} 0.0

test blas1-dotu.1 {} {
    set x [::blas::newVector complex {1 2 3}]
    set y [::blas::newVector complex {{0 4} {0 5} {0 6}}]
    set r [::blas::dotu $x $y]
} {0.0 32.0}

test blas1-dotu.2 {} {
    set x [::blas::newVector doublecomplex {{0 4} {0 5} {0 6}}]
    set y [::blas::newVector doublecomplex {1 2 3}]
    set r [::blas::dotu $x $y]
} {0.0 32.0}

test blas1-dotc.1 {} {
    set x [::blas::newVector complex {1 2 3}]
    set y [::blas::newVector complex {{0 4} {0 5} {0 6}}]
    set r [::blas::dotc $x $y]
} {0.0 32.0}


test blas1-dotc.2 {} {
    set x [::blas::newVector doublecomplex {{0 4} {0 5} {0 6}}]
    set y [::blas::newVector doublecomplex {1 2 3}]
    set r [::blas::dotc $x $y]
} {0.0 -32.0}

#######
# rot #
#######

test blas1-rotg-rot.1 {} {
    set x [::blas::newVector float {1 2 3 4 5}]
    set y [::blas::newVector float {2 4 8 16 32}]
# DANGER : ne pas appeler rotg sur x ou y
    set ab [::blas::newVector float [list \
               [::blas::getAtIndex $x 4]\
               [::blas::getAtIndex $y 4]]]
    set cs [::blas::rotg $ab 0 $ab 1]
    foreach {c s} $cs {}
    ::blas::rot $x $y $c $s
    set r [list]
    foreach xe [::blas::getVector $x] ye [::blas::getVector $y] {
        lappend r [list [format %.4f $xe] [format %.4f $ye]]
    }
    set r
} {{2.1304 -0.6793} {4.2608 -1.3585} {8.3672 -1.7290} {16.4257 -1.4820} {32.3883 0.0000}}


test blas1-rotg-rot.2 {} {
    set x [::blas::newVector double {1 2 3 4 5}]
    set y [::blas::newVector double {2 4 8 16 32}]
# DANGER : ne pas appeler rotg sur x ou y
    set ab [::blas::newVector double [list \
               [::blas::getAtIndex $x 4]\
               [::blas::getAtIndex $y 4]]]
    set cs [::blas::rotg $ab 0 $ab 1]
    foreach {c s} $cs {}
    ::blas::rot $x $y $c $s
    set r [list]
    foreach xe [::blas::getVector $x] ye [::blas::getVector $y] {
        lappend r [list [format %.4f $xe] [format %.4f $ye]]
    }
    set r
} {{2.1304 -0.6793} {4.2608 -1.3585} {8.3672 -1.7290} {16.4257 -1.4820} {32.3883 0.0000}}

puts "all OK"

puts "zblat1 test"

set CA {0.4 -0.7}
set INCXS {1 2 -2 -1}
set INCYS {1 -2 1 -2}
set LENS {1 1 2 4 1 1 3 7}
set NS {0 1 2 4}
set CX1 [blas::newVector doublecomplex {{0.7 -0.8} {-0.4 -0.7}\
	{-0.1 -0.9}  {0.2 -0.8}\
	{-0.9 -0.4}  {0.1 0.4}  {-0.6 0.6}}]
set CY1 [blas::newVector doublecomplex {\
	{0.6 -0.6}  {-0.9 0.5}\
	{0.7 -0.6}  {0.1 -0.5}  {-0.1 -0.2}\
	{-0.5 -0.3}  {0.8 -0.7}}]
# CT8{I J 1} I=1 7 J=1 4
set CT8 [blas::newVector doublecomplex -length [expr {28*4}]]
::blas::setVector [list $CT8 0 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.32 -1.41}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.32 -1.41}\
	{-1.55 0.5}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.32 -1.41}  {-1.55 0.5}\
	{0.03 -0.89}  {-0.38 -0.96}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}}
::blas::setVector [list $CT8 28 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.32 -1.41}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {-0.07 -0.89}\
	{-0.9 0.5}  {0.42 -1.41}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.78 0.06}  {-0.9 0.5}\
	{0.06 -0.13}  {0.1 -0.5}\
	{-0.77 -0.49}  {-0.5 -0.3}\
	{0.52 -1.51}}
::blas::setVector [list $CT8 [expr 2*28] 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.32 -1.41}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {-0.07 -0.89}\
	{-1.18 -0.31}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.78 0.06}  {-1.54 0.97}\
	{0.03 -0.89}  {-0.18 -1.31}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}}
::blas::setVector [list $CT8 [expr 28*3] 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.32 -1.41}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.32 -1.41}  {-0.9 0.5}\
	{0.05 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.32 -1.41}\
	{-0.9 0.5}  {0.05 -0.6}  {0.1 -0.5}\
	{-0.77 -0.49}  {-0.5 -0.3}\
	{0.32 -1.16}}
set CT7 [blas::newVector doublecomplex {{0.0 0.0}  {-0.06 -0.90}\
	{0.65 -0.47}  {-0.34 -1.22}\
	{0.0 0.0}  {-0.06 -0.90}\
	{-0.59 -1.46}  {-1.04 -0.04}\
	{0.0 0.0}  {-0.06 -0.90}\
	{-0.83 0.59}  {0.07 -0.37}\
	{0.0 0.0}  {-0.06 -0.90}\
	{-0.76 -1.15}  {-1.33 -1.82}}]
set CT6 [blas::newVector doublecomplex {{0.0 0.0}  {0.90 0.06}\
	{0.91 -0.77}  {1.80 -0.10}\
	{0.0 0.0}  {0.90 0.06}  {1.45 0.74}\
	{0.20 0.90}  {0.0 0.0}  {0.90 0.06}\
	{-0.55 0.23}  {0.83 -0.39}\
	{0.0 0.0}  {0.90 0.06}  {1.04 0.79}\
	{1.95 1.22}}]
set CT10X [::blas::newVector doublecomplex -length [expr 28*4]]
::blas::setVector [list $CT10X 0 1 28] {{0.7 -0.8}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.6 -0.6}  {-0.9 0.5}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.6 -0.6}\
	{-0.9 0.5}  {0.7 -0.6}  {0.1 -0.5}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}}
::blas::setVector [list $CT10X 28 1 28] {{0.7 -0.8}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.7 -0.6}  {-0.4 -0.7}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.8 -0.7}\
	{-0.4 -0.7}  {-0.1 -0.2}\
	{0.2 -0.8}  {0.7 -0.6}  {0.1 0.4}\
	{0.6 -0.6}}
::blas::setVector [list $CT10X [expr 2*28] 1 28] {{0.7 -0.8}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {-0.9 0.5}  {-0.4 -0.7}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.1 -0.5}\
	{-0.4 -0.7}  {0.7 -0.6}  {0.2 -0.8}\
	{-0.9 0.5}  {0.1 0.4}  {0.6 -0.6}}
::blas::setVector [list $CT10X [expr 3*28] 1 28] {{0.7 -0.8}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.6 -0.6}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.6 -0.6}  {0.7 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.6 -0.6}\
	{0.7 -0.6}  {-0.1 -0.2}  {0.8 -0.7}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}}
set CT10Y [::blas::newVector doublecomplex -length [expr 28*4]]
::blas::setVector [list $CT10Y 0 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.7 -0.8}  {-0.4 -0.7}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.7 -0.8}\
	{-0.4 -0.7}  {-0.1 -0.9}\
	{0.2 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}}
::blas::setVector [list $CT10Y 28 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {-0.1 -0.9}  {-0.9 0.5}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {-0.6 0.6}\
	{-0.9 0.5}  {-0.9 -0.4}  {0.1 -0.5}\
	{-0.1 -0.9}  {-0.5 -0.3}\
	{0.7 -0.8}}
::blas::setVector [list $CT10Y [expr 2*28] 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {-0.1 -0.9}  {0.7 -0.8}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {-0.6 0.6}\
	{-0.9 -0.4}  {-0.1 -0.9}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}}
::blas::setVector [list $CT10Y [expr 3*28] 1 28] {{0.6 -0.6}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.7 -0.8}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.7 -0.8}  {-0.9 0.5}\
	{-0.4 -0.7}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.7 -0.8}\
	{-0.9 0.5}  {-0.4 -0.7}  {0.1 -0.5}\
	{-0.1 -0.9}  {-0.5 -0.3}\
	{0.2 -0.8}}
set CSIZE1 [::blas::newVector doublecomplex {{0.0 0.0}  {0.9 0.9}\
	{1.63 1.73}  {2.90 2.78}}]
set CSIZE3 [::blas::newVector doublecomplex {{0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	{0.0 0.0}  {0.0 0.0}  {1.17 1.17}\
	{1.17 1.17}  {1.17 1.17}\
	{1.17 1.17}  {1.17 1.17}\
	{1.17 1.17}  {1.17 1.17}}]
set CSIZE2 [::blas::newVector doublecomplex  {{0.0 0.0}  {0.0 0.0}\
	 {0.0 0.0}  {0.0 0.0}  {0.0 0.0}\
	 {0.0 0.0}  {0.0 0.0}  {1.54 1.54}\
	 {1.54 1.54}  {1.54 1.54}\
	 {1.54 1.54}  {1.54 1.54}\
	 {1.54 1.54}  {1.54 1.54}}]

proc fmdeclare {listName dims} {
    global FDIMS
    set dblist [list]
    set dimbloc 1
    foreach dim $dims {
	lappend dblist $dimbloc
	set dimbloc [expr {$dimbloc*$dim}]
    }
    upvar $listName list
    if {[llength $list] != $dimbloc} {
	error "erreur de dimension"
    }
    set FDIMS($listName) $dblist
}

proc findex {list args} {
    if {[llength $args] == 1} {
	set index $args
	incr index -1
    } elseif {[llength $args] >= 2} {
	set dims [lindex $args 0]
	set indexes [lrange $args 1 end]
	set n [llength $dims]
	if {[llength $indexes] != $n} {
	    error "syntaxe de findex incorrecte"
	}
	set dimbloc 1
	set index 0
	foreach dim $dims i $indexes {
	    set index [expr {$index + $dimbloc*($i-1)}]
	    set dimbloc [expr {$dimbloc*$dim}]
	}
    } else {
	error "syntaxe de findex incorrecte"
    }
    return [lindex $list $index]
}

proc blas_findex {blasVector args} {
    if {[llength $args] == 1} {
	set index $args
	incr index -1
    } elseif {[llength $args] >= 2} {
	set dims [lindex $args 0]
	set indexes [lrange $args 1 end]
	set n [llength $dims]
	if {[llength $indexes] != $n} {
	    error "syntaxe de findex incorrecte"
	}
	set dimbloc 1
	set index 0
	foreach dim $dims i $indexes {
	    set index [expr {$index + $dimbloc*($i-1)}]
	    set dimbloc [expr {$dimbloc*$dim}]
	}
    } else {
	error "syntaxe de findex incorrecte"
    }
    puts [list ::blas::getAtIndex $blasVector $index -> [::blas::getAtIndex $blasVector $index]]
    return [::blas::getAtIndex $blasVector $index]
}


proc sdiff {sa sb} {
    return [expr {$sa - $sb}]
}

proc stest {len scomp strue ssize sfac} {
    foreach c $scomp t $strue s $ssize {
	set sd [expr {$c - $t}]
	puts [list $s $sfac $sd -> [expr {abs($s)+abs($sfac*$sd)}] et [expr {abs($s)}]]
	if {[sdiff [expr {abs($s)+abs($sfac*$sd)}] [expr {abs($s)}]] != 0.0} {
	    error "erreur de calcul"
	}
    } 
}

proc ctest {LEN CCOMP CTRUE CSIZE SFAC} {
    puts [list CCOMP = $CCOMP]
    puts [list CTRUE = $CTRUE]
    puts [list CSIZE = $CSIZE]
    set SCOMP [list]
    set STRUE [list]
    set SSIZE [list]
    foreach c $CCOMP t $CTRUE s $CSIZE {
	foreach v $c {lappend SCOMP $v}
	foreach v $t {lappend STRUE $v}
 	foreach v $s {lappend SSIZE $v}
    }
    stest [expr {2*$LEN}] $SCOMP $STRUE $SSIZE $SFAC
}

set  SFAC 9.765625E-4
for {set IC 1} {$IC <= 10} {incr IC} {
    set ICASE $IC
    for {set KI 1} {$KI <= 4} {incr KI} {
	set INCX [findex $INCXS $KI]
	set INCY [findex $INCYS $KI]
	set MX [expr {abs($INCX)}]
	set MY [expr {abs($INCY)}]
	for {set KN 1} {$KN <= 4} {incr KN} {
	    set N [findex $NS $KN]
	    if {$KN < 2} {
		set KSIZE $KN
	    } else {
		set KSIZE 2
	    }
	    set LENX [findex $LENS {4 2} $KN $MX]
	    set LENY [findex $LENS {4 2} $KN $MY]
	    set CX $CX1
	    set CY $CY1
	    if {$ICASE == 3} {
		::blas::axpy $CA $CX $CY
		puts [list CSIZE2 = $CSIZE2]
		ctest $LENY [::blas::getVector $CY] [blas_findex $CT8 {7 4 4} 1 $KN $KI] [blas_findex $CSIZE2 {7 2} 1 $KSIZE] $SFAC
	    }
	}
    }
}
	
