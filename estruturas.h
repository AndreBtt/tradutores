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
typedef struct Pilha Pilha;
typedef struct PilhaElemento PilhaElemento;

char* buscar_token(char*);
Pilha* pilha_push(Pilha*, int);
Pilha* pilha_pop(Pilha*);
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
	int id, linha, coluna, escopo;
	char *tipo;
	int funcao;
	Pilha *parametros;
	Simbolo *proximo;
};

struct ListaSimbolo {
	Simbolo *primeiro;
};

struct Pilha {
	PilhaElemento *elemento;
	int tam;
};

struct PilhaElemento {
	int val;
	PilhaElemento *proximo;
};

#endif