package provide fidev_zinzout 1.2

set HELP(fidev_zinzout-1.2) {

}

set HISTORIQUE(fidev_zinzout-1.2) {
    2004-02-19 (FP) abandon du zoom manuel, restriction du zoom à un facteur 2^n
}


package require opt 0.4.2

namespace eval ::fidev::zinzout {
}

proc list_from_lines {lines} {
    set ret [list]
    foreach l [split $lines \n] {
	set l [string trim $l]
	if {$l != {}} {
	    lappend ret $l
	}
    }
    return $ret
}


proc proc+doc {name args help callers historique body} {
    global HELP USEDBY HISTORIQUE
    set HELP($name) $help
    set USEDBY($name) [list_from_lines $callers]
    set HISTORIQUE($name) [list_from_lines $historique]
    proc $name $args $body
}


##################
# procédures API #
##################


         ########################
set HELP(::fidev::zinzout::create) {
         ########################
    API {
	$win une fenêtre existante (vierge) dans laquelle on crée un canvas et des boutons
	$displayWinProc
	$displayWinArgum Les arguments rajoutés à "$displayWinProc $win.c"
    }

    Internals {
	au travers de la variable globale "::fidev::zinzout::$win", on a les éléments du tableau :

	displayWinProc      +create    -updateOrCreate
	displayWinArgum     +create    -updateOrCreate
	actionSelect        +create                                                                                -b1Press
	echelle             +create                    -getLimits -getScale -reconfigureWinCanvas +zout +zoom
	xCenterA            +create                                         +reconfigureWinCanvas +zout +zoom +recentre
	yCenterA            +create                                         +reconfigureWinCanvas +zout +zoom +recentre

	winId               -winUpdate +updateOrCreate

	objwritten                     +updateOrCreate                                                             
	button1                        +updateOrCreate                                                             -b1Press -b2Press -b3Press -b1Motion -b1Release
	ZoomFact                       +updateOrCreate                                            +zout 

	xminP                          +updateOrCreate -getLimits           -reconfigureWinCanvas
	yminP                          +updateOrCreate -getLimits           -reconfigureWinCanvas
	xmaxP                          +updateOrCreate -getLimits           -reconfigureWinCanvas
	ymaxP                          +updateOrCreate -getLimits           -reconfigureWinCanvas

	xZoomIni           +beginZoom -winZoom
	yZoomIni           +beginZoom -winzoom
    }
}

set USEDBY(::fidev::zinzout::create) {
    %extern% dxf/library/rdxf.tcl
    %extern% dxf/library/rdxf2.tcl
    %extern% masque/bin/jumbogood.tcl
    %extern% masque/bin/tbs2good.tcl
    %extern% masque/bin/tbs2measured.tcl
    %extern% tpg/library/tpg.0.3.tcl
    %extern% tpg/library/tpg.tcl
    %extern% tpg/tbs2/tpg.0.3.tcl
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

    ::fidev::zinzout::updateOrCreate $win -width $width -height $height
}


###########################################
proc+doc fidev::zinzout::winUpdate {canvas} {
###########################################
    Intro {
        Il est utile d'appeler update de temps en temps pour permettre
        une interaction avec le milieu extérieur
    }

    API {
        Une fonction de trace dans le canvas::fidev::zinzout $canvas doit contenir typiquement
            upvar #0 [::fidev::zinzout::getObjwrittenVar $canvas] objwritten
            ...
            $canvas create ...
            incr objwritten
            if {$objwritten % 10000 == 0 && [::fidev::zinzout::winUpdate $canvas]} {
                # arrêt de toute trace demandé
            }
    }
    
    Internals {            
        La variable $G(winId) permet de savoir si après l'update
        la fenêtre a été renouvelée,
        auquel cas on retourne 1 pour signifier d'arrêter le tracé
    }
} {
    %extern%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set winId $G(winId)
    puts stderr "update !"
    update
    if {$winId != $G(winId)} {
        puts "stop $winId -> $G(winId)"
        return 1
    }
    return 0
}

