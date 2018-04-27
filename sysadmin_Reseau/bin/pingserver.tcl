#!/bin/sh
#\
exec tclsh "$0" "$@"

set timeout 10000

# Implemente le service
# Cet exemple interprete une commande
proc doService {sock msg} {
    puts stderr "reçu [string length $msg] caractères sur $sock"
    puts $sock $msg
    flush $sock
}

# Handles the input from the client and  client shutdown
proc  svcHandler {sock} {
    global EVENTS
    incr EVENTS

  set l [gets $sock]    ;# get the client packet
  if {[eof $sock]} {    ;# client gone or finished
    close $sock        ;# release the servers client channel
    puts stderr "exit"
    exit 0
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

set CONNEXIONS 0

proc acceptProc {sock addr port} {
  
    global CONNEXIONS

    if {$CONNEXIONS > 0} {
        puts stderr "Only one..."
        close $sock
        return 1
    }

    set secondes [clock seconds]
    set dada [clock format $secondes -format {%Y/%m/%d %H:%M:%S}]
    puts "Voici la date : $dada"
    
    # Note we've accepted a connection (show how get peer info fm socket)
    
    foreach {address hostName portNumber} [fconfigure $sock -sockname] {}
    puts "sockname : ip=$address ($hostName) port=$portNumber)"
    
    foreach {address hostName portNumber} [fconfigure $sock -peername] {}
    puts "peername : ip=$address ($hostName) port=$portNumber)"
    
    # log the connection
    puts "Accepted connection from $addr at $dada"
    
    # à chaque fois qu'il y a qqchose à lire, on appelle "svcHandler $sock"
    fileevent $sock readable [list svcHandler $sock]
    
    # Read big client input
    fconfigure $sock -buffering full -buffersize 1000000 -blocking 1

    incr CONNEXIONS

}

proc stopIfIdle {timeout} {
    global EVENTS LASTEVENTS

    puts stderr "$EVENTS events"

    if {$EVENTS == $LASTEVENTS} {
        exit 1
    }
    set LASTEVENTS $EVENTS
    after $timeout stopIfIdle $timeout
}


# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

set ok 0
for {set svcPort 33000} {$svcPort < 65000} {incr svcPort} {
    set err [catch {socket -server acceptProc $svcPort} message]
    if {!$err} {
        set ok 1
        break
    }
    if {($errorCode == "NONE" && $message == "couldn't open socket: address already in use") ||\
        [lindex $errorCode 0] == "POSIX" && [lindex $errorCode 1] == "EADDRINUSE"} {
        continue
    } else {
        return -code error $message
    }
}

puts "port=$svcPort"
flush stdout

set EVENTS 0
set LASTEVENTS 0

after $timeout stopIfIdle $timeout

vwait events   ;# handle events till variable events is set

