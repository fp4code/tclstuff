#!/usr/local/bin/tclsh

set LPFTP(BatBL) lexmark
set LPFTP(BatK) lexmarkk
set LPFTP(BatC) lexmarkc
set LPFTP(BatB) lexmarkb

if {$argc < 2} {
    puts stderr "syntaxe : $argv0 imprimante fichiers..."
    puts stderr "          $argv0 imprimante -nodelete fichier ..."
    exit 1
}

if {[lindex $argv 0] == "-waitend"} {
    set WAITEND 1
    set argv [lrange $argv 1 end]
} else {
    set WAITEND 0
}


close stdin
puts "Vous pouvez détruire cette fenêtre pour arrêter l'impression."
puts ""
set imprimante [lindex $argv 0]
set liste [lrange $argv 1 end]

set fichiers [list]
set delete 1
foreach f $liste {
    if {$f == "-nodelete"} {
        set delete 0
        continue
    }
    lappend fichiers $f
    set DELETE($f) $delete
    set delete 1
}

if {[info exists LPFTP($imprimante)]} {
    eval exec /usr/local/bin/lpftp $LPFTP($imprimante) $fichiers >&@ stdout
    foreach f $fichiers {
    	if {$DELETE($f)} {
    	    puts "effacement de $f"
    	    file delete $f
    	}
    }
} else {
    foreach f $fichiers {
        set chaine "* Impression de $f *"
        set cadre ""
        set i [string length $chaine]
        for {} {$i>0} {incr i -1} {
        	append cadre "*"
        }
        puts "        $cadre"
        puts "        $chaine"
        puts "        $cadre"
        puts ""
        exec /usr/local/bin/ipp $imprimante $f >&@ stdout
    	if {$DELETE($f)} {
    	    puts "effacement de $f"
    	    file delete $f
    	}
    }
}

puts ""
puts "Terminé !"
if {$WAITEND} {
    set delai 1000
} else {
    set delai 5000
}
    puts "Destruction automatique de la fenêtre dans [expr $delai/1000.] secondes..."
    after $delai
}
exit 0




