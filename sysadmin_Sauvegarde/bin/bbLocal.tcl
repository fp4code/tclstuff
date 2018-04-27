#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.5 "$0" ${1+"$@"}

set DF LINUX
# set DF SOLARIS


set tests {

}


# tclsh8.4 file est trop lent

# $Id$

set INFO(bbLocal.tcl) {
    4 février 2003 (FP)
    scanne tous les répertoires et crée dans /BB/2003.02.04.c0t2d0s7/ les bases

    2003.02.04.yoko.lpn.prive.c0t2d0s7.links.db
    lien_source {mtime lien_destination {nature (file, dir, dead, ...)}}

    2003.02.04.yoko.lpn.prive.c0t2d0s7.dirs.db
    dirname {mtime owner group permissions}

    2003.02.04.yoko.lpn.prive.c0t2d0s7.files.db
    {md5sum instantDeScan [#i]} {size mtime dir name inode owner group permissions}
    On suppose la clé unique. Il faut donc introduire un indice supplémentaire éventuel #1, #2, etc.

    2003.02.04.yoko.lpn.prive.c0t2d0s7.dirContents.db
    dir {file md5sum instantDeScan [#i]}
    dir {dir dirname}
    dir {link lien_source}
    Clé non unique 

    2003.02.04.yoko.lpn.prive.c0t2d0s7.inodes.db
    inode {file md5sum instantDeScan [#i]}
    inode {dir dirname}
    inode {link lien_source}
    Clé non unique

    2003.02.04.yoko.lpn.prive.c0t2d0s7.log
    2003.02.04.yoko.lpn.prive.c0t2d0s7.errors


    premiers essais : 1    GB   8 minutes
                      4.65 GB 120 minutes
                      8.0  GB 210 minutes
                     19.100GB 500 minutes
                     33.0  GB 630 minutes

2004-03-11 0.164 3 minutes tcl8.3
2004-03-11 3.475 3 minutes tcl8.4
2004-03-11 0.164 3 minutes tcl8.3
                     

2005-04-29 (tcl8.3) root@soda:www# time /home/fab/A/fidev/Tcl/sysadmin_Sauvegarde/bin/bbLocal.tcl /var/www
                    taille traitée = 0.91008387 14.57user 4.51system 2:20.94elapsed 13%CPU (0avgtext+0avgdata 0maxresident)k
2005-04-29 (tcl8.4) root@soda:www# time /home/fab/A/fidev/Tcl/sysadmin_Sauvegarde/bin/bbLocal.tcl /var/www
                    taille traitée = 0.91008387 17.26user 5.45system 2:38.01elapsed 14%CPU (0avgtext+0avgdata 0maxresident)k
2005-04-29 (tcl8.5) root@soda:www# time /home/fab/A/fidev/Tcl/sysadmin_Sauvegarde/bin/bbLocal.tcl /var/www
                    taille traitée = 0.91008387 16.38user 4.40system 2:33.86elapsed 13%CPU (0avgtext+0avgdata 0maxresident)k



2005-05-09 passage de "file ..." à "file_..." 

2005-05-10 suppression de -dup pour 

}

#	set GLOB(excludeRegexpDirAbsolu) [list {/export/home/Free$} {/export/home/[^/]+/C$} {/\.netscape/cache} {^/BB$} {^/local/Y}]
	set GLOB(excludeRegexpDirAbsolu) {}
set GLOB(excludeRegexpDirRelatif) [list {^tmp$} {^Poubelle$} {^Z$} {^Z_} {^TT_DB$}]
# {^\.}
# {^Y$}

# package require Tcl 8.4 ;# Pour les entiers "wide"
package require fidev
package require alladin_md5 1.0
load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so

proc syntaxError {} {
    global argv0
    puts stderr "usage : $argv0 \[-debug\] /export/home ou autre"
    exit 1
}

proc traiteErreur {h message} {
    puts stderr "    $message"
    puts $h $message
    flush $h
}

proc file_lstat {f vName} {
    upvar $vName v
    return [file lstat $f v]
}

proc file_attributes {f quoi} {
    return [file attributes $f $quoi]
}

proc file_readlink {f} {
    return [file readlink $f]
}

proc file_type {f} {
    return [file type $f]
}


proc explore {dir dev &GLOB} {
    upvar ${&GLOB} GLOB

    if {0 && $GLOB(size) > 1e9} {
	$GLOB(dbLinks)       close
	$GLOB(dbDirs)        close
	$GLOB(dbFiles)       close
	$GLOB(dbDirContents) close
	$GLOB(dbInodes)      close
	close $GLOB(fileLog)
	close $GLOB(fileErrors)
	exit
    }

    puts stderr "[format %.3f [expr {$GLOB(size)/1e9}]] explore $dir"
    set err [catch {cd $dir} message]
    if {$err} {
        traiteErreur $GLOB(fileErrors) "cd $dir : $message"
        return
    }
    set fichiers [lsort [glob -nocomplain .* *]]
    foreach f $fichiers {
        # on saute . et ..
        if {$f == "." || $f == ".."} {
            continue
        }
        set fullname [file join $dir $f]
        if {[string index $f 0] == "~"} {
            traiteErreur $GLOB(fileErrors) "fichier débutant par \"~\" exclu : \"$fullname\""
            continue
        }
        # lstat important pour le pas suivre les liens
        set err [catch {file_lstat $f attrib} message]
        # puts stderr $message
        # parray attrib
        if {$err} {
            traiteErreur $GLOB(fileErrors) "file lstat \"$fullname\" : $message"
            continue
        }
        switch $attrib(type) {
            "directory" {
                $GLOB(dbDirs) put $fullname [list $attrib(mtime) $attrib(ino) [file_attributes $f -owner] [file_attributes $f -group] [file_attributes $f -permissions]]
                $GLOB(dbInodes) put $attrib(ino) [list dir $fullname]
                $GLOB(dbDirContents) put $dir [list dir $fullname]
                set exclu 0
                foreach regexp $GLOB(excludeRegexpDirAbsolu) {
                    if {[regexp $regexp $fullname]} {
                        traiteErreur $GLOB(fileErrors) "exclu dir absolu : \"$fullname\""
                        set exclu 1
                        break
                    } else {
                        # puts stderr [list regexp $regexp $fullname -> 1]
                    }
                }
                if {$exclu} continue
                foreach regexp $GLOB(excludeRegexpDirRelatif) {
                    if {[regexp $regexp $f]} {
                        traiteErreur $GLOB(fileErrors) "exclu dir relatif : \"$fullname\""
                        set exclu 1
                        break
                    }
                }
                if {$exclu} continue
                if {$attrib(dev) != $dev} {
                    traiteErreur $GLOB(fileErrors) "on other device : \"$fullname\""
                    continue
                }
                explore $fullname $dev GLOB
                $GLOB(dbLinks) sync
                $GLOB(dbDirs) sync
                $GLOB(dbFiles) sync
                $GLOB(dbDirContents) sync
                $GLOB(dbInodes) sync
                cd $dir
            }
            "file" {
                if {[regexp {[\r\n]} $f]} {
                    traiteErreur $GLOB(fileErrors) "Fichier interdit, le nom contient un retour : \"[file join [pwd] $f]\""
                    continue
                }
                if {[string index $f 0] == "|"} {
                    traiteErreur $GLOB(fileErrors) "Fichier interdit, le nom commence par \"|\" : \"[file join [pwd] $f]\""
                    continue
                }
# déjà fait
#                set err [catch {file stat $f attrib} message]
#                if {$err} {
#                    traiteErreur $GLOB(fileErrors) "file stat \"$f\" : $message"
#                    continue
#                }
                # incr ne marche pas avec un incrément "wide"
                set GLOB(size) [expr {$GLOB(size) + $attrib(size)}]
                set err [catch {alladin_md5::file $f} md5sum]
                if {$err} {
                    traiteErreur $GLOB(fileErrors) "alladin_md5 $f : $md5sum"
                    continue
                }
                set instant [clock seconds]
                set key "$md5sum $instant"

                if {[$GLOB(dbFiles) get $key] != {}} {
                    set iv 1
                    set key "$md5sum $instant #$iv"
                    while {[$GLOB(dbFiles) get $key] != {}} {
                        incr iv
                        set key "$md5sum $instant #$iv"
                    }
                }
                $GLOB(dbFiles) put $key [list \
					     $attrib(size) $attrib(mtime) $attrib(ino) $dir $f \
					     [file_attributes $f -owner] [file_attributes $f -group] [file_attributes $f -permissions]]
                $GLOB(dbInodes) put $attrib(ino) [list file $key]
                $GLOB(dbDirContents) put $dir [list file $key]
            }
            "link" {
                set err [catch {file_readlink $f} lili]
                if {$err} {
                    traiteErreur $GLOB(fileErrors) "$fullname : $lili"
                } else {
                    catch {file_type $lili} lilitype
                }
                $GLOB(dbLinks) put $fullname [list $attrib(mtime) $attrib(ino) $lilitype $lili]
                $GLOB(dbInodes) put $attrib(ino) [list link $fullname]
                $GLOB(dbDirContents) put $dir [list link $fullname]
            }
            default {
                traiteErreur $GLOB(fileErrors) "unknown type : $attrib(type) for \"$fullname\""
            }
        } 
    }
}

set GLOB(size) [expr {wide(0)}]
#set GLOB(size) [expr {double(0)}]
set GLOB(links) [list]

if {[lindex $argv 0] == "-debug"} {
    set DEBUG 1
    set argv [lrange $argv 1 end]
} else {
    set DEBUG 0
}

if {[llength $argv] != 1} {
    syntaxError
}

set fs $argv

set err [catch [list exec df -k $fs] message]
if {$err} {
    puts stderr "df -k $fs -> $message"
    exit 1
}

set lignes [split $message \n]
if {[llength $lignes] != 2} {
    puts stderr "attendu deux lignes à \"df -k $fs\" -> $message"
    exit 1
}

set ligne [lindex $lignes 1]

switch $DF {
    LINUX {set colfs 5}
    SOLARIS {set colfs 5}
    default {return -code error "DF \"$DF\" inconnu"}
}

set l [lindex $ligne $colfs]
if {$l != $fs} {
    puts stderr "attendu \"$fs\" colonne [expr {$colfs+1}] de \"$ligne\""
    # exit 1
}

set GLOB(raw) [lindex [split [lindex $ligne 0] /] end]

set GLOB(hostname) [info hostname]
set GLOB(date) [clock format [clock seconds] -format %Y-%m-%d]

set GLOB(dirdest) [file join /local/home/bb $GLOB(date).$GLOB(raw)]
if {[file exists $GLOB(dirdest)]} {
    puts stderr "dirname $GLOB(dirdest) alread exists, BYE"
    exit 1
}

parray GLOB
file mkdir $GLOB(dirdest)
file attributes $GLOB(dirdest) -group p10admin -permissions 040770

set prefix $GLOB(date).$GLOB(hostname).$GLOB(raw)
set GLOB(dbLinks)       [berkdb open -create -btree -- [file join $GLOB(dirdest) $prefix.links.db]]
set GLOB(dbDirs)        [berkdb open -create -btree -- [file join $GLOB(dirdest) $prefix.dirs.db]]
set GLOB(dbFiles)       [berkdb open -create -btree -- [file join $GLOB(dirdest) $prefix.files.db]]
set GLOB(dbDirContents) [berkdb open -create -btree -dup -- [file join $GLOB(dirdest) $prefix.dircontents.db]]
set GLOB(dbInodes)      [berkdb open -create -btree -dup -- [file join $GLOB(dirdest) $prefix.inodes.db]]
set GLOB(fileLog)    [open [file join $GLOB(dirdest) $prefix.log] w]
set GLOB(fileErrors) [open [file join $GLOB(dirdest) $prefix.errors] w]
close [open [file join $GLOB(dirdest) $prefix.start] w]

file stat $fs attrib
explore $fs $attrib(dev) GLOB

puts stderr "\n"
puts "taille traitée = [expr {1e-9*$GLOB(size)}]"

$GLOB(dbLinks) close
$GLOB(dbDirs) close
$GLOB(dbFiles) close
$GLOB(dbDirContents) close
$GLOB(dbInodes) close
close $GLOB(fileLog)
close $GLOB(fileErrors)
