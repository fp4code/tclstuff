#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison5.tcl
##
## attend une connection de labo4 à travers le proxy ssl et
## lui envoie stdin
## Dans le cas de labo5, on a déjà un shell
##

set svcPort 443

proc bgerror {message} {
    puts stderr "bgerror: $message"
    puts stderr [info level]
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
  
    global onlyOne
    close $onlyOne

    # Setup handler for future communication on client socket
    fileevent $labo readable [list readLabo $labo]
    
    # Note we've accepted a connection (show how get peer info fm socket)
    puts stderr "Accept from [fconfigure $labo -peername]"
    
    # Read client input in lines, disable blocking I/O
    fconfigure $labo -buffering line -blocking 0
    
    # Send Acceptance string to client
    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $labo "HTTP/1.1 200 OK"
    puts $labo "Date: $date"
    puts $labo "Server: CNRS/LPN/Phydis maison"
    puts $labo ""
    puts $labo ""
    puts $labo ""
    puts $labo "blabla"

    # log the connection
    puts stderr "Accepted connection from $addr at $date"
    puts stderr "Tapez sur le clavier"

    # démarrage du shell
    puts $labo START

    # Setup handler for future communication on client socket
    fileevent stdin readable [list sendLabo $labo]

}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

set onlyOne [socket -server accept $svcPort]
vwait events    ;# handle events till variable events is set
puts stderr $events
