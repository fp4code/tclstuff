#!/bin/sh
# ceci est pour emacs: -*-Tcl-*-sh
# sous Unix, la ligne suivante démarre tclsh\
exec tclsh "$0" ${1+"$@"}

proc iso2mac {fich} {
    set f [open $fich r]
    fconfigure $f  -encoding iso8859-1 -translation lf
    set data [read -nonewline $f]
    close $f
    
    # On donne un nouveau nom sans risque
    set nfich [file rootname $fich].codeMac[file extension $fich]
    
    set f [open $nfich w]
    fconfigure $f -encoding macRoman -translation cr
    puts $f $data
    close $f
    
    puts stderr "le fichier \"$nfich\" est écrit"
}

if {[llength $argv] != 1} {
    puts stderr "syntaxe $argv0 fichier"
} else { 
    iso2mac $argv
}
