#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo4.tcl
##
## connecte à maison4 et affiche ce qui est reçu
##

set svcPort 443

# lecture de ce qui sort de la chaussette $sock et impression à l'écran 
# la variable globale eventLoop est modifiée si le serveur meurt
proc readMaison {maison} {
    global eventLoop
    if [eof $maison] {
        close $maison                        ;# close the socket client connection
        set eventLoop "Maison is dead"     ;# terminate the vwait (eventloop)
    } else {
        set l [gets $maison]
        puts stdout "Maison: \"$l\""
    }
}

#
proc doIt {proxy proxyPort maisonHost maisonPort} {
    
    # demande de connexion (synchrone) au serveur
    set maison [socket $proxy $proxyPort]

    # configuration de la chaussette demandant de lire
    # au moyen de "read_maison" lorsqu'il y a qqchose à lire
    fileevent $maison readable [list readMaison $maison]

    # configuration de la chaussette pour une communication flushée ligne et non bloquée
    fconfigure $maison -buffering line -blocking 0

    # BlaBla 
    puts stderr "Connecté au proxy !"

    puts $maison "CONNECT $maisonHost:$maisonPort HTTP/1.1"
    puts $maison {}
    puts $maison {}
    puts $maison {}
    puts $maison blibli
    puts $maison bloblo

    # wait for and handle events...
    vwait eventLoop
    
}

doIt proxy 8080 tif.lpn.prive 443
puts $eventLoop
