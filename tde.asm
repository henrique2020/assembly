.model small


.stack 100H


.data
    MICRO_TO_SEC EQU 1000000    ; 1 segundo = 1.000.000 microsegundos (1000 * 1000)
    DURACAO_FASE EQU 60         ; Tempo que ira durar cada fase
    NUMERO_VIDAS EQU 3
    N_DIGITIOS_TEMPO EQU 2
    N_DIGITOS_PONTOS EQU 5
    CR EQU 13                   ; define uma constante de valor 13
    LF EQU 10                   ; define uma constante de valor 10
    
    ALTURA EQU 200
    LARGURA EQU 320

op_menu db 1

seed dw 0 
      
fase db 1 ;indicia fase atual 
      
menu_selecao db 0   ; 0 = Jogar, 1 = Sair
inicia_jogo  db 0   ; Flag para iniciar o jogo
delay dw 1000        ; tempo em microsegundos (/10 para frames por segundo)
tempo_tela_fase dd MICRO_TO_SEC * 1

temp_numero db ?

vidas dw NUMERO_VIDAS

caracteres_pontuacao dw N_DIGITOS_PONTOS
pontuacao dw 0

caracteres_tempo dw N_DIGITIOS_TEMPO
tempo_fase dw DURACAO_FASE
tempo_restante dw DURACAO_FASE

largura_video dw LARGURA
altura_video dw ALTURA

nave_posicao dw 0
nave_inimiga_posicao dw 0
meteoro_posicao dw 0

alien_posicao dw 0
alien_y dw 0
alien_x dw 0
alien_direction dw 1 ;1 = esquerda, 2 = direita


limite_topo dw 10 * LARGURA
limite_fundo dw (ALTURA - 13) * LARGURA
limite_direita dw LARGURA - 29 
      
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
            
;  _____  _____  __  __  _____    _____  __ __  _____  _____ 
; /   __\/  _  \/  \/  \/   __\  /  _  \/  |  \/   __\/  _  \
; |  |_ ||  _  ||  \/  ||   __|  |  |  |\  |  /|   __||  _  <
; \_____/\__|__/\__ \__/\_____/  \_____/ \___/ \_____/\__|\_/
;  __ __  _____  _____  _____  _____  _____  _____  _____    
; /  |  \/   __\/  _  \/     \/   __\|  _  \/  _  \/  _  \   
; \  |  /|   __||  |  ||  |--||   __||  |  ||  |  ||  _  <   
;  \___/ \_____/\__|__/\_____/\_____/|_____/\_____/\__|\_/   



btn_jogar db 15 dup(" "),218,196,196,196,196,196,196,196,191,LF,CR
          db 15 dup(" "),179,           " JOGAR ",       179,LF,CR
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,LF,CR
          
tamanho_jogar equ $-btn_jogar ;$-> como se fosse um contador de posicao, ao montar uma string
                              ;$ aponta para o final dela.
                              

btn_sair  db 15 dup(" "),218,196,196,196,196,196,196,196,191,LF,CR
          db 15 dup(" "),179,           " SAIR  ",        179,LF,CR
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,LF,CR


tamanho_sair equ $-btn_sair


;FORMULA BASICA DE POSICIONAMENTO NA TELA: LINHA * 320 + COLUNA.
; 13 linhas x 29 colunas
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


; ========= METEORO 13x29 (valores em 00H..0FH) =========
; 13 linhas x 29 colunas
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


alien  db 00h,00h,00h,00h,00h,00h,00h,02h,02h,02h,02h,02h,02h,02h,0Ah,0Eh,0Eh,0Eh,0Eh,0Eh,0Eh,00h,00h,00h,00h,00h,00h,00h,00H
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

status db "SCORE:", 22 + (N_DIGITOS_PONTOS+1) - (N_DIGITIOS_TEMPO+1) dup(" "), "TEMPO:", LF, CR
tamanho_status equ $ - status

