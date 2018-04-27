set PVM_ROOT /prog/pvm3
set PVM_LIB ${PVM_ROOT}/lib
set INCLUDES [list $TCLINCLUDEDIR ../../pvm/src ${PVM_ROOT}/include]

set SOURCES(libtclscilab) {scilab_pvm.c}
set    LIBS(libtclscilab) [list ../../pvm/src/libtclpvm ${PVM_ROOT}/lib/libpvm3 $TCLLIB libc libm]

set SOURCES(scish) mainTcl.c
set    LIBS(scish) [list ./libtclscilab ${PVM_ROOT}/lib/libpvm3 $TCLLIB]

do -case lib -create lib libtclscilab
do -case bin -create program scish
do -case default -do lib               ;# idem "do -do lib"
do -case default -do bin