####################################################
proc+doc ::fidev::zinzout::getObjwrittenVar {canvas} {
####################################################
    Cf. ::fidev::zinzout::winUpdate
} {
    %extern%
} {
    2004-02-25 (FP) $c -> $canvas
    2004-02-27 (FP) suppression du \ devant (
} {
    return ::fidev::zinzout::[winfo parent $canvas](objwritten)
}


#################################
# accès aux paramètres internes #
#################################

#############################################
proc+doc ::fidev::zinzout::getLimits {canvas} {
#############################################
    retourne la liste des limites de la zone à tracer
} {
    %extern%
} {
    2004-02-25 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set xmin [expr {$G(xminP)/$G(echelle)}]
    set ymin [expr {-$G(ymaxP)/$G(echelle)}]
    set xmax [expr {$G(xmaxP)/$G(echelle)}]
    set ymax [expr {-$G(yminP)/$G(echelle)}]
    return [list $xmin $ymin $xmax $ymax]
}


############################################
proc+doc ::fidev::zinzout::getScale {canvas} {
############################################
    retourne l'échelle
} {
    %extern%
} {
    2004-02-25 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    return $G(echelle)
}


##################################################################
proc+doc ::fidev::zinzout::getPhysicalSize {canvas dxPName dyPName} {
##################################################################
    retourne les largeurs et hauteur en intervalles et non en pixels (différence de 1)
} {
    ::fidev::zinzout::updateOrCreate
    ::fidev::zinzout::reconfigureWinCanvas
} {
    2004-02-25 (FP) $c -> $canvas
} {
    upvar $dxPName dxP
    upvar $dyPName dyP
    update ;# INDISPENSABLE pour que "winfo" donne des informations à jour
   # ne convient pas : set dxP [$canvas cget -width] ; set dyP [$canvas cget -height]
   # deux façons sérieuses je crois :

    if {0} {
	set marge [expr {[$canvas cget -borderwidth] + [$canvas cget -highlightthickness]}]
	set dxP [expr {[winfo width  $canvas] - 2*$marge - 1}]
	set dyP [expr {[winfo height $canvas] - 2*$marge - 1}]
    } else {
	
    }
    



}



###################
# noyau principal #
###################

####################################################
proc+doc ::fidev::zinzout::updateOrCreate {win args} {
####################################################
} {
    ::fidev::zinzout::create
    ::fidev::zinzout::reconfigureWinCanvas
    ::fidev::zinzout::zout
    ::fidev::zinzout::recentre
    ::fidev::zinzout::zoom
} {
    2004-02-26 (FP)
    2004-02-27 (FP) suppression du zoom manuel pour imposer le facteur 2^n ; améliorations diverses
} {

    upvar #0 ::fidev::zinzout::$win G

puts $win
    if {$win == "."} {
        set base {}
    } else {
        set base $win
    }
    set canvas $base.c
    set fb $base.fb

    if {[info exists G(winId)]} {
        incr G(winId)
    } else {
        set G(winId) 0
    }


    if {[winfo exists $canvas]} {
        $canvas delete all
    } else {
        eval [list canvas $canvas -borderwidth 0 -highlightthickness 5] $args
        frame $fb
        grid configure $canvas -sticky ewns
        grid configure $fb -sticky ewns
        grid columnconfigure $win 0 -weight 1
        grid rowconfigure $win 0 -weight 1   

        set G(button1) pan
        set G(ZoomFact) 2
	set G(ZoomPos) c

        radiobutton $fb.s1 -text select -variable ::fidev::zinzout::${win}(button1) -value select
	# radiobutton $fb.s2 -text zoom -variable ::fidev::zinzout::${win}(button1) -value zoom
	radiobutton $fb.s3 -text z/pan/uz -variable ::fidev::zinzout::${win}(button1) -value pan
	label $fb.l -text "facteur :"
        radiobutton $fb.zf1 -variable ::fidev::zinzout::${win}(ZoomFact) -value 2 -text 2
        radiobutton $fb.zf2 -variable ::fidev::zinzout::${win}(ZoomFact) -value 4 -text 4
	radiobutton $fb.zf3 -variable ::fidev::zinzout::${win}(ZoomFact) -value 8 -text 8

	frame $fb.nc ;# neuf cases
        radiobutton $fb.nc.nw -variable ::fidev::zinzout::${win}(ZoomPos) -value nw
        radiobutton $fb.nc.n  -variable ::fidev::zinzout::${win}(ZoomPos) -value n
        radiobutton $fb.nc.ne -variable ::fidev::zinzout::${win}(ZoomPos) -value ne
        radiobutton $fb.nc.w  -variable ::fidev::zinzout::${win}(ZoomPos) -value w
        radiobutton $fb.nc.c  -variable ::fidev::zinzout::${win}(ZoomPos) -value c
        radiobutton $fb.nc.e  -variable ::fidev::zinzout::${win}(ZoomPos) -value e
        radiobutton $fb.nc.sw -variable ::fidev::zinzout::${win}(ZoomPos) -value sw
	radiobutton $fb.nc.s  -variable ::fidev::zinzout::${win}(ZoomPos) -value s
        radiobutton $fb.nc.se -variable ::fidev::zinzout::${win}(ZoomPos) -value se
	grid configure $fb.nc.nw $fb.nc.n $fb.nc.ne
	grid configure $fb.nc.w  $fb.nc.c $fb.nc.e
	grid configure $fb.nc.sw $fb.nc.s $fb.nc.se

      # entry $fb.e -width 3 -textvariable ::fidev::zinzout::${win}(ZoomFact)
        label $fb.echelle  -textvariable ::fidev::zinzout::${win}(echelle)
        button $fb.center -text recentre -command "::fidev::zinzout::recentre $canvas"
        button $fb.print -text imprime -command "::fidev::zinzout::print $canvas"

        grid configure $fb.s1 $fb.s3 $fb.l $fb.echelle $fb.zf1 $fb.zf2 $fb.zf3 $fb.nc $fb.center $fb.print

       # la dénomination des events est étrange
        bind $canvas <ButtonPress-1> {::fidev::zinzout::b1Press %W %x %y}
        bind $canvas <ButtonPress-2> {::fidev::zinzout::b2Press %W %x %y}
        bind $canvas <ButtonPress-3> {::fidev::zinzout::b3Press %W %x %y}
        bind $canvas <Button1-Motion> {::fidev::zinzout::b1Motion %W %x %y}
        bind $canvas <ButtonRelease-1> {::fidev::zinzout::b1Release %W %x %y}
        bindtags $win [concat [bindtags $win] rWM] ;# pour ne pas propager aux sous-widgets
    }
        

   # présupposés géométriques : echelle, xCenterA, yCenterA
   # $[x|y]m[in|ax]  : coord utilisateur, orienté y en haut
   # $[x|y]m[in|ax]P : coord pixel, orienté y en bas
   # entre les deux : $echelle uniquement
   # la translation est gérée par le canvas

    ::fidev::zinzout::getPhysicalSize $canvas dxP dyP
            
    set G(xminP) [expr {int(floor( $G(xCenterA)*$G(echelle) - 0.5*$dxP))}]
    set G(yminP) [expr {int(floor(-$G(yCenterA)*$G(echelle) - 0.5*$dyP))}]
    set G(xmaxP) [expr $G(xminP) + $dxP]
    set G(ymaxP) [expr $G(yminP) + $dyP]

# puts [list scrollregion = $G(xminP) $G(yminP) $G(xmaxP) $G(ymaxP)]
    $canvas configure -scrollregion [list $G(xminP) $G(yminP) $G(xmaxP) $G(ymaxP)]

    # à mettre ici et non pas à la création de la fenêtre
    bind $canvas <Configure> {::fidev::zinzout::reconfigureWinCanvas %W %w %h %B}
    bind rWM <Configure> {::fidev::zinzout::reconfigureWinMaster %W %w %h %B}

    # création des axes couleur yellow
    # et appel de la fonction de trace
    $canvas create line -100000 0 100000 0 -fill yellow
    $canvas create line 0 -100000 0 100000 -fill yellow

    # il faut mettre ce flag à 0 juste avant l'appel de $G(displayWinProc)
    set G(objwritten) 0

    $G(displayWinProc) $canvas $G(displayWinArgum)

    return $canvas
}


##############################################################
proc+doc ::fidev::zinzout::reconfigureWinMaster {canvas w h B} {
##############################################################
    On avait fait autrefois une tentative plus élaborée basée sur "winfo root[x|y]"
    Elle était utile en cas de toplevel pour garder immobile le dessin sur l'écran
} {
    %bind%
} {
    2004-02-26 (FP)
} {
    # puts "reconfigureWinMaster $w $h $B"
}


##############################################################
proc+doc ::fidev::zinzout::reconfigureWinCanvas {canvas w h B} {
##############################################################
} {
    %bind%
} {
    2004-02-26 (FP)
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    ::fidev::zinzout::getPhysicalSize $canvas dxP dyP

    # idem
    #set marge [expr {[$canvas cget -borderwidth] + [$canvas cget -highlightthickness]}]
    #set w [expr {$w - 2*$marge - 1}]
    #set h [expr {$h - 2*$marge - 1}]
    #puts "B = $B $w=$dxP $h=$dyP" 
    if {$dxP > $G(xmaxP) - $G(xminP) || $dyP > $G(ymaxP) - $G(yminP)} {
        set G(xCenterA) [expr $G(xCenterA) + 0.5*($dxP - ($G(xmaxP) - $G(xminP)))/$G(echelle)]
        set G(yCenterA) [expr $G(yCenterA) - 0.5*($dyP - ($G(ymaxP) - $G(yminP)))/$G(echelle)]
        ::fidev::::zinzout::updateOrCreate [winfo parent $canvas]
    } 
}


#########################################
# procédures de changement de géométrie #
#########################################


#################################################
proc+doc ::fidev::zinzout::zout {canvas oper x y} {
#################################################
} {
    ::fidev::zinzout::b1Press
    ::fidev::zinzout::b2Press
    ::fidev::zinzout::b3Press
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G

    set G(xCenterA) [expr  [$canvas canvasx $x]/$G(echelle)]
    set G(yCenterA) [expr -[$canvas canvasy $y]/$G(echelle)]
# puts "$x $y -> [$canvas canvasx $x] [$canvas canvasy $y] -> $G(xCenterA) $G(yCenterA)"

###### $$$$$ Noter que catch {expr {$G(ZoomFact)}} fact
###### ne rale pas et renvoie dans tous les cas $G(ZoomFact)
    if {[catch {expr "$G(ZoomFact)"} fact] || $G(ZoomFact) <= 1.0} {
        set G(ZoomFact) 2
    }
    switch $oper {
        pan {}
        zoom {
            set G(echelle) [expr {$G(ZoomFact)*$G(echelle)}]
        }
        unzoom {
            set G(echelle) [expr {$G(echelle)/$G(ZoomFact)}]
        }
    }
    ::fidev::zinzout::updateOrCreate [winfo parent $canvas]
}


########################################
proc+doc ::fidev::zinzout::zoom {canvas} {
########################################
} {
    ::fidev::zinzout::b1Release
} {
    2004-02-26 (FP) $c -> $canvas    
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set bb [$canvas coords zoomrect] ;# les coords sont réarangées
    $canvas delete zoomrect
# puts "bb = $bb"
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
    set marge [expr {[$canvas cget -borderwidth] + [$canvas cget -highlightthickness]}]
    set xEch [expr $G(echelle) * double([winfo width $canvas] - 2*$marge) / $dxP]
    set yEch [expr $G(echelle) * double([winfo height $canvas] - 2*$marge) / $dyP]

    if {$xEch <= $yEch} {
        set echelle $xEch
    } else {
        set echelle $yEch
    }
    set G(xCenterA) $xCentre
    set G(yCenterA) $yCentre
    set G(echelle) $echelle
    ::fidev::zinzout::updateOrCreate [winfo parent $canvas]
}


############################################
proc+doc ::fidev::zinzout::recentre {canvas} {
############################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set G(xCenterA) 0.0
    set G(yCenterA) 0.0
    ::fidev::zinzout::updateOrCreate [winfo parent $canvas]
}


##########################################################
# auxilliaires pour la construction du rectangle de zoom #
##########################################################


#################################################
proc+doc ::fidev::zinzout::beginZoom {canvas x y} {
#################################################
} {
    ::fidev::zinzout::b1Press
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set x [$canvas canvasx $x]
    set y [$canvas canvasy $y]
    set G(xZoomIni) $x
    set G(yZoomIni) $y
}


###############################################
proc+doc ::fidev::zinzout::winZoom {canvas x y} {
###############################################
} {
    ::fidev::zinzout::b1Motion
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    set x [$canvas canvasx $x]
    set y [$canvas canvasy $y]
    $canvas delete zoomrect
    $canvas create rectangle $G(xZoomIni) $G(yZoomIni) $x $y -tags zoomrect
}


########################
# gestion de la souris #
########################

###################################################
proc+doc ::fidev::zinzout::noActionSelect {win x y} {
###################################################
} {
} {
    2004-02-26 (FP) $c -> $canvas
} {
    bell
}


###############################################
proc+doc ::fidev::zinzout::b1Press {canvas x y} {
###############################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    switch $G(button1) {
        select "$G(actionSelect) $canvas $x $y"
        zoom " ::fidev::zinzout::beginZoom $canvas $x $y"
        pan " ::fidev::zinzout::zout $canvas zoom $x $y"
    }
}