.code
; Funcao generica que escreve Strings com cor na tela
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

    mov AH, 13h ;escreve string com atributos de cor
    mov AL, 01h ;modo: atualiza o cursor apos a escrita   
    pop BX  
    xor BH, BH  ;pagina de video 0
    int 10h     ; Interrupcao para escrever a string
    
    pop BP
    pop SI
    pop ES
    pop DS
    pop BX
    pop AX
           
    ret
endp

ESCREVE_NUMERO proc
    ; Salva o contexto
    push AX
    push BX
    push CX
    push DX
    push SI
    push BP
    push DI

    mov DI, DX
    mov SI, CX      ; Numero de caracteres
    
    mov BX, 10      ; Divisor
    xor CX, CX

    DIVIDE_LOOP:
        xor DX, DX
        div BX              ; AX / 10 -> Resto em DX
        
        push DX             ; Salva o digito na pilha
        inc CX              ; Conta +1 digito real
        
        cmp AX, 0
        jne DIVIDE_LOOP
    
    PREENCHE_ZEROS:
        cmp SI, CX          ; Se Largura Desejada <= Digitos Reais
        jle LOOP_IMPRIME    ; Entao nao precisa mais de zeros
        
        ; Imprime um '0'
        push CX
        
        ; mov [temp_numero], '0' ; Carrega o caractere '0'
        
        ; Configura ESCREVE_STRING
        mov BP, offset temp_numero ; Texto
        mov CX, 1                  ; 1 Caractere
        mov DX, DI                 ; Posicao Atual
        call ESCREVE_STRING
        
        pop CX
        inc DL              ; Avanca o cursor (Coluna)
        mov DI, DX          ; Atualiza a posicao salva em DI
        dec SI              ; Decrementa a largura pendente
        jmp PREENCHE_ZEROS
        
    LOOP_IMPRIME:
        pop AX              ; Recupera o digito (estava em DX no push)
        push CX             ; Salva o contador do loop
        
        add AL, '0'         ; Converte para ASCII
        mov [temp_numero], AL
        
        mov BP, offset temp_numero
        mov CX, 1           ; Tamanho 1
        mov DX, DI          ; Posicao Atual
        ; BL Cor mantida
        call ESCREVE_STRING
        
        pop CX              ; Restaura contador
        
        inc DL              ; Avanca cursor
        mov DI, DX          ; Atualiza posi??o salva
        
        loop LOOP_IMPRIME   ; Decrementa CX e repete se > 0

    ; Restaura contexto
    pop DI
    pop BP
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
ESCREVE_NUMERO endp

ESCREVE_BARRA_STATUS proc
    ; Texto Score / Tempo
    mov DH, 0
    mov DL, 0
    mov BL, 0FH
    mov BP, offset status
    mov CX, tamanho_status
    call ESCREVE_STRING

    ; Pontuacao atual
    mov AX, pontuacao
    mov DH, 0
    mov DL, 7
    mov BL, 0AH
    mov CX, [caracteres_pontuacao]
    call ESCREVE_NUMERO

    ; Tempo restante
    mov AX, tempo_restante
    mov DH, 0
    mov DL, 38
    mov BL, 0AH
    mov CX, [caracteres_tempo]
    call ESCREVE_NUMERO
    
    ret
endp

LIMPA_TELA proc
    push CX
    push AX
    push DI
    
    mov AX, 0A000h
    mov ES, AX
    
    xor DI, DI
    xor AX, AX
    CLD ;zera o DF, DF = 0 avanca e DF = 1 volta
    
    mov CX,32000  ;como avanca +2 em stoswORD precisa percorrer 32k nao 64k
    mov DI,0

    rep stosw  ;repete CX vezes: [ES:DI] = AX; DI += 2. 
    
    pop DI
    pop AX
    pop CX
    ret
