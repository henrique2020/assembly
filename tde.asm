.model small
.stack 100H

.data
    MICRO_TO_SEC            EQU 1000000 ; 1 segundo = 1.000.000 microsegundos (1000 * 1000)
    DELAY_FRAME             EQU 10000   ; 10.000us = 10ms
    FPS                     EQU 100

    DURACAO_FASE            EQU 5       ; Tempo que ira durar cada fase
    NUMERO_VIDAS            EQU 3
    NUMERO_DIGITOS_PONTOS   EQU 5
    NUMERO_DIGITOS_TEMPO    EQU 2

    LARGURA                 EQU 320     ; Largura da tela
    ALTURA                  EQU 200     ; Altura da tela
    LARGURA_CENARIO         EQU 480     ; Largura total do cenario

    MAX_INIMIGOS            EQU 5
    DELAY_SPAWN_INIMIGO     EQU 50
    VELOCIDADE              EQU 1       ; Quanto maior, mais rapido

    MAX_TIROS               EQU 5
    VELOCIDADE_TIRO         EQU 4
    VELOCIDADE_JET          EQU VELOCIDADE + 1

    CR                      EQU 13      ; define uma constante de valor 13
    LF                      EQU 10      ; define uma constante de valor 10

tempo_tela_fase dd MICRO_TO_SEC * 1
tabela_pontuacao_tempo dw 10, 15, 20
tabela_pontuacao_nave dw 100, 0, 150


seed dw 0
menu_selecao db 0   ; 0 = Jogar, 1 = Sair

temp_numero db ?

; Dentro da partida
fase db ?
pontuacao dw 0
tempo_restante dw DURACAO_FASE

vidas db NUMERO_VIDAS
vidas_vetor db NUMERO_VIDAS dup(1)          ; 1=Com vida, 0=Sem vida
vida_posicao_x db 132
               db 152
               db 172

inimigos_ativo      db MAX_INIMIGOS dup(0)  ; 0=Morto, 1=Vivo
inimigos_posicao    dw MAX_INIMIGOS dup(0)
timer_spawn_inimigo dw 0

tiros_ativo         db MAX_TIROS dup(0)     ; 0=Livre, 1=Em uso
tiros_posicao       dw MAX_TIROS dup(0)

cont_frames dw 0                            ; Frames percorridos dentro de 1s

; Movimento no menu
nave_posicao dw 0
meteoro_posicao dw 0
alien_posicao dw 0
alien_y dw 0
alien_x dw 0
alien_direction dw 1                        ; 1=ESQ, 2=DIR

altura_terrenos dw 49, 49, 81
terrenos_ptrs   dw  offset terreno_1, OFFSET terreno_1, OFFSET terreno_predios
linhas_ptrs     dw  48320, 48320, 38080

; limites da tela jogavel
limite_topo dw 10 * LARGURA
limite_fundo dw (ALTURA - 13) * LARGURA
limite_direita dw LARGURA - 29 
            

; SPRITES
arte_titulo db 3 dup(" ")," ___                    _    _     ", LF, CR
            db 3 dup(" "),"/ __| __ _ _ __ _ _ __ | |__| |___ ", LF, CR
            db 3 dup(" "),"\__ \/ _| '_/ _` | '  \| '_ \ / -_)", LF, CR
            db 3 dup(" "),"|___/\__|_| \__,_|_|_|_|_.__/_\___|", LF, CR
tamanho_arte equ $ - arte_titulo

arte_f1 db 10 dup(" ")," ___               _ ", LF, CR
        db 10 dup(" "),"| __|_ _ ___ ___  / |", LF, CR
        db 10 dup(" "),"| _/ _` (_-</ -_) | |", LF, CR
        db 10 dup(" "),"|_|\__,_/__/\___| |_|", LF, CR
tamanho_f1 equ $ - arte_f1

arte_f2 db 10 dup(" ")," ___               ___ ", LF, CR
        db 10 dup(" "),"| __|_ _ ___ ___  |_  )", LF, CR
        db 10 dup(" "),"| _/ _` (_-</ -_)  / / ", LF, CR
        db 10 dup(" "),"|_|\__,_/__/\___| /___|", LF, CR 
tamanho_f2 equ $ - arte_f2

arte_f3 db 10 dup(" ")," ___               ____ ", LF, CR
        db 10 dup(" "),"| __|_ _ ___ ___  |__ / ", LF, CR
        db 10 dup(" "),"| _/ _` (_-</ -_)  |_ \ ", LF, CR
        db 10 dup(" "),"|_|\__,_/__/\___| |___/ ", LF, CR
tamanho_f3 equ $ - arte_f3

arte_game_over db 10 dup(" "),"   ___                ",LF,CR
               db 10 dup(" "),"  / __|__ _ _ __  ___ ",LF,CR
               db 10 dup(" ")," | (_ / _` | '  \/ -_)",LF,CR
               db 10 dup(" "),"  \___\__,_|_|_|_\___|",LF,CR
               db 10 dup(" "),"  / _ \__ _____ _ _   ",LF,CR
               db 10 dup(" ")," | (_) \ V / -_) '_|  ",LF,CR
               db 10 dup(" "),"  \___/ \_/\___|_|    ",LF,CR  
tamanho_arte_game_over equ $-arte_game_over

arte_vencedor db 3 dup(" "),"__   __                  _         ",LF,CR
              db 3 dup(" "),"\ \ / /__ _ _  __ ___ __| |___ _ _ ",LF,CR
              db 3 dup(" ")," \ V / -_) ' \/ _/ -_) _` / _ \ '_|",LF,CR
              db 3 dup(" "),"  \_/\___|_||_\__\___\__,_\___/_|  ",LF,CR     
tamanho_arte_vencedor equ $-arte_vencedor

btn_jogar db 15 dup(" "),218,196,196,196,196,196,196,196,191,LF,CR
          db 15 dup(" "),179,           " JOGAR ",       179,LF,CR
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,LF,CR
tamanho_jogar equ $-btn_jogar                         

btn_sair  db 15 dup(" "),218,196,196,196,196,196,196,196,191,LF,CR
          db 15 dup(" "),179,           " SAIR  ",        179,LF,CR
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,LF,CR
tamanho_sair equ $-btn_sair

nave db 09H,09H,09H,09H,09H,09H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
     db 00H,09H,09H,09H,09H,09H,09H,09H,00H,00H,00H,00H,00H,00H,00H,0CH,0CH,0CH,0CH,00H,0EH,0EH,0EH,00H,00H,00H,00H,00H,00H
     db 00H,00H,08H,09H,09H,09H,09H,09H,09H,00H,00H,00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,00H,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H
     db 00H,00H,00H,09H,09H,09H,09H,09H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,00H,0EH,0EH,00H,08H,0EH,0EH,08H,00H,00H
     db 00H,00H,00H,00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,00H,0EH,0EH,00H,08H,0EH,0EH,0EH,06H,00H
     db 00H,00H,00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,08H,0EH,00H,0EH,0EH,0EH,08H,0EH,0EH
     db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,06H,00H,00H,00H,00H,00H,00H,00H,00H
     db 00H,00H,00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
     db 00H,00H,00H,00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,06H,00H
     db 00H,00H,00H,09H,09H,09H,09H,09H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,08H,00H,00H
     db 00H,08H,09H,09H,09H,09H,09H,09H,01H,00H,00H,00H,06H,06H,06H,0CH,0CH,0CH,0CH,06H,06H,06H,06H,06H,08H,00H,00H,00H,00H
     db 00H,09H,09H,09H,09H,09H,09H,09H,00H,00H,00H,00H,00H,00H,00H,06H,06H,06H,06H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
     db 09H,09H,09H,09H,09H,09H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
