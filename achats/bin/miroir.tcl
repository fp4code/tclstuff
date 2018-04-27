#package require tcllib
package require ftp


set handle [ftp::Open freeway cnrsmar@hydre.auteuil.cnrs-dir.fr cmacma]

if {![ftp::Cd $handle webcnrs/achats/Details]} {
  return -code error "le répertoire webcnrs/achats/Details a disparu"
}

set pwd [ftp::Pwd $handle]

proc analyseLignes {handle ici &fichiers} {
  upvar ${&fichiers} fichiers
  if {![ftp::Cd $handle $ici]} {
    return -code error "le répertoire \"$ici\" a disparu"
  }
  
  set lignes [ftp::List $handle]
  
  foreach l $lignes {
    if {![regexp {^([0-1][0-9])-([0-3][0-9])-([0-9][0-9]) +(([0-1][0-9]):([0-5][0-9])(A|P)M) +((<DIR>)|([0-9]+)) +(.+)$} \
        $l dummy m d y time H M ap dirsize dir size name]} {
      return -code error "cannot regexp \"$l\""
    }
    set subdirs [list]
    if {$dir == ""} {
      set fichinfo [list [clock scan "$y-$m-$d $time"] $size $ici/$name]
      puts $fichinfo
      lappend fichiers $fichinfo
    } else {
      lappend subdirs $name
    }
    foreach dir [lsort $subdirs] {
       analyseLignes $handle "$ici/$dir" fichiers
      if {![ftp::Cd $handle $ici]} {
        return -code error "le répertoire \"$ici\" a disparu"
      }
    }
  }
}


proc locaux {root ici &fichiers} {
  upvar ${&fichiers} fichiers
  cd $ici
  
  set flist [glob -nocomplain *]
  
  foreach f $flist {
    set type [file type $f]
    set subdirs [list]
    switch $type {
      file {
        file stat $f stat
        set fichinfo [list $stat(mtime) $stat(size) $ici/$f]
        puts $fichinfo
        lappend fichiers $fichinfo
      }
      directory {
        lappend subdirs $f
      }
      default {
        puts stderr "TYPE $type: $ici/$f"
      }
    }
    foreach dir [lsort $subdirs] {
      locaux $root "$ici/$dir" fichiers
      cd $ici
    }
  }
}



set ftp::VERBOSE 0
set distants [list]
analyseLignes $handle $pwd distants


proc sortFich {f1 f2} {
  return [string compare [lindex $f1 2] [lindex $f2 2]]
}


