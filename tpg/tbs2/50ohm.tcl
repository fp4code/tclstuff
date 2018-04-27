set rien {
INCLUDE struct
INCLUDE geom

: Fmicrons S>F ;
: microns 10 * ;
: unites 10E F* F>I ;
: pt>i unites unites SWAP ;


MARKER DetruiT
}


set gamma 2.125                       ;# coeff. géom. d'impédance
set l50/2 40.                         ;# demi-largeur interne

set gl50/2 [expr {$gamma * ${l50/2}
set af 0.                              ;# angle final
# axe: axeExt-final   gl50/2   af   axeExt-final axe!

set di 0.
set ai -0.25                           ;# demi-tours angle initial
# axe: axeExt-initial   di   ai axeExt-initial axe!

set yc [expr {160 - 40}]               ;# ordonnee du centre de courbure
set al 0.5
# axe: axe-limite         yc al      axe-limite axe!

\ rc=di-xc cos(ai)- yc cos(ai)
\ xc = gl50/2 - rc

set rc [expr {($di - ${gl50/2}*cospi($ai) - $yc*sinpi($ai))/(1.-cospi($ai))}]
set xc [expr {${gl50/2} - $rc}]

set centreDeCourbure [::geom2D::pt $xc $yc]
set cercleExterieur [$centreDeCourbure $rc]

proc axeExtFromAngle {angle} {
   global cercleExterieur
   return [::geom2D::axeTangentFromCercle+Angle $cercleExterieur $angle]
;

set rien {
axe: axeExt
axe: axeInt
axe: axeExtSuivant
axe: axeIntSuivant
pt: foyer
pt: ptExt
pt: ptInt
}

set origine ::geom2D::pt 0.0 0.0
set 50ohme [Chemin::new 0.0 0.0]
set 50ohmi [Chemin::new 0.0 0.0]

proc calculePointExterieur {} {
    global axeExt axeExtSuivant ptExt
    set ptExt [::geom2D::intersection $axeExt $axeExtSuivant]
}

proc calculePointInterieur {} {
    global axeInt axeIntSuivant ptInt
    set ptInt [::geom2D::intersection $axeInt $axeIntSuivant]
} 

proc calculeFoyer {} {
    global Oy axeExtSuivant foyer
    set foyer ::geom2D::intersection $Oy $axeExtSuivant]
}

proc calculeAxeExterieurSuivant {angle} {
    global axeExtSuivant
    set axeExtSuivant [axeExtFromAngle $angle]
}

proc calculeAxeInterieurSuivant {} {
    global foyer axeExtSuivant gamma
    ::geom2D::axeGet d a $axeExtSuivant
    set a [expr {$a/$gamma}]
    set axeIntSuivant [::geom2D::axe $d $a]
    
proc copieAxeInterieur {} {
   global axeIntSuivant axeInt
   set axeInt $axeIntSuivant
}
: copieAxeExterieur ( -- )
   global axeExtSuivant axeExt
   set axeExt $axeExtSuivant
}

proc 50ohm {} {
    global axeExt axeInt ptExt ptInt origine
    set axeExt [::geom2D::axe ${gl50/2} 0.]
    set axeInt [::geom2D::axe ${l50/2} 0.]
    for {set i 1} {$i < 10} {incr i} {
        calculeAxeExterieurSuivant [expr {$i*(-5./180.)}]
        calculePointExterieur
        calculeFoyer
        calculeAxeInterieurSuivant
        calculePointInterieur
        copieAxeExterieur
        copieAxeInterieur
        calculePointExterieur
        ::geom2D::ptGet x y $ptExt
        Chemin::appendPoint 50ohme E $x $y
        ::geom2D::ptGet x y $ptInt
        Chemin::appendPoint 50ohmi E $x $y
    }
    ::geom2D::ptGet x y $origine
    Chemin::appendPoint 50ohme E $x $y
    Chemin::appendPoint 50ohmi E $x $y
}

50ohm


