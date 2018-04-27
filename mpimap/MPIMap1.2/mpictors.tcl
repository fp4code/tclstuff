# mpictors.tcl

# John May 21 September 1995

# Set up and operate the MPI datatype constructor menus for MPIMap.

# 18 Dec 95 johnmay	Clear other types from display when creating new one
# 19 Dec 95 johnmay	Add message about selecting ctor to clear fields
# 28 Dec 2000 johnmay	Add MPI2 type constructors

# Copyright (c) 1995, 2000 by the Regents of the University of California.
# All rights reserved.

set mpiParams(MPI_Type_contiguous) { count "old type" "new type" }
set mpiParams(MPI_Type_hindexed) { count "block lengths array"
				"displacements array" "old type" "new type" }
set mpiParams(MPI_Type_hvector) { count "block length" stride "old type"
				"new type" }
set mpiParams(MPI_Type_indexed) { count "block lengths array"
				"displacements array" "old type" "new type" }
set mpiParams(MPI_Type_struct) { count "block lengths array"
				"displacements array" "old types array"
				"new type" }
set mpiParams(MPI_Type_vector) { count "block length" stride "old type"
				"new type" }
# Only use MPI2 ctors if they have been defined
if { [info commands MPI_Type_create_resized] != {} } {
	set mpiParams(MPI_Type_create_resized) { "old type" "lower bound"
		extent "new type" }
}

if { [info commands MPI_Type_create_subarray] != {} } {
	set mpiParams(MPI_Type_create_subarray) { "num dimensions"
		"global sizes" "subarray sizes" "start indices"
		"storage order" "old type" "new type" }
}

set mpiParamChecks(MPI_Type_contiguous) { CheckInt CheckOldType CheckNewType }
set mpiParamChecks(MPI_Type_hindexed) { CheckInt CheckIntArray CheckIntArray
				CheckOldType CheckNewType }
set mpiParamChecks(MPI_Type_hvector) { CheckInt CheckInt CheckInt CheckOldType
				CheckNewType }
set mpiParamChecks(MPI_Type_indexed) { CheckInt CheckIntArray CheckIntArray
				CheckOldType CheckNewType }
set mpiParamChecks(MPI_Type_struct) { CheckInt CheckIntArray CheckIntArray
				CheckOldTypeArray CheckNewType }
set mpiParamChecks(MPI_Type_vector) { CheckInt CheckInt CheckInt CheckOldType
				CheckNewType }
if { [info commands MPI_Type_create_resized] != {} } {
	set mpiParamChecks(MPI_Type_create_resized) { CheckOldType CheckInt
		CheckInt CheckNewType }
}
if { [info commands MPI_Type_create_subarray] != {} } {
	set mpiParamChecks(MPI_Type_create_subarray) { CheckInt CheckIntArray
		CheckIntArray CheckIntArray CheckOrder CheckOldType
		CheckNewType }
}

set mpiCtors [lsort [array names mpiParams]]

# Determine max parameters of any ctor
set maxParams 0
foreach ctor $mpiCtors {
	set params [llength $mpiParams($ctor)]
	set maxParams [expr {($params > $maxParams) ? $params : $maxParams}]
}

# Set up keyboard traveral if Tk doesn't do it automatically
if { $tk_version < 4.0 } {
	# Set up keyboard traversal of entries
	bind Entry <Tab> "NextEntry %W 1"
	bind Entry <Shift-Tab> "NextEntry %W -1"
}

bind Entry <Return> "NextEntry %W 1"

proc MPICtorMenu { display userTypesDisplay } {

	# Menu bar is just a frame
	set ctorMenuBar [frame $display.bar -relief raised -bd 1]
	set ctorWindow [frame $display.window]
	pack $ctorMenuBar $ctorWindow -side top
	
	# Create a menu button and a "go" button
	set mbutton [menubutton $ctorMenuBar.ctors \
		-text "Select MPI Type Constructor" \
		-relief raised -bd 1 \
		-menu $ctorMenuBar.ctors.menu]

	set gobutton [button $ctorMenuBar.go \
		-text "Generate New Type" \
		-bd 1 \
		-state disabled]

	pack $mbutton $gobutton -side left

	# Create the menu that will respond to the button
	set ctorMenu [menu $mbutton.menu]

	global mpiCtors mpiParams

	# Fill in the menu with entries
	foreach ctorName $mpiCtors {
		$ctorMenu add command -label $ctorName \
			-command "DrawCtor $ctorName $gobutton \
				$ctorWindow $userTypesDisplay"
	}

	tk_menuBar $ctorMenuBar $mbutton

	SetupCtorFields $display
}

