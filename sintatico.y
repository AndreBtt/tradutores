%define parse.error verbose
%define parse.lac none
%define api.pure
%debug
%defines

%code requires {
#include "estruturas.h"
#include "tabela_simbolos.h"
#include "arvore.h"
extern int yylex();
Nodo *raiz;
}

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
%type <nodo> function_declaration
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
	}

program:
	function_definition {
		$$ = criar_nodo("program");
		add_filho($$, $1);
	}
	| function_definition program {
		$$ = criar_nodo("program");
		add_filho($$, $1);
		add_filho($$, $2);
	}
	| variables_declaration program {
		$$ = criar_nodo("program");
		add_filho($$, $1);
		add_filho($$, $2);
	}

function_definition:
	function_declaration parameters function_body {
		$$ = criar_nodo("function definition");
		add_filho($$, $1);
		add_filho($$, $2);
		add_filho($$, $3);
	}

function_declaration:
	type_identifier T_Id {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da função %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			criar_simbolo($2);

			$$ = criar_nodo("function declaration");
			add_filho($$, $1);
			add_filho($$, criar_nodo("identifier"));
		}
	}

function_body:
	T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("function body");
		add_filho($$, criar_nodo("left brace"));
		add_filho($$, criar_nodo("right brace"));
		add_filho($$, $2);
	}

parameters: 
	T_LeftParentheses parameters_list T_RightParentheses {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("parameters");
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $2);
		add_filho($$, criar_nodo("right parentheses"));
	}
	| T_LeftParentheses T_RightParentheses {
		criar_simbolo($1);
		criar_simbolo($2);

		$$ = criar_nodo("parameters");
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, criar_nodo("right parentheses"));
	}

parameters_list:
	parameter T_Comma parameters_list {
		criar_simbolo($2);

		$$ = criar_nodo("parameters list");
		add_filho($$, $1);
		add_filho($$, criar_nodo("comma"));
		add_filho($$, $3);
	} 
	| parameter {
		$$ = criar_nodo("parameters list");
		add_filho($$, $1);
	}

parameter:
	type_identifier T_Id {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			criar_simbolo($2);
		}

		$$ = criar_nodo("parameter");
		add_filho($$, $1);
		add_filho($$, criar_nodo("identifier"));
	}
	| type_identifier T_Id T_LeftBracket T_RightBracket {
		Simbolo *simbolo = buscar_simbolo($2.lexema, $2.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $2.linha, $2.lexema, simbolo->linha);
		} else {
			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);
		}

		$$ = criar_nodo("parameter");
		add_filho($$, $1);
		add_filho($$, criar_nodo("identifier"));
		add_filho($$, criar_nodo("left bracket"));
		add_filho($$, criar_nodo("right bracket"));
	}

type_identifier:
	T_List T_ListType {
		criar_simbolo($1);
		criar_simbolo($2);

		$$ = criar_nodo("type identifier");
		add_filho($$, criar_nodo("list"));
		add_filho($$, criar_nodo("list type"));
	} 
	| T_Type {
		criar_simbolo($1);

		$$ = criar_nodo("type identifier");
		add_filho($$, criar_nodo("type"));
	}

statements:
	statement statements {
		$$ = criar_nodo("statements");
		add_filho($$, $1);
		add_filho($$, $2);
	}
	| T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("statements");
		add_filho($$, criar_nodo("left brace"));
		add_filho($$, $2);
		add_filho($$, criar_nodo("right brace"));
	}
	| statement {
		$$ = criar_nodo("statements");
		add_filho($$, $1);
	}

statement:
	variables_declaration {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}
	| return {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}
	| conditional {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}
	| loop {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}
	| expression T_Semicolon {
		criar_simbolo($2);

		$$ = criar_nodo("statement");
		add_filho($$, $1);
		add_filho($$, criar_nodo("semicolon"));
	}
	| read {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}
	| write {
		$$ = criar_nodo("statement");
		add_filho($$, $1);
	}

read:
	T_Read T_Id T_Semicolon {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($3);

		$$ = criar_nodo("read");
		add_filho($$, criar_nodo("read"));
		add_filho($$, criar_nodo("identifier"));
		add_filho($$, criar_nodo("semicolon"));
	}

