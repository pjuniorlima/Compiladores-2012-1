/*
 * CheckPoint do trabalho de compiladores
 *
 * common.h: Define as funções usadas pelo analisador sintático e pelo Lexico
 *
 * Aluno:Bruno dos Reis Calcado
 * Matricula: 080196
 */
#ifndef cCOMMON
#define cCOMMON

#include <stdio.h>
#include "env.h"

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif
 
extern int yylex(); 
extern int yyparse(); 
extern void yyerror(const char* s);


typedef struct _scanner {
  int intval;
  char charval;
  char* stringval;
} scanner;

scanner lex_value;


// Mensagem de token encontrado
void _token(char *s);

// Mensagem de lexema encontrado
void _lex(char *s);

// Faz um dump da tabela de simbolos
void table_dump(Env *e);

// Faz um dump da tabela de parametros das funções
void table_func_dump(GHashTable *hash);

#endif
