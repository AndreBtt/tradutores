#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "tabela_simbolos.h"
#include "estruturas.h"

ListaSimbolo *tabelaSimbolo;

void criar_simbolo(Token t) {
	Simbolo *simbolo = (Simbolo*) malloc(sizeof(Simbolo));
	strcpy(simbolo->token, buscarToken(t.lexema));
	strcpy(simbolo->lexema, t.lexema);
	simbolo->linha = t.linha;
	simbolo->coluna = t.coluna;
	simbolo->proximo = NULL;
	simbolo->escopo = t.escopo;

	if (tabelaSimbolo == NULL) {
		tabelaSimbolo = (ListaSimbolo*) malloc(sizeof(ListaSimbolo));
		tabelaSimbolo->primeiro = simbolo;
	} else {
		Simbolo *aux = tabelaSimbolo->primeiro;
		while (aux->proximo != NULL) aux = aux->proximo;
		aux->proximo = simbolo;
	}
}

Simbolo* buscar_simbolo(char *s, int escopo) {
	if (tabelaSimbolo == NULL) return NULL;

	Simbolo *simbolo = tabelaSimbolo->primeiro;
	while (simbolo != NULL && !(strcmp(simbolo->lexema, s) == 0 && simbolo->escopo == escopo)) {
		simbolo = simbolo->proximo;
	}

	return simbolo;
}

void mostrar_tabela() {
	printf("Tabela de Símbolos\n\n");
	printf(" Linha |       Token       |                 Lexema              |   Escopo\n");
	printf("------------------------------------------------------------------------------\n");
	if (tabelaSimbolo != NULL) {
		Simbolo *simbolo = tabelaSimbolo->primeiro;
		while (simbolo != NULL) {
			printf("%6d | %17s | %35s | %5d \n", simbolo->linha, simbolo->token, simbolo->lexema, simbolo->escopo);
			simbolo = simbolo->proximo;
		}
	}
}

void liberar_tabela() {
	if (tabelaSimbolo != NULL) {
		Simbolo *prev = tabelaSimbolo->primeiro;
		Simbolo *prox = prev->proximo;
		while (prox != NULL) {
			free(prev);
			prev = prox;
			prox = prox->proximo;
		}

		free(prev);
	}
}


void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}