write:
	T_Write T_Id T_Semicolon {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($3);

		$$ = criar_nodo("write");
		add_filho($$, criar_nodo("write"));
		add_filho($$, criar_nodo("identifier"));
		add_filho($$, criar_nodo("semicolon"));
	}

function_call:
	T_Id T_LeftParentheses arguments_list T_RightParentheses  {
		// TODO
		Simbolo *simbolo = buscar_simbolo($1.lexema, 0);
		if (!simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: função %s não foi declarada\n", $1.linha, $1.lexema);
		} else {
		}
	}

arguments_list:
	arguments_list T_Comma value  {
		criar_simbolo($2);

		$$ = criar_nodo("arguments list");
		add_filho($$, $1);
		add_filho($$, criar_nodo("comma"));
		add_filho($$, $3);
	}
	| value {
		$$ = criar_nodo("arguments list");
		add_filho($$, $1);
	}

conditional: 
	T_If T_LeftParentheses expression T_RightParentheses statements else {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("conditional");
		add_filho($$, criar_nodo("if"));
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses"));
		add_filho($$, $5);
		add_filho($$, $6);
	}
	| T_If T_LeftParentheses expression T_RightParentheses statements {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("conditional");
		add_filho($$, criar_nodo("if"));
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses"));
		add_filho($$, $5);
	}

else:
	T_Else conditional {
		criar_simbolo($1);

		$$ = criar_nodo("else");
		add_filho($$, criar_nodo("else"));
		add_filho($$, $2);
	}
	| T_Else T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("else");
		add_filho($$, criar_nodo("else"));
		add_filho($$, criar_nodo("left brace"));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right brace"));
	}

loop:
	T_While T_LeftParentheses expression T_RightParentheses T_LeftBrace statements T_RightBrace {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);
		criar_simbolo($5);
		criar_simbolo($7);

		$$ = criar_nodo("loop");
		add_filho($$, criar_nodo("while"));
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses"));
		add_filho($$, criar_nodo("left brace"));
		add_filho($$, $6);
		add_filho($$, criar_nodo("right brace"));
	}

return:
	T_Return value T_Semicolon {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("return");
		add_filho($$, criar_nodo("return"));
		add_filho($$, $2);
		add_filho($$, criar_nodo("semicolon"));
	}

value:
	T_Id {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (!simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			criar_simbolo($1);

			$$ = criar_nodo("value");
			add_filho($$, criar_nodo("identifier"));
		}
	}
	| number {
		$$ = criar_nodo("value");
		add_filho($$, $1);
	} 
	| array_access {
		$$ = criar_nodo("value");
		add_filho($$, $1);
	}
	| function_call {
		$$ = criar_nodo("value");
		add_filho($$, $1);
	}

array_access:
	T_Id T_LeftBracket expression T_RightBracket  {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (!simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);
			criar_simbolo($4);

			$$ = criar_nodo("array access");
			add_filho($$, criar_nodo("identifier"));
			add_filho($$, criar_nodo("left bracket"));
			add_filho($$, $3);
			add_filho($$, criar_nodo("right bracket"));
		}
	}

variables_declaration:
	type_identifier identifiers_list T_Semicolon {
		criar_simbolo($3);

		$$ = criar_nodo("variables declaration");
		add_filho($$, $1);
		add_filho($$, $2);
		add_filho($$, criar_nodo("semicolon"));
	}

identifiers_list:
	T_Id T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);
		}

		$$ = criar_nodo("identifiers list");
		add_filho($$, criar_nodo("identifier"));
		add_filho($$, criar_nodo("comma"));
		add_filho($$, $3);
	}
	| 
	T_Id T_LeftBracket T_Integer T_RightBracket T_Comma identifiers_list {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);
			criar_simbolo($5);

			$$ = criar_nodo("identifiers list");
			add_filho($$, criar_nodo("identifier"));
			add_filho($$, criar_nodo("left bracket"));
			add_filho($$, criar_nodo("integer"));
			add_filho($$, criar_nodo("right bracket"));
			add_filho($$, criar_nodo("comma"));
			add_filho($$, $6);
		}
	}
	| 
	T_Id T_LeftBracket T_Integer T_RightBracket {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);

			$$ = criar_nodo("identifiers list");
			add_filho($$, criar_nodo("identifier"));
			add_filho($$, criar_nodo("left bracket"));
			add_filho($$, criar_nodo("integer"));
			add_filho($$, criar_nodo("right bracket"));
		}
	}
	| 
	T_Id {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: redeclaração da variável %s, primeira ocorrência na linha %d\n", $1.linha, $1.lexema, simbolo->linha);
		} else {
			criar_simbolo($1);

			$$ = criar_nodo("identifiers list");
			add_filho($$, criar_nodo("identifier"));
		}
	}

