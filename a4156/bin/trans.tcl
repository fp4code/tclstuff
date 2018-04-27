package require flex 0.2

set rien {
    example_spot_measurement
    
    a4156 write "FMT 3"
    a4156 flex::set_output_on {1 2}
    a4156 flex::set_all_outputs_on
    for {set i 0} {$i < 100} {incr i} {
	a4156 flex::start_measurement
    }
    a4156 flex::set_all_outputs_off
    a4156 flex::get_error_register_and_message


    a4156 flex::get_number_of_measurements_in_buffer
    for {set i 0} {$i < 100} {incr i} {
	a4156 write "RMD? 4"
	if 1 {
	    set s [a4156 readBin 25]
	    puts "$i [llength $s] [extract_bin $s] $s"
	} else {
	    set s [a4156 read 25]
	    puts "$i [string length $s]"
	}
    }
}



set rien {

    a4156 flex::get_number_of_measurements_in_buffer
    a4156 write "RMD? 1"
    a4156 readBin 6
    
    
    
    scrouitch, pas trouve de solution GPIB pour que readBin ne s'arrete pas sur \n
    C'est peut-être eoi
    ::GPIBBoard::eot $a4156(gpibBoard) 0
    NON, pas mieux, en fait il y a toujours LF
    
    set ::GPIBBoard::SRQ_period 10000
    ::GPIBBoard::TRACE_ON true
    
    
    while {[a4156 flex::get_number_of_measurements_in_buffer] > 0} {
	puts [a4156 flex::read_measurements 4]
    }
    
    
    while {[a4156 flex::get_number_of_measurements_in_buffer] > 0} {
	puts [a4156 flex::read_measurements 4]
    }
}


# 

proc ex {v} {
    a4156 DCL
    a4156 write US ;#  attention,  a4 write "US" ; détruit *SRE, *ESE, etc.
    a4156 write "FMT 1"
    a4156 flex::set_averaging_number 1
    a4156 flex::set_short_integration_time_value .0005
    a4156 flex::set_long_integration_time_value .04
    a4156 flex::set_integration_time_type Period
    a4156 flex::set_all_smu_filters_off
    a4156 flex::set_output_on {1 2 3}
    a4156 flex::smu_force_output_voltage SMU1 2V 0 0.01
    a4156 flex::smu_force_output_voltage SMU2 2V 0 0.01
    a4156 flex::smu_force_output_voltage SMU3 2V $v 0.01
    a4156 flex::choose_spot_measurement {1 2 3}
    a4156 flex::set_smu_measurement_mode SMU1 Current
    a4156 flex::set_smu_measurement_mode SMU2 Current
    a4156 flex::set_smu_measurement_mode SMU3 Current
    a4156 flex::enable_time_stamp
    a4156 flex::get_error_register_and_message
    a4156 flex::start_measurement
    a4156 flex::get_error_register_and_message
    a4156 flex::set_all_outputs_off
    a4156 flex::get_number_of_measurements_in_buffer
    a4156 flex::read_measurements All
}

# 2007-12-21

proc ex2 {v range icomplist mts} {
    a4156 write "FMT 1,1"
    a4156 flex::enable_time_stamp
    a4156 flex::set_output_on {1 2 3}
    a4156 write "MSC 1"
    a4156 write "MCC"
    a4156 write "MT $mts"
    a4156 flex::choose_sampling_measurement {1 2 3}
    set im1 [lindex $icomplist 0]
    set im2 [lindex $icomplist 1]
    set im3 [lindex $icomplist 2]
    a4156 flex::reset_time_stamp
    a4156 flex::smu_force_output_voltage SMU1 2V 0 $im1
    a4156 flex::smu_force_output_voltage SMU2 2V 0 $im2
    a4156 flex::smu_force_output_voltage SMU3 2V $v $im3
#    a4156 write "MV 3,11,$v,$v,$im3"
    a4156 write "RI 1,$range"
    a4156 write "RI 2,$range"
    a4156 write "RI 3,$range"
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    return [a4156 flex::get_error_register_and_message]
}


