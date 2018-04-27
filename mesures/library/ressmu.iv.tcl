# 1 juillet 1999: modif de mes.ser pour compatibilité avec "3smus"
# 11 septembre 2000: ajout de mesures en 2 smus V(I)
# 1 juin 2010 (FP): rien fait pour résoudre le pb. du premier point
# 22 septembre 2011 (FP) : ajout de la date 
# 22 septembre 2011 (FP) correction pb. du premier point (compliance sum0)
# 2014-07-29 (FP) correction de mes.res

proc mes.res {nom} {
    global temperature gloglo

    set mesures [list "@@T:$nom"]
    mes.temperature
    lappend mesures {@ T(K) date}
    lappend mesures [list $temperature  [clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]]
    lappend mesures "@@mes.res-$nom"
    set smu $gloglo(smu)
    set smu0 $gloglo(smu0)
    
    $smu write "D0X" ;# ca peut faire du bien
    $smu0 write "D0X" ;# ca peut faire du bien

    $smu poll
    $smu0 poll

    $smu I(V)
    $smu0 I(V)
  
    set idm [expr abs($gloglo(-idmax))]
    set idp [expr abs($gloglo(+idmax))]
    set iamax [expr {$idm>$idp ? $idm : $idp}]
    $smu setCompliance [expr $idm>$idp ? $idm : $idp]

#  1000 smu.sweep.delay :=
#  1.0e-9 \ courant chargeant 50pF sous 2V en 0.1s

    $smu0 sourceContinue 0.0
    set iamax0 [expr {2.0*$iamax}]
    if {$iamax0 > 0.1} {
	puts stderr "limite 100 mA pour smu0, risque de premier point aberrant"
	set iamax0 0.1
    }
    $smu0 setCompliance $iamax0 -range best

    $smu linStair $gloglo(-vdmax) $gloglo(+vdmax) $gloglo(ressmu.npts) $gloglo(ressmu.delay)
    $smu linStairAppend $gloglo(+vdmax) $gloglo(-vdmax) $gloglo(ressmu.npts) $gloglo(ressmu.delay)
     
    $smu operate
    $smu declenche
    $smu repos
    $smu0 repos
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    return $mesures
}

# double le nombre de points par rapport à mes.res
proc mes.res.from0 {nom} {
    global temperature gloglo

    set mesures [list "@@T:$nom"]
    mes.temperature
    lappend mesures {@ T(K) date}
    lappend mesures [list $temperature  [clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]]
    lappend mesures "@@mes.res.from0-$nom"
    set smu $gloglo(smu)
    set smu0 $gloglo(smu0)
    
    $smu write "D0X" ;# ca peut faire du bien
    $smu0 write "D0X" ;# ca peut faire du bien

    $smu poll
    $smu0 poll

    $smu I(V)
    $smu0 I(V)
  
    set idm [expr abs($gloglo(-idmax))]
    set idp [expr abs($gloglo(+idmax))]
    set iamax [expr {$idm>$idp ? $idm : $idp}]
    $smu setCompliance [expr $idm>$idp ? $idm : $idp]

#  1000 smu.sweep.delay :=
#  1.0e-9 \ courant chargeant 50pF sous 2V en 0.1s

    $smu0 sourceContinue 0.0
    set iamax0 [expr {2.0*$iamax}]
    if {$iamax0 > 0.1} {
	puts stderr "limite 100 mA pour smu0, risque de premier point aberrant"
	set iamax0 0.1
    }
    $smu0 setCompliance $iamax0 -range best

    set nn1 $gloglo(ressmu.npts)
    set nn2 [expr {2*$nn1-1}]
    $smu linStair       0               $gloglo(+vdmax) $nn1 $gloglo(ressmu.delay)
    $smu linStairAppend $gloglo(+vdmax) $gloglo(-vdmax) $nn2 $gloglo(ressmu.delay)
    $smu linStairAppend $gloglo(-vdmax) 0               $nn1 $gloglo(ressmu.delay)
     
    $smu operate
    $smu declenche
    $smu repos
    $smu0 repos
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    return $mesures
}

# 1 juillet 1999: modif de mes.ser pour compatibilité avec "3smus"
# 29 novembre 2002 : fixed range

