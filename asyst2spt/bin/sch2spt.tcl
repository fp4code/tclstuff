#!/usr/local/bin/tclsh

proc sch2spt {from to} {

    if {[file exists $to]} {
        error "Le fichier \"$to\" existe"
    }
    set contenus [exec print_asyst_file $from]
    set contenus [split $contenus \n]
    if {[llength $contenus] != 3} {
        error "llength $contenus != 3"
    }
    set hc1 {Comment #1  : }
    set hc2 {Comment #2  : }
    set hs1 {Subfile #1  : }
    set c1 [litEntreXetBlancs [lindex $contenus 0] $hc1]
    set c2 [litEntreXetBlancs [lindex $contenus 1] $hc2]
    set s1 [litEntreXetBlancs [lindex $contenus 2] $hs1]
    if {[regexp {^REAL DIM\[ 2 , ([0-9]+) \]$} $s1 tout nLignes] == 0} {
        error "regexp s1 = $s1"
    }
    set f [open $to w]
    puts $f "@@sch $c1 $c2"
    set datas [split [exec print_asyst_file $from 1 %12.5e] \n]
    if {$nLignes*2 != [llength $datas]} {
        error "nLignes = $nLignes, #[llength $datas] datas"
    }
    puts $f "@       V            I"
    for {set i 0; set j $nLignes} {$i < $nLignes} {incr i; incr j} {
        puts $f "[lindex $datas $j] [lindex $datas $i]"
    }
    close $f
}

proc litEntreXetBlancs {ligne X} {
    set regexp [join [list ^ $X {(.*[^ ]) *$}] {}]
    if {[regexp $regexp $ligne tout resul] == 0} {
        error "regexp ligne = $ligne"
    }
    return $resul
}

proc fulldir {fromD toD} {
    set fichiers [glob $fromD/*.sch]
    foreach from $fichiers {
        puts $from
        sch2spt $from $toD/[file tail $from].spt
    }
}

if {$argc != 2} {
    puts stderr "syntaxe : $argv0 repertoire_des_sch repertoire_des_spt"
}

set fromD [lindex $argv 0]
set toD [lindex $argv 1]

fulldir $fromD $toD
