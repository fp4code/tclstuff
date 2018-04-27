#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
package require trig_sun
package require tpg

set l(0) 80000
set l(1) 60000
set l(2) 55000
set l(3) 50000
set l(4) 45000
set l(5) 40000
set l(6) 35000
set l(7) 30000
set l(8) 25000
set l(9) 20000
set l(10) 15000
set l(11) 10000
set l(12) 5000

set L 20000
set w 4000
# différence paire

proc halbas {x y h l} {
    global L w
    tpg::boundary "x=$x y=$y;v$h;>$L;^$h;<$L;"
    set xx [expr {$x + ($L-$w)/2}]
    incr y -$h
    tpg::boundary "x=$xx y=$y;v$l;>$w;^$l;<$w;"
    incr y -$l
    tpg::boundary "x=$x y=$y;v$h;>$L;^$h;<$L;"
}

proc halhaut {x y h l} {
    halbas $x [expr {$y + 2*$h + $l}] $h $l
}

tpg::Struct::new HALTERES
tpg::setLayer 0
tpg::setDose 0

for {set co 0} {$co < 13} {incr co} {
    set x [expr {$co * 62000}]
    set coco [expr {12-$co}]
    halbas  $x       0 14000 $l($co)
    halhaut $x -213000 20000 $l($coco)
    halbas  $x -273000 30000 $l($co)
    halhaut $x -558000 40000 $l($coco)
    halbas  $x -618000 60000 $l($co)
}

set SCRIPT [info script]
set time [file mtime $SCRIPT]

tpg::outGds2 HALTERES HALTERES ~fab/W/Z/anne $time 1 1e-9
tpg::displayWinStruct2 HALTERES 0 0 0.1
