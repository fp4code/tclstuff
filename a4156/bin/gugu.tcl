proc gugu {Ib_comp Ib_range Ice_comp Ice_range Vcb Vbe_min Vbe_max Nsteps blabla fichier} {
    a4156 write "FMT 1,1"
    a4156 flex::disable_time_stamp
    a4156 write "MM 2,$::E,$::B,$::C"
    a4156 write "WM 2,1" ;# aborting conditions
    a4156 flex::set_output_on [list $::E $::B $::C]
    a4156 flex::smu_force_output_voltage SMU$::B 2V 0.0 ${Ib_comp}
    a4156 flex::smu_force_output_voltage SMU$::C Auto ${Vcb} ${Ice_comp}
    a4156 write "WV $::E,1,11,-${Vbe_min},-${Vbe_max},${Nsteps},${Ice_comp}"
    a4156 write "RI $::E,$Ice_range"
    a4156 write "RI $::B,$Ib_range"
    a4156 write "RI $::C,$Ice_range"
    puts stderr [a4156 flex::get_error_register_and_message]
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    puts stderr [a4156 flex::get_error_register_and_message]
    set rep [litout]
    # puts $rep
    
    set out [open ${fichier}.spt w]
    puts $out "@@Gummel $blabla Vcb=$Vcb [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]\n@Ie Ib Ic Vcb"

    set gg ""
    foreach {i1 i2 i3 v} $rep {
	set i1 [expr {-[string range $i1 5 end]}]
	set i2 [expr {[string range $i2 5 end]}]
	set i3 [expr {[string range $i3 5 end]}]
	set v [expr {-[string range $v 5 end]}]
	puts $out "$i1 $i2 $i3 $v"
	if {$i1 == {} || $i2 == {} || $i3 == {} || $v == {}} break
	append gg "$i1 $i2 $i3 $v\n"
    }
    append gg e
    #puts $::gp {set log y}
    #puts $::gp "plot \"-\" using (\$4):(\$${::B}) title \"Ib\" with linespoints, \"-\" using (\$4):(\$${::C}) title \"Ic\" with linespoints"
    #puts $::gp $gg
    #puts $::gp $gg
    close $out
}



a4156 DCL
a4156 write US
ditou

a4156 DCL
a4156 write "MCC"
a4156 flex::set_averaging_number 1
a4156 flex::set_all_smu_filters_off
a4156 flex::auto_zero_enable ;## pas plus rapide
a4156 flex::set_integration_time_type Period
set E 1
set B 2
set C 3
set rien {
if {[string match sun4* $tcl_platform(machine)] && [string match SunOS $tcl_platform(os)]} {
    set gp [open {|/home/p10admin/binSparcSolaris/gnuplot 2>@ stderr} w]
} elseif {[string match i* $tcl_platform(machine)] && [string match "Linux" $tcl_platform(os)]}  {
    set gp [open {|/usr/bin/gnuplot 2>@ stderr} w]
} else {
    error "machine/os = $tcl_platform(machine)/$tcl_platform(os) ; reconnus actuellement : sun*/SunOs, i*/Linux"
}
fconfigure $gp -buffering line
}

puts {
  Taper qq du genre
#  Ib_comp Ib_range Ice_comp Ice_range Vcb Vbe_min Vbe_max Nsteps comment fichier_sans_spt
gugu 1e-3 -17 10e-3 -18 0 0.4 0.6 21 "mon beau transistor @T = 300K" fichier

}