expression:
	T_Id T_assignment expression {
		Simbolo *simbolo = buscar_simbolo($1.lexema, $1.escopo);
		if (!simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $1.linha, $1.lexema);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);

			$$ = criar_nodo("expression");
			add_filho($$, criar_nodo("identifier"));
			add_filho($$, criar_nodo("assignment"));
			add_filho($$, $3);
		}
	}
	| array_access T_assignment expression {
		criar_simbolo($2);

		$$ = criar_nodo("expression");
		add_filho($$, $1);
		add_filho($$, criar_nodo("assignment"));
		add_filho($$, $3);
	}
	| expression_1 {
		$$ = criar_nodo("expression");
		add_filho($$, $1);
	}
	| T_ListOperation T_LeftParentheses T_Id T_RightParentheses {
		Simbolo *simbolo = buscar_simbolo($3.lexema, $3.escopo);
		if (!simbolo) {
			sprintf(erroGlobal + strlen(erroGlobal),"Erro na linha %d: variável %s sendo usada porém não foi declarada\n", $3.linha, $3.lexema);
		} else {
			criar_simbolo($1);
			criar_simbolo($2);
			criar_simbolo($3);
			criar_simbolo($4);

			$$ = criar_nodo("list expression");
			add_filho($$, criar_nodo("list operation"));
			add_filho($$, criar_nodo("left parentheses"));
			add_filho($$, criar_nodo("identifier"));
			add_filho($$, criar_nodo("right parentheses"));
		}
	}

expression_1:
	expression_2 T_Op1 expression_1 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 1");
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 1"));
		add_filho($$, $3);
	} 
	| expression_2 {
		$$ = criar_nodo("expression 1");
		add_filho($$, $1);
	}

expression_2:
	expression_3 T_Op2 expression_2 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 2");
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 2"));
		add_filho($$, $3);
	}
	| expression_3 {
		$$ = criar_nodo("expression 2");
		add_filho($$, $1);
	}

expression_3:
	value T_Op3 expression_3 {
		criar_simbolo($2);

		$$ = criar_nodo("expression 3");
		add_filho($$, $1);
		add_filho($$, criar_nodo("operation 3"));
		add_filho($$, $3);
	}
	| T_UOp value {
		criar_simbolo($1);

		$$ = criar_nodo("expression 3");
		add_filho($$, criar_nodo("unary operation"));
		add_filho($$, $2);
	}
	| T_UOp T_LeftParentheses expression T_RightParentheses {
		criar_simbolo($1);
		criar_simbolo($2);
		criar_simbolo($4);

		$$ = criar_nodo("expression 3");
		add_filho($$, criar_nodo("unary operation"));
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $3);
		add_filho($$, criar_nodo("right parentheses"));
	}
	| value {
		$$ = criar_nodo("expression 3");
		add_filho($$, $1);
	}
	| T_LeftParentheses expression T_RightParentheses {
		criar_simbolo($1);
		criar_simbolo($3);

		$$ = criar_nodo("expression 3");
		add_filho($$, criar_nodo("left parentheses"));
		add_filho($$, $2);
		add_filho($$, criar_nodo("right parentheses"));
	}

number:
	T_Integer {
		criar_simbolo($1);

		$$ = criar_nodo("number");
		add_filho($$, criar_nodo("integer"));
	}
	| T_Float {
		criar_simbolo($1);

		$$ = criar_nodo("number");
		add_filho($$, criar_nodo("float"));
	}

%%

int main (void) {
	yyparse();
	printf("\n");
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