proc mes.ser {nom} {
    global temperature gloglo

    set mesures [list "@@T:$nom"]
    mes.temperature
    lappend mesures {@ T(K) date}
    lappend mesures [list $temperature  [clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]]
    lappend mesures "@@mes.ser-$nom"
    set smu $gloglo(smu)
    set smu0 $gloglo(smu0)
    
    $smu write "D0X" ;# ca peut faire du bien
    $smu0 write "D0X" ;# ca peut faire du bien

    $smu poll
    $smu0 poll

    $smu V(I)
    $smu0 I(V)

    set vdm [expr {abs($gloglo(-vdmax))}]
    set vdp [expr {abs($gloglo(+vdmax))}]
    set vamax [expr {$vdm>$vdp ? $vdm : $vdp}]

    set idm [expr {abs($gloglo(-idmax))}]
    set idp [expr {abs($gloglo(+idmax))}]
    set iamax [expr {$idm>$idp ? $idm : $idp}]

    $smu0 sourceContinue 0.0
    set iamax0 [expr {2.0*$iamax}]
    if {$iamax0 > 0.1} {
	puts stderr "limite 100 mA pour smu0, risque de premier point aberrant"
	set iamax0 0.1
    }
    $smu0 setCompliance $iamax0 -range best
   
    $smu setCompliance $vamax -range best

    # Pb. premier point pas resolu, ajout de fixed 2011-09-22 (FP)
    set irange [$smu bestIRange $iamax -code]
    $smu linStair $gloglo(-idmax) $gloglo(+idmax) $gloglo(ressmu.npts) 0  -range $irange
    $smu linStairAppend $gloglo(+idmax) $gloglo(-idmax) $gloglo(ressmu.npts) 0 -range $irange
     
    $smu operate
    $smu declenche
    $smu repos
    $smu0 repos
    # lappend mesures {@ instant statut I V}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot $mesure 3 2 x y mes
    return $mesures
}

# 2011-03-22 supprimer
proc mes.debug {nom} {
    global temperature gloglo

    puts "nom = \"$nom\""
    
    set mesures [list "@@mes.ser-$nom"]
    set smu $gloglo(smu)
    set smu0 $gloglo(smu0)
    
    $smu write "D0X" ;# ca peut faire du bien
    $smu0 write "D0X" ;# ca peut faire du bien

    $smu poll
    $smu0 poll

    $smu V(I)
    $smu0 I(V)

    set vdm [expr {abs($gloglo(-vdmax))}]
    set vdp [expr {abs($gloglo(+vdmax))}]
    set vamax [expr {$vdm>$vdp ? $vdm : $vdp}]

    set idm [expr {abs($gloglo(-idmax))}]
    set idp [expr {abs($gloglo(+idmax))}]
    set iamax [expr {$idm>$idp ? $idm : $idp}]

    $smu0 sourceContinue 0.0
    $smu0 setCompliance $iamax -range best
   
    $smu setCompliance $vamax -range best

    # Pb. premier point pas resolu, ajout de fixed 2011-09-22 (FP)
    set irange [$smu bestIRange $gloglo(idebugrange) -code]
    $smu fixedLevelSweep [lindex $gloglo(idebuglist) 0] 0 20 -range $irange
    foreach ii $gloglo(idebuglist) {
	$smu fixedLevelSweepAppend $ii 0 20 -range $irange
    }
    $smu operate
    $smu declenche
    $smu repos
    $smu0 repos
    # lappend mesures {@ instant statut I V}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot $mesure 3 2 x y mes
    return $mesures
}


# 26 aout 1999: V(t), pour créneau I

proc mes.V(t) {nom} {
    global temperature gloglo

    set smu $gloglo(smu)
    set smu0 $gloglo(smu0)
    
    $smu write "D0X" ;# ca peut faire du bien
    $smu0 write "D0X" ;# ca peut faire du bien

    $smu poll
    $smu0 poll

    $smu V(I)
    $smu0 I(V)

    $smu0 sourceContinue 0.0
   
    set vdp [expr abs($gloglo(vmax))]
    $smu setCompliance $vdp

    $smu fixedLevelSweep $gloglo(i) $gloglo(delay) $gloglo(npts)
puts stderr "On roupille!"
    after 2000
     
    $smu operate
    $smu declenche
    $smu repos
    $smu0 repos
    lappend mesures {@ instant statut I V}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot $mesure 3 2 x y mes
    return $mesures
}

namespace eval ::mes::2smu {}

