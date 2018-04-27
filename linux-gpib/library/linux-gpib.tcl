namespace eval linux-gpib {}

puts stderr "WARNING, ni488.tcl is platform dependant"

if {[string match i* $tcl_platform(machine)] && [string match "Linux" $tcl_platform(os)]}  {
    fidev_load ../src/libtcllinuxgpib.0.1.5 ni488
} elseif {[string match x86_64 $tcl_platform(machine)] && [string match "Linux" $tcl_platform(os)]}  {
    fidev_load ../src/libtcllinuxgpib.0.1.5 ni488
} else {
    error "machine/os = $tcl_platform(machine)/$tcl_platform(os) ; reconnus actuellement : i*/Linux"
}

package provide linux-gpib 0.1
