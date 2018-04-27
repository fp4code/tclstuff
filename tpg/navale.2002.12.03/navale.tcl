#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
package require trig_sun
package require tpg
package require tpgFontLucidaTypeWriter

tpg::setLayer 0
tpg::setDose 0

set PAS     200
set CARRE   100
set W        20
set PMW      [expr {$PAS - 2*$W}]
set XOFFc    60
set YOFFc1   20
set YOFFc2 -200
set XOFFl1  -10
set XOFFl2  110
set YOFFl    10
set FFONT     1

set N        10

tpg::createLucidaTypeWriterFont {} 20 18

tpg::Struct::new NAVALE

for {set li 0} {$li < $N} {incr li} {
    for {set co 0} {$co < $N} {incr co} {
        set xc [expr {$CARRE + $co*$PAS}]
        set yc [expr {-$CARRE - $li*$PAS}]
        tpg::boundary "x=$xc y=$yc;v$PAS;>$W;^$PAS;<$W;"
        tpg::boundary "x=[expr {$xc+$W+$PMW}] y=$yc;v$PAS;>$W;^$PAS;<$W;"
        tpg::boundary "x=[expr {$xc+$W}] y=$yc;v$W;>$PMW;^$W;<$PMW;"
        tpg::boundary "x=[expr {$xc+$W}] y=[expr {$yc-$W-$PMW}];v$W;>$PMW;^$W;<$PMW;"
    }
}

tpg::boundary "x=0                       y=0;                       v$CARRE;>$CARRE;^$CARRE;<$CARRE;"
tpg::boundary "x=[expr {$CARRE+$N*$PAS}] y=0;                       v$CARRE;>$CARRE;^$CARRE;<$CARRE;"
tpg::boundary "x=0                       y=[expr {-$CARRE-$N*$PAS}];v$CARRE;>$CARRE;^$CARRE;<$CARRE;"
tpg::boundary "x=[expr {$CARRE+$N*$PAS}] y=[expr {-$CARRE-$N*$PAS}];v$CARRE;>$CARRE;^$CARRE;<$CARRE;"

# foreach lettre {a b c d e f g h i j} li {0 1 2 3 4 5 6 7 8 9} 

for {set co 0} {$co < $N} {incr co} { 
    set char ch_$co
    tpg::sref $char [expr {$CARRE + $co * $PAS + $XOFFc}] [expr {-$CARRE + $YOFFc1}]
    tpg::sref $char [expr {$CARRE + $co * $PAS + $XOFFc}] [expr {-$CARRE + $YOFFc2 - $N*$PAS}]
}

scan a %c aAscii

for {set li 0} {$li < $N} {incr li} { 
    set char [format %c [expr {$aAscii + $li}]]_maj
    puts $char
    tpg::sref $char [expr {          $XOFFl1}] [expr {-$CARRE - ($li + 1) * $PAS + $YOFFl}]
    tpg::sref $char [expr {$N*$PAS + $XOFFl2}] [expr {-$CARRE - ($li + 1) * $PAS + $YOFFl}]
}

# l'heure du "gds2" sera l'heure de création de ce script :
set time [file mtime [info script]]
catch {tpg::outGds2 NAVALE NAVALE ~fab/W/Z $time 1 1e-9} blabla
puts $blabla

tpg::displayWinStruct2 NAVALE 0 0 0.1
