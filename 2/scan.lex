%{
#include <stdlib.h>
#include <stdio.h>
#include <string>		// Necessário para usar strings
#include <iostream>

using namespace std;
  
int token;
string lexema;
int cont;


void A();
void E();
void E_linha();
void T();
void T_linha();
void F();

void B();
void P();

void casa( int );

enum { tk_id = 256, tk_string, tk_num, tk_funcao };
%}

WS	[ \n\t]
DIGITO	[0-9]
LETRA	[A-Za-z_]

INT    [1-9]+[0-9]*|0
NUM   {INT}("."{INT}*)?([Ee]("+"|"-")?{INT})?
ID	{LETRA}({LETRA}|{DIGITO})*

ASS  '
ASD  \"
AS      ({ASS}|{ASD})

STRING     {AS}([^"\""\n']|\\{ASD}|{ASD}{ASD})*{AS}

FUNCAO      (dtos|max|print)

%%

{WS}  		{ }

{FUNCAO}    {return tk_funcao;}
{NUM} 		{ return tk_num; }
{ID}		{ return tk_id; }
{STRING}   {return tk_string;}


.		{ return yytext[0]; }

%%

int next_token() {
    return yylex();
}

void print_lexema(){
    cout << lexema + " ";
}


void B(){
    if(token == tk_funcao){
        casa(tk_funcao); E(); printf("print # "); casa(';'); B();
    } 
    else if(token == tk_id){
        A(); casa(';'); B();
    }
}

void P(){
    if(token == '+'){
        casa('+'); E(); P();
    }
        
}

void A() {
  casa(tk_id); print_lexema(); casa('='); E(); printf("= ");        
}

void E(){
    T(); E_linha();
}

void E_linha(){
    if(token == '+'){
        casa('+'); T(); printf("+ "); E_linha();
    }else if(token == '-'){
        casa('-'); T(); printf("- "); E_linha();
    }
}

void T() {
  F();T_linha();
}

void T_linha(){
    if(token == '*'){
        casa('*'); F(); printf("* "); T_linha();
    }else if(token == '/'){
        casa('/'); F(); printf("/ "); T_linha();
    }
}

void F(){
    if(token == tk_id){
        casa(tk_id);
        print_lexema();
    }else if(token == tk_num){
        casa(tk_num);
        print_lexema();
    }else if(token == '('){
        casa('('); E(); casa(')');
    }else if(token == tk_funcao){
        casa(tk_funcao);
        if(token == '('){
            casa('('); E();
            if(token == ','){
                casa(','); E(); casa(')'); printf("max # ");
            }else{
                casa(')'); printf("dtos # ");
            }               
        }           
    }else if(token == tk_string){
        casa(tk_string);
        print_lexema();
    }
}

void casa( int esperado ) {
  if( token == esperado ){
    lexema = yytext;
    token = next_token();
  }
    
   
  else {
    printf( "\nEsperado %d, encontrado: %d. Tokens lidos: %d\n", esperado, token, cont );
    exit( 1 );
  }
}

int main() {
  token = next_token();
  // Pega o lexema
  lexema = yytext;
  B();
  printf( "\nSintaxe ok!\n" );
  
  return 0;
}

