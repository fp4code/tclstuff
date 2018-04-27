#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
package require trig_sun
package require tpg

set l(0) 80
set l(1) 60
set l(2) 55
set l(3) 50
set l(4) 45
set l(5) 40
set l(6) 35
set l(7) 30
set l(8) 25
set l(9) 20
set l(10) 15
set l(11) 10
set l(12) 5

set L 20
set w 4
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
    set x [expr {$co * 62}]
    set coco [expr {12-$co}]
    halbas  $x    0 14 $l($co)
    halhaut $x -213 20 $l($coco)
    halbas  $x -273 30 $l($co)
    halhaut $x -558 40 $l($coco)
    halbas  $x -618 60 $l($co)
}

set SCRIPT [info script]
set time [file mtime $SCRIPT]

tpg::outGds2 HALTERES HALTERES ~fab/W/Z/anne $time 1 1e-10
tpg::displayWinStruct2 HALTERES 0 0 0.1
