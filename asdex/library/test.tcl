#!/usr/local/bin/wish

package require fidev
package require blas
package require asdex
package require -exact l2mGraph 1.2
package require aide
package require minihelp
package require horreur

proc ::asdex::test_win {B} {
    upvar #0 $B P

    set P(hyster) 2
    label $B.titre1 -text "Paramètres à fiter" -foreground black
    label $B.titre3 -text Fixe -foreground black
    label $B.titre4 -text Mini -foreground black
    label $B.titre5 -text Maxi -foreground black
    grid configure $B.titre1 x $B.titre3 $B.titre4 $B.titre5
    ::asdex::DefCoef $B 1 "Préfacteur exponentiel #1 (A)" 1 "1e-12" 1e-14 1e-6
    ::asdex::DefCoef $B 2 "Préfacteur exponentiel #2 (A)" 0 "1e-12" 1e-14 1e-9
    ::asdex::DefCoef $B 3 "Facteur d'idéalité #1 (eV)" 1 "0.02586" 0.025 0.050
    ::asdex::DefCoef $B 4 "Facteur d'idéalité #2 (eV)" 0 "0.02586" 0.025 0.050
    ::asdex::DefCoef $B 5 "Résistance série (Ohm)" 1 "5." 0. 1000.
    ::asdex::DefCoef $B 6 "Résistance parallèle" 1 "1e9" 1e5 1e10
    label $B.blanc1 -text " "
    label $B.blanc2 -text " "
    grid configure $B.blanc1 x x $B.titre4 $B.titre5
    ::asdex::DefDom  $B I "Domaine de courant (A)" 1e-15 0.1
    ::asdex::DefDom  $B V "Domaine de tension (V)" 0.0 1.0
    grid configure $B.blanc2 x x x x
    radiobutton $B.hyster1 -variable [set B](hyster) -value 1 -text descente -anchor w
    radiobutton $B.hyster2 -variable [set B](hyster) -value 2 -text montee
    radiobutton $B.hyster3 -variable [set B](hyster) -value 3 -text moyenne
    button $B.fitIt -text "Fit" -command "::asdex::fitIt $B"
    grid configure $B.fitIt - $B.hyster1 $B.hyster2 $B.hyster3 -sticky news
}


proc ::asdex::fitIt {B} {
    upvar #0 $B P
#    puts $P(fixe2)

    set coef [::blas::newVector double [list $P(fixe1) $P(fixe2) $P(fixe3) $P(fixe4) $P(fixe5) $P(fixe6)]]
    set flagcoef [::blas::newVector int [list $P(fit1) $P(fit2) $P(fit3) $P(fit4) $P(fit5) $P(fit6)]]
    set coefmin [::blas::newVector double [list $P(mini1) $P(mini2) $P(mini3) $P(mini4) $P(mini5) $P(mini6)]]
    set coefmax [::blas::newVector double [list $P(maxi1) $P(maxi2) $P(maxi3) $P(maxi4) $P(maxi5) $P(maxi6)]]
    set hyster [::blas::newVector int [list $P(hyster)]]
    set rdom [::blas::newVector double [list $P(miniI) $P(maxiI) $P(miniV) $P(maxiV)]]

# Appel routine d'initialisation des variables globales a DioDir
    ::asdex::IniDioDir $coef $flagcoef $coefmin $coefmax $hyster $rdom

    puts "et voici le travail:"
    foreach ve $P(Ve) ie $P(Ie) {
	puts "$ve $ie"
    }

    set v [::blas::newVector double $P(Ve)]
    set i [::blas::newVector double $P(Ie)]

# Fit des diodes polarisées en direct
    set chisq   [::blas::newVector double -length 1]
    ::asdex::DioDir $i $v $coef $chisq

# Appel fonction calcul I(V) theorique
    set ideb 1
    set ifin 1
    set itheo   [::blas::newVector double -length [::blas::getDataLength $i]]
    ::asdex::DioDirTheo $itheo $v ideb ifin

# Affichage des résultats
    set j 1
    foreach local [::blas::getVector $coef] {
        if {$j == 3 || $j == 4} {
          set P(fixe$j) [format %8.4g [expr {$local/0.02586}]]
        } else {
          set P(fixe$j) [format %8.4g $local]
        }
        incr j
    }

# Trace des courbes
    set listx1 [lrange [::blas::getVector $v] $ideb $ifin]
    set listy1 [lrange [::blas::getVector $i] $ideb $ifin]
    set listy2 [lrange [::blas::getVector $itheo] $ideb $ifin]
    if 0 {
	foreach x1 $listx1 y1 $listy1 y2 $listy2 {
	    puts "$x1 $y1 $y2"
	}
    }
    
    .graphfit.g1.c delete I(V)mod
    .graphfit.g1.c delete I(V)exp
    ::l2mGraph::plotSimple .graphfit.g1 $listx1 $listy1 -xscale x -yscale y -style croix -tags I(V)exp
    ::l2mGraph::plotSimple .graphfit.g1 $listx1 $listy2 -xscale x -yscale y -style lines -tags I(V)mod
#    ::l2mGraph::plotSimple .graphfit.g1 $listx1 $listy1 -xscale x -yscale y -style lines -tags I(V)exp
puts "listy1 = $listy1"
puts "listy2 = $listy2"
    ::l2mGraph::fullview2 .graphfit.g1 all

# Variations de chisq par parametres
    set indcoef [::blas::newVector int {1}]
    set coefvar [::blas::newVector double -length 100]
    set chisqvar [::blas::newVector double -length 100]
    set courbes {Prefac_1 Préfac_2 Ideal_1 Idéal_2 Rs Rp}
    foreach indcoef {1 2 3 4 5 6} {
      ::asdex::DioDirVar $i $v $indcoef $coefvar $chisqvar $ideb $ifin
      set listx [lrange [::blas::getVector $coefvar] 1 100]
      set listy [lrange [::blas::getVector $chisqvar] 1 100]
      .graphfit.g[expr {$indcoef+1}].c delete [lindex $courbes [expr {$indcoef-1}]]
      ::l2mGraph::toLog .graphfit.g[expr {$indcoef+1}] y
      ::l2mGraph::plotSimple .graphfit.g[expr {$indcoef+1}] $listx $listy -xscale x -yscale y -style lines -tags [lindex $courbes [expr {$indcoef-1}]]
    }

    puts "Coefs= [::blas::getVector $coef]"
    puts "chisq= [::blas::getVector $chisq]"
    ::blas::deleteVector $i
    ::blas::deleteVector $v
    ::blas::deleteVector $coef
    ::blas::deleteVector $chisq
    ::blas::deleteVector $flagcoef
    ::blas::deleteVector $coefmin
    ::blas::deleteVector $coefmax
    ::blas::deleteVector $hyster
    ::blas::deleteVector $rdom
}

