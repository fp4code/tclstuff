#!/bin/sh
# The next line is executed by /bin/sh, but not tcl\
exec tclsh "$0" ${1+"$@"}


# $Id: sauvegardeServeur.tcl,v 1.4 2003/03/11 11:06:48 fab Exp $
set INFO(sauvagardeServeur.tcl) {
    23 janvier 2003 (FP) création
    27 janvier 2003 (FP) changement de philosophie :
     - md5sum dans 256 répertoires bodies/xx
     - databases dans databasesV1/yyyy.mm.dd

}

if {$argc != 1} {
    puts stderr "usage : $argv0 port"
    exit 1
}

package require fidev
package require alladin_md5

namespace eval sbb {
    global argv
    variable svcPort [lindex $argv 0]
    variable GLOB
    set GLOB(RDEST) /export/SAUVEGARDE/essaiBigBrother2

    variable LOCKTRANS ;# verrou sur la transaction d'un fichier identifé par sa md5sum
    variable CACHE {} ;# fichier dont le contenu est à reporter dans les databaseV1

}

# Handles the input from the client and  client shutdown
proc sbb::svcHandler {sock} {
    variable STATUS
    variable GLOB
    variable LOCKTRANS
    variable MD5DATABASE

    set l [gets $sock]    ;# get the client packet
    if {[eof $sock]} {    ;# client gone or finished
        sbb::protocolEnd $sock
    } else {
        set err [catch {sbb::doService $sock $l} message]
        if {$err} {
            global errorInfo
            puts stderr "service error : $message"
            puts stderr $errorInfo
            puts $sock  "service error : $message"
            puts $sock $errorInfo
            flush $sock
            sbb::protocolEnd $sock
        }
    }
}

proc sbb::protocolError {sock message} {
    puts stderr "protocol error : $message"
    puts $sock  "protocol error : $message"
    flush $sock
    sbb::protocolEnd $sock
}

proc sbb::protocolEnd {sock} {
    variable STATUS
    variable LOCKTRANS
    upvar \#0 TRANS$sock transaction
    puts stderr "$sock is closed"
    close $sock        ;# release the servers client channel
    unset STATUS($sock)
    if {[info exists transaction]} {
        if {[info exists transaction(md5sum)] && [info exists LOCKTRANS($transaction(md5sum))]} {
            unset LOCKTRANS($transaction(md5sum))
        }
        unset transaction
    }
    sbb::flushCache ;# Je ne pense pas que cela fasse du mal
}

proc sbb::gmtDay {instant} {
    return [clock format $instant -format %Y.%m.%d -gmt 1]
}


set INFO(sbb::databaseStatus) {
    renvoit selon status
    - inexistent          ->
    - existingClone       -> 
    - differentAttributes -> insertionTime prevSaver attributes
    - alreadySaved        -> insertionTime prevSaver
}

proc sbb::databaseStatus {md5sum &insertionTime size &prevSaver &attributes machine dir name} {
    upvar ${&insertionTime} insertionTime
    upvar ${&prevSaver} prevSaver
    upvar ${&attributes} attributes
    variable MD5DATABASE

    if {![info exists MD5DATABASE($md5sum)]} {
        return inexistent
    }
    set datalist $MD5DATABASE($md5sum)
    set n [llength $datalist]

    # taille [instant_d_insertion sauveur attributes machine repertoire nom]+
    if {$n % 6 != 1} {
        return -code error [list Corrupted database list $datalist]
    }
    if {[lindex $datalist 0] != $size} {
        puts stderr [list $md5sum datalist = $datalist size = $size]
        return exceptionalMd5sumEvent
    }

    set mtime [lindex $attributes end]
    if {$mtime > [clock seconds] + 10} {
        return mtimeInTheFuture
    }

    set status existingClone
    while {$n > 1} {
        incr n -1
        if {[lindex $datalist $n] != $name} {
            incr n -5
            continue
        }
        incr n -1
        if {[lindex $datalist $n] != $dir} {
            incr n -4
            continue
        }
        incr n -1
        if {[lindex $datalist $n] != $machine} {
            incr n -3
            continue
        }
        incr n -3
        set insertionTime [lindex $datalist $n]
        incr n
        set prevSaver [lindex $datalist $n]
        incr n
        if {[lindex $datalist $n] == $attributes} {
            set status alreadySaved
        } else {
            set attributes [lindex $datalist $n]
            set status differentAttributes
        }
        break
    }
    return $status
}

