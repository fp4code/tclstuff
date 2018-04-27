package provide gpibLowLevel 1.0

if {[info exists env(OSTYPE)] && $env(OSTYPE)=="linux"} {
    set MACHTYPE Linux
} else {
    set MACHTYPE SunSol
}

if {$MACHTYPE == "SunSol"} {
    package require ni488
} elseif {$MACHTYPE == "Linux"} {
    package require linux-gpib
}



set didi [file dirname [info script]]

source $didi/gpib_lowlev_ui.tcl
source $didi/low_level.ui.tcl
source $didi/device_level.ui.tcl
source $didi/gpib.tcl
