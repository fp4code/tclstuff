

proc confCRes {s centre resolution} {
    puts "centre = $centre [expr $centre] [expr {$centre}]" 
    $s configure -from [expr {$centre - 100*$resolution}]
    $s configure -to   [expr {$centre + 100*$resolution}]
    $s configure -resolution $resolution
    set f [winfo parent $s]
    if {[winfo exists ${f}.resolution]} {
        ${f}.resolution configure -text [format %5g $resolution]
    }
}

proc raffine {s} {
    set resolution [expr {0.1*[$s cget -resolution]}]
    set centre [$s get]
    confCRes $s $centre $resolution
}
 
proc grossier {s} {
    set resolution [expr {10.0*[$s cget -resolution]}]
    set centre [expr {0.5*([$s cget -from] + [$s cget -to])}]
    confCRes $s $centre $resolution
}

proc decale {s sens} {
    set g [$s cget -from]
    set d [$s cget -to]
    set p [$s get]
    set i [expr {0.5*$sens*($d-$g) + $p - 0.5*($d+$g)}]
    $s configure -from [expr {$g + $i}]
    $s configure -to   [expr {$d + $i}]
    $s set             [expr {0.5*($d+$g) + $i}]
}


proc creeScale {f varName resolution} {
    destroy $f
    frame $f
    upvar #0 $varName centre
    set centreOriginal $centre
    scale ${f}.s -variable $varName \
                 -orient horizontal \
                 -command ::fctlm::recalcule
    set positions [expr 2*100+1]

puts "   centre : $centre -> $centreOriginal"
    confCRes ${f}.s $centreOriginal $resolution
    set centre $centreOriginal

    ${f}.s configure -length [expr [${f}.s cget -sliderlength] + \
                           2*([${f}.s cget -borderwidth]) + \
                           ($positions - 1)]
    ${f}.s configure -showvalue 1
    ${f}.s configure -borderwidth 0

    button ${f}.droite -text "+" -command "decale ${f}.s 1" -takefocus 0
    button ${f}.gauche -text "-" -command "decale ${f}.s -1" -takefocus 0
    
    button ${f}.raffine -text - -command "raffine ${f}.s" -takefocus 0
    button ${f}.grossier -text + -command "grossier ${f}.s" -takefocus 0
    label ${f}.resolution -text [format %5g $resolution] -width 5 -relief ridge -borderwidth 4
    label ${f}.label -text $varName

    pack ${f}.droite -side right ;# -anchor s
    pack ${f}.s -side right ;# -anchor s
    pack ${f}.gauche -side right ;#  -anchor s
    pack ${f}.raffine -side left
    pack ${f}.resolution -side left
    pack ${f}.grossier -side left
    pack ${f}.label -side right
}

destroy .fitvals
toplevel .fitVals

puts stderr "resultat = $resultat"
set rM [blas::vector get $resultat 1]
set rP [blas::vector get $resultat 2]
set rS0  [blas::vector get $resultat 3]
set rS [blas::vector get $resultat 4]
set LT [blas::vector get $resultat 5]

puts stderr "\nET VOICI LES VALEURS $rM $rP $rS0 $rS $LT"

creeScale .fitVals.rM rM 0.01
creeScale .fitVals.rP rP 1
creeScale .fitVals.rS0 rS0 0.1
creeScale .fitVals.rS rS 0.1
creeScale .fitVals.lT LT 0.01
pack .fitVals.rM .fitVals.rP .fitVals.rS0 .fitVals.rS .fitVals.lT -fill x

frame .fitVals.fits
button .fitVals.fits.fitIt -text fitIt -command fitIt
button .fitVals.fits.badFit -text badFit -command badFit 


pack .fitVals.fits
pack .fitVals.fits.fitIt -side left
pack .fitVals.fits.badFit -side left

bind Scale <Control-Key-Up> {grossier %W}
bind Scale <Control-Key-Down> {raffine %W}
bind Scale <Key-Up> {tkScaleIncrement %W down little noRepeat}
bind Scale <Key-Down> {tkScaleIncrement %W up little noRepeat}

frame .fitVals.dispos
pack .fitVals.dispos

