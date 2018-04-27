
# 2004-02-26 (FP)

set fichier ../tests/t1.j01

set f [open $fichier r]
fconfigure $f -encoding binary -translation binary
# On suppose que les lignes sont terminées par \n ou \r\n
# Dans le but de faciliter le transfert rackam->PDP,
# un fichier normal est au format DOS, lignes terminées par des \r\n
set lines [split [read $f] \n]
close $f

set FORMATERRORS(dli) 0   ;# dernière ligne incomplète
set FORMATERRORS(nodos) 0 ;# format Unix
set FORMATERRORS(totrim) [list] ;# ligne avec des blancs
set FORMATERRORS(toobig) [list] ;# ligne trop longue

if {[string index [lindex $lines 0] end] == "\r"} {
    set DOS 1
} else {
    set DOS 0
    incr FORMATERRORS(nodos)
}
if {[lindex $lines end] != {}} {
    incr FORMATERRORS(dli)
} else {
    set lines [lrange $lines 0 end-1]
}

set JEOL01 [list]
set previous_line {}
set il 0
set index_list 0
catch {unset IDL} ;# tableau index -> lignes
foreach l $lines {
    incr il
    if {$DOS} {
	if {[string index $l end] == "\r"} {
	    set l [string range $l 0 end-1]
	} else {
	    return -code error "fin de ligne $il incohérente (manque \\r)"
	}
    }
    
    if {[string index $l 0] == "*"} {
	# commentaire
	continue
    }

    set llen [string length $l]
    set l [string trimright $l]
    if {[string length $l] != $llen} {
	lappend FORMATERRORS(totrim) $il
    }
    unset llen

    if {[string length $l] >= 500} {
	lappend FORMATERRORS(toobig) $il
    }

    lappend IDL($index_list) $il

    if {[string index $l end] == {$}} {
	set l [string range $l 0 end-1]
	if {$previous_line != {}} {
	    append previous_line "-$l"
	} else {
	    set previous_line $l
	}
    } else {
	if {$previous_line != {}} {
	    lappend JEOL01 "$previous_line-$l"
	    set previous_line {}
	} else {
	    lappend JEOL01 $l
	}
	incr index_list
    }
}

proc syntax_error {idx message} {
    global IDL
    set lignes $IDL($idx)
    if {[llength $lignes] == 1} {
	return -code error "erreur ligne $IDL($idx) : $message"
    } else {
	return -code error "erreur lignes $IDL($idx) : $message"
    }
}

proc readJeol01Commands {&MOTIF JEOL01} {
    upvar ${&MOTIF} MOTIF
    catch {unset MOTIF}

    set BLOCLEVEL -1
    set BLOC(0) [list]
    set idx -1
    foreach l $JEOL01 {
	incr idx
	set tag [string range $l 0 1]
	
	if {$BLOCLEVEL < 0} {
	    if {$tag != "ID" || [string index $l 2] != "/"} {
		syntax_error $idx "attendu \"ID/...\" au lieu de \"$l\""
	    }
	    set id [string range $l 3 end]
	    if {[string length $id] > 24} {
		syntax_error $idx "ID \"$id\" trop long (max. 24)"
	    }
	    if {[string length $id] == 0} {
		syntax_error $idx "ID inexistant"
	    }
	    if {[info exists MOTIF($id)]} {
		syntax_error $idx "motif \"$id\" déjà vu"
	    }
	    set MOTIF($id) {}
	    set STATUS postID
	    set BLOCLEVEL 0
	} else {
	    switch $tag {
		"RT" {
		    lappend BLOC($BLOCLEVEL) [readRT $idx $l]
		}
		"TK" {
		    lappend BLOC($BLOCLEVEL) [readTK $idx $l]
		}
		"LN" {
		    lappend BLOC($BLOCLEVEL) [readLN $idx $l]
		}
		"RG" {
		    lappend BLOC($BLOCLEVEL) [readRG $idx $l]
		}
		"RL" {
		    incr BLOCLEVEL
		    if {$BLOCLEVEL > 4} {
			syntax_error $idx "trop de RL (max 4)"
		    }
		    set BLOC($BLOCLEVEL) [readRL $idx $l]
		}
		"RE" {
		    set b $BLOC($BLOCLEVEL)
		    incr BLOCLEVEL -1
		    if {$BLOCLEVEL < 0} {
			syntax_error $idx "un RE en trop"
		    }
		    lappend BLOC($BLOCLEVEL) $b
		}
		"EF" {
		    if {$BLOCLEVEL != 0} {
			syntax_error $idx "manque $BLOCLEVEL RE"
		    }
		    set BLOCLEVEL -1
		    set MOTIF($id) $BLOC(0)
		    puts stderr EF,terminé
		    return
		}
	    }
	}
    }
}

