WS	[ \t]
DIGITO	[0-9]
LETRA	[A-Za-z_]

INT     [1-9]+[0-9]*|0
NUM     {INT}("."{INT}*)?([Ee]("+"|"-")?{INT})?
ID      {LETRA}({LETRA}|{DIGITO})*

ASS  '
ASD  \"
AS      ({ASS}|{ASD})

STRING  ({ASD}([^"\""\n]|\\{ASD}|{ASD}{ASD}|{ASS}{ASS})*{ASD}|{ASS}([^"\""\n]|\\{ASD}|{ASD}{ASD}|{ASS}{ASS})*{ASS})

    /*Pula linha*/
PL      "\n"

FOR     "for"
WHILE    "while"

IF        "if"
ELSE      "else"
ELSEIF    "else if"

LT      "<="
LE      ">="
EQ      "=="
NE      "!="

    /*Operadores relacionais*/
OR      ({LT}|{LE}|{EQ}|{NE})

    /*Define uma variável*/
DV      "let"

%%

{WS}  		{ }

{OR}		{ yylval.c = novo + yytext;
            return OR_T; }

{PL}        {cont_linha++;}

{DV}        {return DV_T;}

{FOR}       {return FOR_T;}
{WHILE}     {return WHILE_T;}

{IF}        {return IF_T;}
{ELSE}      {return ELSE_T;}
{ELSEIF}    {return ELSEIF_T;}

{NUM} 		{ yylval.c = novo + yytext;
            return NUM_T; }

{ID}		{ yylval.c = novo + yytext;
            return ID_T; }

{STRING}    {yylval.c = novo + yytext;
            return STRING_T;}

.		    { yylval.c = novo + yytext;
            return yytext[0]; }
