package provide kdutil 1.2

#Extraits de kd :

# ----------------------------------------------------------------------
#     NAME:  Kosher Dill
#  PURPOSE:  Disk usage management utility
#
#   AUTHOR:  Michael J. McLennan       Phone: (215)770-2842
#            AT&T Bell Laboratories   E-mail: michael.mclennan@att.com
#
#      RCS:  main.tcl,v 1.4 1994/02/08 21:05:20 mmc Exp
# ----------------------------------------------------------------------
#                 Copyright (c) 1993  AT&T Bell Laboratories
# ======================================================================
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted,
# provided that the above copyright notice appear in all copies and that
# both that the copyright notice and warranty disclaimer appear in
# supporting documentation, and that the names of AT&T Bell Laboratories
# any of their entities not be used in advertising or publicity
# pertaining to distribution of the software without specific, written
# prior permission.
#
# AT&T disclaims all warranties with regard to this software, including
# all implied warranties of merchantability and fitness.  In no event
# shall AT&T be liable for any special, indirect or consequential
# damages or any damages whatsoever resulting from loss of use, data or
# profits, whether in an action of contract, negligence or other
# tortuous action, arising out of or in connection with the use or
# performance of this software.
# ======================================================================



set ASDEX(font) "-b&h-lucidatypewriter-medium-r-normal-sans-12-*-*-*-*-*-iso8859-1"
option add *Font $ASDEX(font)



# ----------------------------------------------------------------------
#  USAGE:  kd_map <win>
#
#  Used instead of "wm deiconify" to map a window.  If the window has
#  already been mapped and has placement information, this is set just
#  before the window is mapped to put the window back in the proper
#  place.  Needed for proper interaction with virtual window managers
#  when windows are in outlying quadrants.
# ----------------------------------------------------------------------
proc kd_map {win} {
	global KdGeom

	if {[info exists KdGeom($win)]} {
		wm geometry $win $KdGeom($win)
	}
	wm deiconify $win
	raise $win
	focus $win
}

# ----------------------------------------------------------------------
#  USAGE:  kd_unmap <win>
#
#  Used instead of "wm withdraw" to unmap a window.  Saves current
#  placement information for the window, for the next call to kd_map.
#  Needed for proper interaction with virtual window managers when
#  windows are in outlying quadrants.
# ----------------------------------------------------------------------
proc kd_unmap {win} {
	global KdGeom

	set KdGeom($win) "+[winfo rootx $win]+[winfo rooty $win]"
	wm withdraw $win
}

# ----------------------------------------------------------------------
#  USAGE:  kd_message_box <type> <mesg>
#
#  Pops up a dialog box with a message in it, and waits for the user
#  to dismiss it.  The "type" should be one of "error", "warning" or
#  "info".
# ----------------------------------------------------------------------
proc kd_message_box {type mesg} {
	global KdError
puts "$type $mesg"
puts [info level 0]
puts [info level 1]
puts [info level 2]

	.box.mesg config -text $mesg
	.box.cntl.icon config -bitmap $type
	kd_map .box
	tkwait visibility .box
	focus .box
	grab .box
	tkwait variable KdError
	grab release .box

	kd_unmap .box
}

# ----------------------------------------------------------------------
#  NOTICE WINDOW
# ----------------------------------------------------------------------
toplevel .box -class Notice
message .box.mesg -aspect 1000

frame .box.cntl -borderwidth 2 -relief raised
label .box.cntl.icon
pack .box.cntl.icon -side top -pady 2
frame .box.cntl.d -borderwidth 2 -relief sunken
button .box.cntl.d.dismiss -text "OK" \
	-command "set KdError dismiss"
pack .box.cntl.d.dismiss -padx 4 -pady 4
pack .box.cntl.d -padx 8 -pady 8

pack .box.cntl -side left -fill y
pack .box.mesg -side top -expand yes -fill both

wm title .box "Asdex : Notice"
bind .box <Any-Visibility> { raise %W }
bind .box <Key-Return> {
	.box.cntl.d.dismiss flash
	.box.cntl.d.dismiss invoke
}
bind .box.cntl.icon <Double-ButtonPress-1> {
	global errorInfo
	.box.mesg config -text $errorInfo
}
wm withdraw .box