canvas .c
pack .c

# GLOBAUX

# facteurs d'échelle

set fx 200.0
set fy -400.0

# identificateur de la courbe

set COURBE [.c create line 0 0 0 0 -tags COURBE]

#

set COURBE_ZERO [.c create line 400 [expr {0.5*$fy}] 800 [expr {0.5*$fy}] -tags COURBE_ZERO]
set COURBE_UNITE [.c create line 0 $fy 400 $fy -tags COURBE_UNITE]

# coordonnées pixel des longueurs de contact (échelle log)

set xPOINTS [list]
foreach ln [lrange $ln_Vector 1 end] {
    lappend xPOINTS [expr {$fx*log10(10.0*$ln)}]
}

set lnCourbe [list]
# 0.1 ... 100.
for {set i 0} {$i <= 800} {incr i} {
    lappend lnCourbe [expr {0.1*pow(10.0 ,$i/200.)}]
}

proc ::fctlm::tracePoint {x y ym yp tags tagpt} {
    set l1 [.c create line $x $ym $x $yp -tag [concat L1 $tags $tagpt]]
    set l2 [.c create line [expr {$x-3}] $y [expr {$x+3}] $y -tag [concat L2 $tags $tagpt]]
    .c create line $x $y $x $y -tag [concat CENTRE $tags $tagpt] 
}

# saturation : de 0.25 à Inf -> 0.25 à 0.4
# y -> C*(A+1/x)/(B+1/x)
# x = Inf : y = C => C = 2/5
# x = 1/4 : y = 1/4 => 8*A + 12 = 5*B => B = (8/5)*A + 12/5
# y' = C*(A +((A + 1/x)/(B + 1/x)- 1)/(x*x))/(B + 1/x)
# Trop lourd : on préfère ne pas raccorder les dérivées
# y = 8./(20.+3./x)
proc ::fctlm::echelleLigne {y} {
    if {$y > 0.25} {
	set y [expr {8./(20. + 3./$y)}]
    } elseif {$y < -0.25} {
	set y [expr {-8./(20. - 3./$y)}]
    }
    return $y
}


