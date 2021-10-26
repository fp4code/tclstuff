#!/bin/sh

# RCS: @(#) $Id: agilent.tcl,v 0.1 2006-11-14 fab Exp $

# the next line restarts using wish \
LD_LIBRARY_PATH=$LD_LIBRARY_PATH":"/opt/NICgpib/lib ; export LD_LIBRARY_PATH ; exec wish "$0" "$@"

set tcl_traceExec 0
set tcl_traceCompile 0

proc sourceCode {dir file} {
    puts "sourceCode EST OBSOLETE, utiliser \"package\""
    puts "### $file"
    source $dir/library/$file
}

package require fidev
package require a4156
package require flex

set AsdexTclDir $FIDEV_TCL_ROOT
cd $AsdexTclDir

package require gpibLowLevel
package require gpib

puts "ALL IS SOURCED"

proc iniGlobals {} {
    global variable_SRQ
    set variable_SRQ {}

    global GPIB_board GPIB_boardAddress

    GPIB::newGPIB a4156 a4156  $GPIB_board 9
}

GPIB::main

iniGlobals

# 2006-11-14 mesures de MSM
# sense-low = masse coax = SMU1 
# source-hi = centre coax = SMU2
# sense-hi  = pointe DC = SMU3
# référence P = SMU4

package forget a4156
package require a4156

a4156 ini
puts [a4156 getModel]
a4156 enable_time_stamp
a4156 reset_time_stamp
a4156 write "FMT 1"
set t [a4156 read_time_stamp]
a4156 write "FMT 3,1"
set t [a4156 read_time_stamp]

couic

a4156 write "TSC 1"                ;# enable timestamp
a4156 write "TSR"                  ;# set timestamp to 0
a4156 write "CN 1,2,3,4"           ;# output on
a4156 write "MM 1,1,2,3,4"         ;# measurement mode = spot
a4156 write "DV 1,11,0,100e-9,0"   ;# 
a4156 write "DV 2,11,0,100e-9,0"
a4156 write "DV 3,11,0,100e-9,0"
a4156 write "DV 4,11,0,100e-9,0"
a4156 write "RI 1,11,2"
a4156 write "RI 2,11,2"
a4156 write "RI 3,11,2"
a4156 write "RI 4,11,2"
a4156 write "CMM 1,0"
a4156 write "CMM 2,0"
a4156 write "CMM 3,0"
a4156 write "CMM 4,0"
set r [a4156 mesure 8] ; for {set i 0} {$i < 8} {incr i 2} {puts [lrange $r $i [expr {$i+2}]]}



proc gett l {return [lindex $l 3]}
proc getv l {return [expr {[lindex $l 4] * [lindex $l 5]}]}
proc gettv l {return [list \
    [getv [lindex $l 1]] [getv [lindex $l 3]]\
    [getv [lindex $l 5]] [getv [lindex $l 7]]\
    [gett [lindex $l 0]] [gett [lindex $l 2]]\
    [gett [lindex $l 4]] [gett [lindex $l 6]]]}
proc cloclo {} {
    return [clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]
}

proc poupou {f v} {
    puts $v
    puts $f $v
}


set f [open ~/Z/mesures.[cloclo].spt w]
puts $f "@@MSM [cloclo]"
puts $f "@V3 I1 I2 I3 I4 T1 T2 T3 T4"
for {set v 0} {$v <= 1.0} {set v [expr {$v+0.01}]} {
    a4156 write "DV 3,11,$v,100e-9,0"
    poupou $f "$v [gettv [a4156 mesure 8]]"
}
for {set v 1.0} {$v >= -1.0} {set v [expr {$v-0.01}]} {
    a4156 write "DV 3,11,$v,100e-9,0"
    poupou $f "$v [gettv [a4156 mesure 8]]"
}
for {set v -1.0} {$v <= 0} {set v [expr {$v+0.01}]} {
    a4156 write "DV 3,11,$v,100e-9,0"
    poupou $f "$v [gettv [a4156 mesure 8]]"
}
close $f


set rien {
a4156 write "CMM 1,3"
a4156 write "CMM 2,3"
a4156 write "CMM 3,3"
a4156 write "CMM 4,3"
}
