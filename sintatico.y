%define parse.error verbose
%define parse.lac none
%define api.pure
%debug
%defines

%{

#include "estruturas.h"
#include "tabela_simbolos.h"
#include "arvore.h"

extern int yylex();
extern Nodo *raiz;
extern Pilha *pilhaParametros;
extern Pilha *pilhaArgumentos;
extern Pilha *pilhaValores;
extern char *retornoFuncao;
extern char erroGlobal[2000000];

%}

%union {
	Token token;
	Nodo *nodo;
}

%token <token> T_Integer
%token <token> T_Float
%token <token> T_Bool
%token <token> T_Return
%token <token> T_If
%token <token> T_LeftParentheses
%token <token> T_RightParentheses
%token <token> T_Else
%token <token> T_While
%token <token> T_Write
%token <token> T_Read
%token <token> T_Type
%token <token> T_List
%token <token> T_ListType
%token <token> T_ListOperation
%token <token> T_Id
%token <token> T_Op1 
%token <token> T_Op2
%token <token> T_Op3
%token <token> T_UOp
%token <token> T_assignment
%token <token> T_LeftBrace
%token <token> T_RightBrace
%token <token> T_LeftBracket
%token <token> T_RightBracket
%token <token> T_Semicolon
%token <token> T_Comma

%type <nodo> type_identifier
%type <nodo> expression
%type <nodo> expression_1
%type <nodo> expression_2
%type <nodo> expression_3
%type <nodo> value
%type <nodo> number
%type <nodo> function_call
%type <nodo> array_access
%type <nodo> conditional
%type <nodo> identifiers_list
%type <nodo> variables_declaration
%type <nodo> function_definition
%type <nodo> function_body
%type <nodo> parameters
%type <nodo> program
%type <nodo> statements
%type <nodo> statement
%type <nodo> return
%type <nodo> loop
%type <nodo> read
%type <nodo> write
%type <nodo> parameters_list
%type <nodo> parameter
%type <nodo> arguments_list
%type <nodo> start
%type <nodo> else

%start start

%%

start:
	program {
		raiz = $$;
		pilhaParametros = pilha_libera(pilhaParametros);
	}

program:
	function_definition {
		$$ = criar_nodo("program", -1);
		add_filho($$, $1);
	}
	| function_definition program {
		$$ = criar_nodo("program", -1);
		add_filho($$, $1);
		add_filho($$, $2);
	}
	| variables_declaration program {
		$$ = criar_nodo("program", -1);
		add_filho($$, $1);
		add_filho($$, $2);
	}

function_definition:
	type_identifier T_Id parameters function_body {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da função %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($2);
			char *tipo = buscar_tipo($1);
			definir_tipo(id, tipo);

			if (retornoFuncao == NULL) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função espera retorno do tipo %s e nada foi retornado\n", $2.linha, tipo);
			} else if (verificarTipos(tipo, retornoFuncao) == 1) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função espera retorno do tipo %s e foi retornado tipo %s\n", $2.linha, tipo, retornoFuncao);
			}

			simbolo = buscar_simbolo_id(id);
			simbolo->funcao = 1;
			if (pilhaParametros != NULL) {
				simbolo->parametros->elemento = pilhaParametros->elemento;
				simbolo->parametros->tamanho = pilhaParametros->tamanho;
				pilhaParametros = NULL;
			}
		}

		$$ = criar_nodo("function definition", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, $3);
		add_filho($$, $4);
	}

function_body:
	T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("function body", -1);
		add_filho($$, criar_nodo("left brace", -1));
		add_filho($$, criar_nodo("right brace", -1));
		add_filho($$, $2);
	}

parameters:
	T_LeftParentheses parameters_list T_RightParentheses {
		pilhaValores = pilha_libera(pilhaValores);

		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("parameters", -1);
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, $2);
		add_filho($$, criar_nodo("right parentheses", -1));
	}
	| T_LeftParentheses T_RightParentheses {
		criar_simbolo($1);
		criar_simbolo($2);

		$$ = criar_nodo("parameters", -1);
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, criar_nodo("right parentheses", -1));
	}

