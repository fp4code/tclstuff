#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo23.tcl
##
## dérivé de labo13.tcl
## connecte à l'écran X11 maison23, à travers un proxy en cryptant
## lance un programme
##

set svcPort 443
set PROG emacs

if {$argc != 1} {
    puts stderr "syntaxe : $argv0 adresse_maison"
    exit 1
}

package require md5
puts -nonewline stderr "mot de passe : "
set pass [gets stdin]
set MD5PASS [md5::md5 $pass]

package require tls
tls::init
proc printargs args {
    puts stderr "printargs $args"
}

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror: $message"
    puts stderr [info level]
    puts stderr $errorInfo
}

proc readMaison1 {maison} {
    global eventLoop MD5PASS
    if [eof $maison] {
        close $maison
        set eventLoop "Maison is dead"
        return
    }
    set l [gets $maison]
    puts stdout "Maison: \"$l\""
    if {![string match START* $l]} {
        return
    }
    fileevent $maison readable {}
    fconfigure $maison -blocking 1
    puts stderr "pass à lire"
    set md5pass [gets $maison]
    puts stderr "pass lu"
    if {$md5pass != $MD5PASS} {
        puts $maison "Mauvais mot de passe"
        close $maison
        return -code error "Mauvais mot de passe"
    }
    puts $maison OK
    tls::import $maison  \
            -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
            -request 0 -require 0 \
            -command printargs
    set essais 10
    while {$essais > 0} {
        set err [catch {tls::handshake $maison} message]
        if {$err} {
            puts stderr "tls::handshake $essais -> \"$message\""
            incr essais -1
            if {$essais == 0} {
                return -code error "tls::handshake raté"
            }
            after 1000
        } else {
            set essais 0
        }
        puts stderr "tls::status = [tls::status $maison]"
    }
    demarrePseudoEcranEtProgramme $maison
}

proc transmets {socka sockb} {
    global eventLoop
    set bytes [read $socka 4096]
    if {[eof $socka]} {
        close $sockb
        set eventLoop "$socka is dead"
    } else {
        puts -nonewline $sockb $bytes
        flush $sockb
        # puts stderr "$socka->$sockb [string length $bytes]"
    }    
}

proc accept {maison programme host port} {
    global pseudoEcran
    close $pseudoEcran
    fconfigure $programme -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fconfigure $maison -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $programme readable [list transmets $programme $maison]
    fileevent $maison readable [list transmets $maison $programme]
}


proc demarrePseudoEcranEtProgramme {maison} {
    global PROG env pseudoEcran

    set ok 0
    set ecran 10
    
    while {!$ok} {
        set err [catch {socket -server [list accept $maison] [expr {6000 + $ecran}]} pseudoEcran]
        if {$err} {
            puts stderr "écran $ecran déjà utilisé"
            incr ecran
            if {$ecran > 20} {
                puts stderr "pas assez d'écrans disponibles"
                exit 2
            }
        } else {
            set ok 1
        }
    }
    set env(DISPLAY) [info hostname]:$ecran
    puts stderr "Démarrage de $PROG affiché sur $env(DISPLAY)"
    exec $PROG -display $env(DISPLAY) &
}


proc doIt {proxy proxyPort maisonHost maisonPort} {
    set maison [socket $proxy $proxyPort]
    fileevent $maison readable [list readMaison1 $maison]
    fconfigure $maison -buffering line -blocking 0
    puts stderr "Connecté au proxy !"
    puts $maison "CONNECT $maisonHost:$maisonPort HTTP/1.1"
    puts $maison {}
    puts $maison {}
    puts $maison {}
    puts $maison blibli
    puts $maison bloblo
}

doIt proxy 8080 $argv 443
vwait eventLoop    
puts $eventLoop
