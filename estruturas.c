#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "estruturas.h"

char* buscar_token(char *s) {
	if(strcmp(s, "int") == 0) return "int";
	if(strcmp(s, "float") == 0) return "float";
	if(strcmp(s, "writeInt") == 0 || strcmp(s, "writeFloat") == 0) return "write";
	if(strcmp(s, "readInt") == 0 || strcmp(s, "readFloat") == 0) return "read";
	if(strcmp(s, "=") == 0) return "Assignment";
	if(strcmp(s, "(") == 0) return "Left parentheses";
	if(strcmp(s, ")") == 0) return "Right parentheses";
	if(strcmp(s, "{") == 0) return "Left brace";
	if(strcmp(s, "}") == 0) return "Right brace";
	if(strcmp(s, "[") == 0) return "Left bracket";
	if(strcmp(s, "]") == 0) return "Right bracket";
	if(strcmp(s, "return") == 0) return "return";
	if(strcmp(s, "if") == 0) return "if";
	if(strcmp(s, "else") == 0) return "else";
	if(strcmp(s, ",") == 0) return "Comma";
	if(strcmp(s, ";") == 0) return "Semicolon";
	if(strcmp(s, "while") == 0) return "while";
	if(strcmp(s, "number") == 0) return "Number";
	if(strcmp(s, "==") == 0) return "Equal operation";
	if(strcmp(s, "List") == 0) return "List";
	if(strcmp(s, "<int>") == 0 || strcmp(s, "<float>") == 0) return "List type";
	if(strcmp(s, "Avg") == 0) return "List operation";
	return "Identifier";
}

Pilha* pilha_pop(Pilha *p) {
	if (p->elemento == NULL) return p;
	PilhaElemento *aux = p->elemento;
	p->elemento = p->elemento->proximo;
	free(aux);
	return p;
}

Pilha* pilha_push(Pilha *p, int val) {
	if (p == NULL) {
		p = (Pilha*) malloc(sizeof(Pilha));
		p->elemento = NULL;
		p->tam = 0;
	}
	PilhaElemento *novoElemento = (PilhaElemento*) malloc(sizeof(PilhaElemento));
	novoElemento->val = val;
	novoElemento->proximo = p->elemento;
	p->elemento = novoElemento;
	p->tam += 1;

	return p;
}
