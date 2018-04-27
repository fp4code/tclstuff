proc sum {a b} {
    return [expr {$a+$b}]
}
proc pow3 {a} {
    return [expr {$a*$a*$a}]
}

proc timeit {txt cmd} {
    set num 100
    set count 1000
    set run {}
    for {set n 0} {$n < 100} {incr n} {
	lappend run $cmd
    }
    set val [uplevel 1 [list time \
			    [join $run {; }] $count]]
    set tmp [lreplace $val 0 0 \
		 [expr {[lindex $val 0]/(1.0*$num)}]]
    puts "$txt: [lrange $tmp 0 1]"
}

set a 1 ; set b 2
timeit "Tcl noop" {}
timeit "Tcl expr" {expr {1+2}}
timeit "Tcl vars" {expr {$a+$b}}
timeit "Tcl sum " {sum 1 2}
timeit "Tcl expr" {expr {2*2*2}}
timeit "Tcl vars" {expr {$b*$b*$b}}
timeit "Tcl pow3" {pow3 2}

package require critcl
critcl::cproc noop2 {} void {}
critcl::cproc add2 {int x int y} int {
    return x + y;
}
critcl::cproc cube2 {int x} int {
    return x * x * x;
}

timeit "Tcl noop2" {noop2}
timeit "Tcl add2" {add2 1 2}
timeit "Tcl cube2" {cube2 2}

