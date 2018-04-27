package require fidev
package require blasObj 0.2
package require slatec 0.2

set n      5
set x      [::blas::vector create double {0.1 1.0 10.0 20.0 30.0}]
set y      [::blas::vector create double {2.1 11.02 101.03 201.04 301.05}]
set w      [::blas::vector create double {1. 1. 1. 1. 1.}]
set maxdeg 2
set eps    0.
set r      [::blas::vector create double -length 10]
set a      [::blas::vector create double -length [expr 3*$n+3*$maxdeg+3]]

# Fit discrete data in a least squares sense by polynomials

#     Abstract

#     Given a collection of points X(I) and a set of values Y(I) which
#     correspond to some function or measurement at each of the X(I),
#     subroutine  DPOLFT  computes the weighted least-squares polynomial
#     fits of all degrees up to some degree either specified by the user
#     or determined by the routine.  The fits thus obtained are in
#     orthogonal polynomial form.  Subroutine  DP1VLU  may then be
#     called to evaluate the fitted polynomials and any of their
#     derivatives at any point.  The subroutine  DPCOEF  may be used to
#     express the polynomial fits as powers of (X-C) for any specified
#     point C.

#     The parameters for  DPOLFT  are

#     Input -- All TYPE REAL variables are DOUBLE PRECISION
#         N -      the number of data points.  The arrays X, Y and W
#                  must be dimensioned at least  N  (N .GE. 1).
#         X -      array of values of the independent variable.  These
#                  values may appear in any order and need not all be
#                  distinct.
#         Y -      array of corresponding function values.
#         W -      array of positive values to be used as weights.  If
#                  W(1) is negative,  DPOLFT  will set all the weights
#                  to 1.0, which means unweighted least squares error
#                  will be minimized.  To minimize relative error, the
#                  user should set the weights to:  W(I) = 1.0/Y(I)**2,
#                  I = 1,...,N .
#         MAXDEG - maximum degree to be allowed for polynomial fit.
#                  MAXDEG  may be any non-negative integer less than  N.
#                  Note -- MAXDEG  cannot be equal to  N-1  when a
#                  statistical test is to be used for degree selection,
#                  i.e., when input value of  EPS  is negative.
#         EPS -    specifies the criterion to be used in determining
#                  the degree of fit to be computed.
#                  (1)  If  EPS  is input negative,  DPOLFT  chooses the
#                       degree based on a statistical F test of
#                       significance.  One of three possible
#                       significance levels will be used:  .01, .05 or
#                       .10.  If  EPS=-1.0 , the routine will
#                       automatically select one of these levels based
#                       on the number of data points and the maximum
#                       degree to be considered.  If  EPS  is input as
#                       -.01, -.05, or -.10, a significance level of
#                       .01, .05, or .10, respectively, will be used.
#                  (2)  If  EPS  is set to 0.,  DPOLFT  computes the
#                       polynomials of degrees 0 through  MAXDEG .
#                  (3)  If  EPS  is input positive,  EPS  is the RMS
#                       error tolerance which must be satisfied by the
#                       fitted polynomial.  DPOLFT  will increase the
#                       degree of fit until this criterion is met or
#                       until the maximum degree is reached.

#     Output -- All TYPE REAL variables are DOUBLE PRECISION
#         NDEG -   degree of the highest degree fit computed.
#         EPS -    RMS error of the polynomial of degree  NDEG .
#         R -      vector of dimension at least NDEG containing values
#                  of the fit of degree  NDEG  at each of the  X(I) .
#                  Except when the statistical test is used, these
#                  values are more accurate than results from subroutine
#                  DP1VLU  normally are.
#         IERR -   error flag with the following possible values.
#             1 -- indicates normal execution, i.e., either
#                  (1)  the input value of  EPS  was negative, and the
#                       computed polynomial fit of degree  NDEG
#                       satisfies the specified F test, or
#                  (2)  the input value of  EPS  was 0., and the fits of
#                       all degrees up to  MAXDEG  are complete, or
#                  (3)  the input value of  EPS  was positive, and the
#                       polynomial of degree  NDEG  satisfies the RMS
#                       error requirement.
#             2 -- invalid input parameter.  At least one of the input
#                  parameters has an illegal value and must be corrected
#                  before  DPOLFT  can proceed.  Valid input results
#                  when the following restrictions are observed
#                       N .GE. 1
#                       0 .LE. MAXDEG .LE. N-1  for  EPS .GE. 0.
#                       0 .LE. MAXDEG .LE. N-2  for  EPS .LT. 0.
#                       W(1)=-1.0  or  W(I) .GT. 0., I=1,...,N .
#             3 -- cannot satisfy the RMS error requirement with a
#                  polynomial of degree no greater than  MAXDEG .  Best
#                  fit found is of degree  MAXDEG .
#             4 -- cannot satisfy the test for significance using
#                  current value of  MAXDEG .  Statistically, the
#                  best fit found is of order  NORD .  (In this case,
#                  NDEG will have one of the values:  MAXDEG-2,
#                  MAXDEG-1, or MAXDEG).  Using a higher value of
#                  MAXDEG  may result in passing the test.
#         A -      work and output array having at least 3N+3MAXDEG+3
#                  locations

