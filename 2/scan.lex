%{
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <iostream>

using namespace std;

int token;
string lexema;

void A();
void E();
void E_linha();
void T();
void T_linha();
void F();

void B();
void P();

void casa( int );

enum { tk_id = 256, tk_string, tk_num, tk_print };
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

PRINT      (print)

%%

{WS}  		{ }

{PRINT}    {return tk_print;}
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
    if(token == tk_print){
        casa(tk_print); E(); printf("print # "); casa(';'); B();
    } 
    else if(token == tk_id){
        A(); casa(';'); B();
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
        if(token != '('){
            print_lexema();
            printf("@ ");
        }else{
            string temp = lexema;
            casa('('); E();P(); casa(')'); 
            cout << temp + " " + "#" + " ";
        }
    }else if(token == tk_num){
        casa(tk_num);
        print_lexema();
    }else if(token == '('){
        casa('('); E(); casa(')');          
    }else if(token == tk_string){
        casa(tk_string);
        print_lexema();
    }
}

void P(){
    if(token == ','){
        casa(','); E(); P();
    }
}

void casa( int esperado ) {
  if( token == esperado ){
    lexema = yytext;
    token = next_token();
  }
}

int main() {
  token = next_token();
  // Pega o lexema atual
  lexema = yytext;
  // A ideia é que um programa sempre parte de um bloco de código.
  B();  
  return 0;
}