endp

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
    
    jmp FIM_TECLADO_JOGO
    
    SETA_CIMA:
        cmp DI, [limite_topo]
        jbe FIM_TECLADO_JOGO ; Se DI <= 3200, não sobe mais

        mov AX, 0 ; 0 = Cima
        call MOVER_VERTICAL
        jmp FIM_TECLADO_JOGO
        
    SETA_BAIXO:
        cmp DI, [limite_fundo]
        jae FIM_TECLADO_JOGO ; Se DI >= 59840, não desce mais

        mov AX, 1 ; 1 = Baixo
        call MOVER_VERTICAL
        jmp FIM_TECLADO_JOGO

    SETA_ESQUERDA:
        ; Calcula a coluna atual (DI % 320)
        mov AX, DI
        xor DX, DX
        mov BX, [largura_video]
        div BX
        
        cmp DX, 0  ; Verifica se X <= 0
        jle FIM_TECLADO_JOGO ; Se sim, não vai para a esquerda

        mov AX, 0 ; 0 = Esquerda
        call MOVER_HORIZONTAL
        jmp FIM_TECLADO_JOGO

    SETA_DIREITA:
        ; Calcula a coluna atual (DI % 320)
        mov AX, DI
        xor DX, DX
        mov BX, [largura_video]
        div BX
        
        cmp DX, [limite_direita] ; Verifica se X >= 291
        jae FIM_TECLADO_JOGO ; Se sim, não vai para a direita

        mov AX, 1 ; 1 = Direita
        call MOVER_HORIZONTAL
        jmp FIM_TECLADO_JOGO
        
    FIM_TECLADO_JOGO:
        mov [nave_posicao], DI
        pop AX
        pop DI
        ret
    endp

MOVER_VERTICAL proc
    ; AX=0 (Cima), AX=1 (Baixo)
    push BX
    mov BX, [largura_video]
    
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

MOVER_HORIZONTAL proc
    ; AX=0 (Esquerda), AX=1 (Direita)
    cmp AX, 0
    je MOVER_ESQUERDA
    
    MOVER_DIREITA:
        inc DI
        jmp SAIR_MOVIMENTO_HORIZONTAL
    
    MOVER_ESQUERDA:
        dec DI
        jmp SAIR_MOVIMENTO_HORIZONTAL
    
    SAIR_MOVIMENTO_HORIZONTAL:
        ret
endp

CARREGA_FASE proc       ; Espera X segundos e depois limpa a tela
    mov CX, WORD PTR [tempo_tela_fase + 2]
    mov DX, WORD PTR [tempo_tela_fase]
    mov AH, 86h
    int 15h
    
    call LIMPA_TELA
    ret
endp

PARTIDA proc
    call ESCREVE_BARRA_STATUS 
    
    mov AX, [nave_posicao]
    mov SI, offset nave
    call DESENHA


    JOGANDO:
        call ESCREVE_BARRA_STATUS 
        call BUSCA_INTERACAO
        
        mov DI, [nave_posicao]
        call LIMPA_13x29; apaga 13x29 na posicao DI.
        
        call VERIFICA_TECLADO_JOGO
        
        mov AX, [nave_posicao]
        mov SI, offset nave ;prepara SI para MOVSB Move de DS:SI -> ES:DI
        call DESENHA
        
        jmp JOGANDO
    ret
endp

JOGAR_SAIR proc                     ; Verifica qual opcao esta marcada
    cmp menu_selecao, 1
    jne JOGAR_F1
    call TERMINA_JOGO
    
    JOGAR_F1:
        xor inicia_jogo, 1
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 0FH
        mov BP, offset arte_f1
        mov CX, tamanho_f1
        call ESCREVE_STRING
        
        call CARREGA_FASE
        call PARTIDA
        
    JOGAR_F2:
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 0CH
        mov BP, offset arte_f2
        mov CX, tamanho_f2
        call ESCREVE_STRING
        
        call CARREGA_FASE
        ; call PARTIDA
        
    JOGAR_F3:
        call LIMPA_TELA
        mov DH, 10
        mov DL, 0
        mov BL, 04H
        mov BP, offset arte_f3
        mov CX, tamanho_f3
        call ESCREVE_STRING
        
        call CARREGA_FASE
        call PARTIDA
        

    ret
