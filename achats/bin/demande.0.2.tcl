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
set FOURNISSEUR LCDI
set ADRESSE {192 rue de Charenton 75012 Paris}
set PHONE {1 4343 2440, 1 4343 1004}
set FAX {1 4346 1317}


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

putHTextI .c {Liée à un projet Européen / contrat national / action incitative ou programme : }
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

putHTextI .c {Fonctionnement, Équipement, Réparation sur contrat : }
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
    putHTextI .c {Hors marché}
} else {
    putHTextI .c {Sur marché No : }
    putHText .c $MARCHE
}

set CURSORX 20
incr CURSORY [expr {$LS(normal)}]

if {$ADRESSE != {}} {
    putHTextI .c {Adresse : }
    putHText .c $ADRESSE
}
if {$PHONE != {}} {
    putHTextI .c {Téléphone : }
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
    putHTextI .c {Qté}
    set CURSORX $c1
    incr CURSORX 2
    putHTextI .c {Désignation du matériel}
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
        # set pn [lindex $l 4]
        set pn $pu
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
    putHTextTiny .c {NB : Vous devez fournir un devis original (non faxé), en deux ou trois exemplaires pour toute commande d'équipement ou de réparation.}
    set CURSORX $c0
    incr CURSORY $LS(tiny)
    putHTextTiny .c {NB : En cas de réparation, le devis devra comporter le nb. d'heures travaillées, le taux horaire de la main d'oeuvre et le détail des pièces.}
    set CURSORX $c0
    incr CURSORY $LS(tiny)
    putHTextTiny .c {En cas de commande hors marché, vous devez joindre une attestation de commande hors marché.}
}


set liste {
    4 {carte MSI Pro2 (DDR)}           145. {} {}
    4 {proc. AMD XP 1800+ (Box)}       245. {} {}
    8 {mém. DDR 256 MO}                  86. {} {}
    4 {DD Seagate 40 GO (7200t/min)}     140. {} {}
    2 {carte video AGP 8MO}              25. {} {}
    2 {carte ATI Radeon VE 64 MO}        75. {} {}
    4 {lecteur 1.44 Sony}                14. {} {}
    2 {boitier desktop ATX}              83. {} {}
    2 {boitier moyen tour 811}           44. {} {}
    2 {clavier logitech D}               18. {} {}
    2 {souris logitech M}                15. {} {}
    2 {moniteur Iiyama LS 902}          332. {} {}
    2 {DVD Memorex IDE}                  79. {} {}
    1 {graveur Memorex 24/10/40 IDE}    118. {} {}
    5 {carte réseau 3COM PC 10/100}      49. {} {}
    2 {switch Soho 8 ports}               60. {} {}
    1 {commutateur switch 4 voies}        35. {} {}
    6 {cables PS2 (switch)}               45. {} {}
    3 {cables VGA (switch)}               45. {} {}
}

printlist $liste



button .b
pack .b

tkwait visibility .c

.c postscript -fontmap PSFONT -file /tmp/popo

after 2000 {exec pageview /tmp/popo}
