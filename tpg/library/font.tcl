package provide tpgFont 0.1


tpg::Struct::new a_maj
set c [tpg::Chemin::newFromString {;>10;>4^15;>11;I^10;E<7;>7^27;I^18;E<5;<20v70;}]
tpg::Struct::newBoundary a_maj $c $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary a_maj [tpg::Chemin::translated 50 0 [tpg::Chemin::transformed miroir.axey $c]]  $enCours(layer) $enCours(datatype)

# displayWinStruct a_maj 1

tpg::Struct::new b_maj
set ce [tpg::Chemin::newFromString {;>42;>8^8;^12;I<10;Ev10;<30;^10;I<10;Ev20;}]
set ci [tpg::Chemin::newFromString {y=20;I>10;E^10;>22;>8v8;v2;I>10;E^7;<8^8;I<42;Ev15;}]
tpg::Struct::newBoundary b_maj $ce $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary b_maj $ci $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary b_maj [tpg::Chemin::translated 0 70 [tpg::Chemin::transformed miroir.axex $ci]] $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary b_maj [tpg::Chemin::translated 0 70 [tpg::Chemin::transformed miroir.axex $ce]] $enCours(layer) $enCours(datatype)

tpg::Struct::new c_maj
tpg::boundary {x=15;>31;>8^8;^7;<10;v5;<20;<10^10;^30;>10^10;>20;v5;>10;^7;<8^8;<31;<15v15;v40;>15v15;}

tpg::Struct::new e_maj
tpg::boundary {;>50;^10;<40;^20;>15;^10;<15;^20;>40;^10;<50;v70;}

tpg::Struct::new l_maj
tpg::boundary {;>50;^10;<40;^60;<10;v70;}

tpg::Struct::new m_maj
tpg::boundary {;>10;^50;>15v25;>15^25;v50;>10;^70;<10;<15v25;<15^25;<10;v70;}

tpg::Struct::new n_maj
tpg::boundary {;>10;^50;>30v50;>10;^70;<10;v50;<30^50;<10;v70;}

tpg::Struct::new q_maj
set c [tpg::Chemin::newFromString {x=15;>20;>15^15;^20;I<10;Ev15;<10v10;<10;<10^10;^15;I<10;Ev20;>15v15;}]
tpg::Struct::newBoundary q_maj $c $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary q_maj [tpg::Chemin::translated 0 70 [tpg::Chemin::transformed miroir.axex $c]] $enCours(layer) $enCours(datatype)
tpg::boundary {x=40;<15^20;>10;>15v20;<10;}

tpg::Struct::new r_maj
tpg::boundary {x=10y=40;Iv10;>10;E>22;>8^8;^2;I<10;E<30;}
tpg::boundary {;>10;^26;I^14;E^20;>30;v20;I>10;E^22;<8^8;<42;v70;}
tpg::boundary {x=50;<30^30;I<10;v4;E>26v26;>14;}

tpg::Struct::new s_maj
tpg::boundary {y=15;v7;>8v8;>34;>8^8;^24;<8^8;<32;^20;>30;v5;>10;^7;<8^8;<34;<8v8;v24;>8v8;>32;v20;<30;^5;<10;}

tpg::Struct::new t_maj
tpg::boundary {x=20;>10;^60;>20;^10;<50;v10;>20;v60;}

tpg::Struct::new u_maj
tpg::boundary {x=8;>34;>8^8;^62;<10;v60;<30;^60;<10;v62;>8v8;}

tpg::Struct::new tiret
tpg::boundary  {x=10 y=30;>30;^10;<30;v10;}

tpg::Struct::new slash
tpg::boundary {;>12;>38^70;<12;<38v70;}

tpg::Struct::new deux_points
set c [tpg::Chemin::newFromString {x=20 y=15;>10;^10;<10;v10;}]
tpg::Struct::newBoundary deux_points $c $enCours(layer) $enCours(datatype)
tpg::Struct::newBoundary deux_points  [tpg::Chemin::translated 0 30 $c] $enCours(layer) $enCours(datatype)

# \ Chiffres
# \ =========

tpg::Struct::new ch_1
tpg::boundary {;>50;^10;<20;^60;<10;<10v5;v5;>10;v50;<20;v10;}
  
