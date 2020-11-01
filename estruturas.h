#ifndef ESTRUTURAS
#define ESTRUTURAS

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Simbolo Simbolo;
typedef struct ListaSimbolo ListaSimbolo;
typedef struct Token Token;
typedef struct ListaNodo ListaNodo;
typedef struct Nodo Nodo;

char* buscarToken(char*);
char erroGlobal[2000000];

struct Token {
	int linha, coluna, escopo;
	char *lexema;
};

struct ListaNodo {
	Nodo *val;
	ListaNodo *proximo;
};

struct Nodo {
	ListaNodo *filhos;
	char* tipo;
};

struct Simbolo {
	char token[20];
	char lexema[34];
	int linha, coluna, escopo;
	Simbolo *proximo;
};

struct ListaSimbolo {
	Simbolo *primeiro;
};

#endif