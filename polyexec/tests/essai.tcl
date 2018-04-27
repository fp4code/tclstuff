#!/usr/local/bin/tclsh

package require fidev
package require polyexec 0.1

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

set cmds [list]
foreach f $fichiers {
    lappend cmds "$PROG $f"
}

polyexec::launchAll $machines $cmds