proc ::mes::2smu::ini {} {
    smuV SRQon Warning Error
    smuI SRQon Warning Error
    
    smuV repos
    smuI repos

# choix des synchros:
# - "trigIn preSRC" indispensable pour démarrer le tout avec un seul fire
# sinon il faut faire 2 déclenchements, avec tous les risques d'overrun
# le pendant est "trigOut postMSR"
# - trigIn preDLY, sinon il y a des décalages entre appareils, surtout en IbIxFR à courant élevé
# le endant est "trigOut postSRC"
# - pas de synchro avant preMSR, parce que le délai est adapté pour chaque appareil,
# en fonction de la gamme (fixe), pour que la mesure se termine en même temps.

    smuV trigIn preSRC preDLY
    smuI trigIn preSRC preDLY

    smuV trigOut postMSR postSRC
    smuI trigOut postMSR postSRC

    smuV trigSweepEnd 0
    smuI trigSweepEnd 0
    
    smuV trigOn ext
    smuI trigOn ext

    smuV sweep
    smuI sweep
}

proc ::mes::2smu::2smu.mesure {args} {
    global variable_SRQ

#    puts stderr {rustine à revoir pb. K0 NRFD : on roupille 1000 ms...}
#    after 1000

    smuV operate
    smuI operate
    
    smuV SRQon Warning Error ReadyForTrigger
    smuV waitRft
    smuV SRQon Warning Error SweepDone

    smuI SRQon Warning Error ReadyForTrigger
    smuI waitRft
    smuI SRQon Warning Error SweepDone

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

    set aTester [list smuI smuV]
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
            error "2smuWait : Pb. de synchro"
        } else {
            set aTester $restent
        }
    }

    smuI repos
    smuV repos

    return [list $jour $heure]
}


proc ::mes::2smu::debloque {} {
    smuV write "D0X" ;# sinon bloque les smus recents
    smuI write "D0X" ;# sinon bloque les smus recents
}

# le suffixe FR vient de "Fixed Range" pour les bipolaires
# On n'utilise pas le multi-fixed-range paranoiaque,
# mais on conserve ce nom. 

proc ::mes::2smu::iniFR {retVarName sptName} {
    upvar $retVarName retour

    set retour [list $sptName]
    lappend retour \
	    [list \
	    @ {    I    } {      V       } {      Vpolar    }\
	    {      jour} {   heure} {    tI} {    tV} SI SV ]
}

proc ::mes::2smu::mesureFR {retVarName} {
    upvar $retVarName retour

    foreach {jour heure} [::mes::2smu::2smu.mesure] {}
    
    set sI [smuI litSweep]
    set sV [smuV litSweep]
    
    set tcolI [lindex $sI 0]
    set tcolV [lindex $sV 0]
  
    set sI [lrange $sI 1 end]
    set sV [lrange $sV 1 end]
    
    if {$tcolI != [list @ I V instant statut]} {
        return -code error "tcolI = \"$tcolI\""
    }
    if {$tcolV != [list @ I V instant statut]} {
        return -code error "tcolV = \"$tcolV\""
    }


    foreach esI $sI esV $sV {

        foreach {II VI tI SI} $esI {break}
        foreach {IV VV tV SV} $esV {break}
        
        lappend retour [list\
		[::smu::engVal $II] \
 		[::smu::engVal $VV] \
    		[::smu::engVal $VI] \
 		$jour $heure\
		[format %6d $tI] [format %6d $tV] \
		$SI $SV\
		]
    }   
}

proc ::mes::2smu::V(I) {nom} {
    global gloglo
    global variable_SRQ

    ::mes::2smu::debloque
    
    smuV SRQon Error Warning
    smuI SRQon Error Warning

    smuV V(I)
    smuI V(I)

    smuV sweep
    smuI sweep

    smuI setCompliance $gloglo(vmaxpolar) -range best
    smuV setCompliance $gloglo(vrange) -range best

    ::mes::2smu::iniFR retour "@@Hall V(I) $nom"
    set delai [expr {int($gloglo(delay)*1000.)}]

    smuI linStair       0.0            $gloglo(+imax) $gloglo(+npts) $delai
    smuI linStairAppend $gloglo(+imax) 0.0            $gloglo(+npts) $delai
    smuI linStairAppend 0.0            $gloglo(-imax) $gloglo(-npts) $delai
    smuI linStairAppend $gloglo(-imax) 0.0            $gloglo(-npts) $delai

    set npts [smuI getSweepSize]
    smuV fixedLevelSweep 0.0 0 $npts

    ::mes::2smu::mesureFR retour
    bell

    return $retour
}


