# Sequencia de comandos para execução:

* make (criará um arquivo chamado semantico)
* ./semantico < caminho_para_arquivo_teste

## Arquivos de teste

Todos os testes estão dentro da pasta *testes* dividos por cada fase da compilação, sendo:

| Pasta  | Fase do projeto  |
|---|---|
| lexico  | Análise léxica  |
| sintatico  | Análise Sintática  |
| semantio  | Análise Semântica  |
| primitiva  | Código de três endereços  |

A pasta primitiva contém exemplos de como usar a primitiva implementada.

Arquivos de testes que possuem entradas corretas estão nomeados com:
* s1.c
* s2.c
* s3.c

Arquivos de testes que possuem entradas incorretas estão nomeados com:
* e1.c
* e2.c
* e3.c

# Código de três endereços

Uma vez executado o comando ```./semantico < caminho_para_arquivo_teste``` um arquivo chamado *programa.tac* será gerado contendo o programada traduzido para código de três endereços.

Com isso para executar, é nescessário baixar o interpretador (https://github.com/lhsantos/tac) e executar o comando ```./tac <caminho>/programa.tac```