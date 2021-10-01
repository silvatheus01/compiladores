all: compilador entrada.txt
	(./compilador > saida.txt) < entrada.txt
	./interpretador < saida.txt

saida.txt:
	cat > saida.txt

lex.yy.c: scan.lex
	lex scan.lex

y.tab.c: compilador.y
	yacc compilador.y

compilador: lex.yy.c y.tab.c
	g++ -o compilador y.tab.c -ll

clean:
	rm y.tab.c lex.yy.c compilador saida.txt