# -----------------------------------------------------------------------------#
# Recompilation automatique du code C++ associé et chargement
# -----------------------------------------------------------------------------#

package provide nr 1.0

set Nr_peredir [pwd]
set Nr_heredir [file dirname [info script]]
cd $Nr_heredir

set nr [list fit gammln gammq gcf gser nrutil nr]
proc baba {l1 suff} {
    set l2 {}
    foreach f $l1 {
        lappend l2 ${f}${suff}
    }
    return $l2
}

set ajour 1
if {![file exists nr.so]} {
    set ajour 0
} else {
    set dso [file mtime nr.so]
    foreach f $nr {
        if {[file mtime nr.cc] > $dso} {
            set ajour 0
            break
        }
    }
}
if {!$ajour} {
    foreach f $nr {
        if {![file exists $f.so] || [file mtime $f.cc] > [file mtime $f.so]} {
            exec CC -I/usr/openwin/include \
      -I/prog/Tcl/tk${tk_patchLevel}/generic \
      -I/prog/Tcl/tcl${tcl_patchLevel}/generic \
                    -g -KPIC -c $f.cc
        }
    }
    set commande [list exec CC -G -ztext [baba $nr .o] -o nr.so -L/usr/local/lib -llifi -lC]
    puts $commande
    eval $commande
}



cd $Nr_peredir
load $Nr_heredir/nr.so Nr
