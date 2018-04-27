package provide fidev_zinzout 1.0

package require opt

namespace eval ::fidev::zinzout {
}

set HELP(::fidev::zinzout::create) {
    API {
	$win une fenêtre existante (vierge) dans laquelle on crée un canvas et des boutons
	$displayWinProc
	$displayWinArgum Les arguments rajoutés à "$displayWinProc $win.c"
    }

    Internals {
	au travers de la variable globale "::fidev::zinzout::$win"

	displayWinProc
	displayWinArgum
	actionSelect
	echelle
	xCenterA
	yCenterA

	winId

	objwritten
	button1
	UnZoomFact

	xminP
	yminP
	xmaxP
	ymaxP

	xZoomIni
	yZoomIni
    }
}

::tcl::OptProc ::fidev::zinzout::create {
    {win "Nom de la fenêtre existante"}
    {displayWinProc}
    {displayWinArgum}
    {-actionSelect ::fidev::zinzout::noActionSelect "Que faire on select"}
    {-xCenter -float 0}
    {-yCenter -float 0}
    {-scale -float 1.0}
    {-width -integer 500}
    {-height -integer 500}
    } {
    foreach v [info locals] {
        puts stderr [format "%14s : %s" $v [set $v]]
    }
    upvar #0 ::fidev::zinzout::$win G

    set G(displayWinProc) $displayWinProc
    set G(displayWinArgum) $displayWinArgum
    set G(actionSelect) $actionSelect
    set G(echelle) $scale
    set G(xCenterA) $xCenter
    set G(yCenterA) $yCenter

    updateOrCreate $win -width $width -height $height
}


set HELP(::fidev::zinzout::winUpdate) {
    Intro {
        Il est utile d'appeler update de temps en temps pour permettre
        une interaction avec le milieu extérieur
    }

    API {
        Une fonction de trace dans le canvas::fidev::zinzout $c doit contenir typiquement
            upvar #0 [::fidev::zinzout::getObjwrittenVar $c] objwritten
            ...
            $c create ...
            incr objwritten
            if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $c]} {
                # arrêt de toute trace demandé
            }
    }
    
    Internals {            
        La variable $G(winId) permet de savoir si après l'update
        la fenêtre a été renouvelée,
        auquel cas on retourne 1 pour signifier d'arrêter le tracé
    }
}

proc ::fidev::zinzout::winUpdate {c} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set winId $G(winId)
    update
    if {$winId != $G(winId)} {
        puts {stop!!!}
        return 1
    }
    return 0
}

set HELP(::fidev::zinzout::create) {
    Intro {
        cree un canvas muni de boutons
    }
    
    API {
        $win nom de la fenêtre "toplevel" à créer
        
    }
}

proc ::fidev::zinzout::noActionSelect {win x y} {
    bell
}

proc ::fidev::zinzout::updateOrCreate {win args} {

    upvar #0 ::fidev::zinzout::$win G

    if {$win == "."} {
        set base {}
    } else {
        set base $win
    }
    set c $base.c
    set fb $base.fb

    if {[info exists G(winId)]} {
        incr G(winId)
    } else {
        set G(winId) 0
    }

    set G(objwritten) 0

    if {[winfo exists $c]} {
        $c delete all
    } else {
        eval [list canvas $c -borderwidth 0 -highlightthickness 5] $args
        frame $fb
        grid configure $c -sticky ewns
        grid configure $fb -sticky ewns
        grid columnconfigure $win 0 -weight 1
        grid rowconfigure $win 0 -weight 1   

        set G(button1) select
        set G(UnZoomFact) 1

        radiobutton $fb.s1 -text select -variable ::fidev::zinzout::$win\(button1) -value select
        radiobutton $fb.s2 -text zoom -variable ::fidev::zinzout::$win\(button1) -value zoom
        radiobutton $fb.s3 -text pan/z/uz -variable ::fidev::zinzout::$win\(button1) -value pan
        label $fb.l -text "facteur :"
        entry $fb.e -width 3 -textvariable ::fidev::zinzout::$win\(UnZoomFact)
        label $fb.echelle  -textvariable ::fidev::zinzout::$win\(echelle)
        button $fb.center -text recentre -command "::fidev::zinzout::recentre $c"
        button $fb.print -text imprime -command "::fidev::zinzout::print $c"

        grid configure $fb.s1 $fb.s2 $fb.echelle $fb.s3 $fb.l $fb.e $fb.center $fb.print

       # la dénomination des events est étrange
        bind $c <ButtonPress-1> {::fidev::zinzout::b1Press %W %x %y}
        bind $c <Button1-Motion> {::fidev::zinzout::b1Motion %W %x %y}
        bind $c <ButtonRelease-1> {::fidev::zinzout::b1Release %W %x %y}
        bindtags $win [concat [bindtags $win] rWM] ;# pour ne pas propager aux sous-widgets
    }
        

   # présupposés géométriques : echelle, xCenterA, yCenterA
   # $[x|y]m[in|ax]  : coord utilisateur, orienté y en haut
   # $[x|y]m[in|ax]P : coord pixel, orienté y en bas
   # entre les deux : $echelle uniquement
   # la translation est gérée par le canvas

    ::fidev::zinzout::getPhysicalSize $c dxP dyP
            
    set G(xminP) [expr {int(floor( $G(xCenterA)*$G(echelle) - 0.5*$dxP))}]
    set G(yminP) [expr {int(floor(-$G(yCenterA)*$G(echelle) - 0.5*$dyP))}]
    set G(xmaxP) [expr $G(xminP) + $dxP]
    set G(ymaxP) [expr $G(yminP) + $dyP]

puts [list scrollregion = $G(xminP) $G(yminP) $G(xmaxP) $G(ymaxP)]
    $c configure -scrollregion [list $G(xminP) $G(yminP) $G(xmaxP) $G(ymaxP)]

    # à mettre ici et non pas à la création de la fenêtre
    bind $c <Configure> {::fidev::zinzout::reconfigureWinCanvas %W %w %h %B}
    bind rWM <Configure> {::fidev::zinzout::reconfigureWinMaster %W %w %h %B}

    # création des axes couleur yellow
    # et appel de la fonction de trace
    $c create line -100000 0 100000 0 -fill yellow
    $c create line 0 -100000 0 100000 -fill yellow
    $G(displayWinProc) $c $G(displayWinArgum)

    return $c
}

