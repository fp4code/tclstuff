#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.3 "$0" ${1+"$@"}

# $Id: sauvegardeClient.tcl,v 1.6 2003/03/11 14:43:23 fab Exp $

set AFAIRE { /home/ArchiveL2M
/home/alphane /home/asdex /home/dion /home/dsoltani /home/dupuis /home/fab /home/fico2 /home/ficopt /home/ficosimu /home/jboutkab /home/jluc /home/kammoun /home/lijadi /home/lwb /home/nathalie /home/p10admin /home/scollin }

set INFO(sauvegardeClient.tcl) {
  23 janvier 2003 (FP)

Principe de la sauvegarde
  - On calcule la chaine md5sum mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm du fichier original.
  - On r�cup�re la date yyyy.mm.dd de derni�re modification du fichier original
  - S'il n'existe pas de fichier � contenu identique,
    c'est � dire de m�me nom dans un des sous-r�pertoires de $GLOB(RDEST)
    on copie le fichier comme $GLOB(RDEST)/yyyy.mm.dd/mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
    Les permissions de ces fichiers sont simplement "-r--r-----"
  - Le nom et les caract�ristiques d'un fichier de date de derni�re modification yyyy.mm.dd
    sont conserv�es dans $GLOB(RDEST)/yyyy.mm.dd/databaseV1
    Format :
    md5sum + instant_d_insertion taille sauveur repertoire_archive {owner group mode mtime} machine repertoire nom
    
    md5sum              : 32 caract�res hexa

    +                   : signe d'insertion
    instant_d_insertion : en secondes depuis "the epoch Unix"
    taille              : normalement inutile (idem "ls repertoire_archive/md5sum"), mais acc�l�re la gestion
    sauveur             : identit� du responsable de l'ex�cution du client, souvent similaire � owner
    repertoire_archive  : "." si le fichier est la premi�re instance copi�e
                          yyyy.mm.dd si le fichier a un contenu identique � une archive existante
    La liste des attributs pour Unix est {owner group mode mtime}
    Elle peut �tre diff�rente sur une autre machine, mais mtime doit toujours figurer, et TOUJOURS en DERNIER
    owner               : propri�taire du fichier � sauvegarder en lettres      
    group               : propri�taire du fichier � sauvegarder en lettres      
    mode                : comme Tcl, genre "00644"
    mtime               : en secondes depuis "the epoch Unix"
    machine             :
    repertoire          :
    nom                 : 
  - � terme, le programme sera client/serveur :
    * Le client se pr�sente : "je suis telle machine, tel sauveur avec telles cl�s, et je veux sauvegarder ou connaitre le statut
       d' un fichier dont voici md5sum owner group mode mtime machine repertoire nom".
          HELLO I'M fab ON yoko
          HELLO fab@yoko
          STATUS OF md5sum owner group mode mtime machine repertoire nom
          
      * Le serveur v�rifie les cl�s du sauveur et rejette tout si elles sont incorrectes
      * Si le fichier est archiv�, contenu et param�tres, le serveur r�pond
        "ALREADY SAVED AT instant_d_insertion BY sauveur BYE"
        et la transaction est termin�e
      * Si le fichier est archiv�, contenu, machine, repertoire, nom identiques mais attributs diff�rents,
        le serveur renvoit "DIFFERENT ATTRIBUTES owner group mode mtime AT instant_d_insertion BY sauveur"
        * Le client doit renvoyer "OK" ou "CHANGE" ou "INVALIDATE"
      * Si le contenu du fichier est archiv�, mais avec un autre machine/repertoire/nom, le serveur r�pond "EXISTING CLONE"
        * Le client doit renvoyer "OK" ou "CLONE".
      * Si le contenu du fichier n'est pas archiv�, le serveur r�pond "INEXISTENT".
        * Le client doit renvoyer "OK" ou "ARCHIVE".

        * Si le client a envoy� "OK" � "DIFFERENT ATTRIBUTES...", le serveur renvoit "BYE".
        * Si le client a envoy� "INVALIDATE" � "DIFFERENT ATTRIBUTES...", le serveur invalide l'instance d'archive
          par exemple en �crivant une ligne
            "md5sum - instant_d_invalidation sauveur instant_d_insertion_a_invalider"
          dans le fichier databaseV1 qui contenait la ligne avec "md5sum + ..."
          Cela suppose que les instants insertion/invalidation sont s�par�s d'au moins une seconde.
          C'est presque certain mais le programme doit le v�rifier et introduire un d�lai dans la r�ponse au client.
          Le serveur renvoit "INVALIDATED AT instant_d_invalidation BYE"
        * Si le client a renvoy� "CHANGE" � "DIFFERENT ATTRIBUTES...", le serveur
          ins�re une ligne 
            "md5sum c instant_de changement sauveur instant_de_insertion_a_changer owner group mode mtime"
          et renvoit "CHANGED AT instant_de changement BYE"
          Apr�s r�flexion, si mtime change, la database change. Donc cas diff�rent.
          Pour ne pas se casser la t�te (mais perdre une ligne), on invalide et on recr�e
        * Si le client a renvoy� "CLONE" � "EXISTING CLONE", le serveur
          ajoute une ligne
            "md5sum + instant_d_insertion sauveur repertoire_archive owner group mode mtime machine repertoire nom"
          Dans le fichier databaseV1 dont la date du r�pertoire parent correspond au jour GMT de "mtime".
          Le cas �ch�ant, il aura cr�� ce r�pertoire.
          Cloner peut poser le PROBL�ME de l'absence de v�rification que le client poss�de bien
          le fichier. Ainsi, � partir de la connaissance d'un md5sum,
          le client peut s'approprier le contenu d'un fichier inconnu de lui.
        * Si le client a renvoy� "ARCHIVE" � "INEXISTENT", il doit poursuivre avec sur une ligne la longueur du fichier
          puis les octets du fichier. Le serveur v�rifie alors le md5sum, archive le fichier, ajoute une ligne
             "md5sum + instant_d_insertion sauveur repertoire_archive owner group mode mtime machine repertoire nom"
          dans le fichier databaseV1 ad'hoc et renvoit "ARCHIVED AT instant_d_insertion BYE"


  - Pour �viter tout m�lange, un seul programme � la fois peut travailler sur $GLOB(RDEST)
    Le fichier $GLOB(RDEST)/LOCK_machine_pid indique quel est le programme en cours


  - Les fichiers de base de donn�e sont misent en m�moire vive sous forme de tableau associatif 
    dont la cl� est la chaine md5sum, et la valeur une liste � 1 plus 9N �l�ments
    Premier �l�ment =  r�pertoire contenant l'archive (genre 2003.01.22)
    groupes suivants = instant_d_insertion sauveur owner group mode mtime machine repertoire nom


    11 mars 2003 (FP)

    Je reviens � tcl8.3 � cause de la lenteur de la commande "file"
    Je passe les op�rations en "double"
    Les gros fichiers ne seront pas trait�s (could not read "big": Value too large for defined data type)

}

