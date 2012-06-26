/*
 * CheckPoint do trabalho de compiladores
 *
 * sintatico: Arquivo que contém a gramática e o programa que inicia analisador.
 *
 * Aluno:Bruno dos Reis Calcado
 * Matricula: 080196
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>//Hash Tables — associations between keys and values so that given a key the value can be found quickly - tirado de http://goo.gl/yyBZa

#include "common.h"
#include "node.h"
#include "env.h"

extern scanner lex_value;
extern int yylineno;

// Mapeia os ids das funções com os parâmetros
char cur_func[100];
GHashTable *func_params;

int has_pushed = 0;
Node *root;
Env *top, *saved;

Env* new_env(Env *p){
	Env *env = malloc(sizeof(Env));
	env->table = g_hash_table_new(g_str_hash, g_str_equal);
	env->prev = p;
	
	return env;
}

char* env_get(Env *env, char *k) {
	// debug da tabela de simbolos
	// table_dump(env);
	for(; env != null; env = env->prev){
		char *type = g_hash_table_lookup(env->table, k);
		
		if(type != null){
			return type;
		}
	}
	return null;
}

// Insere na tabela de simbolos o 'id' e o 'tipo'
void env_put(Env *env, char *k, Node *v) {
	char *type = g_hash_table_lookup(env->table, k);
	if ( type != null ) {
		char msg[100];
		sprintf(msg, "Variável %s já declarada no escopo", k);
		yyerror(msg);
	}
	else {
		g_hash_table_insert(env->table, k, v);
	}
}

void array_id(char *result, char *str){
	char *full = str;
	
	int i, begin = 0, end;
	for(i=0; i<strlen(full); i++){
		if(full[i] == '['){
			end = i;
			break;
		}
	}
	
	strncpy(result, &full[begin], end);
}

char* array_pos(char *result, char *str){
	char *full = str;
	
	int i, begin, end;
	for(i=0; i<strlen(full); i++){
		if(full[i] == '['){
			begin = end = i+1;
		}
		else if (full[i] == ']'){
			break;
		}
		else {
			end++;
		}
	}
	
	strncpy(result, &full[begin], end-begin);
}

int is_id(char *str){
	return str[0] < '0' || str[0] > '9';
}

int verify_env(Node *n) {
	char msg[100];
	if(n->type == cID){
		char *id = (char*) n->value;
		if(env_get(top, id) == null){
			sprintf(msg, "Variável \"%s\" não declarada", id);
			yyerror(msg);
			return 0;
		}
	}
	
	if(n->type == cARRAY){
		char *id = (char*) n->value;
		int flag = 0;
		
		if(env_get(top, id) == null){
			sprintf(msg, "Variável \"%s\" não declarada", id);
			yyerror(msg);
			flag = 1;
		}
		
		char *pos = (char*) n1(n)->value;
		if(is_id(pos)){
			if(env_get(top, pos) == null){
				sprintf(msg, "Variável \"%s\" não declarada", pos);
				yyerror(msg);
				flag = 1;
			}
			if(strcmp(env_get(top, pos), "char") == 0){
				sprintf(msg, "Variável \"%s\" é do tipo char, apenas inteiros são permitos em indices de arrays", pos);
				yyerror(msg);
				flag = 1;
			}
		}
		
		if(flag) return 0;
	}
	return 1;
}

// Busca o tipo do atributo mais a esquerda da expressão
enum node_type get_type(Node *n);

// Verifica se os argumentos passados a função corresponde aos da assinatura
int compare_params_args(Node *params, Node *args);

%}

%union {
	struct _Node *node;
}

%start Program

%token
	CONSTSTRING
	ID
	IDARRAY
	MAIN
	INTTP
	CHARTP
	RETURN
	READ
	WRITE
	WRITELN
	BREAK
	IF
	ELSE
	WHILE
	INTCONST
	CHARCONST
	EXCLAMACAO
	IGUALA
	DIFERENTEDE
	ELOGICO
	OULOGICO

%left MAIS MENOS
%left ESTRELA BARRA
%left MENOR MENORIGUAL MAIOR MAIORIGUAL

%type <node>
	Program
	Decls
	VarDecl
	FuncDecl
	ParamDeclList
	ParamDeclListTail
	Block
	VarDeclList
	Type
	Ident
	StmtList
	Stmt
	Expr
	BinaryExpr
	UnaryExpr
	PostFixExpr
	Constant
	ArgumentList
	UnaryOp
	BinOp
	AritmOp
	RelOp
	BooleanOp;	
 
%error-verbose
 
%%

Program:
	Decls { root = $1; }
;
 
Decls:
		Type Ident VarDecl ';' {
			Node *var = new_var_node($1, $2);
			env_put(top, (char *)((Node*)$2)->value, var);
		
			Node *temp = $3;
			while(temp != null){
				if(n1(temp) != null){
					Node *aux_node = new_var_node($1, n1(temp));
					env_put(top, (char *)n1(temp)->value, aux_node);
				}
				temp = n2(temp);
			}
		}
		Decls {
			Node *var = new_var_node($1, $2);
			$$ = new_decls_node(var, $3, $6);
		}
		
	|	Type Ident {
			Node *var = new_function_node($1, $2);
			env_put(top, (char *)((Node*)$2)->value, var);
			strcpy(cur_func, (char *)((Node*)$2)->value);
		}
		FuncDecl Decls {
			Node *var = new_function_node($1, $2);
			$$ = new_decls_node(var, $4, $5);
		}
		
	|	Type MAIN {
			Node *n = new_leaf_type(cID);
			char _main[5] = "main\0";
			n->value = (unsigned long) _main;
			
			Node *var = new_var_node($1, n);
			env_put(top, (char *)n->value, var);
			strcpy(cur_func, _main);
		}
		FuncDecl {
			Node *n = new_leaf_type(cID);
			char _main[5] = "main\0";
			n->value = (unsigned long) _main;
			
			Node *var = new_var_node($1, n);
			$$ = new_decls_node(var, $4, null);
		}
;

VarDecl:
		/* vazio */
		{ $$ = null; }
	|	',' Ident VarDecl {
			$$ = new_vardecl_node($2, $3);
		}