proc sbb::databaseInvalidate {saver md5sum insertionTime} {
    variable MD5DATABASE
    variable CACHE

    if {$CACHE == {}} {
        set CACHE [open cacheV1 w 0660]
    }

    set instant [clock seconds]
    set attente [expr {$insertionTime - $instant}]
    while {$attente >= 0} {
        if {$attente > 10} {
            return -code error "Hardly desynchronised database, we are at $instant, there is datas inserted at $insertionTime"
        }
        puts stderr "A little bit desynchronised database, waiting $attente s"  
        after [expr {$attente * 1000 + 1000}]
        set instant [clock seconds]
        set attente [expr {$insertionTime - $instant}]
    }

    set day [sbb::gmtDay $insertionTime]

    set n [llength $MD5DATABASE($md5sum)]
    
    for {incr n -6} {$n >= 1} {incr n -6} {
        if {[lindex $MD5DATABASE($md5sum) $n] == $insertionTime} break
    }
    if {$n < 0} {
        return -code error [list database error, insertionTime $insertionTime not find in $MD5DATABASE($md5sum) $n]
    }

    set MD5DATABASE($md5sum) [lreplace $MD5DATABASE($md5sum) $n [expr {$n + 6}]]
    puts $CACHE [list $md5sum - $instant $saver $insertionTime]

    return $instant
}

proc sbb::databaseChangeAttributes {saver md5sum insertionTime attributes} {
    variable MD5DATABASE
    variable CACHE

    if {$CACHE == {}} {
        set CACHE [open cacheV1 w 0660]
    }

    set instant [clock seconds]
    set instantMoins1 [expr {$instant - 1}]
    set attente [expr {$insertionTime - $instantMoins1}] ;# Moins1 pour garantir Invalidate une seconde avant
    while {$attente >= 0} {
        if {$attente > 10} {
            return -code error "Hardly desynchronised database, we are at $instant, there is datas inserted at $insertionTime"
        }
        puts stderr "A little bit desynchronised database, waiting $attente s"  
        after [expr {$attente * 1000 + 1000}]
        set instant [clock seconds]
        set instantMoins1 [expr {$instant - 1}]
        set attente [expr {$insertionTime - $instantMoins1}] ;# Moins1 pour garantir Invalidate une seconde avant
   }

    set day [sbb::gmtDay $insertionTime]

    set n [llength $MD5DATABASE($md5sum)]
    
    for {incr n -6} {$n >= 1} {incr n -6} {
        if {[lindex $MD5DATABASE($md5sum) $n] == $insertionTime} break
    }
    if {$n < 0} {
        return -code error [list database error, insertionTime $insertionTime not find in $MD5DATABASE($md5sum) $n]
    }

    set MD5DATABASE($md5sum) [lreplace $MD5DATABASE($md5sum) $n [expr {$n + 2}] $instantMoins1 $saver $attributes]
    set newdata [lrange $MD5DATABASE($md5sum) $n [expr {$n + 5}]]
    puts $CACHE [list $md5sum - $instantMoins1 $saver $insertionTime]
    puts $CACHE [concat [list $md5sum + $instant $saver $attributes] [lrange $newdata 3 5]]
    return $instant
}

proc sbb::databaseClone {saver md5sum attributes machine dir name} {
    variable MD5DATABASE
    variable CACHE

    if {$CACHE == {}} {
        set CACHE [open cacheV1 w 0660]
    }
    
    set lastInsertionTime 0

    set n [llength $MD5DATABASE($md5sum)]
    
    for {incr n -6} {$n >= 1} {incr n -6} {
        if {[lindex $MD5DATABASE($md5sum) $n] > $lastInsertionTime} {
            set lastInsertionTime [lindex $MD5DATABASE($md5sum) $n]
        }
    }
    
    set instant [clock seconds]
    set attente [expr {$lastInsertionTime - $instant}]
    # j'admets les clone dans la même seconde
    while {$attente > 0} {
        if {$attente > 10} {
            return -code error "Hardly desynchronised database, we are at $instant, there is datas inserted at $lastInsertionTime"
        }
        puts stderr "A little bit desynchronised database, waiting $attente s"  
        after [expr {$attente * 1000 + 1000}]
        set instant [clock seconds]
        set attente [expr {$lastInsertionTime - $instant}]
    }

    lappend MD5DATABASE($md5sum) $instant $saver $attributes $machine $dir $name
    puts $CACHE [list $md5sum + $instant $saver [lindex $MD5DATABASE($md5sum) 0] $attributes $machine $dir $name]
    return $instant
}

