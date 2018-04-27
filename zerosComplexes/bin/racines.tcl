#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
# package require superWidgetsScroll
package require complexes 1.1
package require eqvp

set polar TM
set eps1 [::complexes::newXY 12.5254 0.5593]
set eps2 [::complexes::newXY -140.4 3.555]
set lambda 1.55
set d 0.85
set r 0.08
set kx0N 0.0
set XNm -8.0 
set XNp 8.0
set YNm -6.0
set YNp 20.0
set NDMAX 100
set DYMIN 1e-6
set DZM1 1e-6
set DZM2 1e-12
set DZwarn 1e-4
set divOfPeriod 20
set dl 0.05
set dtheta 0.05

set DEUXPI [expr {8.0*atan(1.0)}]

set k0 [expr {$DEUXPI/$lambda}]
set dN [expr {$d/$lambda}]

for {set r 0.01} {$r < 1.0} {set r [expr {$r + 0.01}]} {
    set resul "\{$r, "
    set r2 $r
    set r1 [expr {1.0 - $r2}]
    set d1N [expr {$r1*$dN}]
    set d2N [expr {$r2*$dN}]
    ::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN
    set err [catch {::zerosComplexes::zeros al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines]
    if {$err} {
	puts stderr "$r -> $racines"
	continue
    }
    append resul "\{"
    set first 1
    foreach z $racines {
	if {$first} {
	    set first 0
	} else {
	    append resul ", "
	}
	append resul "[format %.12f [::complexes::re $z]] + I [format %.12f [::complexes::im $z]]"
    }
    append resul "\}"
    append resul "\}"
    puts $resul
}



