set Mes2Elem(dummy) {}
set Elem2Mes(dummy) {}

proc firstfree tab {
    upvar #0 $tab t
    set i 1
    while {[info exists t($i)]} { #; il faut les {}  autour de [] !!!
        incr i
    }
puts "firstfree=$i"
    return $i
}

set Couleur(0)  "white"
# 8 plumes HP
set Couleur(1)  "black"
set Couleur(2)  "red"
set Couleur(3)  "green"
set Couleur(4)  "blue"
set Couleur(5)  "yellow"
set Couleur(6)  "orange"
set Couleur(7)  "brown3"
set Couleur(8)  "orchid2"
# autres couleurs */
set Couleur(9)  "aquamarine"
set Couleur(10)  "navajowhite2"
set Couleur(11)  "deepskyblue1"
set Couleur(12)  "limegreen"
set Couleur(13)  "deeppink"
set Couleur(14)  "tomato"
set Couleur(15)  "darkorchid3"
set Couleur(16)  "gainsboro"
set Couleur(17)  "seagreen"
set Couleur(18)  "salmon"
set Couleur(19)  "darkturquoise"
set Couleur(20)  "khaki"
set Couleur(21)  "darkviolet"
set Couleur(22)  "firebrick2"
set Couleur(23)  "tan"
set Couleur(24)  "limegreen"
set Couleur(25)  "lightskyblue"
set Couleur(26)  "turquoise1"
set Couleur(27)  "violet"
set Couleur(28)  "dark orange"
set Couleur(29)  "yellow"
set Couleur(30)  "deepskyblue"
set Couleur(31)  "gray"
set Couleur(32)  "bisque1"
set Couleur(33)  "peru"
set Couleur(34)  "red1"
set Couleur(35)  "green"
set Couleur(36)  "chocolate"
set Couleur(37)  "sea green"
set Couleur(38)  "lemonchiffon"

proc icouleur {i} {
    global Couleur
    incr i
    if {[info exists Couleur($i)]} {
        return $Couleur($i)
    }
    return black
}

proc createVector {args} {
    foreach v $args {
        global $v
        if {![info exists $v]} {
            vector $v
        }
    }
}

set LASTMES -1
set REMPLACE 1
set DETRUIT 0

set HELP(plotfit) {
Appel     : plotfit tag index tab
Arguments :
    tag     : identifiant géographique de la mesure sur un dispo. ex L01C23
    index   : numéro de la mesure dans le fichier.
    tab     : adresse d'un tableau Asyst
globals   :
in :    dirData, Dispo, Mesure : Construction du répertoire
out:    Mes2Elem : tableau 
        Elem2Mes : 
        REMPLACE : indicateur
}
proc plotfit {tag index tab} {
puts "plotfit $tag $index $tab"
    global ASDEX
    global Mes2Elem Elem2Mes REMPLACE LASTMES
    if {$index != {}} {
        set index I$index
    }
    set coucou $ASDEX(dirData)/$ASDEX(Plaque)/$ASDEX(Dispo)/$ASDEX(Mesure)/${tag}${index}
puts $coucou
    if {![info exists Mes2Elem($coucou)]} {
        if {$REMPLACE && [info exists Elem2Mes($LASTMES)]} {
            set i $LASTMES
            unset Mes2Elem($Elem2Mes($i))
            set Elem2Mes($i) $coucou
            set Mes2Elem($coucou) $i
            global xVector$i yVector$i
            createVector xVector$i yVector$i
            a6plotdata xVector$i yVector$i $tab
        } else {
            set i [firstfree Elem2Mes]
            set Elem2Mes($i) $coucou
            set Mes2Elem($coucou) $i
            global xVector$i yVector$i
            createVector xVector$i yVector$i
            .g element create $i -linewidth 0 -symbol none \
                -color [icouleur $i] -xdata xVector$i -ydata yVector$i
            a6plotdata xVector$i yVector$i $tab  
            update ;# A VOIR, ne suffit pas à mettre à jour la légende
            set LASTMES $i
        }
    }
}

if {![winfo exists .gcontroles]} {
frame .gcontroles
pack .gcontroles -in .droite

set wc [frame .gcontroles.pointeur]
pack $wc -side left
radiobutton $wc.detruit -text detruit -variable DETRUIT -value 1 -command "SetDeleteOnLegend .g"
radiobutton $wc.off -text off -variable DETRUIT -value 0 -command "UnSetDeleteOnLegend .g"
pack $wc.detruit $wc.off -side left

set wc [frame .gcontroles.remplace]
pack $wc -side right
radiobutton $wc.remplace -text remplace -variable REMPLACE -value 1
radiobutton $wc.ajoute -text ajoute -variable REMPLACE -value 0
pack $wc.remplace $wc.ajoute -side left

}



# help ;# pour amorcer ?
nondocumente .

