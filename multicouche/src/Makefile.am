## Process this file with automake to produce Makefile.in -*-Makefile-*-

INCLUDES = -I@TCLINCLUDEDIR@ ../../blas/src ../../complexes/src ../../trig_sun/src

lib_LTLIBRARIES = libtclmulticouche.la

libtclmulticouche_la_LDFLAGS = -version-info 1:1:1
libtclmulticouche_la_SOURCES = mtc.f multicouche.c

#${LIBNAME}:${OBJSLIB} 
#	${DO_SO} -o $@ ${OBJSLIB}\
#	-L${PREFIX}/Tcl/complexes ${RP} ${PREFIX}/Tcl/complexes -ltclcomplexes \
#	-L${PREFIX}/Tcl/trig_sun ${RP} ${PREFIX}/Tcl/trig_sun -ltcl_trig_sun \
#	-L${PREFIX}/Tcl/horreur ${RP} ${PREFIX}/Tcl/horreur -ltcl_horreur \
#	$(FLIBS) -lm




