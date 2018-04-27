#!/prog/Tcl/bin/tclsh

if {$argc < 2} {
    puts stderr "syntaxe : imprime_and_delete.tcl imprimante fichiers..."
    exit 1
}

# close stdin
close stdout
close stderr

set imprimante [lindex $argv 0]
set tmpfic [lrange $argv 1 end]

set label "Impression Rustique de $tmpfic sur $imprimante"

eval exec /usr/openwin/bin/cmdtool \
                -geometry 1150x150 \
                -label {$label} \
                -c /home/sysadmin/tcl/ipp_and_delete.tcl $imprimante $tmpfic \
                    >& /dev/null &
exit 0
