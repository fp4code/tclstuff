package require Tktable
proc tableEtCurseurs {w} {
    if {$w == "."} {
        set w {}
    }
    table $w.t \
        -yscrollcommand "$w.sy set"\
        -xscrollcommand "$w.sx set"\
    scrollbar $w.sx -orient h -command "$w.t xview"
    scrollbar $w.sy -orient v -command "$w.t yview"
    grid $w.t $w.sy -sticky nsew
    grid $w.sx -sticky ew
    grid columnconfig . 0 -weight 1
    grid rowconfig . 0 -weight 1
}
tableEtCurseurs .

Les cases sont indicées ligne,colonne
La case en haut à gauche est par défaut 0,0 mais les options
    .t configure -colorigin -2
    .t configure -roworigin -2
permettent de changer cela.
En outre, les premières lignes et colonnes peuvent être neutralisées :
    .t configure -titlecols 2
    .t configure -titlerows 2
Le nombre total de colonnes et de lignes (y compris les colonnes
et lignes fixées) est obtenu par
    .t configure -cols 3
    .t configure -rows 40
Il y a aussi
    .t configure -width 0       ;# ???
    .t configure -height 0      ;# ???
    .t configure -maxwidth 800  ;# en pixels
    .t configure -maxheight 600 ;# en pixels
    
L'insertion de $n colonnes après la colonne $co est possible
    .t insert cols -- $co $n
On peut aussi les insérer avant :
    .t insert cols -- $co -$n
Les options -cols, -holddimensions, -holdtags, -keeptutiles, -rows sont possibles
La destruction de colonnes suit la même syntaxe :
    .t delete cols ?-options? -- $co $n
    .t delete cols ?-options? -- $co -$n

L'insertion et la destruction de lignes sont similaires
à ce qu'elles sont pour les colonnes
    .t insert rows ...
    .t delete rows ...

Tableau associé :
    .t configure -variable tableau
Chaque case correspond à la valeur $tableau(li,co)
Existe en outre l'élément $tableau(active)
La modification d'une case peut intervenir par
    set tableau($li,$co) $valeur
ou
    .t set $li,$co $valeur
Cette dernière forme modifie bien tableau($li,$co)
Sa forme la plus générale est 
    .t set $index $valeur
La forme de l'index peut être
  $li,$co     -> ligne colonne
  active      -> la case marquée (en blanc)
  anchor      -> ???
  origin      -> la case la plus en haut à gauche
      (mises à par les lignes et colonnes neutralisées pour les titres)
  end         -> la case la plus en bas à droite
  topleft     -> la case visible la plus en haut à gauche
  bottomright -> la case visible la plus en bas à droite
  @$x,$y      -> la case qui contient le pixel $x,$y
On peut répéter une sucession index-valeur
    .t set 0,1 01 0,2 02 0,3 03
Pour récupérer la liste des valeurs d'un rectangle de cases (lues à l'occidentale)
    set liste [.t get $indexHautGauche $indexBasDroit]

On peut récupérer la forme normalisée de l'index par
    set index [.t index $index]
On peut aussi récupérer l'indice de colonne ou l'indice de ligne
    set col [.t index $index col]
    set row [.t index $index row]
    
Les cases de titre sont fixes mais sont concernées comme les autres par set, get
ou les valeurs du tableau associé.

Avant qu'une case ait été validée (pendant qu'on tape des caractères dedant),
on peut connaitre le contenu affiché
    set valeurProchaine [.t curvalue]
  
La dimension des cases 
    .t configure -colwidth 10 ;# en caractères
    .t configure -rowheight 20 ;# en pixels ; 0 donne une hauteur de 1 caractère
    .t configure -rowheight 0 ;# hauteur de 1 caractère
Ce dimensionnement est strict seulement si 
    .t configure -rowstretchmode none
    .t configure -colstretch     none
Mais on peut donner les options
        none   aucune case ne change de dimension pour suivre le cadre
        unset  changent les cases dont la dimension n'est pas définie
        last   la dernère case change de dimension
        all    toutes les cases changent (attention)
On peut dimensionner une colonne précise :
    .t width $co $width
et connaitre la largeur (en caractères)
    set width [.t width $co]
