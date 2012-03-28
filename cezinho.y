%{
	#include<stdio.h>
	#include<stdlib.h>
	FILE *yyin;
	extern int yylineno;
	extern int yylex();
	void yyerror(char const *msg);
	char* constString=NULL;
%}

%token programa
%token car
%token carconst
%token id
%token int
%token intconst
%token retorne
%token leia
%token escreva
%token cadeiaCaracteres
%token novalinha
%token se
%token entao
%token senao
%token enquanto
%token execute
%token leia
%token atribuicao

%error-verbose
%%
Programa:	DeclFuncVar DeclProg

;
DeclFuncVar:	Tipo id DeclVar ';' DeclFuncVar
		| Tipo id '[' INTCONST ']' DeclVar ';' DeclFuncVar

		| Tipo id DeclFunc DeclFuncVar
;

DeclProg:	programa Bloco
;

DeclVar:	' '
		| ',' id DeclVar

		| ',' id '[' INTCONST ']' DeclVar
;
DeclFunc:	'(' ListaParametros ')' Bloco
;

ListaParametros:	' '
		| ListaParametrosCont
;

ListaParametrosCont:	Tipo id

		| Tipo id '[' ']'
		| Tipo id ',' ListaParametrosCont
		| Tipo id '[' ']' ',' ListaParametrosCont
; 
Bloco:		'{' ListaDeclVar ListaComando '}'
		| '{' ListaDeclVar '}'
;
ListaDeclVar:	' '
		| Tipo id DeclVar ';' ListaDeclVar
		| Tipo id '[' INTCONST ']' DeclVar ';' ListaDeclVar
;

Tipo:		int
		| car
;

ListaComando:	Comando
		| Comando ListaComando
;

Comando:	';'
		| Expr ';'
		| retorne Expr ';'
		| leia LValueExpr ';'
		| escreva Expr ';'
		| escreva cadeiaCaracteres ';'
		| novalinha ';'
		| se '(' Expr ')' entao Comando

		| se '(' Expr ')' entao Comando senao Comando

		| enquanto '(' Expr ')' execute Comando
		| Bloco
;

Expr:		AssignExpr
;

AssignExpr:	CondExpr
		| LValueExpr=AssignExpr
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

LValueExpr:	id '[' Expr ']'
		| id
;

PrimExpr:	id '(' ListExpr ')'

		| id '(' ')'
		| id '[' Expr ']'
		| id
		| carconst
		| intconst
		| '(' Expr ')'
;

ListExpr:	AssignExpr
		| ListExpr ';' AssignExpr
;