;

FuncDecl:
		'(' {
			// Se é uma função, empila e marca a flag de bloco de função
			saved = top; top = new_env(saved);
			has_pushed = 1;
		} ParamDeclList ')' {
			// Insere os parametros na tabela de funções
			char *s = malloc(sizeof(char)*100);
			strcpy(s, cur_func);
			g_hash_table_replace(func_params, s, $3);
		} Block {
			Node *n = new_funcdecl($3, $6);
			$$ = n;
		}
;

ParamDeclList:
		/* vazio */
		{ $$ = null; }
	|	ParamDeclListTail {
			$$ = $1;
		}
;

ParamDeclListTail:
		Type Ident {
			Node *var = new_var_node($1, $2);
			env_put(top, (char *)((Node*)$2)->value, var);
			$$ = new_paramdecllisttail_node(var, null);
		}
		
	|	Type Ident ',' ParamDeclListTail {
			Node *var = new_var_node($1, $2);
			env_put(top, (char *)((Node*)$2)->value, var);
			
			Node *temp = $4;
			while(temp != null){
				if(n1(temp) != null){
					Node *aux_node = new_var_node($1, n1(temp));
					env_put(top, (char *)n1(temp)->value, aux_node);
				}
				temp = n2(temp);
			}
			
			$$ = new_paramdecllisttail_node(var, $4);
		}
;

Block:
		'{' {
			if(!has_pushed) {
				saved = top; top = new_env(saved);
			}
			// Se é um bloco de função, então desmarca a flag
			has_pushed = 0;
		} VarDeclList StmtList '}' {
			$$ = new_block_node($3, $4);
			top = top->prev;
		}
		
	|	'{' {
			if(!has_pushed) {
				saved = top; top = new_env(saved);
			}
			// Se é um bloco de função, então desmarca a flag
			has_pushed = 0;
		} VarDeclList '}' {
			$$ = new_block_node($3, null);
			top = top->prev;
		}
;

VarDeclList:
		/* vazio */
		{ $$ = null; }
	|	Type Ident VarDecl ';' VarDeclList {
			Node *var = new_var_node($1, $2);
			env_put(top, (char *)((Node*)$2)->value, var);
			
			Node *temp = (Node*) $3;
			while(temp != null){
				if(n1(temp) != null){
					Node *aux_node = new_var_node($1, n1(temp));
					env_put(top, (char *)n1(temp)->value, aux_node);
				}
				temp = n2(temp);
			}
			
			$$ = new_vardecllist_node(var, $3, $5);
		}
;

Type:
		INTTP {
			Node *n = new_leaf_type(cINT);
			char tipo[4] = "int\0";
			n->value = (unsigned long) tipo;
			$$ = n;
		}
		
	|	CHARTP {
			Node *n = new_leaf_type(cCHAR);
			char tipo[5] = "char\0";
			n->value = (unsigned long) tipo;
			$$ = n;
		}
;

Ident:
		ID {
			Node *n = new_leaf_type(cID);
			n->value = (unsigned long) lex_value.stringval;
			$$ = n;
		}
		
	|	IDARRAY {
			Node *n = new_leaf_type(cARRAY);
			char *id = malloc(sizeof(char)*strlen(lex_value.stringval));
			array_id(id, lex_value.stringval);
			n->value = (unsigned long) id;
			
			Node *n2 = new_leaf_type(cARRAYPOS);
			char *pos = malloc(sizeof(char)*strlen(lex_value.stringval));
			array_pos(pos, lex_value.stringval);
			n2->value = (unsigned long) pos;
			
			n1(n) = n2;
			$$ = n;
		}
