# MakeView.tcl

# John May -- 15 July 1993

# Copyright (c) 1995 by the Regents of the University of California.
# All rights reserved.

# Builds a top-level frame for a view, inserts buttons on the
# left, and returns the name of a frame to contain the display.
# Button functions can be specified either in a file or a list.
# In either case, substitutions can be made into the button
# commands to fill in the name of the host, the button frame,
# the data frame, the toplevel window, and the name of any button.

# Modified slighly to remove the host parameter from the original
# Panorama version.
# jmm 19 June 1995

# 12/19/95 johnmay:	Updated pack calls to new usage

proc MakeView {type title {buttonlist {}}} {

	set w .$type

	# Get rid of any existing window of this type
	catch { destroy $w }
	toplevel $w
	wm withdraw $w
	wm title $w "$title"

	# Make frames for the buttons and the display
	frame $w.m_frame -relief flat
	frame $w.d_frame -relief flat
	#pack append $w $w.m_frame { left fill } $w.d_frame { right fill}
	pack $w.m_frame -side left -fill both 
	pack $w.d_frame -side right -fill both

	# If list wasn't specified, read the buttonlist from a file
	if { $buttonlist == {} } {
		set filename [PanFind ${type}_cmds]
		if { $filename == {} } {
			puts stderr "Can't read menu items from ${type}_cmds"
			return 0
		}

		set mfile_hndl [open $filename r]
		set buttonlist [read $mfile_hndl]
		close $mfile_hndl
	}

	global tk_version
	set b_no 0
	set sublist [list [list %toplevel $w] \
 		[list %buttonframe $w.m_frame] [list %dataframe $w.d_frame] \
 		[list %button(\[0-9\]+) $w.m_frame.\\1]]
	foreach buttonData $buttonlist {
		# Substitute the local names we know about into the
		# command, if necessary
		set com [lindex $buttonData 1]
		foreach subpair $sublist {
			if { [regsub -all [lindex $subpair 0] $com 					[lindex $subpair 1] newCom] } {
				set com $newCom
			}
		}

		set buttonCommand \
 			"button $w.m_frame.$b_no \
 				 -text \"[lindex $buttonData 0]\"\
				 -command \"$com\" "
		# Get any extra set info for this button
		if { [llength $buttonData] > 2 } {
			append buttonCommand " " [lindex $buttonData 2]
		}

		# Disable Tk 4.0's automatic traversal of buttons
		if { $tk_version >= 4.0 } {
			append buttonCommand " -takefocus 0"
		}

		eval $buttonCommand

		incr b_no
	}

	for { set i 0 } { $i < $b_no } { incr i } {
#		pack append $w.m_frame $w.m_frame.$i { top fill }
		pack $w.m_frame.$i -side top -fill x
	}

	# Return the frame for the "main event," to be filled in by
	# someone else.

	return $w.d_frame
}
