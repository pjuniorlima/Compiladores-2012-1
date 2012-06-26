/**
 * Primeiro trabalho de compiladores
 *
 * scanner.l
 *	Define as regras do analisador léxico.
 *
 * Alunos: Arthur, Danilo e Luila
 */
%{
#include <string.h>

#include "parser.h"
#include "common.h"
#include "node.h"

#define save_string(a, b, c) a = malloc(sizeof(char)*c+1); strncpy(a, b, c); a[c] = '\0'

int yylineno;
int error;

extern scanner lex_value;
%}

/* Definições */
ID 			[a-z][a-z0-9]*
CHAR 		[a-zA-Z0-9]
STRING 		[a-zA-Z0-9 \t\[\],.\-:=]+
STRING_CR	[a-zA-Z0-9\[\],.=\- \n\t]+
WHITESPACE 	[ \t]+
NEWLINE 	[\n\r]
DIGITS 		[0-9]+
ANY_CHAR 	.
 
%option case-insensitive
 
%% /* Regras */
 
{WHITESPACE} /* Ignore */ ;
{NEWLINE} 		{ yylineno++; }

"main" 			{ _token("main"); return MAIN; }
"int" 			{ _token("int"); return INTTP; }
"char" 			{ _token("char"); return CHARTP; }
"return" 		{ _token("return"); return RETURN; }
"read" 			{ _token("read"); return READ; }
"write" 		{ _token("write"); return WRITE; }
"writeln" 		{ _token("writeln"); return WRITELN; }
"break" 		{ _token("break"); return BREAK; }
"if" 			{ _token("if"); return IF; }
"else" 			{ _token("else"); return ELSE; }
"while" 		{ _token("while"); return WHILE; }
{DIGITS} 		{ _token("NUM"); sscanf(yytext, "%d", &lex_value.intval); return INTCONST; }
"'"{CHAR}"'" 	{ _token("CHAR"); sscanf(yytext, "'%c", &lex_value.charval); return CHARCONST; }
"-" 			{ _lex("sinal de menos"); return MENOS; }
"!" 			{ _lex("negacao"); return EXCLAMACAO; }
"+" 			{ _lex("soma"); return MAIS; }
"*" 			{ _lex("multiplicao"); return ESTRELA; }
"/" 			{ _lex("divisao"); return BARRA; }
"==" 			{ _lex("equivalencia"); return IGUALA; }
"!=" 			{ _lex("nao equivalencia"); return DIFERENTEDE; }
"<" 			{ _lex("menor"); return MENOR; }
"<=" 			{ _lex("menor igual"); return MENORIGUAL; }
">" 			{ _lex("maior"); return MAIOR; }
">=" 			{ _lex("maior igual"); return MAIORIGUAL; }
"&&" 			{ _lex("e logico"); return ELOGICO; }
"||" 			{ _lex("ou logico"); return OULOGICO; }

{ID}				{ _token("id"); save_string(lex_value.stringval, yytext, yyleng); return ID; }
{ID}"["{DIGITS}"]"	{ _token("id(tipo array)"); save_string(lex_value.stringval, yytext, yyleng); return IDARRAY; }
{ID}"["{ID}"]"		{ _token("id(tipo array)"); save_string(lex_value.stringval, yytext, yyleng); return IDARRAY; }

"\""{STRING}"\""	{
	_token("CONSTSTRING");
	save_string(lex_value.stringval, yytext+1, yyleng-2); // +1 e -2 são para desconsiderar as aspas
	return CONSTSTRING;
}

"\""{STRING_CR}"\""	{
					error = TRUE;
					printf("\nERRO:Cadeia de caracteres ocupa mais de uma linha (linha: %d)", yylineno);
					}

"/*"	{
	register int c;

	for ( ; ; ) {
		/* Consome os caracteres do comentário */
		while ( (c = input()) != '*' && c != EOF );

		if ( c == '*' ) {
			while ( (c = input()) == '*' );
			
			if ( c == '/' )
				break; /* Fim do comentário */
		}

		if ( c == EOF ) {
			error = TRUE;
			printf( "\nERRO: COMENTARIO NAO TERMINA" );
			break;
		}
	}
}

"=" 			{ return '='; }
";" 			{ return ';'; }
"," 			{ return ','; }
")" 			{ return ')'; }
"(" 			{ return '('; }
"{"				{ return '{'; }
"}" 			{ return '}'; }
 
{ANY_CHAR} {
	error = TRUE;
	printf("\nERRO:Caractere inválido: '%c' na linha %d", yytext[0], yylineno);
}
