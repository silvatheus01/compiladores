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

OL      [GT|GE|LT|LE|EQ|NE]

    /*Define uma variável*/
DV      let

%%

{WS}  		{ }

{PL}        {cont_linha++;}

{OL}        {return OL;}

{DV}        {return DV;}

{FOR}       {return "for";}
{WHILE}     {return "while";}

{IF}        {return "if";}
{ELSE}      {return "else";}
{IFELSE}    {return "if else";}

{NUM} 		{ return NUM; }
{ID}		{ yylval.nome = yytext; return ID; }
{STRING}   {return STRING;}


.		{ return yytext[0]; }
