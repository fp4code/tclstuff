package provide superWidgetsListbox 1.2
package require superWidgetsScroll 1.0

# A VOIR (pour récupérer le clavier dans le text)
tk_focusFollowsMouse

namespace eval widgets {
    variable SELECTED
}

set HELP(widgets::removeTagFromAll) {
    enlève le tag $tag de tous les éléments de $w
}
proc widgets::removeTagFromAll {w tag} {
    set indexes [$w tag ranges $tag]
    foreach {i0 i1} $indexes {
        $w tag remove $tag $i0 $i1
    }
}

proc widgets::selectLineFromXY3 {w x y commande} {
    widgets::selectLine3 $w [$w index @$x,$y] $commande
}

proc widgets::selectLineFromXY2 {w x y commande} {
    widgets::selectLine2 $w [$w index @$x,$y] $commande
}

proc widgets::selectLineFromXY1 {w x y commande} {
    widgets::selectLine1 $w [$w index @$x,$y] $commande
}

proc widgets::selectLine3 {w pos commande} {
    variable SELECTED
    set range1 [$w tag prevrange level1 "$pos lineend"]
    set range2 [$w tag prevrange level2 "$pos lineend"]
    set range3 [$w tag nextrange level3 "$pos linestart"]
    
    if {$range1 == {} || $range2 == {} || $range3 == {}} {
        return
    }
    
    set selected1 [eval [concat $w get $range1]]
    set selected2 [eval [concat $w get $range2]]
    set selected3 [eval [concat $w get $range3]]
    
    widgets::removeTagFromAll $w selected1
    widgets::removeTagFromAll $w selected2
    widgets::removeTagFromAll $w selected3
    
    eval [concat $w tag add selected1 $range1]
    eval [concat $w tag add selected2 $range2]
    eval [concat $w tag add selected3 $range3]
    $w see [lindex $range1 0]
    $w see [lindex $range2 0]
    $w see [lindex $range3 0]
    set SELECTED($w) [list $selected1 $selected2 $selected3]
    if {$commande != {}} {
        eval $commande $SELECTED($w)
    }
}

proc widgets::selectLine2 {w pos commande} {
    variable SELECTED
    set range1 [$w tag prevrange level1 "$pos lineend"]
    set range2 [$w tag nextrange level2 "$pos linestart"]
    
    if {$range1 == {} || $range2 == {}} {
        return
    }
    
    set selected1 [eval [concat $w get $range1]]
    set selected2 [eval [concat $w get $range2]]
    
    widgets::removeTagFromAll $w selected1
    widgets::removeTagFromAll $w selected2
    
    eval [concat $w tag add selected1 $range1]
    eval [concat $w tag add selected2 $range2]
    $w see [lindex $range1 0]
    $w see [lindex $range2 0]
    set SELECTED($w) [list $selected1 $selected2]
    if {$commande != {}} {
        eval $commande $SELECTED($w)
    }
}

proc widgets::selectLine1 {w pos commande} {
    variable SELECTED
    set rangeLeaf [$w tag nextrange leaf "$pos linestart"]

    set selectedLeaf [eval [concat $w get $rangeLeaf]]
    
    widgets::removeTagFromAll $w selectedLeaf
    
    eval [concat $w tag add selectedLeaf $rangeLeaf]
    $w see [lindex $rangeLeaf 0]
    set SELECTED($w) $selectedLeaf
    if {$commande != {}} {
        eval $commande $SELECTED($w)
    }
}

proc widgets::selectLineProche3 {w dir commande} {
    set selected3 [$w tag ranges selected3]
    if {$dir>0} {
        set r [$w tag nextrange level3 [lindex $selected3 1]]
    } elseif {$dir<0} {
        set r [$w tag prevrange level3 [lindex $selected3 0]]
    } else {
        return
    }
    if {$r != {}} {
        widgets::selectLine3 $w [lindex $r 0] $commande
    }
}

proc widgets::selectLineProche2 {w dir commande} {
    set selected2 [$w tag ranges selected2]
    if {$dir>0} {
        set r [$w tag nextrange level2 [lindex $selected2 1]]
    } elseif {$dir<0} {
        set r [$w tag prevrange level2 [lindex $selected2 0]]
    } else {
        return
    }
    if {$r != {}} {
        widgets::selectLine2 $w [lindex $r 0] $commande
    }
}

proc widgets::selectLineProcheSimple {w dir commande} {
    set selectedLeaf [$w tag ranges selectedLeaf]
    if {$dir>0} {
        set r [$w tag nextrange leaf [lindex $selectedLeaf 1]]
    } elseif {$dir<0} {
        set r [$w tag prevrange leaf [lindex $selectedLeaf 0]]
    } else {
        return
    }
    if {$r != {}} {
        widgets::selectLine1 $w [lindex $r 0] $commande
    }
}


