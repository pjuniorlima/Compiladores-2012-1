CC= gcc
CFLAGS= -g -Wall -ansi
LFLAGS= -lm

cezinho: main.o lexico.o
	$(CC) $(CFLAGS) $(LFLAGS) lexico.o main.o -o cezinho

main.o:	cezinho.tab.c
	$(CC) $(CFLAGS) -c cezinho.tab.c -o main.o

cezinho.lexico.c: cezinho.l
	flex --yylineno --outfile=cezinho.lexico.c cezinho.l

lexico.o: cezinho.lexico.c
	$(CC) $(CFLAGS) -c cezinho.lexico.c -o lexico.o

cezinho.tab.c: cezinho.y
	bison -d -t -v cezinho.y

clean:	
	rm -f cezinho.tab.[ch] cezinho.lexico.c *.o cezinho cezinho.output

cleanObj:
	rm -f *.o

tgz:
	rm -f *.o cezinho *.tgz
	tar cvfz cezinho.tgz *
	echo "Trabalho pronto para o envio!!"
