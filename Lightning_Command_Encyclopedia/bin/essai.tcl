# fichier exporté avec : séparateur = \t, fin de ligne = \r, pas de "

set f [open Lightning_Command_Encyclopedia.dat r]
fconfigure $f -encoding iso8859-1 -translation binary
set ll [split [read -nonewline $f] \r] ; close $f

set i 0
foreach ls $ll {
    set l [split $ls \t]
    set n [llength $l]
    if {$n != 34} {
	puts ERROR
    }
    puts "[llength $l] $i [lindex $l 0]"
    incr i
}
