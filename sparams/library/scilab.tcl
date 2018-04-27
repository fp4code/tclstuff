package provide spalab 1.1

package require scilab

catch {::pvm::start_pvmd {} 1}
set tid [::scilab::pvm_spawn /home/fab/A/fidev/scilab/essai_pvm/esclave.sce]

proc ::scilab::execLines {tid lines} {
    foreach l [split $lines \n] {
	set l [string trim $l]
	if {$l == {}} {
	    continue
	}
	::scilab::exec $tid $l
    }
}

proc s {commande} {
    global tid
    ::scilab::exec $tid $commande
}

proc g {var} {
    global tid
    return [::scilab::get $tid $var]
}

proc ini {args} {
    global tid MODELE

    if [catch {array set argums $args}] {
        return -code error "Syntaxe: ini \[-modele xxx\]"
    }
    
    if {[info exists argums(-modele)]} {
        set MODELE $argums(-modele)
    } else {
        set MODELE sparams_HBT
        puts stderr "Modèle = $MODELE"
    }

    ::scilab::execLines $tid {
	sparams_path = '/home/fab/A/fidev/scilab/sparams/'
	getf(sparams_path+'sparams_genericTransform.sci')
	
	getf(sparams_path+'sparams_GfromS.sci')
	getf(sparams_path+'sparams_HfromS.sci')
	getf(sparams_path+'sparams_YfromS.sci')
	getf(sparams_path+'sparams_ZfromS.sci')
	getf(sparams_path+'sparams_SfromG.sci')
	getf(sparams_path+'sparams_SfromH.sci')
	getf(sparams_path+'sparams_SfromY.sci')
	getf(sparams_path+'sparams_SfromZ.sci')
    }

    puts "VERIFS: tout doit être << 0"
    
    scilab::exec $tid {ctmp=[%i;%i;%i]}
    scilab::exec $tid {s11=rand(ctmp); s12=rand(ctmp); s21=rand(ctmp); s22=rand(ctmp)}
    
    scilab::exec $tid {[y11, y12, y21, y22] = sparams_YfromS(s11, s12, s21, s22)}
    scilab::exec $tid {[s11n, s12n, s21n, s22n]=sparams_SfromY(y11, y12, y21, y22)}
    puts "y: 0 = [lindex [scilab::get $tid {max(abs([s11n, s12n, s21n, s22n] - [s11, s12, s21, s22]))}] 3]"
    
    scilab::exec $tid {[z11, z12, z21, z22] = sparams_ZfromS(s11, s12, s21, s22)}
    scilab::exec $tid {[s11n, s12n, s21n, s22n]=sparams_SfromZ(z11, z12, z21, z22)}
    puts "z: 0 = [lindex [scilab::get $tid {max(abs([s11n, s12n, s21n, s22n] - [s11, s12, s21, s22]))}] 3]"
    
    puts "yz: 0 = [lindex [scilab::get $tid {max(abs(-1+y11.*z11+y12.*z21))}] 3]"
    puts "yz: 0 = [lindex [scilab::get $tid {max(abs(y11.*z12+y12.*z22))}] 3]"
    puts "yz: 0 = [lindex [scilab::get $tid {max(abs(y21.*z11+y22.*z21))}] 3]"
    puts "yz: 0 = [lindex [scilab::get $tid {max(abs(-1+y21.*z12+y22.*z22))}] 3]"
    
    scilab::exec $tid {[g11, g12, g21, g22] = sparams_GfromS(s11, s12, s21, s22)}
    scilab::exec $tid {[s11n, s12n, s21n, s22n]=sparams_SfromG(g11, g12, g21, g22)}
    puts "g: 0 = [lindex [scilab::get $tid {max(abs([s11n, s12n, s21n, s22n] - [s11, s12, s21, s22]))}] 3]"
    
    scilab::exec $tid {[h11, h12, h21, h22] = sparams_HfromS(s11, s12, s21, s22)}
    scilab::exec $tid {[s11n, s12n, s21n, s22n]=sparams_SfromH(h11, h12, h21, h22)}
    puts "h: 0 = [lindex [scilab::get $tid {max(abs([s11n, s12n, s21n, s22n] - [s11, s12, s21, s22]))}] 3]"
    
    puts "gh: 0 = [lindex [scilab::get $tid {max(abs(-1+g11.*h11+g12.*h21))}] 3]"
    puts "gh: 0 = [lindex [scilab::get $tid {max(abs(g11.*h12+g12.*h22))}] 3]"
    puts "gh: 0 = [lindex [scilab::get $tid {max(abs(g21.*h11+g22.*h21))}] 3]"
    puts "gh: 0 = [lindex [scilab::get $tid {max(abs(-1+g21.*h12+g22.*h22))}] 3]"
    
    ::scilab::execLines $tid {
	getf(sparams_path+'sparams_U_mason.sci')
	getf(sparams_path+'sparams_U_masonBis.sci')
	getf(sparams_path+'sparams_U_masonTer.sci')
	getf(sparams_path+'sparams_rimp.sci')
	getf(sparams_path+'sparams_SwithY.sci')
	getf(sparams_path+'sparams_SwithZ.sci')
	getf(sparams_path+'sparams_Scomb.sci')
	getf(sparams_path+'sparams_SofLine.sci')
	getf(sparams_path+'sparams_SofDiscretLine.sci')
	getf(sparams_path+'sparams_SexchangeBE.sci')
	getf(sparams_path+'sparams_HBT.sci')
	getf(sparams_path+'sparams_CalibOpen.sci')
	getf(sparams_path+'sparams_CalibCC.sci')
	getf(sparams_path+'sparams_CalibPass.sci')
    }

    scilab::exec $tid {ctmp=[%i;%i;%i]}
    scilab::exec $tid {s11=rand(ctmp); s12=rand(ctmp); s21=rand(ctmp); s22=rand(ctmp)}
    scilab::exec $tid {[s11b, s12b, s21b, s22b]=sparams_SexchangeBE(s11, s12, s21, s22)}
    scilab::exec $tid {[s11e, s12e, s21e, s22e]=sparams_SexchangeBE(s11b, s12b, s21b, s22b)}
    puts "e->b->e: 0 = [lindex [scilab::get $tid {max(abs([s11, s12, s21, s22] - [s11e, s12e, s21e, s22e]))}] 3]"

    scilab::exec $tid {CC_s11=-ones(ctmp); CC_s12=zeros(ctmp); CC_s21=zeros(ctmp); CC_s22=-ones(ctmp)}
    scilab::exec $tid {Z1=rand(ctmp); Z2=rand(ctmp); Z3=rand(ctmp); Z4=rand(ctmp);}
    scilab::exec $tid {[s11, s12, s21, s22]=sparams_SwithZ(CC_s11, CC_s12, CC_s21, CC_s22, Z1, Z2, Z1)}
    scilab::exec $tid {[s11, s12, s21, s22]=sparams_SwithY(s11, s12, s21, s22, Z3, Z4, Z4)}
    scilab::exec $tid {[s11n, s12n, s21n, s22n]=sparams_SexchangeBE(s11, s12, s21, s22)}
    puts "eb sym: 0 = [lindex [scilab::get $tid {max(abs([s11, s12, s21, s22] - [s11n, s12n, s21n, s22n]))}] 3]"
}

