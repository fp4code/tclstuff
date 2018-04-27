#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
package require trig_sun
package require tpg


tpg::Struct::new RECTS
tpg::setLayer 0
tpg::setDose 0

set ex 44000
set ey 40000

set dx(0) 10000
set dx(1) 14000
set dx(2) 20000
set dx(3) 40000
set dx(4) 60000
set dx(5) 80000
set dx(6) 100000
set dx(7) 140000


set dy(0) 50000
set dy(1) 40000
set dy(2) 30000
set dy(3) 24000
set dy(4) 20000
set dy(5) 14000
set dy(6) 14000
set dy(7) 20000
set dy(8) 24000
set dy(9) 30000
set dy(10) 40000
set dy(11) 50000

set x 0
for {set co 0} {$co < 8} {incr co} {
    set y 0
    for {set li 0} {$li < 12} {incr li} {
        tpg::boundary "x=$x y=$y;v$dy($li);>$dx($co);^$dy($li);<$dx($co);"
        set y [expr {$y - $dy($li) - $ey}]
    }
    set x [expr {$x + $dx($co) + $ex}]
}

set SCRIPT [info script]
set time [file mtime $SCRIPT]

tpg::outGds2 RECTS RECTS ~fab/W/Z/anne $time 1 1e-9
tpg::displayWinStruct2 RECTS 0 0 0.1
