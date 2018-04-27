package provide superWidgetsPlusMoins 1.0

proc upDown {w var vmin vmax} {
    
    frame $w
    upvar #0 $w wvar
    set wvar(var) $var
    set wvar(min) $vmin
    set wvar(max) $vmax
    button $w.bu -image [image create bitmap -data {
        #define up_width 10
        #define up_height 6
        static char up_bits[] = {
           0x30, 0x00, 0x48, 0x00,
           0x84, 0x00, 0x02, 0x01,
           0x01, 0x02, 0xff, 0x03};
        }]

    button $w.bd -image [image create bitmap -data {
        #define down_width 10
        #define down_height 6
        static char down_bits[] = {
           0xff, 0x03, 0x01, 0x02,
           0x02, 0x01, 0x84, 0x00,
           0x48, 0x00, 0x30, 0x00};
        }]
    pack $w.bu $w.bd

    bind $w.bu <1> "plusmoinsAjoute $w 1"
    bind $w.bd <1> "plusmoinsAjoute $w -1"
}

proc plusmoinsAjoute {wname inc} {
    upvar $wname w
    upvar $w(var) var

    set nv [expr $var + $inc]
    if {$inc > 0} {
        if {$w(max) != {} && $w(max) < $nv} {
            set nv $w(max)
        }
    } elseif {$inc < 0} {
        if {$w(min) != {} && $w(min) > $nv} {
            set nv $w(min)
        }
    }
    set var $nv
}


proc essaiupDown {} {
    set toto 0
    entry .e -textvariable toto -justify right -width 3
    upDown .b toto 0 {}
    pack .e .b -side left
}
