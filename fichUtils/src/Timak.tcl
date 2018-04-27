set INCLUDES [concat $TCLINCLUDEDIR ../../../c/alladin_md5/src]

set SOURCES(libfichUtils.0.2) {md5.0.2.c}
set LIBS(libfichUtils.0.2) [concat ../../../c/alladin_md5/src/liballadin_md5 $TCLLIB libc]


set SOURCES(msh) mainTcl.c
set    LIBS(msh) [concat ./libfichUtils.0.2 $LIBS(libfichUtils.0.2)]

do -case lib -create lib libfichUtils.0.2
do -case bin -create program msh
do lib bin
