#!/usr/local/bin/tclsh

package require http
package require opt

::http::config -proxyhost freeway -proxyport 8080

namespace eval brevets {}

set DEBUG 1

##############################

proc ::http::Progress {args} {
    puts -nonewline stderr . ; flush stderr
}

#############################################

proc ::http::copy { url file {chunk 4096} } {
    
    puts {}
    puts -nonewline [list $url $file]

    if {[file exists $file]} {
        puts " ...on saute (existe déjà)"
        return
    } else {
        puts ""
    }
    lock $file
    set out [open $file w]
    set token [geturl $url -channel $out -progress ::http::Progress \
        -blocksize $chunk]
    close $out
    unlock $file
    # This ends the line started by http::Progress
    puts stderr ""
    upvar #0 $token state
    set max 0
    foreach {name value} $state(meta) {
        if {[string length $name] > $max} {
            set max [string length $name]
        }
        if {[regexp -nocase ^location$ $name]} {
        # Handle URL redirects
            puts stderr "Location:$value"
            return [copy [string trim $value] $file $chunk]
        }
    }
    incr max
    foreach {name value} $state(meta) {
        puts [format "%-*s %s" $max $name: $value]
    }
    return $token
}

proc ::http::lock {file} {
    set lock $file.lock
    if {[file exists $lock]} {
        error "$lock exists"
    }
    set f [open $lock w]
    puts $f [list [info hostname] [pid]]
    close $f
}

proc ::http::unlock {file} {
    set lock $file.lock
    file delete $lock
}

proc getPage.new {adresse numero page scale chunk} {
    set gifFile $numero.E-p${page}.gif
    if {[file exists $gifFile]} {
        puts "$gifFile existe déjà"
        return
    }
    set ltmp [string length $numero]
    set n1 [string range $numero [expr $ltmp - 2] end]
    set n2 [string range $numero 0 1]
    set p $adresse/fcgi-bin/viewpat.cmd/$numero?PAGE=$page
    
    if {$page == 1} {
#        set scale 0.72
        set scale 0.35
    } else {
        ::http::copy $p $numero.Z-p${page}.html $chunk
#    file delete $numero.Z-p${page}.html
        set scale 0.35
    }
    
    set p $adresse/any2html.gifcache/${numero}.tif.${page}.s${scale}.r0.gif
    ::http::copy $p $gifFile $chunk
}

proc ::brevets::getPageV2 {adresse numero page chunk} {
    set gifFile $numero.E-p${page}.gif
    if {[file exists $gifFile]} {
        puts "$gifFile existe déjà"
        return
    }
    set ltmp [string length $numero]
    set p $adresse/cgi-bin/viewpat.cmd/${numero}__?PAGE=$page
    set f $numero.Z-p${page}.html
    
    if {[file exists $f]} {
        file delete $f
    }

    ::http::copy $p $f $chunk

    set c [::brevets::readFile $f]
#    file delete $f

    set regexp "<IMG SRC=\"(/gifcache/\[^\"\]*)\""
    if {[regexp $regexp $c dummy p]} {
        ::http::copy ${adresse}$p $gifFile $chunk
    } else {
        puts stderr "\n          ERREUR : cannot regexp $regexp on $f"
        file rename -force -- $f $f.bad
    }
    if {$page != 2} {
        file delete $f
    }
}

proc ::brevets::getNumberOfPages {numero} {
    set text [::brevets::readFile $numero.A-details+claims.html]
    set regexp {.*View[}
    append regexp " \n"
    append regexp {]+Images \(([0-9]+) pages\).*}
    if {[regexp $regexp $text dummy nPages] != 0} {
puts stderr "A : $nPages"
        return $nPages
    }
    set text [::brevets::readFile $numero.Z-viewpat.html]
    if {[regexp {of <STRONG>([0-9]+)</STRONG>} $text dummy nPages] != 0} {
puts stderr "Z : $nPages"
        return $nPages
    }
    set text [::brevets::readFile $numero.Z-p2.html]
    if {[regexp {of <STRONG>([0-9]+)</STRONG>} $text dummy nPages] != 0} {
puts stderr "Zp2 : $nPages"
        return $nPages
    }
    error "$numero : pas de nombre de pages ?"
}

