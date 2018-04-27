# Les déclinaisons latines

# 2 juin 2000 (FP)
# 5 juin 2000 (FP) correction de nombreux bogues, ajout de boutons.

set genres {nominatif vocatif accusatif genitif datif ablatif}
# substantifs
set DesinencesS(rosa)      {a  a   am  ae  ae a ae ae  as  arum  is   is}
set DesinencesS(dominus)   {us e   um  i   o  o  i  i  os  orum  is   is}
set DesinencesS(puer)      {{} {}  um  i   o  o  i  i  os  orum  is   is}
set DesinencesS(ager)      {er er rum ri  ro ro ri ri ros rorum ris  ris}
set DesinencesS(templum)   {um um  um  i   o  o  a  a  a   orum  is   is}
set DesinencesS(consul)    {{} {}  em  is  i  e  es es es    um ibus ibus}
set DesinencesS(corpus)    {us us  us  is  i  e  a  a  a     um ibus ibus}
set DesinencesS(civis)     {is is  em  is  i  e  es es es   ium ibus ibus}
set DesinencesS(mare)      {e  e   e   is  i  i  ia ia ia   ium ibus ibus}
set DesinencesS(cornu)     {u  u   u   us  ui u  ua ua ua   uum ibus ibus}
set DesinencesS(manus)     {us us  um  us  ui u  us us us   uum ibus ibus}
set DesinencesS(domus)     {us us  um  us  ui o  us us {us, os} {uum, orum} ibus ibus}
set DesinencesS(dies)      {es es  em  ei  ei e  es es es  erum ebus ebus}

# adjectifs
set DesinencesA(bonus)   {us e   um  i   o  o  i  i  os  orum  is  is}
set DesinencesA(bona)    {a  a   am  ae  ae a  ae ae is  arum  is   is}
set DesinencesA(bonum)   {um um  um  i   o  o  a  a  a   orum  is   is}
set DesinencesA(vetusM)  {us us  em  is  i  e  es es es    um ibus ibus}
set DesinencesA(vetusF)  {us us  em  is  i  e  es es es    um ibus ibus}
set DesinencesA(vetusN)  {us us  em  is  i  e  a  a  a     um ibus ibus}
set DesinencesA(fortisM) {is is  em  is  i  i  es es es   ium ibus ibus}
set DesinencesA(fortisF) {is is  em  is  i  i  es es es   ium ibus ibus}
set DesinencesA(forteN)   {e  e   e   is  i  i  ia ia ia   ium ibus ibus}
set DesinencesA(prudensM) {s tis tem tis ti {i, e} tes tes tium tibus tibus}
set DesinencesA(prudensF) {s tis tem tis ti {i, e} tes tes tium tibus tibus}
set DesinencesA(prudensN) {s ta  ta  tis ti i  tia tia tium tibus tibus}


# initialisation du tableau "NG" des suffixes nominatif et génitif
catch {unset NG}
foreach d [array names DesinencesS] {
    set nomgen [lindex $DesinencesS($d) 0],[lindex $DesinencesS($d) 3]
    if {[info exists NG($nomgen)]} {
        puts stderr "DANGER, ambiguité $NG($nomgen)-$d"
    }
    lappend NG($nomgen) $d
}

# affichage classé du contenu du tableau

parray NG

# initialisation des déclinaisons connues

foreach s [array names DesinencesS] {
    set Declinaison($s) $s
}


set HELP(racine) {
  - procédure d'extraction de racine
  - exemple: racine sara a -> a
  - On utilise "regexp", qui est très puissant, mais compliqué.
    Cet outil est standardisé en dehors de Tcl.
    Prenons un suffixe du nominatif valant "um" par exemples,
    on cherche dans "$nominatif" une chaine qui ressemble à "^(.*)um$"
    Le ^ veut dire qu'il faut que ça colle dès le début.
    Le $ veut dire qu'il faut que ça colle jusqu'à la fin.
    Parce que la chaine est mise entre "" à cause de ${suffixe},
    il faut écrire "\$" à la place de "$" pour que Tcl transmette
    le dollar à la machine regexp.
    La chaine "." veut dire "un caractère quelconque"
    La chaine ".*" veut dire "un nombre quelconque de caractères quelconques"
    Elle est mise entre parenthèses () pour que cet ensemble de
    caractères quelconques soit mis dans la variable dont le nom est ici "racine"
    La variable "tout" n'est pas utilisée ici.
}

