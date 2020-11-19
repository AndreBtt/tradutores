#include "estruturas.h"
#include "tabela_simbolos.h"
#include "arvore.h"
#include "sintatico.tab.h"

int linha, coluna, errors, escopo = 0;
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
	if (busca_main() == 0) sprintf(erroGlobal + strlen(erroGlobal),"Função main não foi declarada\n");
	if (erroGlobal[0]) {
		printf("%s", erroGlobal);
	} else {
		mostrar_arvore(raiz, 1);
		liberar_arvore(raiz);
		mostrar_tabela();
		liberar_tabela();
	}
	printf("\n");
}

void yyerror (char const *s) {
  sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: %s\n", linha, s);
}