
proc boundary {layer datatype xy} {
    # mettre du contrôle
    return [list {} {} $layer $datatype $xy] 
}

proc newStructure {name date} {
    global STRUCTURES
    set S_modif_time($name) $date
    set S_access_time($name) $date

}

set date0 {02 04 22 10 00 00} 

newStructure s20cc $date0


[boundary 0 1 {
    +12000 -20000
    -12000 -20000
    -10000 -10000
    +10000 -10000
    +20000 -12000
    +20000  12000
    +10000  10000
    -10000  10000
    -20000 -20000}]

set b10cc [boundary 0 1 {
    +12000 -20000
    -12000 -20000
    -10000 -10000
     -5000  -5000
      5000  -5000
    +10000 -10000
    +20000 -12000
    +20000  12000
    +10000  10000
      5000   5000
     -5000   5000
    -10000  10000
    -20000 -20000}]

set b10