nave_tamanho equ $-nave

meteoro db 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,05H,05H,05H,05H,05H,08H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,05H,0DH,0DH,0DH,05H,05H,08H,00H,00H,05H,05H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,00H,00H,05H,05H,0CH,0DH,05H,05H,05H,0CH,0CH,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,05H,05H,05H,05H,0CH,0CH,05H,05H,05H,05H,0CH,0CH,0CH,00H,00H,00H,0DH,0DH,0CH,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,05H,05H,0CH,05H,0CH,0CH,05H,05H,05H,0CH,0CH,05H,05H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,05H,0CH,0CH,05H,0CH,0CH,0CH,05H,05H,0CH,05H,05H,0CH,05H,05H,05H,00H,00H,05H,05H,00H,00H,00H,00H
        db 00H,00H,00H,00H,05H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,05H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,05H,0CH,0CH,0CH,05H,05H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,05H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,05H,05H,0DH,0CH,05H,0CH,0CH,0CH,0CH,0CH,05H,05H,0CH,0CH,0CH,0CH,00H,00H,0CH,0CH,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,08H,05H,0DH,0DH,0CH,05H,0CH,0CH,0CH,0CH,05H,05H,05H,0CH,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,00H,05H,0DH,0DH,0CH,0CH,0CH,0CH,0CH,05H,05H,05H,00H,00H,0CH,0CH,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,00H,00H,08H,08H,05H,05H,05H,05H,0CH,08H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
        db 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,05H,05H,05H,05H,05H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
meteoro_tamanho equ $-meteoro

alien db 00h,00h,00h,00h,00h,00h,00h,02h,02h,02h,02h,02h,02h,02h,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,00h,00h,02h,02h,02h,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,02h,02h,02h,02h,02h,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00H
      db 00h,00h,00h,00h,02h,02h,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,00h,00h,00h,00H
      db 00h,00h,02h,02h,02h,02h,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00H
      db 00h,00h,02h,02h,02h,02h,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00H
      db 02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,0Ah,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh
      db 02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,0Ah,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,0EH
      db 00h,00h,00h,00h,05h,05h,05h,0Dh,02h,02h,0Ah,0Eh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,05h,05h,05h,0Dh,02h,02h,0Ah,0Eh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,05h,05h,05h,0Dh,02h,02h,0Ah,0Eh,0Eh,0Eh,05h,05h,05h,0Dh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,02h,02h,02h,0Ah,0Ah,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00H
      db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,02h,02h,02h,0Ah,0Ah,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00H
alien_tamanho equ $ - alien

status db "SCORE:", 22 + (NUMERO_DIGITOS_PONTOS+1) - (NUMERO_DIGITOS_TEMPO+1) dup(" "), "TEMPO:", LF, CR
tamanho_status equ $ - status

pontuacao_frase db "PONTUACAO:"
tamanho_pontuacao_frase equ $-pontuacao_frase

vida db 09H,09H,09H,09H,09H,00H,0CH,0CH,0CH,00H,0EH,0EH,0EH,00H,00H,00H
     db 00H,09H,09H,09H,0CH,0CH,0CH,0CH,0CH,00H,0EH,00H,00H,0EH,0EH,00H
     db 00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,00H,0EH,00H,0EH,0EH,00H,0EH
     db 0EH,0EH,0EH,0EH,0CH,0CH,0CH,0CH,0CH,0CH,00H,00H,00H,00H,00H,00H
     db 00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH
     db 00H,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,0CH,00H,00H
     db 09H,09H,09H,09H,09H,00H,0CH,0CH,0CH,0CH,0CH,0CH,00H,00H,00H,00H
vida_tamanho equ $-vida

scroll_cenario dw 0

