%{
	#include "cezinho.tab.h"
	#define BUFFSIZE 800
		extern char* constString;
	
%}

CHAR		['][!-~][']
DIGIT		[0-9]
ID		[a-zA-Z\_][a-zA-Z\_0-9]*
WHITESPACE	[\t\n\r ]
CADEIACARACTERES 	[\"]([^\"\\\n]|([\\](.|[\n])))*[\"]

%%

programa {
		return(PROGRAMA);
	}

int	{
		return(INT);
	}

car	{
		return(CAR);
	}

retorne	{
		return(RETORNE);
	}

leia	{
		return(LEIA);
	}

escreva	{
		return(ESCREVA);
	}

novalinha	{
		return(NOVALINHA);
	}

se	{
		return(SE);
	}

entao	{
		return(ENTAO);
	}

senao	{
		return(SENAO);
	}

enquanto	{
		return(ENQUANTO);
	}

execute	{
		return(EXECUTE);
	}

"="	{
		return(ATRIBUICAO);
	}

"!"	{
		return(NEGACAO);
	}

ou	{
		return(OULOGICO);
	}

e	{
		return(ELOGICO);
	}

"("	{
		return(ABREPAR);
	}

")"	{
		return(FECHAPAR);
	}

"{"	{
		return(ABRECHAVE);
	}

"}"	{
		return(FECHACHAVE);
	}

"["	{
		return(ABRECOLCH);
	}

"]"	{
		return(FECHACOLCH);
	}

","	{
		return(VIRGULA);
	}

";"	{
		return(PONTOVIRGULA);
	}

"+"	{
		return(ADICAO);
	}

"-"	{
		return(SUBTRACAO);
	}

"/"	{
		return(DIVISAO);
	}

"*"	{
		return(MULTIPLICACAO);
	}

"%"	{
		return(MOD);
	}

"?"	{
		return(INTERROGACAO);
	}

":"	{
		return(DOISPONTOS);
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
			return(CADEIACARACTERES);
	}

"/*" {
	register int c;
	
	while(1){
		while ((c = input()) != '*' && c != EOF);
		if ( c == '*' ){
			while ((c = input()) == '*');
			if ( c == '/' )
				break;
		}
		if ( c == EOF ){
			printf("Comentário não termina.\n");
			return 1;
		}
	}
}

"!="	{
		return(DIFERENTE);
	}

"=="	{
		return(IGUAL);
	}

">"	{
		return(MAIOR);
	}

"<"	{
		return(MENOR);
	}

"<="	{
		return(MENORIGUAL);
	}

">="	{
		return(MAIORIGUAL);
	}

{DIGIT}+	{
		yylval=atoi(yytext);
		return(INTCONST);
	}

{CHAR}	{
		return (CAR);
	}

{ID}+	{
		return (IDENTIFICADOR);
	}

{CADEIACARACTERES}	{
		return(CADEIACARACTERES);
}

{WHITESPACE}

.	{
		printf("Caractere inválido %s.\n", yytext);
		return (-1);
	}

%%

int yywrap();

int yywrap(){
	return 1;
}
	
