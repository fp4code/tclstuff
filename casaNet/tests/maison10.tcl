#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison10.tcl
##
## attend une connection de labo10 et cause à peine
##
## socket encryptée bloquante
##

## Il faut créer les certificats par les commandes
##  % openssl req -out CA.pem -new -x509
##  % openssl genrsa -out server.key 1024
##  % openssl req -key server.key -new -out server.req
##  % cat > file.srl << EOF
##  36
##  EOF
##  % openssl x509 -req -in server.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out server.pem

set portServeur 9999
set CONNECTION 0

proc demandeLiaison {sock IP port} {
    global CONNECTION sockServeur sockVersClient
    incr CONNECTION
    set sockVersClient $sock
    puts stderr [list demandeLiaison $sock $IP $port]
}

set sockServeur [socket -server demandeLiaison $portServeur]
vwait CONNECTION
set s $sockVersClient
package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}
tls::import $s -certfile server.pem -keyfile server.key \
        -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
        -request 0 -require 0 -server 1 -command printargs
tls::handshake $s
puts stderr [tls::status $s]
puts $s "Blabla de la maison vers le labo"
flush $s
puts stderr "Labo: [gets $s]"
