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

Les cases sont indic�es ligne,colonne
La case en haut � gauche est par d�faut 0,0 mais les options
    .t configure -colorigin -2
    .t configure -roworigin -2
permettent de changer cela.
En outre, les premi�res lignes et colonnes peuvent �tre neutralis�es :
    .t configure -titlecols 2
    .t configure -titlerows 2
Le nombre total de colonnes et de lignes (y compris les colonnes
et lignes fix�es) est obtenu par
    .t configure -cols 3
    .t configure -rows 40
Il y a aussi
    .t configure -width 0       ;# ???
    .t configure -height 0      ;# ???
    .t configure -maxwidth 800  ;# en pixels
    .t configure -maxheight 600 ;# en pixels
    
L'insertion de $n colonnes apr�s la colonne $co est possible
    .t insert cols -- $co $n
On peut aussi les ins�rer avant :
    .t insert cols -- $co -$n
Les options -cols, -holddimensions, -holdtags, -keeptutiles, -rows sont possibles
La destruction de colonnes suit la m�me syntaxe :
    .t delete cols ?-options? -- $co $n
    .t delete cols ?-options? -- $co -$n

L'insertion et la destruction de lignes sont similaires
� ce qu'elles sont pour les colonnes
    .t insert rows ...
    .t delete rows ...

Tableau associ� :
    .t configure -variable tableau
Chaque case correspond � la valeur $tableau(li,co)
Existe en outre l'�l�ment $tableau(active)
La modification d'une case peut intervenir par
    set tableau($li,$co) $valeur
ou
    .t set $li,$co $valeur
Cette derni�re forme modifie bien tableau($li,$co)
Sa forme la plus g�n�rale est 
    .t set $index $valeur
La forme de l'index peut �tre
  $li,$co     -> ligne colonne
  active      -> la case marqu�e (en blanc)
  anchor      -> ???
  origin      -> la case la plus en haut � gauche
      (mises � par les lignes et colonnes neutralis�es pour les titres)
  end         -> la case la plus en bas � droite
  topleft     -> la case visible la plus en haut � gauche
  bottomright -> la case visible la plus en bas � droite
  @$x,$y      -> la case qui contient le pixel $x,$y
On peut r�p�ter une sucession index-valeur
    .t set 0,1 01 0,2 02 0,3 03
Pour r�cup�rer la liste des valeurs d'un rectangle de cases (lues � l'occidentale)
    set liste [.t get $indexHautGauche $indexBasDroit]

On peut r�cup�rer la forme normalis�e de l'index par
    set index [.t index $index]
On peut aussi r�cup�rer l'indice de colonne ou l'indice de ligne
    set col [.t index $index col]
    set row [.t index $index row]
    
Les cases de titre sont fixes mais sont concern�es comme les autres par set, get
ou les valeurs du tableau associ�.

Avant qu'une case ait �t� valid�e (pendant qu'on tape des caract�res dedant),
on peut connaitre le contenu affich�
    set valeurProchaine [.t curvalue]
  
La dimension des cases 
    .t configure -colwidth 10 ;# en caract�res
    .t configure -rowheight 20 ;# en pixels ; 0 donne une hauteur de 1 caract�re
    .t configure -rowheight 0 ;# hauteur de 1 caract�re
Ce dimensionnement est strict seulement si 
    .t configure -rowstretchmode none
    .t configure -colstretch     none
Mais on peut donner les options
        none   aucune case ne change de dimension pour suivre le cadre
        unset  changent les cases dont la dimension n'est pas d�finie
        last   la dern�re case change de dimension
        all    toutes les cases changent (attention)
On peut dimensionner une colonne pr�cise :
    .t width $co $width
et connaitre la largeur (en caract�res)
    set width [.t width $co]
M�me chose pour la hauteur d'une ligne, en pixels
    .t height $li $height
    set height [.t height $li]

Copi�-Coll� :
Normalement "copier" une s�lection de cases retourne une liste de listes
correspondant au balayage lignes par lignes de toute la table,\
et en n'ajoutant aux listes que ce qui est s�lectionn�.
Attention aux s�lections multiples : Le collage change la g�om�trie.
    .t configure -rowseparator {}
    .t configure -colseparator {}
    .t configure -selectioncommand {}
Toutefois, il est possible, pour copier ou coller X facilement,
de pr�ciser des caract�res de s�paration, valables dans les deux sens.
    .t configure -colseparator "\t"
    .t configure -rowseparator "\n"
Il est aussi possible de passer la s�lection copi�e dans la table
au travers d'une moulinette suppl�mentaire
    .t configure -selectioncommand {uneCommande ...}
La moulinette standard est {} est �quivalente �
    .t configure -selectioncommand {return %s}
Outre %s, qui correspond � la s�lection,
on peut utiliser  %c pour le nombre de colonnes,
%r pour le nombre de lignes
(deux valeurs obtenues apr�s le rassemblement des lignes et colonnes dans le
cas de s�lections multiples),
%i pour le nombre de cases et
%W pour le nom du widget table.

Mise en valeur automatique des changements de valeur des cases
    .t configure -flashmode 1
    .t configure -flashtime 8 ;$ 1/4 de secondes

Effacement de la case au premier caract�re frapp�
    .t configure -autoclear 1

Appel d'une commande � chaque changement de case "active".
    .t configure -browsecommand {uneCommande ...}
Le changement de case active a lieu avec le click de souris, les fl�ches
ou la commande
    .t activate $index

Insertion d'une chaine � la position $i de la chaine de la case
    .t insert active $i $chaine
Attention, il faut auparavant, sinon autant utiliser ".t set active $chaine"
    .t configure -autoclear 0
Destruction de caract�res d'une case
    .t delete active $iDebut
    .t delete active $iDebut $iFin+1
    .t delete active $iDebut end
    .t delete active $iDebut insert ;# ???

La table peut bouger :
Pour voir la case $index :
    .t see $index  
Comme un canvas, associ� � un scrollbar par exemple :
    .t xview ...
    .t yview ...
Comme canvas, balayage rapide de table
    .t scan mark ...
    .t scan dragto ...
(bind� avec le bouton du milieu)

Tout d�s�lectionner.
(Attention, cela peut arriver lorsque l'on clicke dans une autre fen�tre)
    .t selection clear all
S�lectionner ou d�s�lectionner une zone
    .t selection set $limin1,$comin1 $limax1,$comax1
    .t selection set $limin2,$comin2 $limax2,$comax2
    .t selection clear $limin3,$comin3 $limax3,$comax3
ou une case
    .t selection set $index4
    .t selection clear $index5
    ...
    
    .t selection anchor ;# ???

Savoir si une case est s�lectionn�e
    set isSelectionned [.t selection includes $index]
Connaitre la liste des cases s�lectionn�es
    set liste [.t curselection]
Changer leur valeur
    .t curselection set $valeurCommune



# cosm�tique :

-bd borderWidth
-borderwidth 1 # largeur des traits de s�paration des cases
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