endp

TERMINA_JOGO proc ; Encerra o jogo
    mov AH, 4Ch
    int 21h
    ret
endp

VERIFICA_OPCAO proc         ; Verifica qual opcao esta marcada no menu (jogar/sair)
    push BP
    push BX
    push CX
    push DX
    
    cmp menu_selecao, 0
    jne OPCAO_SAIR
    
    mov DH, 18                   ; Opcao "Jogar" selecionada
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
    
    OPCAO_SAIR:                 ; Opcao "Sair" selecionada
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

INTERAGE_MENU proc      ; Verifica se houve alguma interacao na tela do menu
    push AX
    
    mov AH, 01H
    int 16H
    jz VOLTAR_MENU
    
    xor AH, AH
    int 16H
    
    cmp AH, 48H         ; Seta Cima
    jne BOTAO_BAIXO
    xor menu_selecao, 1
    jmp VOLTAR_MENU
    
    BOTAO_BAIXO:
        cmp AH, 50H     ; Seta Baixo
        jne BOTAO_ENTER
        xor menu_selecao, 1
        jmp VOLTAR_MENU
        
    BOTAO_ENTER:
        cmp AH, 1CH     ; Enter
        jne VOLTAR_MENU
        call JOGAR_SAIR
        
    VOLTAR_MENU:
        pop AX
        ret
endp

BUSCA_INTERACAO proc ; Cria pausas para ver se houve interacao no teclado
    push CX
    push DX
    
    xor CX, CX      ; Inicia em 0
    mov DX, [delay] ; e vai ate delay
    mov AH, 86h
    int 15h
    
    pop DX
    pop CX
    ret
endp

JOGO proc                       ; Carrega a tela inicial do jogo (menu)
    call ESCREVE_TITULO
    call ESCREVE_BOTOES  
    call RESET_ALIEN_MENU  ;posiona nave alien em uma posicao aleatoria na tela
    call RESET_POSICOES_MENU    ;posiciona nave e meteoro nas extremidades
     
    MENU:
        call BUSCA_INTERACAO
        call INTERAGE_MENU
        call MENU_ANIMATION
        jne CONTINUA_LOOP
    
    CONTINUA_LOOP:
        call VERIFICA_OPCAO
        jmp MENU

    ret
endp

 
ESCREVE_TITULO proc ;prepara registradores pra executar o call print
    mov AX,DS
    mov ES,AX
    
    mov BP, offset arte_titulo
    mov CX, tamanho_arte
    mov BL, 02H ;representa a cor verde
    xor DX,DX ;zerando o registrador DX -> DH=linha/DL=coluna
    
    call ESCREVE_STRING      
    
    ret
endp 
    
ESCREVE_BOTOES proc
    push AX
    
    mov BL, 0FH ;cor
    mov AH, op_menu
    
    cmp AH, 1     
    
    jne INICIA_BTN
    mov BL, 0CH

    INICIA_BTN:
        mov BP, offset btn_jogar 
        mov CX, tamanho_jogar
        
        xor DL,DL ;coluna = 0 | Modo 13h (320?200): grade 40?25 (colunas 0..39, linhas 0..24).
        mov DH,18 ;linha = 18 |
        call ESCREVE_STRING
        
        mov BL, 0FH
        mov AH, op_menu
        cmp AH, 0
        jne SAIR_BTN
        mov BL, 0CH
        
    SAIR_BTN:
       mov BP, offset btn_sair
       mov CX, tamanho_sair
       xor DL, DL ;colunha =0;
       mov DH, 21 ;linha
       call ESCREVE_STRING
       
   pop AX
   ret
endp 

REINICIA_FASE proc  ;RESET_SECTOR
    mov fase, 1
    
    ret
