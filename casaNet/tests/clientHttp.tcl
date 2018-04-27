#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# lecture de ce qui sort de la chaussette $sock et impression à l'écran 
# la variable globale eventLoop est modifiée si le serveur meurt
proc read_sock {sock} {
    global eventLoop
    if [eof $sock] {
        fileevent stdin readable {}
        close $sock                        ;# close the socket client connection
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

if {$argc != 2} {
    error "Syntaxe : $argv0 host port"
}

proc doIt {eshost esport} {
    
    # demande de connexion (synchrone) au serveur
    set esvrSock [socket $eshost $esport]

    # configuration de la chaussette demandant de lire
    # au moyen de "read_sock" lorsqu'il y a qqchose à lire
    fileevent $esvrSock readable [list read_sock $esvrSock]

    # configuration de la chaussette pour une communication flushée
    # à chaque fin de ligne
    fconfigure $esvrSock -buffering line

    fconfigure $esvrSock -translation crlf

    # configuration du clavier demandant de lire lorsqu'il y a qqchose à lire
    #   Vector stdin data to the socket
    fileevent stdin readable [list read_stdin $esvrSock]

    # BlaBla 
    puts "EchoServerClient Connected to echo server"
    puts "...what you type should be echoed."

    # wait for and handle either socket or stdin events...
    vwait eventLoop
    
}

doIt [lindex $argv 0] [lindex $argv 1]
puts $eventLoop