###############################################
proc+doc ::fidev::zinzout::b2Press {canvas x y} {
###############################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    switch $G(button1) {
        pan " ::fidev::zinzout::zout $canvas pan $x $y"
    }
}


###############################################
proc+doc ::fidev::zinzout::b3Press {canvas x y} {
###############################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    switch $G(button1) {
        pan " ::fidev::zinzout::zout $canvas unzoom $x $y"
    }
}


################################################
proc+doc ::fidev::zinzout::b1Motion {canvas x y} {
################################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    switch $G(button1) {
        zoom " ::fidev::zinzout::winZoom $canvas $x $y"
    }
}


################################################
proc+doc ::fidev::zinzout::b1Release {canvas x y} {
################################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    switch $G(button1) {
        zoom " ::fidev::zinzout::zoom $canvas"
    }
}


##############
# impression #
##############


#########################################
proc+doc ::fidev::zinzout::print {canvas} {
#########################################
} {
    %bind%
} {
    2004-02-26 (FP) $c -> $canvas
} {
    set p [$canvas postscript -pageheight 277m -pagewidth 190m]
#    set err [catch {exec lp << $p > out 2> err1} message]
    set err [catch {exec lp << $p 2>@stdout} message]
    if {$err} {
        tk_messageBox -title impression -message "$message"
    } else {
        puts stderr "impression OK"
    }
}



