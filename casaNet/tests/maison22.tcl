#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison22.tcl
##
## attend une connection un port et connecte à l'écran local X11
##
## tif% xhost localhost 
## tif% ./maison22.tcl 6022
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
