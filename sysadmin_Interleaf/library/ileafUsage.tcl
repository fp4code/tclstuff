#!/usr/local/bin/tclsh

# 1999/09/22 (FP) le tri n'est plus fait par un "| grep"
#                 mais à l'intérieur de getProc. Cela évite de lancer un processus de plus
#                 et de gérer le retour "1" de la part de "grep"

set LOG stdout

proc writeLog {message} {
    global LOG
    puts $LOG $message
    flush $LOG
}

proc getproc {machine} {
    if {[info hostname] == $machine} {
	set commande {exec ps -eo {pid user stime time comm}}
    } else {
	set commande {exec rsh $machine ps -eo {"pid user stime time comm"}}
    }
    if {[catch $commande resul]} {
	writeLog $resul
	return
    }
    set ret [list]
    foreach l [split $resul \n] {
	if {[lindex $l 4] == "/interleaf/ileaf5/sun4os5/bin/ileaf"} {
	    lappend ret [concat ${machine}:[lindex $l 0] [lrange $l 1 end]]
	}
    }
    return $ret
}

proc ini {} {
    global TIME UINFO
    set procs [concat [getproc l2m] [getproc u5fico]]
    foreach p $procs {
	set pid [lindex $p 0]
	set user [lindex $p 1]
	set debut [lindex $p 2]
	if {![catch {clock scan [split $debut _]} debut]} {
	    set debut [list [clock format $debut -format "%Y/%m/%d"] [clock format $debut -format "%H:%M:%S"]]
	} else {
	    writeLog "ERREUR cannot \"clock scan $debut\""
	    set debut [list 1999/01/01 00:00:00]
	}
	set userinfo [concat $debut $user]
	set TIME($pid) [lindex $p 3]
	set UINFO($pid) $userinfo
    }    
    foreach pid [sortedPids] {
	writeLog "ETAT  [format %-28s $UINFO($pid)] [format %8s $TIME($pid)] $pid"
    }
}


proc new {} {
    global TIME UINFO
    set instant [clock seconds]
    writeLog "CHECK [list [clock format $instant -format "%Y/%m/%d"] [clock format $instant -format "%H:%M:%S"]]"
    set procs [concat [getproc l2m] [getproc u5fico]]
    foreach p $procs {
	set pid [lindex $p 0]
	set user [lindex $p 1]
	set debut [lindex $p 2]
	if {![catch {clock scan [split $debut _]} debut]} {
	    set debut [list [clock format $debut -format "%Y/%m/%d"] [clock format $debut -format "%H:%M:%S"]]
	} else {
	    writeLog "ERREUR cannot \"clock scan $debut\""
	    set debut [list 1999/01/01 00:00:00]
	}
	set userinfo [concat $debut $user]
	set NTIME($pid) [lindex $p 3]
	set NUINFO($pid) $userinfo
    }
    foreach pid [sortedPids] {
	if {![info exists NUINFO($pid)]} {
	    writeLog "OUT   [format %-28s $UINFO($pid)] [format %8s $TIME($pid)] $pid"
	    unset UINFO($pid) TIME($pid)
	} elseif {$NTIME($pid) != $TIME($pid)} {
	    set TIME($pid) $NTIME($pid)
	    writeLog "ACTIF [format %-28s $UINFO($pid)] [format %8s $TIME($pid)] $pid"
	}
    }
    foreach pid [array names NUINFO] {
	if {![info exists UINFO($pid)]} {
	    set UINFO($pid) $NUINFO($pid)
	    set TIME($pid) $NTIME($pid)
	    writeLog "NEW   [format %-28s $UINFO($pid)] [format %8s $TIME($pid)] $pid"
	} 	
    }
}


proc sortPidsCommand {p1 p2} {
    global UINFO
    return [string compare $UINFO($p1) $UINFO($p2)]
}

proc sortedPids {} {
    global UINFO
    return [lsort -command sortPidsCommand [array names UINFO]]
}


proc aNew {} {
    global DELAI
    new
    after $DELAI aNew
}

if {$argc != 1 || [catch {expr {$argv*1000}} DELAI]} {
    puts stderr "syntaxe: $argv0 intervalle_en_secondes"
    exit 1
}

close stdin
ini
aNew
vwait dummy

