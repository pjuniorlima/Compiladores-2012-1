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
%token CHAR
%token IDENTIFICADOR
%token INT
%token CHAR
%token RETORNE
%token LEIA
%token ESCREVA
%token NOVALINHA
%token SE
%token ENTAO
%token SENAO
%token ENQUANTO
%token EXECUTE
%token LEIA
%token ATRIBUICAO

%error-verbose
%%
Programa:	DeclaracoesFuncVariaveis DeclaracaoPrograma
;
DeclacacoesFuncVariaveis