# Create the widgets for the display with nothing in them;
# this reserves the space so we don't have to resize the window
proc SetupCtorFields { display } {
	
	set window $display.window
	set title [label $window.name -anchor c -relief raised -bd 1]
	pack $title -side top -expand yes -fill x

	set count 0
	set packCommand "pack "

	global maxParams
	for { set count 0 } { $count < $maxParams } { incr count } {
		set pframe [frame $window.f$count -relief raised -bd 1]
		set desc [label $pframe.desc -width 20 -anchor e]
		set value [entry $pframe.value -relief flat -state disabled\
			-width 25]
		pack $desc $value -side left -expand yes -fill x
		append packCommand " $pframe"
	}

	eval "$packCommand -side top -expand yes -fill x"

	global tk_version
	if { $tk_version < 4.0 } {
		set helptext \
		"Select types with mouse; Ctrl-v puts selection in a field"
	} else {
		set helptext "Select and paste type names with mouse"
	}

	set info1 [label $window.info1 -anchor c -text $helptext]
	set info2 [label $window.info2 -anchor c \
		-text "To clear all fields, select a new constructor"]

	pack $info1 $info2 -side top -expand yes

}
	
proc DrawCtor { ctorName gobutton display userTypesDisplay } {

	$display.name config -text $ctorName

	global mpiParams maxParams

	set packCommand "pack "

	# Use this for Tab, Return traversal as well as collecting parameters
	global ctorEntries
	set ctorEntries {}

	set paramList $mpiParams($ctorName)
	set numParams [llength $paramList]
	for { set count 0 } { $count < $maxParams } { incr count } {
		set pframe $display.f$count
		if { $count < $numParams } {
			set parameter [lindex $paramList $count]
			$pframe.desc config -text $parameter
			$pframe.value config -relief sunken -state normal
			$pframe.value delete  0 end
			lappend ctorEntries $pframe.value
		} else {
			$pframe.desc config -text ""
			$pframe.value delete  0 end
			$pframe.value config -relief flat -state disabled
		}
	}

	# Activate the "go" button
	$gobutton configure -state normal -command "DoCtor \
		$ctorName  $userTypesDisplay $ctorEntries"

	# Newer versions of Tk do keyboard traversal automatically,
	# but we don't want to traverse this button.
	global tk_version
	if { $tk_version >= 4.0 } {
		$gobutton configure -takefocus 0
	}

	# Set focus to first entry
	focus $display.f0.value

	# Put a default name in the last entry
	global uTypeCount
	if { ![info exists uTypeCount] } {
		set uTypeCount 1
	}
	set lastEntry [lindex $ctorEntries [expr [llength $ctorEntries] - 1]]
	$lastEntry insert 0 "UserType$uTypeCount"
}

# args accepts a variable-size list of entry widgets
proc DoCtor { ctorName userTypesDisplay args } {

	# See that parameters are correctly entered by applying the
	# appropriate check function to each one.

	set entries $args

	global mpiParamChecks mpiParams
	set count 0
	set arrayCount -1
	set error 0
	set paramList {}
	set errmsg ""

	foreach widget $entries {
			
		set param [$widget get]
		set checkFunc [lindex $mpiParamChecks($ctorName) $count]
		if { [$checkFunc param $arrayCount] != "ok" } {
#			set pname [lindex [lindex $mpiParams($ctorName) \
#				$count] 0]
			set pname [lindex $mpiParams($ctorName) $count]

			append errmsg "In parameter $pname:\n"
			append errmsg "$param\n\n"
			set error 1
		} else {
			lappend paramList $param
		}

		if { $count == 0 } {
			# Parameter 0 is always an item count; we need
			# to save it for use in other tests.
			if { !$error } {
				set arrayCount $param
			}
		}

		incr count
	}

	if { $error == 0 } {
		global userTypes mapUserTypes userTypeMaps

		# Turn off display of other types
		foreach type $userTypes {
			if { $mapUserTypes($type) } {
				set mapUserTypes($type) 0
				ClearMap MPIMap 0 $type
			}
		}

		# New type name is always last, and count should point
		# just past it; grab the name
		set newName [lindex $paramList [expr $count - 1]]

		set newType [eval $ctorName $paramList]

		# Add the chosen name to our list of user types
		lappend userTypes $newName
		set userTypes [lsort $userTypes]

		# Store the type map
		set userTypeMaps($newName) $newType

		# Turn display bit of new type on
		set mapUserTypes($newName) 1

		# Show the new map
		ParseMap $newType MPIMap 0 $newName

		# Update the list of user types
		ShowUserTypes $userTypesDisplay
	
		# Update cumulative count of user types
		global uTypeCount
		incr uTypeCount

	} else {
		Alert $errmsg
	}
}

# Checks value referenced by "textName" for validity as an
# integer.  Floating point values are rounded off.  Nonsense
# values generate errors.  On success, a normal decimal integer
# is returned in the textName; otherwise, and error message
# appears there.
# "count" is a dummy here, included for symmetry.
proc CheckInt { textName count } {
	
	upvar $textName text

	set err [catch "expr int($text)" value]
	if { $err } {
		set text "\"$text\" is not in the form of an integer"
		return "error"
	} else {
		if { $value < 0 } {
			set text "negative values ($value) not permitted"
			return "error"
		} else {
			set text $value
			return "ok"
		}
	}
}

