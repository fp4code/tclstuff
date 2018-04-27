# 2017-04-18 (FP) imité de diode 1 smu inv

package require smu 1.2
package require mes 0.1

namespace eval ::mes::res1smu {}

proc ::mes::res1smu::mesure {nom} {
    global temperature gloglo
    global JMaxRaisonnable
    
    set symDes [lindex $nom end]

    set IMax [expr {[mes::readUnit $gloglo(IMax) A]}]
    set vInvMax  [expr {[mes::readUnit $gloglo(VInvMax) V]}]
    set vDirMax  [expr {[mes::readUnit $gloglo(VDirMax) V]}]
    set step [expr {[mes::readUnit $gloglo(dV) V]}]

    if {[info exists gloglo(sweepDelay)]} {
	set sweepDelay $gloglo(sweepDelay)
    } else {
	set sweepDelay 0
    }
    puts "sweepDelay = $sweepDelay"

    set mesures [list "@@mes1smu $nom"]

    smu write "D0X" ;# ca peut faire du bien

    smu poll

    smu I(V)

    smu setCompliance $IMax
    smu linStairStep       0 $vDirMax $step $sweepDelay -range [::smu::bestVRange smu $vDirMax]
    smu linStairStepAppend $vDirMax 0 [mes::negVal $step] $sweepDelay -range [::smu::bestVRange smu $vDirMax]
    smu linStairStepAppend 0 [mes::negVal $vInvMax] [mes::negVal $step] $sweepDelay -range [::smu::bestVRange smu $vInvMax]
    smu linStairStepAppend [mes::negVal $vInvMax]  0 $step $sweepDelay -range [::smu::bestVRange smu $vInvMax]

    smu operate
    smu declenche
    puts stderr "before repos"
    smu repos

    set mesure [smu litSweep]
    set mesures [concat $mesures $mesure]
#    plot [lrange $mesure 1 end] 1 0 x y mes
    puts stderr "end res1smu"
    return $mesures
}

package provide res1smu 0.1