Même chose pour la hauteur d'une ligne, en pixels
    .t height $li $height
    set height [.t height $li]

Copié-Collé :
Normalement "copier" une sélection de cases retourne une liste de listes
correspondant au balayage lignes par lignes de toute la table,\
et en n'ajoutant aux listes que ce qui est sélectionné.
Attention aux sélections multiples : Le collage change la géométrie.
    .t configure -rowseparator {}
    .t configure -colseparator {}
    .t configure -selectioncommand {}
Toutefois, il est possible, pour copier ou coller X facilement,
de préciser des caractères de séparation, valables dans les deux sens.
    .t configure -colseparator "\t"
    .t configure -rowseparator "\n"
Il est aussi possible de passer la sélection copiée dans la table
au travers d'une moulinette supplémentaire
    .t configure -selectioncommand {uneCommande ...}
La moulinette standard est {} est équivalente à
    .t configure -selectioncommand {return %s}
Outre %s, qui correspond à la sélection,
on peut utiliser  %c pour le nombre de colonnes,
%r pour le nombre de lignes
(deux valeurs obtenues après le rassemblement des lignes et colonnes dans le
cas de sélections multiples),
%i pour le nombre de cases et
%W pour le nom du widget table.

Mise en valeur automatique des changements de valeur des cases
    .t configure -flashmode 1
    .t configure -flashtime 8 ;$ 1/4 de secondes

Effacement de la case au premier caractère frappé
    .t configure -autoclear 1

Appel d'une commande à chaque changement de case "active".
    .t configure -browsecommand {uneCommande ...}
Le changement de case active a lieu avec le click de souris, les flèches
ou la commande
    .t activate $index

Insertion d'une chaine à la position $i de la chaine de la case
    .t insert active $i $chaine
Attention, il faut auparavant, sinon autant utiliser ".t set active $chaine"
    .t configure -autoclear 0
Destruction de caractères d'une case
    .t delete active $iDebut
    .t delete active $iDebut $iFin+1
    .t delete active $iDebut end
    .t delete active $iDebut insert ;# ???

La table peut bouger :
Pour voir la case $index :
    .t see $index  
Comme un canvas, associé à un scrollbar par exemple :
    .t xview ...
    .t yview ...
Comme canvas, balayage rapide de table
    .t scan mark ...
    .t scan dragto ...
(bindé avec le bouton du milieu)

Tout désélectionner.
(Attention, cela peut arriver lorsque l'on clicke dans une autre fenêtre)
    .t selection clear all
Sélectionner ou désélectionner une zone
    .t selection set $limin1,$comin1 $limax1,$comax1
    .t selection set $limin2,$comin2 $limax2,$comax2
    .t selection clear $limin3,$comin3 $limax3,$comax3
ou une case
    .t selection set $index4
    .t selection clear $index5
    ...
    
    .t selection anchor ;# ???

Savoir si une case est sélectionnée
    set isSelectionned [.t selection includes $index]
Connaitre la liste des cases sélectionnées
    set liste [.t curselection]
Changer leur valeur
    .t curselection set $valeurCommune



# cosmétique :

-bd borderWidth
-borderwidth 1 # largeur des traits de séparation des cases
-font -dt-interface user-medium-r-normal-s*-*-*-*-*-*-*-*-*
-cursor xterm

Comme tout widget
    .t configure ...
    .t cget ...

Divers
    .t version -> actuellement 1.80

# standard

-bg background
-fg foreground
-anchor center
-background #D100C0EFAE93
-exportselection 1
-foreground #000000000000
-highlightbackground #d9d9d9
-highlightcolor Black
-highlightthickness 2
-insertborderwidth 0
-insertofftime 300
-insertontime 600
-insertwidth 2
-padx 2
-pady 1
-relief sunken
-takefocus 




AUTRE

-batchmode 0
-cache 0
-coltagcommand 
-command 
-drawmode compatible
-insertbackground Black
-rowtagcommand 
-selcmd selectionCommand


-selectmode browse
-selecttype cell
-state normal
-usecommand 1
-validate 0
-validatecommand 
-vcmd validateCommand

bbox
border
flush
icursor
reread
tag
validate


