# Sequencia de comandos para execução:

* make (criará um arquivo chamado sintatico)
* ./semantico < caminho_para_arquivo_teste

## Arquivos de teste

Todos os testes estão dentro da pasta *testes* dividos por cada fase da compilação, sendo:

| Pasta  | Fase do projeto  |
|---|---|
| lexico  | Análise léxica  |
| sintatico  | Análise Sintática  |
| semantio  | Análise Semântica  |

Arquivos de testes que possuem entradas corretas estão nomeados com:
* s1.c
* s2.c
* s3.c

Arquivos de testes que possuem entradas incorretas estão nomeados com:
* e1.c
* e2.c
* e3.c