proc riri2 {a N} {
    set n [$a flex::get_number_of_measurements_in_buffer]
    if {($n % (2*$N+1)) != 0} {
	error "n % (2*$N+1)"
    }
    set first_last 0
    set Irep 000
    for {set i 0} {$i < ($n / (2*$N+1))} {incr i} {
	$a write "RMD? [expr {2*$N+1}]"
	if {$first_last == 0} {
	    set r [$a read [expr {(2*$N+1)*19 - 1}]]
	    set first_last 1
	} else {
	    set r [string range [$a read [expr {(2*$N+1)*19}]] 1 end]	    
	}
	if {$i + 1 == ($n / (2*$N+1))} {
	    set first_last 2
	}
	if {$first_last == 2} {
	    set Irep 128
	}
	switch $N {
	    3 {
		foreach {p T1 I1 T2 I2 T3 I3} [split $r ,] {
		    if {[string range $p 3 4] == "Zp" &&
			[string range $T1 0 4] == "000AT" &&
			[string range $I1 3 4] == "AI" &&
			[string range $T2 0 4] == "000BT" &&
			[string range $I2 3 4] == "BI" &&
			[string range $T3 0 4] == "000CT" &&
			[string range $I3 3 4] == "CI"} {
			set pe [string range $p 0 2]
			set p [string range $p 5 end]
			set T1 [string range $T1 5 end]
			set I1e [string range $I1 0 2]
			set I1 [string range $I1 5 end]
			set T2 [string range $T2 5 end]
			set I2e [string range $I2 0 2]
			set I2 [string range $I2 5 end]
			set T3 [string range $T3 5 end]
			set I3e [string range $I3 0 2]
			set I3 [string range $I3 5 end]
			set sp [format %4d [expr {int($p)}]]
			set sT1 [format %8.3f [expr {(1e-4*$T1)}]]
			set sT2 [format %8.3f [expr {(1e-4*$T2)}]]
			set sT3 [format %8.3f [expr {(1e-4*$T3)}]]
			set TT [format %8.3e [expr {$I1 + $I2 + $I3}]]
			puts "$sp $sT1 $sT2 $sT3 $I1 $I2 $I3 $pe $I1e $I2e $I3e $TT"
		    } else {
			puts "ERR $r"
		    }
		}
	    }
	    1  {
		foreach {p T3 I3} [split $r ,] {
		    if {[string range $p 3 4] == "Zp" &&
			[string range $T3 0 4] == "000CT" &&
			[string range $I3 3 4] == "CI"} {
			set pe [string range $p 0 2]
			set p [string range $p 5 end]
			set T3 [string range $T3 5 end]
			set I3e [string range $I3 0 2]
			set I3 [string range $I3 5 end]
			set sp [format %4d [expr {int($p)}]]
			set sT3 [format %8.3f [expr {(1e-4*$T3)}]]
			puts "$sp $sT3 $I3 $pe $I3e"
		    } else {
			puts "ERR $r"
		    }
		}
	    }
	    default {error "N = $N"}
	}
    }
    set last [$a read]
    if {$last != "\n"} {error "lu \"$last\", attendu \"\n\""}
}

proc ex3 {i irange range icomplist mts} {
    a4156 write "FMT 1,1"
    a4156 flex::enable_time_stamp
    a4156 flex::set_output_on {1 2 3}
    a4156 write "MSC 1"
    a4156 write "MCC"
    a4156 write "MT $mts"
    a4156 flex::choose_sampling_measurement {3}
    set im1 [lindex $icomplist 0]
    set im2 [lindex $icomplist 1]
    a4156 flex::reset_time_stamp
    a4156 flex::smu_force_output_voltage SMU1 2V 0 $im1
    a4156 flex::smu_force_output_voltage SMU2 2V 0 $im2
    a4156 flex::smu_force_output_current SMU3 $irange $i 1.0
#    a4156 write "MV 3,11,$v,$v,$im3"
    a4156 write "RI 1,$range"
    a4156 write "RI 2,$range"
    a4156 write "RV 3,11"
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    return [a4156 flex::get_error_register_and_message]
}

