#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set nomServeur tif.lpn.prive ;# ou un autre nom internet
set portServeur 9999
set sockVersServeur [socket $nomServeur $portServeur]
set s $sockVersServeur
package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}
tls::import $s  \
        -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
        -request 0 -require 0 \
        -command printargs
tls::status $s
tls::handshake $s
puts $s "Blabla du labo vers la maison"
flush $s
puts stderr "Maison: [gets $s]"
