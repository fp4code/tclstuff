#!/bin/sh
#\
exec tclsh "$0" "$@"

set HELP(Program) {
  28 avril 2000 (FP)
    démonstration d'un programme qui appelle plusieurs "serveurs"
    Ces serveurs répondent à des requêtes de création de socket auquelles correspond
    un interpréteur.
    Ces serveurs s'autodétruisent si on les laisse endormis.
}

proc lit {ident machine pipe} {
    global STATUS

    puts stderr {}
    if {[eof $pipe]} {
        puts stderr "server is closed"
        # pour ne pas avoir de <defunct>
        close $pipe
        set STATUS($ident) closed
    } else {
        set lu [gets $pipe]
        if {$STATUS($ident) == "new"} {
            if {[string range $lu 0 4] == "port="} {
                set STATUS($ident) [list OK [string range $lu 5 end]]
            } else {
                set STATUS($ident) [list ERROR $lu]
                close $pipe
            }
        } else {
            puts stderr "$ident -> \"$lu\""
        }
    }
    parray STATUS
}

proc newCreateServer {machine timeout} {
    global STATUS

    set pwd [pwd]
    cd [file dirname [info script]]
    set script [file join [pwd] creator.tcl]
    cd $pwd

    set commande "$script $timeout 2>@stdout"
    puts stderr $commande

    if {$machine != "localhost"} {
        set commande "rsh -n $machine $commande"
    }
    set err [catch {open "|$commande" r} message]
    
    if {$err} {
        # apparement, ne concerne que "localhost"
        return -code error "ERREUR sur $machine: $message"
    } else {
        set f $message
    }
    
    set ident [aMachineIdent $machine]
    set STATUS($ident) "new"
    fconfigure $f -blocking 0
    fileevent $f readable [list lit $ident $machine $f]
    return $ident
}

proc aMachineIdent {machine} {
    global STATUS
    set i 1
    while {[info exists STATUS([list $machine $i])]} {
        incr i
    }
    return [list $machine $i]
}

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

newCreateServer u5fico 10000
newCreateServer bibi   10000
newCreateServer fico3  10000
set ident [newCreateServer u5fico 10000]
newCreateServer localhost 10000

proc causette {esvrSock ident delai n} {
    global STATUS

    if {$n == 0} {
        close $esvrSock
        return
    }

    if {[lindex $STATUS($ident) 0] != "OK"} {
        return -code error "Mort prématurée"
    }
    set port [lindex $STATUS($ident) 1]

    if {$esvrSock == {}} {

        # Pas de connexion avec un client en cours
        # demande de connexion (synchrone) au serveur
        
        set esvrSock [socket [lindex $ident 0] $port]
        
        # configuration de la chaussette pour une communication flushée
        # à chaque fin de ligne
        
        fconfigure $esvrSock -buffering line
        fconfigure $esvrSock -translation crlf
        
    }

    puts stderr {}
    exec_sock $esvrSock set toto blabla
    puts stderr "$n [exec_sock $esvrSock set toto]"

    incr n -1
    after $delai [list causette $esvrSock $ident $delai $n]
}

after 5000 [list causette {} $ident 2000 10]

after 50000 exit
vwait events


