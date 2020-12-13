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

void construirAVG() {
	codeTAC = alocar_memoria(codeTAC);
	sprintf(codeTAC + strlen(codeTAC), "\nAvg:\nmov $0, #0\nmov $1, #1\nmov $2, 0\nmov $3, 0\n__loop:\nslt $4, $3, $1\nbrz __fim, $4\nmov $5, $0[$3]\nadd $2, $2, $5\nadd $3, $3, 1\njump __loop\n__fim:\ninttofl $2, $2\ninttofl $1, $1\ndiv $5, $2, $1\nreturn $5\n\n");
	Token avg;
	avg.lexema = malloc(strlen("Avg") + 1);
	strcpy(avg.lexema, "Avg");
	avg.coluna = 0;
	avg.linha = 0;
	avg.escopo = 0;

	int id = criar_simbolo(avg);
	Simbolo *simbolo = buscar_simbolo_id(id);
	simbolo->funcao = 1;
	simbolo->tipo = malloc(strlen("float") + 1);
	strcpy(simbolo->tipo, "float");
}

int main() {
	construirAVG();

	yyparse();

	printf("\n");
	mostrar_tabela();
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
	}

	liberar_arvore(raiz);
	liberar_tabela();
	pilha_libera(pilhaParametros);
	pilha_libera(pilhaArgumentos);
	pilha_libera(pilhaValores);

	printf("\n");
}

void yyerror (char const *s) {
	erroSintatico = 1;
  sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: %s\n", linha, s);
}