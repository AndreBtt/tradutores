#ifndef TABELA
#define TABELA

#include "estruturas.h"

int criar_simbolo(Token);
char* buscar_tipo(Nodo*);
void definir_tipo(int, char*);
void mostrar_tabela();
void liberar_tabela();
Simbolo* buscar_simbolo(char*, int);

void yyerror (char const *);

#endif