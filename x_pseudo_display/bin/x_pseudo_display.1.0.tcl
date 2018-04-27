#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## 25 mars 2002 (FP) xpds.2.0.tcl portage de mon vieux xpds.c
## 5 novembre 2002 (FP) ajout de quelques commentaires
##
## permet de lancer plusieurs programmes, ferme convenablement les flux
##
## ATTENTION : n'utilise aucun protocole pour se connecter à l'écran machinePossedantEcranX11:0
##             Il faut donc demander "xhost machineSurLaquelleCeProgrammeEstLancé
##
## Imprime dans stderr le display : hostname:ecran
## ecran est attribué, selon disponibilité, entre 10 et 20
## 

if {$argc != 1} {
    puts stderr "syntaxe : $argv0 machinePossedantEcranX11"
    exit 2
}

set machine [lindex $argv 0]

proc bgerror {message} {
    global errorInfo
    puts stderr $errorInfo
}

#################################
# copie de de socka vers sockb
#################################

proc transmets {socka sockb} {
    set bytes [read $socka 4096]
    # puts stderr "transmets : \"$bytes\""
    if {[string length $bytes] != 0} {
        puts -nonewline $sockb $bytes
        flush $sockb
    }
    if {[eof $socka]} {
        fileevent $socka readable {}
        fileevent $sockb readable {}
        close $socka
        close $sockb
        puts stderr "$socka is dead, close $sockb"
    }  
}

proc accept {machine pseudoProgramme host port} {
    set veritableEcran [socket $machine 6000]
    fconfigure $pseudoProgramme \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fconfigure $veritableEcran  \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $pseudoProgramme readable [list transmets $pseudoProgramme $veritableEcran]
    fileevent $veritableEcran  readable [list transmets $veritableEcran $pseudoProgramme]
    puts stderr "pseudoProgramme = $pseudoProgramme, veritableEcran = $veritableEcran"
}

proc demarrePseudoEcran {machine} {
    set ok 0
    set ecran 10
    while {!$ok} {
        set err [catch {socket -server [list accept $machine] [expr {6000 + $ecran}]} pseudoEcran]
        if {$err} {
            puts stderr "écran $ecran déjà utilisé"
            incr ecran
            if {$ecran > 20} {
                return -code error "pas assez d'écrans disponibles"
            }
        } else {
            set ok 1
        }
    }
    return $ecran
}

close stdin
if {[catch {demarrePseudoEcran $machine} ecran]} {
    puts stderr "demarrePseudoEcran en erreur : \"$ecran\""
    exit 2
}
puts stdout "[info hostname]:$ecran"
close stdout
vwait rienDuTout
