all: compilador entrada.txt
	./compilador < entrada.txt

lex.yy.c: scan.lex
	lex scan.lex

y.tab.c: compilador.y
	yacc compilador.y

compilador: lex.yy.c y.tab.c
	g++ -o compilador y.tab.c -ll

clean:
	rm y.tac.c lex.yy.c compilador