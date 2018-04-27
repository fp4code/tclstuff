#!/usr/local/bin/tclsh

if {$argc < 1} {
    puts stderr "Syntaxe : $argv0 pid ?display?"
    exit 1
}
set WISH /usr/local/bin/wish

puts "$argv0 $argv"

set tpid [lindex $argv 0]
set rep [exec /usr/bin/ps -p $tpid -o "ruser args"]
set rep [split $rep "\n"]
set rep [lindex $rep 1]
set ruser [lindex $rep 0]
set prog [lrange $rep 1 end]

if {$argc == 1} {
    set ou [exec nismatch $ruser auto_home.org_dir]
    set ou [lindex $ou 1]
    set ou [split $ou ":"]
    set machine [lindex $ou 0]
    set repertoire [lindex $ou 1]
    set DISPLAY [exec rsh -n $machine cat $repertoire/.DISPLAY]
    puts stdout $DISPLAY
# si .Xauthority n'existe pas, xauth râle
#catch {exec /usr/bin/rsh -n $machine cat $repertoire/.Xauthority} xau
#puts "xau=$xau"
#catch {exec /usr/openwin/bin/xauth merge - << $xau} rep
#puts $rep

    exec su - $ruser -c "$WISH [info script] $tpid $DISPLAY -display $DISPLAY" &
    exit 0
} else {
    set DISPLAY [lindex $argv 1]
}

wm title . "tueur de tâche"

proc continueTask {} {
    global tpid
    exec kill -CONT $tpid
    puts stdout continueTask
    bind . <Destroy> {}
    exit 0
}

proc killTask {} {
    global tpid
    exec /usr/bin/kill -KILL $tpid
    puts stdout killTask
    exit 0
}

label .l -text "Le programme\n$prog\nvient d'être suspendu par l'administrateur Unix\nparce qu'il utilise trop de ressources système.\nVous ne devez normalement pas continuer ce programme sur cette machine.\nDemandez plus d'explications à l'administrateur  Unix \"sysadmin\"" 
button .b1 -text "OK, je tue brutalement la tâche" -command killTask
button .b2 -text "je veux continuer" -command continueTask
pack .l .b1 .b2 -fill both -expand 1

bind . <Unmap> {
    if {"%W" == "."} {
        wm deiconify .
    }
}

bind . <Visibility> {
    if {"%W" == "."} {
        raise .
    }
}

bind . <Destroy> {
    if {"%W" == "."} {
        killTask
    }
}

set color red
set defcolor [.b1 cget -bg]

proc blink {} {
    global color defcolor
    .b1 configure -bg $color
    if {$color == "red"} {
        set color $defcolor
        after 100 blink
    } else {
        set color red
        after 900 blink
    }
}

blink

puts toto

exec /usr/bin/kill -STOP $tpid