proc sbb::archiveFile {sock saver md5sum size attributes machine dir name &message} {
    variable GLOB
    upvar ${&message} message

    set fbb [open unverified.${md5sum} w 0440]
    set handle [alladin_md5::init]

    fileevent $sock readable {}
    fconfigure $sock -blocking 1 -translation binary -buffering full -buffersize 4096

    set reste $size

    while {$reste >= 4096} {
        set buf [read $sock 4096]
        alladin_md5::append $handle $buf
        puts -nonewline $fbb $buf
        incr reste -4096
    }

    if {$size != 0} {
        set buf [read $sock $reste]
        alladin_md5::append $handle $buf
        puts -nonewline $fbb $buf
    }

    fileevent $sock readable [list sbb::svcHandler $sock]
    fconfigure $sock  -translation auto -buffering line -blocking 0

    close $fbb
    set bstring [alladin_md5::finish $handle]
    binary scan $bstring H32 ret

    if {$ret != $md5sum} {
        # puts stderr "unverified.${md5sum} NOT DELETED"
        file delete unverified.${md5sum}
        set message "FILE MD5SUM ERROR BYE"
        return 0
    }
    
    set mtime [lindex $attributes end]

    set begin [string range $md5sum 0 1]
    set dbodies [file join bodies $begin]
#    set day [sbb::gmtDay $mtime]
    if {![file exists $dbodies]} {
        puts stderr "mkdir $dbodies"
        file mkdir $dbodies
        file attributes $dbodies -group p10admin -permissions 040775
    }
    file rename unverified.${md5sum} [file join $dbodies $md5sum]
    set instant [sbb::databaseNewArchive $saver $md5sum $size $attributes $machine $dir $name message]
    if {$instant == 0} {
        file delete [file join $dbodies $md5sum]
        return 0
    }
    return $instant
}

proc sbb::databaseNewArchive {saver md5sum size attributes machine dir name &message} {
    variable MD5DATABASE
    variable CACHE
    upvar ${&message} message

    if {[info exists MD5DATABASE($md5sum)]} {
        return -code error "Database Error"
    }

    if {$CACHE == {}} {
        set CACHE [open cacheV1 w 0660]
    }
    set instant [clock seconds]
    set mtime [lindex $attributes end]

    set attente [expr {$mtime - $instant}]
    while {$attente >= 0} {
        if {$attente > 11} {
            set message "Hardly desynchronised file, we are at $instant, file mtime is $mtime BYE"
            return 0
        }
        puts stderr "A little bit desynchronised file, waiting $attente s"  
        after [expr {$attente * 1000 + 1000}]
        set instant [clock seconds]
        set attente [expr {$mtime - $instant}]
    }
    
    set MD5DATABASE($md5sum) [list $size $instant $saver $attributes $machine $dir $name]
    puts $CACHE [list $md5sum + $instant $saver $size $attributes $machine $dir $name]

    return $instant
}

proc sbb::flushCache {} {
    variable CACHE

    if {$CACHE != {}} {
        close $CACHE
        set CACHE {}
    }
    if {![file exists cacheV1]} {
        return
    }
    if {![file exists databasesV1]} {
        file mkdir databasesV1
        file attributes databasesV1 -group p10admin -permissions 040775
    }
    
    set cache [open cacheV1 r]
    set lines [split [read -nonewline $cache] \n]
    close $cache
    foreach l $lines {
        set type [lindex $l 1]
        switch -- $type {
            + {
                set md5sum [lindex $l 0]
                set insertionTime [lindex $l 2]
                set attributes [lindex $l 5]
                set mtime [lindex $attributes end]
                set day [sbb::gmtDay $mtime]
                # puts stderr "$l $mtime $day"
                lappend V1($day) $l
                set SEEN($md5sum,$insertionTime) $day
            }
            - {               
                lappend V1($SEEN($md5sum,[lindex $l 4])) $l
            }
            default {
                return -code error "Corrupted database cacheV1"
            }
        }
    }
            
    if {[info exists V1]} {
        foreach day [array names V1] {
            set lines $V1($day)
            set year  [string range $day 0 3]
            set databasesV1_year [file join databasesV1 $year]
            if {![file exists ${databasesV1_year}]} {
                file mkdir ${databasesV1_year}
            }
            set databaseV1 [open [file join ${databasesV1_year} $day] a]
            foreach l $lines {
                puts $databaseV1 $l
            }
            close $databaseV1
        }
    }
    file delete cacheV1
}    

