#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

package require fidev
package require blasObj
package require fctlm
package require minpack
package require superTable
package require fctlm

set fcn    "::fctlm::toMinimize"

#########################################################################
#         COD� DUR !!!!!! vvv
#########################################################################
set dispoDir [pwd]
set dir $dispoDir
set blocs 33A

set geomReferenceDesA 33A
set geomReferenceDesB 33B

proc ::fctlm::cosmetique {} {
    .c itemconfigure 000/62A -fill yellow
    .c raise 000/62A
}

set rM    3.0       ;# ohm    (par carr�)
set rP  2000.0       ;# ohm um
set rS0 2000.        ;# ohm    (par carr�)
set rS  2000.        ;# ohm    (par carr�)
set LT    0.8       ;#     um

#########################################################################
#          COD� DUR !!!!!! ^^^
#########################################################################

proc sessions {dir} {
    set entete $dir
    puts [list entete = $entete]
    set le [string length ${entete}/fctlm_]
    set spts [glob ${entete}/fctlm_*.spt]
    set ret [list]
    foreach spt $spts {
	set ie [expr {[string length $spt] - 5}]
	lappend ret [string range $spt $le $ie]
    }
    return $ret
}

if {$argc != 2} {
    puts stderr "syntaxe: $argv0 session geom"
    puts stderr [list session = one from [sessions $dir]]
    exit 1
}

set session [lindex $argv 0]
set geom [lindex $argv 1]

proc litTables {dir session bloc geom} {

    set exemple {/export/home/asdex/data/81214/81214.6/fit_fctlm_resistances 000 62A}
        
    # table des dimensions
    set nameOfTable "repr�sentants g�om�triques de geom*.spt*"
    set fE $dir/../${geom}Etalon.spt
    set fG $dir/../${geom}.spt
    if {[catch {::superTable::fileToTable rpgData $fE nameOfTable {}} message]} {
	puts stderr $message
	puts stderr "fichier en cause: \"$fE\""
	exit 1
    }
    set rpgGlobal [::superTable::getCell rpgData 0 global]
    set rpgCCA    [::superTable::getCell rpgData 0 "CC A"]
    set rpgCCB    [::superTable::getCell rpgData 0 "CC B"]

    # table des dimensions
    set nameOfTable "mesures �talonn�es � partir de ${geom}.spt*"
    if {[catch {::superTable::fileToTable gData $fE nameOfTable {TYPE DISPO}} message]} {
	puts stderr $message
	puts stderr "fichier en cause: \"$fE\""
	exit 1
    }
    
    # table des aspects
    set qDataTableName *qualit�*$bloc*
    if {[catch {::superTable::fileToTable qData $fG qDataTableName TYPE} message]} {
	puts stderr $message
	puts stderr "fichier en cause: \"$fG\""
	exit 1
    }
    
    set fichier $dir/fctlm_${session}.spt
    set rDataTableName "R�sistances Mesur�es mesures_fctlm_$session"
    if {[catch {::superTable::fileToTable rData $fichier rDataTableName {BLOC TYPE}} message]} {
	puts stderr $message
	puts stderr "fichier en cause: \"$fichier\""
	exit 1
    }
 
    set rIndex [lindex $message 0]
    
    foreach l {iL_List RL_List DRL_List uM_List uS_List DL_List\
	    iF_List RF_List DRF_List wF_List DF_List\
	    in_List Rn_List DRn_List wn_List Dn_List Nn_List ln_List} {
	global $l
	set $l [list]
    }

    foreach i $rIndex {
	# 
	set type [lindex $i 1]
	set iNew [list $type [lindex $i 0]]

	set AorB [string index $bloc [expr {[string length $bloc] - 1}]]
	if {$type == "CC"} {
	    set representant [set rpgCC$AorB]
	} else {
	    set representant $rpgGlobal
	}
	set iGeom [list $type $representant]
	unset representant

	if {$rData([list $i Valide]) == 0} {
	    continue
	}
	if {[lindex $qData([list $type OK]) 0] != "bon"} {
	    continue
	}

	if {![info exists gData([list $iGeom TYPE])]} {
	    puts  stderr "no type \"[list $iGeom TYPE]\""
	    continue
	}

	if {$type == "CC"} {
	    lappend iL_List $iNew
	    lappend RL_List [::superTable::getCell rData $i R]
	    lappend DRL_List [::superTable::getCell rData $i DeltaR]
	    lappend uM_List [lindex [::superTable::getCell gData $iGeom larMetal] 0]
	    lappend uS_List [lindex [::superTable::getCell gData $iGeom larMesa] 0]
	    lappend DL_List [lindex [::superTable::getCell gData $iGeom longueur] 0]
	} elseif {$type == "Vide"} {
	    lappend iF_List $iNew
	    lappend RF_List $rData([list $i R])
	    lappend DRF_List $rData([list $i DeltaR])
	    lappend wF_List [lindex [::superTable::getCell gData $iGeom larMesaTh] 0]
	    lappend DF_List [lindex [::superTable::getCell gData $iGeom lVideMoy] 0]
	} else {
	    lappend in_List $iNew
	    lappend Rn_List $rData([list $i R])
	    lappend DRn_List $rData([list $i DeltaR])
	    lappend wn_List [lindex [::superTable::getCell gData $iGeom larMesaTh] 0]
	    lappend Dn_List [lindex [::superTable::getCell gData $iGeom lVideMoy] 0]        
	    set nFant [::superTable::getCell gData $iGeom nFant]
	    lappend Nn_List $nFant
	    set ln     [lindex [::superTable::getCell gData $iGeom l] 0]
	    lappend ln_List $ln
	}
    }
}


