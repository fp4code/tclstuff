package provide tkSuperTable 1.8
# 2006-03-21 (FP) passage de -nogood en -trie $char

package require superTable 1.5
package require Tktable 2.7
package require superWidgetsListbox 1.2
package require superWidgetsScroll 1.0

set TMPDIR ~/tmp

namespace eval tkSuperTable {
    variable SUPERTABLES
    set HELP(SUPERTABLES) {
        SUPERTABLES contient beaucoup de choses :
            workingDir
            destroyLastSptWin
            lastSptWinId
            date          $fichier
            debuts        $fichier
            lignes        $fichier
            nomsDesTables $fichier
            dirAndFich $winId
            hold       $winId
            spt        $winId
            winId $dirAndFich $spt
            
            workingDir
                répertoire de travail (chemin complet)
            
            destroyLastSptWin
                0 (on conserve la dernière fenêtre table)
                1 (on détruit la dernière fenêtre table)
            
            lastSptWinId
                index $winId permettant de distinguer les fenêtres (.sptwin#$winId)
            
            date $fichier
                date du fichier lors de la précédente lecture de la table
                permet à "insertInLoader" de gérer la relecture des fichiers modifiés entre temps
                
            lignes        $fichier
            debuts        $fichier
            nomsDesTables $fichier
                directement issu de l'API superTable
                "insertInLoader" lit les fichiers,
                                 stocke les lignes
                                 et les analyse pour marquer les superTables.
            
            dirAndFich $winId
            spt        $winId
                nom complet du fichier et de la superTable
                associés à la fenêtre numéro $winId
            hold       $winId
                indique que la fenêtre numéro $winId doit être conservée

            winId $dirAndFich $spt
                numéro de la fenêtre associée à la supertable $spt
                du fichier $dirAndFich
    }
    

    set HELP(procs) {

        sptLoader $w
            crée une superListbox de niveau 3
            permettant le choix de visualisation des superTables

        insertInLoaderFichier {w}
        insertInLoaderRepertoire {w}
        insertInLoader {w dirAndFich}
        interactiveGetFile {}
            commandes permettant de remplir la superListbox

        tkSuperTable::voitSpt $win $repertoire $fichier $spt
            commande appele par sélection dans la superListbox,
            ouvrant une fenêtre style tableur
            interface avec "createSptWin"

        createSptWin $show $dirAndFich $spt
        destroySptWin $win
        holdSptWin $win
            commandes gérant les fenêtres style tableur 
        
        tkSuperTable::tableEtCurseurs $w
        tkSuperTable::ajouteTables $win $winId $sptArrayName $TkTableArrayName $tables
            appelées par "createSptWin"
        
        getColIndex {win colname}
        ajouteColonne {win colname}
        tkSuperTable::toutesLignes {win}
        verifOptR {win}
            essais de manipulation des tableurs
    }
    variable ArreteTout 0 ;  # brutal mais commode. À revoir
}
    
###############################################################################

# fenêtre loader

proc tkSuperTable::sptLoader {w} {
    if {$w == "."} {
        set w {}
    }
    frame $w.f
    pack $w.f -expand 1 -fill both
    set l [widgets::listbox $w.f]

    # C'est là que l'on déclare la procédure appelée lors de la sélection d'une supertable

    widgets::listboxSetType3 $l [list tkSuperTable::voitSpt %W]
    
    button $w.b  -text load     -command [list tkSuperTable::insertInLoaderFichier $l]
    button $w.bf -text loadFull -command [list tkSuperTable::insertInLoaderN $l]
    entry $w.ecb -width 16
    menubutton $w.choix\
        -menu $w.choix.menu \
        -indicatoron 1\
        -relief raised\
        -text "callback :"
  # postcommand est une précommande !!
  # %W ne marche pas
    menu $w.choix.menu -postcommand [list tkSuperTable::creeMenuCallbacks $w $w.choix.menu]
    button $w.stop -text stop -command "set tkSuperTable::ArreteTout 1"
#    button $w.good -text good -command [list tkSuperTable::good $w.f.list]
    set checkbuttonShowTable 1
    checkbutton $w.showTable -text "show next tables" -variable checkbuttonShowTable

    pack $w.b $w.bf $w.stop -side left
    pack $w.ecb $w.choix -side right

    pack $w.showTable -fill y -expand y
}

proc tkSuperTable::good {win repertoire fichier spt} {
    puts "win = $win"
    set twin $win.good
    if {![winfo exists $twin]} {
	toplevel $twin
	text $twin.txt
	button $twin.save -text save -command "::widgets::saveIt $twin.txt $repertoire good.spt {{{table des bons} good*.spt}}"
	pack  $twin.save -fill x -expand y -side bottom
	::widgets::packWithScrollbar $twin txt
	$twin.txt insert end "@@table des bons\n"
	$twin.txt insert end "@repertoire fichier table\n"
    }
    $twin.txt insert end "[list $repertoire $fichier $spt]\n"
    $twin.txt see end
}

proc tkSuperTable::trie {char win repertoire fichier spt} {
    set twin $win.tri_$char
    puts "$win $twin"
    if {![winfo exists $twin]} {
	toplevel $twin
	text $twin.txt
	button $twin.save -text save -command "::widgets::saveIt $twin.txt $repertoire tri_$char.spt {{{tables de tri} tri*.spt}}"
	pack  $twin.save -fill x -expand y -side bottom
	::widgets::packWithScrollbar $twin txt
	$twin.txt insert end "@@table de tri $char\n"
	$twin.txt insert end "@repertoire fichier table\n"
    }
    $twin.txt insert end "[list $repertoire $fichier $spt]\n"
    $twin.txt see end
}

proc tkSuperTable::creeMenuCallbacks {base menu} {
    global tkSuperTable::callbacks::CALLBACKS
    $menu delete 0 end
    foreach t [array names tkSuperTable::callbacks::CALLBACKS]  {
        $menu add command -label $t -command [list tkSuperTable::changeEntry $base.ecb tkSuperTable::callbacks::$t]
    }
}

proc tkSuperTable::changeEntry {entry value} {
    $entry delete 0 end
    $entry insert 0 $value
    $entry xview end
}

###############################################################################

proc tkSuperTable::insertInLoaderFichier {w} {
    set dirAndFich [interactiveGetFile1]
    if {$dirAndFich == {}} {
        return
    }
    insertInLoader $w $dirAndFich [file dirname $dirAndFich]
}
    
proc tkSuperTable::insertInLoaderN {w} {
    set dirAndFich [interactiveGetFileN]
    if {$dirAndFich == {}} {
        return
    }
    if {[regexp {^(.*)\.(tar\.gz|tgz)} $dirAndFich tgz repertoire]} {
        tkSuperTable::insertInLoaderTgz $w $tgz $repertoire
    } else {
        set repertoire [file dirname $dirAndFich]
        tkSuperTable::insertInLoaderRepertoire $w $repertoire $repertoire
    }
}

proc tkSuperTable::insertInLoaderRepertoire {w repertoire name} {
    variable ArreteTout
    set erreurs [list]
    foreach dirAndFich [lsort -command ::superTable::compareNameOfSpt [glob $repertoire/*.spt]] {
        if {$ArreteTout} {
            set ArreteTout 0
            update ;# indispensable sinon coince de temps en temps
            error "Arrêt demandé"
        }
        if {[catch {insertInLoader $w $dirAndFich $name} erreur]} {
            lappend erreurs $erreur
        }
        update
    }
    if {$erreurs != {}} {
        error "Erreurs : $erreurs"
    }
}

proc tkSuperTable::insertInLoaderTgz {w tgz repertoire} {
    global TMPDIR
    if {$repertoire == {}} {
        return
    }
    set repertoireTmp $TMPDIR/[file tail $repertoire]
    puts $repertoireTmp
    if {[file exists $repertoireTmp]} {
        error "$repertoireTmp existe déjà, on se refuse d'y créer des fichiers"
    }
    set ici [pwd]
    cd  $TMPDIR
    exec zcat $tgz | tar xvf -
    cd $ici
    insertInLoaderRepertoire $w $repertoireTmp $tgz
    file delete -force $repertoireTmp
}


# Il faudrait éviter de retrier si l'on est sûr d'insérer à la fin

proc tkSuperTable::insertInLoader {w dirAndFich name} {
    variable SUPERTABLES
    
    set dateFile [file mtime $dirAndFich]
    if {![info exists SUPERTABLES(date,$dirAndFich)] || ($SUPERTABLES(date,$dirAndFich) < $dateFile)} {
        set SUPERTABLES(date,$dirAndFich) $dateFile
        set SUPERTABLES(lignes,$dirAndFich) [superTable::getLines $dirAndFich]
        set SUPERTABLES(debuts,$dirAndFich) \
            [superTable::marqueTables $SUPERTABLES(lignes,$dirAndFich)]
        set SUPERTABLES(nomsDesTables,$dirAndFich) \
            [superTable::nomsDesTables \
                 $SUPERTABLES(lignes,$dirAndFich) $SUPERTABLES(debuts,$dirAndFich)]
    }

#    set repertoire [file dirname $dirAndFich]
    set repertoire $name
    set fichier [file tail $dirAndFich]

    set lRep [$w tag ranges level1]
    set comp 2
    foreach {lr0 lr1} $lRep {
        set comp [string compare $repertoire [$w get $lr0 $lr1]]
        if {$comp <= 0} {
            break
        }
    }
  # comparaison : 2 si on a affaire au premier repertoire
  #               0 si le répertoire a été chargé. Le nom se trouve dans la zone $lr0 et $lr1
  #               -1 si le répertoire doit être mis en $lr0
  #               +1 si le répertoire doit être mis à la fin après tous les autres
    if {$comp > 0} {
        if {$comp != 2} {
            $w insert end \n
        }
        $w see end
        $w insert end $repertoire level1
        $w see end
        $w insert end \n
        $w insert end "    "
        $w insert end $fichier level2
        set first 1
        foreach t $SUPERTABLES(nomsDesTables,$dirAndFich) {
            if {$first} {
                set first 0
                $w see end
            }
            $w insert end \n
            $w insert end "        "
            $w insert end $t level3
        }        
    } elseif {$comp < 0} {
        set pos [expr {int($lr0)}]
        $w see $pos.0
        $w insert $pos.0 \n
        $w insert $pos.0 $repertoire level1
        incr pos
        $w see $pos.0
        $w insert $pos.0 \n
        $w insert $pos.0 "    "
        $w insert "$pos.0 lineend" $fichier level2
        incr pos
        set first 1
        foreach t $SUPERTABLES(nomsDesTables,$dirAndFich) {
            if {$first} {
                set first 0
                $w see $pos.0
            }
            $w insert $pos.0 \n
            $w insert $pos.0 "        "
            $w insert "$pos.0 lineend" $t level3
            incr pos
        }        
    } else {
        $w see $lr0
        set lf [$w index "$lr0 + 1 lines"]
      # lf correspond à un début de ligne
      # susceptible de recevoir le nom de fichier et la liste des superTables
        set lrNext [$w tag nextrange level1 $lf]
        if {$lrNext == {}} {
            set lrNext [$w index end]
        } else {
            set lrNext [lindex $lrNext 0]
        }
      # $lrNext est l'index de la prochaine ligne répertoire, ou de la fin de texte
        set comp 1
        while {$lf < $lrNext} {
            set range [$w tag nextrange level2 $lf]
            if {$range == {}} {
              # plus de level2 -> insertion à la fin, à l'index $lrNext
                set lf $lrNext
                break
            }
            foreach {lf0 lf1} $range {}
            if {$lf0 > $lrNext} {
                set lf $lrNext
                break
            }
            set comp [::superTable::compareNameOfSpt $fichier [$w get $lf0 $lf1]]
            if {$comp > 0} {
              # à partir de la ligne suivante
                set lf [$w index "$lf0 + 1 lines"]
            } elseif {$comp < 0} {
              # plus petit : stop
                set lf $lf0
                break
            } else {
                error "fichier $fichier déjà chargé"
            }
        }
        set pos [expr {int($lf)}]
        $w see $pos.0
        $w insert $pos.0 \n
        $w insert $pos.0 "    "
        $w insert "$pos.0 lineend" $fichier level2
        incr pos
        set first 1
        foreach t $SUPERTABLES(nomsDesTables,$dirAndFich) {
            if {$first} {
                $w see $pos.0
                set first 0
            }
            $w insert "$pos.0" \n
            $w insert $pos.0 "        "
            $w insert "$pos.0 lineend" $t level3
            incr pos
        }        
    }
}

proc tkSuperTable::interactiveGetFile1 {} {
    variable SUPERTABLES
    if {![info exists SUPERTABLES(workingDir)]} {
        set SUPERTABLES(workingDir) /home/asdex
    }
    set fichier [tk_getOpenFile \
                     -defaultextension spt \
                     -filetypes {{superTable *.spt}} \
                     -initialdir $SUPERTABLES(workingDir) \
                     -title Supertables]
    if {$fichier != {}} {
        set SUPERTABLES(workingDir) [file dirname $fichier]
    }
    return $fichier
}

proc tkSuperTable::interactiveGetFileN {} {
    variable SUPERTABLES
    if {![info exists SUPERTABLES(workingDir)]} {
        set SUPERTABLES(workingDir) /home/asdex
    }
    set fichier [tk_getOpenFile \
                     -defaultextension spt \
                     -filetypes {{superTables {*.spt *.tar.gz *.tgz}}} \
                     -initialdir $SUPERTABLES(workingDir) \
                     -title Supertables]
    if {$fichier != {}} {
        set SUPERTABLES(workingDir) [file dirname $fichier]
    }
    return $fichier
}

###############################################################################

  # commande appelée par la sélection dans la superListbox

proc tkSuperTable::voitSpt {win args} {
    global checkbuttonShowTable

    puts stderr [list entrée dans tkSuperTable::voitSpt $win $args]

    #

    set argc [llength $args]
    foreach {repertoire fichier spt} [lrange $args [expr {$argc - 3}] end] {}    
    if {$argc >= 4} {
	set gonogo [lindex $args 0]
	if {$gonogo == "-good"} {
	    tkSuperTable::good $win $repertoire $fichier $spt
	} elseif {$gonogo == "-trie"} {
	    tkSuperTable::trie [lindex $args 1] $win $repertoire $fichier $spt
	} else {
	    error "argument \"$gonogo\" ni \"-good\" ni \"-trie $char\""
	}
	return
    }
    puts stderr createSptWin
    set tkTable [createSptWin $checkbuttonShowTable $repertoire/$fichier $spt]
    puts stderr [list createSptWin $repertoire/$fichier $spt a renvoyé $tkTable]
#    if {!$checkbuttonShowTable} {
#	wm iconify [winfo parent [winfo parent $tkTable]]
#    }

    set grandpapa [winfo parent $win]
    set grandpapa [winfo parent $grandpapa]
    if {$grandpapa == "."} {
        set grandpapa {}
    }
    set callback [$grandpapa.ecb get]
puts [list $grandpapa.ecb get -> $callback]
    if {$callback != {}} {
puts [list callback : $callback $tkTable]
        $callback $tkTable
    } 
  # ne fonctionne qu'avec tkwait
    focus $win
}

###############################################################################

proc tkSuperTable::createSptWin {show dirAndFich spt} {

    variable SUPERTABLES

    # S'il existe déjà une fenêtre pour la supertable donnée du fichier donné,
    #  on la montre et on retourne directement le nom de la tkTable

    set winIdElem [list winId $dirAndFich $spt]
    if {[info exists SUPERTABLES($winIdElem)]} {
	set win .sptwin#$SUPERTABLES($winIdElem)
	raise $win
	return $win.f.t
    }
    

    if {[info exists SUPERTABLES(lastSptWinId)]} {

	# S'il existe déjà une fenêtre affichant une autre supertable

	if {$SUPERTABLES(destroyLastSptWin)} {

	    # S'il est prévu de la détruire

	    set lastWin .sptwin#$SUPERTABLES(lastSptWinId)
	    if {[winfo exists $lastWin]} {
		set lastGeom [wm geometry $lastWin]
		destroy $lastWin
	    }
	} else {

	    # S'il n'est pas prévu de la détruire

	    # pas méchant si la fenêtre n'existe plus
	    incr SUPERTABLES(lastSptWinId)
	}
    } else {

	# Si c'est la première fenêtre affichant une supertable

	set SUPERTABLES(lastSptWinId) 0
    }
    
    # Création de la fenêtre "toplevel .sptwin#unEntier" d'affichage de la supertable

    set winId $SUPERTABLES(lastSptWinId)
    set win [toplevel .sptwin#$winId -takefocus 0]
    wm title $win "superTable #$winId"
    if {!$show} {
	wm iconify $win
    }
    if {[info exists lastGeom]} {
	wm geometry $win [string range $lastGeom [string first + $lastGeom] end]
    }
    bind $win <Destroy> {tkSuperTable::destroySptWin %W}

    # le titre

    label $win.titre -text $spt -relief sunken
    pack $win.titre
        
    # entregistrement de divers liens de travail

    set SUPERTABLES([list winId $dirAndFich $spt]) $winId
    set SUPERTABLES(dirAndFich,$win) $dirAndFich
    set SUPERTABLES(spt,$win) $spt

    upvar #0 SUPERTABLE#$winId sptArray
    if {[info exists sptArray]} {
	error "SUPERTABLE#$winId existe"
    }
    
    upvar #0 TkTableArray#$winId tkTableArray
    if {[info exists tkTableArray]} {
	error "TkTableArray#$winId existe"
    }

    set inutile {
	set sptArray(dummysptArray) {}
	set tkTableArray(dummytableau) {}
    }

    # Création d'un "frame" .f contenant une tkTable .f.t

    tkSuperTable::tableEtCurseurs $win.f
    pack $win.f -expand 1 -fill both

    # Système permettant de conserver constamment affichée la ou les colonnes de gauche
    
    set SUPERTABLES(numberOfIndexColumns) 0
    button $win.noicPlus -text  "+" -command "tkSuperTable::changeNumberOfIndexColumns $win 1"
    button $win.noicMinus -text "-" -command "tkSuperTable::changeNumberOfIndexColumns $win -1"
    pack $win.noicMinus $win.noicPlus -side left

    # Système d'invalidation de lignes
    button $win.valide -text  "valide" -command "tkSuperTable::valinval $win 1"
    button $win.invalide -text "invalide" -command "tkSuperTable::valinval $win 0"
    pack $win.invalide $win.valide -side left
    $win.f.t tag configure "inval" -background #c88

    # a priori on ne conservera pas cette fenêtre lorsqu'on ouvrira une autre fenêtre
    # Mais on crée un bouton pour changer ce choix

    set SUPERTABLES(destroyLastSptWin) 1
    checkbutton $win.hold \
	    -text hold \
	    -variable tkSuperTable::SUPERTABLES(hold,$win) \
	    -command "tkSuperTable::holdSptWin $win"
    pack $win.hold
    
    
    $win.f.t configure -cursor watch
    # a revoir, pour focus
    if {$show} {
	catch {
	    tkwait visibility $win
	}
    }

    # Le nom approximatif de la supertable est $spt
    # Le nom réel sera $name
    
    set name $spt
    set range [superTable::linesOfTable \
	    $SUPERTABLES(lignes,$dirAndFich) \
	    $SUPERTABLES(debuts,$dirAndFich) \
	    name]
    
    set indexes [superTable::readTable \
	    $SUPERTABLES(lignes,$dirAndFich) \
	    $range sptArray {}]
    foreach {lindex ccom cncom} $indexes {}
    set tables [superTable::regroupeColonnes sptArray $lindex $ccom $cncom]
    
    # remplissage de la tkTable .f.t
    
    tkSuperTable::ajouteTables $win.f.t $winId sptArray TkTableArray#$winId $tables
    
    $win.f.t configure -cursor {}

    # On retourne la tkTable
    return $win.f.t
}

proc tkSuperTable::destroySptWin {win} {
    variable SUPERTABLES
    # puts "INFO PROGRAMMEUR : revoir bind, bindtags... dans destroySptWin"
    if {![info exists SUPERTABLES(dirAndFich,$win)]} {
	return
    }
    set dirAndFich $SUPERTABLES(dirAndFich,$win)
    set spt $SUPERTABLES(spt,$win)
    unset SUPERTABLES(dirAndFich,$win)
    set winIdElem [list winId $dirAndFich $spt]
    set winId $SUPERTABLES($winIdElem)
    unset SUPERTABLES($winIdElem)
    upvar #0 SUPERTABLE#$winId superTable
    upvar #0 TkTableArray#$winId tkTableArray
# revoir les pbs de destruction anticipée de fenêtre
    catch {unset superTable}
    catch {unset tkTableArray}
}

proc tkSuperTable::holdSptWin {win} {
    variable SUPERTABLES
    if {$SUPERTABLES(hold,$win) == 1} {
	set SUPERTABLES(destroyLastSptWin) 0
    } else {
	destroy $win
    }
}
    
###############################################################################

proc tkSuperTable::changeNumberOfIndexColumns {win incr} {
    variable SUPERTABLES
    incr SUPERTABLES(numberOfIndexColumns) $incr
    set colmin 0
    set colmax [expr {[$win.f.t cget -cols] - 1}]
    if {$SUPERTABLES(numberOfIndexColumns) < $colmin} {
	set SUPERTABLES(numberOfIndexColumns) $colmin
    }
    if {$SUPERTABLES(numberOfIndexColumns) > $colmax} {
	set SUPERTABLES(numberOfIndexColumns) $colmax
    }
    $win.f.t configure -titlecols [expr {$SUPERTABLES(numberOfIndexColumns) + 1}]
}

###############################################################################


proc tkSuperTable::valinval {win valinval} {
    if {$valinval} {
        set tag {}
    } else {
        set tag inval
    }
    set cells [$win.f.t curselection]
    foreach cell $cells {
        set row [lindex [split $cell ,] 0]
        set BADS($row) {}
    }
    set rows [lsort [array names BADS]]
    foreach row $rows {
        $win.f.t tag row $tag $row
    }
}

###############################################################################

# Construction d'un "frame" contenant une tkTable et ses curseurs

proc tkSuperTable::tableEtCurseurs {win} {

    # $win est un "frame"

    frame $win

    # création de la tkTable

    table $win.t \
	-yscrollcommand "$win.sy set"\
	-xscrollcommand "$win.sx set"

    # copié-collé X

    $win.t configure -selectmode extended
    $win.t configure -colseparator "\t"
    $win.t configure -rowseparator "\n"

    # création des scrollbars

    scrollbar $win.sx -orient h -command "$win.t xview"
    scrollbar $win.sy -orient v -command "$win.t yview"

    # mise en place

    grid $win.t $win.sy -sticky nsew
    grid $win.sx -sticky ew
    grid columnconfig $win 0 -weight 1
    grid rowconfig $win 0 -weight 1

    # on retourne le "frame" qui contient le tout

    return $win
}

# Connexion de la tkTable avec des données

proc tkSuperTable::ajouteTables {tkTable winId sptArrayName tkTableArrayName tables} {
    variable SUPERTABLES

    upvar $sptArrayName sptArray
    upvar #0 $tkTableArrayName tkTableArray

# puts [list ajouteTables $tkTable $winId $sptArrayName $tables]
# strange : -variable nom ou varName (pb avec upvar) ?
# reponse : il faut le nom global de la variable globale

    $tkTable configure \
	-variable $tkTableArrayName \
	-colorigin -1 \
	-roworigin -1 \
	-titlecols [expr {$SUPERTABLES(numberOfIndexColumns) + 1}] \
	-titlerows 1
      # ligne et colonne -1 servent aux titres
      # la table proprement dite commence en 0
    set icoMax -1
      # indice de la colonne existante la plus à droite
    set iliPrec -1
      # indice de la dernière ligne de la table précédente
    foreach table $tables {
	foreach {colonnesDeTable lignesDeTable} $table {}
	set ico -1
	set ili $iliPrec
	set larMax($ico) 0
	foreach li $lignesDeTable {
	    incr ili
	    set case $li
	    set tkTableArray($ili,$ico) $case
	    set larCase [string length $case]
	    if {$larCase > $larMax($ico)} {
		set larMax($ico) $larCase
	    }
	}
	  # les titres de ligne sont remplis
	foreach co $colonnesDeTable {
	    if {![info exists colIndex($co)]} {
		incr icoMax
		set ico $icoMax
		set ili -1
		set colIndex($co) $ico
		set case $co
		set tkTableArray($ili,$ico) $case
		set larCase [string length $case]
		set larMax($ico) $larCase
		  # le titre de colonn est rempli
	    } else {
		set ico $colIndex($co)
	    }
	    set ili $iliPrec
	      # $ico est l'indice de colonne en cours
	    foreach li $lignesDeTable {
		incr ili
		set case $sptArray([list $li $co])
		set tkTableArray($ili,$ico) $case
		set larCase [string length $case]
		if {$larCase > $larMax($ico)} {
		    set larMax($ico) $larCase
		}
	    }
	}
	set iliPrec $ili
    }
    $tkTable configure \
	-cols [expr {$icoMax + 2}] \
	-rows [expr {$iliPrec + 2}]
    for {set ico -1} {$ico <= $icoMax} {incr ico} {
	$tkTable width $ico [expr {$larMax($ico) + 1}]
	# puts [list $ico [expr {$larMax($ico) + 1}] [$tkTable width $ico]]
    }
}
    
###############################################################################
set HELP(tkSuperTable::getColIndex) {
    retourne le numero de la colonne $colname
}

proc tkSuperTable::getColIndex {tkTable colname} {

    # méthode rustique
    # Il faudrait trouver autre chose

    set colonnes [tkSuperTable::toutesColonnes $tkTable]
    set ico 0
    foreach colonne $colonnes {
	if {$colonne == $colname} {
	    return $ico
	} else {
	    incr ico
	}
    }
    return {}
}

proc tkSuperTable::ajouteColonne {tkTable colname} {
    upvar #0 [$tkTable cget -variable] tkTableArray
    set ico [getColIndex $tkTable $colname]
    if {$ico != {}} {
	error "La colonne $colname existe déjà (colonne $ico)"
    }
    $tkTable insert cols end 1
    set ico [expr {[$tkTable cget -cols] - 2}]
    set tkTableArray(-1,$ico) $colname
}

proc tkSuperTable::toutesLignes {tkTable} {
    set nli [expr {[$tkTable cget -rows] - 1}]
    set lignes [list]
    for {set ili 0} {$ili < $nli} {incr ili} {
	lappend lignes $ili
    }
    return $lignes
}

proc tkSuperTable::toutesLignesValides {tkTable} {
    set toutes [tkSuperTable::toutesLignes $tkTable]
    set invalides [$tkTable tag row inval]

    # calcul de la différence
    foreach l $invalides {
        set INVAL($l) {}
    }

    set lignes [list]
    foreach l $toutes {
        if {![info exists INVAL($l)]} {
            lappend lignes $l
        }
    }
    return $lignes
}

proc tkSuperTable::toutesColonnes {tkTable} {
    upvar #0 [$tkTable cget -variable] tkTableArray
    set nco [expr {[$tkTable cget -cols] - 1}]
    set colonnes [list]
    for {set ico 0} {$ico < $nco} {incr ico} {
	lappend colonnes $tkTableArray(-1,$ico)
    }
    return $colonnes
}

############################################################################
# géré en packages

namespace eval tkSuperTable::callbacks {
}