proc racine {nominatif suffixe} {
    if {![regexp "^(.*)${suffixe}\$" $nominatif tout racine]} {
        return -code error "incompatibilité \"racine $nominatif $suffixe\""
    }
    return $racine
}


set HELP(declineConnu) {
    exemple: declineConnu sara rosa -> sara sara saram sarae sarae sara sarae sarae saras sararum saris saris
    Extrait la racine du modèle et construit la liste en ajoutant les suffixes
}

proc declineConnu {nominatif modele} {
    global DesinencesS
    set suffixes $DesinencesS($modele)
    set racine [racine $nominatif [lindex $suffixes 0]]
    set tout [list]
    foreach s $suffixes {
        lappend tout "${racine}${s}"
    }
    return $tout
}

set HELP(modele) {
    exemple: modele sara sarae -> rosa
    Le nominatif et le génitif étant connus, tente de retrouver le modèle
}
proc modele {nominatif genitif} {
    global NG
    set similitudes [list]
    foreach ng [array names NG] {
        set ngs [split $ng ","]
        if {[regexp "^(.*)[lindex $ngs 0]\$" $nominatif tout racine]} {
            if {[string compare $genitif $racine[lindex $ngs 1]] == 0} {
                # on utilise concat et non lappend parce que $NG($ng)
                # peut contenir plusieurs modeles
                set similitudes [concat $similitudes $NG($ng)]
            }
        }
    }
    if {[llength $similitudes] == 1} {
        return $similitudes
    } elseif {[llength $similitudes] == 0} {
        return -code error "déclinaison inconnue: $nominatif, $genitif"
    } else {
        return -code error\
        "ambiguités: \"modele $nominatif $genitif\" -> \"$similitudes\""
    }
}

set HELP(apprend) {
    apprentissage, appelé automatiquement par "decline"
}

proc apprend {nominatif genitif} {
    global Declinaison
    set Declinaison($nominatif) [modele $nominatif $genitif]
}


set HELP(decline) {
    # exemple: decline rosa -> rosa rosa rosam rosae rosae rosa rosae rosae rosas rosarum rosis rosis
    #          decline sara -> ajouter l'argument génitif
    #          decline sara sarae -> sara sara saram sarae sarae sara sarae sarae saras sararum saris saris
    #          decline sara  -> sara sara saram sarae sarae sara sarae sarae saras sararum saris saris
    # Il a appris "sara"
}

proc decline {nominatif args} {
    global Declinaison

    # s'il y a 2 arguments, le second est le génitif
    if {[llength $args] == 1} {
        apprend $nominatif $args
    } elseif {[llength $args] == 2} {
        set Declinaison($nominatif) [lindex $args 1]
    } elseif {[llength $args] == 0} {
        if {![info exists Declinaison($nominatif)]} {
            return -code error "ajouter l'argument génitif et éventuellement le modèle"
        }
    } else {
        return -code error "trop d'arguments"
    }
    set declinaison [declineConnu $nominatif $Declinaison($nominatif)]
    # Un petit controle paranoiaque
    if {[llength $args] > 0} {
        if {[lindex $args 0] != [lindex $declinaison 3]} {
            return -code error "conflit entre \"[lindex $args 0]\" et \"$declinaison\""
        }
    }
    return $declinaison
}

##############
# sauvegarde #
##############

set HELP(litFichDecl) {
    Lecture d'un fichier des déclinaisons
    Ce fichier est normalement créé par "ecritFichDecl ..."
}

