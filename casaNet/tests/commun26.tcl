#
# procédures communes à maison26.tcl et à labo26.tcl
#

set sslPort 443
package require tls
tls::init

package require md5
puts -nonewline stderr "mot de passe casaNet : "
set pass [gets stdin]
set MD5PASS [md5::md5 $pass]

# tous >= 1000
set TUNPS(stdin) 1000
set TUNPS(stdout) 1001
set TUNPS(stderr) 1002
set TUNPS(put)    1003
set TUNPS(x11)    1011

proc bgerror {message} {
    global errorInfo
    errmsg $errorInfo
}

proc printargs args {puts stderr "printargs $args"}

proc readTunnel {} {
    global PSstat TUNNEL eventLoop
    set active $PSstat(active)
    set size $PSstat(size)
    if {$size > 4096} {
        set size 4096
    }
    set bytes [read $TUNNEL $size]
    set len [string length $bytes]
    if {$len != 0} {
        append PSstat(data) $bytes
        set PSstat(size) [expr {$PSstat(size) - $len}]
        if {$PSstat(size) == 0} {
            after 0 psDemiLu
        }
    }
    if {[eof $TUNNEL]} {
        fileevent $TUNNEL readable {}
        close $TUNNEL
        set eventLoop "$TUNNEL is dead"
    }
}

proc writeTunnel {ps data} {
    global TUNNEL
    puts -nonewline $TUNNEL [binary format S $ps]
    puts -nonewline $TUNNEL [binary format I [string length $data]]
    puts -nonewline $TUNNEL $data
    flush $TUNNEL
}

proc psDemiLu {} {
    global PSstat
    set active PSstat(active)
    if {$PSstat(isData)} {
        psLu
        set PSstat(active) 0
        set PSstat(isData) 0
        set PSstat(size) 6
        set PSstat(data) ""
    } else {
        binary scan $PSstat(data) SI active size
        set PSstat(active) $active
        set PSstat(isData) 1
        set PSstat(size) $size
        set PSstat(data) ""
    }
}

proc idSock {sock} {
    global TUNPS
    set idSock [string range $sock 4 end]
    if {$idSock >= 1000} {
        return -code error "sock ID >= 1000"
    }
    return $idSock
}

# transfert vraiment trivial
proc putOnFile {data} {
    global PUT
    if {[string length $data] < 5} {
        return -code error "putOnFile data length < 5"
    }
    set commande [string index $data 0]
    binary scan [string range $data 1 4] I putTag
    set data [string range $data 5 end]
    switch $commande {
        B {
            set name $data
            set localName [file join ~ Z [file tail $name]]
            errmsg "$name -> $localName"
            if [catch {open $localName w} PUT($putTag)] {
                errmsg $PUT($putTag)
                set PUT($putTag) {}
            } else {
                fconfigure $PUT($putTag) -translation binary
            }
        }
        C {
            if {$PUT($putTag) != {}} {
                puts -nonewline $PUT($putTag) $data
            }
            # A LIMITER À MAISON
            puts -nonewline stderr # 
        }
        E {
            if {$PUT($putTag) != {}} {
                close $PUT($putTag)
                errmsg \nDONE
            } else {
                errmsg "\nNOT DONE"
            }
            unset PUT($putTag)
        }
        default {
            errmsg "putOnFile bad subcommand \"$commande\""
        }
    }
}

# IL FAUDRAIT RECYCLER PUTTAG
set PUTTAG 0
proc putFile fichier {
    global TUNPS PUTTAG DATAPUT
    incr PUTTAG
    set putTag [binary format I $PUTTAG]  
    set err [catch {open $fichier r} f]
    if {$err} {
        writeTunnel $TUNPS(stderr) "$f"
        return 1
    }
    fconfigure $f -translation binary
    set DATAPUT($putTag) [read $f]
    puts stderr "putFile $fichier"
    writeTunnel $TUNPS(put) B$putTag$fichier
    set begin 0
    set end 3999
    set length [string length $DATAPUT($putTag)]
    putFileB $putTag $length $begin $end
}

proc putFileB {putTag length begin end} {
    global TUNPS DATAPUT
    if {$begin < $length} {
        if {$end >= $length} {
            set end [expr {$length-1}]
        }
        writeTunnel $TUNPS(put) C${putTag}[string range $DATAPUT($putTag) $begin $end]
        incr begin 4000
        incr end 4000
        # Passer la chaine $DATAPUT($putTag) est catastrophique
        # parce que after calcule la forme chaine de la liste (tcl8.3) !
        after idle [list putFileB $putTag $length $begin $end]
    } else {
        writeTunnel $TUNPS(put) E$putTag
    }
}
proc transmetsOut {sock} {
    global OUT TUNPS
    set bytes [read $sock 4096]
    set len [string length $bytes]
    if {$len != 0} {
        # puts stderr "$len on OUT($sock) = $OUT($sock)"
        writeTunnel $OUT($sock) $bytes
    }
    if {[eof $sock]} {
        puts stderr "eof $sock"
        writeTunnel $TUNPS(stdin) "_CLOSE_ $OUT($sock)"
        fileevent $sock readable {}
        close $sock
    }   
}
