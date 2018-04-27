# (C) CNRS/L2M Groupe de Physique des Composants 1995-1997

package provide superTable 1.5
package require opt
package require listUtils
namespace eval superTable {}

################################################################################

set Changes(superTable) {
    1.5 : le paramètre $globNameOfTableName
    des procédures
    linesOfTable fileToTable fileToFile
    devient un nom de variable
    nameOfTable

    ajout de getCell
}

################################################################################

set Help(superTable) {

  INTRO
    
    Le goupe de physique de composants du L2M/CNRS a introduit
      la notion de superTable
      dans le but de stocker
      de façon simple, souple et surtout lisible
      des données de tous types.

  VOCABULAIRE

    Ensemble : éléments 2 à 2 distincts regroupés de manière non ordonnée.
    
    Suite : éléments regroupés de manière ordonnée.
    
    Paire : suite de 2 éléments.

  NOTION DE SUPERTABLE
    
    Une table est une paire formée de :
        - une ligne d'index de colonnes
        - un ensemble de lignes

    Chaque ligne de la table a autant de colonnes
      que la ligne d'index de colonnes

    Une superTable est une paire formée de :
        - un nom
        - un ensemble de tables.

  FICHIER DE SUPERTABLES
  
    Un fichier de superTables version 1997/05 est une suite de lignes.
    
    Il peut contenir plusieurs superTables et des commentaires.
    
    La longueur des lignes est quelconque.

    Chaque ligne se termine
      par le délimiteur de fin ligne classique (\n sous Unix).

    Une ligne commençant par le caractère # est
      une ligne de commentaire.
    
    Une ligne ne contenant que des blancs ou tabulations est également
      une ligne de commentaires.

    La suppression ou l'ajout d'une ligne de commentaire
      n'a aucune conséquence sur les superTables.

    Chaque superTable correspond à une suite de lignes contiguës,
      éventuellement entrecoupées de commentaires.
      
    La première ligne d'une superTable commence habituellement par @@.
    
    Les caractères qui suivent @@ sur la ligne sont
      le nom de la superTable.

    Si cette ligne ne figure pas,
      le fichier ne contient qu'une superTable, sans nom.
      
    Après cette ligne figurent une suite de tables et de lignes de commentaires.

    Une table est une suite de lignes contiguës.
    
    La première ligne d'une table est la ligne des noms de colonnes.
    
    La ligne des index de colonnes commence par @
      et se poursuit par une suite de noms de colonnes,
      séparés par des blancs ou des tabulations.

    Un nom de colonnes peut comporter des blancs, si il est entièrement
    encadré d'accolades.

    Toutes les lignes suivant la ligne des noms de colonnes
      sont des lignes de données si elles ne commencent ni par @ ni par #
      et si elles ne contiennet pas uniquement des blancs ou des tabulations.

    Les données formant une ligne de données sont séparées par
      un ou plusieurs blancs ou tabulations.

    Le nombre de blancs est quelconque avant le premier élément
      ainsi qu'après le dernier élément,
      et au moins égal à un entre deux éléments.

    Un élément peut être entouré d'accolades,
      cela est obligatoire s'il comporte des blancs ;
      cela est aussi conseillé s'il comporte des caractères spéciaux
      tels que les accolades.
# NON Pour des complément de syntaxe, on se rapportera à la commande
# Tcl [eval list $ligne]

    Une ligne commençant par @ mais pas par @@ indique un début de table.

    La fin d'une table est définie
      par la première ligne de la table suivante
      ou par la première ligne de la superTable suivante
      ou par la fin de fichier.

  SUPERTABLES INDEXABLES
A ECRIRE, J'AI MIS DU CHAOS ICI
    Chaque ligne est éventuellement indexable
      par la liste des valeurs des cases correspondant
      sur cette ligne
      à une liste fixe de noms de colonnes.

       partageant éventuellement une même liste d'index.

    Les colonnes permettant d'indexer les lignes sont nécessairement
      communes à toutes les tables d'une superTable.
    
    Il n'y a pas d'autre contrainte.

    Le fichier ne contient
      aucune information spécifiant
      une liste ou plusieurs listes possible des colonnes d'index.
        
    Lors de la transformation d'une superTable en array Tcl,
      la liste de colonnes d'index doit permettre
une indexation non ambiguë.

  PROCEDURES TCL

    Une superTable correspond à un tableau.
    
    tableau([list $li $co]) contient la valeur de la colonne de nom $co
    sur la ligne indexée par $li.
    
    Dans le cas d'une table non indexée,
    $li est un entier sans signification particulière.
    
    Dans le cas d'une table indexée, $li est la liste des valeurs des
    colonnes servant d'index. Dans ce cas,
      $tableau([list [list $vc1 $vc2 ... $vcn] $c1]) vaut $vc1,
      $tableau([list [list $vc1 $vc2 ... $vcn] $c2]) vaut $vc2, etc.
}

