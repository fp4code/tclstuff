#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo30.tcl cosmétique de labo27.tcl + argument port
##
## connecte à maison27.tcl
##
## utilise ssh
## 

source casaNetCommun.30.tcl

if {$argc != 3} {
    puts stderr "syntaxe : $argv0 adresseMaison \{machineSSH | -server\} portSSH"
    exit 1
}

set casaNet_adresseMaison [lindex $argv 0]

if {$casaNet_adresseMaison != "ram94-1-81-57-198-61.fbx.proxad.net"} {
    puts stderr "\"$casaNet_adresseMaison\" != \"ram94-1-81-57-198-61.fbx.proxad.net\""
    exit 2
}

set casaNet_machineSSH    [lindex $argv 1]
set casaNet_portSSH       [lindex $argv 2]

proc casaNet_readTUNNEL1 {machineServeur portServeur TUNNEL} {
    global eventLoop MD5PASS TUNPS
    if [eof $TUNNEL] {
        close $TUNNEL
        set eventLoop "TUNNEL is dead"
        return
    }
    set l [gets $TUNNEL]
    puts stdout "TUNNEL: \"$l\""
    if {![string match START* $l]} {
        return
    }
    fileevent $TUNNEL readable {}
    fconfigure $TUNNEL -blocking 1
    puts stderr "pass à lire"
    set md5pass [gets $TUNNEL]
    puts stderr "pass lu : \"$md5pass\" (attendu \"$MD5PASS\")"
    if {$md5pass != $MD5PASS} {
        puts $TUNNEL "Mauvais mot de passe"
        close $TUNNEL
        return -code error "Mauvais mot de passe"
    }
    puts $TUNNEL OK

    puts stderr "Liaison acceptée de [fconfigure $TUNNEL -peername]"

    if {$machineServeur == "-server"} {
	socket -server [list casaNet_liaisonLocaleAcceptee $TUNNEL] $portServeur	
	global casaNet_LIAISONS
	set casaNet_LIAISONS(oneShot) {}
    } else {
	set err [catch {socket $machineServeur $portServeur} socketServeur]
	if {$err} {
	    puts stderr "connexion refusée vers $machineServeur:$portServeur ($socketServeur)"
	    return
	}
	puts stderr "Liaison acceptée vers [fconfigure $socketServeur -peername]"
	casaNet_bipont $TUNNEL        $socketServeur
    }
}

proc casaNet_liaisonLocaleAcceptee {TUNNEL socketClient adresseClient portClient} {
    set qui [fconfigure $socketClient -peername]
    puts stderr "Liaison locale acceptée de $qui"
    casaNet_bipont $socketClient $TUNNEL
    puts stderr "Connecté !"
}

proc casaNet_doIt {machineServeur portServeur proxyHost proxyPort tunnelHost tunnelPort} {
    global TUNNEL PROG TUNPS
    puts stderr [list socket $proxyHost $proxyPort]
    set TUNNEL [socket $proxyHost $proxyPort]
    puts stderr done
    fileevent $TUNNEL readable [list casaNet_readTUNNEL1 $machineServeur $portServeur $TUNNEL]
    fconfigure $TUNNEL -blocking 0 -buffering line
    puts stderr "Connecté au proxy !"
    puts $TUNNEL "CONNECT $tunnelHost:$tunnelPort HTTP/1.1"
    puts $TUNNEL {}
    puts $TUNNEL {}
    puts stderr "Connecté !"
}

close stdin
casaNet_doIt $casaNet_machineSSH $casaNet_portSSH proxy 8080 $casaNet_adresseMaison 443
vwait casaNet_TERMINE
puts stderr $casaNet_TERMINE
