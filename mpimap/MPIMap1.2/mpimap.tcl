# mpimap.tcl

# John May -- 19 June 1995
# Parses an MPI type map and displays it in living color (if possible)

# Copyright 1995, 1996 by the Regents of the University of California.
# All rights reserved.

# 22 Sep 95 johnmay	Adapted to black and white displays
# 12 Dec 95 johnmay	Updated link to user guide in About... window
# 19 Dec 95 johnmay	Add checklist for types to delete
# 20 Dec 95 johnmay	Add mpimap_library path to bitmap file references
# 15 Mar 96 johnmay	Updated version number for changes in C code
# 20 Jun 96 johnmay	Updated version number for Tcl7.5/Tk4.1 compatibility
# 28 Dec 2000 johnmay	Support MPI2 type ctors and decoders; update to
#			work with Tcl/Tk 8

set MPIMapVersion 1.2.0
set auto_path ". $auto_path"

# Hide the generic tk window
wm withdraw .

# The mpiSizes array should have been set by the C-language initialization
# function initTypeCtors.  This function determines what types are available
# and set the sizes in the array.  The array of colors below may include
# more entries than we have types, but it must include at least all the
# types that are available.  Setting the list below gives us the definitive
# list of the types we can use during this run.

set mpiTypes [lsort [array names mpiSizes]]
set userTypes {}

if { [winfo depth .] >= 4 } {
	# Colors are chosen so that objects of same size will look
	# very different, but obejcts of different size in same 
	# category will be similar.  Categories are: units (reddish),
	# signed integer (greenish), unsigned (bluish), floating-point
	# (yellowish).  Also try to make larger objects darker.
	set mpiColors(MPI_BYTE) pink
	set mpiColors(MPI_CHAR) orange
	set mpiColors(MPI_DOUBLE) yellow
	set mpiColors(MPI_FLOAT) lightyellow
	set mpiColors(MPI_INT) khaki
	set mpiColors(MPI_LONG) OliveDrab
	set mpiColors(MPI_LONG_DOUBLE) goldenrod
	set mpiColors(MPI_PACKED) red
	set mpiColors(MPI_SHORT) aquamarine
	set mpiColors(MPI_UNSIGNED_CHAR) cyan
	set mpiColors(MPI_UNSIGNED) blue
	set mpiColors(MPI_UNSIGNED_LONG) SteelBlue
	set mpiColors(MPI_UNSIGNED_SHORT) azure
	set mpiColors(MPI_CHARACTER) coral
	set mpiColors(MPI_COMPLEX) brown
	set mpiColors(MPI_DOUBLE_PRECISION) tan
	set mpiColors(MPI_INTEGER) green
	set mpiColors(MPI_LOGICAL) purple
	set mpiColors(MPI_REAL) gold
} else {
	# Not enough depth to get color contrast, so make 'em all white
	foreach type $mpiTypes {
		set mpiColors($type) white
	}
}

# Following aren't normally available in a map, so we give them background color
set bgcolor [lindex [. config -background] 4]
set mpiColors(MPI_UB) $bgcolor
set mpiColors(MPI_LB) $bgcolor

# So zooming doesn't mess up if done before mapping
set upperbound 0

proc InitMap {} {

	set instance 0
	global tk_version mpimap_library

	# Set up a list of commands for the buttons
#	set readfile [list "Read from file" "ReadFile MPIMap $instance"]
	set about [list "About MPIMap" "About MPIMap $instance"]
	set zoomin [list "Zoom in" "Rescale MPIMap $instance in"]
	set zoomout [list "Zoom out" "Rescale MPIMap $instance out"]
	set delete [list "Delete type..." "DeleteType MPIMap $instance \
		%dataframe.utypes"]
	set close [list Quit "exit"]
#	set commands [list $readfile $zoomin $zoomout $delete $close]
	set commands [list $about $zoomin $zoomout $delete $close]

	# Create the frame for the displays
	set w [MakeView mpi_type_map "MPI Type Map" $commands]

	wm group [winfo parent $w] .

	# Put in the logo
	set logo [label [winfo parent $w].m_frame.logo \
		-bitmap @${mpimap_library}/LLNLlogo.xbm -fg blue]
	pack $logo -side bottom -anchor sw

	# Frame for the canvas & scrollbar
	set vizFrame [frame $w.viz -relief raised -bd 1]

	# Create the canvas for the display
	MPIMapCtor $instance $vizFrame

	# Frame for the ctor information
	if {$tk_version < 4.0} {
		set ctorFrame [frame $w.ctors \
			-relief raised -geometry 400x300 -bd 1]
	} else {
		set ctorFrame [frame $w.ctors \
			-relief raised -width 400 -height 300 -bd 1]
	}

	# Frame for the user defined types (need its name now)
	set userFrame [frame $w.utypes -relief raised -bd 1]

	MPICtorMenu $ctorFrame $userFrame

	pack $vizFrame -side top -expand no -fill x
	pack $ctorFrame -side top -expand yes -fill both

	# Frame for the list of types
	set typeFrame [frame $w.types -relief raised -bd 1]
	pack $typeFrame -side right -before $w.viz -expand yes -anchor n

	ShowTypes $typeFrame
	
	# Finish up with user types menu
	ShowUserTypes $userFrame

	pack $userFrame -side bottom -expand yes -fill x -anchor s

	wm deiconify [winfo parent $w]
}

