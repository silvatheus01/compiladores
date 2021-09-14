WS	[ \t]
DIGITO	[0-9]
LETRA	[A-Za-z_]

INT     [1-9]+[0-9]*|0
NUM     {INT}("."{INT}*)?([Ee]("+"|"-")?{INT})?
ID      {LETRA}({LETRA}|{DIGITO})*

ASS  '
ASD  \"
AS      ({ASS}|{ASD})

STRING  {AS}([^"\""\n']|\\{ASD}|{ASD}{ASD})*{AS}

    /*Pula linha*/
PL      \\n

FOR     "for"
WHILE    "while"

IF        "if"
ELSE      "else"
IFELSE    IF[ ]ELSE

GT      <
GE      >
LT      <=
LE      >=
EQ      ==
NE      !=

    /*Operadores relacionais*/
OR      [GT|GE|LT|LE|EQ|NE]

    /*Define uma variável*/
DV      "let"

%%

{WS}  		{ }

{PL}        {cont_linha++;}


{OR}        {yylval.c = novo + yytext; 
            return OR_T;}

{DV}        {return DV_T;}

{FOR}       {return FOR_T;}
{WHILE}     {return WHILE_T;}

{IF}        {return IF_T;}
{ELSE}      {return ELSE_T;}
{IFELSE}    {return IFELSE_T;}

{NUM} 		{ yylval.c = novo + yytext;
            return NUM_T; }

{ID}		{ yylval.c = novo + yytext;
            return ID_T; }

{STRING}    {yylval.c = novo + yytext;
            return STRING_T;}

.		    { yylval.c = novo + yytext;
            return yytext[0]; }
