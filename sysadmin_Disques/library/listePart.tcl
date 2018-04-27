#!/usr/local/bin/tclsh

set REP "\04"

catch {exec /usr/sbin/format << $REP} lignes

set lignes [split $lignes \n]

set iligne 0
foreach l $lignes {
    incr iligne
    if {$l == "AVAILABLE DISK SELECTIONS:"}
        break
    }
}

set l [lrange $lignes $iligne 
Specify disk (enter its number): 
