%{
	#include "cezinho.tab.h"
	#define BUFFSIZE 800
		extern char* constString;
	
%}

CHAR		['][!-~][']
DIGIT		[0-9]
LETTER		[A-Za-z]
ID		{LETTER}({LETTER}_{DIGIT})*
WHITESPACE	[\t\n\r' ']
NUMBER		{digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%

programa {
		return PROGRAMA;
	}

int	{
		return INT;
	}

retorne	{
		return RETORNE;
	}

leia	{
		return LEIA;
	}

escreva	{
		return ESCREVA;
	}

novalinha	{
		return NOVALINHA;
	}

se	{
		return SE;
	}

entao	{
		return ENTAO;
	}

enquanto	{
		return ENQUANTO;
	}

execute	{
		return EXECUTE;
	}
"\""	{
		register int x;
		if(constString)
			free(constString);
			if( !(constString = (char*)malloc(BUFFSIZE))){
				printf("Não há memória para armazenar a String na linha %d\n", yylineno);
				return 1;
			}
			int i=0;
			char c;
			while((c=input()) != '\"' && c != EOF && c != '\n'){
				constString[i++]=c;
				if(i==BUFFSIZE){
					constString = (char*) realloc(constString, 2*BUFFSIZE);
					if(!constString){
						printf("Não há memória para armazenar a String na linha %d\n", yylineno);
						return 1;
					}
				}
			}
			if(c != '\"'){
				printf("Erro na linha %d\n", yylineno);
				return 1;
			}
			constString[i] = '\0';
			return CADEIACARACTERES;

	}

"!="	{
		return DIFERENTE;
	}

"=="	{
		return IGUAL;
	}

">"	{
		return MAIOR;
	}

"<"	{
		return MENOR;
	}

"<="	{
		return MENORIGUAL;
	}

">="	{
		return MAIORIGUAL;
	}

{DIGIT}+	{
		*yylval=atoi(yytext);
		return (INTCONST);
	}

{CHAR}	{
		return (CHARCONST);
	}

{ID}+	{
		return (IDENTIFICADOR);
	}

{WHITESPACE}

.	{
		printf("Caractere inválido %s.\n", yytext);
		return (-1);
	}

%%

int yywrap();
main(){
	yylex();
}

int yywrap(){
	return 1;
}
	
