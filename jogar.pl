:- dynamic valor/3.
:- [ambiente], [mina].

/*Predicado criado para escrever no arquivo que o jogo foi perdido por ter atingido uma mina.*/
perder :- write('Jogo Encerrado'),nl, open('saida.pl', append,Stream),
          nl(Stream), write(Stream, 'Jogo Encerrado'), nl(Stream), close(Stream).

/*Predicado criado para escrever no arquivo que o jogo foi vencido quando não houver mais valores.*/
ganhar :- not(valor(_,_,_)), write('Parabéns!Você venceu!'),nl , open('saida.pl', append,Stream),
          nl(Stream), write(Stream, 'Parabéns!Você venceu!'), nl(Stream), close(Stream), salvarArquivo, [ambiente]. 
ganhar.

/*Predicado criado para avisar ao jogador que a posição já foi aberta previamente.*/
posicaoJaAberta :- write('Posição já aberta!'),nl, open('saida.pl', append,Stream),
          nl(Stream), write(Stream, 'Posição já aberta!'), nl(Stream), close(Stream).

/*Predicado criado para escrever no arquivo uma jogada em uma posicao (x,y).*/
salvarJogada(X, Y) :- open('saida.pl', append,Stream), nl(Stream), write(Stream, '/*JOGADA*/'), nl(Stream),
                      write(Stream, 'posicao('), write(Stream, X), write(Stream, ','),
                      write(Stream, Y), write(Stream,').'), nl(Stream),
                      write(Stream, '/*AMBIENTE*/'), close(Stream).

/*Predicado criado para escrever no arquivo uma posição (x,y) que foi aberta pela expansão.*/
salvarPosicao(X, Y, Z) :- concat('valor(', X, VALORX), concat(VALORX, ', ', VALOR),
                                     concat(VALOR, Y, VALORY), concat(VALORY, ', ', VALORVIRGULA),
                                     concat(VALORVIRGULA, Z, VALORZ), concat(VALORZ, ').', VALORFINAL),
                                     write(VALORFINAL), nl, open('saida.pl', append,Stream),
                                     nl(Stream), write(Stream, VALORFINAL), nl(Stream), close(Stream).

/*Predicado criado para salvar arquivo de saída ao término do jogo.*/
salvarArquivo :- get_time(TIME), stamp_date_time(TIME, DATE, 'local'),
                 format_time(atom(ATOM), '%d-%b-%T',DATE, posix), concat('saida.pl-', ATOM, NAME),
                 rename_file('saida.pl', NAME), open('saida.pl', write ,Stream), close(Stream).

/*Predicado criado para percorrer todos os 8 vizinhos da posição (x,y).*/
expandirAdjacencias(X, Y) :- adj1(X, Y), adj2(X, Y), adj3(X, Y), adj4(X, Y), 
			     adj5(X, Y), adj6(X, Y), adj7(X, Y), adj8(X, Y).

/*Predicado criado para checar os adjacentes de uma posição. Caso o valor dessa posição seja zero, ou seja, não possua
nenhuma mina ao redor, iremos expandir todos os seus adjacentes também. Caso contrário, iremos apenas escrever tal posição aberta 
no arquivo. Ao final dos dois casos excluimos o valor da posição (usando retract) das regras do jogo, para sinalizar que a mesma já foi aberta.*/
checarAjacentes(X, Y) :- valor(X, Y, 0), salvarPosicao(X, Y, 0), retract(valor(X,Y,0)), 
			 expandirAdjacencias(X, Y).
checarAjacentes(X, Y) :- valor(X, Y, Z), salvarPosicao(X, Y, Z), retract(valor(X,Y,Z)).

/*Predicado criado para iniciar a expansão de uma posição. Caso tal posição não seja uma mina e seja válida nas dimensões do tabuleiro, 
a escrevemos no arquivo e checamos todos os seus adjacentes. Caso contrário, verificamos se a mesma é uma posição que contém mina, se sim,
a escrevemos no arquivo, sinalizamos que o jogador perdeu o jogo e salvamos o arquivo. Caso o predicado mina dê false no segundo caso é porque
a posição extrapola os limites do tabuleiro e apenas a ignoramos.*/
posicao(X, Y) :- valor(X, Y, _), salvarJogada(X, Y), checarAjacentes(X, Y), ganhar.
posicao(X, Y) :- mina(X, Y), salvarJogada(X, Y), perder, salvarArquivo.
posicao(_,_) :- posicaoJaAberta.

/*Os predicados adj* são divididos em 3 casos. O primeiro é o caso em que o valor da quantidade de minas adjacentes da posição é zero e checamos todos os
seus adjacentes. O segundo caso é quando o valor das minas adjacentes não é zero e apenas a escrevemos no arquivo. Já o terceiro é o caso geral, que será 
chamado apenas quando o valor da posição der false, ou seja, a posição extrapola os limites do tabuleiro.*/

adj1(X,Y):- A is X+1,B is Y, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj1(X,Y) :- A is X+1,B is Y, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj1(_,_).
adj2(X,Y):- A is X+1,B is Y+1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj2(X,Y) :- A is X+1,B is Y+1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj2(_,_).
adj3(X,Y):- A is X,B is Y+1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj3(X,Y) :- A is X,B is Y+1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj3(_,_).
adj4(X,Y):- A is X-1,B is Y+1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj4(X,Y) :- A is X-1,B is Y+1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj4(_,_).
adj5(X,Y):- A is X-1,B is Y, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj5(X,Y) :- A is X-1,B is Y, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj5(_,_).
adj6(X,Y):- A is X-1,B is Y-1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj6(X,Y) :- A is X-1,B is Y-1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj6(_,_).
adj7(X,Y):- A is X,B is Y-1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj7(X,Y) :- A is X,B is Y-1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj7(_,_).
adj8(X,Y):- A is X+1,B is Y-1, valor(A, B, Z), 
	    Z = 0, checarAjacentes(A, B).
adj8(X,Y) :- A is X+1,B is Y-1, valor(A, B, Z), salvarPosicao(A, B, Z),retract(valor(A,B,Z)).
adj8(_,_).
