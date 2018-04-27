set INCLUDES [concat $TCLINCLUDEDIR]

set SOURCES(libfoo) {foo.c}
set    LIBS(libfoo) [concat\
	$TCLLIB libc]

set SOURCES(foosh) mainTcl.c
set    LIBS(foosh) [concat\
        ./libfoo\
	$LIBS(libfoo)\
        $GLOBLIBS(dynload)]

do -case lib -create lib libfoo
do -case bin -create program foosh

do lib bin