proc ::fctlm::recalcule {dummy} {

    # résistance spécifique de métal

    global rM

    # résistance d'un PAD

    global rP

    # résistance spécifique de semicond. non perturbé

    global rS0

    # résistance spécifique de semicond. sous le contact

    global rS

    # longueur de transfert

    global LT

    # liste fixe de longueurs de métallisation "ln"

    global  lnCourbe

    # facteurs d'échelle

    global fx fy

    #######################################################
    # listes de valeurs mesurées, avec contacts flottants #
    #######################################################

    # identificateur de la valeur (genre {2x4 Ni10nm/00A})

    global in_List

    # résistance mesurée

    global Rn_List DRn_List

    # largeur de mesa

    global wn_List

    # distance entre pads

    global  Dn_List

    # nombre de fantômes

    global  Nn_List

    # longueur d'un fantôme

    global  ln_List

    #######################################################
    # listes de valeurs mesurées, sans contacts flottants #
    #######################################################

    # identificateur de la valeur (genre {Vide Ni10nm/00A})

    global iF_List

    # résistance mesurée

    global RF_List DRF_List

    # largeur du mesa

    global wF_List

    # distance entre pads

    global DF_List

    ############################################
    # listes de valeurs mesurées, ligne longue #
    ############################################

    # identificateur de la valeur (genre {CC Ni10nm/00A})

    global iL_List

    # résistance mesurée

    global RL_List DRL_List

    # largeur de métal

    global  uM_List

    # largeur de mesa

    global  uS_List

    # longueur de ligne

    global  DL_List

    #############

    # identificateur de la courbe

    global COURBE

    # coordonnées pixel des longueurs de contact (échelle log)

    global xPOINTS

    #######################################################
    # calcul et trace de la courbe des contacts flottants #
    #######################################################

# puts "-- $rM $rP $rS0 $rS $LT"
    set xyList [::fctlm::calcule $fx $fy [list $rM $rP $rS0 $rS $LT] \
         $lnCourbe]

    # eval [list .c coords $COURBE] $xyList
    .c coords $COURBE $xyList

    #######################
    # points de la courbe #
    #######################

    .c delete POINT_n POINT_F POINT_L

    if {[winfo children .fitVals.dispos] == {}} {
	foreach in $in_List {
	    set geoms([lindex $in 1]) {}
	}
	global COSMETIQUE
	foreach g [lsort [array names geoms]] {
	    set COSMETIQUE($g) 0
	    checkbutton .fitVals.dispos.b$g -text $g -variable COSMETIQUE($g) -command fctlm::cosmetique
	    pack .fitVals.dispos.b$g -side left
	}
	unset geoms
    }

    foreach in $in_List \
            Rn $Rn_List \
            DRn $DRn_List \
            wn $wn_List \
            Dn $Dn_List \
            Nn $Nn_List \
            ln $ln_List \
            xPoint $xPOINTS {
        set r [expr {-(-$Rn*$wn + 2.0*$rP + ($Dn - $Nn*$ln)*$rS0)/($Nn*$ln)}]
        set dr [expr {($DRn*$wn)/($Nn*$ln)}]
        set yPoint [expr {($fy/$rS0)*$r}]
        set dyPoint [expr {($fy/$rS0)*$dr}]
	# puts stderr "normal $in $Rn $wn $Dn $Nn $ln $xPoint -> $r -> $yPoint"
	::fctlm::tracePoint $xPoint $yPoint [expr {$yPoint - $dyPoint}] [expr {$yPoint + $dyPoint}] $in POINT_n

        set xxx [expr {$ln/(2.0*$LT)}]
        set rG [expr {(2.0*$LT/(1.0+$rM/$rS))*($rM*$xxx + $rS*tanh($xxx))}]
        set espaces [expr {$Dn - $Nn*$ln}]
        set r [expr {(2.0*$rP + $espaces*$rS0 + $Nn*$rG)/$wn}]
        # puts stderr "   $r"
    }
    
    ###############
    # free (vide) #
    ###############

    set xPoint 10
    foreach iF $iF_List \
            RF $RF_List \
	    DRF $DRF_List \
	    wF $wF_List \
            DF $DF_List {
# vérifier
        set yPoint [expr {-($fy/$rS0)*(-$RF*$wF + 2.0*$rP)/$DF}]
        set dyPoint [expr {($fy/$rS0)*($DRF*$wF)/$DF}]
	# puts stderr "free $iF $RF $wF $DF -> $yPoint"
::fctlm::tracePoint $xPoint $yPoint [expr {$yPoint - $dyPoint}] [expr {$yPoint + $dyPoint}] $iF POINT_F

        incr xPoint 10
        
        set r [expr {(2.0*$rP + $DF*$rS0)/$wn}]
puts "    $r"
    }

    ##########################
    # ligne continue (métal) #
    ##########################
    
    set xPoint 790
    foreach iL $iL_List \
            RL $RL_List \
            DRL $DRL_List \
            uM $uM_List \
            uS $uS_List \
            DL $DL_List {
        set y [expr {1.0 + (-$RL*$uM*(1.0/$rM+1.0/$rS+($uS/$uM-1.0)/$rS0)/$DL)}]
        set ym [expr {1.0 + (-($RL - $DRL)*$uM*(1.0/$rM+1.0/$rS+($uS/$uM-1.0)/$rS0)/$DL)}]
        set yp [expr {1.0 + (-($RL + $DRL)*$uM*(1.0/$rM+1.0/$rS+($uS/$uM-1.0)/$rS0)/$DL)}]
        
	# puts stderr "line $iL $RL $uM $uS $DL -> $y"
	# puts stderr "    $y"
	
        set yPoint [expr {($fy)*(0.5 + [::fctlm::echelleLigne $y])}]
	set ymPoint [expr {($fy)*(0.5 + [::fctlm::echelleLigne $ym])}]
	set ypPoint [expr {($fy)*(0.5 + [::fctlm::echelleLigne $yp])}]
	::fctlm::tracePoint $xPoint $yPoint $ymPoint $ypPoint $iL POINT_L
        incr xPoint -10
    }
    

    ::fctlm::cosmetique
    
    set dPad 50.0
    set rC [expr {($rS+$rM)*$LT*$LT}]
    puts "rC = $rC, rP ~ [expr {sqrt($rS*$rC)/tanh($dPad*sqrt($rS/$rC))}]"
    set LTprime [expr {sqrt($rC/$rS)}]
    puts "rC = $rC, rP ~ [expr {($rS)*$LTprime/tanh($dPad/$LTprime)}]"
    set microns [expr {2.0*($rP - ($rS+$rM)*$LTprime/tanh($dPad/$LTprime))/$rS0}]
    puts "ecart = $microns microns"

    set x [::blas::vector create double [list $rM $rP $rS0 $rS $LT]]
    set n      5
    set m      [expr {[llength $iL_List] + [llength $iF_List] + [llength $in_List]}]
    set ldfjac $m
    set fvec   [::blas::vector create double -length $m]
    set fjac   [::blas::vector create double -length [expr $ldfjac*$n]]
    set iflag 1
    fctlm::toMinimize $m $n $x $fvec $fjac $ldfjac iflag
    set tot 0.0
foreach v [lrange $fvec 1 end] {
	set tot [expr {$tot + $v*$v}]
    }
    puts [list ---> $tot $fvec]

    # ::blas::deleteVector $x
    # ::blas::deleteVector $fvec
    # ::blas::deleteVector $fjac
}