proc sbb::readDatabaseV1 {day} {
    variable MD5DATABASE
    
    set year [string range $day 0 3]
    set h [open [file join databasesV1 $year $day] r]
    set lines [split [read -nonewline $h] \n]
    close $h

    # Lecture à l'envers pour voir les - avant les +

    set i [llength $lines]
    for {incr i -1} {$i >= 0} {incr i -1} {
        set l [lindex $lines $i]
        set type [lindex $l 1]
        switch -- $type {
            + {
                set md5sum [lindex $l 0]
                set instant [lindex $l 2]
                if {[info exists invalidated($md5sum,$instant)]} {
                    break
                }
                if {![info exists MD5DATABASE($md5sum)]} {
                    set MD5DATABASE($md5sum) [list [lindex $l 4]]
                }
                lappend MD5DATABASE($md5sum) $instant [lindex $l 3] [lindex $l 5] [lindex $l 6] [lindex $l 7] [lindex $l 8]
            }
            - {
                set md5sum [lindex $l 0]
                set instant [lindex $l 2]
                set INVALIDATED($md5sum,$instant) {}
            }
            default {
                return -code error "column 2 is not \"+\" or \"-\""
            }
        }
    }
}

proc sbb::doService {sock l} {
    variable STATUS
    variable LOCKTRANS
    upvar \#0 TRANS$sock transaction

    switch $STATUS($sock) {
        initial {
            if {![regexp {^HELLO I'M (.+) ON (.+)$} $l tout transaction(saver) machine]} {
                sbb::protocolError $sock "\"$l\" in sbb::doService/initial"
                return
            }
            puts stderr "ATTENTION, ${transaction(saver)}@$machine sans contrôle actuellement"
            puts $sock "HELLO ${transaction(saver)}@${machine}"
            flush $sock
            set STATUS($sock) hello
        }
        hello {
            # Pour être certain d'avoir une bonne liste
            # "eval list $l" pourrait être catastrophique avec l dt genre "[file delete ...]"
            if {[catch {lindex $l end} li]} {
                sbb::protocolError $sock "\"$l\" -> \"$li\" in sbb::doService/hello"
                break
            }
            set ll $l
            switch [lindex $ll 0] {
                STATUS {
                    if {[llength $ll] != 8 || [lrange $ll 0 1] != "STATUS OF"} {
                        sbb::protocolError $sock "\"$ll\" in sbb::doService/hello"
                        break
                    }
                    foreach {
                        transaction(md5sum) transaction(size)
                        transaction(attributes)
                        transaction(machine) transaction(dir) transaction(name)
                    } [lrange $ll 2 end] break
                    if {[info exists LOCKTRANS($transaction(md5sum))]} {
                        set lockid  $LOCKTRANS($transaction(md5sum))
                        set socklock [lindex $lockid 0]
                        if {$socklock != $sock} {
                            puts $sock "TRANSACTION LOCKED ON $transaction(md5sum) BY [lindex $lockid 1] AT [lindex $lockid 2] BYE"
                            flush $sock
                            break
                        }
                        unset lockid socklock
                    }
                    set attributes $transaction(attributes)
                    set status [sbb::databaseStatus\
                                    $transaction(md5sum)\
                                    transaction(insertionTime) $transaction(size) prevSaver attributes\
                                    $transaction(machine) $transaction(dir) $transaction(name)]
                    switch $status {
                        alreadySaved {
                            puts $sock [list ALREADY SAVED AT $transaction(insertionTime) BY $prevSaver]
                            flush $sock
                            set STATUS($sock) alreadySaved
                            set LOCKTRANS($transaction(md5sum)) [list $sock ${transaction(saver)} [clock seconds]]
                        }
                        differentAttributes {
                            puts $sock [list DIFFERENT ATTRIBUTES $attributes AT $transaction(insertionTime) BY $prevSaver]
                            flush $sock
                            set STATUS($sock) diffAttr
                            set LOCKTRANS($transaction(md5sum)) [list $sock ${transaction(saver)} [clock seconds]]
                        }
                        existingClone {
                            puts $sock "EXISTING CLONE"
                            flush $sock
                            set STATUS($sock) existingClone
                            set LOCKTRANS($transaction(md5sum)) [list $sock ${transaction(saver)} [clock seconds]]
                        }
                        inexistent {
                            puts $sock "INEXISTENT"
                            flush $sock
                            set STATUS($sock) inexistent
                            set LOCKTRANS($transaction(md5sum)) [list $sock ${transaction(saver)} [clock seconds]]
                        }
                        exceptionalMd5sumEvent {
                            puts $sock "DIFFERENT CONTENT ( EXCEPTIONAL MD5SUM EVENT ) BYE"
                            flush $sock
                            set STATUS($sock) hello
                        }
                        mtimeInTheFuture {
                            # Rejeter cela permet de garantir
                            # que lors du vidage de cacheV1, le - est dans un répertoire de $day postérieur ou = au répertoire du +
                            # s'il nous prenait l'idée de ne pas mettre les - dans le répertoire des + 
                            puts $sock "FILE TIME IN THE FUTURE OF GMT [clock format [clock seconds] -format "%Y.%m.%d_%H:%M:%S"] BYE"
                            flush $sock
                            set STATUS($sock) hello
                        }
                        default {
                            return -code error "PROGRAMMING ERROR in sbb::doService/hello, status=\"$status\""
                        }
                    }
                }
                BYE {
                    puts $sock "BYEBYE"
                    sbb::protocolEnd $sock
                }
                default {
                    sbb::protocolError $sock "\"$ll\" in sbb::doService/hello"
               }
            }
        }
        alreadySaved {
            switch $l {
                OK {
                    puts $sock "BYE"
                    flush $sock
                    set STATUS($sock) hello
                    unset LOCKTRANS($transaction(md5sum))
                }
                INVALIDATE {
                    set instant [sbb::databaseInvalidate $transaction(saver) $transaction(md5sum) $transaction(insertionTime)]
                    puts $sock "INVALIDATED AT $instant BYE"
                    flush $sock
                    set STATUS($sock) hello                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                default {
                    sbb::protocolError $sock "\"$l\" in sbb::doService/diffAttr"
                    return
                }
            }
        }
        diffAttr {
            switch $l {
                OK {
                    puts $sock "BYE"
                    flush $sock
                    set STATUS($sock) hello
                    unset LOCKTRANS($transaction(md5sum))
                }
                INVALIDATE {
                    set instant [sbb::databaseInvalidate $transaction(saver) $transaction(md5sum) $transaction(insertionTime)]
                    puts $sock "INVALIDATED AT $instant BYE"
                    flush $sock
                    set STATUS($sock) hello                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                CHANGE {
                    set instant [sbb::databaseChangeAttributes\
                                     $transaction(saver) $transaction(md5sum) $transaction(insertionTime)\
                                     $transaction(attributes)]
                    puts $sock "CHANGED AT $instant BYE"
                    flush $sock
                    set STATUS($sock) hello                                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                default {
                    sbb::protocolError $sock "\"$l\" in sbb::doService/diffAttr"
                    return
                }
            }
        }
        existingClone {
            switch $l {
                OK {
                    puts $sock "BYE"
                    flush $sock
                    set STATUS($sock) hello
                    unset LOCKTRANS($transaction(md5sum))              
                }
                CLONE {
                    set instant [sbb::databaseClone\
                                     $transaction(saver) $transaction(md5sum)\
                                     $transaction(attributes)\
                                     $transaction(machine) $transaction(dir) $transaction(name)]
                    puts $sock "CLONED AT $instant BYE"
                    flush $sock
                    set STATUS($sock) hello                                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                default {
                    sbb::protocolError $sock "\"$l\" in sbb::doService/existingClone"
                    return
                }
            }
        }
        inexistent {
            switch $l {
                OK {
                    puts $sock "BYE"
                    flush $sock
                    set STATUS($sock) hello                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                ARCHIVE {
                    set instant [sbb::archiveFile $sock\
                                     $transaction(saver) $transaction(md5sum) $transaction(size)\
                                     $transaction(attributes)\
                                     $transaction(machine) $transaction(dir) $transaction(name) message]
                    if {$instant == 0} {
                        puts $sock $message
                    } else {
                        puts $sock "ARCHIVED AT $instant BYE"
                    }
                    flush $sock
                    set STATUS($sock) hello                    
                    unset LOCKTRANS($transaction(md5sum))
                }
                default {
                    sbb::protocolError $sock "\"$l\" in sbb::doService/inexistent"
                }
            }
        }
        default {
            return -code error "PROGRAMMING ERROR in sbb::doService, STATUS($sock)=\"$STATUS($sock)\""
        }
    }
}

proc sbb::acceptProc {sock addr port} {
  
  variable STATUS

  set instant [clock seconds]
  set dada [clock format $instant -format {%Y/%m/%d %H:%M:%S}]
  puts stderr "Voici la date : $dada"

  # log the connection
  puts stderr "Accepted connection from $addr at $dada"

  # construction d'un identificateur non ambigu pour la connexion
  set STATUS($sock) initial
  
  # à chaque fois qu'il y a qqchose à lire, on appelle "sbb::svcHandler $peerRef $sock"
  fileevent $sock readable [list sbb::svcHandler $sock]

  # Read client input in lines, disable blocking I/O
  fconfigure $sock -buffering line -blocking 0 -translation auto -encoding binary
}

if {0} {
    set sbb::GLOB(RDEST) /export/SAUVEGARDE/essaiBigBrother2
    cd /export/SAUVEGARDE/essaiBigBrother2
    set gg [glob -nocomplain unverified.* cacheV1 200*/* 19*/*]
    foreach f $gg {file delete $f}
}

puts stderr "TESTER une connexion en timeout"
puts stderr "ENRICHIR le protocole de CLONE pour contrôler quelques octets"


set rien {
puts stderr "HELLO I'M fab ON yoko"
puts stderr "STATUS OF d41d8cd98f00b204e9800998ecf8427e 0 {fab fab 00644 1038502699} yoko /home/fab/Z vide"
puts stderr "ARCHIVE"
puts stderr "STATUS OF d41d8cd98f00b204e9800998ecf8427e 0 {fab fab 00644 1038502699} yoko /home/fab/Z vide"
puts stderr "OK"
puts stderr "STATUS OF d41d8cd98f00b204e9800998ecf8427e 0 {fab fab 00644 1999999999} yoko /home/fab/Z vide"
puts stderr "STATUS OF d41d8cd98f00b204e9800998ecf8427e 0 {fab fab 00644 1043429361} yoko /home/fab/Z vide"
puts stderr "CHANGE"
puts stderr "BYE"
}

cd $sbb::GLOB(RDEST)

set lock [glob -nocomplain LOCK_*]
if {$lock != {}} {
    foreach {dummy host pid} [split $lock _] break
    puts stderr "Locked by process $pid on $host, bye !"
    exit 1
}
set lock LOCK_[info hostname]_[pid]
close [open $lock w]  

if {[file exists cacheV1]} {
    puts stderr "flushing cache"
    sbb::flushCache
}

set year {}
foreach f [lsort -increasing [glob -nocomplain databasesV1/*/*]] {
    # puts $f
    set newyear [file tail [file dirname $f]]
    if {$newyear != $year} {
        set year $newyear
        puts $year
    }
    if {[catch {sbb::readDatabaseV1 [file tail $f]} message]} {
        puts stderr "Corrupted database $f : $message"
        puts stderr "$errorInfo"
        exit 2
    }
}
if {![info exists sbb::MD5DATABASE]} {
    set nlu 0
} else {
    set nlu [llength [array names sbb::MD5DATABASE]]
    foreach md5sum [array names sbb::MD5DATABASE] {
        set referenced($md5sum) {}
    }
}

puts stderr "Lu $nlu référence(s)."

set unrefs [list]
foreach df [glob -nocomplain bodies/*/*] {
    set md5sum [file tail $df]
    if {[info exists referenced($md5sum)]} {
        unset referenced($md5sum)
    } else {
        lappend unrefs $md5sum
        set sbb::MD5DATABASE($md5sum) [file size $df]
    }
}

# catch {parray sbb::MD5DATABASE}

if {[info exists referenced] && [llength [array names referenced]] != 0} {
    puts stderr "ERROR, THERE IS [llength [array names referenced]] REFERENCES WITHOUT BODY"
    puts stderr "   ([lrange [array names referenced] 0 3] ...)"
}

if {$unrefs != {}} {
    puts stderr "WARNING, THERE IS [llength $unrefs] BODIES WITHOUT REFERENCE"
    puts stderr "   ([lrange $unrefs 0 3]] ...)"
}


puts stderr "TOUT LU !"

# catch {parray sbb::MD5DATABASE}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.
socket -server sbb::acceptProc $sbb::svcPort
vwait events    ;# handle events till variable events is set

# Trouver le moyen d'interrompre proprement (Ctrl/C ou autre)

cd $GLOB(RDEST)
file delete $lock
