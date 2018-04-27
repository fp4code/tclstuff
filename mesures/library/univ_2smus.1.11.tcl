# 2014-02-17 (FP) issu de hemt
# 2014-05-21 (FP) mes::controlLimit ->  mes::controlLimitWidth
# 2014-05-27 (FP) ajout de VIuniv
# 2014-12-15 (FP) enrichissement de IVuniv  pour IXMax et IYMax

# Le suffixe FR veut dire "Fixed Range"

set info {
}

package require smu 1.2

package require mes 0.1

set IdMaxRaisonnable 1e-3 ;# A*um-1

namespace eval ::mes::univ_2smus {

variable resumeDesMesures {

gloglo:

JdMax                 A*um-1
JdMaxRaisonnable      A*um-1
IdMax                 A
PMax                   W*um-1
VdsMax                 V

supertable : VX VY IX IY sX sY jour heure tX tY 
}
}

# standard
proc ::mes::univ_2smus::mesure {nom} {
    global gloglo
    global TC

    set commandes [list]
    foreach c $gloglo(commandes2smus) {
	lappend commandes [concat $c [list $nom]]
    }

    set ret [list]
    puts stderr [list commandes = $commandes]
    set i 0
    foreach commande $commandes {
	if {!$TC(go)} {
	    error "Arrêt demandé dans \"$nom\""
	}
	incr i
	puts stderr "#$i ------- $commande"
	if {[catch $commande resul]} {
            global errorInfo
	    puts stderr "ERREUR dans \"$commande\" : $resul\n"
            puts stderr $errorInfo
	} else {
	    set ret [concat $ret $resul]
	}
    }
    puts stderr "------- TERMINE"
    for {set i 0} {$i < 3} {incr i} bell
    return $ret
}

# standard
proc ::mes::univ_2smus::2smu.ini {} {
    smuX SRQon Warning Error
    smuY SRQon Warning Error
    
    smuX repos
    smuY repos

# choix des synchros:
# - "trigIn preSRC" indispensable pour démarrer le tout avec un seul fire
# sinon il faut faire 2 déclenchements, avec tous les risques d'overrun
# le pendant est "trigOut postMSR"
# - trigIn preDLY, sinon il y a des décalages entre appareils, surtout en IbIxFR à courant élevé
# le endant est "trigOut postSRC"
# - pas de synchro avant preMSR, parce que le délai est adapté pour chaque appareil,
# en fonction de la gamme (fixe), pour que la mesure se termine en même temps.

    smuX trigIn preSRC preDLY
    smuY trigIn preSRC preDLY

    smuX trigOut postMSR postSRC
    smuY trigOut postMSR postSRC

    smuX trigSweepEnd 0
    smuY trigSweepEnd 0
    
    smuX trigOn ext
    smuY trigOn ext

    smuX sweep 
    smuY sweep 
}


proc ::mes::univ_2smus::debloque {} {
    smuX write "D0X" ;# sinon bloque les smus recents
    smuY write "D0X" ;# sinon bloque les smus recents
}

proc ::mes::univ_2smus::iniFR {retVarName sptName} {
    upvar $retVarName retour

    set retour [list $sptName]
    lappend retour \
	    [list \
	    @ {    VX    } {      VY    }\
	    {      IX    } {      IY    }\
	    {      jour} {   heure} {    tX} {    tY} SX SY]
}
    synchro fire