proc CheckOrder { textName count } {

	upvar $textName text

	switch [string tolower $text] {
	c
		-
	mpi_order_c {
		set text MPI_ORDER_C
	}
	f
		-
	fortran
		-
	mpi_order_fortran {
		set text MPI_ORDER_FORTRAN
	}
	default {
		set text "storage order must be C or Fortran (or MPI_ORDER_C or MPI_ORDER_FORTRAN; \"$text\" is not a valid order"
		return "error"
	}
	}
	return "ok"
}

proc CheckIntArray { textName count } {
	
	upvar $textName text

	# Split a comma-separated list
	set elementList [split $text ,]

	# Look for range patterns (10..20) and multiples (4x5)
	set numList {}
	set numPat {(0x[0-9a-f]+|[0-9]+)}
	set rangePattern "^ *$numPat *to *$numPat *(by *(-?$numPat))? *$"
	set multPattern "^ *$numPat *copies *$numPat *$"
	foreach element $elementList {
		# Check for range pattern
		set increment 1
		if { [regexp -nocase $rangePattern $element \
				whole num1 num2 byexpr increment] } {
			if { $increment == 0 } {
				set text "illegal increment ($increment)\
					for range \"$whole\""
				return "error"
			}
			set compare [expr {($increment < 0) ? ">=" : "<="}]
			for { set i $num1 } { [expr $i $compare $num2] } \
					{ incr i $increment } {
				lappend numList $i
			}
		} else {
		# Check for mulitplier pattern
		if { [regexp -nocase $multPattern $element \
				whole num1 num2] } {
			for { set i 0 } { $i < $num1 } { incr i } {
				lappend numList $num2
			}
		} else {
		# Not a special case; see if it's a legal number
		if { [CheckInt element 0] != "ok" } {
			set text $element
			return "error"
		} else {
			lappend numList $element
		}}}
	}
			
	set arrayLength [llength $numList]
	if { $arrayLength!= $count } {
		set text "count parameter ($count) differs from\
			array length ($arrayLength)"
		return "error"
	}

	# Everything's ok -- copy the list of integers back to the parameter
	set text $numList
	return "ok"
}

# See if the given type is an MPI built in type or the name of
# an exisiting user type. 
# "count" is a dummy here, included for symmetry.
proc CheckOldType { textName count } {
	
	upvar $textName text

	global mpiTypes userTypes

	# First trim any spaces
	set name [string trim $text]

	if { [lsearch $mpiTypes $name] < 0 && \
		[lsearch $userTypes $name] < 0 } {
		set text "\"$name\" is not a valid type"
		return "error"
	} else {
		set text $name
		return "ok"
	}
}

proc CheckOldTypeArray { textName count } {
	
	upvar $textName text

	set elementList [split $text ,]
	set typeList {}
	set numPat {(0x[0-9a-f]+|[0-9]+)}
	set multPattern "^ *$numPat *copies(.+)$"
	foreach element $elementList {
		# Check for mulitplier pattern
		if { [regexp -nocase $multPattern $element \
				whole num1 name] } {
			if { [CheckOldType name 0] != "ok" } {
				set text $name
				return "error"
			}
			for { set i 0 } { $i < $num1 } { incr i } {
				lappend typeList $name
			}
		} else {
		if { [CheckOldType element 0] != "ok" } {
			set text $element
			return "error"
		} else {
			lappend typeList $element
		}}
	}

	# See that the length matches the count parameter
	set arrayLength [llength $typeList]
	if { $arrayLength!= $count } {
		set text "count parameter ($count) differs from\
			array length ($arrayLength)"
		return "error"
	}

	# Everything's ok -- copy the list of types back to the parameter
	set text $typeList
	return "ok"
}

# See if the given type name is already an MPI built-in type
# "count" is a dummy here, included for symmetry.
proc CheckNewType { textName count } {
	
	upvar $textName text

	global mpiTypes userTypes

	# Trim any spaces
	set name [string trim $text]

	# It's legal if it's not in the list
	if { $name == "" } {
		set text "you must supply a name for the new type"
	} else {
	if { [string first " " $name] >= 0 } {
		set text "type name may not contain spaces"
		return "error"
	}
	if { [lsearch $mpiTypes $name] >= 0
		|| [lsearch $userTypes $name] >= 0 } {
		set text "\"$name\" is already in use as a type name"
		return "error"
	} else {
	if { [lsearch [info globals] $name] >= 0 } {
		set text "\"$name\" is already used internally; please chose\
			another name"
		return "error"
	} else {
		set text $name
		return "ok"
	}
	}
	}
}

# Move to the next entry in a set.  Dir specifies the direction,
# typically +1 or -1
proc NextEntry { window dir } {

	global ctorEntries
	set count [llength $ctorEntries]
	set index [expr ([lsearch $ctorEntries $window]+$dir)%$count]

	# Depending on how % is implemented, we may need to fix it up
	if { $index < 0 } {
		incr index $count
	}

	set newName [lindex $ctorEntries $index]

	focus $newName
}