# Reads and MPI type map and displays it graphically
# Map should be a list of two-item lists; each two-item
# list consists of an offset followed by an MPI basic type.
proc ParseMap { typemap canvasName instance tag } {
	
	global mpiSizes mpiColors
	global upperbound

	set itemcount 0
	set upperbound 0

	foreach pair $typemap {
		set offset [lindex $pair 0]
		set type [lindex $pair 1]
		set size $mpiSizes($type)
		set color $mpiColors($type)

		BasicTypeCtor $canvasName $instance $offset $size $color \
			$type $itemcount $tag

		incr itemcount
		set blockend [expr $offset + $size]
		if { $blockend > $upperbound } {
			set upperbound $blockend
		}
	}

	DrawScale $canvasName $instance $upperbound
}

proc DrawScale { canvasName instance end } {

	# Figure out granularity of scale by seeing how many
	# units there are in "spacing" pixels -- the approximate
	# desired distance between ticks.  Then we'll round to
	# the next higher power of 10.

	global $canvasName
	set spacing 100
	set units [expr $spacing / [set ${canvasName}($instance,hUtoPix)]]
	set increment [expr int(pow(10, round(log10($units))))]

	# Put a hash mark and a counter at every "increment" units
	for { set i 0 } { $i < $end + $increment } { incr i $increment } {
		HashMarkCtor $canvasName $instance $i
		ValueCtor $canvasName $instance $i $i
	}
}

proc Rescale { canvasName instance inout } {

	# Redo the scale
	Zoom $canvasName $instance $inout

	# Remove old scaling marks by deleting items with "scaling" tags
	ClearScale $canvasName $instance

	# Redraw the scaling marks
	global upperbound
	DrawScale $canvasName $instance $upperbound
}

proc GetInfo { prompt {initial ""} } {

	set t .getinfo
	catch "destroy $t"
	toplevel $t
	wm transient $t .
	wm title $t "Enter Info"

	global dialogdata ok
	set dialogdata $initial
	label $t.title -text $prompt
	entry $t.entry -relief sunken -textvariable dialogdata
	button $t.ok -text "OK" -command "set ok 1; destroy $t"
	button $t.cancel -text "Cancel" -command "set ok 0; destroy $t"

	pack $t.title -side top
	pack $t.entry -side top -fill x
	pack $t.ok $t.cancel -side left -expand yes -fill x

	bind $t.entry <Return> "$t.ok invoke"
	focus $t.entry
#	grab $t

	tkwait window $t
	grab release $t
	if { $ok } {
		return $dialogdata
	} else {
		return ""
	}
}

proc Alert { message } {
	set t .alert
	catch "destroy $t"
	toplevel $t
	wm transient $t .
	wm title $t "Alert"

	message $t.message -text $message -width 200
	button $t.ok -text "OK" -command "destroy $t"
	pack $t.message -side top
	pack $t.ok -side left -expand yes -fill x
	grab $t

	tkwait window $t
	grab release $t
}

