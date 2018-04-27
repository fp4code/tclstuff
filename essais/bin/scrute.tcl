#!/bin/sh

#\
exec wish8.3 "$0" "$@"

# Le programme suivant montre que pour 10 ms, sur une Ultra-5,
# on peut avoir 70 "after" en parallèle
# La consommation de CPU reste négligeable en dessous de 60 "after"

proc attend {fichier ms} {
    if {[file exists $fichier]} {
        puts "OUI"
        global tutu
        set tutu 1
    } else {
        # puts "NON"
        set aa [after $ms attend $fichier $ms]
        set aa [string range $aa 6 end]
        if {$aa % 10000 == 0} {
            puts $aa
        }
        # puts "info: [after info]"
    }
}

set i 0
set pupu "push $i"

proc bibi {} {
    global i pupu
    attend /tmp/$i 10
    incr i
    set pupu "push $i"
}

button .b -command bibi -textvariable pupu
pack .b

