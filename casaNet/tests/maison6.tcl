#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison6.tcl
##
## attend une connection de labo6 et cause à peine
##
## encode ssl
##

set svcPort 9999
package require tls 1.4
tls::init

proc readLabo {labo} {
    set l [gets $labo]
    if {[eof $labo]} {
        close $labo
    } else {
        puts stderr "Labo: \"$l\""
    }
}

proc accept {labo addr port} {
    while {![tls::handshake $labo]} {
        puts stderr 0
    }
    puts stderr Handshake
    

    fileevent $labo readable [list readLabo $labo]
    puts stderr "Accept from [fconfigure $labo -peername]"
    fconfigure $labo -buffering line -blocking 0
    puts $labo "$addr:$port, You are connected !"
    set date [clock format [clock seconds]]
    puts $labo "It is now $date"
    puts stderr "Accepted connection from $addr at $date"
    flush $labo
}


foreach protocol {ssl2 ssl3 tls1} {
    puts stderr "\n***$protocol ***"
    foreach c [tls::ciphers $protocol 1] {
        puts $c
    }
}

tls::socket -server accept $svcPort
vwait events    ;# handle events till variable events is set
