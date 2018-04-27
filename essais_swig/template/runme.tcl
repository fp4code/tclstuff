# file: runme.tcl

load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/template/libswigtemplate.so Example

# Call some templated functions
puts [example::maxint 3 7]
puts [example::maxdouble 3.14 2.18]

# Create some class

# set iv [example::new_Vecint 100]
# set dv [example::new_Vecdouble 1000]

example::Vecint iv 100
example::Vecdouble dv 1000

iv getitem 0
iv incrFirst
iv getitem 0
iv incrFirstBy 10
iv getitem 0

example::getInt [iv get 0]

catch {iv setitem 101 10} message
puts stderr $message

for {set i 0} {$i < 100} {incr i} {
    iv setitem $i [expr {2*$i}]
}

for {set i 0} {$i < 1000} {incr i} {
    dv setitem $i [expr {1/($i+1.0)}]
}

set sum 0
for {set i 0} {$i < 100} {incr i} {
    set sum [expr {$sum + [iv getitem $i]}]
}
puts $sum

set sum 0.0
for {set i 0} {$i < 1000} {incr i} {
set sum [expr {$sum + [dv getitem $i]}]
}
puts $sum

