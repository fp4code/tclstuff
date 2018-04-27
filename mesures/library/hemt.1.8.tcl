# package provide mes_hemt 1.8

# 2007-03-07 issu de mes_bipolaire 1.8
# 2007-03-14 déverminage
# 2009-02-13 (FP) ajout IdVgsFR

# Le suffixe FR veut dire "Fixed Range"

package require smu 1.2

package require mes 0.1

set IdMaxRaisonnable 1e-3 ;# A*um-1

namespace eval ::mes::hemt {

if {![winfo exists .b]} {
    toplevel .b
    button .b.b -text exec -command {eval [.b.e get]}
    entry .b.e -width 80
    pack .b.b .b.e -side left
}

variable resumeDesMesures {

gloglo:

JdMax                 A*um-1
JdMaxRaisonnable      A*um-1
IdMax                 A
PMax                   W*um-1
VdsMax                 V
IgMax                  A
IdVdsNptsV

supertable : Ve Vb Vc Ie Ib Ic se sb sc jour heure te tb tc 
}

variable eparamsTypique {
# direct
set gloglo(JceMax)    {0.5e-3 A*um-2}
set gloglo(JbDirMax)  {0.05e-3 A*um-2}
set gloglo(VbeDirMax) {1.0 V}
set gloglo(VbcDirMax) {1.0 V}
set gloglo(IDirNptsLog) 10 
set gloglo(ILogMin)   {1e-13 A} -> IbDirMin

# inverse
set gloglo(VbeInvMax) {3.0 V}
set gloglo(VbcInvMax) {4.0 V}
set gloglo(JbeInvMax) {1e-6 A*um-2}
set gloglo(JbcInvMax) {1e-6 A*um-2}

# ibic
set gloglo(VbeIbIcMin) {0.0 V}
set gloglo(VbeIbIcMax) {1.0 V}
set gloglo(dVbeIbIc) {0.02 V}
set gloglo(VcbList) {{0.0 V} {1.0 V}} ;# positif si aide à la collection

# raccord direct-inverse
set gloglo(VbeInvDir) {0.2 V}
set gloglo(VbcInvDir) {0.2 V}
}
}

# standard
proc ::mes::hemt::3smu.ini {} {
    smuS SRQon Warning Error
    smuG SRQon Warning Error
    smuD SRQon Warning Error
    
    smuS repos
    smuG repos
    smuD repos

# choix des synchros:
# - "trigIn preSRC" indispensable pour démarrer le tout avec un seul fire
# sinon il faut faire 2 déclenchements, avec tous les risques d'overrun
# le pendant est "trigOut postMSR"
# - trigIn preDLY, sinon il y a des décalages entre appareils, surtout en IbIxFR à courant élevé
# le endant est "trigOut postSRC"
# - pas de synchro avant preMSR, parce que le délai est adapté pour chaque appareil,
# en fonction de la gamme (fixe), pour que la mesure se termine en même temps.

    smuS trigIn preSRC preDLY
    smuG trigIn preSRC preDLY
    smuD trigIn preSRC preDLY

    smuS trigOut postMSR postSRC
    smuG trigOut postMSR postSRC
    smuD trigOut postMSR postSRC


    smuS trigSweepEnd 0
    smuG trigSweepEnd 0
    smuD trigSweepEnd 0
    
    smuS trigOn ext
    smuG trigOn ext
    smuD trigOn ext

    smuS sweep 
    smuG sweep 
    smuD sweep
}

# not used
proc ::mes::hemt::3smu.mesure_not_used {args} {
    global variable_SRQ

#    puts stderr {rustine à revoir pb. K0 NRFD : on roupille 1000 ms...}
#    after 1000

    smuS operate
    smuG operate
    smuD operate
    
    smuS SRQon Warning Error ReadyForTrigger
    smuS waitRft
    smuS SRQon Warning Error SweepDone
    smuG SRQon Warning Error ReadyForTrigger
    smuG waitRft
    smuG SRQon Warning Error SweepDone
    smuD SRQon Warning Error ReadyForTrigger
    smuD waitRft
    smuD SRQon Warning Error SweepDone

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

    set aTester [list smuE smuB smuC]
    while {$aTester != {}} {
        GPIB::srqWait
        set restent [list]
        foreach smuName $aTester {
            set poll [::smu::serialPoll $smuName]
# puts stderr "while de ::smu::wait $smuName -> [format 0x%02x $poll]"
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
                    error "::smu::wait : $smuName : Warning : [::smu::warnings $smuName]"
                }
                lappend restent $smuName
            }
        }
        if {$aTester == $restent} {
            error "3smuWait : Pb. de synchro"
        } else {
            set aTester $restent
        }
    }

    smuS repos
    smuG repos
    smuD repos

    return [list $jour $heure]
}

