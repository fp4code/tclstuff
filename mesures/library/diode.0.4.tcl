# 2004-02-03 (FP) passage à 2 smus (1 smu de tension nulle) sur le modèle de mes.ser
# 2004-02-03 (FP) style similaire à mes_bipolaire
# 2004-02-04 (FP) intruduction de gloglo(sweepDelayDir) et gloglo(sweepDelayInv)
# 2013-07-31 (FP) ajout du style #1_commande
# 2014-02-25 (FP) facteur 1.2 pour la compliance de smu0 en courant

package require smu 1.2
package require mes 0.1

namespace eval ::mes::diode {}

proc ::mes::diode::mesure {nom} {
    global gloglo
    global TC

    set commandes [list]
    foreach c $gloglo(commandesDiode) {
	if {[string index $c 0] == "#"} {
	    set ii [string first _ $c]
	    set nono [list "$nom [string range $c 0 [expr {$ii - 1}]]"]
	    set c [string range $c [expr {$ii + 1}] end]
	} else {
	    set nono [list $nom]
	}
	lappend commandes [concat $c $nono]
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

    set mesures [list "@@mes_diode_dir_0.4 $nom"]

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

    set idirmin [expr {(-1)*[mes::readUnit $gloglo(ILogMin) A]}]
    set idirmax [expr {(-1)*$IDirMax}]

    if {[info exists gloglo(sweepDelayDir)]} {
	set sweepDelay $gloglo(sweepDelayDir)
    } else {
	set sweepDelay 0
    }

    set mesures [list "@@mes_diode_dir_neg_0.4 $nom"]

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



    set mesures [list "@@mes_diode_inv_0.4 $nom"]

    smu write "D0X" ;# ca peut faire du bien
    smu0 write "D0X" ;# ca peut faire du bien

    smu poll
    smu0 poll

    smu I(V)
    smu0 I(V)

    smu setCompliance $IInvMax
    smu linStairStep       [mes::negVal $vDirRacc] [mes::negVal $vInvMax] [mes::negVal $step] $sweepDelay -range [::smu::bestVRange smu $vInvMax]
    smu linStairStepAppend [mes::negVal $vInvMax]  [mes::negVal $vDirRacc] $step $sweepDelay -range [::smu::bestVRange smu $vInvMax]

    smu0 setCompliance [expr {1.2*$IInvMax}] -range best
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

package provide mes_diode 0.4
