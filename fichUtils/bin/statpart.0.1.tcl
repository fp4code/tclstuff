#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set HELP(statpart.0.1.tcl) {
    6 avril 2002 (FP)
    explore un répertoire en restant sur la même partition
}

package require fidev
package require alladin_md5 1.0

proc exploreDir {dev inodesVar hardlinksVar filePropsVar dirPropsVar} {

    upvar $inodesVar inodes
    upvar $hardlinksVar hardlinks
    upvar $filePropsVar fileProps
    upvar $dirPropsVar dirProps

    set ici [pwd]
    if {$dev == {}} {
	file lstat $ici stat 
	set dev $stat(dev)
    }

   # On récupère tous les fichiers d'un répertoire (non portable ??)
    set fichiers [lsort [glob -nocomplain * .*]]
    set dirs [list]
    foreach f $fichiers {
	# on élimine "." et ".."
	if {$f == "." || $f == ".."} {
	    continue
	}
	if {[catch {file lstat $f stat} message]} {
	    puts stderr [list ****** $message]
	    continue
	}
	if {$stat(dev) != $dev} {
	    puts stderr [list *** Other media: $f]
	    continue
	}
	set dirFich [list $ici $f]
	set inode $stat(ino)
	if {[info exists inodes($inode)]} {
	    lappend hardlinks($inode) $dirFich
	    puts stderr [list HARDLINK $inodes($inode)]
	    continue
	}
	# si c'est un répertoire jamais vu au travers d'un "hard link"
	# on continue à explorer
	set inodes($inode) $dirFich
	switch $stat(type) {
	    "directory" {
		lappend dirs $f
		set dirProps($inode) [list $stat(mtime) $stat(uid) $stat(gid) $stat(mode) [file join $ici $f]] 
	    }
	    "link" {
		# puts stderr "LINK"
	    }
	    "file" {
		if {[catch {alladin_md5::file $f} md5]} {
		    puts stderr "ERREUR \"$ici $f\" : $md5"
		    continue
		}
		set fileProps($inode) [list $md5 $stat(size) $stat(mtime) $stat(uid) $stat(gid) $stat(mode)]
		# puts stderr [list $md5 $ici $f]
	    }
	    default {
		# puts stderr [list *** Special \($stat(type)\): $f]
	    }
	}
    }
    foreach dir $dirs {
	puts stderr "= $ici $dir"
	if {[catch {cd $dir} message]} {
	    puts stderr "ERREUR \"($ici) cd $dir\" : $message"
	    continue
	}
	exploreDir $dev inodes hardlinks fileProps dirProps
	cd $ici
    }
}

proc compare {arrayVar i1 i2} {
    upvar $arrayVar array
    foreach s1 $array($i1) s2 $array($i2) {
	set comp [string compare $s1 $s2]
	if {$comp != 0} {
	    return $comp
	}
    }
    return 0
}

set rien {
# 17 novembre 2002 (FP)
    source statpart.0.1.tcl
    cd ...
    exploreDir {} inodes hardlinks fileProps dirProps




createdb fichiers_home_fab
psql fichiers_home_fab
# gère mal : md5sum -> devrait être en binaire
             size   -> ne dépassera pas 2 GB
             mtime  -> ne dépassera pas l'an 2038
    CREATE TABLE f_2002_11_18_f (md5sum char(32), size int, mtime int, uid smallint, gid smallint, mode int, dirIndex int, file text);
    CREATE TABLE d_2002_11_18 (dirIndex int, dir text);
		      }