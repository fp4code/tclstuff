#!/usr/local/bin/tclsh

# Ce n'est pas un Bug, mais un changement de comportement:


proc getIt {i} {
    return $i
}

set i 2
while [getIt $i] {
    puts "$i -> [getIt $i]"
    if {$i == 1} {
	puts "Arret ici avec la version <= 8.0"
    } elseif {$i == 0} {
	puts stderr "La version $tcl_version continue"
	break
    }
    incr i -1
}

set i 2
while $i {
    puts "$i -> $i"
    if {$i == 1} {
	puts "Arret ici avec la version <= 8.0"
    } elseif {$i == 0} {
	puts stderr "La version $tcl_version continue"
	break
    }
    incr i -1
}

set i 2
while {[getIt $i]} {
    puts "$i -> [getIt $i]"
    if {$i == 1} {
	puts "Arret ici avec toutes les versions"
    } elseif {$i == 0} {
	puts stderr "La version $tcl_version continue"
	break
    }
    incr i -1
}


set x 0
while {$x<3} {
    puts "x is $x"
    incr x
}


set x 0
while $x<3 {
    puts "x is $x"
    incr x
}

for {set i 2} $i {incr i -1} {
}
