%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <stdbool.h>

using namespace std;

struct Atributos {
  // Atributo "código" de uma regra
  vector<string> c;
};

#define YYSTYPE Atributos


map<vector<string>, int> vars_global;
set<vector<string>> vars_local;
int cont_linha = 1;

// Insere variável no vetor de variáveis no escopo global
void insere_var(vector<string> var);
// Checa variáveis nos dois escopos
void checa_var(vector<string> var);

// Auxilia com as labels
vector<string> operator+( vector<string> a, string b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> concatena( vector<string> a, vector<string> b );
string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
void imprime(vector<string> codigo);
vector<string> novo;

/*Auxilia com as funções*/
vector<string> funcoes;
// Conta a posição atual de um parâmatro
int pos_parametro = 0;
// Conta o número de parâmetros
int num_parametros = 0;
bool escopo_local;
void elimina_vars_locais();


int yylex();
int yyparse();
void yyerror(const char *);

%}

%token OR_T DV_T FOR_T WHILE_T IF_T ELSE_T ELSEIF_T NUM_T ID_T STRING_T FUNCTION_T RETURN_T

// Sentença inicial da gramática
%start S

%right '=' 
%nonassoc '>' '<' OR_T
%left '+' '-'
%left '*' '/'


%%
S: CMDs { $$.c = $1.c + "." + funcoes; imprime(resolve_enderecos($$.c));}
  ;

CMD: E V ';'                 {$$.c = $1.c + "^" + $2.c;}
  | FOR                    
  | IF                    
  | WHILE
  | DF                  
  ;

// Bloco de código
CMDs: CMD CMDs  {$$.c = $1.c + $2.c;}
  |             {$$.c = novo;}
  ;

// Definir função 
DF: FUNCTION_T ID_T'('PD')''{'CMDsF'}'  { escopo_local = true;
                                        string cmds_function = gera_label("funcao");
                                        pos_parametro = 0;
                                        funcoes = funcoes + (":" + cmds_function) + $4.c + $7.c + "undefined" +  "@" + "'&retorno'" +  "@" + "~";
                                        $$.c = $2.c + "&" + $2.c + "{}" + "=" + "'&funcao'" + cmds_function + "[=]" + "^";
                                        elimina_vars_locais();}
  ;

// Chamar função
CF: ID_T'('PC')'  {$$.c = $3.c + to_string(num_parametros) + $1.c + "@" + "$"; 
                  num_parametros = 0;
                  }

// Parâmetros de função quando chamamos uma função 
PC: E         {num_parametros++; $$.c = $1.c;}
  | E ',' PC  {num_parametros++; $$.c = $1.c + $3.c;}
  |           {$$.c = novo;}
  ;

// Parâmetros de função quando definimos uma função
PD: ID_T        { insere_var($1.c);
                $$.c = $1.c + "&" + $1.c + "arguments" + "@" + to_string(pos_parametro) + "[@]" + "=" + "^";
                }                             
  | ID_T ',' PD {insere_var($1.c);
                $$.c = $1.c + "&" + $1.c + "arguments" + "@" + to_string(pos_parametro) + "[@]" + "=" + "^" + $3.c;
                pos_parametro++;
                }
  |             {$$.c = novo;}
  ;

// Comandos para função
CMDsF: CMD CMDsF {$$.c = $1.c + $2.c;}
  | RETURN_T E ';'   {$$.c = $2.c + "'&retorno'" + "@" + "~";}
  ;

// Definição de objeto
DEFO: '{' '}' {$$.c = novo + "{}";}
  ;

// Definição de array
DEFA: '[' ']' {$$.c = novo + "[]";}
  ;

// Array preenchido
AP: '[' E ']'AP       {$$.c = $2.c + "[@]" + $4.c;}
  | '[' E ']'         {$$.c = $2.c;}
  ;


LVALUEPROP: ID_T AP   {$$.c = $1.c + "@" + $2.c; checa_var($1.c);}
  | ID_T '.' ID_T     {$$.c = $1.c + "@" + $3.c; checa_var($1.c);}
  | ID_T '.' ID_T AP  {$$.c = $1.c + "@" + $3.c  + "[@]" + $4.c; checa_var($1.c);}
  ;

LVALUE: ID_T {$$.c = $1.c;}
  ;

// Virgula
V: ',' ID_T '=' E V       {$$.c = $2.c + "&" + $2.c + $4.c + "=" +"^" + $5.c; insere_var($2.c);}
  | ',' ID_T V            {$$.c = $2.c + "&" + $3.c; insere_var($2.c);}
  |                       {$$.c = novo;}
  ;

// Condição
C: E '<' E           {$$.c = $1.c + $3.c + $2.c;}
  | E '>' E          {$$.c = $1.c + $3.c + $2.c;}
  | E OR_T E         {$$.c = $1.c + $3.c + $2.c;}
  ;