set GLOB(excludeRegexpDirAbsolu) [list {/home/Free$} {/home/p10admin/prog$} {/home/[^/]+/C$}]
set GLOB(excludeRegexpDirRelatif) [list {^tmp$} {^Tmp$} {^Z$} {^Z_} {^TT_DB$} {^Poubelle$} {^temp$} {^.xvpics$} {^cache$} {Trash$}]
# {^\.}
# {^Y$}
set GLOB(RDEST) /export/SAUVEGARDE/essaiBigBrother

# package require Tcl 8.4 ;# Pour les entiers "wide"
package require fidev
package require alladin_md5 1.0

if {$argc <= 2} {
    puts stderr "usage : $argv0 \[-debug\]  \[-since \"YYYYmmdd HHMMSS\"\] serveur port rep rep ..."
    exit 1
}

proc traiteErreur {&list message} {
    upvar ${&list} list
    puts stderr "    $message"
    lappend list $message
}

proc transmets {sock file} {
    set f [open $file r]
    fconfigure $f -translation binary  -encoding binary -buffering full -buffersize 4096

    putslog $sock ARCHIVE
    fconfigure $sock -translation binary  -encoding binary -buffering full -buffersize 4096

    while {![eof $f]} {
        puts -nonewline $sock [read $f 4096]
    }
    close $f
    flush $sock

    fconfigure $sock -buffering line -translation auto -encoding binary
    set s [getslog $sock]
    if {![string match "ARCHIVED AT * BYE" $s]} {
        puts stderr "NO OK \:\"$file\": \"$s\""
    }
}