;

StmtList:
		Stmt {
			$$ = $1;
		}
		
	|	Stmt StmtList {
			$$ = new_stmtlist_node($1, $2);
		}
;

Stmt:
		Expr ';' {
			$$ = $1;
		}
		
	| RETURN Expr ';' {
			$$ = new_return_node($2);
		}
		
	| RETURN ';' {
			$$ = new_return_node(null);
		}
		
	| READ Ident ';' {
			if(!verify_env($2)) {
				//return 0;
			}
			$$ = new_read_node($2);
		}
	
	| WRITE Expr ';' {
			$$ = new_write_node($2);
		}
		
	| WRITE CONSTSTRING ';' {
			Node *n = new_string_node();
			n->value = (unsigned long) lex_value.stringval;
			$$ = n;
		}
		
	| WRITELN ';' {
			Node *n = new_string_node();
			char *a = "\n";
			n->value = (unsigned long) a;
			$$ = n;
		}
		
	| BREAK ';' {
			$$ = new_break_node();
		}
		
	| IF '(' Expr ')' Stmt {
			$$ = new_if_node($3, $5, null);
		}
		
	| IF '(' Expr ')' Stmt ELSE Stmt {
			$$ = new_if_node($3, $5, null);
		}
		
	| WHILE '(' Expr ')' Stmt {
			$$ = new_while_node($3, $5);;
		}
		
	| Block {
			$$ = $1;
		}
;

Expr:
		UnaryExpr '=' Expr {
			// Verifica se os tipos da expressão são os mesmos
			if(get_type($1) != get_type($3)){
				char error[100];
				char t1[10], t2[10];
				//sprintf(error, "Erro, atribuição de um tipo %s a um tipo %s", t2, t1);
				type_to_string(t1, get_type($1));
				type_to_string(t2, get_type($3));
				sprintf(error, "Erro, tipos diferem [%s a um %s]", t1, t2);
				yyerror(error);
			}
			
			$$ = new_expr_node($1, $3);
		}
		
	|	BinaryExpr {
			$$ = $1;
		}
;

BinaryExpr:
		BinaryExpr BinOp UnaryExpr {
			// Verifica se os tipos da expressão são os mesmos
			if(get_type($1) != get_type($3)){
				char error[100];
				char t1[10], t2[10];
				//sprintf(error, "Erro, atribuição de um tipo %s a um tipo %s", t2, t1);
				type_to_string(t1, get_type($1));
				type_to_string(t2, get_type($3));
				sprintf(error, "Erro, tipos diferem [%s a um %s]", t1, t2);
				yyerror(error);
			}
			$$ = new_binaryexpr_node($1, $2, $3);
		}
		
	|	UnaryExpr {
			$$ = $1;
		}
;

UnaryExpr:
		UnaryOp UnaryExpr {
			$$ = new_unaryexpr_node($1, $2);
		}
		
	|	PostFixExpr {
			$$ = $1;
		}
;

PostFixExpr:
		Ident '(' ArgumentList ')' {
			if(verify_env($1)) {
				Node *args = $3;
				Node *params = g_hash_table_lookup(func_params, (char*) $1->value);
				switch(compare_params_args(params, args)){
					case 1: yyerror("Tipo errado de argumetnos"); break;
					case 2: yyerror("Numero de argurmentos inferior a assinatura do método"); break;
					case 3: yyerror("Numero de argurmentos superior a assinatura do método"); break;
				}
			}
			$$ = new_postfixexpr_node($1, $3);
		}
		
	|	Ident '(' ')' {
			if(verify_env($1)) {
				Node *params = g_hash_table_lookup(func_params, (char*) $1->value);
				switch(compare_params_args(params, null)){
					case 1: yyerror("Tipo errado de argumetnos"); break;
					case 2: yyerror("Numero de argurmentos inferior a assinatura do método"); break;
					case 3: yyerror("Numero de argurmentos superior a assinatura do método"); break;
				}
			}
			$$ = $1;
		}
		
	|	Ident {
			verify_env($1);
			$$ = $1;
		}
		
	|	Constant {
			$$ = $1;
		}
		
	|	'(' Expr ')' {
			$$ = $2;
		}
;

Constant:
		INTCONST {
			Node *n = new_leaf_type(cINT);
			int i = lex_value.intval;
			n->value = (unsigned long) &i;
			$$ = n;
		}
		
	|	CHARCONST {
			Node *n = new_leaf_type(cCHAR);
			char c = lex_value.charval;
			n->value = (unsigned long) &c;
			$$ = n;
		}
;