bind .c <1> "%W scan mark %x %y"
bind .c <B1-Motion> {%W scan dragto %x %y; puts [list [%W canvasx 0] [%W canvasy 0]]}

.c configure -width 900 -height 800
.c configure -scrollregion {-200 -1500 1500 500}

bind .c <2> {getIt %W %x %y}

proc getIt {win x y} {
    set H 3
    set xc [$win canvasx $x]
    set yc [$win canvasy $y]
    puts [list $x $y $xc $yc]
    set pts [$win find enclosed [expr {$xc - $H}] [expr {$yc - $H}] [expr {$xc + $H}] [expr {$yc + $H}]]
    
    foreach pt $pts {
	puts [$win gettags $pt]
    }
}

proc fitIt {} {
    global iL_List iF_List in_List
    global rM rP rS0 rS LT
    global old_rM old_rP old_rS0 old_rS old_LT
    set fcn    "::fctlm::toMinimize"
    set n      5
    set m      [expr {[llength $iL_List] + [llength $iF_List] + [llength $in_List]}]
    set x [::blas::vector create double [list $rM $rP $rS0 $rS $LT]]
    set ldfjac $m
    set fvec   [::blas::vector create double -length $m]
    set fjac   [::blas::vector create double -length [expr $ldfjac*$n]]
    set tol    1e-15
    set ipvt   [::blas::vector create long -length $n]
    set lwa    [expr 5*$n+$m]
    set wa     [::blas::vector create double -length $lwa]

    foreach v {rM rP rS0 rS LT} {
	set old_$v [set $v]
    }

    ::minpack::lmder1 $fcn $m $n $x $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa


    set rM [blas::vector get $x 1]
    set rP [blas::vector get $x 2]
    set rS0  [blas::vector get $x 3]
    set rS [blas::vector get $x 4]
    set LT [blas::vector get $x 5]

    ::fctlm::recalcule {}

    puts "info = $info"
 
    #::blas::deleteVector $x
    #::blas::deleteVector $fvec
    #::blas::deleteVector $fjac
    #::blas::deleteVector $ipvt
    #::blas::deleteVector $wa
}

proc badFit {} {
    global rM rP rS0 rS LT
    global old_rM old_rP old_rS0 old_rS old_LT

    foreach v {rM rP rS0 rS LT} {
	set $v [set old_$v]
    }
    ::fctlm::recalcule {}

}
proc ::fctlm::cosmetique {} {
    global COSMETIQUE
    .c itemconfigure POINT_n -fill "dark olive green"
    .c itemconfigure POINT_F -fill blue
    .c itemconfigure POINT_L -fill blue
    foreach geom [array names COSMETIQUE] {
	if {$COSMETIQUE($geom)} {
	    .c itemconfigure $geom -fill red
	    .c raise $geom
	}
    }
}