IF: IF_T'('C')'CMD ELSEIF         {string if_ou_elseif = gera_label("if_ou_elseif");
                                  $$.c = $3.c + "!" + if_ou_elseif + "?" +  $5.c + (":" + if_ou_elseif) + $6.c;}
  | IF_T'('C')''{'CMDs'}'ELSEIF   {string if_ou_elseif = gera_label("if_ou_elseif");
                                  $$.c = $3.c + "!" + if_ou_elseif + "?" +  $6.c + (":" + if_ou_elseif) + $8.c;}
  | IF_T'('C')'CMD ELSE           {string if_else = gera_label("if_else");
                                  $$.c = $3.c + "!" + if_else + "?" +  $5.c + (":" +  if_else);}
  | IF_T'('C')''{'CMDs'}'ELSE     {string if_else = gera_label("if_else");
                                  $$.c = $3.c + "!" + if_else + "?" +  $6.c + (":" + if_else);}
  | IF_T'('C')'CMD                {string if_end = gera_label("if_end");
                                  $$.c = $3.c + "!" + if_end + "?" +  $5.c + (":" + if_end);}
  | IF_T'('C')''{'CMDs'}'         {string if_end = gera_label("if_end");
                                  $$.c = $3.c + "!" + if_end + "?" +  $6.c + (":" + if_end);}
  ;

ELSEIF: ELSEIF_T'('C')' CMD ELSEIF  {string elseif = gera_label("elseif");
                                    $$.c = $3.c + "!" + elseif + "?" +  $5.c + (":" + elseif) + $6.c;}
  | ELSEIF_T'('C')''{'CMDs'}'ELSEIF {string elseif = gera_label("elseif");
                                    $$.c = $3.c + "!" + elseif + "?" +  $6.c + (":" + elseif) + $8.c;}
  | ELSEIF_T'('C')''{'CMDs'}'ELSE   {string elseif_else = gera_label("elseif_else");
                                    $$.c = $3.c + "!" + elseif_else + "?" + (":" + elseif_else) + $8.c +  $6.c;}
  | ELSEIF_T'('C')' CMD ELSE        {string elseif_else = gera_label("elseif_else");
                                    $$.c = $3.c + "!" + elseif_else + "?" + (":" + elseif_else) + $6.c +  $5.c;}                            
  ;

ELSE: ELSE_T'{' CMDs '}'  {$$.c = $3.c;}
  | ELSE_T CMD            {$$.c = $2.c;}   
  ;

WHILE: WHILE_T'('C')''{' CMDs '}' {string while_end = gera_label("while_end");
                                  string while_cond = gera_label("while_cond");
                                  $$.c = novo + (":" + while_cond) + $3.c + "!" + while_end + "?" + $6.c + while_cond + "#" + (":" + while_end);}
  ;

FOR: FOR_T'('CMD C ';' E')''{' CMDs '}' {string for_end = gera_label("for_end");
                                          string for_cond = gera_label("for_cond");
                                          $$.c = $3.c + (":" + for_cond) + $4.c + "!" + for_end + "?" + $9.c  + $6.c + "^" + for_cond  + "#" + (":" + for_end);}
  ;


E: E '+' E              { $$.c = $1.c + $3.c + "+"; }
  | E '-' E             { $$.c = $1.c + $3.c + "-"; }
  | E '*' E             { $$.c = $1.c + $3.c + "*"; }
  | E '/' E             { $$.c = $1.c + $3.c + "/"; }
  | '-'E                { vector<string> t1, t2;
                          t1.push_back("0");
                          t2.push_back("-");                          
                          $$.c = t1 + $2.c + t2; }
  | '('E')'             {$$.c = $2.c;}
  | NUM_T               { $$.c = $1.c; }
  | STRING_T            { $$.c = $1.c; }
  | DV_T LVALUE 	      {$$.c = $2.c + "&" + $2.c + "undefined" + "="; insere_var($2.c);} 
  | DV_T LVALUE '=' E 	{$$.c = $2.c + "&" + $2.c + $4.c + "=";  insere_var($2.c);}
  | LVALUE '=' E 	      {$$.c = $1.c + $3.c + "="; checa_var($1.c);}
  | LVALUEPROP '=' E 	  {$$.c = $1.c + $3.c + "[=]";}
  | LVALUE              { $$.c = $1.c + "@"; checa_var($1.c);}
  | LVALUEPROP          {$$.c = $1.c + "[@]";}
  | DEFO
  | DEFA
  | CF
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

void elimina_vars_locais(){
  escopo_local = false;
  vars_local.clear();
}


void insere_var(vector<string> var){
  if(escopo_local){
    if(vars_global.find(var) != vars_global.end()){
      cout << "Erro: a variável '"  << var.front() << "' local já foi declarada." << endl;
      exit(1);
    }else{
      vars_local.insert(var);
    }  
  }else{
    if(vars_global.find(var) != vars_global.end()){
      cout << "Erro: a variável '"  << var.front() << "' global já foi declarada na linha " << to_string(vars_global.find(var)->second) << "." << endl;
      exit(1);
    }else{
      vars_global.insert(pair<vector<string>,int>(var,cont_linha));
    }
  }
}

void checa_var(vector<string> var){
  if(escopo_local){
    if(vars_local.find(var) == vars_local.end() && vars_global.find(var) == vars_global.end()){
      cout << "Erro: a variável '"  << var.front() << "' não foi declarada em nenhum escopo." << endl;
      exit(1);
    }   
  }else{
    if(vars_global.find(var) == vars_global.end()){
      cout << "Erro: a variável '"  << var.front() << "' não foi declarada no escopo global." << endl;
      exit(1);
    }
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
}


void yyerror( const char* msg ) {
  cout << "Erro de sintaxe na linha " << to_string(cont_linha) << " próximo a:" << yytext << endl;
  exit( 1 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}