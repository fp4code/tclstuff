package require superWidgetsPlusMoins 1.0

proc plot_ui {f} {
    global ASDEX
    set ASDEX(graph) $f

label $f.comment -relief sunken -borderwidth 2
pack $f.comment

frame $f.frataille
pack $f.frataille

label $f.taille -relief sunken -borderwidth 2

label $f.gdispo -relief sunken -borderwidth 2
pack $f.gdispo

frame $f.index3
label $f.index3.l -text "Index : "
entry $f.index3.e -textvariable index3
upDown $f.index3.ud index3 0 {}
pack $f.index3.l $f.index3.e $f.index3.ud -side left

pack $f.taille $f.index3  -in $f.frataille -side left

# pack $f.g 

frame $f.fraconfig
pack $f.fraconfig

button $f.gconfig \
    -text Configuration \
    -command "ConfigureGraph {[winfo name .]}"


set lock_x " lock x "
set lock_y " lock y "
set lock_x1 " lock x1 "
set lock_y1 " lock y1 "

button $f.blx -textvariable lock_x -command "toglo x"
button $f.bly -textvariable lock_y -command "toglo y"

pack $f.gconfig $f.blx $f.bly -in $f.fraconfig -side left

frame $f.priconf -relief sunken -borderwidth 3
pack $f.priconf -in $f.fraconfig -side left

entry $f.printer -relief sunken -width 10
$f.printer insert 0 BatK

button $f.print -text Print -command imprime
pack $f.printer $f.print -in $f.priconf -side left

}

proc toglo {axis} {
    upvar #0 lock_$axis lock
    puts $lock
    if { $lock == " lock $axis " } {
        set lock "unlock $axis"
        set lims [.g ${axis}axis limits]
puts "A FAIRE .g ${axis}axis configure -min [lindex $lims 0] -max [lindex $lims 1]"
    } else {
        set lock " lock $axis "
puts "A FAIRE        .g ${axis}axis configure -min {} -max {}
"    }
}

proc imprime {} {
    set popo [.g postscript -pagewidth 150m -pageheight 250m -landscape true]
    exec lp -o nobanner -d [.printer get] << $popo
}
