set PVM_ROOT /prog/pvm3
set INCLUDES [list $TCLINCLUDEDIR ${PVM_ROOT}/include]

set SOURCES(libtclpvm) {pvm.c}
set    LIBS(libtclpvm) [list  ${PVM_ROOT}/lib/libpvm3 $TCLLIB libc libm]

set SOURCES(pvmsh) mainTcl.c
set    LIBS(pvmsh) [list ./libtclpvm ${PVM_ROOT}/lib/libpvm3 $TCLLIB]

do -case lib -create lib libtclpvm
do -case bin -create program pvmsh
do -case default -do lib               ;# idem "do -do lib"
do -case default -do bin


#	${FC} -o $@ mainTcl.o\
#	    -L${PWD} ${RP} ${PWD} -l${LIB} \
#	    -L${PVM_LIB} ${RP} ${PVM_LIB} -lpvm3 \
#	    ${LTCL} \
#	    -lm

#${LIBNAME}:${OBJSLIB} 
#	${DO_SO} -o $@ ${OBJSLIB}\
#	-L${PVM_LIB} ${RP} ${PVM_LIB} -lpvm3 \
#	-lm -ldl
