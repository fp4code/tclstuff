package require superTable

proc sauv.ascii {nom tableau} {
    set fichier $nom.txt
puts "on sauve dans $fichier"
    set err [catch {open $fichier w} fifi]
    if {$err != 0} {
        error $fifi
    }
    foreach l $tableau {
        set first 1
        foreach e $l {
            if {$first} {
                set first 0
            } else {
                puts -nonewline $fifi "\t"
            }
            puts -nonewline $fifi $e
        }
        puts $fifi ""
    }
    close $fifi
}

proc sauvInSupertable {nom tableau} {
    set fichier $nom.spt
    if {[file exists $fichier]} {
        set i 1
        set fichier $nom#$i.spt
        while {[file exists $fichier]} {
            incr i
            set fichier $nom#$i.spt
        }
    }
puts "on sauve dans $fichier"
    set err [catch {open $fichier w} fifi]
    if {$err != 0} {
        error $fifi
    }
    foreach l $tableau {
        set first {}
        foreach e $l {
            puts -nonewline $fifi $first$e
            if {$first == {}} {
                set first " "
            }
        }
        puts $fifi {}
    }
    close $fifi
}