##########################
# récupération du brevet #
##########################

proc ::brevets::getBrevet {adresse numero scale chunk} {

    # capture du fichier $numero.A-details+claims.html

    set f $numero.A-details+claims.html
    ::http::copy $adresse/details?pn=${numero}__&s_clms=1 $f $chunk

    # si le brevet n'est pas répertorié dans le répertoire ../LINKS on le répertorie

    if {![file exists ../LINKS/$numero]} {
        exec ln -s ../[file tail [pwd]]/$f ../LINKS/$numero
    }

    ::brevets::genereAbsRef $adresse $f
        
    set f $numero.C-report.html
    ::http::copy $adresse/patlist?&uref_pno=${numero} $f $chunk

    ::brevets::genereAbsRef $adresse $f

    set f $numero.Z-viewpat.html
    ::http::copy $adresse/cgi-bin/viewpat.cmd/${numero}__ $f $chunk

    set nPages [::brevets::creeFichierPages $numero]
    if {$nPages != 0} {
        puts stderr "$nPages pages"
        for {set page 1} {$page <= $nPages} {incr page} {
            ::brevets::getPageV2 $adresse $numero $page $chunk
        }
    } else {
        puts stderr "pas de pages...on se débrouille (c'est écrit page 2)"
        ::brevets::getPageV2 $adresse $numero 1 $chunk
        ::brevets::getPageV2 $adresse $numero 2 $chunk
        set nPages [::brevets::creeFichierPages $numero]
        puts stderr "$nPages pages en fait"
        for {set page 3} {$page <= $nPages} {incr page} {
            ::brevets::getPageV2 $adresse $numero $page $chunk
        }
    }
}

################################
# utilitaires de mise au point #
################################


proc ::brevets::oldToNew {repertoire fichier} {

puts -nonewline stderr "*** $fichier"
    set flOri [::brevets::readFile $fichier]

    set fromTo [list]
    lappend fromTo "\"./" "\"../$repertoire/"
    lappend fromTo "=./" "=../$repertoire/"
    set fl [chText $flOri $fromTo]
    
    if {$fl != $flOri} {
puts stderr "-> Modified"
        safeWriteFile $fichier $fl
    } else {
puts stderr "-> Not modified"
    }
}


proc ::brevets::oldToNewAll2 {repertoire} {
    cd $repertoire
    foreach f [glob *.html] {
puts stderr $f
        genereAbsRef http://www.patents.ibm.com $f
    }
}

proc ::brevets::oldToNewAll {repertoire} {
    cd $repertoire
    foreach f [glob *.html] {
        oldToNew $repertoire $f
    }
}

################################
################################


