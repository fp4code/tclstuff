set VERBOSE 1

proc __doCommands__ {l s} {
    global callerSocket VERBOSE

    if {$VERBOSE} {
	puts "--- Server executing the following for socket $s:"
	puts $l
	puts "---"
    }
    set callerSocket $s
    if {[catch {uplevel #0 $l} msg]} {
	list error $msg
    } else {
	list success $msg
    }
}

proc __readAndExecute__ {s} {
    global command VERBOSE

    set l [gets $s]
    if {[string compare $l "--Marker--Marker--Marker--"] == 0} {
	if {[info exists command($s)]} {
	    puts $s [list error incomplete_command]
	}
	puts $s "--Marker--Marker--Marker--"
	return
    }
    if {[string compare $l ""] == 0} {
	if {[eof $s]} {
	    if {$VERBOSE} {
		puts "Server closing $s, eof from client"
	    }
	    close $s
	}
	return
    }
    append command($s) $l "\n"
    if {[info complete $command($s)]} {
	set cmds $command($s)
	unset command($s)
	set reponse  [__doCommands__ $cmds $s]
	puts "reponse = $reponse"
	puts $s $reponse
    }
    if {[eof $s]} {
	if {$VERBOSE} {
	    puts "Server closing $s, eof from client"
	}
	close $s
    }
}

proc __accept__ {s a p} {
    global VERBOSE

    if {$VERBOSE} {
	puts "Server accepts new connection from $a:$p on $s"
    }
    fileevent $s readable [list __readAndExecute__ $s]
    fconfigure $s -buffering line -translation crlf
}

set serverPort 2048

if {[catch {set serverSocket \
	[socket -server __accept__ $serverPort]} msg]} {
    puts "Server on $serverAddress:$serverPort cannot start: $msg"
} else {
    vwait __server_wait_variable__
}