#########################
#                       #
#########################

############################################
proc+doc ::fidev::zinzout::see {canvas item} {
############################################
    procédure pas finalisée
} {
} {
    2004-02-26 (FP) $c -> $canvas
} {
    set box [$canvas bbox $item]
    puts "$canvas $box"
    if {[string match {} $box]} return
    set scrollreg [$canvas cget -scrollreg]
    if {[string match {} $scrollreg]} {
        error "canvas_see : $canvas configure -scrollreg ... à faire"
    }
    foreach \
        {x y x1 y1} $box\
        {xvmin xvmax} [$canvas xview]\
        {yvmin yvmax} [$canvas yview]\
        {xmin ymin xmax ymax} $scrollreg\
    {
        if {$xvmax - $xvmin == 1.0} {
            $canvas xview moveto 0.0
        } else {
            set xv [expr double($x-$xmin)/double($xmax-$xmin)]
            set xv1 [expr double($x1-$xmin)/double($xmax-$xmin)]
            set xvb [expr 0.2*($xvmax-$xvmin)+$xvmin]
            set xvb1 [expr 0.8*($xvmax-$xvmin)+$xvmin]
            if {$xv < $xvb || $xv1 > $xvb1} {
                $canvas xview moveto [expr (0.5*($x1+$x)-$xmin)/($xmax-$xmin) - 0.5*($xvmax-$xvmin)]
            }
        }
        if {$yvmax - $yvmin == 1.0} {
            $canvas yview moveto 0.0
        } else {
            set yv [expr double($y-$ymin)/double($ymax-$ymin)]
            set yv1 [expr double($y1-$ymin)/double($ymax-$ymin)]
            set yvb [expr 0.2*($yvmax-$yvmin)+$yvmin]
            set yvb1 [expr 0.8*($yvmax-$yvmin)+$yvmin]
        
# puts "$canvas $y $ymin $ymax $ymin [expr ($y-$ymin)/($ymax-$ymin)] ([$canvas yview]) $yv < $yvb || $yv1 > $yvb1"
            if {$yv < $yvb || $yv1 > $yvb1} {
                $canvas yview moveto  [expr (0.5*($y1+$y)-$ymin)/($ymax-$ymin) - 0.5*($yvmax-$yvmin)]
            }
        }
    }
}

