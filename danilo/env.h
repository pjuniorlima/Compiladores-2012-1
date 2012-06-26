/*
 * CheckPoint do trabalho de compiladores
 *
 * env.h: baseada na pagina 57 do livro, tabela encadeada/simulacao de ambientes
 *
 * Aluno:Bruno dos Reis Calcado
 * Matricula: 080196
 */
#ifndef ENV
#define ENV

#include <glib.h>//apoio hashtables
#include <stdlib.h>

typedef struct _Env {
	GHashTable *table;
	struct _Env *prev;
} Env;

// Busca uma variável na pilha de tabelas
//char* env_get(Env*, char*);
#endif