proc testNOSAVE {N} {
    set err [catch [list file exists $N} message]
    if {$err} {
	traiteErreur glob(errors) "\"file exists $N\" dans $dir -> $message"
	return 1
    } else {
	if {$message} {
	    traiteErreur glob(errors) "exclu dir contenant \"$N : $dir"
	    return 1
	}
    }
    return 0
}

proc explore {dir dev &glob sock} {
    upvar ${&glob} glob
    puts stderr "[format %.3f [expr {$glob(size)/1e9}]] explore $dir"
    set err [catch {cd $dir} message]
    if {$err} {
        traiteErreur glob(errors) "cd $dir -> $message"
        return
    }
    # On est ici dans le r�pertoire $dir

    # �limination sur crit�re de pr�sence d'un fichier
    if {[testNOSAVE NOSAVED] || [testNOSAVE @NOSAVED]} return

    set fichiers [lsort [glob -nocomplain .* *]]
    foreach f $fichiers {
        # on saute . et ..
        if {$f == "." || $f == ".."} {
            continue
        }
        set fullname [file join $dir $f]
        # lstat important pour le pas suivre les liens
        set err [catch {file lstat $f attrib} message]
        # puts stderr $message
        # parray attrib
        if {$err} {
            traiteErreur glob(errors) "file stat \"$fullname\" : $message"
            continue
        }
        switch $attrib(type) {
            "directory" {
                set exclu 0
                foreach regexp $glob(excludeRegexpDirAbsolu) {
		    # puts stderr "regexp $regexp $fullname"
                    if {[regexp $regexp $fullname]} {
                        traiteErreur glob(errors) "exclu dir absolu : \"$fullname\""
                        set exclu 1
                        break
                    } else {
                        # puts stderr [list regexp $regexp $fullname -> 1]
                    }
                }
                if {$exclu} continue
                foreach regexp $glob(excludeRegexpDirRelatif) {
                    if {[regexp $regexp $f]} {
                        traiteErreur glob(errors) "exclu dir relatif : \"$fullname\""
                        set exclu 1
                        break
                    }
                }
                if {$exclu} continue
                if {$attrib(dev) != $dev} {
                    traiteErreur glob(errors) "on other device : \"$fullname\""
                    continue
                }
                explore $fullname $dev glob $sock
                cd $dir
            }
            "file" {
                if {[regexp {[\r\n]} $f]} {
                    traiteErreur glob(errors) "Fichier interdit, le nom contient un retour : \"[file join [pwd] $f]\""
                    continue
                }
                if {[string index $f 0] == "|"} {
                    traiteErreur glob(errors) "Fichier interdit, le nom commence par \"|\" : \"[file join [pwd] $f]\""
                    continue
                }
		if {$glob(SINCE) > $attrib(mtime)} continue
# d�j� fait
#                set err [catch {file stat $f attrib} message]
#                if {$err} {
#                    traiteErreur glob(errors) "file stat \"$f\" : $message"
#                    continue
#                }
                # incr ne marche pas avec un incr�ment "wide"
                set glob(size) [expr {$glob(size) + $attrib(size)}]
                set err [catch {alladin_md5::file $f} md5sum]
                if {$err} {
                    traiteErreur glob(errors) "alladin_md5 $f : $md5sum"
                    continue
                } 
		switch $glob(PLATFORM) {
		    "unix" {
			set attributes [list [file attributes $f -owner] [file attributes $f -group] [file  attributes $f -permissions] [file mtime $f]]
		    }
		    "windows" {
			set attributes [list [file mtime $f]]
		    }
		}
                putslog $sock [list STATUS OF\
                                   $md5sum [file size $f]\
                                   $attributes\
                                   [info hostname] $dir $f]
                set rep [getslog $sock]
                if {[string match *BYE $rep]} {
                    if {[string match "DIF*" $rep]} {
                        puts stderr "SAME MD5SUM FOR $dir/$f"
                        exit 33
                    }
                } else {                  
                    if {$rep == "INEXISTENT"} {
                        transmets $sock $f
                        set glob(nnew) [expr {$glob(nnew) + 1}]
                    } elseif {$rep == "EXISTING CLONE"} {
                        putslog $sock CLONE
                        set s [getslog $sock]
                        if {![string match "CLONED AT * BYE" $s]} {
                            exit 22
                        }
                        set glob(nclone) [expr {$glob(nclone) + 1}]
                    } else {
                        putslog $sock OK
                        set rep [getslog $sock]
                        if {$rep != "BYE"} {
                            exit 22
                        }
                    }
                }
            }
            "link" {
                lappend glob(links) $fullname [file readlink $f]
            }
            default {
                traiteErreur glob(errors) "unknown type : $attrib(type) for \"$fullname\""
            }
        } 
    }
}