proc exf {i irange range icomplist mts} {
    a4156 write "FMT 1,1"
    a4156 flex::disable_time_stamp
    a4156 flex::set_output_on {1 2 3}
    a4156 write "MSC 1"
    a4156 write "MCC"
    a4156 write "MT $mts"
    a4156 flex::choose_sampling_measurement {3}
    set im1 [lindex $icomplist 0]
    set im2 [lindex $icomplist 1]
    a4156 flex::reset_time_stamp
    a4156 flex::smu_force_output_voltage SMU1 2V 0 $im1
    a4156 flex::smu_force_output_voltage SMU2 2V 0 $im2
    a4156 flex::smu_force_output_current SMU3 $irange $i 1.0
#    a4156 write "MV 3,11,$v,$v,$im3"
    a4156 write "RI 1,$range"
    a4156 write "RI 2,$range"
    a4156 write "RV 3,11"
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    return [a4156 flex::get_error_register_and_message]
}

proc riri3 {a N} {

    set n [$a flex::get_number_of_measurements_in_buffer]
    if {($n % (2*$N+1)) != 0} {
	error "n % (2*$N+1)"
    }
    set first_last 0
    set Irep 000
#    puts $::gp {plot "-" with linespoints}
    for {set i 0} {$i < ($n / (2*$N+1))} {incr i} {
	$a write "RMD? [expr {2*$N+1}]"
	if {$first_last == 0} {
	    set r [$a read [expr {(2*$N+1)*19 - 1}]]
	    set first_last 1
	} else {
	    set r [string range [$a read [expr {(2*$N+1)*19}]] 1 end]	    
	}
	if {$i + 1 == ($n / (2*$N+1))} {
	    set first_last 2
	}
	if {$first_last == 2} {
	    set Irep 128
	}
	switch $N {
	    1  {
		foreach {p T3 V3} [split $r ,] {
		    if {[string range $p 3 4] == "Zp" &&
			[string range $T3 0 4] == "000CT" &&
			[string range $V3 3 4] == "CV"} {
			set pe [string range $p 0 2]
			set p [string range $p 5 end]
			set T3 [string range $T3 5 end]
			set V3e [string range $V3 0 2]
			set V3 [string range $V3 5 end]
			set sp [format %4d [expr {int($p)}]]
			set sT3 [format %8.3f [expr {(1e-4*$T3)}]]
			puts "$sp $sT3 $V3 $pe $V3e"
			# puts $::gp "$sT3 $V3"
		    } else {
			puts "ERR $r"
		    }
		}
	    }
	    default {error "N = $N"}
	}
    }
#    puts $::gp e
    set last [$a read]
    if {$last != "\n"} {error "lu \"$last\", attendu \"\n\""}
}

