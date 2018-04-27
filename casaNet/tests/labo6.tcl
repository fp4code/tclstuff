#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo6.tcl
##
## connecte à maison6 et affiche ce qui est reçu
##
## encode en ssl
##

set svcPort 9999
package require tls 1.4
tls::init
proc readMaison {maison} {
    global eventLoop
    if [eof $maison] {
        close $maison
        set eventLoop "Maison is dead"
    } else {
        set l [gets $maison]
        puts stdout "Maison: \"$l\""
    }
}

proc doIt {maisonHost maisonPort} {
    set maison [tls::socket $maisonHost $maisonPort]
    fileevent $maison readable [list readMaison $maison]
    # fconfigure $maison -buffering line -blocking 0
    puts stderr "Connecté à la maison !"

    while {![tls::handshake $maison]} {
        puts stderr 0
    }
    puts stderr Handshake

    puts stderr [gets $maison]
    vwait eventLoop
}

foreach protocol {ssl2 ssl3 tls1} {
    puts stderr "\n***$protocol ***"
    foreach c [tls::ciphers $protocol 1] {
        puts $c
    }
}

doIt tif $svcPort
puts $eventLoop
