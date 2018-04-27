A FAIRE

    if {[info command down_bm] == {}} {
	set down_bm {
	    #define dwnarrow.icn_width 15
	    #define dwnarrow.icn_height 15
	    static unsigned char dwnarrow.icn_bits[] = {
		0x00, 0x00, 0x00, 0x00, 0xe0, 0x07, 0xe0, 0x07, 0xe0, 0x07, 0xe0, 0x07,
		0xe0, 0x07, 0xfc, 0x3f, 0xf8, 0x1f, 0xf0, 0x0f, 0xe0, 0x07, 0xc0, 0x03,
		0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	}
	image create bitmap down_bm -data [set down_bm]
	unset down_bm
    }



label .l -image down_bm
pack .l
set i 0
bind .l <1>  "form_combodrop $i $win.can.f ;%W config -relief sunken"




proc form_combodrop {idx w} {
    global formstypes P
    if {$formstypes($idx) != ""} {
	set win $w.$formstypes($idx)toplevel
	set x1 [expr [winfo rootx ${w}.e${idx}.b]-[winfo reqwidth $win]+[winfo reqwidth ${w}.e${idx}.b]]
	set y1 [expr [winfo rooty ${w}.e${idx}.b]+[winfo height ${w}.e${idx}.b]]
	set P(option_sheet_entry) $idx
	wm geom $win +$x1+$y1
	update idletasks
	wm deiconify $win
	raise $win
	focus $win.lb
	update 
	
	# After all this, even *Elvis* should be visible, but I'm getting
        # bug reports of spurious errors where the grab failed because the
	# window isn't visible.  The grab is necessary because we want this
	# menu to go away if the user clicks outside.  So we bind to a
	# <Leave> event so that if the user leaves the toplevel, we punt.
	if {[catch {grab -global $win}]} {
	    bind $win <Leave> "form_comborelease $win"
	}
    }
}

