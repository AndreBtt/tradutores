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

void ordenarLista(){
	codeTAC = alocar_memoria(codeTAC);
	sprintf(codeTAC + strlen(codeTAC), "\nOrdenar:\nmov $0, #0\nmov $1, #1\n__Ordenar__inicio:\nmov $2, 0\nmov $3, $1\nsub $3, $3, 1\n__Ordenar__loop:\nslt $4, $2, $3\nbrz __Ordenar__fim, $4\nmov $5, $0[$2]\nadd $6, $2, 1\nmov $7, $0[$6]\nsleq $8, $5, $7\nbrnz __Ordenar__ok, $8\nmov $0[$2], $7\nmov $0[$6], $5\njump __Ordenar__inicio\n__Ordenar__ok:\nadd $2, $2, 1\njump __Ordenar__loop\n__Ordenar__fim:\nreturn\n\n");
	Token ord;
	ord.lexema = malloc(strlen("Ordenar") + 1);
	strcpy(ord.lexema, "Ordenar");
	ord.coluna = 0;
	ord.linha = 0;
	ord.escopo = 0;
}

void construirAvg() {
	codeTAC = alocar_memoria(codeTAC);
	sprintf(codeTAC + strlen(codeTAC), "\nAvg:\nmov $0, #0\nmov $1, #1\nmov $2, 0\nmov $3, 0\n__Avg__loop:\nslt $4, $3, $1\nbrz __Avg__fim, $4\nmov $5, $0[$3]\nadd $2, $2, $5\nadd $3, $3, 1\njump __Avg__loop\n__Avg__fim:\ninttofl $2, $2\ninttofl $1, $1\ndiv $5, $2, $1\nreturn $5\n\n");
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

void construirMed() {
	codeTAC = alocar_memoria(codeTAC);
	sprintf(codeTAC + strlen(codeTAC), "\nMed:\nmov $0, #0\nmov $1, #1\nmod $2, $1, 2\nbrz __Med__par, $2\ndiv $3, $1, 2\nmov $4, $0[$3]\nreturn $4\n__Med__par:\ndiv $3, $1, 2\nsub $4, $3, 1\nmov $5, $0[$3]\nmov $6, $0[$4]\nadd $7, $5, $6\ninttofl $7, $7\ndiv $7, $7, 2.0\nreturn $7\n\n");
	Token med;
	med.lexema = malloc(strlen("Med") + 1);
	strcpy(med.lexema, "Med");
	med.coluna = 0;
	med.linha = 0;
	med.escopo = 0;

	int id = criar_simbolo(med);
	Simbolo *simbolo = buscar_simbolo_id(id);
	simbolo->funcao = 1;
	simbolo->tipo = malloc(strlen("float") + 1);
	strcpy(simbolo->tipo, "float");
}

int main() {
	ordenarLista();
	construirAvg();
	construirMed();

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
		fprintf(tac, ".code\n\n");
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