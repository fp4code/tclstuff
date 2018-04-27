package provide MOHbt 0.2
package require masque 1.0

namespace eval MOHbt {
    
# TBH multi-orientation (masque Dan)

set VIEILLE_NOMENCLATURE {
    A45 i10x80
    C00 v10x20
    A90 h10x80
    C90 h10x20
    A00 v10x80
    C45 i10x20
    E45 i5x40
    G00 v5x10
    E90 h5x40
    G90 h5x10
    E00 v5x40
    G45 i5x10
    B45 i10x40
    D00 v10x10
    B90 h10x40
    D90 h10x10
    B00 v10x40
    D45 i10x10
    F45 i5x20
    H00 v5x5
    F90 h5x20
    H90 h5x5
    F00 v5x20
    H45 i5x5
}

    variable MOTIFS
    
    set MOTIFS() {0 0}

    foreach m {i5x40 v5x10 h5x40 h5x10 v5x40 i5x10} {
	set MOTIFS($m) [list 0 0]
    }

    foreach m {i5x20 v5x5 h5x20 h5x5 v5x20 i5x5} {
	set MOTIFS($m) [list 400 0]
    }

    foreach m {i10x80 v10x20 h10x80 h10x20 v10x80 i10x20} {
	set MOTIFS($m) [list 0 -350]
    }

    foreach m {i10x40 v10x10 h10x40 h10x10 v10x40 i10x10} {
	set MOTIFS($m) [list 400 -350]
    }

    set GROUPE(1) {h5x40 h5x20 h10x80 h10x40}
    set GROUPE(2) {v5x10 v5x5  v10x20 v10x10}
    set GROUPE(3) {i5x40 i5x20 i10x80 i10x40}
    set GROUPE(4) {i5x10 i5x5  i10x20 i10x10}
    set GROUPE(5) {v5x40 v5x20 v10x80 v10x40}
    set GROUPE(6) {h5x10 h5x5  h10x20 h10x10}

    global SURFACE
    set SURFACE(10x80) 800
    set SURFACE(10x40) 400
    set SURFACE(10x20) 200
    set SURFACE(10x10) 100
    set SURFACE(5x40)  200
    set SURFACE(5x20)  100
    set SURFACE(5x10)   50
    set SURFACE(5x5)    25
}


proc MOHbt::symDesToPos {symDes} {
    variable MOTIFS
    variable GROUPE
    global BLOC_1_6
        
    set li [string index $symDes 0]
    set co [string index $symDes 1]
    set m [string range $symDes 2 end]
    
    if {![info exists MOTIFS($m)] || $li < 0 || $li > 7 || $co < 0 || $co > 7} {
	error "Bad symdes: $symDes"
    }

    if {[lsearch $GROUPE($BLOC_1_6) $m] < 0} {
	error "Bad group, press \"calcule\""
    }

    set b $MOTIFS($m)
    set bx [lindex $b 0]
    set by [lindex $b 1]

    if {$li < 4} {
	set y [expr {$li*(-700)+$by}]
    } else {
	set y [expr {($li+1)*(-700)+$by}]
    }
    if {$co < 4} {
	set x [expr {$co*(800)+$bx}]
    } else {
	set x [expr {($co+1)*(800)+$bx}]
    }

    return [list $x $y]
}


proc MOHbt::allSymDes {typDispo contourMasque} {

    global BLOC_1_6
    variable GROUPE
    toplevel .blocmulti -class Dialog
    label .blocmulti.l -text "Numéro de bloc (1 à 6)"
    
    for {set i 1} {$i <= 6} {incr i} {
	radiobutton .blocmulti.b$i -variable BLOC_1_6 -value $i -text $i -command "destroy .blocmulti"
    }
    grid configure .blocmulti.l  -
    grid configure .blocmulti.b1 .blocmulti.b4
    grid configure .blocmulti.b2 .blocmulti.b5
    grid configure .blocmulti.b3 .blocmulti.b6

    
    bind .blocmulti <Unmap> {
	if {"%W" == ".blocmulti"} {
	    wm deiconify %W
	}
    }
    bind .blocmulti <Visibility> {
	if {"%W" == ".blocmulti"} {
	    raise %W
	}
    }
    aide::nondocumente .blocmulti
    tkwait window .blocmulti
    
    set dispos [list]
    for {set li 0} {$li < 8} {incr li} {
	for {set co 0} {$co < 8} {incr co} {
	    foreach m $GROUPE($BLOC_1_6) {
                set symDes $li$co$m
                foreach {x y} [symDesToPos $symDes] {}
                if {[geom2d::isInternal $contourMasque $x $y]} {
                    lappend dispos $symDes
                }
	    }
	}
    }

    # Pour prendre en compte la nouvelle affectation des smus
    valeurs.par.defaut

    return $dispos
}


proc ::MOHbt::getSurface {symDes} {
    variable SURFACE
    return $SURFACE([string range $symDes 3 end])    
}

proc ::MOHbt::geomName {symDes} {
    return [string range $symDes 2 end]
}

proc ::MOHbt::getFamily {symDes} {
    return [string range $symDes 3 end]
}

proc ::MOHbt::configPointes {} {
    global BLOC_1_6
    GPIB::renameGPIB smuE {}
    GPIB::renameGPIB smuB {}
    GPIB::renameGPIB smuC {}
    GPIB::copyGPIB smu3 smuC
    
    if {[info exists BLOC_1_6] &&  $BLOC_1_6 <= 3} {
        GPIB::copyGPIB smu1 smuE
        GPIB::copyGPIB smu2 smuB
    } else {
        GPIB::copyGPIB smu1 smuB
        GPIB::copyGPIB smu2 smuE
    }
}