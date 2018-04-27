

Produits  $alpha_s $A_m $X_v + $beta_s $Y_v -> Y_v

    Matrice standard. $A peut ÅÍtre transposÅÈe.

        dgemv $alpha $A $X $beta Y

    Banded Matrix,  $A peut ÅÍtre transposÅÈ

        dgbmv $alpha $A $X $beta Y

    Matrice symÅÈtrique extraite d'une Matrice standard

         dsymv $alpha $A $X $beta Y

    Matrice symÅÈtrique extraite d'une Matrice Bande

         dsbmv $alpha $A $X $beta Y

    Matrice symÅÈtrique extraite d'une triangulaire compacte

         dspmv $alpha $A $X $beta Y


$A_m $X_v -> X_v   
    
    Matrice triangulaire dont on poeut rendre la diagonale == 1

        dtrmv  
        dtbmv
        dtpmv

$A_m^-1 $X_v -> X_v sans test de singularitÅÈ

        dtrsv
        dtbsv
        dtpsv

A := alpha*x*y' + A

        dger

A := alpha*x*x' + A,  sur un triangle seulement

        dsyr         forme normale
        dspr         forme compacte

A := alpha*x*y' + alpha*y*x' + A,  sur un triangle seulement

        dsyr2        
        dspr2