parameters_list:
	parameter T_Comma parameters_list {
		pilhaParametros = pilha_push(pilhaParametros, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

		criar_simbolo($2);

		$$ = criar_nodo("parameters list", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("comma", -1));
		add_filho($$, $3);
	} 
	| parameter {
		pilhaParametros = pilha_push(pilhaParametros, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

		$$ = criar_nodo("parameters list", -1);
		add_filho($$, $1);
	}

parameter:
	type_identifier T_Id {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			char *tipo = buscar_tipo($1);
			id = criar_simbolo($2);
			definir_tipo(id, tipo);

			pilhaValores = pilha_push(pilhaValores, id);
		}

		$$ = criar_nodo("parameter", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("identifier", id));
	}
	| type_identifier T_Id T_LeftBracket T_RightBracket {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);

			char *tipo = buscar_tipo($1);
			definir_tipo(id, tipo);

			pilhaValores = pilha_push(pilhaValores, id);
		}

		$$ = criar_nodo("parameter", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left bracket", -1));
		add_filho($$, criar_nodo("right bracket", -1));
	}

type_identifier:
	T_List T_ListType {
		criar_simbolo($1);
		criar_simbolo($2);

		$$ = criar_nodo("type identifier", -1);
		add_filho($$, criar_nodo($1.lexema, -1));
		add_filho($$, criar_nodo($2.lexema, -1));
	} 
	| T_Type {
		criar_simbolo($1);

		$$ = criar_nodo("type identifier", -1);
		add_filho($$, criar_nodo($1.lexema, -1));
	}

statements:
	statement statements {
		$$ = criar_nodo("statements", -1);
		add_filho($$, $1);
		add_filho($$, $2);
	}
	| T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("statements", -1);
		add_filho($$, criar_nodo("left brace", -1));
		add_filho($$, $2);
		add_filho($$, criar_nodo("right brace", -1));
	}
	| statement {
		$$ = criar_nodo("statements", -1);
		add_filho($$, $1);
	}

statement:
	variables_declaration {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}
	| return {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}
	| conditional {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}
	| loop {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}
	| expression T_Semicolon {
		criar_simbolo($2);

		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("semicolon", -1));
	}
	| read {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}
	| write {
		$$ = criar_nodo("statement", -1);
		add_filho($$, $1);
	}

read:
	T_Read T_Id T_Semicolon {
		criar_simbolo($1);
		int id = criar_simbolo($2);
		criar_simbolo($3);

		$$ = criar_nodo("read", -1);
		add_filho($$, criar_nodo("read", -1));
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("semicolon", -1));
	}

write:
	T_Write T_Id T_Semicolon {
		criar_simbolo($1);
		int id = criar_simbolo($2);
		criar_simbolo($3);

		$$ = criar_nodo("write", -1);
		add_filho($$, criar_nodo("write", -1));
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("semicolon", -1));
	}

function_call:
	T_Id T_LeftParentheses arguments_list T_RightParentheses  {
		pilhaValores = pilha_libera(pilhaValores);

		Simbolo *simbolo = buscar_simbolo($1.lexema, 0);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			if (simbolo->parametros->tamanho != pilhaArgumentos->tamanho) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função espera receber %d argumentos mas foi chamada com %d argumentos\n", $1.linha, simbolo->parametros->tamanho, pilhaArgumentos->tamanho);
			} else {
				// o que eu espero receber
				PilhaElemento *parametros = simbolo->parametros->elemento; 
				
				// o que eu recebi
				PilhaElemento *argumentos = pilhaArgumentos->elemento;
				
				int numeroArgumento = 1;

				while (parametros != NULL && argumentos != NULL) {
					Simbolo* parametro = buscar_simbolo_id(parametros->val);
					Simbolo* argumento = buscar_simbolo_id(argumentos->val);

					char *parametroTipo = parametro->tipo;
					char *argumentoTipo = argumento->tipo;
					if (verificarTipos(parametroTipo, argumentoTipo) == 1) {
						sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: argumento número %d da função %s é do tipo %s e foi chamado passando o tipo %s\n", $1.linha, numeroArgumento, $1.lexema, parametroTipo, argumentoTipo);
					}
				
					parametros = parametros->proximo;
					argumentos = argumentos->proximo;
					numeroArgumento++;
				}
			}
		}

		pilhaArgumentos = pilha_libera(pilhaArgumentos);


		$$ = criar_nodo("function_call", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses", -1));
	}
	| T_Id T_LeftParentheses T_RightParentheses  {
		Simbolo *simbolo = buscar_simbolo($1.lexema, 0);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
		}

		$$ = criar_nodo("function_call", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, criar_nodo("right parentheses", -1));
	}

