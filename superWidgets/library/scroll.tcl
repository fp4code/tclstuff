package provide superWidgetsScroll 1.0

namespace eval widgets {
}

proc ::widgets::saveIt {text repertoire fichier filetypes} {
    set fichier [tk_getSaveFile \
	    -defaultextension .spt \
	    -initialdir $repertoire\
	    -initialfile $fichier\
	    -filetypes $filetypes]
    if {$fichier != {}} {
	set gnuplotConfigsDir [file dirname $fichier]
	set f [open $fichier w]
	puts -nonewline $f [$text get 1.0 end]
	close $f
    }
}

proc ::widgets::packWithScrollbar {frame chose} {
    if {$frame == "."} {
	set frame {}
    }
    scrollbar $frame.sb
    $frame.sb configure -command "$frame.$chose yview"
    $frame.$chose configure -yscrollcommand "$frame.sb set"
    
    pack $frame.sb -side left -expand 0 -fill y
    pack $frame.$chose -side left -expand 1 -fill both
}

proc ::widgets::gridWithXYScrollbars {frame chose} {
    if {$frame == "."} {
	set base {}
    } else {
	set base $frame
    }
    scrollbar $base.sx -orient h -command "$base.$chose xview"
    scrollbar $base.sy -orient v -command "$base.$chose yview"
    $base.$chose configure -xscrollcommand "$base.sx set"
    $base.$chose configure -yscrollcommand "$base.sy set"
    
    grid configure $base.sy $base.$chose -sticky news
    grid configure       x   $base.sx     -sticky news

    grid columnconfigure $frame 0 -weight 0
    grid columnconfigure $frame 1 -weight 1

    grid rowconfigure $frame 0 -weight 1
    grid rowconfigure $frame 1 -weight 0
}
