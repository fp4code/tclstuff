#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## maison30.tcl (cosmétique de maison.27.tcl)
##
## connecte à labo27.tcl
##
## Utilise ssh
## local# ./casaNetMaison.30.tcl 9999
## local$ mailx -s "maison-lpn .... muzo 30" fabrice.pardo@lpn.cnrs.fr
## wait...
## local$ ssh -p 9999 localhost
## hulk$ rlogin yoko
## yoko$ vncserver -> :x
## local$ ssh -p 9999  -L 590y:yoko:590x localhost
## hulk$ ...
## local$ vncviewer localhost:y

set PROXY_IP "193.48.163.6"
set PROXY_NAME "prunelle.lpn.cnrs.fr"

source casaNetCommun.30.tcl

if {$argc == 2} {
    if {[lindex $argv 0] != "-server"} {
	puts stderr "syntaxe $argv0 -server portLocal"
	exit 1
    }
    set SERVER 1
    set portServeur      [lindex $argv 1]
} elseif {$argc == 1} {
    set SERVER 0
    set portServeur      [lindex $argv 0]
} else {
    puts stderr "syntaxe $argv0 \[-server\] portLocal"
    exit 1
}

proc casaNet_liaisonHttpsAcceptee {portServeur tunnel addr port} {
    global socketHttps MD5PASS PROXY_IP PROXY_NAME SERVER

    puts stdout [list casaNet_liaisonHttpsAcceptee $portServeur $tunnel $addr $port]
    set qui [fconfigure $tunnel -peername]
    if {[lindex $qui 0] != $PROXY_IP || [lindex $qui 1] != $PROXY_NAME} {
        puts stdout "Liaison refusée de $qui (attend $PROXY_IP $PROXY_NAME)"
        return
    }
    puts stdout "Liaison Https acceptée de $qui"
    if {$SERVER} {
	close $socketHttps
	puts stdout "socketHttps est clos"
    }

    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $tunnel "HTTP/1.1 200 OK"
    puts $tunnel "Date: $date"
    puts $tunnel "Server: CNRS/LPN/Phydis maison"
    puts $tunnel {}
    puts $tunnel {}
    puts stdout "Accepted connection from $addr at $date"
    puts $tunnel START
    flush $tunnel
    puts $tunnel $MD5PASS
    flush $tunnel
    # réécrire
    fconfigure $tunnel -blocking 1
    while {[set lu [gets $tunnel]] != "OK"} {
        puts stdout "Labo: \"$lu\""
        if {[eof $tunnel]} {
            puts stdout "Labo is dead"
            return
        }
    }
    puts stdout "Labo: \"$lu\""

    if {$SERVER} {
	socket -server [list casaNet_liaisonLocaleAcceptee $tunnel] $portServeur
    } else {
	set machineServeur localhost
	set err [catch {socket $machineServeur $portServeur} socketServeur]
	if {$err} {
	        puts stdout "connexion refusee)e vers $machineServeur:$portServeur ($socketServeur)"
	        return
	}
	puts stdout "Liaison acceptee vers [fconfigure $socketServeur -peername]"
	casaNet_bipont $tunnel $socketServeur
    }
}

proc casaNet_liaisonLocaleAcceptee {tunnel socketClient adresseClient portClient} {
    set qui [fconfigure $socketClient -peername]
    puts stdout "Liaison locale acceptée de $qui"
    casaNet_bipont $socketClient $tunnel
    puts stdout "Connecté !"
}

set socketHttps [socket -server [list casaNet_liaisonHttpsAcceptee $portServeur] $HTTPS_PORT]
vwait casaNet_TERMINE
puts stdout $casaNet_TERMINE
