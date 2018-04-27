#!/bin/sh
# the next line restarts using tclsh \
exec wish8.3 "$0" ${1+"$@"}

package require fidev
package require -exact sound 2.0
load $fidev_libDir/libfidev_snack.so
set file /home/fab/Z/sons/la.wav

sound::sound s -file $file -debug 0
#  s play -block 1

# set argv {1 440. 50}

if {[llength $argv] != 3} {
    puts stderr "syntaxe $argv0 factor F Q"
    exit 22
}

set filter [snack::filter damposc [lindex $argv 0] [lindex $argv 1]  [lindex $argv 2]]

s play -block 1 -filter $filter

