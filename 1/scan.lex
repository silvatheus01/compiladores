/* Coloque aqui definições regulares */
E   [$_]+
L   [a-zA-Z]+
ASS  '
ASD  \"
AS      ({ASS}|{ASD})
_INT    [1-9]+[0-9]*|0
_FLOAT   {_INT}("."{_INT}*)?([Ee]("+"|"-")?{_INT})?
_FOR    [Ff][Oo][Rr]
_IF     [Ii][Ff]
COMENTARIO_S    "//"[^\n]*("*/")?
COMENTARIO_C    ("/*")[^"*"]*[^"/"]*("*/")
_COMENTARIO ({COMENTARIO_C}|{COMENTARIO_S})
_STRING     {AS}([^"\""\n']|\\{ASD}|{ASD}{ASD})*{AS}
_ID     ({L}|{E})({L}|{E}|{_FLOAT}|({AS}{_STRING}{AS})|{_COMENTARIO})*
WS  [ \t\n]

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

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