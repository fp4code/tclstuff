#!/usr/local/bin/tclsh

package require fidev
package require fichUtils

if {$argc < 2} {
    puts stderr "syntaxe : $argv0 [-waitend] imprimante fichiers..."
    exit 1
}

puts stderr "$argv0 $argv"

set ippAndDelete [::fidev::fichUtils::whereIsScript]/ippAndDelete.tcl
puts stderr $ippAndDelete

if {[lindex $argv 0] == "-waitend"} {
    set WAITEND 1
    set argv [lrange $argv 1 end]
} else {
    set WAITEND 0
    close stdout
    close stderr
}

set imprimante [lindex $argv 0]
set tmpfic [lrange $argv 1 end]

set label "Impression Rustique sur $imprimante"

set c1 [concat /usr/openwin/bin/cmdtool \
                -geometry 800x150 \
                -label [list $label] \
                -c $ippAndDelete]
set c2 [concat $imprimante $tmpfic >& /dev/null]

if {$WAITEND} {
    set commande [concat $c1 -waitend $c2] 
} else {
    set commande [concat $c1 $c2 &]
}

set LOG [open "/tmp/$env(USER).log" a]
puts $LOG [list eval exec $commande]
puts $LOG "LD_LIBRARY_PATH=$env(LD_LIBRARY_PATH)"
puts $LOG "DISPLAY=$env(DISPLAY)"
close $LOG

puts $comande
eval exec $commande

exit 0





