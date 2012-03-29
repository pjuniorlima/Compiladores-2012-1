%{
	#include<stdio.h>
	#include<stdlib.h>
	FILE *yyin;
	extern int yylineno;
	extern int yylex();
	void yyerror(char const *msg);
	char* constString=NULL;
%}

%token PROGRAMA
%token CAR
%token CARCONST
%token IDENTIFICADOR
%token INT
%token INTCONST
%token RETORNE
%token LEIA
%token ESCREVA
%token CADEIACARACTERES
%token NOVALINHA
%token SE 
%token ENTAO
%token SENAO
%token ENQUANTO
%token EXECUTE
%token ATRIBUICAI

%error-verbose
%%

Programa:	DeclFuncVar DeclProg
;
DeclFuncVar:	Tipo IDENTIFICADOR DeclVar ';' DeclFuncVar
		| Tipo IDENTIFICADOR '[' INTCONST ']' DeclVar ';' DeclFuncVar
		| Tipo IDENTIFICADOR DeclFunc 
;

DeclProg:	PROGRAMA Bloco
;

DeclVar:	
		| ',' IDENTIFICADOR DeclVar

		| ',' IDENTIFICADOR '[' INTCONST ']' DeclVar
;
DeclFunc:	'(' ListaParametros ')' Bloco
;

ListaParametros:	
		| ListaParametrosCont
;

ListaParametrosCont:	Tipo IDENTIFICADOR
		| Tipo IDENTIFICADOR '[' ']'
		| Tipo IDENTIFICADOR ',' ListaParametrosCont
		| Tipo IDENTIFICADOR '[' ']' ',' ListaParametrosCont
; 
Bloco:		'{' ListaDeclVar ListaComando '}'
		| '{' ListaDeclVar '}'
;
ListaDeclVar:	
		| Tipo IDENTIFICADOR DeclVar ';' ListaDeclVar
		| Tipo IDENTIFICADOR '[' INTCONST ']' DeclVar ';' ListaDeclVar
;

Tipo:		INT
		| CAR
;

ListaComando:	Comando
		| Comando ListaComando
;

Comando:	';'
		| Expr ';'
		| RETORNE Expr ';'
		| LEIA LValueExpr ';'
		| ESCREVA Expr ';'
		| ESCREVA CADEIACARACTERES ';'
		| NOVALINHA ';'
		| SE '(' Expr ')' ENTAO Comando
		| SE '(' Expr ')' ENTAO Comando SENAO Comando
		| ENQUANTO '(' Expr ')' EXECUTE Comando
		| Bloco
;

Expr:		AssignExpr
;

AssignExpr:	CondExpr
		| LValueExpr '=' AssignExpr
;

CondExpr:	OrExpr
		| OrExpr '?' Expr ':' CondExpr
;

OrExpr:		OrExpr 'ou' AndExpr
		| AndExpr
;
AndExpr:	AndExpr 'e' EqExpr
		| EqExpr
;

EqExpr:		EqExpr '==' DesigExpr
		| EqExpr '!=' DesigExpr
		| DesigExpr
;

DesigExpr:	DesigExpr '<' AddExpr
		| DesigExpr '>' AddExpr
		| DesigExpr '>=' AddExpr
		| DesigExpr '<=' AddExpr
		| AddExpr
;

AddExpr:	AddExpr '+' MulExpr

		| AddExpr '-' MulExpr
		| MulExpr
;

MulExpr:	MulExpr '*' UnExpr

		| MulExpr '=' UnExpr

		| MulExpr '%' UnExpr

		| UnExpr
;

UnExpr:		PrimExpr
		| '!' PrimExpr
		| PrimExpr
;

LValueExpr:	IDENTIFICADOR '[' Expr ']'
		| IDENTIFICADOR
;

PrimExpr:	IDENTIFICADOR '(' ListExpr ')'
		| IDENTIFICADOR '(' ')'
		| IDENTIFICADOR '[' Expr ']'
		| IDENTIFICADOR
		| CARCONST
		| INTCONST
		| '(' Expr ')'
;

ListExpr:	AssignExpr
		| ListExpr ';' AssignExpr
;
%%
void yyerror(char const* msg){
	printf("%s -- Linha %d\n", msg, yylineno);
}
int main(int argc, char** argv){
	if(argc != 2){
		printf("Uso: cezinho <nome>\n");
		exit(1);
	}
	yyin=fopen(argv[1], "rt");
	if(yyin)
		return yyparse();
	else
		yyerror("arquivo não encontrado.\n");
	return 1;
}
		
