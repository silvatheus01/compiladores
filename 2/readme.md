## Analisador Recursivo Descendente

Este analisador servirá de base para a geração da Notação Polonesa Reversa (NPR).

Para compilar, use o makefile e utilize o comando

```console
user@pc:~/$ make all
```

Após isso o programa já estará rodando para testes. Uma possível entrada depois da compilação seria 

```console
user@pc:~/$ ./a.out
x = 1.3; a1 = 2/((x+1)*(x-1)); b1 = max( a1 * a1, x ); print a1; print x; print b1;
x 1.3 = a1 2 x @ 1 + x @ 1 - * / = b1 a1 @ a1 @ * x @ max # = a1 @ print # x @ print # b1 @ print # 
```
que gera a NPR na última linha do console, como é possível notar.