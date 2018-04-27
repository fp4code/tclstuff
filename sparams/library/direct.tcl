package require trig_sun

source [file join [file dirname [info script]] simul.tcl]

proc ::sparams::creeRealVars {cVar} {
    upvar ${cVar}_r c_r
    upvar ${cVar}_i c_i
    upvar ${cVar}_m c_m
    upvar ${cVar}_a c_a
    upvar ${cVar} c

    set c_r [complexes::re $c]
    set c_i [complexes::im $c]
    set c_m [complexes::module $c]
    set c_a [complexes::arg $c]
}

proc ::sparams::creeRealVarsFrom22 {aVar} {
    foreach i {11 12 21 22} {
        uplevel ::sparams::creeRealVars $aVar$i
    }
}

proc ::sparams::gnuplotDirect {distance tkTable colnames} {

    # Récupération du tableau associé à la tkTable
    
    upvar #0 [$tkTable cget -variable] tkTableArray
    
    # remplissage du tableau "ic" de correspondance entre les colonnes gnuplot
    # 1, 2, ... représentées pas ($1), ($2), ...
    # Et les colonnes du tableau tkTableArray
    
    set sparamsCols {freq s11_m s11_deg s12_m s12_deg s21_m s21_deg s22_m s22_deg}
    
    foreach colname $sparamsCols {
	set ic($colname) [tkSuperTable::getColIndex $tkTable $colname]
	set $colname [list]
    }
    
    # Construction des lignes de données gnuplot à partir du tableau "tkTableArray"


################

    set indice 3.5
#    set distance 150e-6 ;# distance des pointes au transistor
    set celerite 3.0e8
    # un 2 du 2*pi, un 2 vient de la distance double
    set demitourParHertz [expr {4*$indice*$distance/$celerite}]

################
    
    set datas {}
    
    set nli 0
    foreach ili [tkSuperTable::toutesLignes $tkTable] {
	incr nli
	foreach colname $sparamsCols {
	    if {[catch {set $colname $tkTableArray($ili,$ic($colname))} message]} {
		error "mauvaise table de sparams : $message"
	    }
	}
	
        set sE11 [complexes::newRTpi $s11_m [expr {$s11_deg/180.}]]
        set sE12 [complexes::newRTpi $s12_m [expr {$s12_deg/180.}]]
        set sE21 [complexes::newRTpi $s21_m [expr {$s21_deg/180.}]]
        set sE22 [complexes::newRTpi $s22_m [expr {$s22_deg/180.}]]
	
##################################################################################
	set rien {   
	    #    set mf [expr {pow(10., 0.1)}]
	    #    for {set freq 0.1e9} {$freq <= 100.e9} {set freq [expr {$freq*$mf}]} 
	    #	foreach {z11 z12 z21 z22} [sparams::simul 40. $freq] {}
	    #
	    #	foreach {s11 s12 s21 s22} [sparams::SfromZ $z11 $z12 $z21 $z22] {}
	}
        #

	foreach {hE11 hE12 hE21 hE22} [sparams::HfromS $sE11 $sE12 $sE21 $sE22] {}
	foreach {zE11 zE12 zE21 zE22} [sparams::ZfromS $sE11 $sE12 $sE21 $sE22] {}
	foreach {yE11 yE12 yE21 yE22} [sparams::YfromS $sE11 $sE12 $sE21 $sE22] {}
	foreach {gE11 gE12 gE21 gE22} [sparams::GfromS $sE11 $sE12 $sE21 $sE22] {}

	sparams::creeRealVarsFrom22 sE
	sparams::creeRealVarsFrom22 hE
	sparams::creeRealVarsFrom22 zE
	sparams::creeRealVarsFrom22 yE
	sparams::creeRealVarsFrom22 gE
# Gamax_sze  MAG_ramzi
	foreach o {Umax_fab Gp_sze KRollet_sze Gmax_ramzi U_sze U_prasad U_mason} {
	    set ${o}E [sparams::$o $sE11 $sE12 $sE21 $sE22]
	}

        set phase [complexes::newRTpi 1.0 [expr {$demitourParHertz*$freq}]]
        set s11 [complexes::mul $phase $sE11]
        set s12 [complexes::mul $phase $sE12]
        set s21 [complexes::mul $phase $sE21]
        set s22 [complexes::mul $phase $sE22]

	foreach {h11 h12 h21 h22} [sparams::HfromS $s11 $s12 $s21 $s22] {}
	foreach {z11 z12 z21 z22} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
	foreach {y11 y12 y21 y22} [sparams::YfromS $s11 $s12 $s21 $s22] {}
	foreach {g11 g12 g21 g22} [sparams::GfromS $s11 $s12 $s21 $s22] {}

	sparams::creeRealVarsFrom22 s
	sparams::creeRealVarsFrom22 h
	sparams::creeRealVarsFrom22 z
	sparams::creeRealVarsFrom22 y
	sparams::creeRealVarsFrom22 g
#  Gamax_sze  MAG_ramzi
    foreach o {Umax_fab Gp_sze KRollet_sze Gmax_ramzi U_sze U_prasad U_mason} {
        set $o [sparams::$o $s11 $s12 $s21 $s22]
    }

    


##################################################################################

	set first 1
	foreach gpc $colnames {
	    if {$first} {
		set first 0
	    } else {
		append datas \t
	    }
	    append datas [set $gpc]
	}
	append datas \n
    }
    return $datas
}


