/* Coloque aqui definições regulares */
E   [$_]
L   [a-zA-Z]
AS  [" | "]
_INT    [1-9]+[0-9]*
_ID     [{L} | {E}]+[{L} | {E} | {_INT}]*
FLOAT   {_INT}("."{_INT})?([Ee]("+"|"-")?{_INT})?
_FOR    [Ff][Oo][Rr]
_IF     [Ii][Ff]
_COMENTARIO ["/*" | "//"][.\n]*("*/")?
_STRING     {AS}[[^\n{AS}] | {AS}\ | ""]

WS  [ \t\n]


%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}	{ /* ignora espaços, tabs e '\n' */ } 

.       { return *yytext; 
          /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */