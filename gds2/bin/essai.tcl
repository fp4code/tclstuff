package require fidev
package require gds2 0.3


# ordre des arguments de structure : boundaries paths srefs arefs texts nodes boxes

set time  {2003 10 21 13 28 14}

set b1 [list {} {} 0 2 {0 -500 0 0 500 0 500 -500 0 -500} {}]
set s1 [list $time $time un_carre [list $b1] {} {} {} {} {} {}]

set a1 [list {} {} un_carre {} {10 2} {0 0 10000 0 0 2000} {}]
set s2 [list $time $time reseau_de_carres {} {} {} [list $a1] {} {} {}]

set structures [list $s1 $s2]

set lib [list 5 $time $time essai.DB {} {} {} {} {} {0.001 1e-9} $structures]

gds2::writeToFile $lib ~/Z/t.gds2