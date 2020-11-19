all: start

start: sintatico.tab.o lex.yy.o arvore.o tabela.o estruturas.o main.o
	gcc -g -o semantico lex.yy.o sintatico.tab.o arvore.o tabela.o estruturas.o main.o

main.o:
	gcc -c -o main.o main.c

estruturas.o:
	gcc -c -o estruturas.o estruturas.c

arvore.o: estruturas.o
	gcc -c -o arvore.o arvore.c

tabela.o: estruturas.o
	gcc -c -o tabela.o tabela_simbolos.c

lex.yy.o: lex.yy.c sintatico.tab.c
	gcc -c -o lex.yy.o lex.yy.c

lex.yy.c:
	flex tokens.l

sintatico.tab.o: sintatico.tab.c
	gcc -c -o sintatico.tab.o sintatico.tab.c

sintatico.tab.c:
	bison sintatico.y --report=all

clean:
	rm sintatico sintatico.output sintatico.tab.c sintatico.tab.h lex.yy.c *.o