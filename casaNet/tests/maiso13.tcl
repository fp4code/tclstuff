#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison13.tcl
##
## attend une connection de labo13 à travers le proxy en cryptant
## on a déjà un shell
## Il faut donner le même mot de passe aux deux bouts
##
## Il faut créer les certificats par les commandes
##  % openssl req -out CA.pem -new -x509
##  % openssl genrsa -out server.key 1024
##  % openssl req -key server.key -new -out server.req
##  % cat > file.srl << EOF
##  36
##  EOF
##  % openssl x509 -req -in server.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out server.pem

set svcPort 443

package require md5
puts -nonewline stderr "mot de passe : "
set pass [gets stdin]
set MD5PASS [md5::md5 $pass]

package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror: $message"
    puts stderr [info level]
    puts stderr $errorInfo
}

# Handles the output from the labo and labo shutdown
proc readLabo {labo} {
    global events
    set l [gets $labo]    ;# get the client packet
    if {[eof $labo]} {    ;# client gone or finished
        fileevent stdin readable {}
        close $labo       ;# release the servers client channel
        set events "Labo is dead"
    } else {
        puts stderr "Labo: \"$l\""
    }
}


proc sendLabo {labo} {
    global events

    set l [gets stdin]
    if {[eof stdin]} {
        puts stderr "EOF stdin"
        close $labo              ;# close the socket client connection
        set events "done"        ;# terminate the vwait (eventloop)
    } else {
        puts $labo $l            ;# envoi au labo
    }
}


proc accept {labo addr port} {
  
    global onlyOne MD5PASS
    close $onlyOne

    puts stderr "Accept from [fconfigure $labo -peername]"
    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $labo "HTTP/1.1 200 OK"
    puts $labo "Date: $date"
    puts $labo "Server: CNRS/LPN/Phydis maison"
    puts $labo ""
    puts $labo ""
    puts $labo ""
    puts $labo "blabla"
    puts stderr "Accepted connection from $addr at $date"
    puts stderr "Tapez sur le clavier"
    puts $labo START
    flush $labo
    puts $labo $MD5PASS
    flush $labo
    # réécrire
    fconfigure $labo -blocking 1
    while {[set lu [gets $labo]] != "OK"} {
        puts stderr "Labo: \"$lu\""
        if {[eof $labo]} {
            return -code error "Labo is dead"
        }
    }
    puts stderr "Labo: \"$lu\""
    tls::import $labo -certfile server.pem -keyfile server.key \
            -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
            -request 0 -require 0 -server 1 -command printargs
    tls::handshake $labo
    puts stderr "tls::status = [tls::status $labo]"
    fileevent $labo readable [list readLabo $labo]
    fconfigure $labo -buffering line -blocking 0
    fileevent stdin readable [list sendLabo $labo]
}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

set onlyOne [socket -server accept $svcPort]
vwait events    ;# handle events till variable events is set
puts stderr $events
