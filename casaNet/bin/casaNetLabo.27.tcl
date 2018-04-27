#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo27.tcl
##
## connecte à maison27.tcl
##
## utilise ssh
## 

source casaNetCommun.27.tcl

if {$argc != 2} {
    puts stderr "syntaxe : $argv0 adresseMaison machineSSH"
    exit 1
}

set casaNet_adresseMaison [lindex $argv 0]
set casaNet_machineSSH    [lindex $argv 1]

proc casaNet_readMaison1 {machineServeur portServeur maison} {
    global eventLoop MD5PASS TUNPS
    if [eof $maison] {
        close $maison
        set eventLoop "Maison is dead"
        return
    }
    set l [gets $maison]
    puts stdout "Maison: \"$l\""
    if {![string match START* $l]} {
        return
    }
    fileevent $maison readable {}
    fconfigure $maison -blocking 1
    puts stderr "pass à lire"
    set md5pass [gets $maison]
    puts stderr "pass lu : \"$md5pass\" (attendu \"$MD5PASS\")"
    if {$md5pass != $MD5PASS} {
        puts $maison "Mauvais mot de passe"
        close $maison
        return -code error "Mauvais mot de passe"
    }
    puts $maison OK

    puts stderr "Liaison acceptée de [fconfigure $maison -peername]"

    set err [catch {socket $machineServeur $portServeur} socketServeur]
    if {$err} {
        puts stderr "connexion refusée vers $machineServeur:$portServeur ($socketServeur)"
        return
    }

    puts stderr "Liaison acceptée vers [fconfigure $socketServeur -peername]"

    fconfigure $maison \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $maison readable [list casaNet_transmet $maison $socketServeur]

    fconfigure $socketServeur \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $socketServeur readable [list casaNet_transmet $socketServeur $maison]
}

proc casaNet_doIt {machineServeur portServeur proxyHost proxyPort tunnelHost tunnelPort} {
    global TUNNEL PROG TUNPS
    puts stderr [list socket $proxyHost $proxyPort]
    set TUNNEL [socket $proxyHost $proxyPort]
    puts stderr done
    fileevent $TUNNEL readable [list casaNet_readMaison1 $machineServeur $portServeur $TUNNEL]
    fconfigure $TUNNEL -blocking 0 -buffering line
    puts stderr "Connecté au proxy !"
    puts $TUNNEL "CONNECT $tunnelHost:$tunnelPort HTTP/1.1"
    puts $TUNNEL {}
    puts $TUNNEL {}
    puts stderr "Connecté !"
}

close stdin
casaNet_doIt $casaNet_machineSSH 22 proxy 8080 $casaNet_adresseMaison 443
vwait casaNet_TERMINE
puts stderr $casaNet_TERMINE