proc ::fidev::zinzout::getObjwrittenVar {canvas} {
    return ::fidev::zinzout::[winfo parent $canvas]\(objwritten)
}

proc ::fidev::zinzout::getLimits {c} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set xmin [expr {$G(xminP)/$G(echelle)}]
    set ymin [expr {-$G(ymaxP)/$G(echelle)}]
    set xmax [expr {$G(xmaxP)/$G(echelle)}]
    set ymax [expr {-$G(yminP)/$G(echelle)}]
    return [list $xmin $ymin $xmax $ymax]
}

proc ::fidev::zinzout::getScale {canvas} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    return $G(echelle)
}

# retourne les largeurs et hauteur en intervalles et non en pixels (différence de 1)
proc ::fidev::zinzout::getPhysicalSize {c dxPName dyPName} {
    upvar $dxPName dxP
    upvar $dyPName dyP
   # ne convient pas : set dxP [$c cget -width] ; set dyP [$c cget -height]
   # seule façon sérieuse je crois :
    update ;# INDISPENSABLE pour que "winfo" donne des informations à jour
    set marge [expr {[$c cget -borderwidth] + [$c cget -highlightthickness]}]
    set dxP [expr {[winfo width  $c] - 2*$marge - 1}]
    set dyP [expr {[winfo height $c] - 2*$marge - 1}]
}

# On avait fait autrefois une tentative plus élaborée basée sur "winfo root[x|y]"
# Elle était utile en cas de toplevel pour garder immobile le dessin sur l'écran
proc ::fidev::zinzout::reconfigureWinMaster {c w h B} {
puts "$w $h $B"

}

proc ::fidev::zinzout::reconfigureWinCanvas {c w h B} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    ::fidev::zinzout::getPhysicalSize $c dxP dyP

# idem
#set marge [expr {[$c cget -borderwidth] + [$c cget -highlightthickness]}]
#set w [expr {$w - 2*$marge - 1}]
#set h [expr {$h - 2*$marge - 1}]
#puts "B = $B $w=$dxP $h=$dyP" 
    if {$dxP > $G(xmaxP) - $G(xminP) || $dyP > $G(ymaxP) - $G(yminP)} {
        set G(xCenterA) [expr $G(xCenterA) + 0.5*($dxP - ($G(xmaxP) - $G(xminP)))/$G(echelle)]
        set G(yCenterA) [expr $G(yCenterA) - 0.5*($dyP - ($G(ymaxP) - $G(yminP)))/$G(echelle)]
        ::fidev::::zinzout::updateOrCreate [winfo parent $c]
    } 
}

proc ::fidev::zinzout::zout {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G

    set G(xCenterA) [expr  [$c canvasx $x]/$G(echelle)]
    set G(yCenterA) [expr -[$c canvasy $y]/$G(echelle)]
puts "$x $y -> [$c canvasx $x] [$c canvasy $y] -> $G(xCenterA) $G(yCenterA)"

###### $$$$$ Noter que catch {expr {$G(UnZoomFact)}} fact
###### ne rale pas et renvoie dans tous les cas $G(UnZoomFact)
    if {[catch {expr "$G(UnZoomFact)"} fact]} {
        set fact 1
        set G(UnZoomFact) $fact
    } elseif {$fact > 10} {
        set fact 10.0
        set G(UnZoomFact) $fact
    } elseif {$fact < 0.1} {
        set fact 0.1
        set G(UnZoomFact) $fact
    }
    set G(echelle) [expr {$fact*$G(echelle)}]
    ::fidev::zinzout::updateOrCreate [winfo parent $c]
}

