/*
 * node.c
 * Implementa o formato de um nó
 *
 * author: Danilo Inácio
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "node.h"

Node* create_node(enum node_type type, Node* n1, Node* n2, Node* n3){
	Node *n = malloc(sizeof(Node));

	n->type = type;

	n->n1.node = n1;
	n->n2.node = n2;
	n->n3.node = n3;
	
	return n;
}

void type_to_string(char *r, enum node_type type){
  switch (type) {
		case cINT: 		strcpy(r, "int"); break;
		case cCHAR: 	strcpy(r, "char"); break;
		case cARRAY: 	strcpy(r, "array"); break;
		
		case cPARAMDECLLISTTAIL: 	strcpy(r, "Lista de parâmetros"); break;
		case cARGUMENTLIST: 		strcpy(r, "Lista de argumentos"); break;
	}
}

/* Tests
int main() {
	Node *n, *n2;
	
	//n = create_node(S, 0, NULL, NULL, NULL);
	n2 = new_leaft(100);
	n = new_s_node(n2, null);
	
	printf("%d\n", n1(n)->value);
	
	return 0;
}
*/
