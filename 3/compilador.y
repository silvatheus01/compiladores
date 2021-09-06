%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

/*struct Atributos {
  string exp;
};

#define YYSTYPE Atributos
*/

map<string, int> vars;
int cont_linha = 1;

void insere_var(string var);
void checa_var(string var);

int yylex();
int yyparse();
void yyerror(const char *);

%}

%token OL DV FOR_T WHILE_T IF_T ELSE_T IFELSE_T NUM ID STRING

// Sentença inicial da gramática
%start B

%right '=' 
%nonassoc OL
%left '+' '-' '*' '/' '%'

%%

// Bloco de código
B: LVALUE '=' RVALUE ';' B
  | DV ID V ';' B
  | FOR B
  | IF B
  | WHILE B
  |
  ;

// Definição de objeto
DEFO: '{' '}'
  ;

// Definição de array
DEFA: '[' ']'
  ;

// Array preenchido
AP: '[' ID '=' E ']'AP
  | '[' ID '=' S ']'AP
  | '[' NUM ']'AP
  | 
  ;

LVALUEPROP: ID AP
  | ID '.' ID
  ;


RVALUE: E
  | S
  | DEFO
  | DEFA
  | LVALUEPROP R
  ;


LVALUE: DV ID 
  | LVALUEPROP
  ;


// Duas ou mais instanciações 
R: '=' RVALUE R 
  | 
  ;

V: ',' ID '=' RVALUE V
  | ',' ID V
  |
  ;

S: STRING '+' S
  | ID
  | STRING
  ;

C: E OL E
  | S OL S
  ;

FOR1: DV ID '=' NUM
  | ID '=' NUM
  | DV ID
  ;

FOR2: C
  ;

FOR3: ID '=' E
  ;

FOR: FOR_T'('FOR1 ';' FOR2 ';' FOR3')''{' B '}'
  ;

IF: IF_T'('C')' B IFELSE
  ;

ELSE: ELSE_T'{' B '}'
  ;

IFELSE: IFELSE_T'('C')' '{'B'}' IFELSE
  | ELSE
  |
  ;

WHILE: WHILE_T'('C')''{' B '}'
  ;

E: T E_
  ;

E_: '+' T E_ { $$ = '+'; }
  | '-' T E_ { $$ = '-'; }
  | 
  ;

T: F T_
  ;

T_: '*' F T_ { $$ = '*'; }
  | '/' F T_ { $$ = '/'; }
  | 
  ;

F: ID
  | NUM
  | '(' E ')' {$$ = $2;}
  ;
  
%%

#include "lex.yy.c"

void insere_var(string var){
  if(vars.find(var) != vars.end()){
    string msg = "Erro: a variável '"  + var + "' já foi declarada na linha" + to_string(vars.find(var)->second) + ".";
    yyerror(msg.c_str());
  }
  vars.insert(pair<string,int>(var,cont_linha));
}

void checa_var(string var){
  if(vars.find(var) == vars.end()){
    string msg = "Erro: a variável '"  + var + "' não foi declarada.";
    yyerror(msg.c_str());
  }
}

void yyerror( const char* msg ) {
  puts( msg ); 
  exit( 0 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}