#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo1.tcl
##
## couche plus ou moins transparente vers /bin/csh
##


# Création des fichiers fifo dans /tmp
# Ouvrir seulement "w" ou "r" bloque les fifo tant que l'on ne lit ni n'écrit rien
# Développement arrêté parce que "fileevent readable" ne semble par marcher pour les fifo.

set ip $env(USER)_[pid]_
array set mode {in w+ out r+ err r+}
array set 
foreach flux {in out err} {
    set f /tmp/${ip}${flux}.fifo
    if {[file exists $f]} {
        file delete $f
    }
    exec mknod $f p
    set $flux [open $f $mode($flux)]
    puts $flux
    fconfigure [set $flux] -blocking 0 -buffering none
}

proc transmets {args} {
    puts stderr "LU \"$args\""
}

fileevent $out readable [list transmets $out stdout]
fileevent $err readable [list transmets $err stderr]

# Lancement de /bin/csh

exec /bin/csh <@ $in >@ $out 2>@ $err &