terreno_1 db 452 dup(00H), 1 dup(0EH), 27 dup(00H)
          db 376 dup(00H), 1 dup(0EH), 66 dup(00H), 1 dup(0EH), 8 dup(00H), 1 dup(09H), 27 dup(00H)
          db 160 dup(00H), 4 dup(0EH), 91 dup(00H), 3 dup(0EH), 117 dup(00H), 1 dup(0EH), 1 dup(09H), 56 dup(00H), 3 dup(0EH), 5 dup(00H), 2 dup(0EH), 1 dup(09H), 1 dup(0EH), 6 dup(00H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 26 dup(00H)
          db 27 dup(00H), 2 dup(0EH), 130 dup(00H), 1 dup(0EH), 4 dup(09H), 3 dup(0EH), 87 dup(00H), 1 dup(0EH), 3 dup(09H), 2 dup(0EH), 24 dup(00H), 3 dup(0EH), 87 dup(00H), 1 dup(0EH), 2 dup(09H), 1 dup(0EH), 54 dup(00H), 1 dup(0EH), 3 dup(09H), 1 dup(0EH), 1 dup(00H), 3 dup(0EH), 4 dup(09H), 1 dup(0EH), 3 dup(00H), 2 dup(0EH), 3 dup(09H), 1 dup(0EH), 25 dup(00H)
          db 20 dup(00H), 7 dup(0EH), 2 dup(09H), 4 dup(0EH), 1 dup(00H), 1 dup(0EH), 123 dup(00H), 1 dup(0EH), 8 dup(09H), 4 dup(0EH), 1 dup(00H), 4 dup(0EH), 78 dup(00H), 6 dup(09H), 1 dup(0EH), 3 dup(00H), 2 dup(0EH), 1 dup(00H), 1 dup(0EH), 1 dup(00H), 6 dup(0EH), 1 dup(00H), 1 dup(0EH), 3 dup(00H), 4 dup(0EH), 3 dup(09H), 1 dup(00H), 1 dup(0EH), 78 dup(00H), 1 dup(0EH), 4 dup(00H), 1 dup(0EH), 1 dup(00H), 4 dup(09H), 1 dup(0EH), 44 dup(00H), 1 dup(0EH), 3 dup(00H), 2 dup(0EH), 1 dup(00H), 2 dup(0EH), 5 dup(09H), 1 dup(0EH), 8 dup(09H), 3 dup(0EH), 6 dup(09H), 25 dup(00H)
          db 10 dup(00H), 1 dup(0EH), 3 dup(00H), 6 dup(0EH), 13 dup(09H), 1 dup(0EH), 1 dup(09H), 6 dup(0EH), 110 dup(00H), 7 dup(0EH), 13 dup(09H), 1 dup(0EH), 4 dup(09H), 2 dup(0EH), 23 dup(00H), 1 dup(0EH), 50 dup(00H), 2 dup(0EH), 7 dup(09H), 3 dup(0EH), 2 dup(09H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 6 dup(09H), 1 dup(0EH), 1 dup(09H), 3 dup(0EH), 7 dup(09H), 1 dup(0EH), 1 dup(09H), 72 dup(00H), 2 dup(0EH), 1 dup(00H), 3 dup(0EH), 1 dup(09H), 4 dup(0EH), 1 dup(09H), 1 dup(0EH), 5 dup(09H), 39 dup(00H), 2 dup(0EH), 1 dup(00H), 2 dup(0EH), 1 dup(09H), 3 dup(0EH), 2 dup(09H), 1 dup(0EH), 25 dup(09H), 1 dup(0EH), 24 dup(00H)
          db 4 dup(00H), 6 dup(0EH), 1 dup(09H), 3 dup(0EH), 27 dup(09H), 2 dup(0EH), 2 dup(00H), 1 dup(0EH), 103 dup(00H), 2 dup(0EH), 27 dup(09H), 1 dup(0EH), 21 dup(00H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 38 dup(00H), 3 dup(0EH), 7 dup(00H), 1 dup(0EH), 37 dup(09H), 2 dup(0EH), 65 dup(00H), 5 dup(0EH), 2 dup(09H), 1 dup(0EH), 15 dup(09H), 1 dup(0EH), 12 dup(00H), 1 dup(0EH), 18 dup(00H), 1 dup(0EH), 1 dup(00H), 2 dup(0EH), 1 dup(00H), 2 dup(0EH), 2 dup(09H), 1 dup(0EH), 35 dup(09H), 1 dup(0EH), 23 dup(00H)
          db 3 dup(00H), 1 dup(0EH), 39 dup(09H), 2 dup(0EH), 1 dup(09H), 3 dup(0EH), 24 dup(00H), 1 dup(0EH), 72 dup(00H), 3 dup(0EH), 30 dup(09H), 6 dup(0EH), 14 dup(00H), 1 dup(0EH), 3 dup(09H), 36 dup(00H), 2 dup(0EH), 3 dup(09H), 1 dup(0EH), 1 dup(00H), 5 dup(0EH), 40 dup(09H), 5 dup(0EH), 1 dup(00H), 1 dup(0EH), 55 dup(00H), 3 dup(0EH), 24 dup(09H), 3 dup(0EH), 8 dup(00H), 1 dup(0EH), 1 dup(09H), 2 dup(0EH), 12 dup(00H), 1 dup(0EH), 1 dup(00H), 2 dup(0EH), 1 dup(09H), 1 dup(0EH), 2 dup(09H), 1 dup(0EH), 41 dup(09H), 1 dup(0EH), 22 dup(00H)
          db 3 dup(0EH), 46 dup(09H), 1 dup(0EH), 1 dup(00H), 2 dup(0EH), 1 dup(00H), 1 dup(0EH), 17 dup(00H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 65 dup(00H), 1 dup(0EH), 2 dup(00H), 3 dup(0EH), 39 dup(09H), 6 dup(0EH), 7 dup(00H), 1 dup(0EH), 4 dup(09H), 2 dup(0EH), 10 dup(00H), 3 dup(0EH), 20 dup(00H), 1 dup(0EH), 6 dup(09H), 1 dup(0EH), 50 dup(09H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 1 dup(00H), 1 dup(0EH), 1 dup(00H), 2 dup(0EH), 16 dup(00H), 4 dup(0EH), 21 dup(00H), 2 dup(0EH), 2 dup(00H), 4 dup(0EH), 30 dup(09H), 3 dup(0EH), 1 dup(00H), 4 dup(0EH), 4 dup(09H), 2 dup(0EH), 7 dup(00H), 3 dup(0EH), 1 dup(09H), 1 dup(0EH), 49 dup(09H), 1 dup(0EH), 2 dup(00H), 1 dup(0EH), 2 dup(00H), 1 dup(0EH), 15 dup(00H)
          db 50 dup(09H), 1 dup(0EH), 2 dup(09H), 1 dup(0EH), 1 dup(09H), 5 dup(0EH), 4 dup(00H), 1 dup(0EH), 6 dup(00H), 1 dup(0EH), 3 dup(09H), 1 dup(0EH), 12 dup(00H), 4 dup(0EH), 1 dup(00H), 6 dup(0EH), 1 dup(00H), 3 dup(0EH), 1 dup(00H), 32 dup(0EH), 1 dup(00H), 3 dup(0EH), 1 dup(09H), 2 dup(0EH), 48 dup(09H), 7 dup(0EH), 7 dup(09H), 1 dup(0EH), 1 dup(00H), 1 dup(0EH), 2 dup(00H), 5 dup(0EH), 3 dup(09H), 3 dup(0EH), 4 dup(00H), 1 dup(0EH), 2 dup(00H), 1 dup(0EH), 4 dup(00H), 5 dup(0EH), 61 dup(09H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 2 dup(09H), 6 dup(0EH), 6 dup(00H), 1 dup(0EH), 1 dup(00H), 2 dup(0EH), 4 dup(09H), 2 dup(0EH), 4 dup(00H), 2 dup(0EH), 7 dup(00H), 2 dup(0EH), 1 dup(00H), 3 dup(0EH), 2 dup(09H), 2 dup(0EH), 37 dup(09H), 1 dup(0EH), 10 dup(09H), 1 dup(00H), 1 dup(0EH), 1 dup(00H), 4 dup(0EH), 55 dup(09H), 2 dup(0EH), 1 dup(09H), 2 dup(0EH), 1 dup(09H), 2 dup(0EH), 1 dup(00H), 2 dup(0EH), 10 dup(00H)
          db 60 dup(09H), 4 dup(0EH), 1 dup(09H), 6 dup(0EH), 5 dup(09H), 12 dup(0EH), 4 dup(09H), 1 dup(0EH), 6 dup(09H), 1 dup(0EH), 3 dup(09H), 1 dup(0EH), 32 dup(09H), 1 dup(0EH), 69 dup(09H), 1 dup(0EH), 1 dup(09H), 2 dup(0EH), 11 dup(09H), 4 dup(0EH), 1 dup(09H), 2 dup(0EH), 1 dup(09H), 4 dup(0EH), 77 dup(09H), 6 dup(0EH), 1 dup(09H), 1 dup(0EH), 8 dup(09H), 4 dup(0EH), 2 dup(09H), 7 dup(0EH), 2 dup(09H), 1 dup(0EH), 55 dup(09H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 67 dup(09H), 1 dup(0EH), 2 dup(09H), 10 dup(0EH)
          db 60 dup(09H), 4 dup(0EH), 1 dup(09H), 6 dup(0EH), 5 dup(09H), 12 dup(0EH), 4 dup(09H), 1 dup(0EH), 6 dup(09H), 1 dup(0EH), 3 dup(09H), 1 dup(0EH), 32 dup(09H), 1 dup(0EH), 69 dup(09H), 1 dup(0EH), 1 dup(09H), 2 dup(0EH), 11 dup(09H), 4 dup(0EH), 1 dup(09H), 2 dup(0EH), 1 dup(09H), 4 dup(0EH), 77 dup(09H), 6 dup(0EH), 1 dup(09H), 1 dup(0EH), 8 dup(09H), 4 dup(0EH), 2 dup(09H), 7 dup(0EH), 2 dup(09H), 1 dup(0EH), 55 dup(09H), 1 dup(0EH), 1 dup(09H), 1 dup(0EH), 67 dup(09H), 1 dup(0EH), 2 dup(09H), 10 dup(0EH)
          db 38 dup (LARGURA_CENARIO dup(09H))

terreno_predios db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 96 dup(07H), 240 dup(00H), 144 dup(07H)
                db 96 dup(07H), 240 dup(00H), 144 dup(07H)
                db 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 240 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H)
                db 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 240 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H)
                db 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 240 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H)
                db 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 240 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H)
                db 96 dup(07H), 240 dup(00H), 144 dup(07H)
                db 96 dup(07H), 240 dup(00H), 144 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 240 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 72 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 72 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 72 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 72 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 168 dup(00H), 2 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 14 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H),4 dup(07H), 8 dup(04H), 2 dup(07H), 98 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H)
                db 98 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 98 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 108 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 74 dup(07H), 108 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 74 dup(07H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H)
                db 8 dup(04H), 4 dup(07H), 4 dup(04H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH)
                db 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 4 dup(04H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 74 dup(07H), 96 dup(00H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 74 dup(07H), 108 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 108 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 98 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH)
                db 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 98 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H)
                db 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 14 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 98 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 14 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 98 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 98 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 98 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 98 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 14 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 4 dup(07H), 8 dup(04H), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 4 dup(04H), 4 dup(00H), 4 dup(04H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 12 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H)
                db 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 2 dup(07H), 8 dup(0BH), 2 dup(07H)
                db 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H), 2 dup(00H), 8 dup(04H), 2 dup(00H), 12 dup(07H)
                db LARGURA_CENARIO dup(00H)

