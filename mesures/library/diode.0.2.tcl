# 2004-02-03 (FP) passage à 2 smus (1 smu de tension nulle) sur le modèle de mes.ser
# 2004-02-03 (FP) style similaire à mes_bipolaire
# 2004-02-04 (FP) intruduction de gloglo(sweepDelayDir) et gloglo(sweepDelayInv)

package provide mes_diode 0.2

package require smu 1.2
package require mes 0.1


proc OLD.mes.diode {nom} {
    global temperature gloglo
    
    set mesures [list "@@ $nom"]
    set smu $gloglo(smu)
    $smu write "D0X"
    $smu poll

    $smu V(I)
    $smu setCompliance $gloglo(+vmax)
    $smu logStair $gloglo(+imin) $gloglo(+imax) $gloglo(logsmu.npts) 0
    $smu logStairAppend $gloglo(+imax) $gloglo(+imin) $gloglo(logsmu.npts) 0
     
    $smu operate
    $smu declenche
    $smu repos

#    lappend mesures {@    I          V           instant             msec statut}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    plot [lrange $mesure 1 end] 1 0 x y mes
    
    $smu I(V)
    $smu setCompliance $gloglo(-imax)
    $smu linStairStep $gloglo(+vmin) [expr {-$gloglo(-vmax)}] [expr {-$gloglo(dv)}] 0
    $smu linStairStepAppend [expr {-$gloglo(-vmax)}] $gloglo(+vmin) $gloglo(dv) 0

    $smu operate
    $smu declenche
    $smu repos

    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    
    return $mesures
}


namespace eval ::mes::diode {}

proc ::mes::diode::mesure {nom} {
    global gloglo
    global TC

    set commandes [list]
    foreach c $gloglo(commandesDiode) {
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

proc ::mes::diode::dir {args} {
    global temperature gloglo
    global JMaxRaisonnable
    
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

    # contrôle si le courant n'est pas aberrant
    set JDirMax [mes::readUnit $gloglo(JDirMax) "A*um-2"]
    if {$JDirMax > $JMaxRaisonnable} {
        error "JDirMax = $JDirMax > JMaxRaisonnable = $JMaxRaisonnable A*um-2"
    }

    set symDes [lindex $nom end]

    mes::controlLimit gloglo IDirMax A $symDes $JDirMax

    set VDirMax [mes::readUnit $gloglo(VDirMax) V]

    set idirmin [expr {[mes::readUnit $gloglo(ILogMin) A]}]
    set idirmax [expr {$IDirMax}]

    if {[info exists gloglo(sweepDelayDir)]} {
	set sweepDelay $gloglo(sweepDelayDir)
    } else {
	set sweepDelay 0
    }

    set mesures [list "@@mes_diode_dir_0.2 $nom"]

    smu write "D0X" ;# ca peut faire du bien
    smu0 write "D0X" ;# ca peut faire du bien

    smu poll
    smu0 poll

    smu V(I)
    smu0 I(V)

    smu setCompliance $VDirMax
    smu logStair $idirmin $idirmax $gloglo(IDirNptsLog) $sweepDelay
    smu logStairAppend $idirmax $idirmin $gloglo(IDirNptsLog) $sweepDelay

    smu0 setCompliance $idirmax -range best
    smu0 sourceContinue 0.0
        
    smu operate
    smu declenche
    smu repos
    smu0 repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
     
    return $mesures
}

proc ::mes::diode::dir_neg {args} {
    global temperature gloglo
    global JMaxRaisonnable
    
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

    # contrôle si le courant n'est pas aberrant
    set JDirMax [mes::readUnit $gloglo(JDirMax) "A*um-2"]
    if {$JDirMax > $JMaxRaisonnable} {
        error "JDirMax = $JDirMax > JMaxRaisonnable = $JMaxRaisonnable A*um-2"
    }

    set symDes [lindex $nom end]

    mes::controlLimit gloglo IDirMax A $symDes $JDirMax

    set VDirMax [mes::readUnit $gloglo(VDirMax) V]

    set idirmin [expr {-[mes::readUnit $gloglo(ILogMin) A]}]
    set idirmax [expr {-$IDirMax}]

    if {[info exists gloglo(sweepDelayDir)]} {
	set sweepDelay $gloglo(sweepDelayDir)
    } else {
	set sweepDelay 0
    }

    set mesures [list "@@mes_diode_dir_neg_0.2 $nom"]

    smu write "D0X" ;# ca peut faire du bien
    smu0 write "D0X" ;# ca peut faire du bien

    smu poll
    smu0 poll

    smu V(I)
    smu0 I(V)

    smu setCompliance $VDirMax
    smu logStair $idirmin $idirmax $gloglo(IDirNptsLog) $sweepDelay
    smu logStairAppend $idirmax $idirmin $gloglo(IDirNptsLog) $sweepDelay

    smu0 setCompliance $idirmax -range best
    smu0 sourceContinue 0.0
        
    smu operate
    smu declenche
    smu repos
    smu0 repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
     
    return $mesures
}

proc ::mes::diode::inv {args} {
    global temperature gloglo
    global JMaxRaisonnable
    
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

    set symDes [lindex $nom end]

    mes::controlLimit gloglo IInvMax A $symDes [mes::readUnit $gloglo(JInvMax) A*um-2]

    set vDirRacc [expr {-[mes::readUnit $gloglo(VDirRaccord) V]}]
    set vInvMax  [expr {[mes::readUnit $gloglo(VInvMax) V]}]
    set step [mes::readUnit $gloglo(dVInv) V]

    if {[info exists gloglo(sweepDelayInv)]} {
	set sweepDelay $gloglo(sweepDelayInv)
    } else {
	set sweepDelay 0
    }



    set mesures [list "@@mes_diode_inv_0.2 $nom"]

    smu write "D0X" ;# ca peut faire du bien
    smu0 write "D0X" ;# ca peut faire du bien

    smu poll
    smu0 poll

    smu I(V)
    smu0 I(V)

    smu setCompliance $IInvMax
    smu linStairStep       [mes::negVal $vDirRacc] [mes::negVal $vInvMax] [mes::negVal $step] $sweepDelay -range [::smu::bestVRange smu $vInvMax]
    smu linStairStepAppend [mes::negVal $vInvMax]  [mes::negVal $vDirRacc] $step $sweepDelay -range [::smu::bestVRange smu $vInvMax]

    smu0 setCompliance $IInvMax -range best
    smu0 sourceContinue 0.0

    smu operate
    smu declenche
    smu repos
    smu0 repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
     
    return $mesures
}
