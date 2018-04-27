package require fidev
package require blasObj 0.2
package require scpack 0.2

set w [blas::vector create doublecomplex {-2 1 -2 0 0 0 0 2 -1 2 -1 1}]
set n [blas::vector length $w]
set betam [blas::vector create double -length $n]
scpack::angles $w betam
set nptsq 6
set qwork [blas::vector create double -length [expr {(2*$n+3)*$nptsq}]] ;# 460 au maximum
scpack::qinit $betam $nptsq qwork
set iprint 1 ; de -2 a 1 # verbosité
set iguess 0
set tol [expr {pow(10.0, -$nptsq-1)}] ;# * $tailleTypiqueDesSegments}]
set z [blas::vector create doublecomplex -length $n]
set wr -0.5
set wi 0.5 

set rien {
      SUBROUTINE SCSOLV(IPRINT,IGUESS,TOL,ERREST,N,C,Z,WC,
     &   W,BETAM,NPTSQ,QWORK)


   IPRINT  -2,-1,0, OR 1 FOR INCREASING AMOUNTS OF OUTPUT (INPUT)

   IGUESS  1 IF AN INITIAL GUESS FOR Z IS SUPPLIED, OTHERWISE 0
           (INPUT)

   TOL     DESIRED ACCURACY IN SOLUTION OF NONLINEAR SYSTEM
           (INPUT).  RECOMMENDED VALUE: 10.**(-NPTSQ-1) * TYPICAL
           SIZE OF VERTICES W(K)

   ERREST  ESTIMTATED ERROR IN SOLUTION (OUTPUT).  MORE
           PRECISELY, ERREST IS AN APPROXIMATE BOUND FOR HOW FAR
           THE TRUE VERTICES OF THE IMAGE POLYGON MAY BE FROM THOSE
           COMPUTED BY NUMERICAL INTEGRATION USING THE
           NUMERICALLY DETERMINED PREVERTICES Z(K).

   N       NUMBER OF VERTICES OF THE IMAGE POLYGON (INPUT).
           MUST BE .LE. 20

   C       COMPLEX SCALE FACTOR IN FORMULA ABOVE (OUTPUT)

   Z       COMPLEX ARRAY OF PREVERTICES ON THE UNIT CIRCLE.
           DIMENSION AT LEAST N.  IF AN INITIAL GUESS IS
           BEING SUPPLIED IT SHOULD BE IN Z ON INPUT, WITH Z(N)=1.
           IN ANY CASE THE CORRECT PREVERTICES WILL BE IN Z ON OUTPUT.

   WC      COMPLEX IMAGE OF 0 IN THE POLYGON, AS IN ABOVE FORMULA
           (INPUT).  IT IS SAFEST TO PICK WC TO BE AS CENTRAL AS
           POSSIBLE IN THE POLYGON IN THE SENSE THAT AS FEW PARTS
           OF THE POLYGON AS POSSIBLE ARE SHIELDED FROM WC BY
           REENTRANT EDGES.

   W       COMPLEX ARRAY OF VERTICES OF THE IMAGE POLYGON
           (INPUT).  DIMENSION AT LEAST N.  IT IS A GOOD IDEA
           TO KEEP THE W(K) ROUGHLY ON THE SCALE OF UNITY.
           W(K) WILL BE IGNORED WHEN THE VERTEX LIES AT INFINITY;
           SEE BETAM, BELOW.  EACH CONNECTED BOUNDARY COMPONENT
           MUST INCLUDE AT LEAST ONE VERTEX W(K), EVEN IF IT
           HAS TO BE A DEGENERATE VERTEX WITH BETAM(K) = 0.
           W(N) AND W(1) MUST BE FINITE.

   BETAM   REAL ARRAY WITH BETAM(K) THE EXTERNAL ANGLE IN THE
           POLYGON AT VERTEX K DIVIDED BY MINUS PI (INPUT).
           DIMENSION AT LEAST N.  PERMITTED VALUES LIE IN
           THE RANGE -3.LE.BETAM(K).LE.1.  (EXAMPLES: EACH
           BETAM(K) IS -1/2 FOR A RECTANGLE, -2/3 FOR AN EQUI-
           LATERAL TRIANGLE, +1 AT THE END OF A SLIT.)  THE
           SUM OF THE BETAM(K) WILL BE -2 IF THEY HAVE BEEN
           SET CORRECTLY.  BETAM(N-1) SHOULD NOT BE 0 OR 1.
           W(K) LIES AT INFINITY IF AND ONLY IF BETAM(K).LE.-1.

   NPTSQ   THE NUMBER OF POINTS TO BE USED PER SUBINTERVAL
           IN GAUSS-JACOBI QUADRATURE (INPUT).  RECOMMENDED
           VALUE: EQUAL TO ONE MORE THAN THE NUMBER OF DIGITS
           OF ACCURACY DESIRED IN THE ANSWER.  MUST BE THE SAME
           AS IN THE CALL TO QINIT WHICH FILLED THE VECTOR QWORK.

   QWORK   REAL QUADRATURE WORK ARRAY (INPUT).  DIMENSION
           AT LEAST NPTSQ * (2N+3) BUT NO GREATER THAN 460.
           BEFORE CALLING SCSOLV QWORK MUST HAVE BEEN FILLED
           BY SUBROUTINE QINIT.
}

scpack::scsolv $iprint $iguess $tol errest c z $wr $wi $w $betam $nptsq $qwork
 
      # calcul d'un point image

      # détermination d'un point proche

        ::nearz ...

    set ZZ [le_point]
    set Z

    set FZZ [scpack::scsolv $ZZ 0 Z0 W0 K0 $N $C $Z $BETAM $NPTSQ $QWORK]
\end{verbatim}

\end{document}

%%%%%%%%%%%%%%%%%%
% c'est fini ici %
%%%%%%%%%%%%%%%%%%
