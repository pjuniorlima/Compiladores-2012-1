// common.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "common.h"
#include "env.h"

void table_dump_recursive(Env *e, int deep){
	printf("Tabela simbolos, nivel %d\n", deep);
	
	GHashTable *hash = e->table;
	int i;
	
	GHashTableIter iter;
	g_hash_table_iter_init (&iter, hash);
	
	gpointer key, value;
	while(g_hash_table_iter_next(&iter, &key, &value)) {
		for(i = 0; i < deep; i++) printf("\t");
		printf("%s => %s\n", (char*) key, (char*) value);
	}
	
	if(e->prev != NULL) table_dump_recursive(e->prev, deep+1);
}

void table_func_dump(GHashTable *hash){
	printf("-- Dump tabela de funções\n");
	
	GHashTableIter iter;
	g_hash_table_iter_init (&iter, hash);
	
	gpointer key, value;
	while(g_hash_table_iter_next(&iter, &key, &value)) {
		printf("%s => %d\n", (char*) key, (long) value);
	}
	printf("-- Fim - Dump tabela de funções\n\n");
}

void table_dump(Env *e) {
	table_dump_recursive(e, 0);
}

