#!/usr/local/bin/tclsh

package require fidev
package require blas

if {[string compare test [info procs test]] == 1} then {source /prog/Tcl/tcl/tests/defs}

proc blas0DeleteAll {} {
    set vectors [::blas::listOfVectors]
    foreach v $vectors {
	::blas::deleteVector $v
    }
}

test blas0-init {depart propre} {
    blas0DeleteAll
} {}

##############################################
# constructeurs de vecteurs de taille donnée #
##############################################

test blas0-newVector.float.1 {} {

    set v [::blas::newVector float -length 5]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {0.0 0.0 0.0 0.0 0.0}

test blas0-newVector.double.1 {} {

    set v [::blas::newVector double -length 5]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {0.0 0.0 0.0 0.0 0.0}

test blas0-newVector.complex.1 {} {

    set v [::blas::newVector complex -length 5]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{0.0 0.0} {0.0 0.0} {0.0 0.0} {0.0 0.0} {0.0 0.0}}

test blas0-newVector.doublecomplex.1 {} {

    set v [::blas::newVector doublecomplex -length 5]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{0.0 0.0} {0.0 0.0} {0.0 0.0} {0.0 0.0} {0.0 0.0}}

test blas0-newVector.int.1 {} {

    set v [::blas::newVector int -length 5]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {0 0 0 0 0}

test blas0-newVector.bad.1 {} {
    catch {::blas::newVector bad -length 5} r
    set r
} {bad type "bad": must be float, double, complex, doublecomplex, or int}

##################################################
# constructeurs de vecteurs à partir d'une liste #
##################################################

test blas0-newVector.float.2 {} {

    set v [::blas::newVector float {1 2 3 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {1.0 2.0 3.0 4.0 5.0}

test blas0-newVector.double.2 {} {

    set v [::blas::newVector double {1 2 3 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {1.0 2.0 3.0 4.0 5.0}

test blas0-newVector.complex.2 {} {

    set v [::blas::newVector complex {1 2 3 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{1.0 0.0} {2.0 0.0} {3.0 0.0} {4.0 0.0} {5.0 0.0}}

test blas0-newVector.doublecomplex.2 {} {

    set v [::blas::newVector doublecomplex {1 2 3 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{1.0 0.0} {2.0 0.0} {3.0 0.0} {4.0 0.0} {5.0 0.0}}

test blas0-newVector.int.2 {} {

    set v [::blas::newVector int {1 2 3 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {1 2 3 4 5}

test blas0-newVector.bad.2 {} {
    catch {::blas::newVector bad {1 2 3 4 5}} r
    set r
} {bad type "bad": must be float, double, complex, doublecomplex, or int}


#########################################################
# construction de vecteurs complexes à partir de listes #
#########################################################

test blas0-newVector.complex.3 {} {

    set v [::blas::newVector complex {1 2 {3 30} 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{1.0 0.0} {2.0 0.0} {3.0 30.0} {4.0 0.0} {5.0 0.0}}

test blas0-newVector.doublecomplex.3 {} {

    set v [::blas::newVector doublecomplex {1 2 {3 30} 4 5}]

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {{1.0 0.0} {2.0 0.0} {3.0 30.0} {4.0 0.0} {5.0 0.0}}

##############################################
# constructions à partir de mauvaises listes #
##############################################

test blas0-newVector.bad.5 {} {
    catch {set v [::blas::newVector double {1 2 {3 30} 4 5}]} r
    set r
} {expected floating-point number but got "3 30"}

test blas0-newVector.bad.6 {} {
    catch {set v [::blas::newVector complex {1 2 {3 30} {1 2 3} 5}]} r
    set r
} {expected standard complex number but got "1 2 3"}

test blas0-newVector.bad.7 {} {
    catch {set v [::blas::newVector complex {1 2 {3 30} {1 2f5} 5}]} r
    set r
} {expected floating-point number but got "2f5"}

########################
# récupération du type #
########################

test blas0-getType.float.1 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    set r [::blas::getType $v]

    ::blas::deleteVector $v
    set r
} {float}

test blas0-getType.double.1 {} {
    set v [::blas::newVector double {1 2 3 4 5}]

    set r [::blas::getType $v]

    ::blas::deleteVector $v
    set r
} {double}

test blas0-getType.complex.1 {} {
    set v [::blas::newVector complex {1 2 3 4 5}]

    set r [::blas::getType $v]

    ::blas::deleteVector $v
    set r
} {complex}

test blas0-getType.doublecomplex.1 {} {
    set v [::blas::newVector doublecomplex {1 2 3 4 5}]

    set r [::blas::getType $v]

    ::blas::deleteVector $v
    set r
} {doublecomplex}

test blas0-getType.int.1 {} {
    set v [::blas::newVector int {1 2 3 4 5}]

    set r [::blas::getType $v]

    ::blas::deleteVector $v
    set r
} {int}

#########################################################
# contrôle de la bonne gestion de la table des vecteurs #
#########################################################

test blas0-database.1 {} {
    blas0DeleteAll
    set v1 [::blas::newVector float -length 5]
    set v2 [::blas::newVector float -length 5]
    set v3 [::blas::newVector float -length 5]
    set r [llength [::blas::listOfVectors]]
    blas0DeleteAll
    set r
} 3

test blas0-database.2 {} {
    catch {::blas::deleteVector qaz} r
    set r
} {can not find blasVector named "qaz"}

test blas0-database.3 {} {
    set v1 [::blas::newVector float 5]
    set v2 [::blas::newVector float 5]
    catch {::blas::deleteVector qaz} r
    blas0DeleteAll
    set r
} {can not find blasVector named "qaz"}

####################################################################
# récupération de vecteurs blas à trous (colonne de matrice, etc.) #
####################################################################

# ligne 0 ATTENTION : ordre Fortran, coli
test blas0-vectorSublist.1 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]

    set r [::blas::getVector [list $v 0 4 4]]

    ::blas::deleteVector $v
    set r
} {11.0 12.0 13.0 14.0}

# diagonale
test blas0-vectorSublist.2 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]

    set r [::blas::getVector [list $v 0 5 4]]

    ::blas::deleteVector $v
    set r
} {11.0 22.0 33.0 44.0}

# anti-diagonale
test blas0-vectorSublist.3 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]

    set r [::blas::getVector [list $v 12 -3 4]]

    ::blas::deleteVector $v
    set r
} {14.0 23.0 32.0 41.0}

# bad
test blas0-vectorSublist.bad.1 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]
    catch {::blas::getVector [list $v 0 1 17]} r
    ::blas::deleteVector $v
    set r
} {bad blasVector sublist "0 1 17": out of range}

# bad
test blas0-vectorSublist.bad.2 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]
    catch {::blas::getVector [list $v 0 1]} r
    ::blas::deleteVector $v
    set r
} {"0 1" is not a blasVector sublist}

####################################################################
# modufication de vecteurs blas à trous (colonne de matrice, etc.) #
####################################################################

# ligne 0 ATTENTION : ordre Fortran, coli
test blas0-setVectorSublist.1 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]

    ::blas::setVector [list $v 0 4 4] {111. 112. 113. 114.}

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {111.0 21.0 31.0 41.0 112.0 22.0 32.0 42.0 113.0 23.0 33.0 43.0 114.0 24.0 34.0 44.0}

####

# diagonale
test blas0-setVectorSublist.2 {} {
    set v [::blas::newVector float {11 21 31 41 12 22 32 42 13 23 33 43 14 24 34 44}]

    ::blas::setVector [list $v 0 5 4] {111 122 133 144}

    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {111.0 21.0 31.0 41.0 12.0 122.0 32.0 42.0 13.0 23.0 133.0 43.0 14.0 24.0 34.0 144.0}

####

test blas0-getAtIndex.float.1 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    catch {::blas::getAtIndex $v 0} r

    ::blas::deleteVector $v
    set r
} 1.0

test blas0-getAtIndex.float.2 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    set r [::blas::getAtIndex $v 4]

    ::blas::deleteVector $v
    set r
} 5.0

test blas0-getAtIndex.double.1 {} {
    set v [::blas::newVector double {1 2 3 4 5}]

    set r [::blas::getAtIndex $v 0]

    ::blas::deleteVector $v
    set r
} 1.0

test blas0-getAtIndex.double.2 {} {
    set v [::blas::newVector double {1 2 3 4 5}]

    set r [::blas::getAtIndex $v 4]

    ::blas::deleteVector $v
    set r
} 5.0

test blas0-getAtIndex.complex.1 {} {
    set v [::blas::newVector complex {1 2 3 4 5}]

    set r [::blas::getAtIndex $v 0]

    ::blas::deleteVector $v
    set r
} {1.0 0.0}

test blas0-getAtIndex.complex.2 {} {
    set v [::blas::newVector complex {1 2 3 4 5}]

    set r [::blas::getAtIndex $v 4]

    ::blas::deleteVector $v
    set r
} {5.0 0.0}

test blas0-getAtIndex.bad.1 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    catch {::blas::getAtIndex $v -1} r

    ::blas::deleteVector $v
    set r
} {bad blasVector index -1: out of range}

test blas0-getAtIndex.bad.2 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    catch {::blas::getAtIndex $v 5} r

    ::blas::deleteVector $v
    set r
} {bad blasVector index 5: out of range}

test blas0-getAtIndex.bad.3 {} {
    set v [::blas::newVector float {1 2 3 4 5}]

    catch {::blas::getAtIndex $v -1} r

    ::blas::deleteVector $v
    set r
} {bad blasVector index -1: out of range}

test blas0-setAtIndex.1 {} {
    set v [::blas::newVector float {1 2 3 4 5}]
    ::blas::setAtIndex $v 2 333.0
    set r [::blas::getVector $v]
    ::blas::deleteVector $v
    set r
} {1.0 2.0 333.0 4.0 5.0}

puts "terminé"