litTables $dir $session $blocs $geom

set x [::blas::newVector double [list $rM $rP $rS0 $rS $LT]]
set resultat [::blas::getVector $x]

set mL [llength $iL_List]
set mF [llength $iF_List]
set mn [llength $in_List]

set RL_Vector [::blas::newVector double $RL_List]
set DRL_Vector [::blas::newVector double $DRL_List]
set uM_Vector [::blas::newVector double $uM_List]
set uS_Vector [::blas::newVector double $uS_List]
set DL_Vector [::blas::newVector double $DL_List]

set RF_Vector [::blas::newVector double $RF_List]
set DRF_Vector [::blas::newVector double $DRF_List]
set wF_Vector [::blas::newVector double $wF_List]
set DF_Vector [::blas::newVector double $DF_List]

set Rn_Vector [::blas::newVector double $Rn_List]
set DRn_Vector [::blas::newVector double $DRn_List]
set wn_Vector [::blas::newVector double $wn_List]
set Dn_Vector [::blas::newVector double $Dn_List]
set Nn_Vector [::blas::newVector int    $Nn_List]
set ln_Vector [::blas::newVector double $ln_List]

::fctlm::iniLong   $mL $RL_Vector $DRL_Vector $uM_Vector $uS_Vector $DL_Vector
::fctlm::iniFree   $mF $RF_Vector $DRF_Vector $wF_Vector $DF_Vector
::fctlm::iniNormal $mn $Rn_Vector $DRn_Vector $wn_Vector $Dn_Vector $Nn_Vector $ln_Vector

source /home/fidev/Tcl/fctlm/fit_ui.tcl

puts TOTO


# pour debug

proc ::fctlm::DEBUG {} {

    set FVEC [list]
    set FJAC_LT [list]

    for {set i 0} {$i<$mL} {incr i} {
	set RL [lindex $RL_List $i]
	DRL $DRL_List \
	set uM [lindex $uM_List $i]
	set uS [lindex $uS_List $i]
	set DL [lindex $DL_List $i]
	lappend FVEC [expr {-$RL*$uM/$DL + 1.0/(1.0/$rM + 1.0/$rS+ ($uS/$uM - 1.0)/$rS0)}]
	lappend FJAC_LT 0.0
    }

    for {set i 0} {$i<$mF} {incr i} {
	set RF [lindex $RF_List $i]
	set wF [lindex $wF_List $i]
	set DF [lindex $DF_List $i]
	lappend FVEC [expr {-$RF*$wF/$DF + $rS0 +2.0*$rP/$DF}]
	lappend FJAC_LT 0.0
    }

    for {set i 0} {$i<$mn} {incr i} {
	set Rn [lindex $Rn_List $i]
	set wn [lindex $wn_List $i]
	set Dn [lindex $Dn_List $i]
	set Nn [lindex $Nn_List $i]
	set ln [lindex $ln_List $i]
	set xxx [expr {0.5*$ln/$LT}]
	lappend FVEC [expr {(-$Rn*$wn/$Dn + $rS0 + 2.0*$rP/$Dn)*$Dn/($Nn*$ln) + ($rM + $rS*tanh($xxx)/$xxx)/(1.0 + $rM/$rS) - $rS0}]
	lappend FJAC_LT [expr {2.0*$rS/((1.0+$rM/$rS)*$ln)*(tanh($xxx)-$xxx/(cosh($xxx)*cosh($xxx)))}]
    }
    
    puts [list FVEC = $FVEC]
    puts [list FJAC_LT = $FJAC_LT]
}


