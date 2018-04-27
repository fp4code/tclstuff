# MPIMapUtils.tcl
# John May -- 20 June 1995

# Utility functions for MPIMap

# Copyright (c) 1995 by the Regents of the University of California.
# All rights reserved.

# Zooms the horizontal scale in or out by a factor of "zoomfactor"
proc Zoom {canvasName instance inout } {

	global $canvasName
	set origin [set ${canvasName}($instance,origin)]
	set oUnits [set ${canvasName}($instance,oUnits)]
	set oldHScale [set ${canvasName}($instance,hScale)]
	set hSUnits [set ${canvasName}($instance,hSUnits)]
	set c [set ${canvasName}($instance,frame)].cframe.c

	# Change the horizontal scale
	set zoomfactor 2
	set operator [expr { ($inout == "in") ? "/" : "*" }]
	set hScale [expr $oldHScale $operator $zoomfactor]

	# Store the new value
	set ${canvasName}($instance,hScale) $hScale

	# Do the rescaling
	set xratio [expr 1.0*$oldHScale/$hScale]

	# How many pixels per user unit?
	set hUserToPix [expr {[winfo fpixels . 1$hSUnits] 
				/ ( $hScale * 1.0 )} ]

	# Store the conversion
	set ${canvasName}($instance,hUtoPix) $hUserToPix

	# Reposition the movable objects on the canvas.
	# This must be called _after_ the array entries with
	# the scaling values are updated.
	ScaleCanvas $canvasName $instance $xratio 1.0

	$c scale scalable 0 0 $xratio 1.0
	$c scale xscalable 0 0 $xratio 1.0

	# Re-position the orgin.  Even if the user didn't
	# explicitly move it, scaling will change its position.

	# Convert to pixel units for our use
	set oUPix [winfo fpixels . 1$oUnits]
	set xOriginPix [expr [lindex $origin 0]*$oUPix]
	set yOriginPix [expr [lindex $origin 1]*$oUPix]

	# See where the origin is now
	set curscroll [lindex [$c config -scrollregion] 4]

	# Now reset the scrollregion, which will effectively
	# move the origin.
	set newscroll [lreplace $curscroll 0 1 \
		[expr -$xOriginPix] [expr -$yOriginPix] ]
	$c config -scrollregion $newscroll

	# Store the new origin
	set ${canvasName}($instance,origin) $origin
	set ${canvasName}($instance,oUnits) $oUnits

	# Reset the cache (since scrollregion is cached too)
	SetCanvasScale $canvasName $instance

}