tpg::Struct::new ch_2
tpg::boundary {;>50;^10;<40;>40^40;^12;<8^8;<34;<8v8;v7;>10;^5;>30;v6;<40v40;v14;}
  
tpg::Struct::new ch_3
tpg::boundary {y=15;v7;>8v8;>34;>8^8;^23;<4^4;>4^4;^23;<8^8;<34;<8v8;v7;>10;^5;>30;v20;<10;v10;>10;v20;<30;^5;<10;}
  
tpg::Struct::new ch_4
tpg::boundary {x=25;>10;^20;>15;^10;<15;^10;<10;v10;<15;^40;<10;v50;>25;v20;}
  
tpg::Struct::new ch_5
tpg::boundary {y=15;v7;>8v8;>34;>8^8;^24;<8^8;<32;^20;>40;^10;<50;v32;>8v8;>32;v20;<30;^5;<10;}
   
tpg::Struct::new ch_6
tpg::boundary {x=10y=30;>30;v10;I>10;E^12;<8^8;<32;^20;>5;^10;<7;<8v8;v42;I>10;E^10;}
tpg::boundary {x=0y=20;v12;>8v8;>34;>8^8;^12;I<10;Ev10;<30;^10;I<10;}
  
tpg::Struct::new ch_7
tpg::boundary {x=10;>10;^20;>30^30;^20;<50;v10;>40;v8;<30v30;v22;}

tpg::Struct::new ch_8
tpg::boundary {y=10;I>10;E^20;I<10;Ev20;}
tpg::boundary {x=40y=10;I>10;E^20;I<10;Ev20;}
tpg::boundary {y=40;I>10;E^20;I<10;Ev20;}
tpg::boundary {x=40y=40;I>10;E^20;I<10;Ev20;}
tpg::boundary {x=8;>34;>8^8;^2;I<10;E<30;I<10;Ev2;>8v8;}
tpg::boundary {y=60;I>10;E>30;I>10;E^2;<8^8;<34;<8v8;v2;}
tpg::boundary {y=30;I>10;E>30;I>10;E^1;<4^4;>4^4;^1;I<10;E<30;I<10;Ev1;>4v4;<4v4;v1;}

tpg::Struct::new ch_9
tpg::boundary {y=15;v7;>8v8;>34;>8^8;^54;<8^8;<34;<8v8;v22;I>10;E^20;>30;v20;Iv10;Ev20;<30;^5;<10;}
tpg::boundary {y=40;v2;>8v8;>32;I^10;E<30;I<10;}

tpg::Struct::new ch_0
tpg::boundary {y=10;v2;>8v8;>34;>8^8;^54;<8^8;<34;<8v8;v2;I>10;E>30;v50;<30;I<10;}
tpg::boundary {y=10;I>10;E^50;I<10;Ev50;}

set rien {
\ Sigles
\ =======
: cinquantefois ( x y -- x y )
  50 * SWAP 50 * SWAP
;
: nfois ( x y n -- nx ny )
  DUP ROT * ROT * SWAP
;
: fois08 ( x y n -- x y )
  80 * 100 / SWAP 80 * 100 / SWAP
;
: miroir.45 ( x y -- x y )
  SWAP
;
: deuxdivise
  2 / SWAP 2 / SWAP
;

}



tpg::Struct::new fico

tpg::boundary {;>14;>56^70;<14;<56v70;} ;# Barre du phi

set c [list]

set rien {
lappend c 
   DUP EXTERNE 70 35 cpa                      \ Cercle du phi
   DUP EXTERNE 0 180 20 35 35 35 chemin+arc_de_cercle
   DUP INTERNE 10 35 cpa
   DUP EXTERNE 180 0 20 35 35 25 chemin+arc_de_cercle
   DUP chemin.supprime.doubles                \ supprime des doublons
   DUP INTERNE 70 35 cpa                      \ ajoute un doublon final pour c>b
   DUP c>b
   DUP ' miroir.axex tpg::Chemin::transformed
   DUP 0 70 tpg::Chemin::translated
   DUP c>b chemin.delete
  "tpg::Chemin::newFromString
   DUP INTERNE 60 60 cpa                       \ C
   DUP EXTERNE 45 180 20 35 35 35 chemin+arc_de_cercle
   DUP INTERNE 10 35 cpa
   DUP EXTERNE 180 45 20 35 35 25 chemin+arc_de_cercle
   DUP chemin.supprime.doubles
   DUP INTERNE 60 60 cpa
   DUP 70 0 tpg::Chemin::translated
   DUP c>b
   DUP ' miroir.axex tpg::Chemin::transformed
   DUP 0 70 tpg::Chemin::translated
   DUP c>b chemin.delete
  "tpg::Chemin::newFromString
   DUP INTERNE 40 20 cpa                       \ petit o
   DUP EXTERNE 0 180 10 20 20 20 chemin+arc_de_cercle
   DUP INTERNE 10 20 cpa
   DUP EXTERNE 180 0 10 20 20 10 chemin+arc_de_cercle
   DUP chemin.supprime.doubles
   DUP INTERNE 40 20 cpa
   DUP 123 0 tpg::Chemin::translated
   DUP c>b
   DUP ' miroir.axex tpg::Chemin::transformed
   DUP 0 40 tpg::Chemin::translated
   DUP c>b chemin.delete

}

