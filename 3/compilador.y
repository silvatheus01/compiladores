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

// Definição de objeto
DEFO: '{' '}'
  ;

// Definição de array
DEFA: '[' ']'
  ;

// Array preenchido
AP: '[' id '=' E ']'AP
  | '[' id '=' S ']'AP
  | '[' num ']'AP
  | 
  ;

LVALUEPROP: id AP
  | id '.' id
  ;


RVALUE: E
  | S
  | DEFO
  | DEFA
  | LVALUEPROP R
  ;


LVALUE: dv id 
  | LVALUEPROP
  ;


// Duas ou mais instanciações 
R: '=' RVALUE R 
  | 
  ;

// Bloco de código
B: LVALUE '=' RVALUE ';' B
  | dv id V ';' B
  | FOR B
  | IF B
  | WHILE B
  ;

V: ',' id '=' RVALUE V
  | ',' id V
  |
  ;

S: string '+' S
  | id
  | string
  ;

C: E ol E
  | S ol S
  ;

FOR1: dv id '=' num
  | id '=' num
  | dv id
  ;

FOR2: C
  ;

FOR3: id '=' E
  ;

FOR: for'('FOR1 ';' FOR2 ';' FOR3)'{' B '}'
  ;

IF: if'('C')' B IFELSE
  ;

ELSE: else'{' B '}'
  ;

IFELSE: if else'('C')' '{'B'}' IFELSE
  | ELSE
  |
  ;

WHILE: while'('C')''{' B '}'
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