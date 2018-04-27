#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## maison27.tcl
##
## connecte à labo27.tcl
##
## Utilise ssh
## local# ./casaNetMaison.27.tcl 9999
## local$ mailx -s "maison-lpn .... hulk 27" fabrice.pardo@lpn.cnrs.fr
## wait...
## local$ ssh localhost#9999
## hulk$ rlogin yoko
## yoko$ vncserver -> :x
## local$ ssh -L 590y:yoko:590x localhost#9999
## hulk$ ...
## local$ vncviewer localhost:y

set PROXY_IP "193.48.163.6"
set PROXY_NAME "prunelle.lpn.cnrs.fr"

source casaNetCommun.27.tcl

if {$argc != 1} {
    puts stderr "syntaxe $argv0 portLocal"
    exit 1
}
set casaNet_portLocal      [lindex $argv 0]

proc casaNet_liaisonHttpsAcceptee {portLocal tunnel addr port} {
    global TUNNEL onlyOne MD5PASS PROXY_IP PROXY_NAME
    set TUNNEL $tunnel

    set qui [fconfigure $TUNNEL -peername]
    if {[lindex $qui 0] != $PROXY_IP || [lindex $qui 1] != $PROXY_NAME} {
        puts stderr "Liaison refusée de $qui (attend $PROXY_IP $PROXY_NAME)"
        return
    }
    puts stderr "Liaison Https acceptée de $qui"
    close $onlyOne

    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $TUNNEL "HTTP/1.1 200 OK"
    puts $TUNNEL "Date: $date"
    puts $TUNNEL "Server: CNRS/LPN/Phydis maison"
    puts $TUNNEL {}
    puts $TUNNEL {}
    puts stderr "Accepted connection from $addr at $date"
    puts $TUNNEL START
    flush $TUNNEL
    puts $TUNNEL $MD5PASS
    flush $TUNNEL
    # réécrire
    fconfigure $TUNNEL -blocking 1
    while {[set lu [gets $TUNNEL]] != "OK"} {
        puts stderr "Labo: \"$lu\""
        if {[eof $TUNNEL]} {
            return -code error "Labo is dead"
        }
    }
    puts stderr "Labo: \"$lu\""

    socket -server [list casaNet_liaisonLocaleAcceptee $TUNNEL] $portLocal
}


proc casaNet_liaisonLocaleAcceptee {TUNNEL socketClient adresseClient portClient} {

    set qui [fconfigure $socketClient -peername]
    puts stderr "Liaison locale acceptée de $qui"

    fconfigure $socketClient \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $socketClient readable [list casaNet_transmet $socketClient $TUNNEL]

    fconfigure $TUNNEL \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $TUNNEL readable [list casaNet_transmet $TUNNEL $socketClient]
    puts stderr "Connecté !"
}

set onlyOne [socket -server [list casaNet_liaisonHttpsAcceptee $casaNet_portLocal] $HTTPS_PORT]
vwait casaNet_TERMINE
puts stderr $casaNet_TERMINE
