package provide polyexec 0.1

namespace eval polyexec {}

proc bgerror {message} {
    global errorInfo
    puts stderr {}
    puts stderr "ERREUR : $message"
    puts stderr $errorInfo
    puts stderr {}
}


set HELP(polyexec::somethingToRead) {
    commande appelée à chaque fois que le programme écrit une ligne
}

proc polyexec::somethingToRead {globArray machine channel} {
    upvar #0 $globArray glob
    # détection de "eof" indispensable pour ne pas boucler sans fin (Cf. fileevent)
    # on en profite pour relancer un nouveau programme
    if {[eof $channel]} {
	catch {close $channel}
	incr glob(nproc)  -1
	polyexec::launchNewOne $globArray $machine 
    } else {
	set blabla [gets $channel]
	puts "[format %10s $machine] says \"$blabla\""
    }
}

proc polyexec::launchProcess {globArray machine cmd args} {
    upvar #0 $globArray glob
    puts stdout " [list $cmd $args]"
    # On ouvre un canal de communication avec une nouvelle commande
    # La redirection de stderr (ici sur stdout) est indispensable
    set channel [open [concat [list "|rsh" $machine $cmd] $args [list 2>@ stdout]]]
    incr glob(nproc)
    fconfigure $channel -buffering line
    fileevent $channel readable "polyexec::somethingToRead $globArray $machine $channel"
}

proc polyexec::launchNewOne {globArray machine} {
    upvar #0 $globArray glob
    if {$glob(index) < [llength $glob(cmds)]} {
	puts -nonewline stdout "[expr {$glob(index) + 1}]/[llength $glob(cmds)] on $machine"
	set cmd [lindex $glob(cmds) $glob(index)]
	set cmd [concat [list launchProcess $globArray $machine] $cmd]
	if {[catch $cmd message]} {
	    puts stdout " ECHEC : $message"
	} else {
	    puts stdout " OK $glob(nproc)"
	    incr glob(index)
	    incr glob(nexec,$machine)
	}
    } else {
	set nexec $glob(nexec,$machine)
	if {$nexec >= 2} {
	    set s s
	} else {
	    set s ""
	}
	puts "####"
	set instant [clock seconds]
	set duree [expr {$instant - $glob(debut,$machine)}]
	set instant [clock format $instant  -format {%H:%M:%S}]
	if {$nexec != 0} {
	    set vitesse " de durée = [format %.1f [expr {double($duree)/$nexec}]] s par cycle"
	}
	puts "[format %8s $machine] a terminé après $nexec exécution$s$vitesse"
    }
}

proc polyexec::launchAll {machines cmds} {

    # construction du tableau global
    # On doit travailler au niveau global (upvar #0 et non upvar) parce que
    # polyexec::somethingToRead est appelé à partir de ce niveau.

    set i 0
    while {[info globals private_polyexec_global#$i] != {}} {
	incr i
    }
    set globArray private_polyexec_global#$i

    upvar #0 $globArray glob
    set glob(nproc) 0
    set glob(index) 0
    set glob(machines) $machines
    set glob(cmds) $cmds
    
    foreach machine $glob(machines) {
	set glob(nexec,$machine) 0
	set glob(debut,$machine) [clock seconds]
	polyexec::launchNewOne $globArray $machine
    }

    puts "#### TOUTES LES MACHINES ONT DÉMARRÉ"

    while {$glob(nproc) > 0} {
	puts "#### ${globArray}(nproc) = $glob(nproc)"
	vwait ${globArray}(nproc) ;# ! et non vwait glob(nproc)
    }
}