proc readInt {idx x} {
    if {![regexp {^((0)|([1-9][0-9]*))$} $x tout resul]} {
	syntax_error $idx "Attendu un entier non signé au lieu de \"$x\""
    }
    return [expr {$resul}]
}

set rien {
    Les directions sont
    0 E
    1 ENE
    2 NE
    3 NNE
    4 N
    5 NNW
    6 NW
    7 WNW
    8 W
    9 WSW
   10 SW
   11 SSW
   12 S
   13 SSE
   14 SE
   15 ESE
}

proc getDir {x0 y0 x1 y1} {
    set dx [expr {$x1 - $x0}]
    set dy [expr {$y1 - $y0}]

    if {$dx > 0} {
	if {$dy > 0} {
	    if {$dx > $dy} {
		return 1
	    } elseif {$dx < $dy} {
		return 3
	    } else {
		return 2
	    }
	} elseif {$dy < 0} {
	    if {$dx > -$dy} {
		return 15
	    } elseif {$dx < -$dy} {
		return 13
	    } else {
		return 14
	    }
	} else {
	    return 0
	}
    } elseif {$dx < 0} {
	if {$dy > 0} {
	    if {-$dx > $dy} {
		return 7
	    } elseif {-$dx < $dy} {
		return 5
	    } else {
		return 6
	    }
	} elseif {$dy < 0} {
	    if {-$dx > -$dy} {
		return 9
	    } elseif {-$dx < -$dy} {
		return 11
	    } else {
		return 10
	    }
	} else {
	    return 8
	}
    } else {
	if {$dy > 0} {
	    return 4
	} elseif {$dy < 0} {
	    return 12
	} else {
	    return -code error "points confondus"
	}
    }
}

proc getAngle {dir0 dir1} {
    set angle [expr {$dir1 - $dir0}]
    if {$angle > 8} {
	set angle [expr {$angle - 16}]
    } elseif {$angle < -8} {
	set angle [expr {$angle + 16}]
    }
    if {$angle <= -8 || $angle >= 8} {
	return -code error "angle plat ? (= $angle)"
    }
    return $angle
}

proc getTours {poly closed} {
    set x0 [lindex $poly 0]
    set y0 [lindex $poly 1]
    set x1 [lindex $poly 2]
    set y1 [lindex $poly 3]
    set angle 0
    set dir0 [getDir $x0 $y0 $x1 $y1]
    set dir00 $dir0
    set x0 $x1
    set y0 $y1
    foreach {x1 y1} [lrange $poly 4 end] {
	set dir1 [getDir $x0 $y0 $x1 $y1]
	incr angle [getAngle $dir0 $dir1]
	set x0 $x1
	set y0 $y1
	set dir0 $dir1
    }
    if {!$closed} {
	set dir1 [getDir $x0 $y0 [lindex $poly 0] [lindex $poly 1]]
	incr angle [getAngle $dir0 $dir1]
    }
    incr angle [getAngle $dir1 $dir00]
    if {$angle % 16 != 0} {
	return -code error "Erreur de programmation de getTours (l'angle $angle est non nul modulo 16)"
    }
    if {$angle == 16} {
	return 1
    } elseif {$angle == -16} {
	return -1
    } else {
	return -code error "Bouclage multiple ([expr {$angle/16}] tours)"
    }
}

