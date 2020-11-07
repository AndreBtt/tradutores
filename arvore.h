#ifndef ARVORE
#define ARVORE

#include "estruturas.h"

Nodo* criar_nodo(char*, int);
void add_filho(Nodo*, Nodo*);
void mostrar_arvore(Nodo*, int);
void liberar_arvore(Nodo*);

#endif