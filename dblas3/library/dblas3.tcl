C := alpha*A*B + beta*C,
C := alpha*A*B' + beta*C,
C := alpha*A'*B + beta*C,
C := alpha*A'*B' + beta*C,

        dgemm


C := alpha*A*B + beta*C
C := alpha*B*A + beta*C
A sym�trique extraite d'une matrice standard

    dsymm

C := alpha*A*A' + beta*C,
C := alpha*A'*A + beta*C,
C sym�trique extraite d'une matrice standard

dsyrk
dsyr2k
dtrmm
dtrsm
