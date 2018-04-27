#!/prog/Tcl/bin/tclsh

if {$argc < 2} {
    puts stderr "syntaxe : ipp_and_delete.tcl imprimante fichiers..."
    exit 1
}

puts "Vous pouvez d�truire cette fen�tre pour arr�ter l'impression."
puts ""
set imprimante [lindex $argv 0]
set tmpfic [lrange $argv 1 end]
exec /usr/local/bin/ipp $imprimante $tmpfic >&@ stdout
exec /bin/rm $tmpfic
puts ""
puts "Termin� !"
puts "Destruction automatique de la fen�tre dans 5 secondes..."
after 5000
exit 0
