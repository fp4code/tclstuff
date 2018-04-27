#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo5.tcl
##
## connecte à maison5 et affiche ce qui est reçu
##
## ouvre un shell. Mélange stderr et stdout
##

set svcPort 443

# lecture de ce qui sort de la chaussette $sock et impression à l'écran 
# la variable globale eventLoop est modifiée si le serveur meurt
proc readMaison1 {maison} {
    global eventLoop
    if [eof $maison] {
        close $maison                        ;# close the socket client connection
        set eventLoop "Maison is dead"     ;# terminate the vwait (eventloop)
    } else {
        set l [gets $maison]
        puts stdout "Maison: \"$l\""
        if {[string match START* $l]} {
            set programme [open "|/bin/csh 2>@stdout" r+]
            fconfigure $programme -buffering line -blocking 0
            fileevent $programme readable [list readProgramme $programme $maison]
            fileevent $maison readable [list readMaison2 $programme $maison]
        }
    }
}

proc readMaison2 {programme maison} {
    global eventLoop
    if [eof $maison] {
        close $maison                       
        close $programme                      
        set eventLoop "Maison is dead"     ;# terminate the vwait (eventloop)
    } else {
        set l [gets $maison]
        puts stdout "Maison->Programme: \"$l\""
        puts $programme $l
    }
}

proc readProgramme {programme maison} {
    global eventLoop
    if [eof $programme] {
        close $programme                       
        close $maison                       
        set eventLoop "Programme is dead"
    } else {
        set l [gets $programme]
        puts stdout "Programme->Maison: \"$l\""
        puts $maison $l
    }
}


#
proc doIt {proxy proxyPort maisonHost maisonPort} {
    
    # demande de connexion (synchrone) au serveur
    set maison [socket $proxy $proxyPort]

    # configuration de la chaussette demandant de lire
    # au moyen de "read_maison" lorsqu'il y a qqchose à lire
    fileevent $maison readable [list readMaison1 $maison]

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
