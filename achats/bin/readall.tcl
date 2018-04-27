# 24 septembre 2001 (FP)

package require csv

proc controleFichier {fName sepChar} {
  set f [open $fName r]

  set il 0
  while {[gets $f line] >= 0} {
    incr il
    set data [::csv::split $line $sepChar]
    if {[llength $data] < 6} {
      puts stderr "Erreur $fName ligne $il : pas assez de cases ([llength $data])"
    }
    set ic 6
    foreach x [lrange $data 6 end] {
      incr ic
      if {$x != {}} {
        puts stderr "Erreur $fName ligne $il : colonne $ic non vide = \"$x\""
      }
    }
  }
}
