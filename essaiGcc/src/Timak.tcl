all:essai

fonction.o: fonction.c
	/prog/gnu/bin/gcc -fpic -c fonction.c

libfonction.so:fonction.o
	/prog/gnu/bin/gcc -shared -o libfonction.so fonction.o

essai.o:
	/prog/gnu/bin/gcc -c essai.c

essai:essai.o libfonction.so
	/prog/gnu/bin/gcc -o essai essai.o -L . -Xlinker -rpath . libfonction.so


 
