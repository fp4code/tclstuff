#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

if {$argc != 1} {
    puts stderr "usage : $argv0 port"
    exit 1
}

set svcPort [lindex $argv 0]

# Implemente le service
# Cet exemple interprete une commande
proc doService {interp sock msg} {
    global commandeEnCours
    if {$commandeEnCours($interp) == {}} {
        set commandeEnCours($interp) $msg
    } else {
        append commandeEnCours($interp) \n$msg
    }
    if {[info complete $commandeEnCours($interp)]} {
        set coco $commandeEnCours($interp)
        set commandeEnCours($interp) {}
        set err [catch {$interp eval $coco} result]
        if {$err == 0} {
            set retour [list $err $result]
        } else {
            global errorInfo errorCode
            set retour [list $err $result $errorInfo $errorCode]
        }
        puts $sock [string length $retour]
        puts $sock $retour
    } else {
#         puts $sock [list -1 "> "]
    }
}

# Handles the input from the client and  client shutdown
proc  svcHandler {interp sock} {
  set l [gets $sock]    ;# get the client packet
  if {[eof $sock]} {    ;# client gone or finished
     puts "$interp is closed"
     interp delete $interp
     close $sock        ;# release the servers client channel
  } else {
    doService $interp $sock $l
  }
}

# Accept-Connection handler for Server. 
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on, 
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on 
# the client channel - send connection Reply and log connection

proc acceptProc {sock addr port} {
  
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

  # construction d'un identificateur d'interpréteur non ambigu pour la connexion
  set peerRef ${hostName}_$portNumber
  
  # création de l'interpréteur
  interp create -safe $peerRef

  global commandeEnCours
  set commandeEnCours($peerRef) {}
  
  # à chaque fois qu'il y a qqchose à lire, on appelle "svcHandler $peerRef $sock"
  fileevent $sock readable [list svcHandler $peerRef $sock]

  # Read client input in lines, disable blocking I/O
  fconfigure $sock -buffering line -blocking 0
}


# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.
socket -server acceptProc $svcPort
vwait events    ;# handle events till variable events is set

