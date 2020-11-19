#include "estruturas.h"
#include "tabela_simbolos.h"
#include "arvore.h"
#include "sintatico.tab.h"

int linha = 1;
int coluna, errors, escopo = 0;
char erroGlobal[2000000];
int erroSintatico = 0;

Nodo *raiz;
Pilha *pilhaParametros;
Pilha *pilhaArgumentos;
Pilha *pilhaValores;
char *retornoFuncao;

int main() {
	yyparse();
	printf("\n");
	if (erroSintatico == 0 && busca_main() == 0) sprintf(erroGlobal + strlen(erroGlobal),"Função main não foi declarada\n");
	if (erroGlobal[0]) {
		printf("%s", erroGlobal);
	} else {
		mostrar_arvore(raiz, 1);
		liberar_arvore(raiz);
		mostrar_tabela();
		liberar_tabela();
	}

	pilha_libera(pilhaParametros);
	pilha_libera(pilhaArgumentos);
	pilha_libera(pilhaValores);

	printf("\n");
}

void yyerror (char const *s) {
	erroSintatico = 1;
  sprintf(erroGlobal + strlen(erroGlobal),"%s\n", s);
}