set INCLUDES [list $TCLINCLUDEDIR /usr/lib/mpich/include/]

set SOURCES(mpimap) {mpimapAppInit.c CanvasCommands.c MPI2Tcl.c GetMPI2Typemap.c}
set    LIBS(mpimap) [concat libmpi $TKLIB $TCLLIB $GLOBLIBS(math) $GLOBLIBS(c)]

do -case bin -create program mpimap

do  bin
