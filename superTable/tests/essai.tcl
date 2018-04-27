set lignes [superTable::getLines geom.txt]
set tlimit [superTable::marqueTables $lignes]
foreach i $tlimit {
    puts [lindex $lignes $i]
}
set nameOfTable qwert
superTable::linesOfTable $lignes $tlimit nameOfTable

set nameOfTable *commentaire*
superTable::linesOfTable $lignes $tlimit nameOfTable

set nameOfTable *
superTable::linesOfTable $lignes $tlimit nameOfTable

set nameOfTable *dimensions*
superTable::linesOfTable $lignes $tlimit nameOfTable

set nameOfTable *qq*
superTable::linesOfTable $lignes $tlimit nameOfTable

set nameOfTable *dimensions*
set range [superTable::linesOfTable $lignes $tlimit nameOfTable]
set table [lrange $lignes [expr [lindex $range 0]+1] [lindex $range 1]]
unset a
superTable::readTable $lignes $range a {TYPE}

set nameOfTable *essais*
set range [superTable::linesOfTable $lignes $tlimit nameOfTable]
set table [lrange $lignes [expr [lindex $range 0]+1] [lindex $range 1]]
unset a
superTable::readTable $lignes $range a {TYPE c}
