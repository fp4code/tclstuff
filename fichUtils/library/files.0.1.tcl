namespace eval ::fidev::fichUtils {}

proc ::fidev::fichUtils::traiteDirOnSame {dir dev inodesVar hardlinksVar} {

    upvar $inodesVar inodes
    upvar $hardlinksVar hardlinks

   # On récupère tous les fichiers d'un répertoire (non portable ??)
    if {$dir == "."} {
	set fichiers [glob -nocomplain * .*]
    } else {
	set fichiers [glob -nocomplain $dir/* $dir/.*]
    }
    set fichiers [lsort $fichiers]
    foreach f $fichiers {
	set tail [file tail $f]
	# on élimine "." et ".."
	if {$tail == "." || $tail == ".."} {
	    continue
	}
	if {[catch {file lstat $f stat} message]} {
	    puts [list ****** $message]
	    continue
	}
	# puts stderr $f
	# parray stat
	set name [file split $f]
	if {$stat(dev) != $dev} {
	    puts [list *** Other media: $f]
	    continue
	}
	if {[info exists inodes($stat(ino))]} {
	    lappend hardlinks($stat(ino)) $name
	    continue
	}
	# si c'est un répertoire jamais vu au travers d'un "hard link"
	# on continue à explorer
	switch $stat(type) {
	    "directory" {
		set inodes($stat(ino)) $name
		# puts [list Directory: $f]
		::fidev::fichUtils::traiteDirOnSame $f $dev inodes hardlinks
	    }
	    "link" {
		set inodes($stat(ino)) $name
	    }
	    "file" {
		set inodes($stat(ino)) $name
	    }
	    default {
		set inodes($stat(ino)) $name
		puts [list *** Special \($stat(type)\): $f]
	    }
	}
    }
}

proc ::fidev::fichUtils::traiteDir {dir} {
    global inodes hardlinks

    file lstat $dir stat
    set dev $stat(dev)
    ::fidev::fichUtils::traiteDirOnSame $dir $dev inodes hardlinks
}

proc t {} {
    global inodes hardlinks
    catch {unset inodes hardlinks}

    source files.0.1.tcl
    set pwd [pwd]
    cd /home/fab/A
    ::fidev::fichUtils::traiteDir .
    cd $pwd

    puts "Hardlinks:"
    foreach inode [array names hardlinks] {
	puts [concat [list $inodes($inode)] $hardlinks($inode)]
    }

    set ninodes [lsort -command {compare inodes} [array names inodes]]

    foreach inode $ninodes {
	puts "[format %8d $inode] $inodes($inode)"
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