proc ::mes::univ_2smus::2smu.mesure {args} {
    global variable_SRQ

#   puts stderr {rustine à revoir pb. K0 NRFD : on roupille 1000 ms...}
#    after 1000

    smuX operate
    smuY operate
 
puts stderr X   
    smuX SRQon Warning Error ReadyForTrigger
    smuX waitRft
    smuX SRQon Warning Error SweepDone
puts stderr Y
    smuY SRQon Warning Error ReadyForTrigger
    smuY waitRft
    smuY SRQon Warning Error SweepDone
puts stderr OK
    puts -nonewline stderr {delai 100}
    after 100

    if {$variable_SRQ != {}} {
        puts stderr "ERREUR : SRQ :"
        iv:testpoll
        error "ERREUR : SRQ !!!"
    }
    puts -nonewline stderr {prêt (avec un délai pour l'ancêtre)...}
    after 20
    puts stderr feu

    set jour [getJour]
    set heure [getHeure]

    synchro fire

    # pendant que l'appareil mesure, on peut faire qq chose
    if {$args != {}} {
	eval $args
    }

    set aTester [list smuX smuY]
    while {$aTester != {}} {
        puts "sqrWait avec atester = $aTester"
        GPIB::srqWait
        set restent [list]
        foreach smuName $aTester {
            set poll [::smu::serialPoll $smuName]
 puts stderr "while de ::smu::wait $smuName -> [format 0x%02x $poll]"
            if {$poll & 2} {       ;# reading done
                if {$poll & 128} { ;# compliance
                    puts stderr "$smuName : Mesure avec Compliance"
                }
                puts stderr "    SWEEP DONE : $smuName"
            } else {
                if {$poll & 32} { ;# error
                    synchro ini
                    error "::smu::wait : $smuName : Error : [::smu::errors $smuName]"
                }
                if {$poll & 1} {  ;# warning
                    synchro ini
                    error "::smu::wai::mes::univ_2smus::IVuniv t : $smuName : Warning : [::smu::warnings $smuName]"
                }
                lappend restent $smuName
            }
        }
        if {$aTester == $restent} {
            error "2smuWait : Pb. de synchro"
        } else {
            set aTester $restent
        }
    }

    puts "repos pour tous"
    smuX repos
    smuY repos

    return [list $jour $heure]
}

proc ::mes::univ_2smus::2smu.mesureFR {retVarName} {
    upvar $retVarName retour

    foreach {jour heure} [::mes::univ_2smus::2smu.mesure] {}
    
    set sX [smuX litSweep]
    set sY [smuY litSweep]
    
    foreach x {X Y} {
	set sx [set s$x]
	set tcol [lindex $sx 0]
	set s$x [lrange $sx 1 end]
	set rIV [list @ I V instant statut]
	set rVI [list @ V I instant statut]
	# Attention, à cause de $rIV et $rVI, il ne faut pas la forme "switch $tcol {...}"
	switch $tcol \
		$rIV {set c$x [list I$x V$x t$x S$x]}\
		$rVI {set c$x [list V$x I$x t$x S$x]}\
		default {error "ERROR on litSweep : \"$tcol\" should be\n\"$rIV\" or \"$rVI\""}
    }
    foreach x $sX y $sY {
	foreach $cX $x {}
	foreach $cY $y {}

	lappend retour [list \
		[::smu::engVal $VX] \
		[::smu::engVal $VY] \
		[::smu::engVal $IX] \
		[::smu::engVal $IY] \
		$jour $heure\
		[format %6d $tX] [format %6d $tY]\
		$SX $SY\
		]
    }

    smuX repos
    smuY repos
}

proc ::mes::univ_2smus::IVuniv {VXA VXB VYA VYB N args} {
    global JdMaxRaisonnable

    if {[llength $args] == 1} {
        global gloglo
	set nom [lindex $args 0]
	puts stderr [list args = $args nom = $nom]
    } elseif {[llength $args] == 3 && [lindex $args 0] == "-params"} {
	upvar \#0 [lindex $args 1] gloglo
	set nom "[lindex $args 2] -params [lindex $args 1]"
    } else { 
	return -code error "ERREUR, mauvais arguments supplémentaires \"$args\""
    }

    ::mes::univ_2smus::debloque

    set symDes [lindex $nom end]
    
    if {[info exists gloglo(IXMax)]} {
	puts "EXISTE"
	set IXMax [mes::readUnit $gloglo(IXMax) A]
    } else {
	puts "N'EXISTE PAS"
        set JXMax [mes::readUnit $gloglo(JXMax) "A*um-1"]
	mes::controlLimitWidth gloglo IXMax A $symDes $JXMax
    }

    if {[info exists gloglo(IYMax)]} {
	set IYMax [mes::readUnit $gloglo(IYMax) A]
    } else {
	set JYMax [mes::readUnit $gloglo(JYMax) "A*um-1"]
	mes::controlLimitWidth gloglo IYMax A $symDes $JYMax
    }    

    puts "$VXA $VXB $VYA $VYB $N"
    ::mes::univ_2smus::iniFR retour "@@IVuniv VX=$VXA..$VXB VY=$VYA..$VYB $nom"

    smuX I(V)
    smuY I(V)
    
    puts "smuX setCompliance $IXMax -range 0"
    
    smuX setCompliance $IXMax -range 0
    smuY setCompliance $IYMax -range 0

    set vXrange [smuX bestRangeFromList V [list $VXA $VXB]]
    set vYrange [smuY bestRangeFromList V [list $VYA $VYB]]
  
    set NN [expr {2*$N + 2}]

    if {$VXA != $VXB} {
	smuX linStair       $VXA $VXB $N 0 -range $vXrange
	smuX linStairAppend $VXB $VXA $N 0 -range $vXrange
    } else {
	smuX fixedLevelSweep $VXA 0 $NN -range $vXrange
    }
    if {$VYA != $VYB} {
	smuY linStair       $VYA $VYB $N 0 -range $vYrange
	smuY linStairAppend $VYB $VYA $N 0 -range $vYrange
    } else {
	smuY fixedLevelSweep $VYA 0 $NN -range $vYrange
    }

    ::mes::univ_2smus::2smu.mesureFR retour
    return $retour
}

proc ::mes::univ_2smus::VIuniv {IXA IXB IYA IYB N args} {

    if {[llength $args] == 1} {
        global gloglo
	set nom [lindex $args 0]
	puts stderr [list args = $args nom = $nom]
    } elseif {[llength $args] == 3 && [lindex $args 0] == "-params"} {
	upvar \#0 [lindex $args 1] gloglo
	set nom "[lindex $args 2] -params [lindex $args 1]"
	puts stderr [list args = $args nom = $nom]
    } elseif {[llength $args] == 2} {
        global gloglo
	set nom "[lindex $args 1] [lindex $args 0]"
	puts stderr [list args = $args nom = $nom]
    } else {
	return -code error "ERREUR, mauvais arguments supplémentaires \"$args\""
    }

    ::mes::univ_2smus::debloque

    set symDes [lindex $nom end]
    
    set VXMax [mes::readUnit $gloglo(VXMax) "V"]
    set VYMax [mes::readUnit $gloglo(VYMax) "V"]
       
    puts "$IXA $IXB $IYA $IYB $N"
    ::mes::univ_2smus::iniFR retour "@@IVuniv IX=$IXA..$IXB IY=$IYA..$IYB $nom"

    smuX V(I)
    smuY V(I)
    
    smuX setCompliance $VXMax -range 0
    smuY setCompliance $VYMax -range 0

    set iXrange [smuX bestRangeFromList I [list $IXA $IXB]]
    set iYrange [smuY bestRangeFromList I [list $IYA $IYB]]

    set NN [expr {2*$N + 2}]

    if {$IXA != $IXB} {
	smuX linStair       $IXA $IXB $N 0 -range $iXrange
	smuX linStairAppend $IXB $IXA $N 0 -range $iXrange
    } else {
	smuX fixedLevelSweep $IXA 0 $NN -range $iXrange
    }
    if {$IYA != $IYB} {
	smuY linStair       $IYA $IYB $N 0 -range $iYrange
	smuY linStairAppend $IYB $IYA $N 0 -range $iYrange
    } else {
	smuY fixedLevelSweep $IYA 0 $NN -range $iYrange
    }

    ::mes::univ_2smus::2smu.mesureFR retour
    return $retour
}

package provide mes_univ_2smus 1.11
