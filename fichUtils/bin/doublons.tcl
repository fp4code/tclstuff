#!/bin/sh

# the next line restarts using tclsh \
#exec tclsh "$0" "$@"

# 26 décembre 2000 (FP)
# tentative de nettoyage des fichiers
# 5 janvier 2001 usage en sens inverse, restriction sur A
# 7 octobre 2001 (FP) mise à jour


# création du fichiers des checksums

set csh {
find /home/fab/A -type f -exec md5sum {} \; >! /home/fab/Z/md5sum.A
find /home/fab/A.2001.09.28/A -type f -exec md5sum {} \; >> /home/fab/Z/md5sum.A
}


catch {unset F}

set f [open /home/fab/Z/md5sum.A r]
foreach l [split [read -nonewline $f] \n] {
    lappend F([string range $l 0 31]) [string range $l 34 end]
}
close $f

foreach code [array names F] {
    if {[llength $F($code)] == 1} {
	unset F($code)
    }
}

# le tableau F contient maintenant pour chaque index clé md5 la liste des fichiers 

puts "DOUBLONS DE NOM DIFFERENT"
foreach code [array names F] {
    set ref [lindex $F($code) 0]
    set reste [lrange $F($code) 1 end]
    set nref [file tail $ref]
    set diff 0
    foreach r $reste {
	if {$nref != [file tail $r]} {
	    incr diff
	}
    }
    if {$diff} {
	puts $code
	foreach f $F($code) {
	    puts $f
	}
	puts {}
    }
}
####################
set HELP(sameinit) {
    - Retourne 1 si le début de la chaine $string
    est identique à la chaine $ini ;
    le reste est retourné dans la variable de nom ${reste}
    - Retourne 0 sinon
}
###################################
proc sameinit {string ini &reste} {
    upvar ${&reste} reste
    set len [string length $ini]
    if {[string compare $ini [string range $string 0 [expr {$len - 1}]]] == 0} {
	set reste [string range $string $len end]
	return 1
    }
    return 0
}

##########################
set HELP(samethendelete) {
    ${&ensemble} est le nom d'un ensemble de noms de fichiers 
    $f est un nom de fichiers
    $v1 et $v2 sont des noms de répertoires
    - Si $f est dans un sous-répertoire de $v1
    et si on retrouve ce fichier relativement à $v2
    dans l'ensemble, on efface $f comme fichier
    et comme élément de l'ensemble.
    On retourne 1 si l'effacement a eu lieu sans erreur,
    0 dans tous les autres cas
}
#########################################
proc samethendelete {&ensemble f v1 v2} {
    upvar ${&ensemble} ensemble
    
    # set idem [sameinit $f $v1 reste]
    # puts $idem
    # if $idem {
    #    puts stderr "ensemble($v2$reste) -> [info exists ensemble($v2$reste)]"
    # } 

    if {[sameinit $f $v1 reste] && [info exists ensemble($v2$reste)]} {
	set err [catch {file delete $f} message]
	puts -nonewline stderr "file delete $f: "
	if {!$err} {
	    unset ensemble($f)
	    puts stderr OK
	    return 1
	} else {
	    puts stderr $message
	    return 0
	}
    }
    return 0
}

##############################
set HELP(sameNAMEthendelete) {
    ${&ensemble} est le nom d'un ensemble de noms de fichiers 
    $f est un nom de fichiers
    $v1 et $v2 sont des noms de répertoires
    - Si $f est un fichier d'un sous-répertoire de $v1
    et si $fexiste dans un sous-répertoire quelconque de $v2
    on efface $f comme fichier
    et comme élément de l'ensemble.
    On retourne 1 si l'effacement a eu lieu sans erreur,
    0 dans tous les autres cas.
}
#############################################
proc sameNAMEthendelete {&ensemble f v1 v2} {
    upvar ${&ensemble} ensemble
    if {![sameinit $f $v1 dummy]} {
	return 0
    }
    set tail [file tail $f]
    set exists [array names ensemble ${v2}*${tail}]
    if {$exists == {}} {
	return 0
    }
    set err [catch {file delete $f} message]
    puts -nonewline stderr "file delete $f, because $exists: "
    if {!$err} {
	unset ensemble($f)
	puts stderr OK
	return 1
    } else {
	puts stderr $message
	return 0
    }
}


##############################
foreach code [array names F] {
    set liste $F($code)
    catch {unset ensemble}
    foreach f $F($code) {
	set ensemble($f) {}
    }
    # ensemble st l'ensemble des noms de fichier de même code md5
    set decr 0
    foreach f [array names ensemble] {
	if {[samethendelete ensemble $f /home/fab/A.2001.09.28/A/ /home/fab/A/]} {
	    incr decr
	    continue
	}
    }
    set nreste [llength [array names ensemble]]
    if {$nreste <= 1} {
	unset F($code)
    } elseif {$decr} {
	set F($code) [array names ensemble]
    }
}

foreach code [array names F] {
    puts $code
    foreach f $F($code) {
	puts $f
    }
    puts {}
}

exit

set csh {
find /home/fab/A.2001.09.28/A -type l -exec rm {} \; -print
find /home/fab/A.2001.09.28/A -type d -depth -exec rmdir {} \; -print

find /home/fab/2000.12.22/FromCD -type d -exec rmdir {} \; -print
find /home/fab/2000.12.22/FromCD -type d -exec rmdir {} \; -print

cd /home/fab/2000.12.22/FromCD

set err [catch {exec find A -type f -print} fichiers]

foreach f [split $fichiers \n] {
    set new /home/fab/$f
    if {![file exists $new]} {
	set dir [file dirname $new]
	if {![file exists $dir]} {
	    if {[catch {file mkdir $dir} message]} {
		puts stderr "\"file mkdir $dir\": $message"
		puts stderr $errorCode
		continue
	    }
	}
	if {[catch {file rename $f $new} $message]} {
	    puts stderr "\"file rename $f $new\": $message"
	    puts stderr $errorCode
	}
    }
}

find /home/fab/A.2001.09.28/A -name ".#*" -exec rm -i {} \;
find /home/fab/A.2001.09.28/A -type l -exec rm {} \;
find /home/fab/A.2001.09.28/A -type f -name "*~" -exec rm -i {} \; -print
find /home/fab/A.2001.09.28/A -type d -depth -exec rmdir {} \; -print
ls




cd /home/fab/2000.12.22/FromCD
set err [catch {exec find A -type f -print} fichiers]
foreach f [split $fichiers \n] {
    puts -nonewline stderr $f:
    if {[catch {exec tkdiff $f /home/fab/$f} message]} {
	puts stderr $message
    } else {
	puts stderr OK
    }
}
ls
