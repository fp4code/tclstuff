#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison11.tcl
##
## attend une connection de labo11 et cause à peine
##
## Il faut créer les certificats par les commandes
##  % openssl req -out CA.pem -new -x509
##  % openssl genrsa -out server.key 1024
##  % openssl req -key server.key -new -out server.req
##  % cat > file.srl << EOF
##  36
##  EOF
##  % openssl x509 -req -in server.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out server.pem


set svcPort 9999

package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}

proc bgerror args {puts stderr "bgerror $args"}

# Handles the output from the labo and labo shutdown
proc readLabo {labo} {
    set l [gets $labo]
    if {[eof $labo]} {
        close $labo
    } else {
        puts stderr "Labo: \"$msg\""
    }
}

proc accept {labo addr port} {
    tls::import $labo -certfile server.pem -keyfile server.key \
            -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
            -request 0 -require 0 -server 1 -command printargs
    tls::handshake $labo
    puts stderr "tls::status = [tls::status $labo]"
    fileevent $labo readable [list readLabo $labo]
    puts stderr "Accept from [fconfigure $labo -peername]"
    fconfigure $labo -buffering line -blocking 0
    puts $labo "$addr:$port, You are connected !"
    set date [clock format [clock seconds]]
    puts $labo "It is now $date"
    puts stderr "Accepted connection from $addr at $date"
}

socket -server accept $svcPort
vwait events    ;# handle events till variable events is set