proc ::asdex::DefCoef {B i text onoff fixe min max} {
    upvar #0 $B P
    set P(fixe$i) $fixe
    set P(fit$i) $onoff
    set P(mini$i) $min
    set P(maxi$i) $max
    set P(text$i) $text
    label $B.label$i -text $text -foreground yellow
    entry $B.fixe$i -textvariable [set B](fixe$i) -width 8 -foreground blue
    entry $B.mini$i -textvariable [set B](mini$i) -width 8 -foreground blue
    entry $B.maxi$i -textvariable [set B](maxi$i) -width 8 -foreground blue
    checkbutton $B.fit$i -variable [set B](fit$i) -anchor center
    grid configure $B.label$i $B.fit$i $B.fixe$i $B.mini$i $B.maxi$i -sticky news
}

proc ::asdex::DefDom {B i text min max} {
    upvar #0 $B P
    set P(mini$i) $min
    set P(maxi$i) $max
    label $B.label$i -text $text -foreground yellow
    entry $B.mini$i -textvariable [set B](mini$i) -width 8 -foreground green
    entry $B.maxi$i -textvariable [set B](maxi$i) -width 8 -foreground green
    grid configure $B.label$i x x $B.mini$i $B.maxi$i -sticky news
}

proc ::asdex::graph_win {B} {

    toplevel $B
    ::l2mGraph::createGraph $B.g1
    ::l2mGraph::createGraph $B.g2
    ::l2mGraph::createGraph $B.g3
    ::l2mGraph::createGraph $B.g4
    ::l2mGraph::createGraph $B.g5
    ::l2mGraph::createGraph $B.g6
    ::l2mGraph::createGraph $B.g7
    ::l2mGraph::boutons $B.ctrl           ;# ".ctrl" est obligatoire

    grid configure  $B.g1   $B.g2   $B.g3
    grid configure    ^     $B.g4   $B.g5
    grid configure    ^     $B.g6   $B.g7
    grid configure  $B.ctrl   ^       ^
    $B.g1 configure -width 600 -height 600
    $B.g2 configure -width 250 -height 250
    $B.g3 configure -width 250 -height 250
    $B.g4 configure -width 250 -height 250
    $B.g5 configure -width 250 -height 250
    $B.g6 configure -width 250 -height 250
    $B.g7 configure -width 250 -height 250

    ::l2mGraph::toLog $B.g1 y
}

