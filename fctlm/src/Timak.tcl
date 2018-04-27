set libname libfctlm.0.2

set INCLUDES [list ${TCLINCLUDEDIR} ../../blasObj/src ../../fidevObj/src]

set SOURCES($libname) "fctlm.0.2.c dummy.f"
set SOURCES(fctlm) mainTk.c

set LIBS($libname) [list ../../blasObj/src/libtclblasobj.0.2 $TCLLIB libc libm]
set LIBS(fctlm)    [list \
	./$libname\
	../../../fortran/dblas1/src/libdblas1\
	../../../fortran/zblas1/src/libzblas1\
	../../../fortran/sblas1/src/libsblas1\
	../../../fortran/cblas1/src/libcblas1\
\#	../../blas/src/libtcl_blas $TCLLIB $TKLIB\
\#	../../minpack/src/libtclminpack.0.3\
\#	../../../fortran/minpack/src/libminpack\
	libc libm]

do -create lib $libname
do -create program fctlm


#bin_PROGRAMS = fctlm
#fctlm_SOURCES = mainTk.c

#fctlm:mainTk.o ${LIBNAME}
#	$(FC) -o $@ mainTk.o\
#	    -L/prog/Tcl/lib             ${RP} /prog/Tcl/lib             -ltcl${VERS}\
#	    -L/prog/Tcl/lib             ${RP} /prog/Tcl/lib             -ltk${VERS}\
#            ${X11LIBS}\
#	    -L${PREFIX}/Tcl/${LIB}      ${RP} ${PREFIX}/Tcl/${LIB}      -l${LIB}\
#	    -L${PREFIX}/Tcl/minpack     ${RP} ${PREFIX}/Tcl/minpack     -ltclminpack\
#	    -L${PREFIX}/Tcl/blas        ${RP} ${PREFIX}/Tcl/blas        -ltclblas\
#	    -L${PREFIX}/fortran/blas    ${RP} ${PREFIX}/fortran/blas    -lblas\
#	    -L${PREFIX}/fortran/minpack ${RP} ${PREFIX}/fortran/minpack -lminpack\
#	    -lm -ldl\
#	    -L/prog/Tcl/lib             ${RP} /prog/Tcl/lib             -ltk${VERS}\
#
#${LIBNAME}:${OBJSLIB} 
#	${DO_SO} -o $@ ${OBJSLIB}\
#	    -L${PREFIX}/Tcl/minpack ${RP} ${PREFIX}/Tcl/minpack -ltclminpack\
#	    -L${PREFIX}/Tcl/blas ${RP} ${PREFIX}/Tcl/blas -ltclblas\
#	    -lm ${FLIBS}

