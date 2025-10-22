.model small
.stack 100H
.data

arte_titulo db "   _____  _____  _____  _____           " ; , 10, 13 ; Isso quebra a linha
            db "  /  ___>/     \/  _  \/  _  \          "            ; Verificar para usar na versao final
            db "  |___  ||  |--||  _  <|  _  |          "
            db "  <_____/\_____/\__|\_/\__|__/          "
            db "          __  __  _____  ____   _____   "
            db "         /  \/  \/  _  \/  _/  /   __\  "
            db "         |  \/  ||  _  <|  |---|   __|  "
            db "         \__ \__/\_____/\_____/\_____/  "
tamanho_arte equ $ - arte_titulo

arte_fase_1 db "       _____  _____  _____  _____       "
            db "      /   __\/  _  \/  ___>/   __\      "
            db "      |   __||  _  ||___  ||   __|      "
            db "      \__/   \__|__/<_____/\_____/      "
            db "                  ___                   "
            db "                 /   |                  "
            db "                  |  |                  "
            db "                 <____>                 "

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



btn_jogar db "                ",218,196,196,196,196,196,196,196,191,"               "
          db "                ",179," JOGAR ",179,"               "               
          db "                ",192,196,196,196,196,196,196,196,217,"               "
tamanho_btn equ $ - btn_jogar

btn_sair db "                ",218,196,196,196,196,196,196,196,191,"               "
         db "                ",179," SAIR  ",179,"               "              
         db "                ",192,196,196,196,196,196,196,196,217,"               "

menu_selecao db 0   ; 0 = Jogar, 1 = Sair
inicia_jogo  db 0   ; Flag para iniciar o jogo
fps dw 10000        ; tempo em microsegundos (/10 para frames por segundo)


.code
ESCREVE_STRING proc ; Funcao que escreve strings na tela
    push ES   
    push BX

    mov BX, DS
    mov ES, BX

    mov AH, 13h
    mov AL, 01h    
    pop BX              
    xor BH, BH

    int 10h         ; Interrupcao para escrever a string
    
    pop ES       
    ret
endp

LIMPA_TELA proc
    push CX

    mov CX, 64000
    LIMPA_PIXEL:
    mov SI, CX
    mov WORD PTR ES:[SI], 0H
    loop LIMPA_PIXEL
    
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
    jne INICIA_JOGO
    call TERMINA_JOGO
    
    INICIA_JOGO:                    ; Limpa a tela e desenha a fase 1
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
    mov CX, tamanho_btn
    call ESCREVE_STRING
    
    mov DH, 21
    mov BL, 0FH
    mov BP, offset btn_sair
    mov CX, tamanho_btn
    call ESCREVE_STRING
    jmp VOLTAR_VERIFICA_OPCAO
    
    OPCAO_SAIR:                 ; Opcao "Sair" selecionada
        mov DH, 18
        mov DL, 0
        mov BL, 0FH
        mov BP, offset btn_jogar
        mov CX, tamanho_btn
        call ESCREVE_STRING
        
        mov DH, 21
        mov BL, 0CH
        mov BP, offset btn_sair
        mov CX, tamanho_btn
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

    mov DH, 0
    mov DL, 0
    mov BL, 0AH
    mov BP, offset arte_titulo
    mov CX, tamanho_arte
    call ESCREVE_STRING
    
    ;
    ; Fazer as artes das naves e meteoro
    ;
    
    mov DH, 18
    mov BL, 0CH
    mov BP, offset btn_jogar
    mov CX, tamanho_btn
    call ESCREVE_STRING
    
    mov DH, 21
    mov BL, 15
    mov BP, offset btn_sair
    mov CX, tamanho_btn
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

MAIN:
    mov AX, @data
    mov DS, AX
    mov AX, 0A000H
    mov ES, AX
    
    xor AH, AH
    mov AL, 13H
    int 10H
    
    call JOGO
   
end MAIN
