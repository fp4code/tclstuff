#!/usr/local/bin/wish

# il faut le patch "dash" pour un canvas Obj

canvas .c
scale .s

pack .c .s

set ligne [.c create line]

.s configure -command {change $ligne}

proc change {ligne x} {
    set coco [list]
    for {set i 0} {$i<400} {incr i} {
        lappend coco $i [expr sin(0.001*$x*$i)*100+100]
    }
    .c coords $ligne $coco
}

.s configure -orient horizontal -length 300
.s configure -from 11.1
.s configure -to 13.1
.s configure -resolution 0.01

.c itemconfigure $ligne -width 0
 
.s configure -orient horizontal
.s configure -sliderlength 30
.s configure -length 38

.s configure -borderwidth 0
.s configure -length 34

.s configure -highlightthickness 3

.s configure -borderwidth 3

set positions 3
.s configure -length [expr [.s cget -sliderlength] + \
                           2*([.s cget -borderwidth]) + \
                           ($positions - 1)]

set positions [expr 2*100+1]
.s configure -length [expr [.s cget -sliderlength] + \
                           2*([.s cget -borderwidth]) + \
                           ($positions - 1)]


set centre 12
set resolution 0.1

proc confCRes {s centre resolution} {
    $s configure -from [expr {$centre - 100*$resolution}]
    $s configure -to   [expr {$centre + 100*$resolution}]
    $s configure -resolution $resolution
    set f [winfo parent $s]
    if {[winfo exists ${f}.resolution]} {
        ${f}.resolution configure -text [format %5g $resolution]
    }
}

proc raffine {s} {
    set resolution [expr {0.1*[$s cget -resolution]}]
    set centre [$s get]
    confCRes $s $centre $resolution
}
 
proc grossier {s} {
    set resolution [expr {10.0*[$s cget -resolution]}]
    set centre [expr {0.5*([$s cget -from] + [$s cget -to])}]
    confCRes $s $centre $resolution
}

proc decale {s sens} {
    set g [$s cget -from]
    set d [$s cget -to]
    set p [$s get]
    set i [expr {0.5*$sens*($d-$g) + $p - 0.5*($d+$g)}]
    $s configure -from [expr {$g + $i}]
    $s configure -to   [expr {$d + $i}]
    $s set             [expr {0.5*($d+$g) + $i}]
}


proc recalcule {x} {
    puts $x
}

proc creeScale {f varName resolution} {
    destroy $f
    frame $f
    upvar $varName centre
    scale ${f}.s -variable $varName -orient horizontal -command recalcule
    set positions [expr 2*100+1]
    confCRes ${f}.s $centre $resolution

    ${f}.s configure -length [expr [${f}.s cget -sliderlength] + \
                           2*([${f}.s cget -borderwidth]) + \
                           ($positions - 1)]
    ${f}.s configure -showvalue 1
    ${f}.s configure -borderwidth 0

    button ${f}.droite -text "+" -command "decale ${f}.s 1" -takefocus 0
    button ${f}.gauche -text "-" -command "decale ${f}.s -1" -takefocus 0
    
    button ${f}.raffine -text - -command "raffine ${f}.s" -takefocus 0
    button ${f}.grossier -text + -command "grossier ${f}.s" -takefocus 0
    label ${f}.resolution -text [format %5g $resolution] -width 5 -relief ridge -borderwidth 4
    label ${f}.label -text $varName

    pack ${f}.droite -side right ;# -anchor s
    pack ${f}.s -side right ;# -anchor s
    pack ${f}.gauche -side right ;#  -anchor s
    pack ${f}.raffine -side left
    pack ${f}.resolution -side left
    pack ${f}.grossier -side left
    pack ${f}.label -side right
}

toplevel .toto

creeScale .toto.rM rM 0.1
creeScale .toto.rP rP 0.1
creeScale .toto.rS rS 0.1
creeScale .toto.rS0 rS0 0.1
creeScale .toto.lT LT 0.1
pack .toto.rM .toto.rP .toto.rS .toto.rS0 .toto.lT -fill x

bind Scale <Control-Key-Up> {grossier %W}
bind Scale <Control-Key-Down> {raffine %W}
bind Scale <Key-Up> {tkScaleIncrement %W down little noRepeat}
bind Scale <Key-Down> {tkScaleIncrement %W up little noRepeat}