proc ::brevets::quoteRegexpChars {text} {
# A VOIR
    set regexpChars {[.*\^$+|()?}
    set regexp ""
    foreach c [split $regexpChars {}] {
        append regexp \\ $c
    }
    set regexp "(\[$regexp\]|\])"
    set newText ""
    while {[regexp -indices -- $regexp $text indices]} {
        foreach {i1 i2} $indices {}
        append newText [string range $text 0 [expr $i1 - 1]] \
                       \\ \
                       [string range $text $i1 $i2]
        set text [string range $text [expr $i2 + 1] end]
    }

    append newText $text
    return $newText
}

proc ::brevets::chText {text fromToList} {
    
    puts stderr [list DEBUG: chText text $fromToList]
    set froms [list]
    foreach {f t} $fromToList {
        lappend froms [quoteRegexpChars $f]
        set fromTo($f) $t
    }
    
    set regexp ([join $froms |])

# puts stderr "regexp = $regexp"

    set newText ""
    while {[regexp -indices -- $regexp $text indices]} {
        foreach {i1 i2} $indices {}
        set from [string range $text $i1 $i2]

        set to $fromTo($from)
        append newText [string range $text 0 [expr $i1 - 1]] $to
                       
        set text [string range $text [expr $i2 + 1] end]
    }

    append newText $text
    return $newText
}


proc ::brevets::chToLocalNumHref {text} {
    set fromTo(/details?pn10=) {.A-details+claims.html}
    set fromTo(/details?patent_number=) {.A-details+claims.html}
    set fromTo(/report?patent_number=) {.C-report.html}
    set fromTo(/viewpat.cmd/) {.D-pages.html}
    
    # les références 
    set regexp {(HREF=[ 	]*"?)(http://[^">]*)}
    set froms [list]
    foreach f [array names fromTo] {
        lappend froms [quoteRegexpChars $f]
    }
    append regexp ([join $froms |])
    unset froms
    append regexp {([^">]*)}

    set newText ""
    while {[regexp -indices -- $regexp $text dummy ia ioldA ib ic]} {
        foreach {ib1 ib2} $ib {}
        foreach {ic1 ic2} $ic {}
        set tout     [string range $text [lindex $dummy 0] [lindex $dummy 1]]
        set type     [string range $text [lindex $ia    0] [lindex $ia    1]]
        set oldRootA [string range $text [lindex $ioldA 0] [lindex $ioldA 1]]
        set oldRef   [string range $text [lindex $ib    0] [lindex $ib    1]]
	set numero   [string range $text [lindex $ic    0] [lindex $ic    1]]
	if {![regexp {^([^_]+)_*$} $numero tout numero] &&\
	    ![regexp {^([^&]+)&s_all=1$} $numero tout numero]} {
	    error "chToLocalNumHref: CANNOT regexp $numero"
	}

	puts  [list DEBUG $tout -> $type $oldRootA $oldRef $numero]
	unset tout

        if {$numero == {}} {
            set ref $oldRootA$oldRef
            puts "BAD $ref"
        } elseif {[file exists ../LINKS/$numero]} {
            set ou [file dirname [file readlink ../LINKS/$numero]]
            set quoi $fromTo($oldRef)
            if {$quoi == ".A-details.html"} {
                set ref ../LINKS/$numero
            } else {
                set ref $ou/$numero$quoi
            }
            puts "OUI $oldRootA -> $ref"
        } else {
            set ref $oldRootA$oldRef$numero
            puts "NON $ref (numero=$numero)"
        }
        
        append newText [string range $text 0 [expr [lindex $ia 0] - 1]] $type $ref
        set text [string range $text [expr $ic2 + 1] end]
    }
    unset regexp fromTo

    append newText $text
    unset text

    # puts [list LOCALS = [info locals]]
    return $newText
}




proc ::brevets::chToLocalImRef {text} {
    
    set regexp {(IMG[ 	]*SRC[ 	]*=[ 	]*"?)(http://[^/]+/)}

    set newText ""
    while {[regexp -indices -- $regexp $text dummy ia ib]} {
        foreach {ia1 ia2} $ia {}
        foreach {ib1 ib2} $ib {}
        set type [string range $text $ia1 $ia2]
        set oldRef [string range $text $ib1 $ib2]
        set newRef ../LINKS/
        set ref $newRef
        
        append newText [string range $text 0 [expr $ia1 - 1]] $type $ref
        set text [string range $text [expr $ib2 + 1] end]
    }

    append newText $text
    return $newText
}

# lecture sans \n, écriture avec.

proc ::brevets::readFile {fichier} {
    if {[catch {open $fichier r} f]} {
        puts stderr $f
        return {}
    }
    set fl [read -nonewline $f]
    close $f
    return $fl
}

proc ::brevets::safeWriteFile {fichier text} {
    if {[file exists $fichier]} {
        if {![file exists poubelle]} {
            file mkdir poubelle
        }
        set ibak 0
        while {[file exists poubelle/$fichier.bak#$ibak]} {
            incr ibak
        }
        file rename $fichier poubelle/$fichier.bak#$ibak
    }
    set f [open $fichier w]
    puts $f $text
    close $f
}

proc ::brevets::creeFichierPages {numero} {
    set fichier $numero.D-pages.html
    if {[catch {getNumberOfPages $numero} nPages]} {
        return 0
    }
    if {[file exists $fichier]} {
        return $nPages
    }
    set text {<HTML>
<HEAD>
   <TITLE>brevet }
   append text $numero
   append text " : "
   append text $nPages
   append text " pages"
   append text {</TITLE>
   <META NAME="GENERATOR" CONTENT="getPat.tcl">
</HEAD>
<BODY>}
    append text \n\n
    for {set i 1} {$i <= $nPages} {incr i} {
        append text {<IMG SRC="}
        append text $numero.E-p$i.gif
        append text {">}
        append text \n
    }
        append text {
</BODY>
</HTML>}
    append text \n
    safeWriteFile $fichier $text
    return $nPages
}

proc ::brevets::getTitle {numero} {
    set text [::brevets::readFile $numero.A-details+claims.html]
    # set regexp [join [list {>[ 	]*} $numero {[ 	]*:([^<]*)}] {}]
    set regexp {<TITLE>([^<]*)}
    if {[regexp $regexp $text dummy titre]} {
        set titre [string trim $titre \n"]
    } else {
        set titre ""
    }
    return $titre
}

proc ::brevets::creeIndex {} {
    set numeros [::brevets::listPatents]
    set text {<HTML>
<HEAD>
   <TITLE>index des brevets disponibles localement}
   append text \n
   append text {</TITLE>
   <META NAME="GENERATOR" CONTENT="getPat.tcl">
</HEAD>
<BODY>}
    append text \n\n


    foreach numero $numeros {
        append text {<A HREF="}
        append text $numero.A-details+claims.html
        append text {">}
        append text $numero
        append text {</A>}
        append text " :\n"
        append text "    "
        append text [::brevets::getTitle $numero]
        append text {<BR>}
        append text \n
    }
        append text {
</BODY>
</HTML>}
        append text \n\n
    safeWriteFile 0-liste.html $text
}



proc ::brevets::genereAbsRef {adresse fichier} {

    set flOri [::brevets::readFile $fichier]

    set fromTo [list]
    lappend fromTo "HREF=\"/"      "HREF=\"${adresse}/"
    lappend fromTo "HREF=/"        "HREF=${adresse}/"
    lappend fromTo "HREF =/"       "HREF=${adresse}/"
    lappend fromTo "SRC=\"/"       "SRC=\"${adresse}/"
    set fl [chText $flOri $fromTo]
    
    if {$fl != $flOri} {
        safeWriteFile $fichier $fl
    }
}

#####################


#####################

proc ::brevets::genereLocalRef {fichier} {
    set flOri [::brevets::readFile $fichier]
    set fl [::brevets::chToLocalNumHref $flOri]
    set fl [::brevets::chToLocalImRef $fl]
    if {$fl != $flOri} {
        safeWriteFile $fichier $fl
    }
}

proc ::brevets::generePPFromP {adresse fichier} {

    set ici [file tail [pwd]]
    set flOri [::brevets::readFile $fichier]

    set fromTo [list]
    lappend fromTo {"./images}      {"../LINKS/images}
    lappend fromTo {"./}      "\"../$ici/"
    lappend fromTo {=./}      "=../$ici/"
    set fl [chText $flOri $fromTo]
    
    if {$fl != $flOri} {
        safeWriteFile $fichier $fl
    }
}

proc ::brevets::retrouve {fichier} {
    set bak poubelle/$fichier.bak#0
    if {![file exists $bak]} {
        error "le fichier $bak n'existe pas"
    }
    exec /bin/cp -p $bak $fichier
}

proc ::brevets::connecteLocalement {adresse} {

    puts [list DEBUG ::brevets::connecteLocalement $adresse]

    ::brevets::readRefs refA.dat A-details+claims.html
    ::brevets::readRefs refC.dat C-report.html

    # construction de la liste des fichiers à balayer

    if {[catch {glob 0-*.html} html1]} {
        set html1 {}
    }
    if {[catch {glob *\[ABCD\]*.html} html2]} {
        set html2 {}
    }
    set html2 [lsort -decreasing $html2]
    set html [concat $html1 $html2]

    # ::brevets::genereAbsRef a été fait au cours du chargement
    # pour les fichiers du groupe html2

    foreach f $html1 {
        ::brevets::genereAbsRef $adresse $f
    }

    foreach f $html {
        ::brevets::genereLocalRef $f
    }
}

proc ::brevets::listGifs {brevet} {
    set numeros [list]
    foreach f [glob $brevet.E-p*.gif] {
        if {[regexp "${brevet}.E-p(\[0-9\]+).gif" $f dummy numero]} {
            lappend numeros $numero
        } else {
            puts stderr "Cannot regexp $f"
        }
    }
    set numeros [lsort -integer $numeros]
    set gifs [list]
    foreach numero $numeros {
       lappend gifs $brevet.E-p${numero}.gif
    }
    return $gifs
}

proc ::brevets::printBrevet {brevet n} {
    set gifs [listGifs $brevet]
    if {$n == 1} {
        set ps [exec readgif -print $gifs 2>@stderr]
    } elseif {$n == 2} {
        set ps [exec readgif -print -2up $gifs 2>@stderr]
    }
    return $ps
}

proc ::brevets::cleanGif {} {
    set badGifs [exec readgif -verif 2>@stderr]
    foreach f $badGifs {
        if {[regexp {(^.*).E-p[0-9]+.gif} $f dummy brevet]} {
            set BAD($brevet) {}
            set ibad 0
            while {[file exists $f.bad#$ibad]} {
                incr ibad
            }
            file rename $f $f.bad#$ibad
        } else {
            puts stderr "Cannot regexp $f"
        }
    }
    set bads [lsort [array names BAD]]
    foreach b $bads  {
        file delete $b.Z-viewpat.html
    }
    return $bads
}

proc ::brevets::listInexistentIP {} {
    set patents [::brevets::listPatents]
    set patents [lsort $patents]
    set inexistants [list]
    foreach numero $patents {
        if {![file exists $numero.D-pages.html]} {
            lappend inexistants $numero
        } else {
            set n [getNumberOfPages $numero]
            for {set i 1} {$i<=$n} {incr i} {
                if {![file exists $numero.E-p$i.gif]} {
                    lappend inexistants $numero
                    break
                }
            }
        }
    }
    return $inexistants
}

proc ::brevets::listPatents {} {
    set patents [list]
    foreach f [glob *.A-details+claims.html] {
        if {[regexp {(^.*).A-details\+claims\.html} $f dummy brevet]} {
            lappend patents $brevet
        }
    }
    return [lsort $patents]
}

proc ::brevets::existeAilleurs {numero} {
    set ici ../[file tail [pwd]]
    set freres [list]
    foreach f [glob ../*] {
        if {[file isdir $f] && $f != $ici} {
            lappend freres $f
        }
    }
    set existants [list]
    foreach d $freres {
        if {![catch {glob ${d}/${numero}.\[A-Z\]-*} f]} {
            set existants [concat $existants $f]
        }
    }
    set existants [lsort $existants]
    return $existants
}

proc ::brevets::getRefs {fichier} {
    puts -nonewline [list DEBUG ::brevets::getRefs]
    puts -nonewline " $fichier ->"
    set text [::brevets::readFile $fichier]
#    details?patent_number=3867662">
#    ../hbt/5051372.A-details.html
#    ../hbt/5051372
    set regexp {/([^/.]*).A-details.html|details\?patent_number=([^">]*)}
    while {[regexp -indices -- $regexp $text tout i j]} {
        foreach {i1 i2} $i {}
        foreach {j1 j2} $j {}
        if {$j2 != -1} {
            set i1 $j1
            set i2 $j2
        }

        set r [string range $text $i1 $i2]
        if {$r != {}} {
            set references($r) {}
puts -nonewline stderr " $r"
        }
        set text [string range $text [expr $i2 + 1] end]
    }
    set retour [lsort [array names references]]
puts stderr ""
    return $retour
}

######################################################
# Utilisation :
#   ::brevets::readRefs refA.dat A-details+claims.html
#   ::brevets::readRefs refC.dat C-report.html
# Le fichier refA.dat contient la liste des références des fichiers A-details+claims.html
# Le fichier refC.dat contient la liste des références des fichiers C-report.html
# C'est ::brevets::getRefs qui fait le travail
######################################################

proc ::brevets::readRefs {fichier typFich} {

    puts [list DEBUG: ::brevets::readRefs $fichier $typFich]

    # On a récupéré "A-details+claims.html", mais les références sont "A-details.html"

    if {$typFich == "A-details+claims.html"} {
	set typFich "A-details.html"
    }

    set debut [clock seconds]

    # le tableau REFS est le décalque du fichier

    if {[file exists $fichier]} {
        set dateFichier [file mtime $fichier]
        foreach l [split [::brevets::readFile $fichier] \n] {
            set REFS([lindex $l 0]) [lindex $l 1]
        }
    } else {
        set dateFichier 0
    }

    # Construction de la liste des fichiers à balayer
    
    if {[catch  {glob *.$typFich} fichiers]} {
        set fichiers {}
    }

    # on balaye les fichiers plus récents que le fichier refX.dat
    # la procédure ::brevets::getRefs récupère les références

    foreach f $fichiers {
        if {[file mtime $f] >= $dateFichier} {
            set references [::brevets::getRefs $f]
            if {![regexp ^(.*)\.$typFich\$ $f tout numero]} {
                error "ERREUR ::brevets::readRefs -> Cannot regexp \"$f\" as .$typFich file"
            }
            set REFS($numero) $references
        }
    }

    # écriture du fichier à partir du tableau REFS

    set lignes ""
    foreach numero [lsort [array names REFS]] {
        append lignes [list $numero $REFS($numero)]
        append lignes \n
    }
    ::brevets::safeWriteFile $fichier $lignes
    exec touch -t [clock format $debut -format %Y%m%d%H%M.%S] $fichier
}

::tcl::OptProc ::brevets::getArgsAndExecute {
    {-force "charge même si le brevet existe dans un répertoire frère"}
    {-adresse -string "http://www.patents.ibm.com"}
    {-chunk -int 256 "taille du bloc de transfert"}
    {-scale -float 0.35 "échelle des pages gif"}
    {-cleanGif "recharge les pages GIF incomplètes"}
    {-listPatents "liste dans le but de recharger ce qui manque"}
    {-listInexistentIP "liste les brevets dont le fichier D n'existe pas"}
    {-creeIndex "cree l'index"}
    {-oldToNew "Cf. fab"}
    {-rendLocal "modifie les pages html pour les connecter entre elles"}
    {-listGifs "imprime dans l'ordre la liste des pages GIF"}
    {-print "pages GIF -> PostScript"}
    {-2up "en plus de -print, imprime 2 pages sur une"}
    {-fichierAdefaillant "essaye de compter le nombre de pages autrement"}
    {?numero? -string {} "numero de brevet"}
    } {
#    puts stderr {}
#    foreach v [info locals] {
#        puts stderr [format "%14s : %s" $v [set $v]]
#    }
#    puts stderr {}
    if {$numero != {} && $rendLocal} {
        return {On ne peut actuellement récupérer un brevet et appeler -rendLocal
Il ne faut utiliser -rendLocal que lorsque toute construction de fichier html est arêtée
On mettra en place un jour des verrous qui éviteront ces interdictions...
}
    }
    if {$oldToNew} {
        oldToNewAll $numero
        exit 0
    }
    if {$numero == {} && !$rendLocal && !$creeIndex && !$cleanGif && !$listPatents && !$listInexistentIP} {
        return "utilisez l'option -help"
    }
    if {$numero != {}} {
        if {$listGifs} {
            puts [::brevets::listGifs $numero]
        } elseif {$print} {
            if {$2up} {
                puts [::brevets::printBrevet $numero 2]
            } else {
                puts [::brevets::printBrevet $numero 1]
            }
        } else { 
            if {$force || ([set existants [::brevets::existeAilleurs $numero]] == {})} { 
                ::brevets::getBrevet $adresse $numero $scale $chunk
            } else {
                puts stderr "Existent ailleurs : $existants"
                puts stderr "\nUtilisez l'option -force"
            }
        }
    }
    if {$creeIndex} {
        ::brevets::creeIndex
    }
    if {$listInexistentIP} {
        puts stderr "Voici la liste des brevets sans originaux"
        puts [::brevets::listInexistentIP]
    }
    if {$rendLocal} {
        ::brevets::connecteLocalement $adresse
    }
    if {$cleanGif} {
        set bads [::brevets::cleanGif]
        if {$bads != {}} {
            puts stderr "\nATTENTION : Recharger les brevets suivants :"
            puts $bads
        }
    }
    if {$listPatents} {
        puts stderr "Voici la liste des brevets :"
        puts [::brevets::listPatents]
    }
}

if {[catch {eval ::brevets::getArgsAndExecute $argv} retour]} {
    puts $retour
} else {
    puts $retour
}


set exemples {

Ce qui se passe sur le serveur http://www.patents.ibm.com

intro+claims     http://www.patents.ibm.com/details?pn=US05512764__&s_clms=1
les referenceurs http://www.patents.ibm.com/patlist?&uref_pno=US05512764
la premiere image http://www.patents.ibm.com/cgi-bin/viewpat.cmd/US05512764__
les suivantes doivent être mises dans la cache par
                  http://www.patents.ibm.com/cgi-bin/viewpat.cmd/us05512764__?PAGE=2
elles sont        http://www.patents.ibm.com/gifcache/US05512764__.tif.2.s0.35.r0.gif
                  http://www.patents.ibm.com/gifcache/US05512764__.tif.2.s0.52.r0.gif
                  http://www.patents.ibm.com/gifcache/US05512764__.tif.2.s0.78.r0.gif
334k              http://www.patents.ibm.com/gifcache/US05512764__.tif.2.s1.17.r0.gif

http://www.patents.ibm.com/fcgi-bin/any2html?FILENAME=%2Fcache%2F65%2F27%2FUS05512765__.tif&PAGE=15&SCALE=0.78
http://www.patents.ibm.com/fcgi-bin/any2html?FILENAME=%2Fcache%2F65%2F27%2FUS05512765__.tif&PAGE=15&SCALE=0.35
l'échelle peut-être 0.50

ex:
http://www.patents.ibm.com/cgi-bin/viewpat.cmd/us05413764__?PAGE=2
http://www.patents.ibm.com/gifcache/US05413764__.tif.2.s0.35.r0.gif
http://www.patents.ibm.com/fcgi-bin/any2html?FILENAME=%2Fcache%2F64%2F37%2FUS05413764__.tif&PAGE=2&USER_HTML=%253CA%2BHREF%253D%2Forder%253Fpn%3Dus05413764__%253EOrderPatent%253C%2FA%253E&SCALE=0.52
#########
#########
Sous csh :
#########
#########

#############################################################
rechargement de tout ce qui manque (lourdingue mais efficace)
#############################################################
    
foreach p (`getpatent -listPatents`)
echo $p
getpatent $p &
end

#############################################
nettoyage et rechargement des gifs incomplets :
#############################################

foreach p (`getpatent -cleanGif`)
echo $p
getpatent $p &
end

#####################################################
impression du brevet 12345678 sur l'imprimante locale
#####################################################

getpatent -print2 12345678 | lp

##########################################
impression dd tous les brevets sur BatBL
##########################################

foreach p (`getpatent -listPatents`)
echo $p
getpatent -print2 $p | lp -d BatBL
end

}
