#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

set INFO(phone.tcl) {
    26 novembre 2001 (FP) pas d'erreur si rien trouve

    18 décembre 2002 (FP) dion n'est pas dans "fico"
                          et certains fichiers sont non lisibles
                          -> exec cat plante et retourne les lignes des premiers fichiers

}

if {$argc == 0} {
    puts {usage: phone -edit [perso] :	edition de la liste telephonique}
    echo {usage: phone <nom> 	    :	recherche du No associe a ce nom}
    echo {usage: phone - <nom> 	    :	idem, résultats précédés du nom du fichier cherché}
}

set DIR_GLOBAL $env(P10)/etc/phonebooks
set DIR_PERSO $env(HOME)/etc
set PERSO_PERSO $DIR_PERSO/phonebook
set GLOBAL_PERSO $DIR_PERSO/phonebook.public
set GREP "grep -i"

proc FICHIERS {} {
    global DIR_GLOBAL DIR_PERSO PERSO_PERSO
    set PXXFILES [glob $DIR_GLOBAL/P\[0-9\]\[0-9\]*\[a-zA-Z0-9\] $DIR_PERSO/phonebook.public]
    if {![file exists $PERSO_PERSO]} {
        puts "(liste personnelle $PERSO_PERSO absente)"
        set FICHIERS $PXXFILES
    } else {
        set FICHIERS [concat $PXXFILES $PERSO_PERSO]
    }
    return $FICHIERS
}

switch -- [lindex $argv 0] {
    {-edit} { 
	if {![info exists env(EDITOR)]} {
	puts "La variable d'environnement EDITOR n'est pas definie"
	puts "Vous n'aurez que vi a vous mettre sous la dent"
	    set ED vi
	} else {
	    set ED $env(EDITOR)
	}
	if {$argc ==  2} {
	    if {![file exists $DIR_PERSO]} {
		exec mkdir $DIR_PERSO
	    }
	    if {[file exists $PERSO_PERSO]} {
		exec touch $PERSO_PERSO
                exec chmod go-rw $PERSO_PERSO
	    }
	    exec $ED $PERSO_PERSO
	} else {
	    if {![file exists $GLOBAL_PERSO]} {
		exec cp $DIR_GLOBAL/TEMPLATE $GLOBAL_PERSO
	    } 
	    cd $DIR_GLOBAL
	    exec $ED $GLOBAL_PERSO
	}
    }
    {-} {
	set argv [lrange $argv 1 end]
        foreach F [FICHIERS] {
	    set QUEL_FICHIER [exec /bin/ls -l $F]
	    if {$argc != {}} {
		set status [catch {eval exec $GREP $argv [list $F]} RESULTAT]
		if {$status == 0} {
                      puts "\t$QUEL_FICHIER\n"
                      puts "$RESULTAT\n"
		} else {
		    puts "$QUEL_FICHIER"
		}
	    }
	}
    }
    default {
        set lignes ""
        foreach f [FICHIERS] {
            if {[catch {exec cat $f} resul]} {
                puts stderr $resul
            } else {
                append lignes $resul
            }
        }
        set command [concat exec $GREP $argv [list << $lignes]]
	set status [catch $command resul]
        if {$status} {
            global errorCode
            if {[lindex $errorCode 0] == "CHILDSTATUS" && [lindex $errorCode 2] == 1} {
                return 0
            }
            puts stderr "errorCode = $errorCode"
            puts stderr $resul
            return 1
        }
	puts $resul
        return 0
    }
}