#*

set rien {
::fctlm::deleteVector $RL_Vector
::fctlm::deleteVector $uM_Vector
::fctlm::deleteVector $uS_Vector
::fctlm::deleteVector $DL_Vector

::fctlm::deleteVector $RF_Vector
::fctlm::deleteVector $wF_Vector
::fctlm::deleteVector $DF_Vector

::fctlm::deleteVector $Rn_Vector
::fctlm::deleteVector $wn_Vector
::fctlm::deleteVector $Dn_Vector
::fctlm::deleteVector $Nn_Vector
::fctlm::deleteVector $ln_Vector
}


set x0     [::blas::newVector double [list $rM $rP $rS0 $rS $LT]]
set n      5
set m      [expr $mL+$mF+$mn]
set ldfjac $m
set fvec   [::blas::newVector double -length $m]
set fjac   [::blas::newVector double -length [expr $ldfjac*$n]]
set tol    1e-15
set ipvt   [::blas::newVector int -length $n]
set lwa    [expr 5*$n+$m]

set wa     [::blas::newVector double -length $lwa]

set rien {
set iflag 1
::fctlm::toMinimize $m $n $x0 $fvec $fjac $ldfjac iflag
set v0 [::blas::getVector $fvec]
set iflag 2
::fctlm::toMinimize $m $n $x0 $fvec $fjac $ldfjac iflag
set j [::blas::getVector $fjac]
}

proc compare {x1 j delta} {
    global m n fvec fjac ldfjac
    global v0
    set iflag 1
    ::fctlm::toMinimize $m $n $x1 $fvec $fjac $ldfjac iflag
    if {$iflag != 1} {
	error "toMinimize -> $iflag"
    }
    set v1 [::blas::getVector $fvec]
puts {}
puts {}
    for {set i 0} {$i<$m} {incr i} {
        set a0 [lindex $v0 $i]
        set a1 [lindex $v1 $i]
        set analyt [::blas::getAtIndex $fjac [expr $i + $j*$ldfjac]]
        set approx [expr ($a1-$a0)/$delta]
        if {$analyt != 0.0} {
            puts [list [expr ($approx-$analyt)/$analyt] $analyt $approx $a0]
        } else {
            puts [list ******* $analyt $approx $a0]
        }
    }
}

set rien {
compare [::blas::newVector double {1.001 100. 200. 180. 1.}] 0 0.001
compare [::blas::newVector double {1. 100.001 200. 180. 1.}] 1 0.001
compare [::blas::newVector double {1. 100. 200.001 180. 1.}] 2 0.001
compare [::blas::newVector double {1. 100. 200. 180.001 1.}] 3 0.001
compare [::blas::newVector double {1. 100. 200. 180. 1.001}] 4 0.001

compare [::blas::newVector double {1. 100. 200. 180. 1.001}] 4 0.001
compare [::blas::newVector double {1. 100. 200. 180. 1.0001}] 4 0.0001
compare [::blas::newVector double {1. 100. 200. 180. 1.00001}] 4 0.00001
compare [::blas::newVector double {1. 100. 200. 180. 1.000001}] 4 0.000001
compare [::blas::newVector double {1. 100. 200. 180. 1.0000001}] 4 0.0000001
}

::minpack::lmder1 $fcn $m $n $x0 $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa

# ::fctlm::freeParams

puts "$info $resultat"

# % % % 2 1.44875687393 1374.35594784 158.140404356 158.364163286 0.937267905881

set x [::blas::newVector double {10. 300. 300. 300. 10.}]
::minpack::lmder1 $fcn $m $n $x $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa
puts "$info [::blas::getVector $x]"

set x [::blas::newVector double {1. 200. 200. 200. 1.}]
::minpack::lmder1 $fcn $m $n $x $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa
puts "$info [::blas::getVector $x]"





