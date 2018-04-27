#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison22b.tcl
##
## 5 novembre 2002 (FP) ni casanet ni maison22 ne fonctionne. maison22b essaye de décanuler
## EN FAIT, MANQUAIT "xhost localhost"
##
## attend une connection un port et connecte à l'écran local X11
##
## tif% xhost localhost 
## tif% ./maison22b.tcl 6022
## yoko% xterm -display tif:22
##


if {$argc != 1} {
    puts stderr "syntaxe : $argv0 port"
    exit 1
} else {
    set svcPort $argv
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
        puts stderr "$socka->$sockb [string length $bytes]"
        puts -nonewline $sockb $bytes
        flush $sockb
    }    
}

proc accept {labo host port} {
    global onlyOne
    close $onlyOne

    set ecran [socket localhost 6000]
    fconfigure $labo -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fconfigure $ecran -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $labo readable [list transmets $labo $ecran]
    fileevent $ecran readable [list transmets $ecran $labo]
}

set onlyOne [socket -server accept $svcPort]
vwait termine
puts stderr $termine