proc litFichDecl {fichier} {
    set f [open $fichier r]
    set lignes [read -nonewline $f]
    close $f
    set lignes [split $lignes \n]
    set il 0
    foreach l $lignes {
        incr il
        # On nettoye les blancs du début ou de la fin pour simplifier l'analyse
        set l [string trim $l]
        # on saute les lignes vides ou celles qui démarrent pas un "#"
        if {$l == {} || [string index $l 0] == "#"} {
            continue
        }
        # On appelle "decline $l", où $l est le contenu d'une ligne
        # Pour éclater $l en argument, on appelle "eval decline $l"
        # Pour qu'une erreur dans le fichier n'interrompe pas le programme,
        # on appelle "catch {eval decline $l}"
        # On rajoute un argument pour qu'il reçoive le message d'erreur
        # et on récupère la valeur retournée pas "catch"
        set erreur [catch {eval decline $l} message]
        if {$erreur} {
            puts stderr "Erreur ligne $il: \"$message\""
        }
    }
}

set HELP(ecritFichDecl) {
    sauvegarde des déclinaisons apprises
}

proc ecritFichDecl {fichier} {
    global Declinaison
    
    set connus [array names Declinaison]
    # tri alphabetique
    set connus [lsort $connus]
    # construction du contenu des lignes
    # pour mise en forme avant impression
    set lignes [list]
    foreach mot $connus {
        set declinaison [decline $mot]
        lappend lignes [list [lindex $declinaison 0] [lindex $declinaison 3] $Declinaison($mot)]
    }
    # mise en forme
    # On aurait pu intégrer cela à la boucle ci-dessus
    # Cette construction est plus modulaire, et pourrait se construire sous forme
    # de procédure standard
    set w0 0
    set w1 0
    foreach l $lignes {
        if {[string length [lindex $l 0]] > $w0} {
            set w0 [string length [lindex $l 0]]
        }
        if {[string length [lindex $l 1]] > $w1} {
            set w1 [string length [lindex $l 1]]
        }
    }
    # 
    set f [open $fichier w]
    foreach l $lignes {
        # la commande "format" reprend la syntaxe "fprintf" du langage C.
        puts $f [format "%-${w0}s %-${w1}s %s" [lindex $l 0] [lindex $l 1] [lindex $l 2]]
    }
    close $f
    puts "Sauvegarde faite dans $fichier"
}

# construction du nom de fichier des déclinaisons

set repertoire [file dirname [info script]]
if {[file pathtype $repertoire] == "relative"} {
    set repertoire [file join [pwd] $repertoire]
}
set fichDecl [file join $repertoire LesDeclinaisons.dat]

# lecture automatique du fichier s'il existe.

if {[file exists $fichDecl]} {
    puts "lecture du fichier $fichDecl"
    litFichDecl $fichDecl
}

puts "penser à sauver en tapant \"ecritFichDecl $fichDecl\""

# à faire:
# - une procédure plus intelligente, qui n'a pas besoin du génitif quand
# il n'y a pas d'ambiguité
# - les adjectifs

proc declineIt {entry} {
    global singulier pluriel blablaModele Declinaison
    set entree [$entry get]
    set declinaison [eval decline $entree]
    puts $declinaison
    set singulier [join [lrange $declinaison 0 5] \n]
    set pluriel [join [lrange $declinaison 6 11] \n]
    set blablaModele "Modele: $Declinaison([lindex $entree 0])"
}

# destruction de ce qu'il y a dans la fenêtre
# utile lorsque l'on modifie interactivement le programme
foreach e [winfo children .] {
    destroy $e
}

label .m -textvariable blablaModele -relief groove
pack .m -side top

frame .f
pack .f -side bottom -fill x
button .f.s -text Sauve -command {ecritFichDecl $fichDecl}
button .f.l -text Charge -command {litFichDecl $fichDecl}
pack .f.s .f.l -side left
button .f.d -text Decline -command {declineIt .e}
pack .f.d -side right

entry .e -width 30
pack .e -side bottom
# pas besoin d'appuyer sur "decline", il suffit de taper "Return"
bind .e <KeyPress-Return> {declineIt .e}

label .l -height 6 -text [join $genres \n] -justify right
pack .l -side left

label .ls -height 6 -textvariable singulier -justify left
label .lp -height 6 -textvariable pluriel -justify left
pack .lp .ls -side right

