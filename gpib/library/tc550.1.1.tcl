package provide tc550 1.1

proc createTC550IfNonExistent {} {
    global tc550 GPIB_board GPIB_boardAddress
    set board $GPIB_board
    set addr 19
    set name tc550
    if {![info exists tc550]} {
# ATTENTION : 19 codé dur
        if {[info exists tc550]} {
            error "$name already exists"
        }
        set tc550(classe) tc550
        set tc550(board) $board
    #    set tc550(name) $nickname
        set tc550(gpibAddr) $addr
        global gpibNames
        set gpibNames($board,$addr) $name 
        set tc550(inverseY) -1
        set tc550(moveTo) tc550_moveTo
        set tc550(moveToRaw) tc550_moveToRaw
        set tc550(manual) tc550_manual
        set tc550(getPosition) unAlignedTC550:getPosition
        ::aligned::new tc550
        TC550:ini $name
    }
}

proc tc550_manual {name} {
    global tc550
    TC550:wrt tc550 "MA"
    TC550:readExpecting tc550 MA 100000
    toplevel .tc_manual_manual
    button .tc_manual_manual.done -text Done -command {
        TC550:readExpecting tc550 AU 10000
        destroy .tc_manual_manual
    }
    pack .tc_manual_manual.done
    aide::nondocumente .tc_manual_manual
}


proc unAlignedTC550:getPosition {name} {
    upvar #0 $name tc550
set SETBUG {
# tentative non menée à bout pour
# réinitialiser systématiquement la machine après des pertes de mémoire
# (pile HS)
# ECRIRE A LA MAIN DANS CE CAS :
PRX0Y0
MDAM
MOX0Y0
et lire MC
#    TC550:wrt $name "PRX0Y0\nMDAM\nMOX0Y0"
#    TC550:readExpecting tc550 MC 1000
}
    TC550:wrt $name "MDAM\n?P"
    set lu [GPIB:rd 0 $tc550(gpibAddr) 19]
    
    if {[string index $lu 0] != "M"} {
        error "TC550 : ?P : Attendu M..., lu $lu"
    }
    if {[string index $lu 1] != "X"} {
        error "TC550 : ?P : Attendu MX..., lu $lu"
    }
    set index [string first "Y" $lu]
    if {$index < 0} {
        error "TC550 : ?P : Attendu MX...Y..., lu $lu"
    } 
    set x [string range $lu 2 [expr {$index - 1}]] 
    set y [string range $lu [expr {$index + 1}] end] 
    set errx [catch {expr {$x}} x]
    set erry [catch {expr {$y}} y]
    if {$errx || $erry} {
        set    message "TC550 : ?P : Attendu MXxxxxxYyyyyy, lu $lu\n"
        append message "La pile du TC550 est-elle usée ?\n"
        append message "ECRIRE A LA MAIN DANS CE CAS : "
        append message "PRX0Y0\\nMDAM\\nMOX0Y0 "
        append message "et lire MC"
        error $message
    }
    set x [expr {$x * 10}]
    set y [expr {$y * 10 * $tc550(inverseY)}]
    set tc550(xTheoUnaligned) $x
    set tc550(yTheoUnaligned) $y
    return [list $x $y]
}

proc tc550_moveTo {name x y} {
    upvar #0 $name tc550
    TC550:wrt $name "?S"
    set lu [GPIB:rd 0 $tc550(gpibAddr) 12]
    if {[string index $lu 0] != "S"} {
        error "Attendu S..., lu $lu"
    }
    if {[string index $lu 1] != "Z"} {
        error "Attendu SZ..., lu $lu"
    }
    if {[string index $lu 2] == "U"} {
        set up 1
    } elseif {[string index $lu 2] == "D"} {
        set up 0
    } else {
        error "Attendu SZ(U|D)..., lu $lu"
    }
    if {$up} {
        TC550:off $name
    }
    if {$tc550(xTheoUnaligned) > $x} {
# POUR EVITER DES DEPLACEMENTS RAPIDES
#        set xtmp [expr {$tc550(xTheoUnaligned) - 1000}]
#        while {$xtmp > $x - 1000} {
#            tc550_moveToRaw $name $xtmp $y
#            set xtmp [expr {$tc550(xTheoUnaligned) - 1000}]
#        }
        tc550_moveToRaw $name [expr {$x - 1000}] $y
        tc550_moveToRaw $name $x $y
    } else {
# POUR EVITER DES DEPLACEMENTS RAPIDES
#        set xtmp [expr {$tc550(xTheoUnaligned) + 1000}]
#        while {$xtmp < $x} {
#            tc550_moveToRaw $name $xtmp $y
#            set xtmp [expr {$tc550(xTheoUnaligned) + 1000}]
#        }
        tc550_moveToRaw $name $x $y
    }
    if {$up} {
        TC550:on $name
    }
}