# Structure contenant tous les caracteres. Elle permet de redefinir leur dimensions.
# par "dilateStruct $facteur $structure $profondeur"

tpg::Struct::new font


set li 0
set liste [list ch_1 ch_2 ch_3 ch_4 ch_5 ch_6 ch_7 ch_8 ch_9 ch_0 \
         a_maj b_maj c_maj e_maj l_maj m_maj n_maj q_maj r_maj s_maj t_maj u_maj \
         tiret slash deux_points fico]

# set liste [list ch_1 ch_2]
foreach s $liste {
    tpg::Struct::newSref font $s 0 $li
    incr li 100
}
# displayWinStruct font 1


set rien {

tpg::Struct::new abc
newSref abc a_maj 0 0
newSref abc b_maj 60 0
newSref abc c_maj 120 0

tpg::Struct::new toto

newSref toto abc 0 0
newSref toto abc 200 0
newSref toto abc 0 100
newSref toto abc 200 100

set c [tpg::Chemin::newFromString {;>2;^2;<2;v2;}]
for {set i -20} {$i<20} {incr i 10} {
    for {set j -20} {$j<20} {incr j 10} {
        tpg::Struct::newBoundary toto [tpg::Chemin::translated $i $j $c]
    }
    puts $i
    update
}
for {set i 0} {$i<1000} {incr i 100} {
    for {set j 0} {$j<20000} {incr j 200} {
        newSref toto abc $j $i
    }
    puts $i
    update
    
}
puts fini
}

