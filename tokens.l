%{
	#include "sintatico.tab.h"

    int linha = 1, coluna = 0, errors = 0, escopo = 0;
%}

%option noyywrap
%option bison-bridge
%option nounput
%option noinput


DIGIT    [0-9]

ID       [a-zA-Z_][a-z0-9A-Z]*

KEYWORD  if|else|while|return

OP1 >|<|"=="|">="|"<="

OP2 "+"|"-"|'^'|'|'|&|&&|"||"

OP3 "*"|"/"

UOP !|~

BASIC_TYPE int|float|bool

BOOL true|false

LIST List

LIST_OP Avg|Med|Sd|Md

OUT writeInt|writeFloat

IN readInt|readFloat

%%

{DIGIT}+ {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
	yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Integer;
}

{DIGIT}+"."{DIGIT}+ {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
	yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Float;
}

"return" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Return;
}

"if" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_If;
}

"else" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Else;
}

"while" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_While;
}

{OUT} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Write;
}

{IN} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Read;
}

{BASIC_TYPE} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Type;
}

{BOOL} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Bool;
}

{LIST} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_List;
}

{LIST_OP} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_ListOperation;
}

"<"{BASIC_TYPE}">" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_ListType;
}

{ID} {
  if(yyleng >= 33) {
    sprintf(erroGlobal + strlen(erroGlobal),"ERRO! Linha %d. O identificador %s é muito longo, ele foi truncado para conter apenas os 33 caracteres\n", linha, yytext);
    yytext[33] = 0;
    coluna += 33;
  } else {
    coluna += yyleng;
  }
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  return T_Id;
}

{OP1} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Op1;
}

{OP2} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Op2;
}

{OP3} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Op3;
}

{UOP} {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_UOp;
}

"=" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
	yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_assignment;
}

"[" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_LeftBracket;
}

"]" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_RightBracket;
}

";" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Semicolon;
}

"{" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  escopo++;
  coluna += yyleng;
  return T_LeftBrace;
}

"}" {
  escopo--;
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_RightBrace;
}

"(" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_LeftParentheses;
}

")" {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_RightParentheses;
}

"," {
  yylval->token.lexema = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
  strcpy(yylval->token.lexema, yytext);
  yylval->token.linha = linha;
  yylval->token.coluna = coluna;
  yylval->token.escopo = escopo;
  coluna += yyleng;
  return T_Comma;
}

[ \t]+

\n {
  coluna = 0;
  linha++;
}

. {
  errors++;
  sprintf(erroGlobal + strlen(erroGlobal),"ERRO! linha %d! Caractere não reconhecido: %s\n", linha, yytext);
}

%%

// int main(int argc, char** argv) {
//   argv++;
//   argc--;
//   if (argc > 0) {
//     yyin = fopen(argv[0], "r");
//     fclose(yyin);
//   } else {
//     printf("File not found\n");
//     return 0;
//   }
//   yylex();
//   printf("\n");
//   if (errors > 0) {
//     printf("Lexical analysis found %d error\n", errors);
//   }
//   else {
//     printf("Lexical analysis OK.\n");
//   }
//   return 0;
// }