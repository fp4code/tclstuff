#!/bin/sh

# 23 juillet 2001 (FP)
# marche bien pour les tests check1 et check2
# en cours de modification pour check0, après introduction de blas::tensor ...

#\
exec tclsh "$0" ${1+"$@"}

if {[lsearch [namespace children] ::tcltest] == -1} {
    package require tcltest
    namespace import -force ::tcltest::*
}

package require fidev
package require blasObj 0.2
package require dblas1 0.2

namespace eval blastest {}

proc blastest::tensor {type name sizes data} {
    uplevel [concat set [list vector_$name] \[blas::vector create $type [list $data]\]]
    uplevel [concat set [list tensor_$name] \[blas::tensor create 1 [list $sizes] from [list vector_$name]\]]
    set vl [uplevel [concat blas::vector length \$\{vector_$name\}]]
    set ia 0
    set aa "command"
    set ar ""
    set size 1
    set body "
    upvar \"vector_$name\" vector
    upvar \"tensor_$name\" tensor
    set i  \[blas::tensor getindex \$tensor \[list"
    foreach s $sizes {
        incr ia
        append aa " i$ia"
        append ar " \$i$ia"
        set size [expr {$s * $size}]
    }
    append aa " args"
    append body $ar\]\]\n
    append body "
    switch \$command \{
        get \{return \[blas::vector get \$vector \$i\]\}
        set \{blas::vector set vector \$i \$args\}
        default \{return -code error \"syntax: $name \\\[get | set\\\]...\"\}
    \}"

    if {$size != $vl} {
        return -code error "size mismatch [join $sizes x] vs. $vl"
    }
    namespace eval :: [list proc $name $aa $body]
}

proc blastest::vextract {len subvector} {
    set ret [list]
    set vector [blas::subvector getvector $subvector]
    for {set i 1} {$i <= $len} {incr i} {
        lappend ret [blas::vector get $vector $i]
    }
    return $ret
}

proc blastest::textract {len name args} {
    set ret [list]
    set i1 [lindex $args 0]
    for {set i 0} {$i < $len} {incr i} {
        lappend ret [eval $name [expr {$i1+$i}] [lrange $args 1 end]]
    }
    return $ret
}

###################################
# tests from slatec/test/check0.f #
###################################

blastest::tensor double da1 {8} {.3  .4 -.3 -.4 -.3  0.  0.  1.}
blastest::tensor double db1 {8} {.4  .3  .4  .3 -.4  0.  1.  0.}
blastest::tensor double dc1 {8} {.6  .8 -.6  .8  .6  1.  0.  1.}
blastest::tensor double ds1 {8} {.8  .6  .8 -.6  .8  0.  1.  0.}
blastest::tensor double dab {4 9} { \
        .1 .3 1.2 .2 \
        .7  .2  .6  4.2 \
        0. 0. 0. 0. \
        4.  -1.  2.  4. \
        6.e-10 2.e-2 1.e5 10. \
        4.e10 2.e-2 1.e5 10. \
        2.e-10 4.e-2 1.e5 10. \
        2.e10 4.e-2 1.e-5 10. \
        4.  -2.  8.  4.}
blastest::tensor double dtrue {9 9} { \
        0 0.  1.3  .2  0. 0. 0.  .5  0. \
        0. 0.  4.5  4.2  1.  .5  0. 0. 0. \
        0. 0. 0. 0.  -2.  0. 0. 0. 0. \
        0. 0. 0.  4.  -1.  0. 0. 0. 0. \
        0.  15.e-3 0.  10.  -1.  0. -1.e-4 0.  1. \
        0. 0.  6144.e-5 10.  -1.  4096.  -1.e6 0.  1. \
        0. 0. 15. 10. -1.  5.e-5 0. 1. 0. \
        0. 0.  15.  10.  -1.   5.e5 -4096. 1.  4096.e-6 \
        0. 0.  7.  4.  0. 0.  -.5  -.25  0.}

dtrue {1 1} get
dtrue {1 1} set [expr {12.D0 / 130.D0}]

      DTRUE(1,1) = 12.D0 / 130.D0
      DTRUE(2,1) = 36.D0 / 130.D0
      DTRUE(7,1) = -1.D0 / 6.D0
      DTRUE(1,2) = 14.D0 / 75.D0
      DTRUE(2,2) = 49.D0 / 75.D0
      DTRUE(9,2) = 1.D0 / 7.D0
      DTRUE(1,5) = 45.D-11 * (D12 * D12)
      DTRUE(3,5) = 4.D5 / (3.D0 * D12)
      DTRUE(6,5) = 1.D0 / D12
      DTRUE(8,5) = 1.D4 / (3.D0 * D12)
      DTRUE(1,6) = 4.D10 / (1.5D0 * D12 * D12)
      DTRUE(2,6) = 2.D-2 / 1.5D0
      DTRUE(8,6) = 5.D-7 * D12
      DTRUE(1,7) = 4.D0 / 150.D0
      DTRUE(2,7) = (2.D-10 / 1.5D0) * (D12 * D12)
      DTRUE(7,7) = -DTRUE(6,5)
      DTRUE(9,7) = 1.D4 / D12
      DTRUE(1,8) = DTRUE(1,7)
      DTRUE(2,8) = 2.D10 / (1.5D0 * D12 * D12)
      DTRUE(1,9) = 32.D0 / 7.D0
      DTRUE(2,9) = -16.D0 / 7.D0


foreach k {1 2 3 4 5 6 7 8} {
    test dblas1 "blas::drotg $k" {
        set da [da1 $k]
        set db [db1 $k]
        blas::drotg $da $db
    } [list [dc1 $k] [ds1 $k]]

    test dblas1 "blas::drotmg $k" {
        set params [blas::vector create double -length 5]
        concat [blas::drotmg [dab 1 $k] [dab 2 $k] [dab 3 $k] [dab 4 $k] params] [blastest::vextract 5 $params]
    } [blastest::textract 9 dtrue 1 $k]
}

foreach k {1 2 3 4 5 6 7 8 9} {

}

###################################
# tests from slatec/test/check1.f #
###################################

set da 0.3

blastest::tensor dv double {8 5 2} {.1e0 2.e0 2.e0 2.e0 2.e0 2.e0 2.e0 2.e0 \
            .3e0 3.e0 3.e0 3.e0 3.e0 3.e0 3.e0 3.e0 \
            .3e0 -.4e0 4.e0 4.e0 4.e0 4.e0 4.e0 4.e0 \
            .2e0 -.6e0 .3e0 5.e0 5.e0 5.e0 5.e0 5.e0 \
            .1e0 -.3e0 .5e0 -.1e0 6.e0 6.e0 6.e0 6.e0 \
            .1e0 8.e0 8.e0 8.e0 8.e0 8.e0 8.e0 8.e0 \
            .3e0 9.e0 9.e0 9.e0 9.e0 9.e0 9.e0 9.e0 \
            .3e0 2.e0 -.4e0 2.e0 2.e0 2.e0 2.e0 2.e0 \
            .2e0 3.e0 -.6e0 5.e0 .3e0 2.e0 2.e0 2.e0 \
            .1e0 4.e0 -.3e0 6.e0 -.5e0 7.e0 -.1e0  3.e0}

blastest::tensor dtrue1 double 5 {0.0 0.3 0.5 0.7 0.6}
blastest::tensor dtrue3 double 5 {0.0 0.3 0.7 1.1 1.0}
blastest::tensor dtrue5 double {8 5 2} {.10e0 2.e0 2.e0 2.e0 2.e0 2.e0 2.e0 2.e0 \
        .09e0 3.e0 3.e0 3.e0 3.e0 3.e0 3.e0 3.e0 \
        .09e0 -.12e0 4.e0 4.e0 4.e0 4.e0 4.e0 4.e0 \
        .06e0 -.18e0 .09e0 5.e0 5.e0 5.e0 5.e0 5.e0 \
        .03e0 -.09e0 .15e0 -.03e0 6.e0 6.e0 6.e0 6.e0 \
        .10e0 8.e0 8.e0 8.e0 8.e0 8.e0 8.e0 8.e0 \
        .09e0 9.e0 9.e0 9.e0 9.e0 9.e0 9.e0 9.e0 \
        .09e0 2.e0 -.12e0 2.e0 2.e0 2.e0 2.e0 2.e0 \
        .06e0 3.e0 -.18e0 5.e0 .09e0 2.e0 2.e0 2.e0 \
        .03e0 4.e0  -.09e0 6.e0  -.15e0 7.e0  -.03e0 3.e0}

blastest::tensor itrue2 long 5 {0 1 2 2 3}
blastest::tensor itrue3 long 5 {0 1 2 2 2}

foreach incx {1 2} {
    foreach np1 {1 2 3 4 5} {
        set n [expr {$np1 - 1}]
        if {$n > 1} {
            set len [expr {2*$n}]
        } else {
            set len 2
        }
        set dxo [list]
        for {set i 1} {$i <= $len} {incr i} {
            lappend dxo [dv $i $np1 $incx]
        }
        set dxo [blas::subvector create 1 $incx $n [blas::vector create double $dxo]]

        ###########

        set dx $dxo
        test dblas1 "blas::dnrm2 $i $np1 $incx" {
            blas::dnrm2 $dx
        } [dtrue1 $np1]

        set dx $dxo
        test dblas1 "blas::dasum $i $np1 $incx" {
            blas::dasum $dx
        } [dtrue3 $np1]
          
        ###########

        set dx $dxo
        test dblas1 "blas::dscal $i $np1 $incx" {
            blas::dscal $da dx
            blastest::vextract $len $dx
        } [blastest::textract $len dtrue5 1 $np1 $incx]

        ###########

        set dx $dxo
        test dblas1 "blas::idamax $i $np1 $incx" {
            blas::idamax $dx
        } [itrue2 $np1]

        ###########
    }
}


###################################
# tests from slatec/test/check2.f #
###################################

set da 0.3
set dc 0.8
set ds 0.6
blastest::tensor incxs long 4 {1  2 -2 -1}
blastest::tensor incys long 4 {1 -2  1 -2}
blastest::tensor lens long {4 2} {1 1 2 4 1 1 3 7}
blastest::tensor ns long 4 {0 1 2 4}


blastest::tensor dx1 double 7 {.6  .1 -.5  .8  .9 -.3 -.4}
blastest::tensor dy1 double 7 {.5 -.9  .3  .7 -.6  .2  .8}
blastest::tensor dx2 double 7 {1. .01  .02 1. .06  2.  1.}
blastest::tensor dy2 double 7 {1. .04 -.03 -1. .05 3. -1.}
blastest::tensor dpar double {5 4} { \
        -2.   0. 0. 0. 0. \
        -1.   2.  -3.  -4.   5. \
        0.   0.   2.  -3.   0. \
        1.   5.   2.   0.  -4.}
blastest::tensor dt7  double {4 4} { \
        0. .30 .21 .62 \
        0. .30 -.07 .85 \
        0. .30 -.79 -.74 \
        0. .30 .33 1.27}
blastest::tensor dt8 double {7 4 4} { \
        .5 0. 0. 0. 0. 0. 0. \
        .68  0. 0. 0. 0. 0. 0. \
        .68 -.87 0. 0. 0. 0. 0. \
        .68 -.87 .15 .94 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .68 0. 0. 0. 0. 0. 0. \
        .35 -.9 .48 0. 0. 0. 0. \
        .38 -.9 .57 .7 -.75 .2 .98 \
        .5 0. 0. 0. 0. 0. 0. \
        .68 0. 0. 0. 0. 0. 0. \
        .35 -.72 0. 0. 0. 0. 0. \
        .38 -.63 .15 .88 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .68 0. 0. 0. 0. 0. 0. \
        .68 -.9 .33 0. 0. 0. 0. \
        .68 -.9 .33 .7 -.75 .2 1.04}
blastest::tensor dt9x double {7 4 4} { \
        .6 0. 0. 0. 0. 0. 0.  \
        .78 0. 0. 0. 0. 0. 0. \
        .78 -.46 0. 0. 0. 0. 0. \
        .78 -.46 -.22 1.06 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .78 0. 0. 0. 0. 0. 0. \
        .66 .1 -.1 0. 0. 0. 0. \
        .96 .1 -.76 .8 .90 -.3 -.02 \
        .6 0. 0. 0. 0. 0. 0. \
        .78 0. 0. 0. 0. 0. 0. \
        -.06 .1 -.1 0. 0. 0. 0. \
        .90 .1 -.22 .8 .18 -.3 -.02 \
        .6 0. 0. 0. 0. 0. 0. \
        .78 0. 0. 0. 0. 0. 0. \
        .78 .26 0. 0. 0. 0. 0. \
        .78 .26 -.76 1.12 0. 0. 0.}
blastest::tensor dt9y double {7 4 4} { \
        .5 0. 0. 0. 0. 0. 0. \
        .04 0. 0. 0. 0. 0. 0. \
        .04 -.78 0. 0. 0. 0. 0. \
        .04 -.78 .54 .08 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .04 0. 0. 0. 0. 0. 0. \
        .7 -.9 -.12 0. 0. 0. 0. \
        .64 -.9 -.30 .7 -.18 .2 .28 \
        .5 0. 0. 0. 0. 0. 0. \
        .04 0. 0. 0. 0. 0. 0. \
        .7 -1.08 0. 0. 0. 0. 0. \
        .64 -1.26 .54 .20 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .04 0. 0. 0. 0. 0. 0. \
        .04 -.9 .18 0. 0. 0. 0. \
        .04 -.9 .18 .7 -.18 .2 .16}
blastest::tensor dt10x double {7 4 4} { \
        .6 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 -.9 0. 0. 0. 0. 0. \
        .5 -.9 .3 .7 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .3 .1  .5 0. 0. 0. 0. \
        .8 .1  -.6 .8  .3 -.3 .5 \
        .6 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        -.9 .1 .5 0. 0. 0. 0. \
        .7 .1 .3 .8 -.9 -.3 .5 \
        .6 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 .3 0. 0. 0. 0. 0. \
        .5 .3 -.6 .8 0. 0. 0.}
blastest::tensor dt10y double {7 4 4} { \
        .5 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 .1 0. 0. 0. 0. 0. \
        .6 .1 -.5 .8 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.5 -.9 .6 0. 0. 0. 0. \
        -.4 -.9 .9 .7 -.5 .2 .6 \
        .5 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.5 .6 0. 0. 0. 0. 0. \
        -.4 .9 -.5 .6 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 -.9 .1 0. 0. 0. 0. \
        .6 -.9 .1 .7 -.5 .2 .8}
set dt19xa {.6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.8 0. 0. 0. 0. 0. 0. \
        -.9 0. 0. 0. 0. 0. 0. \
        3.5 0. 0. 0. 0. 0. 0. \
        .6 .1 0. 0. 0. 0. 0. \
        -.8 3.8 0. 0. 0. 0. 0. \
        -.9 2.8 0. 0. 0. 0. 0. \
        3.5 -.4 0. 0. 0. 0. 0. \
        .6 .1 -.5 .8 0. 0. 0. \
        -.8 3.8 -2.2 -1.2 0. 0. 0. \
        -.9 2.8 -1.4 -1.3 0. 0. 0. \
        3.5 -.4 -2.2 4.7 0. 0. 0.}
set dt19xb { \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.8 0. 0. 0. 0. 0. 0. \
        -.9 0. 0. 0. 0. 0. 0. \
        3.5 0. 0. 0. 0. 0. 0. \
        .6 .1 -.5 0. 0. 0. 0. \
        0. .1 -3.0 0. 0. 0. 0. \
        -.3 .1 -2.0 0. 0. 0. 0. \
        3.3 .1 -2.0 0. 0. 0. 0. \
        .6 .1 -.5 .8 .9 -.3 -.4 \
        -2.0 .1 1.4 .8 .6 -.3 -2.8 \
        -1.8 .1 1.3 .8 0. -.3 -1.9 \
        3.8 .1 -3.1 .8 4.8 -.3 -1.5}
set dt19xc { \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.8 0. 0. 0. 0. 0. 0. \
        -.9 0. 0. 0. 0. 0. 0. \
        3.5 0. 0. 0. 0. 0. 0. \
        .6 .1 -.5 0. 0. 0. 0. \
        4.8 .1 -3.0 0. 0. 0. 0. \
        3.3 .1 -2.0 0. 0. 0. 0. \
        2.1 .1 -2.0 0. 0. 0. 0. \
        .6 .1 -.5 .8 .9 -.3 -.4 \
        -1.6 .1 -2.2 .8 5.4 -.3 -2.8 \
        -1.5 .1 -1.4 .8 3.6 -.3 -1.9 \
        3.7 .1 -2.2 .8 3.6 -.3 -1.5}
set dt19xd { \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        .6 0. 0. 0. 0. 0. 0. \
        -.8 0. 0. 0. 0. 0. 0. \
        -.9 0. 0. 0. 0. 0. 0. \
        3.5 0. 0. 0. 0. 0. 0. \
        .6 .1 0. 0. 0. 0. 0. \
        -.8 -1.0 0. 0. 0. 0. 0. \
        -.9 -.8 0. 0. 0. 0. 0. \
        3.5 .8 0. 0. 0. 0. 0. \
        .6 .1 -.5 .8 0. 0. 0. \
        -.8 -1.0 1.4 -1.6 0. 0. 0. \
        -.9 -.8 1.3 -1.6 0. 0. 0. \
        3.5 .8 -3.1 4.8 0. 0. 0.}
set dt19ya { \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .7 0. 0. 0. 0. 0. 0. \
        1.7 0. 0. 0. 0. 0. 0. \
        -2.6 0. 0. 0. 0. 0. 0. \
        .5 -.9 0. 0. 0. 0. 0. \
        .7 -4.8 0. 0. 0. 0. 0. \
        1.7 -.7 0. 0. 0. 0. 0. \
        -2.6 3.5 0. 0. 0. 0. 0. \
        .5 -.9 .3 .7 0. 0. 0. \
        .7 -4.8 3.0 1.1 0. 0. 0. \
        1.7 -.7 -.7 2.3 0. 0. 0. \
        -2.6 3.5 -.7 -3.6 0. 0. 0.}
set dt19yb {\
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .7 0. 0. 0. 0. 0. 0. \
        1.7 0. 0. 0. 0. 0. 0. \
        -2.6 0. 0. 0. 0. 0. 0. \
        .5 -.9 .3 0. 0. 0. 0. \
        4.0 -.9 -.3 0. 0. 0. 0. \
        -.5 -.9 1.5 0. 0. 0. 0. \
        -1.5 -.9 -1.8 0. 0. 0. 0. \
        .5 -.9 .3 .7 -.6 .2 .8 \
        3.7 -.9 -1.2 .7 -1.5 .2 2.2 \
        -.3 -.9 2.1 .7 -1.6 .2 2.0 \
        -1.6 -.9 -2.1 .7 2.9 .2 -3.8}
set dt19yc { \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .7 0. 0. 0. 0. 0. 0. \
        1.7 0. 0. 0. 0. 0. 0. \
        -2.6 0. 0. 0. 0. 0. 0. \
        .5 -.9 0. 0. 0. 0. 0. \
        4.0 -6.3 0. 0. 0. 0. 0. \
        -.5 .3 0. 0. 0. 0. 0. \
        -1.5 3.0 0. 0. 0. 0. 0. \
        .5 -.9 .3 .7 0. 0. 0. \
        3.7 -7.2 3.0 1.7 0. 0. 0. \
        -.3 .9 -.7 1.9 0. 0. 0. \
        -1.6 2.7 -.7 -3.4 0. 0. 0.}
set dt19yd {\
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .5 0. 0. 0. 0. 0. 0. \
        .7 0. 0. 0. 0. 0. 0. \
        1.7 0. 0. 0. 0. 0. 0. \
        -2.6 0. 0. 0. 0. 0. 0. \
        .5 -.9 .3 0. 0. 0. 0. \
        .7 -.9 1.2 0. 0. 0. 0. \
        1.7 -.9 .5 0. 0. 0. 0. \
        -2.6 -.9 -1.3 0. 0. 0. 0. \
        .5 -.9 .3 .7 -.6 .2 .8 \
        .7 -.9 1.2 .7 -1.5 .2 1.6 \
        1.7 -.9 .5 .7 -1.6 .2 2.4 \
        -2.6 -.9 -1.3 .7 2.9 .2 -4.0}
blastest::tensor dt19x double {7 4 16} [concat $dt19xa $dt19xb $dt19xc $dt19xd]
blastest::tensor dt19y double {7 4 16} [concat $dt19ya $dt19yb $dt19yc $dt19yd]

foreach ki {1 2 3 4} {
    set incx [incxs $ki]
    set incy [incys $ki]
    set mx [expr {abs($incx)}]
    set my [expr {abs($incy)}]

    foreach kn {1 2 3 4} {
        set n [ns $kn]
        if {$kn > 2} {
            set ksize $kn
        } else {
            set ksize 2
        }
        set lenx [lens $kn $mx]
        set leny [lens $kn $my]

        set dx [blas::subvector create 1 $incx $n $dx1]
        set dy [blas::subvector create 1 $incy $n $dy1]
        test dblas1 "blas::ddot $ki $kn" {
            blas::ddot $dx $dy
        } [dt7 $kn $ki]

        set dx [blas::subvector create 1 $incx $n $dx1]
        set dy [blas::subvector create 1 $incy $n $dy1]
        test dblas1 "blas::daxpy $ki $kn" {
            blas::daxpy $da $dx dy
            blastest::vextract $leny $dy
        } [blastest::textract $leny dt8 1 $kn $ki]

        set dx [blas::subvector create 1 $incx $n $dx1]
        set dy [blas::subvector create 1 $incy $n $dy1]
        test dblas1 "blas::drot $ki $kn" {
            blas::drot dx dy $dc $ds
            concat [blastest::vextract $lenx $dx] [blastest::vextract $leny $dy]
        } [concat [blastest::textract $lenx dt9x 1 $kn $ki] [blastest::textract $leny dt9y 1 $kn $ki]]

        set kni [expr {$kn + 4*($ki-1)}]
        foreach kpar {1 2 3 4} {
            set dx [blas::subvector create 1 $incx $n $dx1]
            set dy [blas::subvector create 1 $incy $n $dy1]
            set dparam [blas::vector create double [blastest::textract 5 dpar 1 $kpar]]
            set dtx [blas::vector create double [blastest::textract 7 dt19x 1 $kpar $kni]]
            set dty [blas::vector create double [blastest::textract 7 dt19y 1 $kpar $kni]]
            test dblas1 "blas::drotm $ki $kn $kpar" {
                blas::drotm dx dy $dparam
                concat [blastest::vextract $lenx $dx] [blastest::vextract $leny $dy]
            } [concat [blastest::vextract $lenx $dtx] [blastest::vextract $leny $dty]]
        }

        set dx [blas::subvector create 1 $incx $n $dx1]
        set dy [blas::subvector create 1 $incy $n $dy1]
        test dblas1 "blas::dcopy $ki $kn" {
            blas::dcopy $dx dy
            blastest::vextract $leny $dy
        } [blastest::textract $leny dt10y 1 $kn $ki]
        
        set dx [blas::subvector create 1 $incx $n $dx1]
        set dy [blas::subvector create 1 $incy $n $dy1]
        test dblas1 "blas::dswap $ki $kn" {
            blas::dswap dx dy
            concat [blastest::vextract $lenx $dx] [blastest::vextract $leny $dy]
        } [concat [blastest::textract $lenx dt10x 1 $kn $ki] [blastest::textract $leny dt10y 1 $kn $ki]]
    }
}

puts stderr done
 
set rien {


dnrm2
drotg
drotmg
}