set rien {
\ Lettres
\ ========

new.struct a_maj
  "new.chemin ;>10;>4^15;>11;I^10;E<7;>7^27;I^18;E<5;<20v70;"
   DUP c>b 
   DUP ' miroir.axey chemin.transforme
   DUP 50 0 chemin.translate
   DUP c>b chemin.delete

new.struct b_maj
  "new.chemin ;>42;>8^8;^12;I<10;Ev10;<30;^10;I<10;Ev20;"
   DUP c>b
  "new.chemin y=20;I>10;E^10;>22;>8v8;v2;I>10;E^7;<8^8;I<42;Ev15;"
   DUP c>b
   DUP ' miroir.axex chemin.transforme
   DUP 0 70 chemin.translate
   DUP c>b chemin.delete
   DUP ' miroir.axex chemin.transforme
   DUP 0 70 chemin.translate
   DUP c>b chemin.delete

new.struct c_maj
  "new.chemin x=15;>31;>8^8;^7;<10;v5;<20;<10^10;^30;>10^10;>20;v5;>10;^7;<8^8;<31;<15v15;v40;>15v15;"
   DUP c>b chemin.delete

new.struct e_maj
  "new.chemin ;>50;^10;<40;^20;>15;^10;<15;^20;>40;^10;<50;v70;"
   DUP c>b chemin.delete

new.struct l_maj
  "new.chemin ;>50;^10;<40;^60;<10;v70;"
   DUP c>b chemin.delete

new.struct m_maj
  "new.chemin ;>10;^50;>15v25;>15^25;v50;>10;^70;<10;<15v25;<15^25;<10;v70;"
   DUP c>b chemin.delete

new.struct n_maj
  "new.chemin ;>10;^50;>30v50;>10;^70;<10;v50;<30^50;<10;v70;"
   DUP c>b chemin.delete

new.struct q_maj
  "new.chemin x=15;>20;>15^15;^20;I<10;Ev15;<10v10;<10;<10^10;^15;I<10;Ev20;>15v15;"
   DUP c>b
   DUP ' miroir.axex chemin.transforme
   DUP 0 70 chemin.translate
   DUP c>b chemin.delete
  "new.chemin x=40;<15^20;>10;>15v20;<10;"
   DUP c>b chemin.delete

new.struct r_maj
  "new.chemin x=10y=40;Iv10;>10;E>22;>8^8;^2;I<10;E<30;"
   DUP c>b chemin.delete
  "new.chemin ;>10;^26;I^14;E^20;>30;v20;I>10;E^22;<8^8;<42;v70;"
   DUP c>b chemin.delete
  "new.chemin x=50;<30^30;I<10;v4;E>26v26;>14;"
   DUP c>b chemin.delete

new.struct s_maj
  "new.chemin y=15;v7;>8v8;>34;>8^8;^24;<8^8;<32;^20;>30;v5;>10;^7;<8^8;<34;<8v8;v24;>8v8;>32;v20;<30;^5;<10;"
   DUP c>b chemin.delete

new.struct t_maj
  "new.chemin x=20;>10;^60;>20;^10;<50;v10;>20;v60;"
   DUP c>b chemin.delete

new.struct u_maj
  "new.chemin x=8;>34;>8^8;^62;<10;v60;<30;^60;<10;v62;>8v8;"
   DUP c>b chemin.delete

new.struct tiret
  "new.chemin y=30;>30;^10;<30;v10;"
   DUP c>b chemin.delete

new.struct slash
  "new.chemin ;>12;>38^70;<12;<38v70;"
   DUP c>b chemin.delete

new.struct deux_points
  "new.chemin x=20 y=15;>10;^10;<10;v10;"
   DUP c>b
   DUP 0 30 chemin.translate
   DUP c>b chemin.delete

\ Chiffres
\ =========

new.struct ch_1
  "new.chemin ;>50;^10;<20;^60;<10;<10v5;v5;>10;v50;<20;v10;"
   DUP c>b chemin.delete
  
new.struct ch_2
  "new.chemin ;>50;^10;<40;>40^40;^12;<8^8;<34;<8v8;v7;>10;^5;>30;v6;<40v40;v14;"
   DUP c>b chemin.delete
  
new.struct ch_3
  "new.chemin y=15;v7;>8v8;>34;>8^8;^23;<4^4;>4^4;^23;<8^8;<34;<8v8;v7;>10;^5;>30;v20;<10;v10;>10;v20;<30;^5;<10;"
   DUP c>b chemin.delete
  
new.struct ch_4
  "new.chemin x=25;>10;^20;>15;^10;<15;^10;<10;v10;<15;^40;<10;v50;>25;v20;"
   DUP c>b chemin.delete
  
new.struct ch_5
  "new.chemin y=15;v7;>8v8;>34;>8^8;^24;<8^8;<32;^20;>40;^10;<50;v32;>8v8;>32;v20;<30;^5;<10;"
    DUP c>b chemin.delete
  
new.struct ch_6
  "new.chemin x=10y=30;>30;v10;I>10;E^12;<8^8;<32;^20;>5;^10;<7;<8v8;v42;I>10;E^10;"
   DUP c>b chemin.delete
  "new.chemin x=0y=20;v12;>8v8;>34;>8^8;^12;I<10;Ev10;<30;^10;I<10;"
   DUP c>b chemin.delete
  
new.struct ch_7
  "new.chemin x=10;>10;^20;>30^30;^20;<50;v10;>40;v8;<30v30;v22;"
   DUP c>b chemin.delete

new.struct ch_8
  "new.chemin y=10;I>10;E^20;I<10;Ev20;"
   DUP c>b chemin.delete
  "new.chemin x=40y=10;I>10;E^20;I<10;Ev20;"
   DUP c>b chemin.delete
  "new.chemin y=40;I>10;E^20;I<10;Ev20;"
   DUP c>b chemin.delete
  "new.chemin x=40y=40;I>10;E^20;I<10;Ev20;"
   DUP c>b chemin.delete
  "new.chemin x=8;>34;>8^8;^2;I<10;E<30;I<10;Ev2;>8v8;"
   DUP c>b chemin.delete
  "new.chemin y=60;I>10;E>30;I>10;E^2;<8^8;<34;<8v8;v2;"
   DUP c>b chemin.delete
  "new.chemin y=30;I>10;E>30;I>10;E^1;<4^4;>4^4;^1;I<10;E<30;I<10;Ev1;>4v4;<4v4;v1;"
   DUP c>b chemin.delete

new.struct ch_9
  "new.chemin y=15;v7;>8v8;>34;>8^8;^54;<8^8;<34;<8v8;v22;I>10;E^20;>30;v20;Iv10;Ev20;<30;^5;<10;"
   DUP c>b chemin.delete
  "new.chemin y=40;v2;>8v8;>32;I^10;E<30;I<10;"
   DUP c>b chemin.delete

new.struct ch_0
  "new.chemin y=10;v2;>8v8;>34;>8^8;^54;<8^8;<34;<8v8;v2;I>10;E>30;v50;<30;I<10;"
   DUP c>b chemin.delete
  "new.chemin y=10;I>10;E^50;I<10;Ev50;"
   DUP c>b chemin.delete

\ Sigles
\ =======
: cinquantefois ( x y -- x y )
  50 * SWAP 50 * SWAP
;
: nfois ( x y n -- nx ny )
  DUP ROT * ROT * SWAP
;
: fois08 ( x y n -- x y )
  80 * 100 / SWAP 80 * 100 / SWAP
;
: miroir.45 ( x y -- x y )
  SWAP
;
: deuxdivise
  2 / SWAP 2 / SWAP
;

new.struct fico
  "new.chemin ;>14;>56^70;<14;<56v70;"        \ Barre du phi
   DUP c>b chemin.delete
  "new.chemin
   DUP EXTERNE 70 35 cpa                      \ Cercle du phi
   DUP EXTERNE 0 180 20 35 35 35 chemin+arc_de_cercle
   DUP INTERNE 10 35 cpa
   DUP EXTERNE 180 0 20 35 35 25 chemin+arc_de_cercle
   DUP chemin.supprime.doubles                \ supprime des doublons
   DUP INTERNE 70 35 cpa                      \ ajoute un doublon final pour c>b
   DUP c>b
   DUP ' miroir.axex chemin.transforme
   DUP 0 70 chemin.translate
   DUP c>b chemin.delete
  "new.chemin
   DUP INTERNE 60 60 cpa                       \ C
   DUP EXTERNE 45 180 20 35 35 35 chemin+arc_de_cercle
   DUP INTERNE 10 35 cpa
   DUP EXTERNE 180 45 20 35 35 25 chemin+arc_de_cercle
   DUP chemin.supprime.doubles
   DUP INTERNE 60 60 cpa
   DUP 70 0 chemin.translate
   DUP c>b
   DUP ' miroir.axex chemin.transforme
   DUP 0 70 chemin.translate
   DUP c>b chemin.delete
  "new.chemin
   DUP INTERNE 40 20 cpa                       \ petit o
   DUP EXTERNE 0 180 10 20 20 20 chemin+arc_de_cercle
   DUP INTERNE 10 20 cpa
   DUP EXTERNE 180 0 10 20 20 10 chemin+arc_de_cercle
   DUP chemin.supprime.doubles
   DUP INTERNE 40 20 cpa
   DUP 123 0 chemin.translate
   DUP c>b
   DUP ' miroir.axex chemin.transforme
   DUP 0 40 chemin.translate
   DUP c>b chemin.delete

\ Structure contenant tous les caracteres. Elle permet de redefinir leur dimensions.

new.struct font
0 0 sref ch_1
0 0 sref ch_2
0 0 sref ch_3
0 0 sref ch_4
0 0 sref ch_5
0 0 sref ch_6
0 0 sref ch_7
0 0 sref ch_8
0 0 sref ch_9
0 0 sref ch_0
0 0 sref a_maj
0 0 sref b_maj
0 0 sref c_maj
0 0 sref e_maj
0 0 sref l_maj
0 0 sref m_maj
0 0 sref n_maj
0 0 sref q_maj
0 0 sref r_maj
0 0 sref s_maj
0 0 sref t_maj
0 0 sref u_maj
0 0 sref tiret
0 0 sref slash
0 0 sref deux_points
0 0 sref fico

0123456789
ABCDEFGHIJ

}
