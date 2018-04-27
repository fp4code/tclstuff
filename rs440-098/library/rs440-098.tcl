package provide fidev_rs440-098 0.1

# 2003-09-16 repris de R.Teissier moteurs.c

namespace eval ::fidev::rs440-098 {
    variable H25_CARD 0
    variable lentille_CARD 0
    variable DH10_CARD 1
    variable FILTRE_CARD 1
    variable HR250_CARD 1
    variable shutter_CARD 1
    variable PORT 
    variable com_port 0
}

proc ::fidev::rs440-098::moteur_init {carte} {
    # Utiliser /dev/ttyS0 au lieu de /dev/cua0, obsolète
    # Cf. http://setserial.sourceforge.net/setserial-man.html
    if {$com_port == 0} {
	set PORT [open /dev/ttyS0 w+]
	fconfigure $PORT -encoding binary -translation binary -mode 9600,n,8,1 -xchar [list \021 \023]
	set com_port 1
	moteur_singleline
    }
    
    moteur_halt $carte 0
    moteur_halt $carte 1
}

proc ::fidev::rs440-098::moteur_singleline {} {
    puts -nonewline $PORT "@0\rsingleline(1)\r"
    puts -nonewline $PORT "@1\rsingleline(1)\r"
    flush $PORT
    after 1000
}

proc ::fidev::rs440-098::moteur_halt {carte axe} {
    set cmd halt($axe)
    moteur_ask $carte $cmd
}

proc ::fidev::rs440-098::moteur_ask {carte buf} {
    variable PORT
    if {[moteur_device_closed $carte]} {
	return -code error "moteur_device_closed"
    }

    flush $PORT
    moteur_write_data $carte $buf
    set askcom [moteur_read_data 128]   
}

#############################################################

proc ::fidev::rs440-098::roundEtBorne {val facteur min max} {
    set nval [expr {round($val*$facteur)}]
    if {$nval < $min} {
	set nval $min
    } elseif {$nval > $max} {
	set nval $max
    }
    return $nval
}

#########################################

proc ::fidev::rs440-098::FILTRE_init {} {
    variable FILTRE    
    moteur_init $FILTRE(CARD)
    moteur_param $FILTRE(CARD) $FILTRE(AXIS) $FILTRE(BASE) $FILTRE(TOP) $FILTRE(ACCEL)
    moteur_halt $FILTRE(CARD) $FILTRE(AXIS)
}

proc ::fidev::rs440-098::FILTRE_set_pos {pos} {
    variable FILTRE
    set newposmot [roundEtBorne $pos $FILTRE(MOT_TO_COUNT) $FILTRE(inf) $FILTRE(sup)]
    moteur_datum $FILTRE(CARD) $FILTRE(AXIS) $newposmot
}

proc ::fidev::rs440-098::FILTRE_get_pos {} {
    variable FILTRE    
    set posmot [moteur_where $FILTRE(CARD) $FILTRE(AXIS)]
    return [expr {$posmot/$FILTRE(MOT_TO_COUNT)}]
}

proc ::fidev::rs440-098::FILTRE_move {pos} {
    variable FILTRE
    set newposmot [roundEtBorne $pos $FILTRE(MOT_TO_COUNT) $FILTRE(inf) $FILTRE(sup)]
    moteur_move $FILTRE(CARD) $FILTRE(AXIS) $newposmot
}

proc ::fidev::rs440-098::FILTRE_get_count {} {
    return [FILTRE_get_pos]
}

proc ::fidev::rs440-098::FILTRE_moving {} {
    variable FILTRE
    return [moteur_moving $FILTRE(CARD) $FILTRE(AXIS)]
}

proc ::fidev::rs440-098::FILTRE_halt {} {
    variable FILTRE
    moteur_halt $FILTRE(CARD) $FILTRE(AXIS)
}

proc ::fidev::rs440-098::FILTRE_close {} {
    variable FILTRE
    moteur_close $FILTRE(CARD)
}