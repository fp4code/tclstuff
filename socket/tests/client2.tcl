#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

if {$argc != 1} {
    puts stderr "syntaxe : $argv0 serveur"
    exit 1
}

set eshost [lindex $argv 0]

# lecture de ce qui sort de la chaussette $sock et impression à l'écran 
# la variable globale eventLoop est modifiée si le serveur meurt
proc read_sock {sock} {
    global eventLoop
    if [eof $sock] {
        fileevent stdin readable {}
        close $sock             ;# close the socket client connection
        set eventLoop "server is dead"     ;# terminate the vwait (eventloop)
    } else {
        set l [gets $sock]
        puts stdout "ServerReply:$l"
    }
}

# lecture du clavier et envoi à la chaussette $wsock
# la variable globale eventLoop est modifiée après un Ctrl/D
proc read_stdin {wsock} {
    global eventLoop
    set l [gets stdin]
    if {[eof stdin]} {
        close $wsock             ;# close the socket client connection
        set eventLoop "done"     ;# terminate the vwait (eventloop)
    } else {
        puts $wsock $l           ;# send the data to the server
    }
}

set esport 9999

if {0} {

  # demande de connexion (synchrone) au serveur
    set esvrSock [socket $eshost $esport]

} else {

  #Another option is to do an asynchronous client connection 

    set esvrSock [socket -async $eshost $esport]

  # .... do whatever that we can't connect synchronously... 

  # resync with the connection, 
  #Socket becomes writable when connection available

    fileevent $esvrSock writable {set connect 1}
    vwait connect   
    # will 'block' here till connection up (or eof or error)

    fileevent $esvrSock writable {}    ;# remove previous handler

    if {[eof $esvrSock]} { # connection closed .. abort }
}

  # configuration de la chaussette demandant de lire
  # au moyen de "read_sock" lorsqu'il y a qqchose à lire
    fileevent $esvrSock readable [list read_sock $esvrSock]

  # configuration de la chaussette pour une communication flushée
  # à chaque fin de ligne
    fconfigure $esvrSock -buffering line

  # configuration du clavier demandant de lire lorsqu'il y a qqchose à lire
  #   Vector stdin data to the socket
    fileevent stdin readable [list read_stdin $esvrSock]

  # BlaBla 
    puts "EchoServerClient Connected to echo server"
    puts "...what you type should be echoed."

  # wait for and handle either socket or stdin events...
    vwait eventLoop

    puts $eventLoop


