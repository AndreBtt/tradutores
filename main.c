#include "estruturas.h"
#include "tabela_simbolos.h"
#include "arvore.h"
#include "sintatico.tab.h"

int linha = 1;
int coluna, errors, escopo = 0;
char erroGlobal[2000000];
int erroSintatico = 0;
char *codeTAC;
char *tableTAC;
char operacaoTAC;

Nodo *raiz;
Pilha *pilhaParametros;
Pilha *pilhaArgumentos;
Pilha *pilhaValores;
Pilha *pilhaAtribuicao;
char *retornoFuncao;
int novoTemporario = 0;
int novoLabel = 0;
int numeroParametro = 0;

int main() {
	yyparse();
	printf("\n");
	if (erroSintatico == 0 && busca_main() == 0) sprintf(erroGlobal + strlen(erroGlobal),"Função main não foi declarada\n");
	if (erroGlobal[0]) {
		printf("%s", erroGlobal);
	} else {
		FILE *tac;
		tac = fopen("programa.tac", "w+");
		fprintf(tac, ".table\n");
		if (tableTAC) fprintf(tac, "%s", tableTAC);
		fprintf(tac, ".code\n");
		fprintf(tac, "%s", codeTAC);
		fclose(tac);

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
  sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: %s\n", linha, s);
}