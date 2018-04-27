#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison4.tcl
##
## attend une connection de labo4 à travers le proxy ssl et cause à peine
##

set svcPort 443

# Handles the output from the labo and labo shutdown
proc readLabo {labo} {
    set l [gets $labo]    ;# get the client packet
    if {[eof $labo]} {    ;# client gone or finished
        close $labo       ;# release the servers client channel
    } else {
        puts stderr "Labo: \"$l\""
    }
}


proc accept {labo addr port} {
  
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
}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

socket -server accept $svcPort
vwait events    ;# handle events till variable events is set