proc ::mes::hemt::3smu.mesure {args} {
    global variable_SRQ

#   puts stderr {rustine à revoir pb. K0 NRFD : on roupille 1000 ms...}
#    after 1000

    smuS operate
    smuG operate
    smuD operate
 
puts stderr S   
    smuS SRQon Warning Error ReadyForTrigger
    smuS waitRft
    smuS SRQon Warning Error SweepDone
puts stderr G
    smuG SRQon Warning Error ReadyForTrigger
    smuG waitRft
    smuG SRQon Warning Error SweepDone
puts stderr D
    smuD SRQon Warning Error ReadyForTrigger
    smuD waitRft
    smuD SRQon Warning Error SweepDone
puts stderr OK

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

    set aTester [list smuS smuG smuD]
    while {$aTester != {}} {
        GPIB::srqWait
        set restent [list]
        foreach smuName $aTester {
            set poll [::smu::serialPoll $smuName]
# puts stderr "while de ::smu::wait $smuName -> [format 0x%02x $poll]"
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
                    error "::smu::wait : $smuName : Warning : [::smu::warnings $smuName]"
                }
                lappend restent $smuName
            }
        }
        if {$aTester == $restent} {
            error "3smuWait : Pb. de synchro"
        } else {
            set aTester $restent
        }
    }

    smuS repos
    smuG repos
    smuD repos

    return [list $jour $heure]
}



# not used
proc ::mes::hemt::iniLettres_not_used {SouD DouSVar coudVar doucVar} {
    upvar $DouSVar DouS
    upvar $coudVar coud
    upvar $dousVar dous
    switch $SouD  {
	"S" {
	    set DouS D
	    set soud s
	    set dous d
	}
	"D" {
	    set Dous D
	    set soud d
	    set dous s
	}
	default {error "incorrect SouD = \"$SouD\", should be S or D"}
    } 
}

# used
proc ::mes::hemt::debloque {} {
    smuS write "D0X" ;# sinon bloque les smus recents
    smuG write "D0X" ;# sinon bloque les smus recents
    smuD write "D0X" ;# sinon bloque les smus recents
}