proc readTK {idx l} {
    global errorInfo
    set ret [list $idx TK]
    if {[string range $l 0 2] != "TK/"} {
	syntax_error $idx "Attendu \"TK/...\" au lieu de \"$l\""
    }
    set ls [split [string range $l 3 end] " "]
    if {[llength $ls] < 2} {
	syntax_error $idx "manque un blanc dans \"\$l\""
    }
    if {[llength $ls] > 2} {
	syntax_error $idx "trop de blancs dans \"\$l\""
    }
    set dose [readInt $idx [lindex $ls 0]]
    if {$dose > 63} {
	syntax_error $idx "numéro de dose trop grand"
    }
    lappend ret $dose
    set xys [split [lindex $ls 1] -]
    if {[lindex $xys 0] == [lindex $xys end]} {
	syntax_error $idx "premier point = dernier point"
    }
    if {[llength $xys] < 3} {
	syntax_error $idx "pas assez de points"
    }
    if {[llength $xys] > 120} {
	syntax_error $idx "trop de points (max. 120)"
    }
    foreach e $xys {
	set xy [split $e ,]
	if {[llength $xy] != 2} {
	    syntax_error $idx "n'est pas une paire xy : \"$e\""
	}
	lappend ret [readInt $idx [lindex $xy 0]] [readInt $idx [lindex $xy 1]] 
    }
    
    if {[catch {getTours [lrange $ret 3 end] 0} msg]} {
	syntax_error $idx "$msg\n$errorInfo"
    } else {
	if {$msg != 1} {
	    syntax_error $idx "rotation de $msg tours au lieu de 1"
	}
    }
    return $ret
}

readJeol01Commands MOTIF $JEOL01

package require Tk
package require fidev
package require fidev_zinzout 1.2

proc trace {canvas argument} {
    global MOTIF

    set scale [::fidev::zinzout::getScale $canvas]
    foreach {xmin ymin xmax ymax} [::fidev::zinzout::getLimits $canvas] {}

    puts stderr [list $scale $xmin $ymin $xmax $ymax]


    $canvas create line {0 0 100 100} -fill brown -width 0	    


    foreach id [lindex [array names MOTIF] 0] {
	set motif $MOTIF($id)
	
	foreach e $motif {
	    set idx [lindex $e 0]
	    set tag [lindex $e 1]
	    set dose [lindex $e 2]
	    set xy [lrange $e 3 end]


	    if {$tag == "TK"} {
		set xyg [list]
		foreach {x y} $xy {
		    set x [expr {($x)*$scale}]
		    set y [expr {($y)*$scale}]
		    lappend xyg $x $y
		}
		set x0 [lindex $xyg 0]
		set y0 [lindex $xyg 1]
		lappend xyg $x0 $y0
		set ii 0
		foreach {x1 y1} [lrange $xyg 2 end] {
		    $canvas create line [list $x0 $y0 $x1 $y1] -fill red -width 0 -tags [list ID_$id D_$dose TK_${idx}_${ii}]
		    set x0 $x1
		    set y0 $y1
		    incr ii
		}
	    }
	}
    }
}

proc cloclo {c x y} {
    set echelle [::fidev::zinzout::getScale $c]
    set xx [$c canvasx $x]
    set yy [$c canvasy $y]

    puts stderr "\ncloclo $x $y -> $xx $yy"

    set xxx [expr $xx/$echelle]
    set yyy [expr -$yy/$echelle]
    puts [list cloclo $c $x $y -> $xx $yy -> $xxx $yyy]
    set x1 [$c canvasx [expr $x - 2]]
    set y1 [$c canvasy [expr $y - 2]]
    set x2 [$c canvasx [expr $x + 2]]
    set y2 [$c canvasy [expr $y + 2]]
    set elems [$c find overlapping $x1 $y1 $x2 $y2]
    puts "\ncloclo $x1 $y1 $x2 $y2 : $elems"
    foreach e $elems {
        puts [list cloclo $e : [$c itemcget $e -fill] [$c coords $e] [$c gettags $e]]
    }
}

set canvas [::fidev::zinzout::create . trace dummy \
                                -actionSelect cloclo \
                                -xCenter 500 \
                                -yCenter 200 \
                                -scale 0.125]