.code

; =================================================================
; Escreve uma string na tela utilizando a interrupcao 10h (AH=13h).
; Entrada: 
;   BP = Offset da string
;   CX = Tamanho da string
;   DH, DL = Posicao (Linha, Coluna)
;   BL = Atributo de cor
; Saida: Nenhum
; =================================================================
ESCREVE_STRING proc 
    push AX
    push BX
    push DS
    push ES
    push SI
    push BP
    push BX
    
    mov BX, DS
    mov ES, BX

    mov AH, 13h 
    mov AL, 01h 
    pop BX  
    xor BH, BH  
    int 10h     
    
    pop BP
    pop SI
    pop ES
    pop DS
    pop BX
    pop AX
    ret
endp

; =================================================================
; Converte um valor numerico de 16 bits em caracteres ASCII e o imprime na tela, preenchendo com zeros a esquerda.
; Entrada: 
;   AX = Valor numerico
;   CX = Largura do campo (numero de caracteres)
;   DH, DL = Posicao (Linha, Coluna)
;   BL = Cor
; Saida: Nenhum
; =================================================================
ESCREVE_NUMERO proc
    push AX
    push BX
    push CX
    push DX
    push SI
    push BP
    push DI

    mov DI, DX
    mov SI, CX      
    
    mov BX, 10      
    xor CX, CX

    DIVIDE_LOOP:
        xor DX, DX
        div BX              
        
        push DX             
        inc CX              
        
        cmp AX, 0
        jne DIVIDE_LOOP
    
    PREENCHE_ZEROS:
        cmp SI, CX          
        jle LOOP_IMPRIME    
        
        push CX
        
        mov [temp_numero], '0' 
        mov BP, offset temp_numero 
        mov CX, 1                  
        mov DX, DI                 
        call ESCREVE_STRING
        
        pop CX
        
        inc DL              
        mov DI, DX          
        dec SI              
        jmp PREENCHE_ZEROS
        
    LOOP_IMPRIME:
        pop AX              
        push CX             
        
        add AL, '0'         
        mov [temp_numero], AL
        
        mov BP, offset temp_numero
        mov CX, 1           
        mov DX, DI          
        call ESCREVE_STRING
        
        pop CX              
        
        inc DL              
        mov DI, DX          
        
        loop LOOP_IMPRIME   

    pop DI
    pop BP
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

; =================================================================
; Atualiza e desenha os valores de pontuacao e tempo no HUD.
; Entrada: Variaveis globais [pontuacao], [tempo_restante].
; Saida: Nenhum
; =================================================================
ESCREVE_VALORES_HUD proc
    mov AX, [pontuacao]
    mov DH, 0
    mov DL, 7
    mov BL, 0AH
    mov CX, NUMERO_DIGITOS_PONTOS
    call ESCREVE_NUMERO

    mov AX, [tempo_restante]
    mov DH, 0
    mov DL, 38
    mov BL, 0AH
    mov CX, NUMERO_DIGITOS_TEMPO
    call ESCREVE_NUMERO
    
    ret
endp

; =================================================================
; Preenche toda a memoria de video (320x200) com cor preta.
; Entrada: Nenhum
; Saida: Nenhum
; =================================================================
LIMPA_TELA proc
    push CX
    push AX
    push DI
    
    mov AX, 0A000h
    mov ES, AX
    
    xor DI, DI
    xor AX, AX
    CLD 
    
    mov CX, 32000  
    mov DI, 0

    rep stosw  
    
    pop DI
    pop AX
    pop CX
    ret
endp

; =================================================================
; Esvazia o buffer do teclado consumindo todas as teclas pendentes.
; Entrada: Nenhum
; Saida: Nenhum
; =================================================================
LIMPA_BUFFER_TECLADO proc
    push AX

    CHECK_BUFFER:
        mov AH, 01h
        int 16h
        jz BUFFER_VAZIO 

        mov AH, 00h
        int 16h     
        
        jmp CHECK_BUFFER 

    BUFFER_VAZIO:
        pop AX
        ret
endp

; =================================================================
; Le o estado do teclado a movimentacao da nave e disparo de tiros.
; Entrada: Variaveis [nave_posicao] e limites de tela.
; Saida: Atualiza [nave_posicao].
; =================================================================
VERIFICA_TECLADO_JOGO proc
    push AX
    push DI
    mov DI, [nave_posicao]
    
    mov AH, 01h
    int 16h
    jz FIM_TECLADO_JOGO
    
    xor AH, AH
    int 16h
    
    cmp AH, 48H
    je SETA_CIMA
    
    cmp AH, 50H
    je SETA_BAIXO
    
    cmp AH, 4BH
    je SETA_ESQUERDA
    
    cmp AH, 4DH
    je SETA_DIREITA
    
    cmp AH, 39h
    je ESPACO
    
    jmp FIM_TECLADO_JOGO
    
    SETA_CIMA:
        cmp DI, [limite_topo]
        jbe FIM_TECLADO_JOGO 

        mov AX, 0 ; 0 = Cima
        call MOVER_VERTICAL
        jmp FIM_TECLADO_JOGO
        
    SETA_BAIXO:
        cmp DI, [limite_fundo]
        jae FIM_TECLADO_JOGO 

        mov AX, 1 ; 1 = Baixo
        call MOVER_VERTICAL
        jmp FIM_TECLADO_JOGO

    SETA_ESQUERDA:
        mov AX, DI
        xor DX, DX
        mov BX, LARGURA
        div BX
        
        cmp DX, 0  
        jle FIM_TECLADO_JOGO 

        mov AX, 0 ; 0 = Esquerda
        call MOVER_HORIZONTAL
        jmp FIM_TECLADO_JOGO

    SETA_DIREITA:
        mov AX, DI
        xor DX, DX
        mov BX, LARGURA
        div BX
        
        cmp DX, [limite_direita] 
        jae FIM_TECLADO_JOGO 

        mov AX, 1 ; 1 = Direita
        call MOVER_HORIZONTAL
        jmp FIM_TECLADO_JOGO

    ESPACO:
        call SPAWN_TIRO
        jmp FIM_TECLADO_JOGO
        
    FIM_TECLADO_JOGO:
        mov [nave_posicao], DI
        call LIMPA_BUFFER_TECLADO
        pop AX
        pop DI
        ret
endp

; =================================================================
; Altera o offset da nave para movela verticalmente.
; Entrada: AX (0=Cima, 1=Baixo), DI (Posicao atual).
; Saida: DI (Nova posicao).
; =================================================================
MOVER_VERTICAL proc
    push BX
    mov BX, LARGURA * VELOCIDADE_JET
    
    cmp AX, 0
    je MOVER_CIMA
    MOVER_BAIXO:
        add DI, BX
        jmp SAIR_MOVIMENTO_VERTICAL
    
    MOVER_CIMA:
        sub DI, BX
        jmp SAIR_MOVIMENTO_VERTICAL
    
    SAIR_MOVIMENTO_VERTICAL:
        pop BX
        ret
endp

