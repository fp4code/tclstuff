#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require snack

array set VOL {Mic 0 VolL 20 VolR 20}
snack::mixer volume Mic VOL(Mic)
snack::mixer volume Vol VOL(VolL) VOL(VolR)

snack::sound s -rate 44000 -channels 2
set gen [snack::filter generator 440 10000 0. sine -1]
s play -filter $gen

set fini 0
after 4000 {set fini 1}
vwait fini

s stop

proc fill {&s rate a duree_ms f1 f2 phase} {
    # phase en demi-tour
    upvar ${&s} s
    snack::sound s -rate $rate -channels 2
    set len [expr {int(ceil(($duree_ms/1000.)*$rate))}]
    s length $len
    set pit [expr {2.0*acos(-1.0)/double($rate)}]
    set pif1 [expr {$pit*double($f1)}]
    set pif2 [expr {$pit*double($f2)}]
    set pipha [expr {$pit*$phase}]
    for {set i 0} {$i < $len} {incr i} {
	s sample $i\
		[expr {round($a*(sin($i * $pif1)))}]\
		[expr {round($a*(sin($i * $pif2 + $pipha)))}]
    }
}
fill s 16000 10000 5000 440 439 0
s play
fill s 44100 10000 3000 100 101 0
s play

# phase sensible:

fill s 44100 3000 8000 1000 1001 0
s play
fill s 44100 3000 8000 500 501 0
s play
# très sensible
fill s 44100 3000 8000 250 251 0
s play
fill s 44100 3000 8000 120 121 0
s play
fill s 44100 3000 8000 60 61 0
s play
