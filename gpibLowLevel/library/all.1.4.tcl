if {[info exists env(P10ARCH)] && $env(P10ARCH)=="IntelLinux"} {
    set MACHTYPE Linux
} else {
    set MACHTYPE SunSol
}

if {$MACHTYPE == "SunSol"} {
    package require ni488
} elseif {$MACHTYPE == "Linux"} {
    package require linux-gpib
}

namespace eval GPIB {}

set didi [file dirname [info script]]

source $didi/gpib_lowlev_ui.tcl
source $didi/low_level.ui.tcl
source $didi/device_level.ui.tcl
source $didi/gpib.1.4.tcl

package provide gpibLowLevel 1.4