; =================================================================
; Altera o offset da nave para move-la horizontalmente.
; Entrada: AX (0=Esquerda, 1=Direita), DI (Posicao atual).
; Saida: DI (Nova posicao).
; =================================================================
MOVER_HORIZONTAL proc
    cmp AX, 0
    je MOVER_ESQUERDA
    
    MOVER_DIREITA:
        add DI, VELOCIDADE_JET
        jmp SAIR_MOVIMENTO_HORIZONTAL
    
    MOVER_ESQUERDA:
        sub DI, VELOCIDADE_JET
        jmp SAIR_MOVIMENTO_HORIZONTAL
    
    SAIR_MOVIMENTO_HORIZONTAL:
        ret
endp

; =================================================================
; Cria um novo inimigo em uma posicao vertical aleatoria.
; Entrada: Nenhum
; Saida: Atualiza vetores de inimigos.
; =================================================================
SPAWN_INIMIGO proc
    push AX
    push BX
    push CX
    push DX
    push SI
    
    xor SI, SI
    xor BX, BX

    PROCURA_VAGA_INIMIGO:
        cmp SI, MAX_INIMIGOS
        je FIM_SPAWN
        
        cmp inimigos_ativo[SI], 0
        je GERAR
        
        inc SI
        add BX, 2
        jmp PROCURA_VAGA_INIMIGO

    GERAR:
        push BX

        xor BX, BX
        mov BL, [fase]
        dec BL
        shl BX, 1
        mov CX, altura_terrenos[BX]

        pop BX

        mov AX, ALTURA -10 -13 ; ALTURA - HUD - SPRITE
        sub AX, CX
        mov AH, AL
        call RAND_8
        add AL, 10
        xor AH, AH

        push CX
        mov CX, LARGURA
        mul CX
        pop CX
        
        add AX, [limite_direita]
        
        mov inimigos_posicao[BX], AX
        mov inimigos_ativo[SI], 1

    FIM_SPAWN:
        pop SI
        pop DX
        pop CX
        pop BX
        pop AX
        ret
endp

; =================================================================
; Controla spawn, movimentacao e desenho dos inimigos.
; Entrada: Vetores [inimigos_ativo], [inimigos_posicao].
; Saida: Nenhum
; =================================================================
MOVE_INIMIGOS proc
    inc [timer_spawn_inimigo]
    cmp [timer_spawn_inimigo], DELAY_SPAWN_INIMIGO
    jl INICIA_LOOP_MOVIMENTO
    
    mov [timer_spawn_inimigo], 0
    call SPAWN_INIMIGO

    INICIA_LOOP_MOVIMENTO:
        xor SI, SI
        xor BX, BX

    LOOP_INIMIGOS:
        cmp SI, MAX_INIMIGOS
        je SAI_GERENCIA

        cmp inimigos_ativo[SI], 1
        jne PROXIMO_INIMIGO

        mov DI, inimigos_posicao[BX]
        call LIMPA_13x29
        
        mov AX, inimigos_posicao[BX]
        xor DX, DX
        push BX
        mov BX, LARGURA
        div BX
        pop BX
    
        cmp DX, VELOCIDADE
        jbe REMOVER_INIMIGO
        
        sub inimigos_posicao[BX], VELOCIDADE
        mov AX, inimigos_posicao[BX]
        
        push SI

        cmp [fase], 2
        je DESENHA_METEORO

        mov SI, offset alien
        jmp DESENHA_INIMIGO

        DESENHA_METEORO:
            mov SI, offset meteoro

        DESENHA_INIMIGO:
            call DESENHA
            pop SI
        
        jmp PROXIMO_INIMIGO

    REMOVER_INIMIGO:
        mov inimigos_ativo[SI], 0

    PROXIMO_INIMIGO:
        inc SI
        add BX, 2
        jmp LOOP_INIMIGOS

    SAI_GERENCIA:
        ret
endp

; =================================================================
; Cria um novo tiro na posicao atual da nave.
; Entrada: DI (Posicao da nave).
; Saida: Atualiza vetores de tiro.
; =================================================================
SPAWN_TIRO proc
    push AX
    push BX
    push SI

    xor SI, SI
    xor BX, BX

    PROCURA_VAGA_TIRO:
        cmp SI, MAX_TIROS
        je FIM_SPAWN_TIRO
        
        cmp tiros_ativo[SI], 0
        je ATIRAR
        
        inc SI
        add BX, 2
        jmp PROCURA_VAGA_TIRO

    ATIRAR:
        mov tiros_ativo[SI], 1
        
        mov AX, DI
        add AX, 29
        add AX, 1920    ; Aproximadamente metade da altura da JET
        
        mov tiros_posicao[BX], AX

    FIM_SPAWN_TIRO:
        pop SI
        pop BX
        pop AX
    ret
endp

; =================================================================
; Move todos os tiros ativos e verifica bordas.
; Entrada: Vetores [tiros_ativo], [tiros_posicao].
; Saida: Nenhum
; =================================================================
MOVE_TIROS proc
    xor SI, SI
    xor BX, BX

    LOOP_TIROS:
        cmp SI, MAX_TIROS
        je SAI_GERENCIA_TIROS

        cmp tiros_ativo[SI], 1
        jne PROXIMO_TIRO_LOOP

        mov DI, tiros_posicao[BX]
        mov byte ptr ES:[DI], 0

        add word ptr tiros_posicao[BX], VELOCIDADE_TIRO

        mov AX, tiros_posicao[BX]
        xor DX, DX
        push BX
        mov CX, LARGURA
        div CX
        pop BX
        
        cmp DX, VELOCIDADE_TIRO
        jb REMOVER_TIRO
        cmp DX, 315
        ja REMOVER_TIRO
        
        cmp tiros_ativo[SI], 0
        je PROXIMO_TIRO_LOOP

        mov DI, tiros_posicao[BX]
        mov byte ptr ES:[DI], 0FH
        
        jmp PROXIMO_TIRO_LOOP

    REMOVER_TIRO:
        mov tiros_ativo[SI], 0

    PROXIMO_TIRO_LOOP:
        inc SI
        add BX, 2
        jmp LOOP_TIROS

    SAI_GERENCIA_TIROS:
        ret
endp

; =================================================================
; Realiza um delay e limpa a tela para transicao de fase.
; Entrada: [tempo_tela_fase]
; Saida: Nenhum
; =================================================================
CARREGA_FASE proc
    mov CX, WORD PTR [tempo_tela_fase + 2]
    mov DX, WORD PTR [tempo_tela_fase]
    mov AH, 86h
    int 15h
    
    call LIMPA_TELA
    ret
endp

