#!/home/fab/C/fidev-unknown-Linux-2.2.16-3-cc/Tcl/snack/src/dsh

set S(vol) 0.15
set S(freqL) 110
set S(freqR) 110
set S(phase) 0.0
set S(difff) 0.0
set S(logf) 0.0
set S(type) phase

frame .type
pack .type
label .type.label -text modulation:
radiobutton .type.phase -variable S(type) -value phase -text phase -command typmod
radiobutton .type.freq -variable S(type) -value freq -text freq -command typmod
pack .type.label .type.phase .type.freq -side left

scale .sph
pack .sph
.sph configure -orient horizontal -from -5 -to 5 -digits 3 -tickinterval 1 -resolution 0.01 -length 600 -variable S(phase) -command reconf

set LMAX [expr {log(22000/440.)/log(2.)}]

scale .sfr
pack .sfr
.sfr configure -orient horizontal -from -4 -to $LMAX -digits 3 -tickinterval 1 -resolution 0.01 -length 600 -variable S(logf) -command reconf

proc typmod {} {
    global S
    switch $S(type) {
	phase {
	    .sph configure -from -5 -to 5 -variable S(phase) -tickinterval 1 -resolution 0.01
	}
	freq {
	    .sph configure -from -20 -to 20 -variable S(difff) -tickinterval 2 -resolution 0.1
	}
    }
}

proc reconf {x} {
    global phase GEN S
    set f [expr {pow(2.0, $S(logf))*440.}]
    switch $S(type) {
	phase {
	    set S(freqL) $f
	    set S(freqR) $f
	    $GEN configure -freqL $S(freqL) -freqR $S(freqR) -phaseL [expr {0.5*$S(phase)}] -phaseR [expr {-0.5*$S(phase)}]
	}
	freq {
	    set S(freqL) [expr {$f - 0.5*$S(difff)}]
	    set S(freqR) [expr {$f + 0.5*$S(difff)}]
	    $GEN configure -freqL $S(freqL) -freqR $S(freqR) -phaseL 0 -phaseR 0
	}
	default {
	    return -code error "unknown type \"$S(type)\"" 
	}
    }
}

set GEN [snack::filter gensin -freqL 440 -freqR 440]
reconf {}
snack::sound s -channels 2 -rate 44100
s play -filter $GEN

