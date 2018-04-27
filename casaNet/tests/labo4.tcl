#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo4.tcl
##
## connecte � maison4 et affiche ce qui est re�u
##

set svcPort 443

# lecture de ce qui sort de la chaussette $sock et impression � l'�cran 
# la variable globale eventLoop est modifi�e si le serveur meurt
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
    # au moyen de "read_maison" lorsqu'il y a qqchose � lire
    fileevent $maison readable [list readMaison $maison]

    # configuration de la chaussette pour une communication flush�e ligne et non bloqu�e
    fconfigure $maison -buffering line -blocking 0

    # BlaBla 
    puts stderr "Connect� au proxy !"

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