; =================================================================
; Controla o loop principal do gameplay.
; Entrada: Variaveis globais do jogo.
; Saida: Nenhum
; =================================================================
PARTIDA proc
    push AX   
    xor AX, AX 
    mov AX, LARGURA * 60 
    mov [nave_posicao], AX
    pop AX
 
    mov [tempo_restante], DURACAO_FASE
    mov [cont_frames], 0  

    mov CX, MAX_INIMIGOS
    xor SI, SI
    ZERA_INIMIGOS:
        mov inimigos_ativo[SI], 0
        inc SI
        loop ZERA_INIMIGOS

    mov CX, MAX_TIROS
    xor SI, SI
    ZERA_TIROS:
        mov tiros_ativo[SI], 0
        inc SI
        loop ZERA_TIROS

    xor BX, BX
    mov BL, [fase]
    cmp BX, 2
    jne NAO_TROCA_COR
    
    dec BL
    shl BX, 1
    cmp BX, 2
    jne NAO_TROCA_COR
  
    mov SI, terrenos_ptrs[BX]
    
    mov BH, 09H 
    mov BL, 06H 
    call TERRENO_TROCA_COR
    
    mov BH, 0EH 
    mov BL, 0CH 
    call TERRENO_TROCA_COR
    
    NAO_TROCA_COR:
        mov DH, 0
        mov DL, 0
        mov BL, 0FH
        mov BP, offset status
        mov CX, tamanho_status
        call ESCREVE_STRING

        call ESCREVE_VALORES_HUD 
        call MOSTRAR_VIDAS
        
        mov AX, [nave_posicao]
        mov SI, offset nave
        call DESENHA

    JOGANDO:
        call CHECA_VIDAS
        cmp fase,5
        je SAIR_DA_FASE
        
        inc [cont_frames]
        cmp [cont_frames], FPS
        jne ATUALIZA_MOVIMENTO
        
        mov [cont_frames], 0

        push AX
        push BX

        xor BX, BX
        mov BL, [fase]
        dec BL
        shl BX, 1

        mov AX, tabela_pontuacao_tempo[BX]
        add [pontuacao], AX
        
        pop AX
        pop BX

        dec [tempo_restante]
        cmp [tempo_restante], 0
        je SAIR_DA_FASE

        call ESCREVE_VALORES_HUD

    ATUALIZA_MOVIMENTO:
        call BUSCA_INTERACAO
        
        mov DI, [nave_posicao]
        call LIMPA_13x29
        
        call VERIFICA_TECLADO_JOGO
        
        mov AX, [nave_posicao]
        mov SI, offset nave
        call DESENHA

        call MOVE_INIMIGOS
        call MOVE_TIROS

        mov BL, [fase] 
        dec BL 

        xor BH,BH
        shl BX, 1
        mov SI, terrenos_ptrs[BX] 
        mov AX, altura_terrenos[BX] 
        mov DX, linhas_ptrs[BX] 
        call TERRENO_MOV

        jmp JOGANDO

    SAIR_DA_FASE:
        ret
endp

; =================================================================
; Gerencia a selecao de opcoes e transicao entre fases.
; Entrada: [menu_selecao]
; Saida: Nenhum
; =================================================================
JOGAR_SAIR proc
    mov [fase], 0
    mov [pontuacao], 0
    cmp menu_selecao, 1
    jne JOGAR_F1
    call TERMINA_JOGO
    
    JOGAR_F1:
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 0FH
        mov BP, offset arte_f1
        mov CX, tamanho_f1
        call ESCREVE_STRING
        
        call CARREGA_FASE

        inc fase
        call PARTIDA
        
        call CHECA_VIDAS
        cmp fase, 5
        je PERDEU
        
        
    JOGAR_F2:
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 0CH
        mov BP, offset arte_f2
        mov CX, tamanho_f2
        call ESCREVE_STRING
        
        call CARREGA_FASE

        inc fase
        call PARTIDA
        
        call CHECA_VIDAS
        cmp fase, 5
        je PERDEU
        
    JOGAR_F3:
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 04H
        mov BP, offset arte_f3
        mov CX, tamanho_f3
        call ESCREVE_STRING
        
        call CARREGA_FASE

        inc fase
        call PARTIDA
        
        call CHECA_VIDAS
        cmp fase, 5
        je PERDEU
        
    call LIMPA_TELA    
    call ESCREVE_VENCEDOR
    inc fase
    
    xor  AH, AH 
    int  16h 
    call LIMPA_TELA
    jmp SAIR_JOGO
        
    PERDEU:
         call LIMPA_TELA
         call ESCREVE_GAME_OVER
         xor  AH, AH 
         int  16h 
         call LIMPA_TELA   
           
    SAIR_JOGO:
        ret
endp

; =================================================================
; Encerra o programa retornando ao DOS.
; Entrada: Nenhum
; Saida: Nenhum
; =================================================================
TERMINA_JOGO proc 
    mov AH, 4Ch
    int 21h
    ret
endp

; =================================================================
; Desenha as opcoes do menu com destaque na selecionada.
; Entrada: [menu_selecao]
; Saida: Nenhum
; =================================================================
VERIFICA_OPCAO proc
    push BP
    push BX
    push CX
    push DX
    
    cmp menu_selecao, 0
    jne OPCAO_SAIR
    
    mov DH, 18 ; Opcao "Jogar" selecionada
    mov DL, 0
    mov BL, 0CH
    mov BP, offset btn_jogar
    mov CX, tamanho_jogar
    call ESCREVE_STRING
    
    mov DH, 21
    mov BL, 0FH
    mov BP, offset btn_sair
    mov CX, tamanho_sair
    call ESCREVE_STRING
    jmp VOLTAR_VERIFICA_OPCAO
    
    OPCAO_SAIR: ; Opcao "Sair" selecionada
        mov DH, 18
        mov DL, 0
        mov BL, 0FH
        mov BP, offset btn_jogar
        mov CX, tamanho_jogar
        call ESCREVE_STRING
        
        mov DH, 21
        mov BL, 0CH
        mov BP, offset btn_sair
        mov CX, tamanho_sair
        call ESCREVE_STRING
    
    VOLTAR_VERIFICA_OPCAO:
        pop DX
        pop CX
        pop BX
        pop BP
        ret
endp

; =================================================================
; Le o teclado no menu para navegar entre as opcoes.
; Entrada: Teclado.
; Saida: Atualiza [menu_selecao].
; =================================================================
INTERAGE_MENU proc
    push AX
    
    mov AH, 01H
    int 16H
    jz VOLTAR_MENU
    
    xor AH, AH
    int 16H
    
    cmp AH, 48H ; Seta Cima
    jne BOTAO_BAIXO
    xor menu_selecao, 1
    jmp VOLTAR_MENU
    
    BOTAO_BAIXO:
        cmp AH, 50H ; Seta Baixo
        jne BOTAO_ENTER
        xor menu_selecao, 1
        jmp VOLTAR_MENU
        
    BOTAO_ENTER:
        cmp AH, 1CH ; Enter
        jne VOLTAR_MENU
        call JOGAR_SAIR
        
    VOLTAR_MENU:
        pop AX
        ret
endp

; =================================================================
; Realiza um delay para controle de FPS.
; Entrada: Constante DELAY_FRAME.
; Saida: Nenhum
; =================================================================
BUSCA_INTERACAO proc 
    push CX
    push DX
    
    xor CX, CX
    mov DX, DELAY_FRAME 
    mov AH, 86h
    int 15h
    
    pop DX
    pop CX
    ret
endp

; =================================================================
; Loop principal do menu do jogo.
; Entrada: Nenhum
; Saida: Nenhum
; =================================================================
JOGO proc                      
    call ESCREVE_TITULO
    call ESCREVE_BOTOES  
    call RESET_ALIEN_MENU 
    call RESET_POSICOES_MENU  
     
    MENU:
        call BUSCA_INTERACAO
        call INTERAGE_MENU
        
        cmp fase, 4
        je RESET_JOGO
        cmp fase, 5
        je RESET_JOGO
        
        call MENU_ANIMATION
        
    CONTINUA_LOOP:
        call VERIFICA_OPCAO
        jmp MENU
 
    RESET_JOGO:
        call LIMPA_TELA
        call RECARREGA_VIDA
        call ESCREVE_TITULO
        call ESCREVE_BOTOES
        call RESET_ALIEN_MENU
        call RESET_POSICOES_MENU
        mov fase, 0

        mov SI, terrenos_ptrs[0]

        mov BH, 06H  
        mov BL, 09H 
        call TERRENO_TROCA_COR
    
        mov BH, 0CH 
        mov BL, 0EH
        call TERRENO_TROCA_COR
        
        jmp MENU 
        
    SAIR_JOGO_LOOP:
        ret
endp

