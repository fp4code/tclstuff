#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# (C) CNRS/LPN (FP) 2001.03.20

if {$argc != 1} {
    return -code error "Syntaxe = $argv0 'col1 col2 ...'\nex: $argv0 'fichier PMOD(cc) PMOD(cc_ext)'"
}

#set COLS {fichier PMOD(cc) PMOD(cc_ext) PMOD(re) PMOD(rb) PMOD(Re) PMOD(Rb) PMOD(ReS) PMOD(RbS) PMOD(CeS) PMOD(CcC)}

set COLS [lindex $argv 0]

proc dumpOne {f cols} {
    foreach v $cols {set V($v) {}}
    set ff [open $f r]
    set lignes [split [read -nonewline $ff] \n]
    close $ff
    foreach l $lignes {
        set v [lindex $l 0]
        if {[info exists V($v)]} {
            if {$V($v) != {}} {
                return -code error "deux lignes $v dans $f"
            }
            set V($v) [lindex $l 1]
        } 
    }
    set lili [list]
    foreach v $cols {
        lappend lili $V($v)
    }
    puts $lili
}

set fichiers [lsort [glob *.dump]]

puts "$COLS"
foreach f $fichiers {
    dumpOne $f $COLS
}