#     Note - DPOLFT  calculates all fits of degrees up to and including
#            NDEG .  Any or all of these fits can be evaluated or
#            expressed as powers of (X-C) using  DP1VLU  and  DPCOEF
#            after just one call to  DPOLFT .

#***REFERENCES  L. F. Shampine, S. M. Davenport and R. E. Huddleston,
#                 Curve fitting by polynomials in one variable, Report
#                 SLA-74-0270, Sandia Laboratories, June 1974.

::slatec::dpolft $x $y $w $maxdeg ndeg eps r ierr a

puts $ndeg

# il faut $l <= $ndeg
set l 1
set c 0.0
set tc     [::blas::vector create double -length 2]

# Convert the DPOLFT coefficients to Taylor series form

#     Abstract

#     DPOLFT  computes the least squares polynomial fit of degree  L  as
#     a sum of orthogonal polynomials.  DPCOEF  changes this fit to its
#     Taylor expansion about any point  C , i.e. writes the polynomial
#     as a sum of powers of (X-C).  Taking  C=0.  gives the polynomial
#     in powers of X, but a suitable non-zero  C  often leads to
#     polynomials which are better scaled and more accurately evaluated.

#     The parameters for  DPCOEF  are

#     INPUT -- All TYPE REAL variables are DOUBLE PRECISION
#         L -      Indicates the degree of polynomial to be changed to
#                  its Taylor expansion.  To obtain the Taylor
#                  coefficients in reverse order, input  L  as the
#                  negative of the degree desired.  The absolute value
#                  of L  must be less than or equal to NDEG, the highest
#                  degree polynomial fitted by  DPOLFT .
#         C -      The point about which the Taylor expansion is to be
#                  made.
#         A -      Work and output array containing values from last
#                  call to  DPOLFT .

#     OUTPUT -- All TYPE REAL variables are DOUBLE PRECISION
#         TC -     Vector containing the first LL+1 Taylor coefficients
#                  where LL=ABS(L).  If  L.GT.0 , the coefficients are
#                  in the usual Taylor series order, i.e.
#                    P(X) = TC(1) + TC(2)*(X-C) + ... + TC(N+1)*(X-C)**N
#                  If L .LT. 0, the coefficients are in reverse order,
#                  i.e.
#                    P(X) = TC(1)*(X-C)**N + ... + TC(N)*(X-C) + TC(N+1)

#***REFERENCES  L. F. Shampine, S. M. Davenport and R. E. Huddleston,
#                 Curve fitting by polynomials in one variable, Report
#                 SLA-74-0270, Sandia Laboratories, June 1974.

::slatec::dpcoef $l $c tc $a

puts $r
puts $tc ;# a0 + a1*x


set rien {
    set m [oneOf 1 2] ;# choix de la fonction + ou -
    set kode [oneOf 1 2] ;# choix de la normalisation
       # 1 -> CY((L-1)=0,...,N-1)=H(M,FNU+(L-1),Z)
       # 2 -> CY((L-1)=0,...,N-1)=H(M,FNU+(L-1),Z)*exp(-(3-2*M)*Z*i)
    set z [aDoubleComplex]
    set zr [complexes::real $z]
    set zi [complexes::imag $z]
    
    set fnu [aDouble >= 0]

    set n [aInt >= 1]

    set cyr [blas::newVector double -length $n]
    set cyi [blas::newVector double -length $n]

    ::slatec::zbesh $zr $zi $fnu $kode $n cyr cyi nz ierr

}



