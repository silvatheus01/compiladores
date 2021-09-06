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

FOR     for
WHILE    while

IF        if
ELSE      else
IFELSE    IF[ ]ELSE

GT      <
GE      >
LT      <=
LE      >=
EQ      ==
NE      !=

    /*Operadores lógicos*/
OL      [GT|GE|LT|LE|EQ|NE]

    /*Define uma variável*/
DV      let

%%

{WS}  		{ }

{PL}        {cont_linha++;}

{OL}        {return OL;}

{DV}        {return DV;}

{FOR}       {return FOR_T;}
{WHILE}     {return WHILE_T;}

{IF}        {return IF_T;}
{ELSE}      {return ELSE_T;}
{IFELSE}    {return IFELSE_T;}

{NUM} 		{ return NUM; }
{ID}		{ return ID; }
{STRING}   {return STRING;}


.		{ return yytext[0]; }