# fast version, without time stamp
# Nvpp = nombre de valeurs par point
proc ririf {a blabla Nvpp mult fichier} {
    set n [$a flex::get_number_of_measurements_in_buffer]
    if {($n % ($Nvpp+1)) != 0} {
	error "n % ($Nvpp+1)"
    }
    set se [private_abc $::SMU(E)]
    set first_last 0
    set Irep 000
    #puts $::gp {plot "-" with linespoints}
    set out [open $fichier w]
    set s "[clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}] ririf $blabla"
    puts $out "@@Chauffage $s\n@i Veb status"
    set oldp 0
    for {set i 0} {$i < ($n / ($Nvpp+1))} {incr i} {
	# puts $i
	$a write "RMD? [expr {$Nvpp+1}]"
	if {$first_last == 0} {
	    set r [$a read [expr {($Nvpp+1)*19 - 1}]]
	    set first_last 1
	} else {
	    set r [string range [$a read [expr {($Nvpp+1)*19}]] 1 end]	    
	}
	if {$i + 1 == ($n / ($Nvpp+1))} {
	    set first_last 2
	}
	if {$first_last == 2} {
	    set Irep 128
	}
	# puts $r
	switch $Nvpp {
	    1  {
		foreach {p VE} [split $r ,] {
		    if {[string range $p 3 4] == "Zp" &&
			[string range $VE 3 4] == "${se}V"} {
			set pe [string range $p 0 2]
			set p [expr {int([string range $p 5 end])}]
			set VEe [string range $VE 0 2]
			set VE [string range $VE 5 end]
			set sp [format %4d $p]
			# puts "$p $oldp"
			if {$p < $oldp} {
			    puts $out "@@Refroidissement $s\n@i Veb status"
			    #puts $::gp ""
			}
			set oldp $p
			# puts "$sp $VE $pe $VEe"
			#puts $::gp "$sp $VE"
			puts $out "$sp $VE $VEe"
		    } else {
			puts "ERR $r"
		    }
		}
	    }
	    default {error "Nvpp = $Nvpp"}
	}
	if {(((1 + $i)*2*$mult) % $n) == 0} {
	    # puts yes
	    set last [$a read]
	    if {$last != "\n"} {error "lu \"$last\", attendu \"\n\""}
	    set first_last 0
	} else {
	    # puts "no $i $mult $n"
	}
    }
    #puts $::gp e
    close $out
}


proc riri_all {a blabla Nvpp mult fichier} {
    set n [$a flex::get_number_of_measurements_in_buffer]
    if {($n % ($Nvpp+1)) != 0} {
	error "n % ($Nvpp+1)"
    }
    set se [private_abc $::SMU(E)]
    foreach sname {E B C} vname {vE iB iC} tname {tE tB tC} {
	set ums($::SMU($sname)) $vname
	set tums($::SMU($sname)) $tname
    }
    set first_last 0
    set Irep 000
    #puts $::gp {plot "-" with linespoints}
    set out [open $fichier w]
    set s "[clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}] ririf $blabla"
    puts $out "@@Chauffage $s\n@i Veb Ib Ic te tb tc status_tE_tB_tC_vE_iB_iC"
    set oldp 0
    for {set i 0} {$i < ($n / ($Nvpp+1))} {incr i} {
	# puts $i
	$a write "RMD? [expr {$Nvpp+1}]"
	if {$first_last == 0} {
	    set r [$a read [expr {($Nvpp+1)*19 - 1}]]
	    set first_last 1
	} else {
	    set r [string range [$a read [expr {($Nvpp+1)*19}]] 1 end]	    
	}
	if {$i + 1 == ($n / ($Nvpp+1))} {
	    set first_last 2
	}
	if {$first_last == 2} {
	    set Irep 128
	}
	# puts $r
	switch $Nvpp {
	    6  {
		foreach [list p $tums(1) $ums(1) $tums(2) $ums(2) $tums(3) $ums(3)] [split $r ,] {
		    if {[string range $p 3 4] == "Zp" &&
			[string range [set $tums(1)] 3 4] == "AT" &&
			[string range [set $tums(2)] 3 4] == "BT" &&
			[string range [set $tums(3)] 3 4] == "CT" &&
			[string range [set $ums(1)] 3 4] == "A[string toupper [string index $ums(1) 0]]" &&
			[string range [set $ums(2)] 3 4] == "B[string toupper [string index $ums(2) 0]]" &&
			[string range [set $ums(3)] 3 4] == "C[string toupper [string index $ums(3) 0]]"} {
			set pe [string range $p 0 2]
			set p [expr {int([string range $p 5 end])}]
			set tEs [string range $tE 0 2]
			set tE [string range $tE 5 end]
			set tBs [string range $tB 0 2]
			set tB [string range $tB 5 end]
			set tCs [string range $tC 0 2]
			set tC [string range $tC 5 end]
			set vEs [string range $vE 0 2]
			set vE [string range $vE 5 end]
			set iBs [string range $iB 0 2]
			set iB [string range $iB 5 end]
			set iCs [string range $iC 0 2]
			set iC [string range $iC 5 end]
			set sp [format %4d $p]
			if {$tEs != "000" ||
			    $tBs != "000" ||
			    $tCs != "000" ||
			    $vEs != "000" ||
			    $iBs != "000" ||
			    $iCs != "000"} {
			    set status "{$tEs $tBs $tCs $vEs $iBs $iCs}"
			} else {
			    set status "{}"
			}

			# puts "$p $oldp"
			if {$p < $oldp} {
			    puts $out "@@Refroidissement $s\n@i Veb Ib Ic te tb tc status_tE_tB_tC_vE_iB_iC"
			    #puts $::gp ""
			}
			set oldp $p
			# puts "$sp $V3 $pe $V3e"
			#puts $::gp "$sp $V3"
			puts $out "$sp $vE $iB $iC $tE $tB $tC $status"
		    } else {
			puts $out "#ERR $r"
			puts "ERR $r"
		    }
		}
	    }
	    default {error "Nvpp = $Nvpp"}
	}
	if {(((1 + $i)*2*$mult) % $n) == 0} {
	    # puts yes
	    set last [$a read]
	    if {$last != "\n"} {error "lu \"$last\", attendu \"\n\""}
	    set first_last 0
	} else {
	    # puts "no $i $mult $n"
	}
    }
    #puts $::gp e
    close $out
}



