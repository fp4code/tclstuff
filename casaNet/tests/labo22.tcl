#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo22.tcl
##
## lance un programme X11 sur le port donné d'une machine donnée, au moyen d'un pseudo-écran local
##
## ./labo22.tcl tif 6000
##

set PROG xterm

if {$argc != 2} {
    puts stderr "syntaxe : $argv0 machineMaison portMaison"
    exit 1
} else {
    set machineMaison [lindex $argv 0]
    set portMaison [lindex $argv 1]
}

proc bgerror {message} {
    global errorInfo
    puts $errorInfo
}

proc transmets {socka sockb} {
    global termine
    set bytes [read $socka 4096]
    if {[eof $socka]} {
        close $sockb
        set termine "$socka is dead"
    } else {
        puts -nonewline $sockb $bytes
        flush $sockb
    }    
}

proc accept {machineMaison portMaison programme host port} {
    global pseudoEcran
    close $pseudoEcran
    set veritableEcran [socket $machineMaison $portMaison]
    fconfigure $programme -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fconfigure $veritableEcran -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $programme readable [list transmets $programme $veritableEcran]
    fileevent $veritableEcran readable [list transmets $veritableEcran $programme]
}

proc demarrePseudoEcranEtProgramme {machineMaison portMaison} {
    global PROG env pseudoEcran

    set ok 0
    set ecran 10
    
    while {!$ok} {
        set err [catch {socket -server [list accept $machineMaison $portMaison] [expr {6000 + $ecran}]} pseudoEcran]
        if {$err} {
            puts stderr "écran $ecran déjà utilisé"
            incr ecran
            if {$ecran > 20} {
                puts stderr "pas assez d'écrans disponibles"
                exit 2
            }
        } else {
            set ok 1
        }
    }

    close stdin
    
    set env(DISPLAY) [info hostname]:$ecran
    puts stderr "Démarrage de $PROG affiché sur $env(DISPLAY)"
    exec $PROG -display $env(DISPLAY) &
}

demarrePseudoEcranEtProgramme $machineMaison $portMaison

vwait termine
puts stderr $termine

