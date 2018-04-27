#!/usr/local/bin/tclsh

if {$argc != 2} {
    puts stderr "Syntaxe : [info script] machine \[-principal | -secondaire\]"
    puts stderr "              -principal ne doit pas être utilisés si vous avez"
    puts stderr "              déjà un écran principal perso. (il écrase le fichier .DISPLAY)"    
    exit 1
}

set ecran [lindex $argv 0]:0.0

# si .Xauthority n'existe pas, xauth râle
catch {exec /usr/openwin/bin/xauth nmerge - < $env(HOME)/.XauthorityDONS} rep
puts $rep

if {[lindex $argv 1] == "-principal"} {
    set displayfile [open $env(HOME)/.DISPLAY w]
    puts $displayfile $ecran
    close $displayfile
}
if {[info exists env(USER)]} {
    set USER $env(USER)
} elseif {[info exists env(LOGNAME)]} {
    set USER $env(LOGNAME)
} else {
    puts stderr "Environnement insuffisant :"
    parray env
    exit 1
}

exec /usr/dt/bin/dtterm -name $USER -display $ecran &

exit 0
