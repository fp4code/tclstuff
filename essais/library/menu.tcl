#!/usr/local/bin/wish

proc essai {} {
global gg
    set w {}
    menubutton $w.choix \
        -bitmap @[file join [file dirname [info script]] .. bitmaps down.xbm]\
        -menu $w.choix.menu \
        -indicatoron 1 \
        -relief raised
    pack $w.choix
    
    set menu [menu $w.choix.menu -postcommand "iii $w.choix.menu"]
    set t rien
}

proc iii {w} {
    global gg
    set cc  [clock seconds]
    lappend gg $cc
    puts $gg
    $w delete 0 end
    
    foreach f $gg {
        $w add command -label $f
    }
}

essai