################################################################################

set Help(superTable::getLines) {
Lit un fichier formés de lignes et retourne la liste des lignes.
Chaque ligne est débarassée de son séparateur de fin de ligne.
}

proc superTable::getLines {fichier} {
    set fifi [open $fichier r]
    set lignes [read -nonewline $fifi]
    set lignes [split $lignes "\n"]
    close $fifi
    return $lignes
}

################################################################################

set Help(superTable::marqueTables) {
Retourne la liste des indices des éléments de la liste $lignes commençant par @@
}

proc superTable::marqueTables {lignes} {
    set marques {}
    set i 0
    foreach l $lignes {
        if {[string match @@* $l]} {
            lappend marques $i
        }
        incr i
    }
    return $marques
}

################################################################################

set Help(superTable::nomsDesTables) {
    retourne la liste des noms des tables de la liste de lignes $lignes,
    repérées par la liste $tlimit
}

proc superTable::nomsDesTables {lignes tlimit} {
    set noms [list]
    foreach tl $tlimit {
        set ligne [lindex $lignes $tl]
        set nom [string range $ligne 2 end]
        lappend noms $nom
    }
    return $noms
}

################################################################################

set Help(superTable::linesOfTable) {

  INTRO {
  
    extrait les lignes correspondant à une superTable

  }

  ARGUMENTS {

    $lignes : liste des lignes d'un fichier de superTables
    
    $tlimit : liste des index de lignes des lignes "@@..."
      L'indexation débute à 0.
      Typiquement résultat de [superTable::marqueTables $lignes]
      
    $nameOfTable : nom de supertable, sans le style "string match $nameOfTable ..."
   
  }

  RETOUR {
  
    Renvoie normalement une liste de deux éléments, identifiant la
      première et la dernière ligne de la superTable.

    La ligne "@@..." n'est pas considérée comme faisant partie de la superTable.

    Si la table ne contient qu'une superTable sans nom
      (pas de ligne "@@..." et donc $tlimit == {})
      et que $nameOfTable est du genre {} ou *,
      renvoie la liste [0 $n-1]
    
  }
   
  {ARGUMENTS MODIFIÉS} {
      modifie nameOfTable
  }
}

proc superTable::linesOfTable {lignes tlimit nameOfTableName} {
    upvar $nameOfTableName nameOfTable
    foreach il $tlimit {
        if {[info exists ok] && ![info exists last]} {
            set last [expr {$il - 1}]
        }
        set ligne [string range [lindex $lignes $il] 2 end]
# on teste l'egalité pour contourner
# string match {a\a} {a\a} -> 0
# string match {a\\a} {a\a} -> 0
# a revoir
        if {$nameOfTable == $ligne || [string match $nameOfTable $ligne]} {
            if {[info exists ok]} {
                error "more than one matching tables $nameOfTable: $ok and $il"
            }
            set nameOfTable $ligne
            set ok $il
        }
    }
    if {[info exists ok]} {
        set first [expr {$ok + 1}]
    } else {
        if {$tlimit == {} && [string match $nameOfTable {}]} {
            set first 0
        } else {
            error "no matching table $nameOfTable"
        }
    }
    if {![info exists last]} {
        set last [expr {[llength $lignes] - 1}]
    }
    return [list $first $last]
}

################################################################################

