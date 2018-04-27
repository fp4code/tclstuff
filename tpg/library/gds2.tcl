# \ LOWER-CASE OFF \ Case-sensitive, pour PFE

# ini.error \ pour capter les erreurs gds++

set rien {
INCLUDE reels.4th
INCLUDE fab.4th

\ ****************************
\ Transformations géométriques
\ ****************************

: rotation.90 ( x y -- x y ) NEGATE SWAP ;
: rotation.180 ( x y -- x y ) NEGATE SWAP NEGATE SWAP ;
: rotation.270 ( x y -- x y ) SWAP NEGATE ;
: miroir.axex ( x y -- x y ) NEGATE ;
: miroir.axey ( x y -- x y ) SWAP NEGATE SWAP ;

5 VALUE angle.de.rotation

: rotation.angle.de.rotation ( x y -- x y )
   S>F S>F
   angle.de.rotation S>F 180E F/ FSINCOSPI ( F: y x sin cos )
   FDUP FPICK3 F* FPICK2 FPICK5 F* F- F>I
   FROLL3 F* FROT FROT F* F+ F>I
;
}



SET RIEN {
\ ****************
\ Types de bords
0 CONSTANT EXTERNE \ Bord normal d'un contour
1 CONSTANT INTERNE \ Bord interne, résultant du découpage d'un contour
2 CONSTANT CORRIGE
\ ****************

\ **************************
\ Définitions gds++ commodes 
\ **************************

: ">imprime 
   ini.gds2.standard
   imprime.tout.standard
   fin.gds2.standard
;
}

: gdsout BL PARSE ">imprime ;

0 VALUE structure.en.cours
0 VALUE dose.en.cours
0 VALUE layer.en.cours

: new.struct 
   >IN @ CREATE >IN !
      BL PARSE             ( pnom unom )
      new.STRUCTURE        ( addr )
      DUP TO structure.en.cours
   ,
   DOES> @
;

: struct
   BL PARSE
   EXECUTE
   TO structure.en.cours
;
  
: set.layer ( valeur -- )
   TO layer.en.cours
;
  
: set.dose ( valeur -- )
   TO dose.en.cours
;
  
: "b ( -- )
   [CHAR] " PARSE
   dose.en.cours layer.en.cours structure.en.cours
   ">BOUNDARY
;

: "new.chemin ( -- )
   [CHAR] " PARSE
   ">new.chemin
;

: c>b
   dose.en.cours layer.en.cours structure.en.cours
   chemin>BOUNDARY
;

: sref ( x y -- )
   BL PARSE
   2SWAP
   structure.en.cours
   raw.SREF
;

: aref ( nx ny x1 y1 x2 y2 x3 y3 -- )
   BL PARSE
   9 -ROLL 9 -ROLL
   structure.en.cours
   raw.AREF
;

\ niveau par defaut
0 set.layer

\ dose par defaut
0 set.dose

\ Chemins
\ -------

: cpa  ( adresse_de_chemin correction_de_bord x y -- )
\ Ajoute un point au chemin (Coord. absolues)
   chemin+point
;

: cpr ( adresse_de_chemin correction_de_bord dx dy -- )
\ Ajoute un point au chemin (Coord. relatives)
   3 PICK chemin.getlast ROT + -ROT + SWAP cpa
;

: rectangle.centre ( x/2 y/2 -- adresse_de_contour )
   0 new.chemin LOCALS| ch y/2 x/2 |
   ch EXTERNE x/2 NEGATE y/2 NEGATE chemin+point
   ch EXTERNE x/2        y/2 NEGATE chemin+point
   ch EXTERNE x/2        y/2        chemin+point
   ch EXTERNE x/2 NEGATE y/2        chemin+point
   ch EXTERNE x/2 NEGATE y/2 NEGATE chemin+point
   ch
;

: rectangle.normal ( x y -- adresse_de_contour )
   0 new.chemin LOCALS| ch yy xx |
   ch EXTERNE  0  0 chemin+point
   ch EXTERNE xx  0 chemin+point
   ch EXTERNE xx yy chemin+point
   ch EXTERNE  0 yy chemin+point
   ch EXTERNE  0  0 chemin+point
   ch
;

: rectangle.xy ( x0 y0 dx dy  -- adresse_de_contour )
   0 new.chemin LOCALS| ch dy dx y0 x0 |
   ch EXTERNE x0 y0 cpa
   ch EXTERNE dx         0        cpr
   ch EXTERNE  0        dy        cpr
   ch EXTERNE dx NEGATE  0        cpr
   ch EXTERNE  0        dy NEGATE cpr
   ch
;

: chemin+arc_de_cercle DEVENU appendArc
\  ( adresse_de_contour correction angle_de_debut angle_de_fin Nbre_segments
\    x_centre y_centre rayon  -- )
  LOCALS| r y x ns af ad cor ch |
  ns 0<= ABORT" : le nombre de segments doit etre >0"
  ns 1+ 0                          \ debut=0 fin=n+1
  DO
    af ad - I * S>F ns S>F F/
    ad S>F F+                      \ angle_courant
    M_PI F* 180.E F/ FSINCOS
    r S>F F* F>I x + 
    r S>F F* F>I y +
    ch cor 2SWAP cpa
  LOOP
;
  

: brc ( x/2 y/2 -- ) rectangle.centre DUP c>b chemin.delete ;
: brn ( x y -- ) rectangle.normal DUP c>b chemin.delete ; 
: brxy ( x0 y0 dx dy -- ) rectangle.xy DUP c>b chemin.delete ;

\ 

TRUE [IF]
: copie.struct+prefixe ( structure profondeur '<espaces>prefixe' -- )
  BL PARSE ROT copie.structures
  2DUP name>STRUCTURE -ROT
  ['] VALUE PARSE_FROM_STRING 
;
[THEN]
