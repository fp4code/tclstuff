set DEMANDEUR PARDO
set POSTE 6148
set DATE [clock format [clock seconds] -format  %d/%m/%Y]
set IMPUTATION PHYDIS
set LIEE NON
set CONTRAT rien

set CHIMIE NON
set GAZ NON
set NATURE FONCTIONNEMENT
set INVENTAIRE 0
set MARCHE 00-25-001
set FOURNISSEUR FARNELL
set ADRESSE {}
set PHONE {}
set FAX {}


#font create normal -family times -size 10
#font create italic -family times -size 10 -slant italic
#font create bold -family times -size 10 -weight bold
#font create tiny -family times -size 4
#font create fixed -family helvetica -size 10

set F(normal) {-adobe-times-medium-r-normal--14-*-*-*-*-*-iso8859-1}
set F(tiny)   {-adobe-times-medium-r-normal--12-*-*-*-*-*-iso8859-1}
set F(italic)    {-adobe-times-medium-i-normal--14-*-*-*-*-*-iso8859-1}
set F(bold)    {-adobe-times-bold-r-normal--14-*-*-*-*-*-iso8859-1}
set F(fixed) {-adobe-helvetica-medium-r-normal--14-*-*-*-*-*-iso8859-1}
set F(title) {-adobe-times-medium-r-normal--18-*-*-*-*-*-iso8859-1}

set PSFONT(normal) {Times-Roman 14}
set PSFONT(tiny) {Times-Roman 12}
set PSFONT(italic) {Times-Italic 14}
set PSFONT(bold) {Times-Bold 14}
set PSFONT(fixed} {Helvetica 14}
set PSFONT(title) {Times-Roman 18}

set LS(normal) [font metrics $F(normal) -linespace]
set LS(tiny)   [font metrics $F(tiny) -linespace]
set LS(title)  [font metrics $F(title) -linespace]
set LS(italic) [font metrics $F(italic) -linespace]
set LS(fixed)  [font metrics $F(fixed) -linespace]
set AS(title)  [font metrics $F(title) -ascent]
set DS(title)  [font metrics $F(title) -descent]

canvas .c -width 640 -height 900
pack .c

.c delete all