#===
#===
proc widgets::listbox {f} {
    set hl [text $f.list]
    $hl configure -height 10 -width 20
    ::widgets::packWithScrollbar $f list
    return $hl
}

proc widgets::listboxSetType3 {hl commande} {

    upvar #0 private_$hl privarray
    if {[info exists privarray(depth)] && $privarray(depth) == 3} {
        return
    }
    
    set privarray(depth) 3
    set privarray(debutNom) {}

    bindtags $hl "$hl . all"
    $hl tag configure selected1 -background green
    $hl tag configure selected2 -background green
    $hl tag configure selected3 -background #ce5555 -foreground white
    $hl tag configure level1 -foreground red
    $hl tag configure level2 -foreground red
    bind $hl <1> [list widgets::listbox3_select %W %x %y $commande]
    bind $hl <Down> [list widgets::listbox3_updown %W 1 $commande]
    bind $hl <Up> [list widgets::listbox3_updown %W -1 $commande]
    bind $hl <Key> [list widgets::listbox3_key %W %A $commande]
}

proc widgets::listboxSetType2 {hl commande} {

    upvar #0 private_$hl privarray
    if {[info exists privarray(depth)] && $privarray(depth) == 2} {
        return
    }
    
    set privarray(depth) 2
    set privarray(debutNom) {}

    bindtags $hl "$hl . all"
    $hl tag configure selected1 -background green
    $hl tag configure selected2 -background #ce5555 -foreground white
    $hl tag configure level1 -foreground red
    bind $hl <1> "widgets::listbox2_select %W %x %y $commande"
    bind $hl <Down> "widgets::listbox2_updown %W 1 $commande"
    bind $hl <Up> "widgets::listbox2_updown %W -1 $commande"
    bind $hl <Key> "widgets::listbox2_key %W %A $commande"
}

proc widgets::listbox3_updown {w sens commande} {
    upvar #0 private_$w privarray
    set privarray(debutNom) ""
    selectLineProche3 $w $sens $commande
}

proc widgets::listbox2_updown {w sens commande} {
    upvar #0 private_$w privarray
    set privarray(debutNom) ""
    selectLineProche2 $w $sens $commande
}

proc widgets::listbox3_key {w char commande} {
    variable SELECTED
    if {$char == "\r"} {
	eval $commande -good $SELECTED($w)
	widgets::listbox3_updown $w 1 $commande
    } elseif {$char == "\033"} {
	eval $commande -nogood $SELECTED($w)
	widgets::listbox3_updown $w 1 $commande
    } else {
	widgets::listbox3_char $w $char $commande
    }
}

proc widgets::listbox2_key {w char commande} {
    puts $char
    widgets::listbox2_char $w $char $commande
}

proc widgets::listbox3_char {w char commande} {
    upvar #0 private_$w privarray
    append privarray(debutNom) $char
    puts "\"$privarray(debutNom)\""
    if {$privarray(debutNom) == {}} {
        return
    }
    set index [$w search -exact "        $privarray(debutNom)" 0.1]
    puts $index
    if {$index == {}} {
        bell
        set l [string length $privarray(debutNom)]
        set privarray(debutNom) [string range $privarray(debutNom) 0 [expr $l-2]]
    } else {
        widgets::selectLine3 $w $index $commande
    }
}

proc widgets::listbox2_char {w char commande} {
    upvar #0 private_$w privarray
    append privarray(debutNom) $char
    puts "\"$privarray(debutNom)\""
    if {$privarray(debutNom) == {}} {
        return
    }
    set index [$w search -exact "    $privarray(debutNom)" 0.1]
    puts $index
    if {$index == {}} {
        bell
        set l [string length $privarray(debutNom)]
        set privarray(debutNom) [string range $privarray(debutNom) 0 [expr $l-2]]
    } else {
        widgets::selectLine2 $w $index $commande
    }
}

proc widgets::listbox3_select {w x y commande} {
    upvar #0 private_$w privarray
    set privarray(debutNom) ""
    selectLineFromXY3 $w $x $y $commande
}

proc widgets::listbox2_select {w x y commande} {
    upvar #0 private_$w privarray
    set privarray(debutNom) ""
    selectLineFromXY2 $w $x $y $commande
}

proc widgets::listboxSetType1 {hl commande} {
    upvar #0 private_$hl privarray
    if {[info exists privarray(depth)] && $privarray(depth) == 1} {
        return
    }
    set privarray(depth) 1
    
    bindtags $hl "$hl . all"
    $hl tag configure selectedLeaf -background black -foreground white
    bind $hl <1> "widgets::selectLineFromXY1 %W %x %y $commande"
    bind $hl <Down> "widgets::selectLineProcheSimple %W 1 $commande"
    bind $hl <Up> "widgets::selectLineProcheSimple %W -1 $commande"
}

proc widgets::insertReturnIfNotVierge {text} {
    if {[$text get 1.0] != "\n"} {
        $text insert end \n
    }
}