if {0} {
    switch $tcl_platform(platform) {
	"unix" {
	    set qui $env(LOGNAME)
	}
	"windows" {
	    set qui $env(USERNAME)
	}
    }
    set GLOB(size) [expr {wide(0)}]
    set GLOB(nnew) [expr {wide(0)}]
    set GLOB(nclone) [expr {wide(0)}]
} else {
    set qui $env(LOGNAME)
    set GLOB(PLATFORM) "unix"
    set GLOB(size) [expr {double(0)}]
    set GLOB(nnew) [expr {double(0)}]
    set GLOB(nclone) [expr {double(0)}]
}
set GLOB(links) [list]
set GLOB(errors) [list]

if {[lindex $argv 0] == "-debug"} {
    set DEBUG 1
    set argv [lrange $argv 1 end]
} else {
    set DEBUG 0
}

if {[lindex $argv 0] == "-since"} {
    set GLOB(SINCE) [clock scan [lindex $argv 1]]
    set argv [lrange $argv 2 end]
} else {
    set GLOB(SINCE) 0
}

if {$GLOB(SINCE) != 0} {
    lappend GLOB(excludeRegexpDirAbsolu) {/home/ArchiveL2M$}
}
puts stderr "Sauvegarde � partir du [clock format $GLOB(SINCE) -format "%Y/%m/%d %H:%M:%S"]"

set sock [socket [lindex $argv 0] [lindex $argv 1]]

proc putslog {sock s} {
    global DEBUG
    if {$DEBUG == 1} {
        puts stderr "> $s"
    }
    puts $sock $s
    flush $sock
}

proc getslog {sock} {
    global DEBUG
    set s [gets $sock]
    if {$DEBUG == 1} {
        puts stderr "< $s"
    }
    return $s
}

putslog $sock "HELLO I'M $qui ON [info hostname]"
getslog $sock

puts stderr "\nargv = \"$argv\""
set i 0
foreach a $argv {
    incr i
    puts stderr "$i \"$a\""
}
puts stderr "C'EST TOUT"

foreach ici [lrange $argv 2 end] {
    file stat $ici attrib
    explore $ici $attrib(dev) GLOB $sock
}

if {$GLOB(links) != {}} {
puts stderr "\nLINKS"
    foreach {e f} [lsort $GLOB(links)] {puts "$e -> $f"}
}
if {$GLOB(errors) != {}} {
    puts stderr "\nERREURS"
    foreach e [lsort $GLOB(errors)] {puts $e}
}
puts stderr "\n"
puts "taille trait�e = [expr {1e-9*$GLOB(size)}], fichiers transmis = $GLOB(nnew), fichiers clon�s = $GLOB(nclone)"

