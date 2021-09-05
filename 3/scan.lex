WS	[ \n\t]
DIGITO	[0-9]
LETRA	[A-Za-z_]

INT     [1-9]+[0-9]*|0
NUM     {INT}("."{INT}*)?([Ee]("+"|"-")?{INT})?
ID      {LETRA}({LETRA}|{DIGITO})*

ASS  '
ASD  \"
AS      ({ASS}|{ASD})

STRING  {AS}([^"\""\n']|\\{ASD}|{ASD}{ASD})*{AS}

GT      <
GE      >
LT      <=
LE      >=
EQ      ==
NE      !=

OL      [GT|GE|LT|LE|EQ|NE]

DV      let

%%

{WS}  		{ }

{NUM} 		{ return tk_num; }
{ID}		{ return tk_id; }
{STRING}   {return tk_string;}


.		{ return yytext[0]; }