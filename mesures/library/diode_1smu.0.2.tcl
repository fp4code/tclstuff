# 2005-10-09 (FP) passage à 1 smu, sur le modèle de diode.0.2.tcl

package require smu 1.2
package require mes 0.1

namespace eval ::mes::diode_1smu {}

proc ::mes::diode_1smu::mesure {nom} {
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

proc ::mes::diode_1smu::dir {args} {
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
    puts "sweepDelay = $sweepDelay"

    set mesures [list "@@mes_diode_1smu_dir_0.2 $nom"]

    smu write "D0X" ;# ca peut faire du bien

    smu poll

    smu V(I)

    smu setCompliance $VDirMax
    smu logStair $idirmin $idirmax $gloglo(IDirNptsLog) $sweepDelay
    smu logStairAppend $idirmax $idirmin $gloglo(IDirNptsLog) $sweepDelay

    smu operate
    smu declenche
    smu repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
     
    return $mesures
}

proc ::mes::diode_1smu::inv {args} {
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
    puts "sweepDelay = $sweepDelay"

    set mesures [list "@@mes_diode_1smu_inv_0.2 $nom"]

    smu write "D0X" ;# ca peut faire du bien

    smu poll

    smu I(V)

    smu setCompliance $IInvMax
    smu linStairStep       [mes::negVal $vDirRacc] [mes::negVal $vInvMax] [mes::negVal $step] $sweepDelay -range [::smu::bestVRange smu $vInvMax]
    smu linStairStepAppend [mes::negVal $vInvMax]  [mes::negVal $vDirRacc] $step $sweepDelay -range [::smu::bestVRange smu $vInvMax]

    smu operate
    smu declenche
    puts stderr "before repos in ::mes::diode_1smu::inv"
    smu repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
    puts stderr "end ::mes::diode_1smu::inv"
    return $mesures
}

package provide mes_diode_1smu 0.2
