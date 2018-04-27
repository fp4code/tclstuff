set libname libtcl_asdex

set INCLUDES [list ${TCLINCLUDEDIR} ../../blas/src ../../horreur/src]

set SOURCES($libname) {asdex.c DioDir.f}
set LIBS($libname) [concat\
	../../../fortran/recipes/src/librecipes\
	../../blas/src/libtcl_blas\
	../../horreur/src/libtcl_horreur\
	$TCLLIB $GLOBLIBS(math) $GLOBLIBS(c)]

do -create lib $libname

set SOURCES(asdexsh) mainTcl.c
set LIBS(asdexsh) [list\
     ../../../fortran/dblas1/src/libdblas1\
     ../../../fortran/zblas1/src/libzblas1\
     ../../../fortran/sblas1/src/libsblas1\
     ../../../fortran/cblas1/src/libcblas1\
    ../../blas/src/libtcl_blas\
    ../../../fortran/recipes/src/librecipes\
    ../../horreur/src/libtcl_horreur\
    ./$libname $TCLLIB]
set SOURCES(wasdexsh) mainTk.c
set LIBS(wasdexsh) [list\
     ../../../fortran/dblas1/src/libdblas1\
     ../../../fortran/zblas1/src/libzblas1\
     ../../../fortran/sblas1/src/libsblas1\
     ../../../fortran/cblas1/src/libcblas1\
     ../../blas/src/libtcl_blas\
    ../../../fortran/recipes/src/librecipes\
    ../../horreur/src/libtcl_horreur\
    ./$libname $TCLLIB $TKLIB]

do -create program asdexsh
do -create program wasdexsh