proc About args {
	global MPIMapVersion mpimap_library
	set t .about
	catch "destroy $t"
	toplevel $t
	wm transient $t .
	wm title $t "About MPIMap"

	label $t.logo -bitmap @${mpimap_library}/LLNLlogo.xbm -fg blue
	label $t.l1 -text "MPIMap version $MPIMapVersion"
	label $t.l2 -text "written by John May, with help from Linda Stanberry"
	label $t.l3 -text "Lawrence Livermore National Laboratory"
	label $t.l4 -text ""
	label $t.l5 -text \
	"Copyright 1995, 1996, 2000 The Regents of the University of California"
	label $t.l6 -text "All rights reserved."
	label $t.l7 -text ""
	label $t.l8 -text "For help, see your local MPIMap web page or check"

	# Use a disabled entry so user can select (but not change) the URL

	# Get the same font as labels use
	set labelFont [lindex [$t.l5 configure -font] 4]
	set url "http://www.llnl.gov/liv_comp/mpimap/UserGuide.html"
	entry $t.e1 -relief flat -font $labelFont -width [string length $url] 
	$t.e1 insert 0 $url
	$t.e1 config -state disabled

	button $t.ok -text "OK" -command "destroy $t"
	pack $t.logo -side top -anchor nw
	pack $t.l1 $t.l2 $t.l3 $t.l4 -side top
	pack $t.l5 $t.l6 $t.l7 $t.l8 $t.e1 -padx 5 -side top -anchor w

	pack $t.ok -side top -expand yes -fill x

	grab $t
	
	tkwait window $t
	grab release $t
}

proc ReadFile { canvasName instance } {

	set filename [GetInfo "Enter file name:"]
	
	if { $filename == "" } return

	set typefile_hndl [open $filename r]
	set typemap [read $typefile_hndl]
	close $typefile_hndl

	ParseMap $typemap $canvasName $instance
}

proc ClearAll { canvasName instance } {
	global $canvasName
	set frame [set ${canvasName}($instance,frame)]

	$frame.cframe.c delete all
}

proc ClearMap { canvasName instance typeName } {
	global $canvasName
	set frame [set ${canvasName}($instance,frame)]

	$frame.cframe.c delete U$typeName
}

proc ClearScale { canvasName instance } {
	global $canvasName
	set frame [set ${canvasName}($instance,frame)]

	$frame.cframe.c delete scaling
}

proc DeleteType { canvasName instance userTypeFrame } {

	global userTypes mapUserTypes userTypeMaps

	TypeListWindow $userTypes deleteList

	if { $deleteList == {} } return
#	if { $typeName == "" } return

#	set index [lsearch $userTypes $typeName]
#	if { $index < 0 } {
#		Alert "$typeName is not a user-defined type name"
#		return
#	}

	foreach typeName $deleteList {
		# Remove C bindings (mpiSizes, mpiExtents, typename)
		ClearType $typeName

		# Remove it from the lists of user types
		set index [lsearch $userTypes $typeName]
		set userTypes [lreplace $userTypes $index $index]
		unset mapUserTypes($typeName)
		unset userTypeMaps($typeName)

		# Remove the display
		ClearMap $canvasName $instance $typeName
	}

	ShowUserTypes $userTypeFrame
}

proc TypeListWindow { typeList outputListName } {

	upvar $outputListName outputList
	global ok killType
	
	set t .typelist
	catch "destroy $t"
	toplevel $t
	wm transient $t .
	wm title $t "Delete Types"

	if { [llength $typeList] == 0 } {
		set title [label $t.title -width 25 -text "No types to delete"]
	} else {
		set title [label $t.title -text "Check types to delete"]
	}
	set packCommand "pack $title"

	set i 0
	foreach type $typeList {
		set killType($type) 0
		set typeFrame [frame $t.f$i -relief raised -bd 1]
		set killit [checkbutton $typeFrame.killit -relief flat \
			-variable killType($type)]
		set name [label $typeFrame.name -width 25 -text $type -anchor w]

		pack $killit $name -side left

		append packCommand " $typeFrame"
		incr i
	}

	set bframe [frame $t.buttons]
	set delete [button $bframe.delete -text "Delete" \
		-command "set ok 1; destroy $t"]
	set cancel [button $bframe.cancel -text "Cancel" \
		-command "set ok 0; destroy $t"]
	pack $delete $cancel -side left -expand yes -fill x

	append packCommand " $bframe"
	eval "$packCommand -side top -expand yes -fill x"

	tkwait window $t
	grab release $t

	set outputList {}

	if { $ok } {
		foreach type $typeList {
			if { $killType($type) } {
				lappend outputList $type
			}
		}
	}
}

# Off we go -- run the initialization and get to work

InitMap
