#!/prog/Tcl/bin/tclsh

# recherche de l'imprimante

set i [lsearch -glob $argv {-d*}]

if {$i < 0} {
    puts stderr {/usr/local/bin/lp : manque "-d Imprimante"}
    exit 1
}

set dede [lindex $argv $i]
set j $i
if {[string compare $dede "-d"] != 0} {
    set imprimante [string range $dede 2 end]
} else {
    incr j
    if {[llength $argv] <= $j} {
        puts stderr {/usr/local/bin/lp : -d : manque "Imprimante"}
        exit 1
    }
    set imprimante [lindex $argv $j]
}

# imprimante accessible via lp

if {[lsearch $imprimante {4si_bag}] >= 0 || \
     [lsearch $imprimante {tek220_bag}] >= 0 || \
     [lsearch $imprimante {xtek220_bag}] >= 0 || \
     [lsearch $imprimante {phaser}] >= 0 || \
     [lsearch $imprimante {xphaser}] >= 0} {
    eval exec /usr/bin/lp $argv
    exit 0
}

# recherche des arguments et recherche des fichiers

set argv [concat [lrange $argv 0 [expr $i-1]] [lrange $argv [expr $j+1] end]]

while {[string match {-*} [lindex $argv 0]]} {
    set argum [string range [lindex $argv 0] 1 end]
    set lettre [string index $argum 0]
    if {[string first $lettre {clmpsw}] >= 0} {
        set argv [concat [string range $argum 1 end] [lrange $argv 1 end]]
    } elseif {[string first $lettre {fHnoPqStTry}] >= 0} {
        if {[string length $argum] > 1} {
            set argv [lrange $argv 1 end]
        } else {
            set argv [lrange $argv 2 end]
        }
    } else {
        puts stderr "/usr/local/bin/lp: Option illegale -- $lettre"
        exit 1
    }
}

set fichiers $argv

# appel de ipp

set tmp /tmp/papif.$env(USER)
exec /bin/mkdir -p $tmp

proc spoule {fichiers tmp} {

    set tmpfic {}

    foreach f $fichiers {
        set tmpf $tmp/[clock format [clock seconds] -format %Y.%m.%d.%H.%M.%S].[file tail $f]
        if {![file readable $f]} {
            puts "Fichier $f : non lisible"
        } else {
    
        set fifi [open $f r]
        set magic [read $fifi 2]
        close $fifi
puts "magic = $magic"
        if {$magic == "%!"} { 
            exec /bin/cp $f $tmpf
puts "cp"
            lappend tmpfic $tmpf
        } elseif {[file size $f] <= 11000} {
            exec mp -lo $f > $tmpf
            lappend tmpfic $tmpf
        } else {
            puts "Fichier $f : non PostScript et trop grand"
        }
        }
    }
    return $tmpfic
}

set tmpfic [spoule $fichiers $tmp]
puts $tmpfic

if {$tmpfic == {} && $fichiers != {}} {
    exit 1
}


exec /home/sysadmin/tcl/imprime_and_delete.tcl $imprimante $tmpfic >/dev/null 2>/dev/null &

exit 0
