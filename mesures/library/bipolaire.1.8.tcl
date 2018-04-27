package provide mes_bipolaire 1.8

# Version 1.7 : Introduction de "-params glogloSpecial"
#               Passage de MES_BIPOLAIRE_FACTEUR MES_BIPOLAIRE_SUBFACTEUR dans gloglo

# Version 1.8 : possibilité de PNP
#               (2004-02-03) déplacement de quelques procédures dans mes.0.1.tcl

# Le suffixe FR veut dire "Fixed Range"
# 2010-0616 (FP) ajout de repos dans 3smu.mesureFR

package require smu 1.2

package require mes 0.1

namespace eval ::mes::bipolaire {

if {![winfo exists .b]} {
    toplevel .b
    button .b.b -text exec -command {eval [.b.e get]}
    entry .b.e -width 80
    pack .b.b .b.e -side left
}

variable resumeDesMesures {
diode BE : Ve, Ib, Vc // Ie = -(IbDirMin=IlogMin) .. -(IbDirMax) log(IbDirNptsLog),    Vb = 0, Ic = 0 // Ve:VbeDirMax Ib:1.5*IbDirMax Vc:VbcInvMax 
           Ie, Ib, Vc // Ve = -(VbeInvDir) .. +(VbeInvMax) dVbe, Vb = 0, Ic = 0 // Ie:IbeInvMax Ib:IbeInvMax     Vc:VbcInvMax

diode BC : Ve, Ib, Vc // Ie = 0, Vb = 0, Ic = -(IbDirMin=IlogMin) .. -(IbDirMax) log    // Ve:VbeInvMax Ib:1.5*IbDirMax Vc:VbcDirMax 
           Ve, Ib, Ic // Ie = 0, Vb = 0, Vc = -(VbcInvDir) .. +(VbcInvMax) dVbc // Ve:VbeInvMax Ib:IbcInvMax     Ic:IbcInvMax

ibic     : Ie, Ib, Ic // Ve = -(VbeIbIcMin) .. -(VbeIbIcMax) -(dVbeIbIc), Vb = 0, Vc = (VcbList) // Ie:IceMax , Ib:IbDirMax, Ic:IceMax

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


proc ::mes::bipolaire::3smu.ini {} {
    smuE SRQon Warning Error
    smuB SRQon Warning Error
    smuC SRQon Warning Error
    
    smuE repos
    smuB repos
    smuC repos

# choix des synchros:
# - "trigIn preSRC" indispensable pour démarrer le tout avec un seul fire
# sinon il faut faire 2 déclenchements, avec tous les risques d'overrun
# le pendant est "trigOut postMSR"
# - trigIn preDLY, sinon il y a des décalages entre appareils, surtout en IbIxFR à courant élevé
# le endant est "trigOut postSRC"
# - pas de synchro avant preMSR, parce que le délai est adapté pour chaque appareil,
# en fonction de la gamme (fixe), pour que la mesure se termine en même temps.

    smuE trigIn preSRC preDLY
    smuB trigIn preSRC preDLY
    smuC trigIn preSRC preDLY

    smuE trigOut postMSR postSRC
    smuB trigOut postMSR postSRC
    smuC trigOut postMSR postSRC


    smuE trigSweepEnd 0
    smuB trigSweepEnd 0
    smuC trigSweepEnd 0
    
    smuE trigOn ext
    smuB trigOn ext
    smuC trigOn ext

    smuE sweep 
    smuB sweep 
    smuC sweep
}


proc ::mes::bipolaire::3smu.mesure {args} {
    global variable_SRQ

#    puts stderr {rustine à revoir pb. K0 NRFD : on roupille 1000 ms...}
#    after 1000

    smuE operate
    smuB operate
    smuC operate
    
    smuE SRQon Warning Error ReadyForTrigger
    smuE waitRft
    smuE SRQon Warning Error SweepDone
    smuB SRQon Warning Error ReadyForTrigger
    smuB waitRft
    smuB SRQon Warning Error SweepDone
    smuC SRQon Warning Error ReadyForTrigger
    smuC waitRft
    smuC SRQon Warning Error SweepDone

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

    smuE repos
    smuB repos
    smuC repos

    return [list $jour $heure]
}



proc ::mes::bipolaire::iniLettres {EouC CouEVar eoucVar coueVar} {
    upvar $CouEVar CouE
    upvar $eoucVar eouc
    upvar $coueVar coue
    switch $EouC  {
	"E" {
	    set CouE C
	    set eouc e
	    set coue c
	}
	"C" {
	    set CouE E
	    set eouc c
	    set coue e
	}
	default {error "incorrect EouC = \"$EouC\", should be E or C"}
    } 
}

proc ::mes::bipolaire::debloque {} {
    smuE write "D0X" ;# sinon bloque les smus recents
    smuB write "D0X" ;# sinon bloque les smus recents
    smuC write "D0X" ;# sinon bloque les smus recents
}

proc ::mes::bipolaire::3smuMesAndResult {sptName} {

    puts stderr [list ::mes::bipolaire::3smuMesAndResult $sptName]

    set retour [list $sptName]
    
    foreach {jour heure} [::mes::bipolaire::3smu.mesure] {}
    
    set se [smuE litSweep]
    set sb [smuB litSweep]
    set sc [smuC litSweep]
    
    foreach x {e b c} {
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
	    @ {    Ve    } {      Vb    } {      Vc    }\
	    {      Ie    } {      Ib    } {      Ic    } {Itot    }\
	    {      jour} {   heure} {    te} {    tb} {    tc} Se Sb Sc ]
    foreach e $se b $sb c $sc {
	foreach $ce $e {}
	foreach $cb $b {}
	foreach $cc $c {}
	set Itot [expr {$Ie + $Ib + $Ic}]
	lappend retour [list \
		[::smu::engVal $Ve] \
		[::smu::engVal $Vb] \
		[::smu::engVal $Vc] \
		[::smu::engVal $Ie] \
		[::smu::engVal $Ib] \
		[::smu::engVal $Ic] \
		[format %8.1e $Itot] \
		$jour $heure\
		[format %6d $te] [format %6d $tb]  [format %6d $tc] \
		$Se $Sb $Sc \
		]
    }
    return $retour
}

############################
# mesures complètes 3 smus #
############################

proc ::mes::bipolaire::mesure {nom} {
    global gloglo
    global TC

    set commandes [list]
    foreach c $gloglo(commandesBipolaire) {
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

proc 3smu.manuel {} {
    smuE trigOut none
    smuB trigOut none
    smuC trigOut none
    smuE trigIn continuous
    smuB trigIn continuous
    smuC trigIn continuous
    smuE sourceContinue 0.0
    smuB sourceContinue 0.0
    smuC sourceContinue 0.0
    GPIB::renOff
}

# 15 juin 1999 (FP)
# fixed ranges
# + innovation majeure, introduction des délais compensatoires

proc ::mes::bipolaire::iniIfNoFACTEURS {&loglo} {
    upvar ${&loglo} loglo
    if {![info exists loglo(MES_BIPOLAIRE_SUBFACTEUR)]} {
	set loglo(MES_BIPOLAIRE_SUBFACTEUR) 0.05
    }
    if {![info exists loglo(MES_BIPOLAIRE_FACTEUR)]} {
	set loglo(MES_BIPOLAIRE_FACTEUR) 0.5
    }
}

proc ::mes::bipolaire::iniFR {retVarName sptName} {
    upvar $retVarName retour

    set retour [list $sptName]
    lappend retour \
	    [list \
	    @ {    Ve    } {      Vb    } {      Vc    }\
	    {      Ie    } {      Ib    } {      Ic    } {Itot    }\
	    {      jour} {   heure} {    te} {    tb} {    tc} Se Sb Sc ]
}

proc ::mes::bipolaire::3smu.mesureFR {retVarName} {
    upvar $retVarName retour

    foreach {jour heure} [::mes::bipolaire::3smu.mesure] {}
    
    set se [smuE litSweep]
    set sb [smuB litSweep]
    set sc [smuC litSweep]
    
    foreach x {e b c} {
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
    foreach e $se b $sb c $sc {
	foreach $ce $e {}
	foreach $cb $b {}
	foreach $cc $c {}
	set Itot [expr {$Ie + $Ib + $Ic}]
	lappend retour [list \
		[::smu::engVal $Ve] \
		[::smu::engVal $Vb] \
		[::smu::engVal $Vc] \
		[::smu::engVal $Ie] \
		[::smu::engVal $Ib] \
		[::smu::engVal $Ic] \
		[format %8.1e $Itot] \
		$jour $heure\
		[format %6d $te] [format %6d $tb]  [format %6d $tc] \
		$Se $Sb $Sc \
		]
    }
    smuE repos
    smuB repos
    smuC repos
}

proc ::mes::bipolaire::diodeBx_DirFR {EouC args} {
    global JceMaxRaisonnable

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

    ::mes::bipolaire::iniLettres $EouC CouE eouc coue
    ::mes::bipolaire::debloque

    # contrôle si le courant de base n'est pas aberrant
    set JbDirMax [mes::readUnit $gloglo(JbDirMax) "A*um-2"]
    if {$JbDirMax > $JceMaxRaisonnable} {
        error "JbDirMax = $JbDirMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }
   
    set symDes [lindex $nom end]

    mes::controlLimit gloglo IbDirMax A $symDes $JbDirMax

    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    set VbcDirMax [mes::readUnit $gloglo(VbcDirMax) V]

    smuE V(I)
    smuB I(V)
    smuC V(I)

    set idirmin [expr {-[mes::readUnit $gloglo(ILogMin) A]}]
    set idirmax [expr {-$IbDirMax}]

    # aller-retour
    ::mes::bipolaire::iniIfNoFACTEURS gloglo
    set ilist [smuE splitIRange $idirmin $idirmax $gloglo(MES_BIPOLAIRE_FACTEUR) $gloglo(MES_BIPOLAIRE_SUBFACTEUR)]
    set ilist [concat $ilist [smuE splitIRange $idirmax $idirmin $gloglo(MES_BIPOLAIRE_FACTEUR) $gloglo(MES_BIPOLAIRE_SUBFACTEUR)]]

    smuE setCompliance $VbeDirMax -range best
    smuC setCompliance $VbcDirMax -range best

    ::mes::bipolaire::iniFR retour "@@diodeB$EouC Dir (I${coue}=0) $nom"

    foreach e $ilist {
	set range [lindex $e 2]
	set delay [expr {$::smu::DefaultDelay(1) - $::smu::DefaultDelay($range)}]
	smu$EouC logStair [lindex $e 0] [lindex $e 1] $gloglo(IDirNptsLog) $delay -range $range
	set npts [smu$EouC getSweepSize]
	smuB fixedLevelSweep 0.0 $delay $npts -range 1
	smuB setCompliance [lindex $::smu::IRangeValues($::smu::Modele(smuB)) $range] -range $range
	smu$CouE fixedLevelSweep 0.0 0 $npts -range 1 ;# range 1 en courant.
	
	::mes::bipolaire::3smu.mesureFR retour
    }
    return $retour
}

proc ::mes::bipolaire::IbIxFR {EouC Vxb args} {
    return [::mes::bipolaire::IbIxFRv2 1 1 $EouC $Vxb $args]
}

set HELP(::mes::bipolaire::IbIxFRv2) {

}
proc ::mes::bipolaire::IbIxFRv2 {rangeFact_B rangeFact_CouE EouC Vxb args} {
    global JceMaxRaisonnable

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

    if {[info exists gloglo(type_de_bipolaire)]} {
	switch $gloglo(type_de_bipolaire) {
	    NPN {set polar [expr {1}]; set polarinv [expr {-1}]; set spolar ""}
	    PNP {set polar [expr {-1}]; set polarinv [expr {1}]; set spolar "-"}
	    default {return -code error "La valeur \"$gloglo(type_de_bipolaire)\" de \"type_de_bipolaire\" est incorrecte. Les valeurs autorisées sont \"NPN\" ou \"PNP\""}
	}
    } else {
	set polar [expr {1.0}]
	set polarinv [expr {-1.0}]
	set spolar ""
    }

    ::mes::bipolaire::iniLettres $EouC CouE eouc coue
    ::mes::bipolaire::debloque

    # contrôle si le courant de base n'est pas aberrant
    set JbDirMax [mes::readUnit $gloglo(JbDirMax) "A*um-2"]
    if {$JbDirMax > $JceMaxRaisonnable} {
        error "JbDirMax = $JbDirMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }

    set JceMax [mes::readUnit $gloglo(JceMax) "A*um-2"]
    if {$JceMax > $JceMaxRaisonnable} {
        error "JceMax = $JceMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }
    
    set symDes [lindex $nom end]

    mes::controlLimit gloglo IbDirMax A $symDes $JbDirMax
    mes::controlLimit gloglo IceMax A $symDes $JceMax

    set PMax [mes::readUnit $gloglo(PMax) W*um-2]

    mes::controlLimit gloglo pmax W $symDes $PMax

    if {$Vxb != 0.0} {
	set IceMaxFromP [expr {$pmax/abs($Vxb)}] ;# abs c'est n'importe quoi, mais tant pis
	if {$IceMax > $IceMaxFromP} {
	    puts stderr "Puissance limite atteinte !"
	    set IceMax $IceMaxFromP
	}
    }

    puts stderr "IceMax = $IceMax"

    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    set VbcDirMax [mes::readUnit $gloglo(VbcDirMax) V]

    smu$EouC V(I)
    smuB     I(V)
    smu$CouE I(V)

    smu$EouC setCompliance [mes::readUnit $gloglo(Vb${eouc}DirMax) V]
    smuB     setCompliance [expr {1.5*$IbDirMax}]
    smu$CouE setCompliance $IceMax

    set idirmin [expr {$polarinv*[mes::readUnit $gloglo(ILogMin) A]}]
    set idirmax [expr {$polarinv*$IceMax}]

    # aller-retour
    ::mes::bipolaire::iniIfNoFACTEURS gloglo
    set ilist [smu$EouC splitIRange $idirmin $idirmax $gloglo(MES_BIPOLAIRE_FACTEUR) $gloglo(MES_BIPOLAIRE_SUBFACTEUR)]
    set ilist [concat $ilist [smu$EouC splitIRange $idirmax $idirmin $gloglo(MES_BIPOLAIRE_FACTEUR) $gloglo(MES_BIPOLAIRE_SUBFACTEUR)]]

    set VbxDirMax [set Vb${eouc}DirMax]
    # gamme fixe
    smu$EouC setCompliance $VbxDirMax -range best

    ::mes::bipolaire::iniFR retour "@@IbI${coue} (${spolar}V${coue} = $Vxb) $nom"

    foreach e $ilist {
	set range [lindex $e 2]
	if {$range >= 10} {
	    puts stderr "ERREUR, PATCH INUTILE NORMALEMENT range 10->9"
	    set range 9
	}
	# $range est la gamme de courant $EouC, et $CouE
	set imaxrange [lindex $::smu::IRangeValues($::smu::Modele(smu$EouC)) $range]
	# $imaxrange est le courant max délivrable sur la gamme $range
        set imax_B [expr {$rangeFact_B*$imaxrange}]
	set imax_B [expr {$imax_B<$IbDirMax?$imax_B:$IbDirMax}]
        puts stderr "rangeFact=$rangeFact_CouE, imaxrange=$imaxrange"
        set imax_CouE [expr {$rangeFact_CouE*$imaxrange}]
	# $imax_B est le courant max sur la base
	set range_B [smuB bestRangeFromList I $imax_B]
	set range_CouE [smu$CouE bestRangeFromList I $imax_CouE]
	set delay_B [expr {$::smu::DefaultDelay($range_B) - $::smu::DefaultDelay($range)}]
	set delay_CouE [expr {$::smu::DefaultDelay($range_CouE) - $::smu::DefaultDelay($range)}]
        if {$delay_B < 0} {
            set delay 0
        } else {
            set delay $delay_B
        }
        if {$delay_CouE > $delay} {
            set delay $delay_CouE
        }
	smu$EouC logStair [lindex $e 0] [lindex $e 1] $gloglo(IDirNptsLog) $delay -range $range
	set npts [smu$EouC getSweepSize]
	smuB     fixedLevelSweep 0.0 0 $npts -range 1
	smuB     setCompliance $imax_B -range $range_B
	smu$CouE fixedLevelSweep [expr {$polar*$Vxb}] $delay $npts -range [::smu::bestVRange smu$CouE $Vxb]
	puts stderr "smu$CouE setCompliance $imax_CouE -range $range_CouE"
	smu$CouE setCompliance $imax_CouE -range $range_CouE
        
	::mes::bipolaire::3smu.mesureFR retour
    }
    return $retour
}

proc ::mes::bipolaire::IbIxFRLowCur {rangeFact_B rangeFact_CouE EouC Vxb args} {
    global JceMaxRaisonnable


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

    ::mes::bipolaire::iniLettres $EouC CouE eouc coue
    ::mes::bipolaire::debloque

    # contrôle si le courant de base n'est pas aberrant
    set JbDirMax [mes::readUnit $gloglo(JbDirMax) "A*um-2"]
    if {$JbDirMax > $JceMaxRaisonnable} {
        error "JbDirMax = $JbDirMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }

    set JceMax [mes::readUnit $gloglo(JceMax) "A*um-2"]
    if {$JceMax > $JceMaxRaisonnable} {
        error "JceMax = $JceMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"    }
    
    set symDes [lindex $nom end]

    mes::controlLimit gloglo IbDirMax A $symDes $JbDirMax
    mes::controlLimit gloglo IceMax A $symDes $JceMax

    set PMax [mes::readUnit $gloglo(PMax) W*um-2]

    mes::controlLimit gloglo pmax W $symDes $PMax

    if {$Vxb != 0.0} {
	set IceMaxFromP [expr {$pmax/abs($Vxb)}] ;# abs c'est n'importe quoi, mais tant pis
	if {$IceMax > $IceMaxFromP} {
	    puts stderr "Puissance limite atteinte !"
	    set IceMax $IceMaxFromP
	}
    }
    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    set VbcDirMax [mes::readUnit $gloglo(VbcDirMax) V]

    ::mes::bipolaire::iniFR retour "@@IbI${coue} LowCur (V${coue} = $Vxb) $nom"
    
    smu$EouC I(V)
    smuB I(V)
    smu$CouE I(V)

    smu$EouC setCompliance 1e-9 -range 1
    smuB     setCompliance 1e-9 -range 1
    smu$EouC setCompliance 1e-9 -range 1

    set vDirMin [expr {-[mes::readUnit $gloglo(Vb${eouc}LowCurMin) V]}]
    set vDirMax [expr {-[mes::readUnit $gloglo(Vb${eouc}LowCurMax) V]}]
    set dVb [expr {-[mes::readUnit $gloglo(dVb${eouc}) V]}]
    set delay 0

    smu$EouC linStairStep       $vDirMin $vDirMax   $dVb $delay
    smu$EouC linStairStepAppend $vDirMax $vDirMin [mes::negVal $dVb] $delay
    set npts [smu$EouC getSweepSize]
    smuB     fixedLevelSweep 0.0 0 $npts -range 1
    smu$CouE fixedLevelSweep $Vxb $delay $npts -range [::smu::bestVRange smu$CouE $Vxb]
    ::mes::bipolaire::3smu.mesureFR retour

    return $retour
}


# à réécrire pour un vrai FR

proc ::mes::bipolaire::diodeBx_InvFR {EouC args} {

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


    ::mes::bipolaire::iniLettres $EouC CouE eouc coue
    ::mes::bipolaire::debloque

    set symDes [lindex $nom end]

    mes::controlLimit gloglo IbInvMax A $symDes [mes::readUnit $gloglo(J${eouc}InvMax) A*um-2]

    # dans cette config., n'y a-t-il pas un risque de dériver
    # vers des potentiels fous qui déclencheront une compliance ?

    smu$EouC I(V)
    smuB     I(V)
    smu$CouE V(I)

    set vDirRacc [expr {-[mes::readUnit $gloglo(Vb${eouc}DirRaccord) V]}]
    set vInvMax  [expr {[mes::readUnit $gloglo(Vb${eouc}InvMax) V]}]
    set step [mes::readUnit $gloglo(dVb${eouc}Inv) V]

    set vInvMaxRange [smuB bestVRange $vInvMax -code]
    set IbInvMaxRange [smuB bestIRange $IbInvMax -code]

    smu$EouC setCompliance $IbInvMax -range $IbInvMaxRange
    smuB     setCompliance $IbInvMax -range $IbInvMaxRange
    smu$CouE setCompliance $vInvMax  -range $vInvMaxRange


    smu$EouC linStairStep       $vDirRacc $vInvMax   $step 0 -range $vInvMaxRange
#    if {$EouC == "C"} {
#	puts -nonewline stderr {rustine à revoir pb. K0 NRFD : on roupille 500 ms...}
#	after 500
#    }
    smu$EouC linStairStepAppend $vInvMax  $vDirRacc [mes::negVal $step] 0 -range $vInvMaxRange
#    if {$EouC == "C"} {
#	puts -nonewline stderr {rustine à revoir pb. K0 NRFD : on roupille 500 ms...}
#	after 500
#    }
    set npts [smu$EouC getSweepSize]
    smuB     fixedLevelSweep 0.0 0.0 $npts -range $vInvMaxRange
# sans range, c'est long !
# 2005-02-22 changement pour imposer la gamme la meilleure    smu$CouE fixedLevelSweep 0.0 0.0 $npts -range $IbInvMaxRange
    smu$CouE fixedLevelSweep 0.0 0.0 $npts -range [smu$CouE bestIRange 0 -code]

    return [::mes::bipolaire::3smuMesAndResult "@@diodeB$EouC Inv (I${coue}=0) $nom"]
}


proc ::mes::bipolaire::IcVceFR {IbFractionDeIceMax betaMax args} {
    global JceMaxRaisonnable

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

    ::mes::bipolaire::debloque

    set symDes [lindex $nom end]
    
    set JceMax [mes::readUnit $gloglo(JceMax) "A*um-2"]
    if {$JceMax > $JceMaxRaisonnable} {
        error "JceMax = $JceMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }
    
    mes::controlLimit gloglo IceMax A $symDes $JceMax
    set Ib [expr {$IbFractionDeIceMax*$IceMax}]

    # contrôle si le courant de base n'est pas aberrant
    set surface [::masque::getSurface $symDes]
    set Jb [expr {$Ib/$surface}]
    if {$Jb > $JceMaxRaisonnable} {
        error "Jb = $Jb > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }

    set IcMax [expr {$Ib*$betaMax}]

    mes::controlLimit gloglo IcMax2 A $symDes $JceMax

    if {$IcMax > $IcMax2} {
	set IcMax $IcMax2
    }

    mes::controlLimit gloglo pmax W $symDes [mes::readUnit $gloglo(PMax) W*um-2]

    set VceMax [expr {$pmax/$IcMax}]
    set VceMax2 [mes::readUnit $gloglo(VbcInvMax) V]
    if {$VceMax > $VceMax2} {
	set VceMax $VceMax2
    }

    puts stderr "VceMax = $VceMax"
    
    ::mes::bipolaire::iniFR retour "@@IcVce (Ib = $Ib) $nom"

    # contrôle en Ic<=0

    smuE I(V)
    smuB V(I)
    smuC V(I)
    
    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    smuE setCompliance [expr {2.0*$Ib}] -range best
    smuB setCompliance $VbeDirMax -range best
    smuC setCompliance $VbeDirMax -range best

    set ibrange [smuB bestRangeFromList I $Ib]
    smuC linStair       [mes::negVal $Ib] 0.0 $gloglo(IcVceNptsIm) 0 -range $ibrange
    smuC linStairAppend 0.0 [mes::negVal $Ib] $gloglo(IcVceNptsIm) 0 -range $ibrange
    set npts [smuC getSweepSize]
    smuE fixedLevelSweep 0.0 0 $npts -range 1
    smuB fixedLevelSweep $Ib 0 $npts -range $ibrange

    ::mes::bipolaire::3smu.mesureFR retour

    # contrôle en Ic>=0

    smuE I(V)
    smuB V(I)
    smuC V(I)
    
    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    smuE setCompliance $IcMax -range best
    smuB setCompliance $VbeDirMax -range best
    smuC setCompliance $VceMax -range best

    set ibrange [smuB bestRangeFromList I $Ib]
    set icrange [smuC bestRangeFromList I $IcMax]
    smuC linStair       0.0 $IcMax $gloglo(IcVceNptsIp) 0 -range $icrange
    smuC linStairAppend $IcMax 0.0 $gloglo(IcVceNptsIp) 0 -range $icrange
    set npts [smuC getSweepSize]
    smuE fixedLevelSweep 0.0 0 $npts -range 1
    smuB fixedLevelSweep $Ib 0 $npts -range $ibrange

    ::mes::bipolaire::3smu.mesureFR retour

    # contrôle en Vc>=0

    smuE I(V)
    smuB V(I)
    smuC I(V)
    
    set VbeDirMax [mes::readUnit $gloglo(VbeDirMax) V]
    smuE setCompliance $IcMax -range best
    smuB setCompliance $VbeDirMax -range best
    smuC setCompliance $IcMax -range best

    set ibrange [smuB bestRangeFromList I $Ib]
    set vcrange [smuC bestRangeFromList V $VceMax]
    smuC linStair       0.0 $VceMax $gloglo(IcVceNptsV) 0 -range $vcrange
    smuC linStairAppend $VceMax 0.0 $gloglo(IcVceNptsV) 0 -range $vcrange
    set npts [smuC getSweepSize]
    smuE fixedLevelSweep 0.0 0 $npts -range 1
    smuB fixedLevelSweep $Ib 0 $npts -range $ibrange

    ::mes::bipolaire::3smu.mesureFR retour

    return $retour

}

proc ::mes::bipolaire::diodeBx_Dir_PretriFR {EouC args} {
    global JceMaxRaisonnable
    global variable_SRQ

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

    ::mes::bipolaire::iniLettres $EouC CouE eouc coue
    ::mes::bipolaire::debloque

    # contrôle si le courant de base n'est pas aberrant
    set JbDirMax [mes::readUnit $gloglo(JbDirMax) "A*um-2"]
    if {$JbDirMax > $JceMaxRaisonnable} {
        error "JbDirMax = $JbDirMax > JceMaxRaisonnable = $JceMaxRaisonnable A*um-2"
    }
    
    set symDes [lindex $nom end]

    mes::controlLimit gloglo IbDirMax A $symDes $JbDirMax

    smuE SRQon Error Warning
    smuB SRQon Error Warning
    smuC SRQon Error Warning

    smuE I(V)
    smuC I(V)

    smuB     V(I)

    smuE dc 
    smuC dc
    smuB sweep

    smuE setCompliance 0.1 -range best
    smuC setCompliance 0.1 -range best

    smuB setCompliance [mes::readUnit $gloglo(Vb${eouc}DirMax) V] -range best

    set idirmin [mes::readUnit $gloglo(ILogMin) A]
    set idirmax $IbDirMax

    smuB trigIn continuous

    smuB logStair       $idirmin $idirmax 5 0 ;# -range 1mA
    smuB logStairAppend $idirmax $idirmin 5 0 ;# -range 1mA

    smu${EouC}     sourceContinue 0


    smuB trigOn get
    smuB operate

    smuB SRQon Warning Error ReadyForTrigger
    smuB waitRft
    smuB SRQon Warning Error SweepDone
    if {$variable_SRQ != {}} {
        puts stderr "ERREUR : SRQ :"
        iv:testpoll
        error "ERREUR : SRQ !!!"
    }

    set jour [getJour]
    set heure [getHeure]
    smuB declenche

    smuE repos
    smuB repos
    smuC repos

    set sx [smuB litSweep]

    if {[lindex $sx 0] != [list @ I V instant statut]} {
         error "conflit mes.bipolaire.diodeBx_Dir_PretriFR/::smu::litSweep sur smuB"
    }
    
    set sx [lrange $sx 1 end]
    
    set retour [list "@@diodeB$EouC Dir Pretri(Vb${coue}=0 ou I${coue}=0) $nom"]
    lappend retour \
        [list @ "    Vb$eouc   " {      Ib    } {      jour} {   heure} {    t } status ]
    foreach x $sx {
	foreach {I V t s} $x {} 
	lappend retour [list \
		[::smu::engVal $V]\
		[::smu::engVal $I]\
		$jour $heure\
		[format %6d $t]\
		$s\
		]
    }
    return $retour
}