# not used
proc ::mes::hemt::3smuMesAndResult_notused {sptName} {

    puts stderr [list ::mes::hemt::3smuMesAndResult $sptName]

    set retour [list $sptName]
    
    foreach {jour heure} [::mes::hemt::3smu.mesure] {}
    
    set ss [smuS litSweep]
    set sg [smuG litSweep]
    set sd [smuD litSweep]
    
    foreach x {s g d} {
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
    
    lappend retour \
	    [list \
	    @ {    Vs    } {      Vg    } {      Vd    }\
	    {      Is    } {      Ig    } {      Id    } {Itot    }\
	    {      jour} {   heure} {    ts} {    tg} {    td} Ss Sg Sd ]
    foreach s $ss g $sg d $sd {
	foreach $cs $s {}
	foreach $cg $g {}
	puts stderr [list -> $cd $d]
	foreach $cd $d {}
	set Itot [expr {$Is + $Ig + $Id}]
	lappend retour [list \
		[::smu::engVal $Vs] \
		[::smu::engVal $Vg] \
		[::smu::engVal $Vd] \
		[::smu::engVal $Is] \
		[::smu::engVal $Ig] \
		[::smu::engVal $Id] \
		[format %8.1e $Itot] \
		$jour $heure\
		[format %6d $ts] [format %6d $tg]  [format %6d $td] \
		$Ss $Sg $Sd \
		]
    }
    return $retour
}

############################
# mesures complètes 3 smus #
############################

# standard
proc ::mes::hemt::mesure {nom} {
    global gloglo
    global TC

    set commandes [list]
    foreach c $gloglo(commandesHemt) {
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

set rien {
triggers_14_juin_1999 {
    Pour un  fixedLevelSweep 2 points, trig complet, il y a 7 declenchements  a faire
    dont un dernier apres la mesure, pour que SRQ sweep done soit envoye

    S'il n'y a pas de trig-in preSRC, il faut un trig de plus en debut de rampe.
    Il vaut donc mieux mettre un trig preSRC

}

mesures_autorisees {

    III interdit: somme(I) = 0
    IIV la source de tension est typiquement 0. Une autre valeur permet de decaler les tensions
    IVV une des sources est typiquement nulle
    VVV une des sources est typiquement nulle

donc en principe:
    II0
    IV0
    VV0



diodeBE_Dir

   Ic = 0, calibre minimal, Vc compliance = 1.1 V
   Ie = 1e-12
}
}

# useable
proc ::mes::hemt::3smu.manuel {} {
    smuS trigOut none
    smuG trigOut none
    smuD trigOut none
    smuS trigIn continuous
    smuG trigIn continuous
    smuD trigIn continuous
    smuS sourceContinue 0.0
    smuG sourceContinue 0.0
    smuD sourceContinue 0.0
    GPIB::renOff
}

# 15 juin 1999 (FP)
# fixed ranges
# + innovation majeure, introduction des délais compensatoires

# not used

proc ::mes::hemt::iniIfNoFACTEURS {&loglo} {
    upvar ${&loglo} loglo
    if {![info exists loglo(MES_HEMT_SUBFACTEUR)]} {
	set loglo(MES_HEMT_SUBFACTEUR) 0.05
    }
    if {![info exists loglo(MES_HEMT_FACTEUR)]} {
	set loglo(MES_HEMT_FACTEUR) 0.5
    }
}

#used
proc ::mes::hemt::iniFR {retVarName sptName} {
    upvar $retVarName retour

    set retour [list $sptName]
    lappend retour \
	    [list \
	    @ {    Vs    } {      Vg    } {      Vd    }\
	    {      Is    } {      Ig    } {      Id    } {Itot    }\
	    {      jour} {   heure} {    ts} {    tg} {    td} Ss Sg Sd ]
}

#used
proc ::mes::hemt::3smu.mesureFR {retVarName} {
    upvar $retVarName retour

    foreach {jour heure} [::mes::hemt::3smu.mesure] {}
    
    set ss [smuS litSweep]
    set sg [smuG litSweep]
    set sd [smuD litSweep]
    
    foreach x {s g d} {
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
    foreach s $ss g $sg d $sd {
	foreach $cs $s {}
	foreach $cg $g {}
	foreach $cd $d {}
	set Itot [expr {$Is + $Ig + $Id}]
	lappend retour [list \
		[::smu::engVal $Vs] \
		[::smu::engVal $Vg] \
		[::smu::engVal $Vd] \
		[::smu::engVal $Is] \
		[::smu::engVal $Ig] \
		[::smu::engVal $Id] \
		[format %8.1e $Itot] \
		$jour $heure\
		[format %6d $ts] [format %6d $tg]  [format %6d $td] \
		$Ss $Sg $Sd \
		]
    }
}

#used
proc ::mes::hemt::IdVdsFR {Vgs args} {
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

    ::mes::hemt::debloque

    set symDes [lindex $nom end]
    
    set JdMax [mes::readUnit $gloglo(JdMax) "A*um-1"]
    if {$JdMax > $JdMaxRaisonnable} {
        error "JdMax = $JdMax > JdMaxRaisonnable = $JdMaxRaisonnable A*um-1"
    }
    
    mes::controlLimit gloglo IdMax A $symDes $JdMax
    set IgMax [mes::readUnit $gloglo(IgMax) A]

    mes::controlLimit gloglo pmax W $symDes [mes::readUnit $gloglo(PMax) W*um-1]

    set VdsMax [mes::readUnit $gloglo(VdsMax) "V"]

    puts stderr "VdsMax = $VdsMax"
    
    ::mes::hemt::iniFR retour "@@IdVds (Vgs = $Vgs) $nom"

    smuD I(V)
    smuG I(V)
    smuS I(V)
    
#    set VgsDirMax [mes::readUnit $gloglo(VgsDirMax) V]
    smuD setCompliance $IdMax -range best
    smuG setCompliance $IgMax -range best
    smuS setCompliance $IdMax -range best

    set vgrange [smuG bestRangeFromList V $Vgs]
    set vdrange  [smuD bestRangeFromList V $VdsMax]
    smuD linStair       0.0 $VdsMax $gloglo(IdVdsNptsV) 0 -range $vdrange
    smuD linStairAppend $VdsMax 0.0 $gloglo(IdVdsNptsV) 0 -range $vdrange
    set npts [smuD getSweepSize]
    smuS fixedLevelSweep 0.0 0 $npts -range 1
    smuG fixedLevelSweep $Vgs 0 $npts -range $vgrange

    ::mes::hemt::3smu.mesureFR retour

    return $retour

}

proc ::mes::hemt::IdVdsAR {Vgs args} {
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

    ::mes::hemt::debloque

    set symDes [lindex $nom end]
    
    set JdMax [mes::readUnit $gloglo(JdMax) "A*um-1"]
    if {$JdMax > $JdMaxRaisonnable} {
        error "JdMax = $JdMax > JdMaxRaisonnable = $JdMaxRaisonnable A*um-1"
    }
    
    mes::controlLimit gloglo IdMax A $symDes $JdMax
    set IgMax [mes::readUnit $gloglo(IgMax) A]

    mes::controlLimit gloglo pmax W $symDes [mes::readUnit $gloglo(PMax) W*um-1]

    set VdsMax [mes::readUnit $gloglo(VdsMax) "V"]

    puts stderr "VdsMax = $VdsMax"
    
    ::mes::hemt::iniFR retour "@@IdVds (Vgs = $Vgs) $nom"

    smuD I(V)
    smuG I(V)
    smuS I(V)
    
#    set VgsDirMax [mes::readUnit $gloglo(VgsDirMax) V]
    smuD setCompliance $IdMax -range 0
    smuG setCompliance $IgMax -range 0
    smuS setCompliance $IdMax -range 0

    set vgrange [smuG bestRangeFromList V $Vgs]
    set vdrange  [smuD bestRangeFromList V $VdsMax]
    smuD linStair       0.0 $VdsMax $gloglo(IdVdsNptsV) 0 -range $vdrange
    smuD linStairAppend $VdsMax 0.0 $gloglo(IdVdsNptsV) 0 -range $vdrange
    set npts [smuD getSweepSize]
    smuS fixedLevelSweep 0.0 0 $npts -range 1
    smuG fixedLevelSweep $Vgs 0 $npts -range $vgrange

    ::mes::hemt::3smu.mesureFR retour

    return $retour

}

proc ::mes::hemt::IdVgsFR {Vds args} {
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

    ::mes::hemt::debloque

    set symDes [lindex $nom end]
    
    set JdMax [mes::readUnit $gloglo(JdMax) "A*um-1"]
    if {$JdMax > $JdMaxRaisonnable} {
        error "JdMax = $JdMax > JdMaxRaisonnable = $JdMaxRaisonnable A*um-1"
    }
    
    mes::controlLimit gloglo IdMax A $symDes $JdMax
    set IgMax [mes::readUnit $gloglo(IgMax) A]

    mes::controlLimit gloglo pmax W $symDes [mes::readUnit $gloglo(PMax) W*um-1]

    set VgsA [mes::readUnit $gloglo(VgsA) "V"]
    set VgsB [mes::readUnit $gloglo(VgsB) "V"]

    puts stderr "VgsA = $VgsA"
    puts stderr "VgsB = $VgsB"
    
    ::mes::hemt::iniFR retour "@@IdVgs (Vds = $Vds) $nom"

    smuD I(V)
    smuG I(V)
    smuS I(V)
    
    smuD setCompliance $IdMax -range best
    smuG setCompliance $IgMax -range best
    smuS setCompliance $IdMax -range best

    set vgrange [smuG bestRangeFromList V [list $VgsA $VgsB]]
    set vdrange [smuD bestRangeFromList V $Vds]
    smuG linStair       $VgsA $VgsB $gloglo(IdVgsNptsV) 0 -range $vgrange
    smuG linStairAppend $VgsB $VgsA $gloglo(IdVgsNptsV) 0 -range $vgrange
    set npts [smuG getSweepSize]
    smuS fixedLevelSweep 0.0 0 $npts -range 1
    smuD fixedLevelSweep $Vds 0 $npts -range $vdrange

    ::mes::hemt::3smu.mesureFR retour

    return $retour

}

proc ::mes::hemt::IdVgsAR {Vds args} {
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

    ::mes::hemt::debloque

    set symDes [lindex $nom end]
    
    set JdMax [mes::readUnit $gloglo(JdMax) "A*um-1"]
    if {$JdMax > $JdMaxRaisonnable} {
        error "JdMax = $JdMax > JdMaxRaisonnable = $JdMaxRaisonnable A*um-1"
    }
    
    mes::controlLimit gloglo IdMax A $symDes $JdMax
    set IgMax [mes::readUnit $gloglo(IgMax) A]

    mes::controlLimit gloglo pmax W $symDes [mes::readUnit $gloglo(PMax) W*um-1]

    set VgsA [mes::readUnit $gloglo(VgsA) "V"]
    set VgsB [mes::readUnit $gloglo(VgsB) "V"]

    puts stderr "VgsA = $VgsA"
    puts stderr "VgsB = $VgsB"
    
    ::mes::hemt::iniFR retour "@@IdVgs (Vds = $Vds) $nom"

    smuD I(V)
    smuG I(V)
    smuS I(V)
    
    smuD setCompliance $IdMax -range 0
    smuG setCompliance $IgMax -range 0
    smuS setCompliance $IdMax -range 0

    set vgrange [smuG bestRangeFromList V [list $VgsA $VgsB]]
    set vdrange [smuD bestRangeFromList V $Vds]
    smuG linStair       $VgsA $VgsB $gloglo(IdVgsNptsV) 0 -range $vgrange
    smuG linStairAppend $VgsB $VgsA $gloglo(IdVgsNptsV) 0 -range $vgrange
    set npts [smuG getSweepSize]
    smuS fixedLevelSweep 0.0 0 $npts -range 1
    smuD fixedLevelSweep $Vds 0 $npts -range $vdrange

    ::mes::hemt::3smu.mesureFR retour

    return $retour

}

package provide mes_hemt 1.8
