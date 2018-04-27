set INCLUDES [list /prog/mysql/include/mysql $TCLINCLUDEDIR ]

set SOURCES(libmysqltcl.2.0) mysqltcl.2.0.c
set SOURCES(mysqltclsh) mysqltclsh.c
set SOURCES(mysqlwish) mysqlwish.c

set LIBS(libmysqltcl.2.0) [concat\
     /prog/mysql/lib/mysql/libmysqlclient\
     $TCLLIB\
     libc]

set LIBS(mysqltclsh) [concat\
     ./libmysqltcl.2.0\
     $LIBS(libmysqltcl.2.0) $TCLLIB]

set LIBS(mysqlwish) [concat\
     ./libmysqltcl.2.0\
     $LIBS(libmysqltcl.2.0) $TKLIB $TCLLIB]

do -create lib libmysqltcl.2.0
do -create program mysqltclsh
do -create program mysqlwish
