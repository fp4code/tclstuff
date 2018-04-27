# MPITypes.tcl

# Copyright (c) 1995 by the Regents of the University of California.
# All rights reserved.

# This file contains the "constructors" for the "display elements"
# used in MPIMap.  It was generated automatically by the Panorama
# Display Builder and edited somewhat by John May.

# Automatically-generated constuctor for MPIMap

proc MPIMapCtor { instance parent } {
	global MPIMap

	# Initialize the canvas parameters.  You may wish to
	# set some of these from the function paramaters
	set MPIMap($instance,origin) {10 0}
	set MPIMap($instance,oUnits) {}
	set MPIMap($instance,hScale) 0.1
	set MPIMap($instance,hUnits) byte
	set MPIMap($instance,hSUnits) {}
	set MPIMap($instance,vScale) 0.05
	set MPIMap($instance,vUnits) type
	set MPIMap($instance,vSUnits) {}
	set MPIMap($instance,hUtoPix) \
		[expr {[winfo fpixels . 1$MPIMap($instance,hSUnits)] \
		/ ($MPIMap($instance,hScale) * 1.0)} ]
	set MPIMap($instance,vUtoPix) \
		[expr {[winfo fpixels . 1$MPIMap($instance,vSUnits)] \
		/ ($MPIMap($instance,vScale) * 1.0)} ]

	# Set the dimensions
	set width 400
	set height 100

	# Set up the canvas in its window
	set MPIMap($instance,frame) $parent
	frame $parent.cframe
	frame $parent.dframe
	set hs [scrollbar $parent.cframe.horizscroll \
		-relief sunken -orient horiz\
		-command "$parent.cframe.c xview"]

	# Added by hand: don't accept keyboard traversal
	global tk_version
	if { $tk_version >= 4.0 } {
		$hs config -takefocus 0
	}

	set origPix [winfo fpixels . 1$MPIMap($instance,oUnits)]
	set xo [expr -1*[lindex $MPIMap($instance,origin) 0]*$origPix]
	set yo [expr -1*[lindex $MPIMap($instance,origin) 1]*$origPix]
	set scrollregion [list $xo $yo [expr $width+$xo] [expr $height+$yo]]
	set c [canvas $parent.cframe.c -relief raised \
		-width $width -height $height \
		-xscrollcommand "$hs set" \
		-scrollregion $scrollregion]
	pack $hs -side bottom -fill x
	pack $parent.cframe.c -side top -expand no -fill both


	# Make labels with scaling data (if any) and data frame
	pack $parent.cframe -side top -expand no -fill both
	pack $parent.dframe -side top

	# Warn the C-language scaling code that a new
	# canvas is being created (this resets its cache).
	SetCanvasScale MPIMap $instance

	# Customization to show basic type's name, offset, and sequence
	set info $parent.dframe.info
	label $info -text "Touch any element with cursor to see more info"
	pack append $parent.dframe $info {top fillx}

	$c bind basictype <Enter> "ShowInfo MPIMap $instance"
	$c bind basictype <Leave> "ClearInfo MPIMap $instance"
}

# Automatically-generated constuctor for BasicType

proc BasicTypeCtor { canvasName instance x width fill nametag 
		serialtag maptag} {
	global $canvasName

	# Convert the boxwidth to screen units
	set boxwidth [expr $width*[set ${canvasName}($instance,hUtoPix)]]

	# Get the location in user units, then convert
	# to pixels and adjust for the anchor position
	set boxheight 40
	set y 1
	CanvasPos $canvasName $instance $x $y xc yc -resize
	set xscr $xc
	set yscr $yc
	set scrCoords [list $xscr $yscr \
		[expr $xscr+$boxwidth] [expr $yscr+$boxheight]]

	# Now determine the other options
	set outline black
	set tags [list scalable basictype]
	set width 1

	# Now we're ready to create the object; find the name
	# of the canvas and issue the command
	set canvas [set ${canvasName}($instance,frame)].cframe.c
	set id [eval $canvas create rectangle $scrCoords\
		-fill [list $fill]\
		-outline [list $outline]\
		-tags [list [concat $tags X$x Y$y U$maptag \
			T$nametag S$serialtag]]\
		-width [list $width]]

	return $id
}

proc ShowInfo { canvasName instance } {
	global $canvasName
	set frame [set ${canvasName}($instance,frame)]

	# Get tags with position and value
	set data [$frame.cframe.c gettags current]
	foreach tag $data {
		if { [string index $tag 0] == "X" } {
			set xval [string range $tag 1 end]
		}
		if { [string index $tag 0] == "T" } {
			set typename [string range $tag 1 end]
		}
		if { [string index $tag 0] == "U" } {
			set usertype [string range $tag 1 end]
		}
		if { [string index $tag 0] == "S" } {
			set sequence [string range $tag 1 end]
		}
	}

	set status [catch {set message \
		[format "%s, element %d: (%d,%s)" \
		$usertype $sequence $xval $typename]}]
	if { !$status } {
		$frame.dframe.info config -text $message
	}
}

proc ClearInfo { canvasName instance } {
	global $canvasName
	set frame [set ${canvasName}($instance,frame)]
	$frame.dframe.info configure \
		-text "Touch any element with cursor to see more info"
}

# Automatically-generated constuctor for HashMark

proc HashMarkCtor { canvasName instance x } {
	global $canvasName

	# Get the location in user units, then convert
	# to pixels and adjust for the anchor position
	set boxwidth 1
	set boxheight 15
	set y @60
	CanvasPos $canvasName $instance $x $y xc yc -resize
	set xoffset [expr $boxwidth/2]
	set xscr [expr $xc-$xoffset]
	set yscr $yc
	set scrCoords [list $xscr $yscr \
		[expr $xscr+$boxwidth] [expr $yscr+$boxheight]]

	# Now determine the other options
	set fill black
	set outline black
	set tags [list scaling xmovable yfixed]
	set width 0

	# Now we're ready to create the object; find the name
	# of the canvas and issue the command
	set canvas [set ${canvasName}($instance,frame)].cframe.c
	set id [eval $canvas create rectangle $scrCoords\
		-fill [list $fill]\
		-outline [list $outline]\
		-tags [list [concat $tags X$x Y$y]]\
		-width [list $width]]

	return $id
}

# Automatically-generated constuctor for Value

proc ValueCtor { canvasName instance x text } {
	global $canvasName

	# Get the location and convert to screen units
	set y @80
	CanvasPos $canvasName $instance $x $y xc yc -resize
	set scrCoords [list $xc $yc]

	# Now determine the other options
	set anchor nw
	set fill black
	set tags [list scaling xmovable yfixed]

	# Now we're ready to create the object; find the name
	# of the canvas and issue the command
	set canvas [set ${canvasName}($instance,frame)].cframe.c
	set id [eval $canvas create text $scrCoords\
		-anchor [list $anchor]\
		-fill [list $fill]\
		-tags [list [concat $tags X$x Y$y]]\
		-text [list $text]]

	return $id
}

