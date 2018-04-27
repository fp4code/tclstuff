package require fidev
package require blasObj 0.2
package require supercomplex 0.2
package require blasmath 0.2

set PI [expr {atan2(0.0, -1.0)}]
set 2PI [expr {2*$PI}]

###########################################
# ordre minimal, maximal, nombre de modes #
###########################################

# OMIN = ordre de diffraction minimal
# OMAX = ordre de diffraction maximal
# NMOD = nombre de modes
# NORD = nombre d'ordres

set OMIN -10
set OMAX 10
set NMOD 15

set NORD [expr {$OMAX + 1 - $OMIN}]

# lambda = longueur d'onde en microns
# eV = énergie des photons en eV
# d = pas du réseau
# h = hauteur du réseau
# r1 = taux de GaAs
# r2 = taux de Ag
# kx0N = sin(incidence)

set lambda 0.8
set eV [expr {1.24/$lambda}]
set d 0.2
set h 0.055
set r1 0.5
set r2 [expr {1.0 - $r1}]
set kx0N 0.0

# k0 = nombre d'onde, dans le vide
# k0carre = k0*k0
# kx0 = projection du vecteur d'onde sur le réseau

set k0 [supercomplex create [expr {$2PI / $lambda}]]
set k0carre [supercomplex mul $k0 $k0]
set kx0 [supercomplex mul $k0 [supercomplex create $kx0N]]

# kR = vecteur d'onde du réseau
# kRv = vecteur doublecomplexe  0 -kR kR -2kR 2kR ... 
# kx = projection des vecteurs d'onde des ordres diffractés 0 -1 1 -2 2 ... 

set kR [expr {${2PI} / $d}]
set kRv [list 0.0 0.0]
for {set i- -1; set i+ 1} {${i-} >= $OMIN && ${i+} <= $OMAX } {incr i- -1; incr i+} {
    if {${i-} >= $OMIN} {
        lappend kRv [expr {${i-}*$kR}] 0.0
    }
    if {${i+} <= $OMAX} {
        lappend kRv [expr {${i+}*$kR}] 0.0
    }
}
set kRv [blas::vector create doublecomplex $kRv]

set kx [blas::vector create -copy $kRv]
blas::mathsvop kx +scal $kx0

set kx_cn [blas::vector create -copy $kx]
blas::mathsvop kx_cn * $kx_cn
blas::mathsvop kx_cn neg

set kz [blas::vector create -copy $kx_cn]
blas::mathsvop kz +scal $k0carre
blas::mathsvop kz sqrt
blas::mathsvop kz posimag

proc interpole {x1 y1 x2 y2 x} {
    if {$x < $x1 || $x > $x2} {
        if {$x1 > $x2} {
            return -code error "Erreur, \"interpole\" veut x1 <= x2"
        }
        return -code error "Erreur, \"interpole\" ne peut extrapoler"
    }
    if {$x1 == $x2} {
        if {$y1 != $y2} {
            return -code error "Erreur, \"interpole\" x1 == x2, y1 != y2"
        }
        return $y1
    }
    return [expr {((double($x) - double($x1))*$y2 + (double($x2) - double($x))*$y1)/(double($x2) - double($x1))}]
}

# epsAg = constante diélectrique complexe

set r [interpole 1.51 0.04 1.64 0.03 $eV]
set i [interpole 1.51 5.727 1.64 5.242 $eV]
set ri [supercomplex create xy $r $i]
set epsAg [supercomplex mul $ri $ri]

# epsGaAs = constante diélectrique complexe

set r [interpole 1.5 3.666 1.6 3.7 $eV]
set i [interpole 1.549 0.0682 1.6 0.093 $eV]
set ri [supercomplex create xy $r $i]
set epsGaAs [supercomplex mul $ri $ri]

package require eqvp 0.2

set polar TM
set DZwarn 1e-4
set eps1 $epsGaAs
set eps2 $epsAg
set XNm -10.0 
set XNp 10.0
set YNm -5.0
set YNp 30.0
set NDMAX 100
set DYMIN 1e-6
set DZM1 1e-6
set DZM2 1e-12
set divOfPeriod 20
set dl 0.01
set dtheta 0.005

