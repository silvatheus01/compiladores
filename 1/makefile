all: lex
	./a.out

lex: lex.yy.c main.cc 
	lex scan.lex
	g++ -Wall -std=c++17 main.cc -lfl  
	
clean:
	rm saida lex.yy.c
	