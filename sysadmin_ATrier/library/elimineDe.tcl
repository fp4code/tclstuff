#!/prog/Tcl/bin/tclsh

if {$argc != 1} {
    puts stderr "Syntaxe : $argv0 repertoireANettoyer"
    puts stderr "	permet d'oter du répertoire repertoireANettoyer"
    puts stderr "	et de ses sous-répertoires"
    puts stderr "	Les fichiers déjà présents dans le répertoire actuel"
    puts stderr "	et de ses sous-répertoires correspondants"
    exit
}

set repertoireANettoyer [lindex $argv 0]

puts "Lecture du repertoire actuel"

set fifi [exec find . -type f -print]

puts "OK pour nettoyer le répertoire $repertoireANettoyer des fichiers identiques dans ce répertoire [pwd] ?"

puts $fifi

foreach f $fifi {
    set err [catch {exec /usr/bin/cmp $f $repertoireANettoyer/$f} diff]
    if {$err == 0} {
        set elimine $repertoireANettoyer/$f
        puts "ELIMINÉ $elimine"
        exec /bin/rm $elimine
    } else {
        puts "    $diff"
    }
}