endp

;INT 1AH - CLOCK 00H - GET TIME OF DAY
;Obtem os valores do controlador do relogio
;do sistema.
SEED_FROM_TICKS proc  ;SYSTIME_SEED
    push AX
    push CX
    push DX
    mov  AH, 00h
    int  1Ah              ; CX:DX = ticks desde 00:00
    mov  seed, DX         
    pop  DX
    pop  CX
    pop  AX
    
    ret
endp


;proc que usa LCG para gerar um numero pseudoaleatorio de 16 bits sem sinal retornado em AX
RAND_16 proc
    
    mov AX,39541
    mul seed
    add AX, 16259
    mov seed,AX
    

    ret
endp

;proc que retorna um numero de 8 bit sem sinal em AL,
;AH = passado como parametro sendo o valor maximo,
;AL = retorno, entre 0 e AL
RAND_8 proc

   push BX
   push CX
   push DX
   push AX
   
   xor CX,CX
   mov CL,AH ;salva o max em CL
   
   call RAND_16; atualiza o seed e retorna UINT16 em AX
   
   xor DX,DX ;prepara DX para receber o resto DX = resto da divisao, entre 0...AH
   mov BX,CX
   div BX
   
   pop AX 
   
   mov AL,DL ;passa para AL o numero pseudoaleatorio
   
   pop DX
   pop CX
   pop BX

    ret
endp

;proc que reposiciona naves e objetos no menu inicial
RESET_POSICOES_MENU proc
    
    ;FORMULA BASICA DE POSICIONAMENTO NA TELA: LINHA * 320 + COLUNA.
    push AX   
    
    xor AX,AX ;zera antes 
    mov AX, 50*320 
    mov nave_posicao, AX ;posiciona a nave
     
    add AX, 291 ;vai ate o fim da linha onde vem o meteoro 
    add AX, 20*320  ;20 pixel pra baixo da nave, tem que multiplicar por 320 
    mov meteoro_posicao, AX  ;posiciona o meteoro
    
      
    pop AX
    
  ret
endp


;proc que redefine a posicao do alien no menu inicial
RESET_ALIEN_MENU proc
    
    push AX
    push DX
    push BX
    
    xor AX,AX
    mov AH, 133 ;AH = MAX
    
    call RAND_8 ; retorna um valor peseudoaleatorio em AL onde AL < AH
    cmp AL,90 ; se AL < 83 -> sendo 83 = 70 do inicio do meteoro + 13 altura do meteoro
    jae Y_OK 
    mov AL,90;come??a depois do meteoro
     
    Y_OK:
        xor DX,DX
        mov DL,AL
        mov alien_y,DX ;passa altura minima para Y
        
        mov AH,255 ; max largura
        call RAND_8
        
        cmp AL,50 ;coluna minima 29
        jae X_OK
        mov AL,50
    X_OK:
        xor DX,DX
        mov DL,AL
        mov alien_x,DX ;coluna minima para X
        
        
        mov BX,320 ;adiciona 320 que o maximo de deslocamento por linha
        
        mov AX,alien_y ; move o valor em alien_y para AX
        mul BX ;multiplica alien_y em AX para obter a linha correta, ja que a formula de deslocamento ? Y*320 + X
        
        add AX,alien_x
    
        mov alien_posicao, AX
        
        mov alien_direction,1

        

        pop BX
        pop DX
        pop AX
    
   ret
endp 


;proc que "limpa" 13x29 pixeis na posicao DI
;DI = POSICAO
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
    add DI, 291
    pop CX
    loop LIMPA_LINHA

    pop ES
    pop DI
    pop CX
    pop AX
    ret

  ret
endp

