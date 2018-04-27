proc litout {} {
    set n [a4156 flex::get_number_of_measurements_in_buffer]
    set ret []
    while {$n > 0} {
	a4156 write "RMD? 1"
	set r [a4156 read 19]
        puts $r
	lappend ret [string range $r 0 17]
	set n [a4156 flex::get_number_of_measurements_in_buffer]
    }
    return $ret
}

proc didi {I_comp I_range V_min V_max Nsteps blabla fichier} {
    a4156 write "FMT 1,1"
    a4156 flex::disable_time_stamp
    a4156 write "MM 2,$::A,$::K" ;# staircase
    a4156 write "WM 2,1" ;# aborting conditions
    a4156 flex::set_output_on [list $::A $::K]
    a4156 flex::smu_force_output_voltage SMU$::K 2V 0.0 ${I_comp}
    a4156 write "WV $::A,1,11,${V_min},${V_max},${Nsteps},${I_comp}"
    a4156 write "RI $::A,$I_range"
    a4156 write "RI $::K,$I_range"
    puts stderr [a4156 flex::get_error_register_and_message]
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    puts stderr [a4156 flex::get_error_register_and_message]
    set rep [litout]
    puts $rep
    
    set out [open ${fichier}.spt w]
    puts $out "@@I(V) $blabla [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]\n@V Ia Ik"

    foreach {i1 i2 v} $rep {
	set i1 [expr {[string range $i1 5 end]}]
	set i2 [expr {[string range $i2 5 end]}]
	set v [expr {[string range $v 5 end]}]
	puts $out "$v $i1 $i2"
	if {$i1 == {} || $i2 == {} || $v == {}} break
    }
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
set K 1
set A 3

puts {
  Taper qq du genre
# I_comp I_range V_min V_max Nsteps blabla fichier_sans_spt
didi 1e-3 -17 -0.1 1 50 "ma belle diode @T = 300K" fichier
didi 1e-6 14 0 0.1 50 "ma belle diode @T = 300K" fichier
}