set dN [expr {$d/$lambda}]
set d1N [expr {$r1*$dN}]
set d2N [expr {$r2*$dN}]

::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN

catch {::zerosComplexes::zeros ym al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_ym
catch {::zerosComplexes::zeros yp al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_yp
catch {::zerosComplexes::zeros xm al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_xm
catch {::zerosComplexes::zeros xp al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn} racines_xp

set ir 0
foreach r_ym $racines_ym  r_xp $racines_xm  r_yp $racines_yp r_xm $racines_xm {
    incr ir
    puts [list $ir $r_ym $r_xp $r_yp $r_xm]
}

# Les listes sont supposées nettoyées des racines doubles
set tout [lsort -command ::zerosComplexes::compareRacines [concat $racines_ym $racines_xm $racines_yp $racines_xm]]

set racines [list]

set Zprec [lindex $tout 0]
lappend racines $Zprec
set n 1
foreach Z [lrange $tout 1 end] {
    if {[supercomplex module [supercomplex sub $Z $Zprec]] <= $DZwarn} {
        incr n
    } else {
        lappend racines $n $Z
        set n 1
    }
    set Zprec $Z
}
lappend racines $n

set graclist [list]
set i 0
foreach {rac n} $racines {
    incr i
    puts "$i $n $rac"
    if {$n > 3} {
        lappend graclist [supercomplex re $rac] [supercomplex im $rac]
    }
}

if {[llength $graclist]/2 < $NMOD} {
    return -code error "On n'a que [expr {[llength $graclist]/2}] modes au lieu de $NMOD, augmenter YNp"
}

#############################################
########## Fin de calcul des modes ##########
#############################################

# kappaz = vecteur doublecomplex des vecteurs d'onde des modes

set kappaz [blas::vector create doublecomplex [lrange $graclist 0 [expr {$NMOD*2}]]]

# kappaz_cn = -kappaz^2

set kappaz_cn [blas::vector create -copy $kappaz]
blas::mathsvop kappaz_cn * $kappaz_cn
blas::mathsvop kappaz_cn neg

# kappa1x = projection sur le plan du réseau du vecteur d'onde des modes, dans le GaAs

set kappa1x [blas::vector create -copy $kappaz_cn]
blas::mathsvop kappa1x +scal [supercomplex mul $eps1 $k0carre]
blas::mathsvop kappa1x sqrt
blas::mathsvop kappa1x posimag

# kappa2x = projection sur le plan du réseau du vecteur d'onde des modes, dans Ag

set kappa2x [blas::vector create -copy $kappaz_cn]
blas::mathsvop kappa2x +scal [supercomplex mul $eps2 $k0carre]
blas::mathsvop kappa2x sqrt
blas::mathsvop kappa2x posimag

set x1 0.0
set x2 [expr {$r1*$d}]

set v1+ [blas::vector create doublecomplex -length [expr {$NORD*$NMOD}]]
set v2+ [blas::vector create doublecomplex -length [expr {$NORD*$NMOD}]]
set v1- [blas::vector create doublecomplex -length [expr {$NORD*$NMOD}]]
set v2- [blas::vector create doublecomplex -length [expr {$NORD*$NMOD}]]

for {set n 1; set offset 1} {$n <= $NORD} {incr n; incr offset} {
    set ligne1+ [blas::subvector create $offset $NORD $NMOD from v1+]
    set ligne2+ [blas::subvector create $offset $NORD $NMOD from v2+]
    set ligne1- [blas::subvector create $offset $NORD $NMOD from v1-]
    set ligne2- [blas::subvector create $offset $NORD $NMOD from v2-]
    blas::mathsvop ligne1+ + $kappa1x
    blas::mathsvop ligne2+ + $kappa2x
    blas::mathsvop ligne1- - $kappa1x
    blas::mathsvop ligne2- - $kappa2x
}

for {set nu 1; set offset 1} {$nu <= $NMOD} {incr nu; incr offset $NORD} {
    set colonne1+ [blas::subvector create $offset 1 $NORD from v1+]
    set colonne2+ [blas::subvector create $offset 1 $NORD from v2+]
    set colonne1- [blas::subvector create $offset 1 $NORD from v1-]
    set colonne2- [blas::subvector create $offset 1 $NORD from v2-]
    blas::mathsvop colonne1+ - $kx
    blas::mathsvop colonne2+ - $kx
    blas::mathsvop colonne1- - $kx
    blas::mathsvop colonne2- - $kx
}

blas::mathsvop v1+ *i
blas::mathsvop v2+ *i
blas::mathsvop v1- *i
blas::mathsvop v2- *i
blas::mathsvop v1+ *rscal [expr {$r1*$d}]
blas::mathsvop v2+ *rscal [expr {$r2*$d}]
blas::mathsvop v1- *rscal [expr {$r1*$d}]
blas::mathsvop v2- *rscal [expr {$r2*$d}]
blas::mathsvop v1+ exprl
blas::mathsvop v2+ exprl
blas::mathsvop v1- exprl
blas::mathsvop v2- exprl

set f1 $kx
blas::mathsvop f1 *i
set f2 $f1
blas::mathsvop f1 *rscal $x1
blas::mathsvop f2 *rscal $x2
blas::mathsvop f1 exp
blas::mathsvop f2 exp
blas::mathsvop f1 *rscal r1
blas::mathsvop f2 *rscal r2

for {set nu 1; set offset 1} {$nu <= $NMOD} {incr nu; incr offset $NORD} {
    set colonne1+ [blas::subvector create $offset 1 $NORD from v1+]
    set colonne2+ [blas::subvector create $offset 1 $NORD from v2+]
    set colonne1- [blas::subvector create $offset 1 $NORD from v1-]
    set colonne2- [blas::subvector create $offset 1 $NORD from v2-]
    blas::mathsvop colonne1+ * f1
    blas::mathsvop colonne1- * f1
    blas::mathsvop colonne2+ * f2
    blas::mathsvop colonne2- * f2
}

set f1 kappa1x
set f2 kappa2x
blas::mathsvop f1 *i 
blas::mathsvop f2 *i 
blas::mathsvop f1 *rscal [expr {$r1*$d}]
blas::mathsvop f2 *rscal [expr {$r2*$d}]

for {set n 1; set offset 1} {$n <= $NORD} {incr n; incr offset} {
    set ligne1+ [blas::subvector create $offset $NORD $NMOD from v1+]
    set ligne2+ [blas::subvector create $offset $NORD $NMOD from v2+]
    set ligne1- [blas::subvector create $offset $NORD $NMOD from v1-]
    set ligne2- [blas::subvector create $offset $NORD $NMOD from v2-]
    blas::mathsvop ligne1- * f1
    blas::mathsvop ligne2- * f2
}

set ir1+ [blas::matrix create 1 $NORD $NORD $NMOD $v1+]
set ir2+ [blas::matrix create 1 $NORD $NORD $NMOD $v2+]
set ir1- [blas::matrix create 1 $NORD $NORD $NMOD $v1-
set ir2- [blas::matrix create 1 $NORD $NORD $NMOD $v2-]

AFAIRE

blas::mathsvop exprl1+ neg
blas::mathsvop exprl1+ + $kappa1x
blas::mathsvop exprl1+ *i
blas::mathsvop exprl1+ 
blas::mathsvop exprl1+ exprl

set exprl1- [blas::vector create -copy $kRv]
blas::mathsvop exprl1- neg
blas::mathsvop exprl1- - $kappa1x
blas::mathsvop exprl1- *i
blas::mathsvop exprl1- *rscal [expr {$r1*$d}]
blas::mathsvop exprl1- exprl


set tmp [blas::vector create -copy $kappa1x]
blas::mathsvop tmp *i
blas::mathsvop tmp *rscal [expr {$r1*$d}]
blas::mathsvop tmp exp
blas::mathsvop exprl1- * $tmp



