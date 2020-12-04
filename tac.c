#include "tac.h"
#include "arvore.h"
#include "tabela_simbolos.h"

extern char *codeTAC;
extern char operacaoTAC;

void tac_expressao(int idPrincipal, Nodo *raiz) {
	ListaNodo *filhoAtual = raiz->filhos;

  if (filhoAtual == NULL) {
    if (raiz->id == -1) {
      // é uma expressão matemática
      if (strcmp(raiz->tipo, "+") == 0) operacaoTAC = '+';
      else if (strcmp(raiz->tipo, "-") == 0) operacaoTAC = '-';
      else if (strcmp(raiz->tipo, "*") == 0) operacaoTAC = '*';
      else if (strcmp(raiz->tipo, "/") == 0) operacaoTAC = '/';

    } else {
      // é um operando ou variavel
      Simbolo *s = buscar_simbolo_id(raiz->id);

      codeTAC = alocar_memoria(codeTAC);
      if (operacaoTAC == '=') {
        if (strcmp(s->token, "Identifier") == 0) {
          sprintf(codeTAC + strlen(codeTAC), "mov $%d, *%d\n", idPrincipal, s->id);
        } else {
          sprintf(codeTAC + strlen(codeTAC), "mov $%d, %s\n", idPrincipal, s->lexema);
        }
      } else {
        char operacao[4];
        if (operacaoTAC == '+') strcpy(operacao, "add");
        else if (operacaoTAC == '-') strcpy(operacao, "sub");
        else if (operacaoTAC == '*') strcpy(operacao, "mul");
        else if (operacaoTAC == '/') strcpy(operacao, "div");

        if (strcmp(s->token, "Identifier") == 0) {
          sprintf(codeTAC + strlen(codeTAC), "%s $%d, $%d, $%d\n", operacao, idPrincipal, idPrincipal, s->id);
        } else {
          sprintf(codeTAC + strlen(codeTAC), "%s $%d, $%d, %s\n", operacao, idPrincipal, idPrincipal, s->lexema);
        }
      }
    }
  }
	
  while (filhoAtual != NULL) {
		tac_expressao(idPrincipal, filhoAtual->val);
		filhoAtual = filhoAtual->proximo;
	}
}
