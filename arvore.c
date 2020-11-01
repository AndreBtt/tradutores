#include <stdio.h>
#include <stdlib.h>
#include "arvore.h"

Nodo* criar_nodo(char *tipo) {
	Nodo *novo = (Nodo*) malloc(sizeof(Nodo));
	novo->filhos = NULL;
	novo->tipo = malloc(strlen(tipo) + 1);
	strcpy(novo->tipo, tipo);
	return novo;
}

void add_filho(Nodo *raiz, Nodo *filho) {
	ListaNodo* novo = (ListaNodo*) malloc(sizeof(ListaNodo));
	novo->val = filho;
	novo->proximo = NULL;
	if (raiz->filhos == NULL) {
		raiz->filhos = novo;
	} else {
		ListaNodo *ultimoFilho = raiz->filhos;
		while (ultimoFilho->proximo) ultimoFilho = ultimoFilho->proximo;
		ultimoFilho->proximo = novo;
	}
}

void mostrar_arvore(Nodo *raiz, int profundidade) {
	int i;
	for (i = 0; i < profundidade-1; i++) printf(" |");
	printf(" %s\n", raiz->tipo);
	ListaNodo *filhoAtual = raiz->filhos;
	while (filhoAtual != NULL) {
		mostrar_arvore(filhoAtual->val, profundidade+1);
		filhoAtual = filhoAtual->proximo;
	}
	if (raiz->filhos != NULL) {
		for (i = 0; i < profundidade-1; i++) printf(" |");
		printf(" \n");
	}
}

void liberar_arvore(Nodo *raiz) {
	ListaNodo *filhoAtual = raiz->filhos;
	while (filhoAtual != NULL) {
		liberar_arvore(filhoAtual->val);
		filhoAtual = filhoAtual->proximo;
	}
	free(raiz);
}