proc ::asdex::iniEssaiIV {B} {
    upvar #0 $B P

    set P(callback) ::asdex::fitIt

    set P(Ve)      [list\
    -61e-5 -62e-5 -62e-5 -60e-5 -58e-5 -54e-5 -48e-5 -39e-5 -25e-5 -3e-5 31e-5 \
    84e-5 167e-5 295e-5 487e-5 769e-5 1167e-5 1708e-5 2403e-5 3252e-5 4237e-5 \
    5334e-5 6515e-5 7759e-5 9048e-5 10372e-5 11726e-5 13103e-5 14506e-5 15938e-5 \
    17405e-5 18915e-5 20475e-5 22111e-5 23847e-5 25724e-5 27802e-5 30160e-5 32906e-5 \
    36190e-5 40175e-5 40174e-5 36189e-5 32905e-5 30158e-5 27801e-5 25723e-5 23847e-5 \
    22111e-5 20477e-5 18916e-5 17407e-5 15942e-5 14510e-5 13108e-5 11731e-5 10378e-5 \
    9055e-5 7766e-5 6523e-5 5341e-5 4244e-5 3257e-5 2408e-5 1711e-5 1170e-5 771e-5 \
    490e-5 297e-5 169e-5 85e-5 33e-5 -2e-5 -24e-5 -38e-5 -47e-5 -51e-5 -55e-5 -58e-5 \
    -59e-5 -60e-5 -60e-5 1000e-4 0e-4 -1000e-4 -2000e-4 -3000e-4 -4000e-4 -5000e-4 \
    -6000e-4 -7000e-4 -8000e-4 -9000e-4 -10000e-4 -11000e-4 -1200e-3 -1300e-3 -1400e-3 \
    -1500e-3 -1600e-3 -1700e-3 -1800e-3 -1900e-3 -2000e-3 -2000e-3 -1900e-3 -1800e-3 \
    -1700e-3 -1600e-3 -1500e-3 -1400e-3 -1300e-3 -1200e-3 -11000e-4 -10000e-4 -9000e-4 \
    -8000e-4 -7000e-4 -6000e-4 -5000e-4 -4000e-4 -3000e-4 -2000e-4 -1000e-4 0e-4 1000e-4]

    set P(Ie)      [list\
    1000e-13 1585e-13 2512e-13 3981e-13 6310e-13 10000e-13 1585e-12 2512e-12 3981e-12 \
    6310e-12 10000e-12 1585e-11 2512e-11 3981e-11 6310e-11 10000e-11 1585e-10 2512e-10 \
    3981e-10 6310e-10 10000e-10 1585e-9 2512e-9 3981e-9 6310e-9 10000e-9 1585e-8 2512e-8 \
    3981e-8 6310e-8 10000e-8 1585e-7 2512e-7 3981e-7 6310e-7 10000e-7 1585e-6 2512e-6 \
    3981e-6 6310e-6 10000e-6 10000e-6 6310e-6 3981e-6 2512e-6 1585e-6 10000e-7 6310e-7 \
    3981e-7 2512e-7 1585e-7 10000e-8 6310e-8 3981e-8 2512e-8 1585e-8 10000e-9 6310e-9 \
    3981e-9 2512e-9 1585e-9 10000e-10 6310e-10 3981e-10 2512e-10 1585e-10 10000e-11 6310e-11 \
    3981e-11 2512e-11 1585e-11 10000e-12 6310e-12 3981e-12 2512e-12 1585e-12 10000e-13 6310e-13 \
    3981e-13 2512e-13 1585e-13 1000e-13 87839e-10 47129e-13 -33664e-11 -40910e-11 -46909e-11 \
    -52566e-11 -58027e-11 -63355e-11 -68632e-11 -73899e-11 -79206e-11 -84582e-11 -90087e-11 \
    -95762e-11 -10198e-10 -10814e-10 -11464e-10 -12158e-10 -12909e-10 -13734e-10 -14654e-10 \
    -15709e-10 -15916e-10 -15164e-10 -14372e-10 -13577e-10 -12803e-10 -12048e-10 -11325e-10 \
    -10633e-10 -9965e-10 -9254e-10 -86456e-11 -80691e-11 -75049e-11 -69520e-11 -63998e-11 \
    -58467e-11 -52824e-11 -47001e-11 -40838e-11 -33467e-11 46447e-13 87280e-10]
}


::asdex::graph_win .graphfit
frame .mainfit
pack .mainfit
::asdex::test_win .mainfit
::asdex::iniEssaiIV .mainfit
::aide::nondocumente .


# On cherche à placer les fenêtres dans un certain ordre.
# "tkwait visibility ." a l'air nécessaire et suffisant.
# Rajouter d'autres "tkwait visibility ..." a plutôt tendance à coincer
tkwait visibility .
raise .graphfit
raise .
update

puts stderr "A REVOIR"

if {$argc == 2} {
    set repertoire [lindex $argv 0]
    puts $repertoire
} else {
    source [file join [file dirname [info script]] litibic.tcl]
    set fichier [tk_getOpenFile \
	    -defaultextension spt \
	    -filetypes {{superTables {*.spt *.tar.gz *.tgz}}} \
	    -initialdir /home/asdex/ \
	    -title Supertables]
}

set repertoire [file dirname $fichier]
::asdex::creeListBox $repertoire .mainfit
