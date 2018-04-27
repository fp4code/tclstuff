source superTable.tcl

# avec index

set nameOfTable {*carres*cubes*}
set indexes [superTable::fileToTable a essai2.dat nameOfTable {i}]

foreach i [lsort -integer $indexes] {
    puts "$i $a($i:i3)"
}
# affiche en deux colonnes les valeurs $i et ($i)**3

# sans index

unset a
set nameOfTable
set indexes [superTable::fileToTable a essai2.dat nameOfTable {}]

foreach i [lsort -integer $indexes] {
    puts "$i $a($i:i3)"
}

puts $indexes
