#   root     is the parent window for this user interface



proc bubu {name command geom} {
    button $name \
		-anchor c \
		-command [concat $command -geometry $geom] \
		-padx 0 -pady 3 \
		-text $geom \
}

proc ntrigue_ui {root args} {

	# this treats "." as a special case

	if {$root == "."} {
	    set base ""
	} else {
	    set base $root
	}	
	
	label $base.4us -text {clavier type 4 américain (ancien)} -justify left -anchor w -padx 3
	label $base.5us -text {clavier type 5 américain (récent, genre PC)} -justify left -anchor w -padx 3
	label $base.5fr -text {clavier type 5 français  (JYM)} -justify left -anchor w -padx 3
	label $base.linux -text {PC sous Linux, clavier AZERTY} -justify left -anchor w -padx 3
	
	
	
	bubu $base.4us1 {ntrigue -lang us -keybd sparcus4.kbd} 1142x872
	bubu $base.4us2 {ntrigue -lang us -keybd sparcus4.kbd} 1024x768
	bubu $base.5us1 {ntrigue -lang us -keybd sparcus5.kbd} 1142x872
	bubu $base.5us2 {ntrigue -lang us -keybd sparcus5.kbd} 1024x768
	bubu $base.5fr1 {ntrigue -lang fr -keybd sparcfr5.kbd} 1142x872
	bubu $base.5fr2 {ntrigue -lang fr -keybd sparcfr5.kbd} 1024x768
	bubu $base.linux1 {ntrigue -lang fr -keybd linux.kbd} 1024x768
	bubu $base.linux2 {ntrigue -lang fr -keybd linux.kbd} 640x480
	
	label $base.label \
		-justify left \
		-text {message du jour} \
		-textvariable messageDuJour \
		-anchor w -relief sunken


	# Geometry management

	grid $base.4us1   $base.4us2  $base.4us   -sticky we
	grid $base.5us1   $base.5us2 $base.5us   -sticky we
	grid $base.5fr1   $base.5fr2 $base.5fr   -sticky we
	grid $base.linux1 $base.linux2 $base.linux -sticky we
	grid $base.label      -            -  -sticky wens

	# Resize behavior management

#	grid rowconfigure $root 1 -weight 0 -minsize 30 
#	grid rowconfigure $root 2 -weight 0 -minsize 30
#	grid rowconfigure $root 3 -weight 0 -minsize 30
#	grid rowconfigure $root 4 -weight 0 -minsize 30
#	grid rowconfigure $root 5 -weight 0 -minsize 30
#	grid rowconfigure $root 6 -weight 0 -minsize 30
#	grid columnconfigure $root 1 -weight 0 -minsize 215
# additional interface code

# end additional interface code

}


# Allow interface to be run "stand-alone" for testing

catch {
    if {$argv0 == [info script]} {
	wm title . "Testing ntrigue"
	ntrigue_ui .
    }
}