proc exft_xxx {xxx tstamp i1 i2 irange range icomplist mts vc delay} {
    a4156 write "FMT 1,1"
    if {$tstamp} {
	a4156 flex::enable_time_stamp
    } else {
	a4156 flex::disable_time_stamp
    }
    a4156 flex::set_output_on {1 2 3}
    a4156 write "MSC 1"
    a4156 write "MCC"
    a4156 write "MT $mts"
    a4156 flex::choose_sampling_measurement $xxx
    set im1 [lindex $icomplist 0]
    set im2 [lindex $icomplist 1]
    a4156 write "RI $::SMU(C),$range"
    a4156 write "RI $::SMU(B),$range"
    a4156 write "RV $::SMU(E),11"
    a4156 flex::reset_time_stamp
    a4156 flex::smu_force_output_voltage SMU$::SMU(B) Auto 0 $im2
    a4156 flex::smu_force_output_voltage SMU$::SMU(C) Auto $vc $im1
    a4156 flex::smu_force_output_current SMU$::SMU(E) $irange $i1 1.0
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    after $delay
    puts -nonewline stderr "wait..."
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    puts [a4156 flex::get_error_register_and_message]
    a4156 flex::smu_force_output_voltage SMU$::SMU(C) Auto 0 $im2
    a4156 flex::smu_force_output_current SMU$::SMU(E) $irange $i2 1.0
    puts -nonewline stderr "XE..."
    a4156 write "XE"
    after $delay
    puts -nonewline stderr "wait..."
    a4156 flex::wait_operation_complete
    puts stderr "complete"
    a4156 flex::set_all_outputs_off
    return [a4156 flex::get_error_register_and_message]
}

set rien {

    a4156 DCL
    a4156 flex::set_averaging_number 1
    a4156 flex::set_short_integration_time_value 80e-6
    a4156 flex::set_long_integration_time_value 0.1
    a4156 flex::set_integration_time_type Period
    a4156 flex::set_all_smu_filters_off
    a4156 flex::auto_zero_disable ;## pas plus rapide
    ex2 -0.55 -17 {10e-4 10e-4 10e-4} "0,0.002,5"
    riri2 a4156 3
    
    a4156 flex::auto_zero_enable ;# pas plus lent
    a4156 flex::set_long_integration_time_value 25e-3
    a4156 flex::set_integration_time_type Long
    a4156 flex::set_all_smu_filters_off
    
    #set gp [open "|/home/p10admin/binSparcSolaris/gnuplot 2>@ stderr" w]
    #set gp [open "|/usr/bin/gnuplot 2>@ stderr" w]
    #fconfigure $gp -buffering line
    ex3 -1e-5 100µA -19 {1e-1 1e-1} "0,0.002,100"
    riri3 a4156 1
}


