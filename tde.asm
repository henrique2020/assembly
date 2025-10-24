.model small


.stack 100H


.data
      op_menu db 0
      
arte_titulo db 3 dup(" ")," ___                    _    _     ", 10, 13 ; , 10, 13 ; Isso quebra a linha
            db 3 dup(" "),"/ __| __ _ _ __ _ _ __ | |__| |___ ", 10, 13            ; Verificar para usar na versao final
            db 3 dup(" "),"\__ \/ _| '_/ _` | '  \| '_ \ / -_)", 10, 13
            db 3 dup(" "),"|___/\__|_| \__,_|_|_|_|_.__/_\___|", 10, 13
       
tamanho_arte equ $ - arte_titulo

arte_fase_1 db "   __                _ ", 10, 13
            db "  / _|__ _ ___ ___  / |", 10, 13
            db " |  _/ _` (_-</ -_) | |", 10, 13
            db " |_| \__,_/__/\___| |_|", 10, 13


arte_fase_2 db "       _____  _____  _____  _____       "
            db "      /   __\/  _  \/  ___>/   __\      "
            db "      |   __||  _  ||___  ||   __|      "
            db "      \__/   \__|__/<_____/\_____/      "
            db "                 _____                  "
            db "                <___  \                 "
            db "                 /  __/                 "
            db "                <_____|                 "

arte_fase_3 db "       _____  _____  _____  _____       "
            db "      /   __\/  _  \/  ___>/   __\      "
            db "      |   __||  _  ||___  ||   __|      "
            db "      \__/   \__|__/<_____/\_____/      "
            db "                 _____                  "
            db "                /  _  \                 "
            db "                >-<_  <                 "
            db "                \_____/                 "
            
;  _____  _____  __  __  _____    _____  __ __  _____  _____ 
; /   __\/  _  \/  \/  \/   __\  /  _  \/  |  \/   __\/  _  \
; |  |_ ||  _  ||  \/  ||   __|  |  |  |\  |  /|   __||  _  <
; \_____/\__|__/\__ \__/\_____/  \_____/ \___/ \_____/\__|\_/
;  __ __  _____  _____  _____  _____  _____  _____  _____    
; /  |  \/   __\/  _  \/     \/   __\|  _  \/  _  \/  _  \   
; \  |  /|   __||  |  ||  |--||   __||  |  ||  |  ||  _  <   
;  \___/ \_____/\__|__/\_____/\_____/|_____/\_____/\__|\_/   



btn_jogar db 15 dup(" "),218,196,196,196,196,196,196,196,191,10,13
          db 15 dup(" "),179,           " JOGAR ",       179,10,13
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,10,13
          
tamanho_jogar equ $-btn_jogar ;$-> como se fosse um contador de posicao, ao montar uma string
                              ;$ aponta para o final dela.
                              

btn_sair  db 15 dup(" "),218,196,196,196,196,196,196,196,191,10,13
          db 15 dup(" "),179,           " SAIR  ",        179,10,13
          db 15 dup(" "),192,196,196,196,196,196,196,196,217,10,13


tamanho_sair equ $-btn_sair


menu_selecao db 0   ; 0 = Jogar, 1 = Sair
inicia_jogo  db 0   ; Flag para iniciar o jogo
fps dw 10000        ; tempo em microsegundos (/10 para frames por segundo)


.code 

ESCREVE_STRING proc ; Funcao que escreve strings na tela
    push AX
    push BX
    push DS
    push ES
    push SI
    push BP

    mov AH, 13h ;escreve string com atributos de cor
    mov AL, 01h ;modo: atualiza o cursor apos a escrita   
           
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

LIMPA_TELA proc
    push CX
    push AX
    push DI
    
    mov AX,0H
    CLD ;zera o DF, DF = 0 avanca e DF = 1 volta
    
    
    mov CX,4  ;como avanca +2 em stoswORD precisa percorrer 32k nao 64k
    mov DI,0

    rep stosw  ;repete CX vezes: [ES:DI] = AX; DI += 2. 
    
    pop DI
    pop AX
    pop CX
    ret
endp

CARREGA_FASE proc       ; Espera 4s e depois limpa a tela
    mov CX, 003Dh
    mov DX, 0900h
    mov AH, 86h
    int 15h
    
    call LIMPA_TELA
    ret
endp

JOGAR_SAIR proc                     ; Verifica qual opcao esta marcada
    cmp menu_selecao, 1
    jne INICIA_JOGO_F1
    call TERMINA_JOGO
    
    INICIA_JOGO_F1:                    ; Limpa a tela e desenha a fase 1
        call LIMPA_TELA
        mov DH, 8
        mov DL, 0
        mov BL, 04H
        mov BP, offset arte_fase_1
        mov CX, tamanho_arte
        call ESCREVE_STRING
        
        call CARREGA_FASE 
        xor inicia_jogo, 1

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
    
    mov AH, 86h
    mov CX, 0       ; Parte alta do tempo
    mov DX, [fps]   ; Parte baixa do tempo
    int 15h
    
    pop DX
    pop CX
    ret
endp

JOGO proc                       ; Carrega a tela inicial do jogo (menu)
    call LIMPA_TELA

    
    ;
    ; Fazer as artes das naves e meteoro
    ;
    
    
    mov DH, 21
    mov BL, 15
    mov BP, offset btn_sair
    mov CX, tamanho_sair
    call ESCREVE_STRING
    
    MENU:
        mov DX, fps
        xor CX, CX
        call BUSCA_INTERACAO
        call INTERAGE_MENU
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
    
    mov BL, 0FH;cor
    mov AH, op_menu
    
    cmp AH, 0     
    
    jne INICIA_BTN
    mov BL, 0CH

INICIA_BTN:
    
    mov BP, offset btn_jogar 
    mov CX, tamanho_jogar
    
    xor DL,DL ;coluna = 0
    mov DH,18 ;linha = 18
    
    call ESCREVE_STRING
    
    mov BL, 0FH
    mov AH, op_menu
    cmp AH, 1
    jne SAIR_BTN
    mov BL, 0CH
    
SAIR_BTN:
   
   mov BP, offset btn_sair
   mov CX, tamanho_sair
   xor DL, DL ;colunha =0;
   mov DH, 21 ;linha
   
   
   pop AX      
    
   ret
endp    
    
MAIN:
    ;referencia o segmento de dados em ds
    mov AX, @data
    mov DS, AX
    
    
    ;referencia o segmento de memoria de video em ES
    mov AX, 0A000H
    mov ES, AX
    
    ;inicia modo de video com 0A000H
    xor AH, AH
    mov AL, 13H
    int 10H
    
    
    call ESCREVE_TITULO
    call ESCREVE_BOTOES
    
    call JOGO
   
end MAIN
