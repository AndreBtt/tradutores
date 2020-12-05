#include <stdio.h>
#include <stdlib.h>
#include "arvore.h"
#include "tabela_simbolos.h"

Nodo* criar_nodo(char *tipo, int id) {
	Nodo *novo = (Nodo*) malloc(sizeof(Nodo));
	novo->filhos = NULL;
	novo->id = id;
	novo->tipo = malloc(strlen(tipo) + 1);
	novo->temporario = -1;
	novo->label = -1;
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

int verificarTipo(Nodo *raiz, char *tipo) {
	ListaNodo *filhoAtual = raiz->filhos;
	int falha = 0;

	if (filhoAtual == NULL && raiz->id != -1) {
		// uma folha que possui um valor
		Simbolo *simbolo = buscar_simbolo_id(raiz->id);
		falha = conversaoTipo(tipo, simbolo->tipo);
	}

	while (filhoAtual != NULL) {
		falha |= verificarTipo(filhoAtual->val, tipo);
		filhoAtual = filhoAtual->proximo;
	}

	return falha;
}

int conversaoTipo(char *esq, char *dir) {
	if (strcmp(esq, dir) == 0 || (strcmp(esq, "float") == 0 && strcmp(dir, "int") == 0)) return 0;
	return 1;
}

void armazenarTipos(Nodo *raiz, char *tipo) {
	ListaNodo *filhoAtual = raiz->filhos;
	if (filhoAtual == NULL && raiz->id != -1) {
		// uma folha que possui um valor

		Simbolo *simbolo = buscar_simbolo_id(raiz->id);

		if (simbolo->tipo != NULL) {
			// é um vetor
			char *tipoVetor = malloc(strlen(tipo) + 1);
			strcpy(tipoVetor, tipo);
			strcat(tipoVetor, simbolo->tipo);
			definir_tipo(raiz->id, tipo);
		} else {
			// tipo normal
			definir_tipo(raiz->id, tipo);
		}
	}

	while (filhoAtual != NULL) {
		armazenarTipos(filhoAtual->val, tipo);
		filhoAtual = filhoAtual->proximo;
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