set rien {

    rename ::a4156::write ::a4156::write_orig
    proc ::a4156::write {a s} {
	puts stderr $s
	::a4156::write_orig $a $s
    }

    #set gp [open "|/usr/bin/gnuplot 2>@ stderr" w]
    #fconfigure $gp -buffering line


}

proc exr {i1 i2 irange range icomplist interval N vc fichier} {
    set mts "0,$interval,$N"
    set delay [expr {int($interval*1000*$N) - 5000}]
    set delay [expr {$delay > 0?$delay:0}]
    exft_xxx $::SMU(E) false $i1 $i2 $irange $range $icomplist $mts $vc $delay
    ririf a4156 "$i1 $i2 $irange $range $icomplist $mts $vc" 1 2 ${fichier}-${vc}.spt
}

proc exr_all {i1 i2 irange range icomplist interval N vc fichier} {
    set mts "0,$interval,$N"
    set delay [expr {int($interval*1000*$N)}]
    puts "Theoretical delay = $delay ms"
    set delay [expr {$delay - 5000}] ;# Marge de 5s
    set delay [expr {$delay > 0?$delay:0}]
    exft_xxx {1 2 3} true $i1 $i2 $irange $range $icomplist $mts $vc $delay
    riri_all a4156 "$i1 $i2 $irange $range $icomplist $mts $vc" 6 7 ${fichier}-${vc}.spt
}

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








a4156 DCL
a4156 write US
ditou

if {[string match sun4* $tcl_platform(machine)] && [string match SunOS $tcl_platform(os)]} {
    #set gp [open {|/home/p10admin/binSparcSolaris/gnuplot 2>@ stderr} w]
} elseif {[string match i* $tcl_platform(machine)] && [string match "Linux" $tcl_platform(os)]}  {
    #set gp [open {|/usr/bin/gnuplot 2>@ stderr} w]
} else {
    error "machine/os = $tcl_platform(machine)/$tcl_platform(os) ; reconnus actuellement : sun*/SunOs, i*/Linux"
}
#fconfigure $gp -buffering line

proc private_abc {i} {
    switch $i {
	1 {return A}
	2 {return B}
	3 {return C}
	default {error "argument \"$i\" incorrect, il faut 1, 2 ou 3"}
    }
}

proc set_smus {ls} {
    foreach is {1 2 3} {
	set ::SMU([lindex $ls [expr {$is-1}]]) $is
    }
}

a4156 DCL
a4156 flex::set_averaging_number 1
a4156 flex::set_all_smu_filters_off
a4156 flex::auto_zero_enable ;## pas plus rapide
a4156 flex::set_short_integration_time_value 0.001
a4156 flex::set_integration_time_type Short

puts {
  Taper
#   Ie1    Ie2   gamme_Ie gamme_IbIc compliances  interval_s N    Vcb fichier_sans_vc_ni_spt

set_smus {E B C}

exr -10e-3 -1e-4 10mA     -18        {1e-2 1e-2}  0.003      1000 0.4 fichier
exr -10e-3 -1e-4 10mA     -18        {1e-2 1e-2}  0.003      10 0.4 fichier
exr_all -10e-3 -1e-4 10mA     -18        {1e-2 1e-2}  0.003      10 0.4 fichier
exr_all -10e-3 -1e-4 10mA     -18        {1e-2 1e-2}  0.03      100 0.4 fichier
}


set rien {
    foreach {i1 i2 irange range icomplist interval N vc fichier} {-10e-3 -1e-4 10mA     -18        {1e-2 1e-2}  0.003      10 0.4 fichier_bidon} {}
    set a a4156
}