arguments_list:
	value T_Comma arguments_list  {
		pilhaArgumentos = pilha_push(pilhaArgumentos, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

		criar_simbolo($2);

		$$ = criar_nodo("arguments list", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("comma", -1));
		add_filho($$, $3);
	}
	| value {
		pilhaArgumentos = pilha_push(pilhaArgumentos, pilhaValores->elemento->val);
		pilhaValores = pilha_pop(pilhaValores);

		$$ = criar_nodo("arguments list", -1);
		add_filho($$, $1);
	}

conditional: 
	T_If T_LeftParentheses expression T_RightParentheses statements else {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("conditional", -1);
		add_filho($$, criar_nodo("if", -1));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses", -1));
		add_filho($$, $5);
		add_filho($$, $6);
	}
	| T_If T_LeftParentheses expression T_RightParentheses statements {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("conditional", -1);
		add_filho($$, criar_nodo("if", -1));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses", -1));
		add_filho($$, $5);
	}

else:
	T_Else conditional {
		criar_simbolo($1);

		$$ = criar_nodo("else", -1);
		add_filho($$, criar_nodo("else", -1));
		add_filho($$, $2);
	}
	| T_Else T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("else", -1);
		add_filho($$, criar_nodo("else", -1));
		add_filho($$, criar_nodo("left brace", -1));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right brace", -1));
	}

loop:
	T_While T_LeftParentheses expression T_RightParentheses T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);
		criar_simbolo($5);
		criar_simbolo($7);

		$$ = criar_nodo("loop", -1);
		add_filho($$, criar_nodo("while", -1));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses", -1));
		add_filho($$, criar_nodo("left brace", -1));
		add_filho($$, $6);
		add_filho($$, criar_nodo("right brace", -1));
	}

return:
	T_Return value T_Semicolon {
		criar_simbolo($1);
		criar_simbolo($3);

		Simbolo *simbolo = buscar_simbolo_id(pilhaValores->elemento->val);
		retornoFuncao = malloc(strlen(simbolo->tipo) + 1);
		strcpy(retornoFuncao, simbolo->tipo);

		$$ = criar_nodo("return", -1);
		add_filho($$, criar_nodo("return", -1));
		add_filho($$, $2);
		add_filho($$, criar_nodo("semicolon", -1));
	}

value:
	T_Id {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			pilhaValores = pilha_push(pilhaValores, id);
		}

		$$ = criar_nodo("value", -1);
		add_filho($$, criar_nodo("identifier", id));
	}
	| number {
		$$ = criar_nodo("value", -1);
		add_filho($$, $1);
	}
	| array_access {
		$$ = criar_nodo("value", -1);
		add_filho($$, $1);
	}
	| function_call {
		$$ = criar_nodo("value", -1);
		add_filho($$, $1);
	}
	| T_Bool {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "bool");
		simbolo->tipo = malloc(strlen("bool") + 1);
		strcpy(simbolo->tipo, "bool");
		pilhaValores = pilha_push(pilhaValores, id);

		$$ = criar_nodo("value", -1);
		add_filho($$, criar_nodo("bool", simbolo->id));
	}

array_access:
	T_Id T_LeftBracket T_Integer T_RightBracket  {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			id = simbolo->id;
			int posicao = atoi($3.lexema);
			if (posicao < 0 || posicao >= simbolo->vetorLimite) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: posição %d inválida no vetor %s\n", $1.linha, posicao, $1.lexema);
			}

			criar_simbolo($2);
			criar_simbolo($4);
		}

		$$ = criar_nodo("array access", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left bracket", -1));
		add_filho($$, criar_nodo("integer", -1));
		add_filho($$, criar_nodo("right bracket", -1));
	}

variables_declaration:
	type_identifier identifiers_list T_Semicolon {
		criar_simbolo($3);
		char *tipo = buscar_tipo($1);
		armazenarTipos($2, tipo);

		$$ = criar_nodo("variables declaration", -1);
		add_filho($$, $1);
		add_filho($$, $2);
		add_filho($$, criar_nodo("semicolon", -1));
	}