proc putHText {canvas text} {
    global CURSORX CURSORY F
    set font $F(normal)
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    incr CURSORX [font measure $font $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    set rien {
        $canvas create line $x1 $y1 $x2 $y1
        $canvas create line $x1 $y2 $x2 $y2
        $canvas create line $x1 $y1 $x1 $y2
        $canvas create line $x2 $y1 $x2 $y2
    }
    return [list $item [$canvas bbox $item]]
}


proc putHTextTiny {canvas text} {
    global CURSORX CURSORY F
    set font $F(tiny)
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    incr CURSORX [font measure $font $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    return [list $item [$canvas bbox $item]]
}

proc putHTextI {canvas text} {
    global CURSORX CURSORY F
    set font $F(italic)
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    set rien {
        $canvas create line $x1 $y1 $x2 $y1
        $canvas create line $x1 $y2 $x2 $y2
        $canvas create line $x1 $y1 $x1 $y2
        $canvas create line $x2 $y1 $x2 $y2
    }
    incr CURSORX [font measure $font $text]

    return [list $item [$canvas bbox $item]]
}

proc putFixedText {canvas text} {
    global CURSORX CURSORY F
    set font $F(fixed)
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    incr CURSORX [font measure $font $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    return [list $item [$canvas bbox $item]]
}

proc putRightFixedText {canvas text} {
    global CURSORX CURSORY F
    set font $F(fixed)
    set item [$canvas create text $CURSORX $CURSORY -anchor se -font $font -text $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    return [list $item [$canvas bbox $item]]
}

proc putTitleText {canvas text} {
    global CURSORX CURSORY F
    set font $F(title)
    set item [$canvas create text $CURSORX $CURSORY -anchor s -font $font -text $text]
    return [list $item [$canvas bbox $item]]
}

.c delete all

set CURSORX 20
set CURSORY 20

putHText .c {L.P.N.}
set CURSORX 20
incr CURSORY $LS(normal)
putHText .c {Laboratoire de Photonique et de Nanostructures}

set CURSORX 320
incr CURSORY [expr {2*$LS(title)}]
putTitleText .c {DEMANDE D'ACHAT}

set y1 [expr {$CURSORY - $LS(title) - 1}]
set y2 $CURSORY
.c create line [list 20 $y1 620 $y1]
.c create line [list 20 $y2 620 $y2]
.c create line [list 20 $y1 20 $y2] 
.c create line [list 620 $y1 620 $y2] 

set CURSORX 20
incr CURSORY [expr {2*$LS(title)}]

putHTextI .c {Demandeur : }
putHText .c $DEMANDEUR

set CURSORX 150
putHTextI .c {Signature du Responsable : }

set CURSORX 400
putHTextI .c {No de poste : }
putHText .c $POSTE

set CURSORX 520
putHTextI .c {Date : }
putHText .c $DATE

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

putHTextI .c {Imputation de la commande : }
putHText .c $IMPUTATION

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

putHTextI .c {Li�e � un projet Europ�en / contrat national / action incitative ou programme : }
if {$LIEE == "NON"} {
    putHText .c NON
} elseif {$LIEE == "OUI"} {
    putHText .c OUI
    set CURSORX 20
    incr CURSORY [expr {$LS(normal)}]
    putHTextI .c {Nom du programme : }
    putHText .c $CONTRAT
} else {
    return -code error "LIEE : OUI ou NON et non pas $LIEE"
}


set CURSORX 20
incr CURSORY [expr {2*$LS(normal)}]
putHTextI .c {Produit chimique : }
putHText .c $CHIMIE

incr CURSORX 50
putHTextI .c {Gaz : }
putHText .c $GAZ

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

putHTextI .c {Fonctionnement, �quipement, R�paration sur contrat : }
putHText .c $NATURE

incr CURSORX 10
putHTextI .c {No inventaire : }

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

putHTextI .c {Fournisseur : }
putHText .c $FOURNISSEUR

incr CURSORX 20
if {$CURSORX < 400} {
    set CURSORX 400
}
if {$MARCHE == {}} {
    putHTextI .c {Hors march�}
} else {
    putHTextI .c {Sur march� No : }
    putHText .c $MARCHE
}

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

if {$ADRESSE != {}} {
    putHTextI .c {Adresse : }
    putHText .c $ADRESSE
}
if {$PHONE != {}} {
    putHTextI .c {T�l�phone : }
    putHText .c $PHONE
}
if {$FAX != {}} {
    putHTextI .c {Fax : }
    putHText .c $FAX
}

incr CURSORY [expr {$LS(normal)}]


proc printlist {list} {
    global CURSORX CURSORY LS
    
    set tot [expr 0.0]
    
    set c0 20
    set c1 50
    set c2 440
    set c3 500
    set c4 560
    set c5 620

    set CURSORX $c0
    incr CURSORX 2
    putHTextI .c {Qt�}
    set CURSORX $c1
    incr CURSORX 2
    putHTextI .c {D�signation du mat�riel}
    set CURSORX $c2
    incr CURSORX 2
    putHTextI .c {P.U. H.T.}
    set CURSORX $c3
    incr CURSORX 2
    putHTextI .c {Tx. remise}
    set CURSORX $c4
    incr CURSORX 2
    putHTextI .c {Prix H.T.}
    
    set y0 [expr {$CURSORY - $LS(italic) - 1}]
    set y1 $CURSORY
    set y2 800
    set y3 [expr {$y2 + $LS(italic) + 1}]
    
    .c create line [list $c0 $y0 $c5 $y0]
    .c create line [list $c0 $y1 $c5 $y1]
    .c create line [list $c0 $y2 $c5 $y2]
    .c create line [list $c0 $y3 $c5 $y3]
    
    .c create line [list $c0 $y0 $c0 $y3]
    .c create line [list $c1 $y0 $c1 $y2]
    .c create line [list $c2 $y0 $c2 $y2]
    .c create line [list $c3 $y0 $c3 $y2]
    .c create line [list $c4 $y0 $c4 $y2]
    .c create line [list $c5 $y0 $c5 $y3]
    
    incr CURSORY $LS(fixed)
    
    set list [split $list \n]
    foreach l $list {
        if {[llength $l] == 0} continue
        if {[llength $l] != 5} {return -code error "Ligne \"$l\""}
        set qte [lindex $l 0]
        set des [lindex $l 1]
        set pu [lindex $l 2]
        set rem [lindex $l 3]
        set pn [lindex $l 4]
        set pht [expr {$qte*$pn}]
        set tot [expr {$tot+$pht}]
        
        set CURSORX [expr {$c1 - 2}]
        putRightFixedText .c $qte
        set CURSORX [expr {$c1 + 6}]
        putHText .c $des
        set CURSORX [expr {$c3 - 2}]
        putRightFixedText .c [string map {. ,} [format %.2f $pu]]
        set CURSORX [expr {$c4 - 2}]
        putRightFixedText .c $rem
        set CURSORX [expr {$c5 - 2}]
        putRightFixedText .c [string map {. ,} [format %.2f $pht]]
        incr CURSORY $LS(fixed)
    }    
    
    set CURSORY $y3
    set CURSORX $c2
    incr CURSORX 2
    putHTextI .c {Montant total net H.T.}
    set CURSORX [expr {$c5 - 2}]
    putRightFixedText .c [string map {, .} [format %.2f $tot]]
    set CURSORX $c0
    incr CURSORY [expr {2*$LS(tiny)}]
    putHTextTiny .c {NB : Vous devez fournir un devis original (non fax�), en deux ou trois exemplaires pour toute commande d'�quipement ou de r�paration.}
    set CURSORX $c0
    incr CURSORY $LS(tiny)
    putHTextTiny .c {NB : En cas de r�paration, le devis devra comporter le nb. d'heures travaill�es, le taux horaire de la main d'oeuvre et le d�tail des pi�ces.}
    set CURSORX $c0
    incr CURSORY $LS(tiny)
    putHTextTiny .c {En cas de commande hors march�, vous devez joindre une attestation de commande hors march�.}
}


set liste {
1  {797-972 bobine 100m}           28.54   9%    25.97
1  {797-984 bobine 100m}           28.54   9%    25.97
1  {797-996 bobine 100m}           28.54   9%    25.97
1  {797-010 bobine 100m}           28.54   9%    25.97
1  {798-022 bobine 100m}           28.54   9%    25.97
1  {798-009 bobine 100m}           29.42   9%    26.77
10 {105-927 buse}                   5.14   9%     4.68    
1  {419-278 soudure D620}          12.42   9%    11.30 
4  {635-297 ventilateur 80mm}      20.12   9%    73.24
1  {105-926 pompe}                 20.90   9%    19.02
10 {803-303 eurocarte}             31.08   9%    28.28
1  {419-503 soudure SnPbAg}        44.58   9%    40.57
1  {145-461 support}               64.23   9%    58.45
20 {317-8912 tube fluo 35W}         5.56   9%     5.06
16 {108-581 starter}                6.14   9%     5.59
}

printlist $liste



button .b
pack .b

tkwait visibility .b

.c postscript -fontmap PSFONT -file /tmp/popo

after 2000 {exec pageview /tmp/popo}