proc superTable::writeToFile {fichier lignes} {

    if {[file exists $fichier]} {
	puts stderr "Le fichier \"$fichier\" existe.\nUn jour viendra où la mise à jour d'un fichier sera possible"
	set i 1
	set f [file rootname $fichier]
	while {[file exists ${f}#${i}.spt]} {
	    incr i
	}
	set fichier ${f}#${i}.spt
    }

    set out [open $fichier w]

    puts "écriture du fichier $fichier"
    foreach l $lignes {
	puts $out $l
    }
    close $out
}

################################################################################

set Help(superTable::readTable) {
    le tableau $array est rempli à partir des lignes $lignes
        délimitées par la liste de 2 éléments $range
        indexées par la liste d'index $indexes
    une triple liste est retournée : liste des index de ligne,
    des colonnes communes, de toutes les colonnes
    si la liste $indexes est vide, l'indexation a lieu sur les lignes
}

proc superTable::readTable {lignes range arrayName indexes} {
    upvar $arrayName array
    set i0 [lindex $range 0]
    set i1 [lindex $range 1]
    set table [lrange $lignes $i0 $i1]
    set il $i0
    incr il -1
    set iligne -1
    set colLastColIndex -1 ;# (index souhaité pour affichage)
    foreach l $table {
        incr il
        if {[string match #* $l] || [string trim $l " \t"]=={}} {
            continue
        } elseif {[string match @* $l]} {
            set colnamesString [string trim [string range $l 1 end] " \t"]
            # set colnames [eval list $colnames] ;# et non pas split
            set colnames [list]
            foreach e $colnamesString {
                lappend colnames $e
            }
            if {[info exists colunion]} {
                foreach n $colnames {
                    if {![info exists colunion($n)]} {
                        incr colLastColIndex
                        set colunion($n) $colLastColIndex
                    }
                    set coltmp($n) {}
                }
                foreach n [array names colintersect] {
                    if {![info exist coltmp($n)]} {
                        unset colintersect($n)
                    }
                }
                unset coltmp
            } else {
                foreach n $colnames {
                    incr colLastColIndex
                    set colunion($n) $colLastColIndex 
                    set colintersect($n) {} 
                }
            }
            set listic {}
            set maxicind -1
            set ic 0
            foreach c $colnames {
# il faudrait contrôler l'absence de caractères incorrects " \t,:"
                set colnum($c) $ic
                incr ic
            }
            set nCol $ic
            if {$indexes != {}} {
                foreach ind $indexes {
                    set icind [lsearch -exact $colnames $ind]
                    if {$icind < 0} {
                        error "ligne $il : la colonne $ind n'existe pas"
                    } else {
                        lappend listic $icind
                        if {$icind>$maxicind} {
                            set maxicind $icind
                        }
                    }
                }
            }
            # la liste "listic" des numeros de colonnes d'index est construite
            # le nombre "maxicind" correspond a la colonne la plus à droite
            #    utilisée comme index.
        } else {
            if {![info exists nCol]} {
                error "ligne $il : pas de ligne d'index"
            } 
            set dataString [string trim $l " \t"]
            # set data [eval list $data] ;# et non pas split
            set data [list]
            foreach e $dataString {
                lappend data $e
            }
            if {[llength $data] <= $maxicind} {
                error "ligne $il non indexable (manque colonne $maxicind)"
            }
            if {$listic != {}} {
                set indexli {}
                foreach icind $listic {
                    set subind [lindex $data $icind]
                    lappend indexli $subind
                }
            } else {
                incr iligne
                set indexli $iligne
            }
#            set indexli [join $indexli ","]
            lappend linesList $indexli
            set ic 0
            foreach d $data {
                if {$ic >= $nCol} {
                    puts stderr "ligne $il : colonne $ic non indexée"
                    continue ;# pas grave
                } else {
                    set index [list ${indexli} [lindex $colnames $ic]]
                    if {[info exists array($index)]} {
                        error "${arrayName}($index) existe déjà";
                    }
                    set array($index) $d
                }
                incr ic
            }
        }
    }
    set communes [list]
    set nonCommunes [list]
    foreach n [array names colunion] {
        if {[info exists colintersect($n)]} {
            lappend communes $n
        } else {
            lappend nonCommunes $n
        }
    }
    set communes [lsort -command "compareArrayValue colunion" $communes]
    set nonCommunes [lsort -command "compareArrayValue colunion" $nonCommunes]
    return [list $linesList $communes $nonCommunes]
}

################################################################################

proc superTable::compareArrayValue {arrayName e1 e2} {
    upvar $arrayName array
    return [expr {$array($e1) - $array($e2)}]
}

################################################################################

set HELP(superTable::fileToTable) {
    Lit dans le fichier de type superTable, de nom $nameOfFile,
    le bloc de lignes correspondant à la table identifiée
    par sa première ligne @@$nameOfTable,
    qui peut contenir des caractères * (Cf. "globbing")
    Si $nameOfTable est vide, lit tout le fichier comme une seule table
    Utilise la liste des colonnes $indexes pour indexer les lignes.
    Crée ou met à jour le tableau de nom $array
    à partir des éléments de la table.
    Renvoie une triple liste.
    Modifie $nameOfTableName.
    
    Exemple : le fichier essai2.dat est de la forme suivante :
#
@@ carrés et cubes
@  i   i2   i3
   0  0.0  0.0
   1  1.0  1.0
   2  4.0  8.0
...
1000 1.0e6 1.0e9
#
La lecture de la table indexée sur la colonne i
peut se faire par la simple commande

    unset a
    set tableName {*carrés*cubes*}
    set indexes [superTable::fileToTable a tableName essai2.dat  {i}]

et son affichage trié par

    foreach i [lsort -integer [lindex $indexes 0]] {
        puts "$i $a($i:i3)"
    }
}

proc superTable::fileToTable {arrayName nameOfFile nameOfTableName indexes args} {
    upvar $arrayName array
    upvar $nameOfTableName nameOfTable
    set lignes [superTable::getLines $nameOfFile] ;# ne pas afficher
    # $lignes est la liste des lignes de $nameOfFile

    set tlimit [superTable::marqueTables $lignes]
    # $tlimit est la liste des lignes commençant par @@

    set range [superTable::linesOfTable $lignes $tlimit nameOfTable]
    # $range est une liste de deux éléments : première et dernière ligne
    # correspondant à la table $nameOfTable
    # la première ligne est la ligne suivant @@...

    set table [lrange $lignes [lindex $range 0] [lindex $range 1]]
    # $table est la liste des lignes du fichier correspondant à
    # la table $nameOfTable

    set indexes [superTable::readTable $lignes $range array $indexes]
    # $indexes est la liste des $i, valeurs de la colonne d'index "i"
    # L'élément ligne $i colonne $c est $a($i:$c)
    return $indexes
    
    # modifie nameOfTable
}

################################################################################

set HELP(supertable::getCell) {
    retourne le contenu d'une cellule
}

proc superTable::getCell {arrayName ligne colonne} {
    upvar $arrayName array
    return $array([list $ligne $colonne])
}

proc superTable::setCell {arrayName ligne colonne value} {
    upvar $arrayName array
    set array([list $ligne $colonne]) $value
}

proc superTable::deleteCell {arrayName ligne colonne} {
    upvar $arrayName array
    unset array([list $ligne $colonne])
}

proc superTable::cellExists {arrayName ligne colonne} {
    upvar $arrayName array
    return [info exists array([list $ligne $colonne])]
}


################################################################################

set HELP(superTable::tablesOfFile) {
    retourne la liste des tables contenues dans le fichier $nameOfSptFile
}
proc superTable::tablesOfFile {nameOfSptFile} {
    set lines [superTable::getLines $nameOfSptFile]
    set tables [list]
    foreach l $lines {
        if {[string range $l 0 1] == "@@"} {
            lappend tables [string range $l 2 end]
        }
    }
    return $tables
}

set HELP(superTable::tablesOfFile) {
    retourne la liste des tables contenues dans le fichier $nameOfSptFile
}

set HELP(superTable::tablesOfFileWithLinesIndexes) {
    la premiere ligne du fichier est la ligne "1"
}

proc superTable::tablesOfFileWithLinepos {nameOfSptFile} {
    set lines [superTable::getLines $nameOfSptFile]
    set llist [list]
    set tlist [list]
    set il 0
    set lb 0
    foreach l $lines {
	incr il
        if {[string range $l 0 1] == "@@"} {
	    if {$lb != 0} {
		lappend llist [list $lb [expr {$il - 1}]]
		lappend tlist $table
	    }
	    set lb $il
	    set table [string range $l 2 end]
        }
    }
    if {$lb != 0} {
	lappend llist [list $lb $il]
	lappend tlist $table
    }
    return [list $llist $tlist]
}

################################################################################

set HELP(superTable::tablesOfDir) {
    explore tous les fichiers $globNames
    crée (après destruction éventuelle) le tableau de nom $arrayName
    Chaque élément du tableau correpond au début d'un nom de table
    il contient la liste des fichiers contenant une table
    dont le début du nom (au sens de premier élément de liste)
    correspond au nom de l'élément du tableau
    Retourne la liste des premiers éléments des noms de tables
}
proc superTable::tablesOfDir {globNames arrayName} {
    upvar $arrayName array
    if {[info exists array]} {
        unset array
    }
    set array(dummy) {}
    unset array(dummy)
    if {[catch {glob $globNames} files]} {
        return {}
    }
    foreach f [glob $globNames] {
        foreach t [superTable::tablesOfFile $f] {
            lappend array([lindex $t 0]) $f
        }
    }
    return [array names array]
}

################################################################################

set HELP(superTable::tableIndexesFromArray) {
    Reconstitue les index de ligne et de colonne à partir d'un tableau de nom $arrayName
    Retourne une liste triple :
    liste des index de ligne,
    des noms de colonnes communes,
    des noms de colonnes non communes
}
proc superTable::tableIndexesFromArray {arrayName} {
    upvar $arrayName array
    foreach n [array names array] {
        if {[llength $n] != 2} {
            error "L'index $n ne peut pas être un élément de tableau superTable"
        }
        foreach {li co} $n {}
        if {[info exists colonnes($co)]} {
            incr colonnes($co)
        } else {
            set colonnes($co) 1
        }
        if {[info exists lignes($li)]} {
            incr lignes($li)
        } else {
            set lignes($li) 1
        }
    }
    set indexOfLines [array names lignes]
    set nlignes [llength $indexOfLines]
    set communes [list]
    set nonCommunes [list]
    foreach co [array names colonnes] {
        if {$colonnes($co) == $nlignes} {
            lappend communes $co
        } else {
            lappend nonCommunes $co
        }
    }
    return [list $indexOfLines $communes $nonCommunes]
}

################################################################################

proc ::superTable::compareNameOfSpt {n1 n2} {
    if {![regexp {^([^#]*)(#([0-9]+)|()).spt$} $n1 tout b1 t v1]} {
	error "Bad spt filename: \"$n1\""
    }
    if {![regexp {^([^#]*)(#([0-9]+)|()).spt$} $n2 tout b2 t v2]} {
	error "Bad spt filename: \"$n2\""
    }
    if {$v1 == {}} {
	set v1 0
    }
    if {$v2 == {}} {
	set v2 0
    }
    set ret [string compare $b1 $b2]
    if {$ret != 0} {
	return $ret
    }
    if {$v1 > $v2} {
	return 1
    }
    if {$v1 < $v2} {
	return -1
    }
    return 0
}


################################################################################

proc superTable::compareSizeOfTables {l1 l2} {
    set comp [expr {[llength [lindex $l1 1]] - [llength [lindex $l2 1]]}]
    if {$comp < 0} {
        return -1
    } elseif {$comp > 0} {
        return 1
    }
    set comp [expr {[llength [lindex $l1 0]]-[llength [lindex $l2 0]]}]
    return $comp
}

################################################################################

set HELP(superTable::regroupeColonnes) {
    Retourne une liste
      dont chaque élément définit
      les moyens d'accès à une table.
    
    Chaque élément est
      une liste de deux éléments :
        - la liste des colonnes
        - la liste des index de lignes

    $arrayName est le nom de l'array Tcl qui représente la supertable.
    
    $indexDeLignes est la liste des index de lignes.
    
    $colonnesCommunes est la liste des colonnes
      communes à toutes les tables
      de la supertable.

    $colonnesNonCommunes est la liste des colonnes
       qui apparaissent dans au moins une table
       dans apparaitre dans toutes.
        
    NOTA :
      L'ordre de la liste $colonnesNonCommunes a
        peut-être
        une certaine importance.
}

proc superTable::regroupeColonnes {arrayName indexDeLignes colonnesCommunes colonnesNonCommunes} {
    upvar $arrayName array
    set ncols [llength $colonnesNonCommunes]
    foreach l $indexDeLignes {
        set ind [list]
        foreach c $colonnesNonCommunes {
            if {[info exists array([list $l $c])]} {
                append ind 1
            } else {
                append ind 0
            }
        }
        lappend inds($ind) $l        
    }
    set tables [list]
    foreach e [array names inds] {
        set lignes $inds($e)
        set cols [list]
        for {set i 0} {$i<$ncols} {incr i} {
            if {[string index $e $i] == "1"} {
                lappend cols [lindex $colonnesNonCommunes $i]
            }
        }
        lappend tables [list [concat $colonnesCommunes $cols] $lignes]
    }
    
    set tables [lsort -command superTable::compareSizeOfTables $tables]
    
    return $tables
}

################################################################################

proc superTable::padToWidth {valeur width} {
    set retour [list $valeur]
    set i [expr {$width - [string length $retour]}]
    while {$i > 0} {
        append retour " "
        incr i -1
    }
    return $retour
}

################################################################################

proc superTable::formatte {valeur {commande {}}} {
    if {$commande == {}} {
        set retour [list $valeur]
    } else {
        set retour [$commande $valeur]
        if {[llength $retour] != 1} {
            error "$commande aurait du retourner un élément unique et non \"$retour\""
        }
    }
    return $retour
}

################################################################################

set HELP(superTable::createLinesFromArray) {
    
}
::tcl::OptProc superTable::createLinesFromArray {
        {arrayName {nom Du tableau contenant les cases}}
        {nomDeTable {nom de la superTable (caractères suivant @@)}}
        {-sortLines -list {} {commande permettant de trier les lignes d'une table}}
        {-itables -list {} {liste facultative des tables, contenant colonnes et liste des lignes}}
        {-orderOfCols -list {} {liste facultative de colonnes, fixant leur ordre ; valable seulement si itables est absent}}} {
    upvar $arrayName array
    
    if {$itables == {}} {
        foreach {lindex commonCols cncom} [superTable::tableIndexesFromArray array] {}
        if {$orderOfCols != {}} {
            set commonCols [listUtils::reorderList $commonCols $orderOfCols]
            set cncom      [listUtils::reorderList $cncom      $orderOfCols]
        }
        set itables [superTable::regroupeColonnes array $lindex $commonCols $cncom]
    }
    
      
    set lignes [list "@@$nomDeTable"]
  # initialisation du tableau de contrôle  
    foreach e [array names array] {
        set vus($e) {}
    }
  # traitement de chaque table  
      foreach t $itables {
      set colonnes [lindex $t 0]
      # analyse de la largeur des colonnes
        foreach c $colonnes {
            set widthCol($c) [string length [superTable::formatte $c]]
            foreach l [lindex $t 1] {
                set case [superTable::formatte $array([list $l $c])]
                set w [string length $case]
                if {$w > $widthCol($c)} {
                    set widthCol($c) $w
                }
            }   
        }
        set lalpha {}
      # ligne de description de colonnes
        foreach c $colonnes {
            if {$lalpha == {}} {
                append lalpha "@"
            } else {
                append lalpha " "
            }
            append lalpha [superTable::padToWidth $c $widthCol($c)]
        }
        lappend lignes $lalpha
      # lignes de données
        set lili [lindex $t 1]
        if {$sortLines != {}} {
            set lili [lsort -command "$sortLines array" $lili]
        }
        foreach l $lili {
            set lalpha {}
            foreach c $colonnes {
                set elem [list $l $c]
                append lalpha " " [superTable::padToWidth $array($elem) $widthCol($c)]
                unset vus($elem)
            }
            lappend lignes $lalpha
        }
    }
    set restent [array names vus]
    if {$restent != {}} {
        error "restent \"$restent\""
    }
    return $lignes
}

################################################################################

set toto {
    package require fidev
    package require superTable
    set lignes [superTable::getLines /home/fidev/Tcl/superTable/test/geom.txt]
    set debuts [superTable::marqueTables $lignes]
    set nomsDesTables [superTable::nomsDesTables $lignes $debuts]
    superTable::readTable $lignes {9 25} titi {}
    array names titi
    unset titi
    superTable::readTable $lignes {9 25} titi TYPE
    array names titi
    unset titi
    set lindex [superTable::readTable $lignes {9 25} titi {LarMesa TYPE}]
    array names titi
    foreach {lindex ccom cncom} [superTable::tableIndexesFromArray titi] {}
    puts $lindex
    puts $ccom
    puts $cncom
    set tables [superTable::regroupeColonnes titi $lindex $ccom $cncom]
    set newLines [superTable::createLinesFromArray titi bibi $tables]
    foreach l $newLines {
        puts $l
    }
# exemple de tri des lignes
# tri sur la valeur de la colonne $col
    proc triNum {col arrayName l1 l2} {
        upvar $arrayName array
        set l1 [list $l1 $col]
        set l2 [list $l2 $col]
        if {![info exists array($l1)] || ![info exists array($l2)]} {
            return 0
        }
        set retour [expr {$array($l1) - $array($l2)}]
        return $retour
    }
  # tri sur la valeur de la colonne nFant
    set newLines [superTable::createLinesFromArray titi bibi -sortLines {triNum nFant}]
    foreach l $newLines {
        puts $l
    }
}

################################################################################

proc superTable::fileToTabSeparatedFile {nameOfSptFile nameOfTabFile nameOfTableName indexes cols} {
    upvar $nameOfTableName nameOfTable
    set out [open $nameOfTabFile w]
    set iii [superTable::fileToTable a $nameOfSptFile nameOfTableName $indexes]
    foreach i [lindex $iii 0] {
        set first 1
        foreach t $cols {
            if {$first} {
                set first 0
            } else {
                puts -nonewline $out "\t"
            }
            puts -nonewline $out $a($i:$t)
        }
        puts $out {}
    }
    close $out
}
# set name *
# superTable::fileToTabSeparatedFile 0000.log /tmp/0000.log name instant {V I statut}

################################################################################

proc ::superTable::readReallyAllTablesInDirectory {directory} {
    set fichiers [glob $directory/*.spt]
    set fitas [list]
    set lb 1
    foreach f $fichiers {
	set instant [file mtime $f]
	foreach {linepos tables} [::superTable::tablesOfFileWithLinepos $f] {}
	lappend fitas [list [file tail $f] $instant $linepos $tables]
    }
    return $fitas
}

proc ::superTable::newCache {directory} {
    set fitas [::superTable::readReallyAllTablesInDirectory $directory]
    set wf 9 ;# "@ fichier"
    set wl 6 ;# "lignes"
    foreach fita $fitas {
	set w [string length [lindex $fita 0]]
	if {$w > $wf} {
	    set wf $w
	}
	foreach l1l2 [lindex $fita 2] {
	    set w [string length $l1l2]
puts "$w $wl"
	    if {$w > $wl} {
		set wl $w
	    }
	}
    }

    # Il faudrait poser des verrous
    set cache [open $directory/.CACHE.spt w]

    # il faudrait trouver le vrai nom du répertoire
    puts $cache "@@cache de $directory"

    set ligne "@ [::superTable::padToWidth "fichier" [expr {$wf - 2}]]"
    append ligne " jour       heure   "
    append ligne " [::superTable::padToWidth "lignes" $wl]"
    append ligne " table"
    puts $cache $ligne

    foreach fita $fitas {
	foreach {f instant linepos tables} $fita {}
	set ligne [::superTable::padToWidth $f $wf]
	append ligne [clock format $instant -format { %Y/%m/%d %H:%M:%S }]
	foreach l $linepos t $tables {
	    set l [::superTable::padToWidth $l $wl]
	    puts $cache "$ligne $l [list $t]"
	}
    }
    close $cache
}

proc ::superTable::allTablesInDirectory {directory} {
    if {![file exists $directory/.CACHE.spt]} {
	puts stderr "Pas de cache => on la crée"
	::superTable::newCache $directory
    }
    set nameOfTable "cache de *"

    foreach f [glob $directory/*.spt] {
	set actuel([file tail $f]) [file mtime $f]
    }

    puts stderr "VERIF DE MISE A JOUR DE CACHE PAS FAITE"
    puts stderr "effacer \".CACHE.spt\" dans le répertoire en cas de doute"

    set indexes [::superTable::fileToTable a $directory/.CACHE.spt nameOfTable {}]
    
    set fprec {}
    set liste [list]
    foreach il [lindex $indexes 0] {
	set f [::superTable::getCell a $il fichier]
	set f [file join $directory $f]
	set t [::superTable::getCell a $il table]
	if {$f != $fprec} {
	    if {$fprec != {}} {
		lappend liste [list $fprec $sublist]
	    }
	    set fprec $f
	    set sublist [list $t]
	} else {
	    lappend sublist $t
	}
    }
    return $liste
}

proc ::superTable::allTablesInFiles {fichiers} {
    error "::superTable::allTablesInFiles not yet implemented"
}