; =================================================================
; Desenha o titulo ASCII do jogo na tela.
; Entrada: [arte_titulo]
; Saida: Nenhum
; =================================================================
ESCREVE_TITULO proc 
    mov AX,DS
    mov ES,AX
    
    mov BP, offset arte_titulo
    mov CX, tamanho_arte
    mov BL, 02H 
    xor DX,DX 
    
    call ESCREVE_STRING      
    
    ret
endp 

; =================================================================
; Desenha a arte de "Vencedor" no final do jogo.
; Entrada: [arte_vencedor], [pontuacao]
; Saida: Nenhum
; =================================================================
ESCREVE_VENCEDOR proc
    mov AX,DS
    mov ES,AX
    
    mov BP, offset arte_vencedor
    mov CX, tamanho_arte_vencedor
    mov BL, 0AH
    xor DX,DX
    mov DH,10 
    call ESCREVE_STRING
    
    mov BP, offset pontuacao_frase
    mov CX, tamanho_pontuacao_frase
    mov BL, 0FH
    xor DX,DX
    mov DH,15 
    mov DL,12
    call ESCREVE_STRING
     
    mov AX, [pontuacao]
    mov DH, 15
    mov DL, 22
    mov CX, NUMERO_DIGITOS_PONTOS
    call ESCREVE_NUMERO

    ret
endp

; =================================================================
; Desenha a arte de "Game Over" no final do jogo.
; Entrada: [arte_game_over]
; Saida: Nenhum
; =================================================================
ESCREVE_GAME_OVER proc
    mov AX,DS
    mov ES,AX
    
    mov BP, offset arte_game_over
    mov CX, tamanho_arte_game_over
    mov BL, 0AH
    xor DX,DX
    mov DH,7 
    call ESCREVE_STRING

  ret
endp

; =================================================================
; Desenha os botoes iniciais do menu.
; Entrada: [op_menu]
; Saida: Nenhum
; =================================================================
ESCREVE_BOTOES proc
    push AX
    
    mov BL, 0FH
    mov AH, menu_selecao
    cmp AH, 1     
    
    jne INICIA_BTN
    mov BL, 0CH

    INICIA_BTN:
        mov BP, offset btn_jogar 
        mov CX, tamanho_jogar
        
        xor DL, DL
        mov DH, 18
        call ESCREVE_STRING
        
        mov BL, 0FH
        mov AH, menu_selecao
        cmp AH, 0
        jne SAIR_BTN
        mov BL, 0CH
        
    SAIR_BTN:
       mov BP, offset btn_sair
       mov CX, tamanho_sair
       xor DL, DL
       mov DH, 21
       call ESCREVE_STRING
       
   pop AX
   ret
endp 


; =================================================================
; Inicializa a semente do gerador de numeros aleatorios usando o relogio do sistema.
; Entrada: Relogio do sistema (INT 1Ah).
; Saida: [seed]
; =================================================================
SEED_FROM_TICKS proc  
    push AX
    push CX
    push DX
    mov  AH, 00h
    int  1Ah              
    mov  seed, DX         
    pop  DX
    pop  CX
    pop  AX
    
    ret
endp

; =================================================================
; Gera um numero pseudoaleatorio de 16 bits.
; Entrada: [seed]
; Saida: AX (Numero aleatorio), [seed] atualizado
; =================================================================
RAND_16 proc
    mov AX, 39541
    mul seed
    add AX, 16259
    mov seed, AX
    
    ret
endp

; =================================================================
; Gera um numero pseudoaleatorio de 8 bits.
; Entrada: AH (Limite maximo)
; Saida: AL (Numero aleatorio entre 0 e AH)
; =================================================================
RAND_8 proc
   push BX
   push CX
   push DX
   push AX
   
   xor CX,CX
   mov CL,AH 
   
   call RAND_16
   
   xor DX,DX 
   mov BX,CX
   div BX
   
   pop AX 
   
   mov AL,DL 
   
   pop DX
   pop CX
   pop BX

    ret
endp

; =================================================================
; Redefine posicoes dos elementos animados do menu.
; Entrada: Nenhum
; Saida: [nave_posicao], [meteoro_posicao]
; =================================================================
RESET_POSICOES_MENU proc
    push AX   
    
    xor AX, AX ;zera antes 
    mov AX, LARGURA * 50 
    mov nave_posicao, AX 
     
    add AX, [limite_direita]
    add AX, LARGURA * 20  
    mov meteoro_posicao, AX  
    
    pop AX
    
    ret
endp

; =================================================================
; Redefine a posicao do alien na animacaoo do menu.
; Entrada: Nenhum
; Saida: [alien_posicao], [alien_x], [alien_y]
; =================================================================
RESET_ALIEN_MENU proc
    push AX
    push DX
    push BX
    
    xor AX, AX
    mov AH, 133 
    
    call RAND_8 
    cmp AL, 90 
    jae Y_OK 
    mov AL, 90
     
    Y_OK:
        xor DX, DX
        mov DL, AL
        mov alien_y, DX 
        
        mov AH, 255 
        call RAND_8
        
        cmp AL,50 
        jae X_OK
        mov AL, 50
    X_OK:
        xor DX, DX
        mov DL, AL
        mov alien_x, DX 
        
        mov BX, LARGURA 
        
        mov AX, alien_y 
        mul BX 
        
        add AX, alien_x
        mov alien_posicao, AX
        mov alien_direction, 1

        pop BX
        pop DX
        pop AX
    
   ret
endp 

; =================================================================
; Apaga um sprite de 13x29 pixels na tela.
; Entrada: DI (posicao inicial na memoria de video).
; Saida: Nenhum
; =================================================================
LIMPA_13x29 proc;            
    push AX
    push CX
    push DI
    push ES
    
    mov AX, 0A000H
    mov ES, AX
    mov CX, 13

    LIMPA_LINHA:
        push CX
        mov CX, 29
        xor AX, AX
        rep stosb
        add DI, [limite_direita]
        pop CX
        loop LIMPA_LINHA

    pop ES
    pop DI
    pop CX
    pop AX
    ret

  ret
endp

; =================================================================
; Desenha um sprite generico de 13x29 pixels.
; Entrada: 
;   AX = posicao na tela
;   SI = Offset do sprite
; Saida: Nenhum
; =================================================================
DESENHA proc
     push BX
     push CX
     push DX
     push DI
     push ES
     push DS
     push AX 
      
     mov AX, @data
     mov DS, AX
     
     mov AX, 0A000H
     mov ES, AX
     
     
     pop AX 
     mov DI, AX
     MOV DX, 13 
     
     push AX
     
    LINHA_LOOP:
         mov CX, 29 
         rep movsb 
         add DI, [limite_direita]
         
         dec DX 
         jnz LINHA_LOOP 
         
    pop AX
    pop DS
    pop ES
    pop DI
    pop DX
    pop CX
    pop BX
     
    ret
endp

; =================================================================
; Desenha o sprite de vida (7x16 pixels).
; Entrada: 
;   AX = posicao na tela
;   SI = Offset do sprite
; Saida: Nenhum
; =================================================================
DESENHA_7x16 proc
     push BX
     push CX
     push DX
     push DI
     push ES
     push DS
     push AX 
      
     mov AX, @data
     mov DS, AX
     
     mov AX, 0A000H
     mov ES, AX
     
     pop AX 
     mov DI, AX
     MOV DX, 7 
     
     push AX
     
    LINHA_LOOP2:
        mov CX, 16 
        rep movsb 
        add DI, LARGURA-16  
        
        dec DX 
        jnz LINHA_LOOP2 
         
    pop AX
    pop DS
    pop ES
    pop DI
    pop DX
    pop CX
    pop BX
     
    ret
