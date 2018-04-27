# RCS: @(#) $Id: ni488.tcl,v 1.6 2002/06/25 08:42:56 fab Exp $

namespace eval ni488 {}

puts stderr "WARNING, ni488.tcl is platform dependant"

if {[string match sun4* $tcl_platform(machine)] && [string match SunOS $tcl_platform(os)]} {
    fidev_load ../src/libni488 ni488
} elseif {[string match i* $tcl_platform(machine)] && [string match "Windows NT" $tcl_platform(os)]}  {
    fidev_load ../src/libni488.2.0 ni488
} elseif {[string match i* $tcl_platform(machine)] && [string match "Linux" $tcl_platform(os)]}  {
    puts stderr "No NI488 driver loaded"
} else {
    error "machine/os = $tcl_platform(machine)/$tcl_platform(os) ; reconnus actuellement : sun*/SunOs, i*/Linux, i$/Windows NT"
}

package provide ni488 1.1