ArgumentList:
		Expr {
			$$ = new_argumentlist_node($1, 0);
		}
		
	|	Expr ',' ArgumentList {
			$$ = new_argumentlist_node($1, $3);
		}
;

UnaryOp:
		MENOS {
			$$ = new_leaf_type(cMENOS);
		}
		
	|	EXCLAMACAO {
			$$ = new_leaf_type(cEXCLAMACAO);
		}
;

BinOp:
		BooleanOp {
			$$ = $1;
		}
		
	|	RelOp {
			$$ = $1;
		}
		
	|	AritmOp {
			$$ = $1;
		}
;

AritmOp:
		MAIS {
			$$ = new_leaf_type(cMAIS);
		}
		
	|	MENOS {
			$$ = new_leaf_type(cMENOS);
		}
		
	|	ESTRELA {
			$$ = new_leaf_type(cESTRELA);
		}
		
	|	BARRA {
			$$ = new_leaf_type(cBARRA);
		}
;

RelOp:
		IGUALA {
			$$ = new_leaf_type(cIGUALA);
		}
		
	|	DIFERENTEDE {
			$$ = new_leaf_type(cDIFERENTEDE);
		}
		
	|	MENOR {
			$$ = new_leaf_type(cMENOR);
		}
		
	|	MENORIGUAL {
			$$ = new_leaf_type(cMENORIGUAL);
		}
		
	|	MAIOR {
			$$ = new_leaf_type(cMAIOR);
		}
		
	|	MAIORIGUAL {
			$$ = new_leaf_type(cMAIORIGUAL);
		}
;

BooleanOp:
		ELOGICO {
			$$ = new_leaf_type(cELOGICO);
		}
		
	|	OULOGICO {
			$$ = new_leaf_type(cOULOGICO);
		}
;
%%

extern int yylineno;
extern FILE *yyin;
extern int error;

void yyerror(const char* errmsg) {
	error = TRUE;
	printf("ERRO: %s na linha %d \n", errmsg, yylineno);
}

// Mensagem de token encontrado
void _token(char *s){
	//printf("\nToken: %s encontrado na linha %d", s, yylineno);
}

// Mensagem de lexema encontrado
void _lex(char *s){
	//printf("\nToken: %s encontrado na linha %d", s, yylineno);
}
 
int yywrap(void) { return 1; }

int main( int argc, char **argv ) {
	++argv, --argc;
	
	error = FALSE;
	if ( argc > 0 ) {
		 yyin = fopen( argv[0], "r" );
	}
	else {
		 yyin = stdin;
	}
	
	func_params = g_hash_table_new(g_str_hash, g_str_equal);
	top = new_env(null);
	
	yyparse();
	
	if(error == FALSE){
		printf("\nANALISE OK.\n");
	}
	else {
		printf("\nERRO(S) FORAM ENCONTRADOS\n");
	}
	return 0;
}

int compare_params_args(Node *params, Node *args) {
	Node *aux;
	while(params != null && params->type == cPARAMDECLLISTTAIL) {
		if(args == null || args->type != cARGUMENTLIST){
			// A quantidade argumentos é menor que a de parametros
			return 2; // Quantidade dos parâmetros inferior
		}
		
		// Pega a variável mais a esquerda do parametro
		Node *var = n1(params);
		// Pega a expreção mais a esquerda do argumento
		Node *expr = n1(args);
		
		// Verifica se os tipos são iguais
		if(n1(var)->type != get_type(expr)){
			return 1; // tipo dos parâmetros diferentes
		}
		
		params = n2(params);
		args = n2(args);
	}
	// Verifica se está sendo passado mais algum argumento
	if(args != null && args->type == cARGUMENTLIST){
		return 3; // Quantidade dos parâmetros maior
	}
	
	return 0; // Argumentos corretos
}

enum node_type get_type(Node *n){
	if(n->type == cEXPR){
		n = n1(n);
	}
	// Percorre a arvore até encontrar o nó folha mais a esquerda
	while(n->type == cBINEXPR){
		n = n1(n);
	}
	while(n->type == cUNAEXPR){
		n = n2(n);
	}
	
	// Verifica se o nó é um POSTFIX
	if(n->type == cPOSTFIXEXPR){
		// Então pega o identificador do nó
		n = n1(n);
	}
	
	// Verifica se é uma constante
	if(n->type == cCHAR || n->type == cINT){
		return n->type;
	}
	
	// Verifica se é um identificador
	if(n->type == cID || n->type == cARRAY){
		// Verifica a variável é do tipo array, se for, retorna o tipo array
		Node *var = (Node*) env_get(top, (char*)n->value);
		if(n2(var) && n2(var)->type == cARRAY && n->type == cID) return cARRAY;
		
		// Se não retorna o tipo int ou char
		return n1(var)->type;
	}
}

