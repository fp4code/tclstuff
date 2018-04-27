#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set svcPort 80

# Implement the service
# This example just writes the info back to the client...
proc doService {sock msg} {
#     puts $sock "$msg"
    puts stderr "$msg"
    if {$msg == {}} {
        # close $sock
    }
}

# Handles the input from the client and  client shutdown
proc  svcHandler {sock} {
    set l [gets $sock]    ;# get the client packet
    if {[eof $sock]} {    ;# client gone or finished
        close $sock       ;# release the servers client channel
    } else {
        doService $sock $l
    }
}

# Accept-Connection handler for Server. 
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on, 
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on 
# the client channel - send connection Reply and log connection

proc accept {sock addr port} {
  
    # Setup handler for future communication on client socket
    fileevent $sock readable [list svcHandler $sock]
    
    # Note we've accepted a connection (show how get peer info fm socket)
    puts stderr "Accept from [fconfigure $sock -peername]"
    
    # Read client input in lines, disable blocking I/O
    fconfigure $sock -buffering line -blocking 0
    
    # Send Acceptance string to client
    set date [clock format [clock seconds]]
    puts $sock "HTTP/1.1 200 OK"
    puts $sock "Date: $date"
    puts $sock "Server: phydis/0.1"
    puts $sock "Connection: close"
    puts $sock "Content-Type: text/plain"
    puts $sock ""
    puts $sock "blabla"

    # log the connection
    puts stderr "Accepted connection from $addr at $date"
}


# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

socket -server accept $svcPort
vwait events    ;# handle events till variable events is set

