#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo11.tcl
##
## connecte à maison11 et affiche ce qui est reçu
##
## Incompréhensible mais anodin "bgerror {expected integer but got ""}"
##

set svcPort 9999

package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}

proc bgerror args {global errorInfo; puts stderr "bgerror $args"; puts stderr $errorInfo}

proc readMaison {maison} {
    global eventLoop
    puts stderr readMaison...
    if {[eof $maison]} {
        close $maison
        set eventLoop "Maison is dead"
    } else {
        set l [gets $maison]
        puts stderr "Maison: \"$l\""
    }
}

proc doIt {maisonHost maisonPort} {
    set maison [socket $maisonHost $maisonPort]
    tls::import $maison  \
        -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
        -request 0 -require 0 \
        -command printargs
    tls::handshake $maison
    puts stderr "tls::status = [tls::status $maison]"
    fileevent $maison readable [list readMaison $maison]
    fconfigure $maison -buffering line -blocking 0
    puts stderr "Connecté à la maison !"
    vwait eventLoop
}

doIt tif $svcPort
puts stderr $eventLoop
