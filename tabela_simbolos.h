#ifndef TABELA
#define TABELA

#include "estruturas.h"

void criar_simbolo(Token);
void mostrar_tabela();
void liberar_tabela();
Simbolo* buscar_simbolo(char*, int);

void yyerror (char const *);

#endif