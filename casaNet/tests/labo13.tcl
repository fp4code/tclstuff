#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo12.tcl
##
## connecte à maison13, à travers un proxy en cryptant
##
## ouvre un shell. Mélange stderr et stdout
##


set svcPort 443

package require tls
tls::init
proc printargs args {puts stderr "printargs $args"}

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror: $message"
    puts stderr [info level]
    puts stderr $errorInfo
}

proc readMaison1 {maison} {
    global eventLoop
    if [eof $maison] {
        close $maison
        set eventLoop "Maison is dead"
    } else {
        set l [gets $maison]
        puts stdout "Maison: \"$l\""
        if {[string match START* $l]} {
            fileevent $maison readable {}
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
        set eventLoop "Maison is dead"
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
    vwait eventLoop    
}

doIt proxy 8080 tif.lpn.prive 443
puts $eventLoop
