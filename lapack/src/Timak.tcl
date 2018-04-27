set INCLUDES [list $TCLINCLUDEDIR ../../blas/src]

set SOURCES(libtcllapack) lapack.c 

do default create lib libtcllapack

#${LIBNAME}:${OBJSLIB} 
#	${DO_SO} -o $@ ${OBJSLIB}\
#	    -L${PREFIX}/fortran/blas   ${RP} ${PREFIX}/fortran/blas -lblas \
#	    -L${PREFIX}/fortran/lapack ${RP} ${PREFIX}/fortran/lapack -llapack \
#	    -lm
