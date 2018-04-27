#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison2.tcl
##
## attend une connection de labo2 et cause à peine
##

if {$argc != 1} {
    puts stderr "syntaxe $argv0 port"
    exit
}

set svcPort [lindex $argv 0]

# Handles the output from the labo and labo shutdown
proc readLabo {labo} {
    set l [gets $labo]    ;# get the client packet
    if {[eof $labo]} {    ;# client gone or finished
        close $labo       ;# release the servers client channel
    } else {
        puts stderr "Labo: \"$l\""
    }
}

# Accept-Connection handler for Server.
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on, 
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on 
# the client channel - send connection Reply and log connection

proc accept {labo addr port} {
  
    # Setup handler for future communication on client socket
    fileevent $labo readable [list readLabo $labo]
    
    # Note we've accepted a connection (show how get peer info fm socket)
    puts stderr "Accept from [fconfigure $labo -peername]"
    
    # Read client input in lines, disable blocking I/O
    fconfigure $labo -buffering line -blocking 0
    
    # Send Acceptance string to client
    puts $labo "$addr:$port, You are connected !"
    set date [clock format [clock seconds]]
    puts $labo "It is now $date"
    
    # log the connection
    puts stderr "Accepted connection from $addr at $date"
}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

socket -server accept $svcPort
vwait events    ;# handle events till variable events is set