identifiers_list:
	T_Id T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			criar_simbolo($2);
		}
		
		$$ = criar_nodo("identifiers list", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("comma", -1));
		add_filho($$, $3);
	}
	|
	T_Id T_LeftBracket T_Integer T_RightBracket T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			definir_tipo(id, "[]");
			simbolo = buscar_simbolo_id(id);
			simbolo->vetorLimite = atoi($3.lexema);

			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);
			criar_simbolo($5);
		}

		$$ = criar_nodo("identifiers list", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left bracket", -1));
		add_filho($$, criar_nodo("integer", -1));
		add_filho($$, criar_nodo("right bracket", -1));
		add_filho($$, criar_nodo("comma", -1));
		add_filho($$, $6);
	}
	| 
	T_Id T_LeftBracket T_Integer T_RightBracket {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
			definir_tipo(id, "[]");
			simbolo = buscar_simbolo_id(id);
			simbolo->vetorLimite = atoi($3.lexema);

			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);
		}

		$$ = criar_nodo("identifiers list", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("left bracket", -1));
		add_filho($$, criar_nodo("integer", -1));
		add_filho($$, criar_nodo("right bracket", -1));
	
	}
	| 
	T_Id {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo != NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			id = criar_simbolo($1);
		}

		$$ = criar_nodo("identifiers list", -1);
		add_filho($$, criar_nodo("identifier", id));
	}

expression:
	T_Id T_assignment expression {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			int falha = verificarTipo($3, simbolo->tipo);
			if (falha == 1) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: a variável %s espera receber valores do tipo %s\n", $1.linha, $1.lexema, simbolo->tipo);
			}
		}

		criar_simbolo($2);

		$$ = criar_nodo("expression", -1);
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("assignment", -1));
		add_filho($$, $3);
	}
	| array_access T_assignment expression {
		criar_simbolo($2);

		$$ = criar_nodo("expression", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("assignment", -1));
		add_filho($$, $3);
	}
	| expression_1 {
		$$ = criar_nodo("expression", -1);
		add_filho($$, $1);
	}
	| T_ListOperation T_LeftParentheses T_Id T_RightParentheses {
		Simbolo *simbolo = buscar_simbolo($3.lexema, $3.escopo);
		int id = -1;
		if (simbolo == NULL) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $3.linha, $3.lexema);
		} else {
			id = simbolo->id;
			if (strcmp(simbolo->tipo, "List<int>") != 0 && strcmp(simbolo->tipo, "List<float>") != 0) {
				sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s aceita apenas variável do tipo List\n", $1.linha, $1.lexema);
			}

			criar_simbolo($1);
			criar_simbolo($2);
			criar_simbolo($4);
		}

		$$ = criar_nodo("list expression", -1);
		add_filho($$, criar_nodo("list operation", -1));
		add_filho($$, criar_nodo("left parentheses", -1));
		add_filho($$, criar_nodo("identifier", id));
		add_filho($$, criar_nodo("right parentheses", -1));
	}

expression_1:
	expression_2 T_Op1 expression_1 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 1", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 1", -1));
		add_filho($$, $3);
	} 
	| expression_2 {
		$$ = criar_nodo("expression 1", -1);
		add_filho($$, $1);
	}

expression_2:
	expression_3 T_Op2 expression_2 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 2", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 2", -1));
		add_filho($$, $3);
	}
	| expression_3 {
		$$ = criar_nodo("expression 2", -1);
		add_filho($$, $1);
	}

expression_3:
	value T_Op3 expression_3 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 3", -1);
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 3", -1));
		add_filho($$, $3);
	}
	| T_UOp value {
		criar_simbolo($1);

		$$ = criar_nodo("expression 3", -1);
		add_filho($$, criar_nodo("unary operation", -1));
		add_filho($$, $2);
	}
	| value {
		$$ = criar_nodo("expression 3", -1);
		add_filho($$, $1);
	}

number:
	T_Integer {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "int");
		simbolo->tipo = malloc(strlen("int") + 1);
		strcpy(simbolo->tipo, "int");
		pilhaValores = pilha_push(pilhaValores, id);

		$$ = criar_nodo("number", -1);
		add_filho($$, criar_nodo("integer", simbolo->id));
	}
	| T_Float {
		int id = criar_simbolo($1);
		Simbolo *simbolo = buscar_simbolo_id(id);
		strcpy(simbolo->token, "float");
		simbolo->tipo = malloc(strlen("float") + 1);
		strcpy(simbolo->tipo, "float");
		pilhaValores = pilha_push(pilhaValores, id);

		$$ = criar_nodo("number", -1);
		add_filho($$, criar_nodo("float", simbolo->id));
	}

%%
