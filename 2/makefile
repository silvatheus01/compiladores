all: lex
	./a.out

lex:
	lex scan.lex
	g++ -Wall -std=c++17 lex.yy.c -ll
	
clean:
	rm saida lex.yy.c
	