proc ::fidev::zinzout::recentre {c} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set G(xCenterA) 0.0
    set G(yCenterA) 0.0
    ::fidev::zinzout::updateOrCreate [winfo parent $c]
}

proc ::fidev::zinzout::print {c} {
    set p [$c postscript -pageheight 277m -pagewidth 190m]
#    set err [catch {exec lp << $p > out 2> err1} message]
    set err [catch {exec lp << $p 2>@stdout} message]
    if {$err} {
        tk_messageBox -title impression -message "$message"
    } else {
        puts stderr "impression OK"
    }
}

proc ::fidev::zinzout::beginZoom {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    set G(xZoomIni) $x
    set G(yZoomIni) $y
}

proc ::fidev::zinzout::winZoom {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    $c delete zoomrect
    $c create rectangle $G(xZoomIni) $G(yZoomIni) $x $y -tags zoomrect
}

proc ::fidev::zinzout::zoom {c} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    set bb [$c coords zoomrect] ;# les coords sont réarangées
    $c delete zoomrect
puts "bb = $bb"
    if {$bb == {}} {
        return
    }
    foreach {xminP yminP xmaxP ymaxP} $bb {}
    set dxP [expr $xmaxP - $xminP]
    set dyP [expr $ymaxP - $yminP]
    if {$dxP == 0 || $dyP == 0} {
        return
    }
    set xCentre [expr  0.5*($xminP + $xmaxP)/$G(echelle)] 
    set yCentre [expr -0.5*($yminP + $ymaxP)/$G(echelle)]
    set marge [expr {[$c cget -borderwidth] + [$c cget -highlightthickness]}]
    set xEch [expr $G(echelle) * double([winfo width $c] - 2*$marge) / $dxP]
    set yEch [expr $G(echelle) * double([winfo height $c] - 2*$marge) / $dyP]

    if {$xEch <= $yEch} {
        set echelle $xEch
    } else {
        set echelle $yEch
    }
    set G(xCenterA) $xCentre
    set G(yCenterA) $yCentre
    set G(echelle) $echelle
    ::fidev::zinzout::updateOrCreate [winfo parent $c]
}

proc ::fidev::zinzout::b1Press {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    switch $G(button1) {
        select "$G(actionSelect) $c $x $y"
        zoom " ::fidev::zinzout::beginZoom $c $x $y"
        pan " ::fidev::zinzout::zout $c $x $y"
    }
}

proc ::fidev::zinzout::b1Motion {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    switch $G(button1) {
        zoom " ::fidev::zinzout::winZoom $c $x $y"
    }
}
proc ::fidev::zinzout::b1Release {c x y} {
    upvar #0 ::fidev::zinzout::[winfo parent $c] G
    switch $G(button1) {
        zoom " ::fidev::zinzout::zoom $c"
    }
}


# ???
proc ::fidev::zinzout::see {c item} {
    set box [$c bbox $item]
    puts "$c $box"
    if {[string match {} $box]} return
    set scrollreg [$c cget -scrollreg]
    if {[string match {} $scrollreg]} {
        error "canvas_see : $c configure -scrollreg ... à faire"
    }
    foreach \
        {x y x1 y1} $box\
        {xvmin xvmax} [$c xview]\
        {yvmin yvmax} [$c yview]\
        {xmin ymin xmax ymax} $scrollreg\
    {
        if {$xvmax - $xvmin == 1.0} {
            $c xview moveto 0.0
        } else {
            set xv [expr double($x-$xmin)/double($xmax-$xmin)]
            set xv1 [expr double($x1-$xmin)/double($xmax-$xmin)]
            set xvb [expr 0.2*($xvmax-$xvmin)+$xvmin]
            set xvb1 [expr 0.8*($xvmax-$xvmin)+$xvmin]
            if {$xv < $xvb || $xv1 > $xvb1} {
                $c xview moveto [expr (0.5*($x1+$x)-$xmin)/($xmax-$xmin) - 0.5*($xvmax-$xvmin)]
            }
        }
        if {$yvmax - $yvmin == 1.0} {
            $c yview moveto 0.0
        } else {
            set yv [expr double($y-$ymin)/double($ymax-$ymin)]
            set yv1 [expr double($y1-$ymin)/double($ymax-$ymin)]
            set yvb [expr 0.2*($yvmax-$yvmin)+$yvmin]
            set yvb1 [expr 0.8*($yvmax-$yvmin)+$yvmin]
        
# puts "$c $y $ymin $ymax $ymin [expr ($y-$ymin)/($ymax-$ymin)] ([$c yview]) $yv < $yvb || $yv1 > $yvb1"
            if {$yv < $yvb || $yv1 > $yvb1} {
                $c yview moveto  [expr (0.5*($y1+$y)-$ymin)/($ymax-$ymin) - 0.5*($yvmax-$yvmin)]
            }
        }
    }
}
