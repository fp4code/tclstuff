# interface generated by SpecTcl version 1.0 from /home/fab/Tcl/gpib/manual.ui
#   root     is the parent window for this user interface

proc manual_ui {root args} {

	# this treats "." as a special case

	if {$root == "."} {
	    set base ""
	} else {
	    set base $root
	}
    
	button $base.button_manual \
		-command tc_manual \
		-text manual


	# Geometry management

	grid $base.button_manual -in $root	-row 1 -column 1 

	# Resize behavior management

	grid rowconfigure $root 1 -weight 0 -minsize 30
	grid rowconfigure $root 2 -weight 0 -minsize 30
	grid columnconfigure $root 1 -weight 0 -minsize 30
	grid columnconfigure $root 2 -weight 0 -minsize 30
# additional interface code
# end additional interface code

}


# Allow interface to be run "stand-alone" for testing

catch {
    if {$argv0 == [info script]} {
	wm title . "Testing manual"
	manual_ui .
    }
}