endp

; =================================================================
; Faz a checagem da quantidade de vidas atual, caso o numero de vidas seja 0 muda o valor de [fase] para 5, indicando game over.
; Entrada:  Nenhum.
; Saida: [fase] atualizado.
; =================================================================
CHECA_VIDAS proc
    cmp vidas, 0
    jne VIDAS_OK
    
    mov fase, 5

    VIDAS_OK:
        ret
endp

; =================================================================
; Decrementa o contador de vidas e atualiza visualmente.
; Entrada: [vidas]
; Saida: [vidas] atualizado, [vidas_vetor] atualizado
; =================================================================
DIMINUIR_VIDA proc
    push AX
    push BX
    push CX
    push DX
    push DI
    push ES
    
    mov AX, 0A000H
    mov ES, AX
    
    xor BX,BX
    xor AX,AX
    
    mov AL, vidas
    cmp AL, 0
    jz DIMINUIR_FIM 
    
    dec AL 
    mov vidas, AL 
    
    mov BL ,AL 
    mov vidas_vetor[BX], 0
    
    mov AL, vida_posicao_x[BX] 
    mov DI, AX
    mov DX, 7 

    DIMINUIR_VIDA_LOOP:
        mov CX, 16
        mov AL, 0
        rep stosb 
        
        add DI, LARGURA -16
        dec DX
        jnz DIMINUIR_VIDA_LOOP
 
    DIMINUIR_FIM:
        pop ES
        pop DI
        pop DX
        pop CX
        pop BX
        pop AX
    
    ret
endp

; =================================================================
; Percorre o vetor de vidas retornando o seus respectivos valores para 1.
; Entrada: Nenhum.
; Saida: [vidas] atualizado, [vidas_vetor] atualizado
; =================================================================
RECARREGA_VIDA proc
    push AX
    push BX
    push CX
    
    xor BX, BX
    xor AX, AX
    
    mov CX, 3
    mov AL, 0
    LOOP_RECARGA:
        cmp AL, 3
        je TERMINOU_RECARGA
        mov BL, AL 
        mov vidas_vetor[BX], 1
        inc AL 
        loop LOOP_RECARGA
        
    TERMINOU_RECARGA:
        mov vidas, 3
   
    pop CX
    pop BX
    pop AX
    
    ret
endp

; =================================================================
; Desenha as vidas iniciais no HUD.
; Entrada: [vidas_vetor], [vida_posicao_x]
; Saida: Nenhum
; =================================================================
MOSTRAR_VIDAS proc
    push AX
    push BX
    push CX
    push DX
    push SI

    xor BX, BX
    xor AX, AX
    mov CX, NUMERO_VIDAS

    DESENHAR_VIDA:
        lea SI, vida  
        mov AL, [vidas_vetor+BX]
        cmp AX, 0

        je PROXIMA_VIDA

        mov AL, [vida_posicao_x+BX]
        call DESENHA_7x16

    PROXIMA_VIDA:
        inc  BX
        loop DESENHAR_VIDA

    pop  SI
    pop  DX
    pop  CX
    pop  BX
    pop  AX
    ret
endp

; =================================================================
; Controla a animacaoo automatica dos elementos no menu principal.
; Entrada: posicoes das naves e meteoros.
; Saida: Atualiza posicoes e redesenha elementos.
; =================================================================
MENU_ANIMATION proc
    MOVE_NAVE:
        mov AX, nave_posicao
        mov DI, AX
        call LIMPA_13x29
        
        mov BX, LARGURA * 50
        add BX, [limite_direita]
        cmp AX, BX
        je MOVE_METEORO
        
        inc nave_posicao 
        inc AX
        mov SI, offset nave 
        call DESENHA
    
    MOVE_METEORO:
        mov AX, meteoro_posicao
        mov DI, AX
        call LIMPA_13x29
        
        cmp AX, LARGURA * 70
        je RESET_NAVE_METEORO

        dec meteoro_posicao
        dec AX
        mov SI, offset meteoro
        call DESENHA

     MOVE_ALIEN:
        mov DX, alien_direction
        cmp DX, 1   
        jne ALIEN_DIREITA
     
        mov AX, alien_posicao
        mov DI, AX
        
        mov DX, alien_x 
        call LIMPA_13x29
        
        cmp DX, 0 
        je RESET_ALIEN_DIRECTION
        
        dec alien_posicao
        dec AX
        dec alien_x
        
        mov SI, offset alien
        call DESENHA
        
        jmp END_POS_UPDATE
        
    ALIEN_DIREITA:
        mov AX, alien_posicao
        mov DI, AX
        mov DX, alien_x  
        cmp DX, [limite_direita]
        je RESET_ALIEN
        
        call LIMPA_13x29
              
        inc alien_posicao
        inc AX
        inc alien_x
        
        mov SI, offset alien
        call DESENHA
        jmp END_POS_UPDATE
    
    RESET_ALIEN_DIRECTION:
        mov alien_direction, 2
        jmp END_POS_UPDATE
        
    RESET_ALIEN:
        mov alien_direction, 1
        jmp END_POS_UPDATE
        
    RESET_NAVE_METEORO:
        call RESET_POSICOES_MENU 
    
    END_POS_UPDATE:
        ret
endp

; =================================================================
; Desenha o terreno rolando horizontalmente (Scrolling).
; Entrada: 
;   SI = Offset do terreno no buffer
;   AX = Altura do terreno
;   DX = Linha inicial do desenho
; Saida: Nenhum
; =================================================================
TERRENO_DESENHA proc
    push CX
    push DX
    push SI
    push DI
    push AX
    
    mov AX, 0A000H
    mov ES, AX
    
    pop AX
    
    add SI, scroll_cenario

    PRINTA_CENARIO:
        mov DI, DX
        mov DX, AX
    DESENHA_LINHA_TERRENO:
        mov CX, LARGURA
        rep movsb

        add SI, LARGURA_CENARIO - LARGURA
        dec DX
        jnz DESENHA_LINHA_TERRENO

    END_PROC:
        pop DI
        pop SI
        pop DX
        pop CX
        pop AX
        ret
endp

; =================================================================
; Atualiza o deslocamento do terreno (scroll).
; Entrada: [scroll_cenario], VELOCIDADE.
; Saida: [scroll_cenario] atualizado.
; =================================================================
TERRENO_MOV proc   
    add scroll_cenario, VELOCIDADE
    cmp scroll_cenario, LARGURA_CENARIO
    jl CONTINUA_MOVIMENTO

    mov scroll_cenario, 0 

    CONTINUA_MOVIMENTO:
        call TERRENO_DESENHA
 
    ret
ENDP

; =================================================================
; Substitui uma cor especifica por outra no buffer do terreno.
; Entrada: 
;   DS:SI = Buffer do terreno
;   BH = Cor alvo
;   BL = Cor nova
; Saida: Buffer alterado.
; =================================================================
TERRENO_TROCA_COR PROC
    push AX
    push BX
    push CX
    push SI

    mov CX, LARGURA_CENARIO*50

    cld

    TERRENO_TROCA_LOOP:
        lodsb
        cmp AL, BH
        jne PULA_ESCRITA_COR
        mov [SI-1], BL

    PULA_ESCRITA_COR:
        loop TERRENO_TROCA_LOOP

    pop SI
    pop CX 
    pop BX
    pop AX
    ret
endp

MAIN:
    mov AX, @data
    mov DS, AX
    
    mov AX, 0A000H
    mov ES, AX
    
    call SEED_FROM_TICKS
    
    xor AH, AH
    mov AL, 13H
    int 10H
    
    call JOGO
end MAIN
