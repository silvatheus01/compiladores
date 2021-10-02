WS	[ \t]
DIGITO	[0-9]
LETRA	[A-Za-z_]

INT     [1-9]+[0-9]*|0
NUM     {INT}("."{INT}*)?([Ee]("+"|"-")?{INT})?

ID      {LETRA}({LETRA}|{DIGITO})*

FUNCTION    "function"

RETURN      "return"

ASS  '
ASD  \"
AS      ({ASS}|{ASD})

STRING  ({ASD}([^"\""\n]|\\{ASD})*{ASD}|{ASS}([^"\""\n']|\\{ASD})*{ASS})

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

BOOL    ("true"|"false")

ARGS    "("{WS}*{ID}{WS}*(","{WS}*{ID}{WS}*)*")"{WS}*"=>"     

%%

{WS}  		{ }

{ARGS}      { 
            yylval.c = token(yytext);
            return ABRE_PAR_SETA_T; 
            } 

{OR}		{ yylval.c = novo + yytext;
            return OR_T; }

{PL}        {cont_linha++;}

{DV}        {return DV_T;}

{BOOL}      { yylval.c = novo + yytext;
            return BOOL_T;}

"=>"        {yylval.c = novo + yytext;
            return SETA_T;}

"asm{".*"}" { string lexema = trim( yytext + 3, "{}" ); 
            yylval.c = tokeniza( lexema );
            return ASM_T; }

{RETURN}    {return RETURN_T;}

{FUNCTION}  {return FUNCTION_T;}

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