proc tc550_moveToRaw {name x y} {
    upvar #0 $name tc550
    set tc550(enMouvement) 1
    TC550:wrt $name "MDAM\nMOX${x}Y[expr {$tc550(inverseY)*$y}]"
    TC550:readExpecting $name MC 10000
# MF VEUT DIRE HORS BORNES
    set tc550(enMouvement) 0
    set tc550(xTheoUnaligned) $x
    set tc550(yTheoUnaligned) $y
}

proc TC550:readExpecting {name s msTimeout} {
    upvar #0 $name tc550
puts [list TC550:readExpecting $name $s $msTimeout]
    # très sale, il faudrait utiliser after
#// Le TC peut renvoyer 0 octets, sans timeout ??
#// Il faudrait accepter de lire le message en plusieurs rd
    set maxtime [expr {[clock seconds] + ceil($msTimeout/1000.)}]
    set encore 1
    while {$encore} {
        set rep [GPIB:rd 0 $tc550(gpibAddr) 512]
        set rep [string trimright $rep "\n\r"]
puts "\"$rep\" \"$s\" [clock seconds] $maxtime"
        if {$rep == ${s}} {
            set encore 0
        } elseif {[clock seconds] > $maxtime} {
            tk_messageBox -message "TC550 : Attendu \"$s\", reçu \"$rep\""
            set encore 0
        }
    }
}

proc TC550:decharge {name} {
afaire
}

proc TC550:aligne {name} {
afaire
}

set HELP(TC550:on) {
Place les pointes en contact
}
proc TC550:on {name} {
    TC550:wrt $name "ZU"
}

set HELP(TC550:off) {
Sépare pointes et substrat
}
proc TC550:off {name} {
    TC550:wrt $name "ZD"
}

proc TC550:enMouvement {name} {
afaire
}

proc TC550:wrt {name s} {
    upvar #0 $name tc550
 
    # ATTENTION !!!
    # si REN=1, repasse au menu au premier MLA
    global GPIB_board
    set ren [expr {[::GPIBBoard::lines $GPIB_board] & 0x1000}]
    
    if {$ren} {
        ::GPIBBoard::sre $GPIB_board 0
    }

 
    append s "\n"
    GPIB:wrt $tc550(board) $tc550(gpibAddr) $s
    if {$ren} {
        ::GPIBBoard::sre $GPIB_board 1
    }
}

proc TC550:ini {name} {
    TC550:wrt $name "MDAM" ;# mode absolu / machine
    TC550:wrt $name "WM0" ;# coord non envoyeees par TC
    TC550:wrt $name "AP0" ;# selectionne aucun cycle
}


#proc tcMoveTo {x y} {
#    ::aligned::moveTo tc550 $x $y
#}

#proc tc_expectedPos {x y} {
#    global tc550
#    set tc550(xTheo) $x
#    set tc550(yTheo) $y
#    tc_pointeTranslate
#}

proc tc550_on {} {
    TC550:on tc550
}

proc tc550_off {} {
    TC550:off tc550
}




#proc tc_pointe {} {
#    ::aligned::corrigeIci tc550
#}

#proc tc_pointeTranslate {} {
#    ::aligned::corrigeIciTranslation tc550
#}

#proc tc_printDist {} {
#    global tc550
#    set ecarts [::isometrie::ecarts $tc550(iso)]
#    puts $ecarts
#}

#proc tc_removeFirst {} {
#    global tc550
#    ::isometrie::removeFirst $tc550(iso)
#}

#proc tc_removeWorst {} {
#    global tc550
#    ::isometrie::removeWorst $tc550(iso)
#}

#proc tc_removeLast {} {
#    global tc550
#    ::isometrie::removeLast $tc550(iso)
#}
