%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

struct Atributos {
  string e;
  string d;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);

%}

%token NUM CTE X

// Indica o símbolo inicial da gramática
%start B

%%

O: '{' '}'
  ;

A: '[' ']'
  ;

LVALUEPROP: E '[' E ']' 
  | E '.' id
  ;


RVALUE: E
  | S
  | LVALUEPROP
  ;


LVALUE: id
  | dv id 
  | LVALUEPROP
  ;


// Duas ou mais instanciações 
R: '=' RVALUE R 
  | 
  ;

// Bloco de código
B: LVALUE '=' RVALUE R V ';' B
  | LVALUEPROP '=' RVALUE ';' B
  | dv id ';' B
  | 
  // Falta regras
  ;

V: ',' id '=' RVALUE V
  | ',' id V
  |
  ;

E: T E'
  ;

E': '+' T { printf("+ "); } E'
  | '-' T { printf("- "); } E'
  | 
  ;

T: F T'
  ;

T': '*' F { printf("* "); } T'
  | '/' F { printf("/ "); } T'
  | 
  ;

F: id { printf("%s @ ", id); }
  | num { printf(num, %d); }
  | ( E )
  ;

S: '+' string S
  |
  ;

  
%%

#include "lex.yy.c"

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Proximo a: %s\n", yytext );
   exit( 0 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}