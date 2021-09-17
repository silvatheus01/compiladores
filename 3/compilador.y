%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

struct Atributos {
  // Atributo "código" de uma regra
  vector<string> c;
};

#define YYSTYPE Atributos


map<string, int> vars;
int cont_linha = 1;

void insere_var(string var);
void checa_var(string var);

// Auxilia com as labels
vector<string> operator+( vector<string> a, string b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> concatena( vector<string> a, vector<string> b );
string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
void imprime(vector<string> codigo);
vector<string> novo;

int yylex();
int yyparse();
void yyerror(const char *);

%}

%token DV_T FOR_T WHILE_T IF_T ELSE_T ELSEIF_T NUM_T ID_T STRING_T

// Sentença inicial da gramática
%start S

%right '=' 
%nonassoc '>' '<'
%left '+' '-'
%left '*' '/'


%%
S: CMDs { imprime(resolve_enderecos($1.c));}
  ;

CMD: LVALUE '=' RVALUE R V ';' {$$.c = $1.c + $3.c  + $4.c + "=" + "^" + $5.c;}
  | FOR                    
  | IF                    
  | WHILE                  
  ;

// Bloco de código
CMDs: CMD CMDs  {$$.c = $1.c + $2.c;}
  | FOR CMDs    {$$.c = $1.c + $2.c;}
  | IF CMDs     {$$.c = $1.c + $2.c;}
  | WHILE CMDs  {$$.c = $1.c + $2.c;}
  |             {$$.c = novo;}
  ;


// Definição de objeto
DEFO: '{' '}' {$$.c = novo + "{}";}
  ;

// Definição de array
DEFA: '[' ']' {$$.c = novo + "[]";}
  ;

// Array preenchido
AP: '[' ID_T '=' E ']'AP    {$$.c = $2.c + "@" + $4.c + "=" + "^" + $6.c + "[=]";}
  | '[' ID_T '=' STR ']'AP  {$$.c = $2.c + "@" + $4.c + "=" + "^" + $6.c + "[=]";}
  | '[' NUM_T ']'AP         {$$.c = $2.c + $4.c + "[=]";}
  | 
  ;

RVALUEPROP: ID_T AP   {$$.c = $1.c + "@";}
  | ID_T '.' ID_T     {$$.c = $1.c + "@" + ($3.c + "[@]");}
  ;

LVALUEPROP: ID_T AP   {$$.c = $1.c;}
  | ID_T '.' ID_T     {$$.c = $1.c + "@" + $3.c;}
  | RVALUEPROP
  ;


RVALUE: E
  | STR
  | DEFO
  | DEFA
  | LVALUE
  ;


LVALUE: DV_T ID_T {$$.c = $2.c + "&" + $2.c;}
  | ID_T          { $$.c = $1.c; }
  ;


// Duas ou mais instanciações 
R: '=' RVALUE R {$$.c = $2.c + "=";} // Para múltiplas atribuições
  |             {$$.c = novo;}        
  ;

// Virgula
V: ',' ID_T '=' RVALUE V  {$$.c = $2.c + "&" + $2.c + $4.c + "=" + "^" + $5.c;}
  | ',' ID_T V            {$$.c = $2.c + "&" + $3.c;}
  |                       {$$.c = novo;}
  ;

STR: STRING_T '+' STR   {$$.c = $1.c + $3.c + "+";}
  | ID_T '+' STR        {$$.c = $1.c + "@" + $3.c + "+";} 
  | STRING_T
  | ID_T                {$$.c = $1.c + "@";} 
  ;

// Condição
C: E '<' E           {$$.c = $1.c + $3.c + $2.c;}
  | E '>' E          {$$.c = $1.c + $3.c + $2.c;}
  ;


IF: IF_T'('C')'CMD ELSEIF        {string if_ou_elseif = gera_label("if_ou_elseif");
                                  $$.c = $3.c + "!" + if_ou_elseif + "?" +  $5.c + (":" + if_ou_elseif);}
  | IF_T'('C')''{'CMDs'}'ELSEIF  {string if_ou_elseif = gera_label("if_ou_elseif");
                                  $$.c = $3.c + "!" + if_ou_elseif + "?" +  $6.c + (":" + if_ou_elseif);}
  ;

ELSE: ELSE_T'{' CMDs '}'  {$$.c = $3.c;}
  | ELSE_T CMD            {$$.c = $2.c;}   
  ;

ELSEIF: ELSEIF_T'('C')' CMD ELSEIF  {string elseif = gera_label("elseif");
                                    $$.c = $3.c + "!" + elseif + "?" +  $5.c + (":" + elseif);}
  | ELSEIF_T'('C')''{'CMDs'}'ELSEIF {string elseif = gera_label("elseif");
                                    $$.c = $3.c + "!" + elseif + "?" +  $6.c + (":" + elseif);}
  | ELSE                            
  |
  ;

FOR1: DV_T ID_T '=' NUM_T
  | ID_T '=' NUM_T
  | DV_T ID_T
  ;

FOR2: C
  ;

FOR3: ID_T '=' E
  ;

FOR: FOR_T'('FOR1 ';' FOR2 ';' FOR3')''{' CMDs '}'
  ;

WHILE: WHILE_T'('C')''{' CMDs '}'
  ;


E: E '+' T  { $$.c = $1.c + $3.c + "+"; }
  | E '-' T { $$.c = $1.c + $3.c + "-"; }
  | T
  ;

T: T '*' F  { $$.c = $1.c + $3.c + "*"; }
  | T '/' F { $$.c = $1.c + $3.c + "/"; }
  | F
  ;


F: ID_T       { $$.c = $1.c + "@"; }
  | NUM_T     { $$.c = $1.c; }
  | '(' E ')' { $$ = $2; }
  ;
  
%%

#include "lex.yy.c"

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+( vector<string> a, string b ) {
  a.push_back( b );
  return a;
}


void insere_var(string var){
  if(vars.find(var) != vars.end()){
    string msg = "Erro: a variável '"  + var + "' já foi declarada na linha" + to_string(vars.find(var)->second) + ".";
    exit(1);
  }
  vars.insert(pair<string,int>(var,cont_linha));
}

void checa_var(string var){
  if(vars.find(var) == vars.end()){
    string msg = "Erro: a variável '"  + var + "' não foi declarada.";
    exit(1);
  }
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

void imprime(vector<string> codigo){
  for(int i = 0; i < codigo.size(); i++)
    cout << codigo[i] << endl;
    
  cout << "." << endl;
}


void yyerror( const char* msg ) {
  cout << "Erro de sintaxe na linha " << to_string(cont_linha) << " próximo a:" << yytext << endl;
  exit( 1 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}