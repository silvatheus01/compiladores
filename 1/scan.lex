/* Coloque aqui definições regulares */
E   [$_]+
L   [a-zA-Z]+
ASS  '
ASD  \"
AS      ({ASS}|{ASD})
_INT    [1-9]+[0-9]*
_FLOAT   {_INT}("."{_INT})?([Ee]("+"|"-")?{_INT})?
_FOR    [Ff][Oo][Rr]
_IF     [Ii][Ff]
_COMENTARIO "/*"({L}|{E}|{_INT}|{_FLOAT}|\n)*"*/"
_STRING     {ASD}({E}|{L}|\\\"|\"\"|" ")*{ASD}
_ID     ({L}|{E})+({L}|{E}|{_INT}|{_FLOAT}|({AS}{_STRING}{AS})|{_COMENTARIO})*
WS  [ \t\n]

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */
    /*enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO };*/

{WS}    { /* ignora espaços, tabs e '\n' */ } 
{_FOR}  {return _FOR; }
{_IF}   {return _IF; }
{_INT}  {return _INT; }
{_FLOAT}    {return _FLOAT; }
">="    {return _MAIG; }
"<="    {return _MEIG; }
"=="    {return _IG; }
"!="    {return _DIF; }
{_STRING}   {return _STRING; }
{_COMENTARIO}   {return _COMENTARIO; }
{_ID}   {return _ID; }
.   { return *yytext; 
    /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */