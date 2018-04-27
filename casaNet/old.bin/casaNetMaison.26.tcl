#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## maison26.tcl = maison25.tcl+ssl
##
## connecte à labo26.tcl
##
## inclus X11 multifenêtres, echo et get/put
##
##  Il faut créer les certificats par les commandes
##  % openssl req -out CA.pem -new -x509
##  % openssl genrsa -out server.key 1024
##  % openssl req -key server.key -new -out server.req
##  % cat > file.srl << EOF
##  36
##  EOF
##  % openssl x509 -req -in server.req -CA CA.pem -CAkey privkey.pem -CAserial file.srl -out server.pem
##


source casaNetCommun.26.tcl

proc errmsg {message} {
    puts stderr $message
}

proc psLu {} {
    global PSstat IN OUT TUNPS
    if {[info exists IN($PSstat(active))]} {
        # puts stderr "$PSstat(active) -> $IN($PSstat(active)) [string length $PSstat(data)]"
        puts -nonewline $IN($PSstat(active)) $PSstat(data)
        flush $IN($PSstat(active))
        return
    }
    switch $PSstat(active) [list "$TUNPS(stderr)" {
        puts stderr "STDERR = \"$PSstat(data)\""
    } "$TUNPS(stdout)" {
        puts stderr "STDOUT = \"$PSstat(data)\""
    } "$TUNPS(stdin)" {
        commande $PSstat(data)
    } "$TUNPS(put)" {
        set err [catch {putOnFile $PSstat(data)} message]
        if {$err} {
            puts stderr $message
        }
    } "$TUNPS(x11)" {    
        # demande X11
        set err [catch {socket localhost 6000} ecran]
        puts stderr "socket localhost 6000 : err=$err, ecran=$ecran"
        if {$err} {
            writeTunnel $TUNPS(stderr) $ecran
            writeTunnel $TUNPS(stdin) "_CLOSE_ sock$idSockProg"
            return
        }
        set err [catch {idSock $PSstat(data)} idSockProg]
        puts stderr "idsock : err=$err, idSockProg=$idSockProg"
        if {$err} {
            writeTunnel $TUNPS(stderr) $idSockProg
            writeTunnel $TUNPS(stdin) "_CLOSE_ sock$idSockProg"
            return
        }
        set IN($idSockProg) $ecran
        set OUT($ecran) $idSockProg
        fconfigure $ecran -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
        fileevent $ecran readable [list transmetsOut $ecran]
    }]
}
    
proc commande argum {
    global IN OUT
    set commande [lindex $argum 0]
    puts stderr "commande $argum ($commande)"
    switch $commande {
        "_CLOSE_" {
            set quoi [lindex $argum 1]
            puts stderr "_CLOSE_ $quoi"
            if {[info exists IN($quoi)]} {
                fileevent $IN($quoi) readable {}
                close $IN($quoi)
                unset OUT($IN($quoi))
                unset IN($quoi)
            }
        }
    }
}

proc accept {tunnel addr port} {
    global TUNNEL onlyOne MD5PASS
    close $onlyOne
    set TUNNEL $tunnel

    puts stderr "Accept from [fconfigure $TUNNEL -peername]"
    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $TUNNEL "HTTP/1.1 200 OK"
    puts $TUNNEL "Date: $date"
    puts $TUNNEL "Server: CNRS/LPN/Phydis maison"
    puts $TUNNEL {}
    puts $TUNNEL {}
    puts stderr "Accepted connection from $addr at $date"
    puts stderr "Tapez sur le clavier"
    puts $TUNNEL START
    flush $TUNNEL
    puts $TUNNEL $MD5PASS
    flush $TUNNEL
    # réécrire
    fconfigure $TUNNEL -blocking 1
    while {[set lu [gets $TUNNEL]] != "OK"} {
        puts stderr "Labo: \"$lu\""
        if {[eof $TUNNEL]} {
            return -code error "Labo is dead"
        }
    }
    puts stderr "Labo: \"$lu\""
    tls::import $TUNNEL -certfile server.pem -keyfile server.key \
            -ssl2 0 -ssl3 0 -tls1 1 -cipher EDH-RSA-DES-CBC3-SHA \
            -request 0 -require 0 -server 1 -command printargs
    tls::handshake $TUNNEL
    puts stderr "tls::status = [tls::status $TUNNEL]"

    fileevent $TUNNEL readable readTunnel
    fconfigure $TUNNEL -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    puts stderr "Connecté !"
    fconfigure stdin -blocking 0 -buffering line
    fileevent stdin readable sendLabo
}

proc sendLabo {} {
    global TUNNEL TUNPS
    set command [gets stdin]
    if {[lindex $command 0] == "put"} {
        foreach f [lrange $command 1 end] {
            putFile $f
        }
        return
    }
    writeTunnel $TUNPS(stdin) $command
    if {[eof stdin]} {
        puts stderr "mauvaise idée : EOF stdin"
    }
}

set PSstat(active) 0
set PSstat(isData) 0 ;# entête -> 0, data -> 1
set PSstat(size) 6
set PSstat(data) ""

set onlyOne [socket -server accept $sslPort]
vwait eventLoop
puts stderr $eventLoop
