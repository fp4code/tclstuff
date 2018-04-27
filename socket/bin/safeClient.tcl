#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

# lecture de ce qui sort de la chaussette $sock et impression à l'écran 
# la variable globale eventLoop est modifiée si le serveur meurt

proc exec_sock {sock args} {
    global reponseEnCours
    global eventLoop

    puts $sock $args           ;# send the data to the server

    if {[eof $sock]} {
        fileevent stdin readable {}
        close $sock             ;# close the socket client connection
        set eventLoop "server is dead"     ;# terminate the vwait (eventloop)
    } else {
        set len [gets $sock]
        # puts stderr "$len a lire"
        incr len ;# sans doute un \n en plus
        set l [read $sock $len]
        # puts stderr "l=$l"
        if {[lindex $l 0] == 0} {
            return [lindex $l 1]
        } else {
            return -code error "[lindex $l 1] [lindex $l 2] [lindex $l 3]"
        }
    }
}

proc causette {eshost esport blabla} {
    # demande de connexion (synchrone) au serveur
    
    set esvrSock [socket $eshost $esport]
    
    # configuration de la chaussette pour une communication flushée
    # à chaque fin de ligne
    
    fconfigure $esvrSock -buffering line
    fconfigure $esvrSock -translation crlf
    
    puts stderr [exec_sock $esvrSock set toto $blabla]
    puts stderr [exec_sock $esvrSock set toto]
    close $esvrSock
}

if {$argc != 2} {
    error "Syntaxe : $argv0 host port"
}

for {set i 0} {1} {incr i} {
    causette [lindex $argv 0] [lindex $argv 1] $i
}