proc stringReplace {s old new} {
    set ret ""
    set ii [string length $old]
    incr ii 1
    while {[set i [string first $old $s]] >= 0} {
	incr i -1
	if {$i >= 0} {
	    append ret [string range $s 0 $i]
	}
	append ret $new
	incr i $ii
	set s [string range $s $i end]
	if {$s == ""} {
	    return $ret
	}
    }
    append ret $s
    return $ret
}

proc plot {f val} {
    global tid gp

    set m2 [lindex [::scilab::get $tid $val] 3]
    set f [lindex [::scilab::get $tid $f] 3]
    puts $gp "plot \"-\" title '[stringReplace $val ' \\']' with lines"
    foreach a $f b $m2 {
	puts $gp "$a $b"
    }
    puts $gp e
}

proc rimp {tid var} {

# 13 juillet 1999: f varie le long des colonnes
    set rimp [::scilab::get $tid sparams_rimp(${var}).']
    set size [lindex $rimp 0]
    set rimp [lindex $rimp 3]

    set from 0
    set rmin [lindex $rimp $from]
    incr from 1
    set rmax [lindex $rimp $from]
    incr from 1
    set to [expr {$from + $size-3}]
    set r [lrange $rimp $from $to]

    set from [expr {$to+1}]
    set imin [lindex $rimp $from]
    incr from 1
    set imax [lindex $rimp $from]
    incr from 1
    set to [expr {$from + $size-3}]
    set i [lrange $rimp $from $to]

    set from [expr {$to+1}]
    set mmin [lindex $rimp $from]
    incr from 1
    set mmax [lindex $rimp $from]
    incr from 1
    set to [expr {$from + $size-3}]
    set m [lrange $rimp $from $to]

    set from [expr {$to+1}]
    set pmin [lindex $rimp $from]
    incr from 1
    set pmax [lindex $rimp $from]
    incr from 1
    set to [expr {$from + $size-3}]
    set p [lrange $rimp $from $to]

    return [list $r $i $m $p $rmin $imin $mmin $pmin $rmax $imax $mmax $pmax]
}

proc plot1param {tid gp xpos ypos f param var var1 var2 rerange imrange logrange degrange} {
    foreach {r i m p rmin imin mmin pmin rmax imax mmax pmax} [rimp $tid $var] {}
    foreach {r1 i1 m1 p1 r1min i1min m1min p1min r1max i1max m1max p1max} [rimp $tid $var1] {}
    foreach {r2 i2 m2 p2 r2min i2min m2min p2min r2max i2max m2max p2max} [rimp $tid $var2] {}
    
    # puts [list $imax $i1max $i2max]

    foreach x {r i m p} range {rerange imrange logrange degrange} {
	if {[set $range] == "\[\]"} {
	    set xmin [set ${x}min]
	    set x1min [set ${x}1min]
	    set x2min [set ${x}2min]
	    if {$x1min < $xmin} {set xmin $x1min}
	    if {$x2min < $xmin} {set xmin $x2min}
	    if {$xmin != 0.0} {
		if {$xmin > 0} {
		    set sign 1
		} else {
		    set sign -1
		}
		set expos_min [expr {pow(10, floor(log10(abs($xmin))))}]
	    } else {
		# dirty!
		set expos_min 1e30
	    }
	    set xmax [set ${x}max]
	    set x1max [set ${x}1max]
	    set x2max [set ${x}2max]
	    if {$x1max > $xmax} {set xmax $x1max}
	    if {$x2max > $xmax} {set xmax $x2max}
	    if {$xmax != 0.0} {
		if {$xmax > 0} {
		    set sign 1
		} else {
		    set sign -1
		}
		set expos_max [expr {pow(10, floor(log10(abs($xmax))))}]
	    } else {
		# dirty!
		set expos_max 1e30
	    }
	    set expos [expr {$expos_min>$expos_max?$expos_min:$expos_max}]
	    
	    # puts [list $x $imax $i1max $i2max [set ${x}max] [set ${x}1max] [set ${x}2max] $xmax $x1max $x2max $expos]
	    set xmin [expr {floor($xmin/$expos)*$expos}]
	    set xmax [expr {ceil($xmax/$expos)*$expos}]

	    # puts "set $range \"$xmin:$xmax\""
	    set $range "\[$xmin:$xmax\]"
	}
    }
    
    puts $gp "set origin $xpos,[expr {$ypos+0.24}]"
    puts $gp "set yrange $rerange"
    puts $gp "set y2range $imrange"
    puts $gp "plot \\"
    puts $gp "\"-\" axes x1y1 title 'real($param)_$rerange' with lines lt 2 lw 2,\\"
    puts $gp "\"-\" axes x1y1 title '' with lines lt 5,\\"
    puts $gp "\"-\" axes x1y1 title '' with lines lt 2,\\"
    puts $gp "\"-\" axes x1y2 title 'imag($param)_$imrange' with lines lt 1 lw 2,\\"
    puts $gp "\"-\" axes x1y2 title '' with lines lt 4,\\"
    puts $gp "\"-\" axes x1y2 title '' with lines lt 1"
    foreach a $f b $r {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $r1 {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $r2 {
	puts $gp "$a $b"
    }
    puts $gp e

    foreach a $f b $i {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $i1 {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $i2 {
	puts $gp "$a $b"
    }
    puts $gp e

    puts $gp "set origin $xpos,$ypos"
    puts $gp "set y2range $logrange"
    puts $gp "set yrange $degrange"
    puts $gp "plot \\"
    puts $gp " \"-\" axes x1y1 title 'deg($param)_$degrange' with lines lt 6 lw 2,\\"
    puts $gp " \"-\" axes x1y1 title '' with lines lt 8,\\"
    puts $gp " \"-\" axes x1y1 title '' with lines lt 6,\\"
    puts $gp "\"-\" axes x1y2 title 'db($param)_$logrange' with lines lt 3 lw 2,\\"
    puts $gp "\"-\" axes x1y2 title '' with lines lt 5,\\"
    puts $gp "\"-\" axes x1y2 title '' with lines lt 3"
    foreach a $f b $p {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $p1 {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $p2 {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $m {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $m1 {
	puts $gp "$a $b"
    }
    puts $gp e
    foreach a $f b $m2 {
	puts $gp "$a $b"
    }
    puts $gp e
    flush $gp
}
 
proc openplots {} {
    upvar gp gp
    upvar ter ter
    upvar NewTer NewTer
    upvar xpos xpos
    upvar ypos ypos
    global GNUPRINT

    

    puts $gp "set auto x"
    puts $gp "set auto y"
    puts $gp "set auto y2"
    puts $gp "set ytics nomirror"
    puts $gp "set y2tics"
    puts $gp "set size 0.25,0.24"
    puts $gp "set lmargin 1"
    puts $gp "set rmargin 1"
    puts $gp "set bmargin 0"
    puts $gp "set tmargin 0"

    puts $gp "set format x \"\""
    puts $gp "set format y \"\""
    puts $gp "set format y2 \"\""

    set xpos 0.
    set ypos 0.5
    if {[info exists GNUPRINT]} {
        foreach l $GNUPRINT {
            puts $gp $l
        }
        set NewTer 0
    } else {
        set ter 0
        set NewTer 1
    }

}


proc aplot {var rerange imrange logrange degrange} {
    upvar tid tid
    upvar gp gp
    upvar f f
    upvar ter ter
    upvar NewTer NewTer
    upvar xpos xpos
    upvar ypos ypos
    upvar nmod nmod
    upvar prefix prefix

    set rerange \[$rerange\]
    set  imrange \[$imrange\]
    set  logrange \[$logrange\]
    set  degrange \[$degrange\]

    if {$NewTer == 1} {
	puts $gp "set nomultiplot"
	puts $gp "set ter X11 $ter"
	puts $gp "set multiplot"
	set NewTer 0
    }

    plot1param $tid $gp $xpos $ypos $f $var ${prefix}$var A${nmod}_$var B${nmod}_$var $rerange $imrange $logrange $degrange

    set xpos [expr {$xpos+0.25}]
    if {$xpos > 1.01-0.25} {
	set xpos 0.0
	set ypos [expr {$ypos-0.5}]
	if {$ypos < -0.01} {
	    set ypos 0.5
	    puts $gp "set nomultiplot"
	    incr ter
	    set NewTer 1
	}
    }
}

proc closeplots {} {
    upvar NewTer NewTer
    upvar gp gp

    if {!$NewTer} {
	puts $gp "set nomultiplot"
    }
}

proc discretLine {tid Zrel delay fSciVar sPrefix fmaxrel} {
    set fmax [lindex [scilab::get $tid "max($fSciVar)"] 3]
    set ft [expr {$fmax/$fmaxrel}]
    set Nelem [expr {3.14*$ft*$delay}]
    puts "$Nelem éléments"
    set log2Nelem [expr {ceil(log($Nelem)/log(2.))}]
    scilab::exec $tid "\[${sPrefix}s11, ${sPrefix}s12, ${sPrefix}s21, ${sPrefix}s22\] = sparams_SofDiscretLine($ft, $Zrel, $log2Nelem, $fSciVar)"
} 

proc essaiDiscretLine {nelems} {
    global tid
    set ft 1e9
    set Zrel 0.1
    set fmin [expr {0.011*$ft}]
    set fmax [expr {0.0111*$ft}]
    set df [expr {($fmax-$fmin)/1000.}]
    scilab::exec $tid "f=($fmin:$df:$fmax).'"
    set delay [expr {$nelems/(3.14*$ft)}]
    set ncycles [expr {$delay*($fmax-$fmin)}]
    puts "prévu $ncycles cycles"
    discretLine $tid $Zrel $delay f essai_ [expr {$fmax/$ft}]
#    scilab::exec $tid {xclear(0); plot(f, real(essai_s21))}
    scilab::exec $tid {xclear(0); [p,m]=phasemag(essai_s21); plot(f, m)}
#    scilab::exec $tid {xclear(0); plot(f, abs(essai_s21))}
    scilab::exec $tid "omegaT = 2*%pi*$delay*f"
    scilab::exec $tid "\[essai2_s11, essai2_s12, essai2_s21, essai2_s22\] = sparams_SofLine($Zrel, omegaT)"

}

proc m {args} {
    global tid prefix PMOD nmod MODELE

    modele $tid $prefix A $MODELE
    # il faut appeler modele pour transmettre les P_
    calcvarsIni $tid $prefix
    calcvars $tid $prefix $prefix
    calcvars $tid $prefix A${nmod}_

    foreach {key value} $args {
	set SAVE($key) $PMOD($key)
	puts "set PMOD($key) $value"
	set PMOD($key) $value
    }

    modele $tid $prefix B $MODELE
    calcvars $tid $prefix B${nmod}_

    foreach key [array names SAVE] {
	puts "set PMOD($key) $SAVE($key)"
	set PMOD($key) $SAVE($key)
    }

    superplot $prefix
}

proc ms {args} {
    global PMOD
    foreach {key value} $args {
	set PMOD($key) $value
    }
}

proc corrlig {tid prefix v Rp Cp Zrel nL} {
    global nmod PMOD NODEFALQUE

    if {[info exists NODEFALQUE] && $NODEFALQUE} {
        return -code error "La variable \"NODEFALQUE\" doit valoir 0"
    }

    foreach varName {Rp Cp Zrel nL} {
	::scilab::exec $tid "P_$varName=$PMOD($varName)"
    }

    # calcul des lignes défalquantes

    ::scilab::exec $tid "omega=(2.)*(%pi)*${prefix}f"

    ::scilab::exec $tid "yPadMinus=P_Z0*%i*(-($Cp)).*omega"
    ::scilab::exec $tid "rPadMinus=(-($Rp)/P_Z0)*ones(omega)"
    ::scilab::exec $tid "\[slm11, slm12, slm21, slm22\]=sparams_SofLine($Zrel, ((-($nL))/299792458.).*omega)"
    ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithY(slm11,slm12,slm21,slm22, zeros(omega), yPadMinus, zeros(omega))"
    ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithZ(slmg11,slmg12,slmg21,slmg22, zeros(omega), rPadMinus, zeros(omega))"
    ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithY(slm11,slm12,slm21,slm22, yPadMinus, zeros(omega), zeros(omega))"
    ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithZ(slmd11,slmd12,slmd21,slmd22, rPadMinus, zeros(omega), zeros(omega))"
    set p ${v}${nmod}_

    # on défalque la ligne et la capa de pads
    
    ::scilab::exec $tid "\[${p}s11, ${p}s12, ${p}s21, ${p}s22\] =\
            sparams_Scomb(slmg11,slmg12,slmg21,slmg22, ${prefix}s11,${prefix}s12,${prefix}s21,${prefix}s22)"	
    ::scilab::exec $tid "\[${p}s11, ${p}s12, ${p}s21, ${p}s22\] =\
            sparams_Scomb(${p}s11,${p}s12,${p}s21,${p}s22, slmd11,slmd12,slmd21,slmd22)"	
    
    
    # calcul des lignes falquantes (defalquées dans superplot!)

    ::scilab::exec $tid "yPad=P_Z0*%i*(P_Cp).*omega"
    ::scilab::exec $tid "rPad=(P_Rp/P_Z0)*ones(omega)"
    ::scilab::exec $tid "\[slm11, slm12, slm21, slm22\]=sparams_SofLine(P_Zrel, ((P_nL)/299792458.).*omega)"
    ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithY(slm11,slm12,slm21,slm22, zeros(omega), yPad, zeros(omega))"
    ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithZ(slmg11,slmg12,slmg21,slmg22, zeros(omega), rPad, zeros(omega))"
    ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithY(slm11,slm12,slm21,slm22, yPad, zeros(omega), zeros(omega))"
    ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithZ(slmd11,slmd12,slmd21,slmd22, rPad, zeros(omega), zeros(omega))"
    # on falque la ligne et la capa de pads
    
    set p ${v}${nmod}_
    ::scilab::exec $tid "\[${p}s11, ${p}s12, ${p}s21, ${p}s22\] =\
            sparams_Scomb(slmg11,slmg12,slmg21,slmg22, ${p}s11,${p}s12,${p}s21,${p}s22)"	
    ::scilab::exec $tid "\[${p}s11, ${p}s12, ${p}s21, ${p}s22\] =\
            sparams_Scomb(${p}s11,${p}s12,${p}s21,${p}s22, slmd11,slmd12,slmd21,slmd22)"	
}


proc mm {RpA RpB CpA CpB zRelA zRelB nLA nLB} {
    global tid prefix PMOD nmod
    corrlig $tid $prefix A $RpA $CpA $zRelA $nLA
    corrlig $tid $prefix B $RpB $CpB $zRelB $nLB
    calcvarsIni $tid $prefix
    calcvars $tid $prefix $prefix
    calcvars $tid $prefix A${nmod}_
    calcvars $tid $prefix B${nmod}_
    superplot $prefix
}



#############################################
################ MODIFIABLES ################
set didi [file dirname [info script]]
source [file join ${didi} optim.tcl]

set HELP(modele) {
    juillet 1999 (FP) construction
      5 mai 2000 (FP) On met le modele en argument

}

proc modele {tid prefix v modele} {
    global nmod
    global PMOD

    # Construction en émetteur commun
    # v est la version

    # nettoyage et initialisation des variables

    ::scilab::exec $tid {names=who('get')}
    set names [lindex [::scilab::get $tid names] 3]
    foreach name $names {
	if {[string match P_* $name]} {
	    ::scilab::exec $tid "clear $name"
	}
    }

    foreach varName [array names PMOD] {
	::scilab::exec $tid "P_$varName=$PMOD($varName)"
    }

    # On relit à chaque fois le programme scilab, c'est plus sûr
    ::scilab::exec $tid "getf(sparams_path+'${modele}.sci')"

    set nmod 9
    set vn ${v}$nmod
    ::scilab::exec $tid "\[${vn}_s11,${vn}_s12,${vn}_s21,${vn}_s22\] = ${modele}(${prefix}f)"
}


proc calcvarsIni {tid prefix} {
    global NODEFALQUE

    if {![info exists NODEFALQUE] || !$NODEFALQUE} {

        # calcul des lignes défalquantes
        
        ::scilab::exec $tid "omega=(2.)*(%pi)*${prefix}f"
        ::scilab::exec $tid "yPadMinus=P_Z0*%i*(-P_Cp).*omega"
        ::scilab::exec $tid "rPadMinus=(-P_Rp/P_Z0)*ones(omega)"
        ::scilab::exec $tid "\[slm11, slm12, slm21, slm22\]=sparams_SofLine(P_Zrel, ((-P_nL)/299792458.).*omega)"
        ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithY(slm11,slm12,slm21,slm22, zeros(omega), yPadMinus, zeros(omega))"
        ::scilab::exec $tid "\[slmg11, slmg12, slmg21, slmg22\]=sparams_SwithZ(slmg11,slmg12,slmg21,slmg22, zeros(omega), rPadMinus, zeros(omega))"
        ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithY(slm11,slm12,slm21,slm22, yPadMinus, zeros(omega), zeros(omega))"
        ::scilab::exec $tid "\[slmd11, slmd12, slmd21, slmd22\]=sparams_SwithZ(slmd11,slmd12,slmd21,slmd22, rPadMinus, zeros(omega), zeros(omega))"
    }
}


proc calcvars {tid prefix p} {
    global NODEFALQUE MODELE

    ::scilab::exec $tid "omega=(2.)*(%pi)*${prefix}f"

    # calcul des variables destinées à être tracées
    
    if {$MODELE == "sparams_HBT"} {
        ::scilab::exec $tid "\[${p}y11, ${p}y12, ${p}y21, ${p}y22\] = sparams_YfromS(${p}s11, ${p}s12, ${p}s21, ${p}s22)"
        ::scilab::exec $tid "\[${p}z11, ${p}z12, ${p}z21, ${p}z22\] = sparams_ZfromS(${p}s11, ${p}s12, ${p}s21, ${p}s22)"
        ::scilab::exec $tid "\[${p}h11, ${p}h12, ${p}h21, ${p}h22\] = sparams_HfromS(${p}s11, ${p}s12, ${p}s21, ${p}s22)"
        ::scilab::exec $tid "${p}racU = sqrt(sparams_U_mason(${p}s11, ${p}s12, ${p}s21, ${p}s22))"
        ::scilab::exec $tid "${p}oldzb = (${p}h11.*${p}h22 - ${p}h12.*${p}h21 - ${p}h12)./${p}h22"
        ::scilab::exec $tid "${p}ttim = (${p}z12-${p}z21)./(${p}z22-${p}z21)"
    }
   
    #	::scilab::exec $tid "${p}spiegel = P_Z0*(${p}z11 - ${p}z12)"
    #	::scilab::exec $tid "${p}spiegel = real(${p}spiegel) + %i*1e12*imag(${p}spiegel)./omega"
    #	::scilab::exec $tid "${p}spiegel2 = P_Z0*${p}z12"
    #	::scilab::exec $tid "${p}spiegel2 = real(${p}spiegel2) + %i*1e12*imag(${p}spiegel2)./omega"
    

    if {![info exists NODEFALQUE] || !$NODEFALQUE} {
        # on défalque la ligne et la capa de pads
        puts "! on defalque !"
    
        ::scilab::exec $tid "\[${p}ns11, ${p}ns12, ${p}ns21, ${p}ns22\] =\
                sparams_Scomb(slmg11,slmg12,slmg21,slmg22, ${p}s11,${p}s12,${p}s21,${p}s22)"	
        ::scilab::exec $tid "\[${p}ns11, ${p}ns12, ${p}ns21, ${p}ns22\] =\
                sparams_Scomb(${p}ns11,${p}ns12,${p}ns21,${p}ns22, slmd11,slmd12,slmd21,slmd22)"	
    } else {
        ::scilab::exec $tid "${p}ns11 = ${p}s11"
        ::scilab::exec $tid "${p}ns12 = ${p}s12"
        ::scilab::exec $tid "${p}ns21 = ${p}s21"
        ::scilab::exec $tid "${p}ns22 = ${p}s22"
    }

    if {$MODELE == "sparams_HBT"} {

        # on calcule en Base commune
        ::scilab::exec $tid "\[${p}bs11, ${p}bs12, ${p}bs21, ${p}bs22\] = sparams_SexchangeBE(${p}ns11, ${p}ns12, ${p}ns21, ${p}ns22)"
        
        ::scilab::exec $tid "\[${p}bz11, ${p}bz12, ${p}bz21, ${p}bz22\] = sparams_ZfromS(${p}bs11, ${p}bs12, ${p}bs21, ${p}bs22)"
        
        ::scilab::exec $tid "${p}zb = ${p}bz12"
        ::scilab::exec $tid "${p}ze = ${p}bz11 - ${p}bz12"
        ::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
        ::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
        # ::scilab::exec $tid "${p}efit1 = real(${p}ze) + (1e12*%i/(2*%pi))*imag(${p}ze)./${prefix}f"
        # ::scilab::exec $tid "${p}efit2 = ones(${p}ze)./(real(${p}ze) - P_Re) + (1e-12*%i/(2*%pi))*ones(${p}ze)./(-imag(${p}ze)./${prefix}f + P_Le)"
        ::scilab::exec $tid "${p}unsurzcc = ones(${p}ze)./${p}zcc"
        ::scilab::exec $tid "${p}cfit1 = real(${p}zcc) + (1e12*%i/(2*%pi))*imag(${p}zcc)./${prefix}f"
        ::scilab::exec $tid "${p}cfit2 = ones(${p}zcc)./(real(${p}zcc) - P_Rc) + %i*1e-12*((1/(2*%pi))*ones(${p}ze)./(-imag(${p}zcc)./${prefix}f + P_Lc))"
        #    ::scilab::exec $tid "${p}alpha = (P_Z0/P_Ro).*${p}zce.*(1+%i*2*%pi*${prefix}f.*P_Ro.*P_cc).*(1+%i*2*%pi*${prefix}f.*P_ce.*P_re)"
        ::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"
    }
}

proc superplot {prefix} {
    global tid gp nmod

    # utilisé par gnuplot

    set f [lindex [::scilab::get $tid ${prefix}f] 3]

    # ATTENTIION : ter, NewTer, xpos et ypos sont modifiés par upvar dans "iniplot" et "aplot"

    openplots
    plotall
    closeplots
}

# Attention, une seconde version suit

proc plotall {} {
    uplevel {
	puts $gp {set xrange [8e9:14e9]}
	puts $gp {set xrange [.5e9:10e9]}
	aplot cfit2 {-50:50} {0:0.005} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [.5e9:50e9]}
	aplot zb {0:2} {-1:1} {-10:20} {-360:-300}
	aplot ze {0:0.4} {-0.4:0} {-40:0} {-90:0}
	aplot efit1 {-2:2} {-4:0} {-40:40} {-360:0}
	aplot efit2 {0:50} {-20:20} {-40:40} {-360:0}
	aplot zcc {} {} {} {}
	aplot cfit1 {-20:80} {-3000:0} {0:120} {-360:0}
	#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
#	aplot h21 {0:15} {-15:0} {5:25} {-90:0}
#	aplot racU {0:15} {0:10} {5:25} {0:90}
#	puts $gp {set nologscale x}
#	aplot bs21 {-10:10} {-10:10} {0:20} {-360:0}
#	aplot bs22 {0:2} {-2:0} {-5:5} {-90:0}
#	aplot s11 {-1:1} {-1:1} {-20:0} {-360:0}
#	aplot s12 {0:0.05} {0.:0.05} {-40:-20} {-360:-270}
#	aplot s21 {-10:10} {-10:10} {0:20} {-360:0}
#	aplot s22 {0:1} {-1:0} {-5:0} {-90:0}
    }
}


proc plotall {} {
    uplevel {
	puts $gp {set nologscale x}
	puts $gp {set xrange [0e9:50e9]}
	aplot zb {} {} {} {}
	aplot ze {} {} {} {}
#	aplot ze {0:0.5} {-0.5:0} {-40:0} {-90:0}
	aplot efit1 {} {} {} {}
#	aplot efit2 {0:50} {-20:20} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [0.5e9:50e9]}
	aplot zcc {} {} {} {}
	aplot cfit1 {} {} {} {}
	aplot s11 {} {} {} {}
	aplot s12 {} {} {} {}
	aplot s21 {} {} {} {}
	aplot s22 {} {} {} {}
	aplot h21 {} {} {} {}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
#	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
    }
}




# impression des paramètres

proc ppmod {} {
    global PMOD prefix
    puts "set prefix $prefix"
    foreach v [array names PMOD] {
	set nonvus($v) {}
    }
    foreach v {Z0 Zrel nL Cp Rp rb\
            Rb RbS CbS Lb\
            re\
            Re ReS CeS Le\
            Ro cc cc_ext\
            Rc RcS CcS Lc\
            typAlpha alpha0\
            taue1 tauc1 taue2 tauc2} {
	if {[info exists PMOD($v)]} {
            puts "set PMOD($v) $PMOD($v)"
            unset nonvus($v)
        }
    }
    foreach v [lsort [array names nonvus]] {
	puts "set PMOD($v) $PMOD($v)"
    }
}

# fit de alpha : fraction rationnelle de degré deg

proc fitalpha {deg args} {
    global tid prefix
    set p $prefix
    if {$args == {}} {
	set freqmul 1
    } else {
	set freqmul $args
    }
    ::scilab::exec $tid "f=\[${p}f*$freqmul\]"
    ::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
    ::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
    ::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

    ::scilab::exec $tid "fresp=\[${prefix}alpha\]"
    ::scilab::exec $tid "\[h, erreur\]=frep2tf(f,fresp,$deg,'c',\[1.e-6; 1.e-12; 50\],ones(f))"
#    ::scilab::exec $tid "\[h, erreur\]=frep2tf_b(f,fresp,$deg,'c',ones(f))"
    ::scilab::exec $tid "hn=coeff(numer(h))"
    ::scilab::exec $tid "hd=coeff(denom(h))"
    
    set numer [lindex [::scilab::get $tid hn] 3]
    set denom [lindex [::scilab::get $tid hd] 3]
    puts "# err=[lindex [::scilab::get $tid erreur] 3]"

    puts "set PMOD(numer) \{\[$numer\]\}" 
    puts "set PMOD(denom) \{\[$denom\]\}" 
   
    ::scilab::exec $tid "frespfit=repfreq(syslin('c', poly(\[$numer\], 's', 'coeff'), poly(\[$denom\], 's', 'coeff')),f)"
    ::scilab::exec $tid "xbasc(0)"
    ::scilab::exec $tid "bode(f,\[fresp;frespfit\])"
}

# 27 juillet 1999 (FP) normalisation par abs(fresp)
proc fitalphaNew {deg args} {
    global tid prefix
    set p $prefix
    if {$args == {}} {
	set freqmul 1
    } else {
	set freqmul $args
    }
    ::scilab::exec $tid "f=\[${p}f*$freqmul\]"
    ::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
    ::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
    ::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

    ::scilab::exec $tid "fresp=\[${prefix}alpha\]"
#    ::scilab::exec $tid "\[h, erreur\]=frep2tf(f,fresp,$deg,'c',\[1.e-6; 1.e-12; 50\],1./abs(fresp))"
    ::scilab::exec $tid "\[h, erreur\]=frep2tf_b(f,fresp,$deg,'c',1./abs(fresp))"
    ::scilab::exec $tid "hn=coeff(numer(h))"
    ::scilab::exec $tid "hd=coeff(denom(h))"
    
    set numer [lindex [::scilab::get $tid hn] 3]
    set denom [lindex [::scilab::get $tid hd] 3]
    puts "# err=[lindex [::scilab::get $tid erreur] 3]"

    puts "set PMOD(numer) \{\[$numer\]\}" 
    puts "set PMOD(denom) \{\[$denom\]\}" 
   
    ::scilab::exec $tid "frespfit=repfreq(syslin('c', poly(\[$numer\], 's', 'coeff'), poly(\[$denom\], 's', 'coeff')),f)"
    ::scilab::exec $tid "xbasc(0)"
    ::scilab::exec $tid "bode(f,\[fresp;frespfit\])"




    set freqmul 1e-6
    set p $prefix
    s "f=\[${p}f*$freqmul\]"
    s {[h,err]=frep2tf_b(f,fresp,2,'c',ones(f))}
    g err

}

proc fitalphaTer {deg fmax} {
    global tid prefix

    set p $prefix
    set freqmul 1

    ::scilab::exec $tid "goods=find(${p}f<=$fmax)"

    ::scilab::exec $tid "f_vis=\[${p}f*$freqmul\]"
    ::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
    ::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
    ::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

    ::scilab::exec $tid "fresp=\[${prefix}alpha\]"
    ::scilab::exec $tid "\[h, erreur\]=frep2tf(f_vis(goods),fresp(goods),$deg)"

    ::scilab::exec $tid "hn=coeff(numer(h))"
    ::scilab::exec $tid "hd=coeff(denom(h))"
    
    set numer [lindex [::scilab::get $tid hn] 3]
    set denom [lindex [::scilab::get $tid hd] 3]
    puts "# err=[lindex [::scilab::get $tid erreur] 3]"

    puts "set PMOD(numer) \{\[$numer\]\}" 
    puts "set PMOD(denom) \{\[$denom\]\}" 
   
    ::scilab::exec $tid "frespfit=repfreq(syslin('c', poly(\[$numer\], 's', 'coeff'), poly(\[$denom\], 's', 'coeff')),f_vis)"
    ::scilab::exec $tid "xbasc(0)"
    ::scilab::exec $tid "bode(f_vis,\[fresp;frespfit\])"
}



proc fitalphaBis {deg} {
    global tid prefix
    set p $prefix

    set freqmul 1e-12

    ::scilab::exec $tid "fTHz=\[${p}f*$freqmul, 10\]"
    ::scilab::exec $tid "weight=\[ones(${p}f), 1000\]"
    ::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
    ::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
    ::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

    ::scilab::exec $tid "fresp=\[${prefix}alpha, -1e-2*%i\]"
    ::scilab::exec $tid "\[h, erreur\]=frep2tf(fTHz,fresp,$deg,'c',\[1.e-2,1.e-4,10\],weight)"

    ::scilab::exec $tid "hn=coeff(numer(h))"
    ::scilab::exec $tid "hd=coeff(denom(h))"
    
    set numer [lindex [::scilab::get $tid hn] 3]
    set denom [lindex [::scilab::get $tid hd] 3]
    puts "# err=[lindex [::scilab::get $tid erreur] 3]"

    puts "set PMOD(numer) \{\[$numer\]\}" 
    puts "set PMOD(denom) \{\[$denom\]\}" 
   
    ::scilab::exec $tid "frespfit=repfreq(syslin('c', poly(\[$numer\], 's', 'coeff'), poly(\[$denom\], 's', 'coeff')), fTHz)"
    ::scilab::exec $tid "xbasc(0)"
    ::scilab::exec $tid "bode(fTHz,\[fresp;frespfit\])"
}


proc trep {} {
    global PMOD tid

    ::scilab::exec $tid "sl=syslin('c', poly($PMOD(numer), 's', 'coeff'), poly($PMOD(denom), 's', 'coeff'))"
    ::scilab::exec $tid "slss=tf2ss(sl); ssprint(slss)"

    ::scilab::exec $tid "frep=(0.001e12:0.01e12:10e12)"       
    ::scilab::exec $tid "xselect(); xbasc(); bode(frep, repfreq(slss, frep)); xpause(2d6)" 

    ::scilab::exec $tid "dt=0.1e-12"
    ::scilab::exec $tid "Ndt=10000"
    ::scilab::exec $tid "sldt=dscr(slss,dt);"
    ::scilab::exec $tid "t=dt*(1:Ndt)"

    ::scilab::exec $tid "u=ones(1,Ndt);"
    ::scilab::exec $tid "y=flts(u,sldt);"
    ::scilab::exec $tid "xselect(); xbasc(); beta=y./(1-y); plot2d(t(2:999),beta(2:999)); xpause(2d6)"

    ::scilab::exec $tid "u=zeros(1,1000);u(1)=1"
    ::scilab::exec $tid "y=flts(u,sldt);"
    # bidouille
    ::scilab::exec $tid "xselect(); xbasc(); plot2d(t(2:999),log10(abs(y(2:999))))"
}

set gp [open "|gnuplot 2>@ stderr" w]
fconfigure $gp -buffering line


######

set verif {
    


    # 1-2 CC, Ra entre 1-2 et 3
    scilab::exec $tid {Ra=[1; 2; 3]}
    scilab::exec $tid {ga11=(1.)./Ra}
    scilab::exec $tid {ga12=-ones(ga11)}
    scilab::exec $tid {ga21=ones(ga11)}
    scilab::exec $tid {ga22=zeros(ga11)}
    scilab::exec $tid {[sa11, sa12, sa21, sa22]=sparams_SfromG(ga11, ga12, ga21, ga22)}

    # 1-2 CC, Rb entre 1-2 et 3
    scilab::exec $tid {Rb=[1; 4; 1]}
    scilab::exec $tid {gb11=(1.)./Rb}
    scilab::exec $tid {gb12=-ones(gb11)}
    scilab::exec $tid {gb21=ones(gb11)}
    scilab::exec $tid {gb22=zeros(gb11)}
    scilab::exec $tid {[sb11, sb12, sb21, sb22]=sparams_SfromG(gb11, gb12, gb21, gb22)}

    # mise en // de Ra et Rb
    scilab::exec $tid {[sc11, sc12, sc21, sc22]=sparams_Scomb(sa11, sa12, sa21, sa22, sb11, sb12, sb21, sb22)}
    scilab::exec $tid {[gc11, gc12, gc21, gc22]=sparams_GfromS(sc11, sc12, sc21, sc22)}
    scilab::get $tid {[gc11, gc12, gc21, gc22]}

    scilab::exec $tid {f=1; Z=1}
    scilab::exec $tid {Pass_s11=zeros(f); Pass_s12=ones(f); Pass_s21=ones(f); Pass_s22=zeros(f)}
    scilab::exec $tid {CC_s11=-ones(f); CC_s12=zeros(f); CC_s21=zeros(f); CC_s22=-ones(f)}
    scilab::exec $tid {[as11, as12, as21, as22] = sparams_SwithY(Pass_s11, Pass_s12, Pass_s21, Pass_s22, 1./Z, 0, 0)}
    scilab::get $tid {[as11, as12, as21, as22]}
 
    scilab::exec $tid {[as11, as12, as21, as22] = sparams_SwithZ(CC_s11, CC_s12, CC_s21, CC_s22, 0, 0, Z)}
    scilab::get $tid {[as11, as12, as21, as22]}
    #verif
    scilab::exec $tid {s=[-1, 0;0, -1]}
    scilab::exec $tid {a=0.5*[Z,Z;Z,Z]*(eye(s)-s)}
    scilab::get $tid {(s+a)/(eye(a)+a)}
    
    ###################################################
    # construction d'une ligne par elements discrets. #
    ###################################################

    # codé en scilab : [s11, s12, s21, s22] = sparams_SofDiscretLine(ft, Z, Nelem, f)

    set resultats: {
     0.0001ft  524288        16.7     en 1e-4 ft
       0.01ft  524288        16.5     en 1e-4 ft
	0.1ft,  65536 elems,  2 tours en 1e-4 ft
               131072         4
	       262144         8
	       524288        17
	0.2ft,  65536 elems,  2 tours en 1e-4 ft
	       524288        17
	0.5ft, 524288 elems, 19 tours en 1e-4 ft
	0.8ft, 524288 elems, 28 tours en 1e-4 ft

	moralité: aux fréquences basses (<0.2 ft, ft=2/(2 pi sqrt(LC)))
	le temps de propagation de la phase vaut 16.7/524288e-4 = 1/(pi ft) = sqrt(LC) par cellule
    }

    scilab::exec $tid {C=0.1e-9}
    scilab::exec $tid {Z0=50}
    scilab::exec $tid {L=(Z0*Z0*C)}
    scilab::exec $tid {ft=2.0/(2*%pi*sqrt(L*C))}
    scilab::exec $tid {fmax=0.0001*ft}
    scilab::exec $tid {fmin=0.0002*ft}
    scilab::exec $tid {df=(fmax-fmin)/1000}

    # 1-2 en CC
    scilab::exec $tid {f=(fmin:df:fmax).'}
#    scilab::exec $tid {f=1e7}

    scilab::exec $tid {Pass_s11=zeros(f); Pass_s12=ones(f); Pass_s21=ones(f); Pass_s22=zeros(f)}
    scilab::exec $tid {CC_s11=-ones(f); CC_s12=zeros(f); CC_s21=zeros(f); CC_s22=-ones(f)}

    # une capa C entre 1 (=2) et 3
    scilab::exec $tid {Yc=Z0*(2.)*%pi*%i*C*f}
    scilab::exec $tid {[c_s11, c_s12, c_s21, c_s22] = sparams_SwithY(Pass_s11, Pass_s12, Pass_s21, Pass_s22, Yc, 0, 0)}

    # deux selfs L/2 sur 1 et sur 2
    
    scilab::exec $tid {Zl=(1/Z0)*(1/2)*(2.)*%pi*%i*L*f}
    scilab::exec $tid {[lc_s11, lc_s12, lc_s21, lc_s22] = sparams_SwithZ(c_s11, c_s12, c_s21, c_s22, Zl, Zl, 0)}
    
    # autre construction:
    scilab::exec $tid {Zc=(1/Z0)*(1.)./((2.)*%pi*%i*C*f)}
    scilab::exec $tid {[lc_s11b, lc_s12b, lc_s21b, lc_s22b] = sparams_SwithZ(CC_s11, CC_s12, CC_s21, CC_s22, Zl, Zl, Zc)}

    # verif:
    scilab::get $tid {max(abs([lc_s11, lc_s12, lc_s21, lc_s22] - [lc_s11b, lc_s12b, lc_s21b, lc_s22b]))}
    
    scilab::exec $tid {line_s11=lc_s11; line_s12=lc_s12; line_s21=lc_s21; line_s22=lc_s22}
    set nelem 1


    # repeat this:

    scilab::exec $tid {[line_s11, line_s12, line_s21, line_s22]\
	    = sparams_Scomb(line_s11, line_s12, line_s21, line_s22, line_s11, line_s12, line_s21, line_s22)}
    scilab::exec $tid {xclear(0); plot(real(line_s21))}
    set nelem [expr {2.*$nelem}]


    
    scilab::exec $tid "ft=1; fref=0.01*ft; df=1e-4*ft; f=(fref:df:fref+1000*df); Z=1; log2Nelem=19"
    scilab::exec $tid {[s11, s12, s21, s22] = sparams_SofDiscretLine(ft, Z, log2Nelem, f); xclear(0); plot(real(s21))}

    ##############################

    puts "ligne discrete"
    essaiDiscretLine 500000
    after 2000
    puts "ligne exacte"
    scilab::exec $tid {xclear(0); [p,m]=phasemag(essai2_s21); plot(f, m)}
    after 2000
    puts "ligne discrete"
    scilab::exec $tid {xclear(0); [p,m]=phasemag(essai_s21); plot(f, m)}
}
