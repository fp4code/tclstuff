# mpitypes.tcl

# John May, July 1995
# Copyright (c) 1995 by the Regents of the University of California.
# All rights reserved.

# Display the menus of built-in and user-defined datatypes for MPIMap.

# 19 Dec 95 johnmay	Adjusted widths of user type names so display doesn't
#			resize itself when the first type is created

proc ShowTypes { display } {
	
	set title [frame $display.title -relief raised -bd 1]
	set name [label $title.name -text "Type" -width 25 -anchor w]
	set size [label $title.size -text "Size" -width 8 -anchor w]
	set color [label $title.color -text "Color" -anchor w]
	pack $name $size $color -side left

	global mpiTypes mpiColors mpiSizes

	# Get the font used in the title label so we can use the same
	# one in the entry-that-looks-like-a-label below
	set labelFont [lindex [$name configure -font] 4]

	set packCommand "pack $title "
	set count 0
	foreach type $mpiTypes {
		set typeFrame [frame ${display}.f$count -relief raised -bd 1]
		# Use a disabled entry for the name so user can select
		# (but not change) the type name
		set name [entry $typeFrame.name -relief flat \
			-font $labelFont -width 25]
		$name insert 0 $type
		$name configure -state disabled
		set size [label $typeFrame.size -text $mpiSizes($type) \
			-width 8 -anchor w]
		set color [label $typeFrame.color -text "     " \
			-bg $mpiColors($type)]

		pack $name $size $color -side left
	
		append packCommand "$typeFrame "
		incr count
	}

	eval "$packCommand -side top -expand yes -fill x"
}

proc ShowUserTypes { display } {
	
	# Get rid of old list, if there was one
	foreach subwindow [winfo children $display] {
		destroy $subwindow
	}

	set title [frame $display.title -relief raised -bd 1]
	set showit [label $title.showit -text "Display" -width 8 -anchor w]
	set name [label $title.name -text "User defined types" \
		-width 20 -anchor w]
	set size [label $title.size -text "Size" -width 8 -anchor w]
	set extent [label $title.extent -text "Extent" -width 8 -anchor w]
	pack $showit $name $size $extent -side left

	global userTypes mpiSizes mpiExtents maxUserTypes mapUserTypes

	# Get the font used in the title label so we can use the same
	# one in the entry-that-looks-like-a-label below
	set labelFont [lindex [$name configure -font] 4]

	set numUserTypes [llength $userTypes]

	set packCommand "pack $title "

	for { set i 0 } { $i < $maxUserTypes } { incr i } {
		set typeFrame [frame ${display}.f$i -relief raised -bd 1]
		# Use a disabled entry for the name so user can select
		# (but not change) the type name
		
		# If there's a user type at this index, show it; otherwise
		# diplay a blank label as a placeholder
		if { $i < $numUserTypes } {
			set type [lindex $userTypes $i]
			set showit [checkbutton $typeFrame.showit \
				-width 7 -relief flat \
				-variable mapUserTypes($type) \
				-command "CheckTypeDisplay $type"]
			set name [entry $typeFrame.name -relief flat \
				-font $labelFont -width 20]
			$name insert 0 $type
			$name configure -state disabled
			set size [label $typeFrame.size -text $mpiSizes($type) \
				-width 8 -anchor w]
			set extent [label $typeFrame.extent \
				-text $mpiExtents($type) \
				-width 8 -anchor w]
			
			pack $showit $name $size $extent -side left
		} else {
			set blank [label $typeFrame.blank -width 50]
			pack $blank -side left
		}
	
		append packCommand "$typeFrame "
	}

	eval "$packCommand -side top -expand yes -fill x"
}

proc CheckTypeDisplay { type } {
	global mapUserTypes userTypeMaps

	# Add or remove a type display
	if { $mapUserTypes($type) } {
		ParseMap $userTypeMaps($type) MPIMap 0 $type
	} else {
		ClearMap MPIMap 0 $type
	}
}