;proc que desenha um elemento na tela utilizando rep movsb ;DS:SI -> ES:DI 
; AX = posicao atual do elemento
; SI = offset do elemento no DS
DESENHA proc
     push BX
     push CX
     push DX
     push DI
     push ES
     push DS
     push AX ;salva a posicao
      
     mov AX, @data
     mov DS, AX
     
     mov AX, 0A000H;SEGMENTO DE VIDEO
     mov ES, AX
     
     
     pop AX ;volta a posicao salva
     mov DI, AX
     MOV DX, 13 ;altura 13
     
     push AX
     
    LINHA_LOOP:
         mov CX, 29 ;largura 29
         rep movsb ;DS:SI -> ES:DI 
         add DI, 320-29  ;+320 avanca 1 linha - 29 para ir na posicao correta do inicio da nave
         
         dec DX ;terminou uma linha decrementa o contador de altura 
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

MENU_ANIMATION proc
    MOVE_NAVE:
        mov AX, nave_posicao
        mov DI, AX   
        
        call LIMPA_13x29; apaga 13x29 na posicao DI.
        
        cmp AX, 50*320+291 ;LINHA 70 + COLUNA = 291 compara se a nave chegou na borda direita
        je MOVE_METEORO
        
        inc nave_posicao ;move 1 pixel
        inc AX ;move tambem AX 1 pixel 
        
        mov SI, offset nave ;prepara SI para MOVSB Move de DS:SI -> ES:DI
        call DESENHA; RENDER_SPRITE
    
    MOVE_METEORO:
        mov AX, meteoro_posicao
        mov DI, AX;move a posicao do meteoro para DI
        
        cmp AX, 70*320 ;linha 70 = 50 da nave + 20 do reset posicoes
        
        
        je RESET_NAVE_METEORO
        
        call LIMPA_13x29; apaga 13x29 na posicao DI.
            
        ;meteoro vem pra direita    
        dec meteoro_posicao
        dec AX
        
        mov SI, offset meteoro
        call DESENHA; RENDER_SPRIT
        
     MOVE_ALIEN:
    
     mov DX,alien_direction
     cmp DX,1   
     jne ALIEN_DIREITA
     
        mov AX, alien_posicao
        mov DI, AX;move a posicao do meteoro para DI
        
        mov DX,alien_x 
        
        cmp DX,0 ;Chegou na borda da esquerda
        
        je RESET_ALIEN_DIRECTION
        
        call LIMPA_13x29; apaga 13x29 na posicao DI.
            
        ;alien vem pra esquerda    
        dec alien_posicao
        dec AX
        dec alien_x
        
        mov SI, offset alien
        call DESENHA; RENDER_SPRIT
        
        jmp END_POS_UPDATE
        
    ALIEN_DIREITA:
        mov AX, alien_posicao
        mov DI, AX;move a posicao do aliwn para DI
        mov DX,alien_x  
        ;push AX
        cmp DX,291 ;Chegou na borda da esquerda     
        ;pop AX     
        je RESET_ALIEN_DIRECTION_2
        
        call LIMPA_13x29; apaga 13x29 na posicao DI.
            
        ;alien vem pra direita    
        inc alien_posicao
        inc AX
        inc alien_x
        
        mov SI, offset alien
        call DESENHA; RENDER_SPRIT 
        jmp END_POS_UPDATE
    
    RESET_ALIEN_DIRECTION:
        mov alien_direction,2
        jmp END_POS_UPDATE
        
    RESET_ALIEN_DIRECTION_2:
        mov alien_direction, 1
        jmp END_POS_UPDATE
        
    RESET_NAVE_METEORO:
        call LIMPA_13x29; apaga 13x29 na posicao DI.
        call RESET_POSICOES_MENU 
    
    END_POS_UPDATE:
        ret
endp

MAIN:
    ;referencia o segmento de dados em ds
    mov AX, @data
    mov DS, AX
    
    ;referencia o segmento de memoria de video em ES
    mov AX, 0A000H
    mov ES, AX
    
    call SEED_FROM_TICKS
    
    ;inicia modo de video com 0A000H
    xor AH, AH
    mov AL, 13H
    int 10H
    
    call JOGO
    
end MAIN