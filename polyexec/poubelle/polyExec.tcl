#!/usr/local/bin/tclsh

package provide polyExec 0.1

namespace eval polyExec {}

set machines [list\
	u5mbeo u5nano\
	ufico ufico2 umbeo unano admin1\
	l2m\
	dao3\
	sbl3 cao1\
	s4fico s4nano s4sbl\
	cao2 dao1\
	mbe3 mbe4 nano3\
	fico6 fico7 fico9 hl\
	lithox1 mbe1 fib1 fico3 fico4 fico5\
	nano1\
	sbl1 sbl2]

set DIR /home/asdex/data/SF5/SF5.1/miroir_jluc/SF5.1.2/43_26
set PROG $DIR/hyper2.tcl

set fichiers [glob $DIR/*V]

set CMDS [list]

foreach f $fichiers {
    lappend CMDS "$PROG $f"
}

proc somethingToRead {machine channel} {
    # indispensable pour ne pas boucler sans fin (Cf. fileevent)
    if [eof $channel] {
	close $channel
	machineHasFinished $machine
    } else {
	set toto [gets $channel]
	puts "$machine says \"$toto\""
    }
}

proc machineHasFinished {machine} {
    global NUMBER_OF_PROCS
    incr NUMBER_OF_PROCS -1 
    launchNewOne $machine
}

proc launchProcess {machine cmd args} {
    global NUMBER_OF_PROCS
    # en cas d'erreur de lancement, lance error
    # ce que $cmd sort sur stderr est redirigé sur stdout
    puts stdout " [list $cmd $args]"
    set channel [open [concat [list "|rsh" $machine $cmd] $args [list 2>@ stdout]]]
    incr NUMBER_OF_PROCS 1
    fconfigure $channel -buffering line
    fileevent $channel readable "somethingToRead $machine $channel"
}

proc launchNewOne {machine} {
    global CMDS INDEX
    if {$INDEX < [llength $CMDS]} {
	puts -nonewline stdout "$INDEX on $machine"
	if [catch {eval [list launchProcess $machine] [lindex $CMDS $INDEX]}] {
	    puts stdout " ECHEC"
	} else {
	    puts stdout " OK"
	    incr INDEX
	}
    }
}

set NUMBER_OF_PROCS 0
set INDEX 0

foreach m $machines {
    launchNewOne $m
}

while {$NUMBER_OF_PROCS > 0} {
    vwait NUMBER_OF_PROCS
}

