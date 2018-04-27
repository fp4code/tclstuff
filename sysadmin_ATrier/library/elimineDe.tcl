#!/prog/Tcl/bin/tclsh

if {$argc != 1} {
    puts stderr "Syntaxe : $argv0 repertoireANettoyer"
    puts stderr "	permet d'oter du r�pertoire repertoireANettoyer"
    puts stderr "	et de ses sous-r�pertoires"
    puts stderr "	Les fichiers d�j� pr�sents dans le r�pertoire actuel"
    puts stderr "	et de ses sous-r�pertoires correspondants"
    exit
}

set repertoireANettoyer [lindex $argv 0]

puts "Lecture du repertoire actuel"

set fifi [exec find . -type f -print]

puts "OK pour nettoyer le r�pertoire $repertoireANettoyer des fichiers identiques dans ce r�pertoire [pwd] ?"

puts $fifi

foreach f $fifi {
    set err [catch {exec /usr/bin/cmp $f $repertoireANettoyer/$f} diff]
    if {$err == 0} {
        set elimine $repertoireANettoyer/$f
        puts "ELIMIN� $elimine"
        exec /bin/rm $elimine
    } else {
        puts "    $diff"
    }
}
