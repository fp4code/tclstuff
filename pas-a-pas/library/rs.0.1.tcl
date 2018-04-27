namespace eval rs {}

proc rs::init {} {
    variable m

    set m [open /dev/term/a w+]
    fconfigure $m -blocking 1
    fconfigure $m -buffering line
    fconfigure $m -encoding binary
    fconfigure $m -translation binary
    puts $m @1
}

proc rs::send {command} {
    variable m

    puts $m $command
    return [gets $m]
}

proc rs::move x {
    return [rs::send move(0,$x)]
}
proc rs::moving {} {
    return [rs::send moving()]
}
proc rs::halt {} {
    return [rs::send halt()]
}
proc rs::where {} {
    return [rs::send where(1)]
}

proc rs::zero {} {
    return [rs::send datum(1)]
}

proc rs::nmToStep {x} {
    return [expr {round($x*10)}]
}

proc rs::move_nm {x} {
    return [rs::move [rs::nmToStep $x]]
}

proc rs::ici_nm {x} {
    return [rs::send datum(1,[rs::nmToStep $x])]
}

rs::init

rs::ici_nm 500
rs::move_nm 700
rs::move_nm -30 (mini)


set nemarchepas {

    proc read_tty {tty} {
        if {[eof $tty]} {
            puts stderr "Stepper motor line is closed"
        } else {
            set lu [gets $tty]
            puts stdout "RS:$lu"
        }
    }
    
    fileevent $m readable [list read_tty $m]
    fconfigure $m -blocking 1
    fconfigure $m -blocking 0
}
