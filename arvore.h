#ifndef ARVORE
#define ARVORE

#include "estruturas.h"

Nodo* criar_nodo(char*, int);
void add_filho(Nodo*, Nodo*);
void mostrar_arvore(Nodo*, int);
int verificarTipo(Nodo*, char*);
void armazenarTipos(Nodo*, char*);
void liberar_arvore(Nodo*);

#endif