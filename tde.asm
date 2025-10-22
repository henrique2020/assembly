.model small
.stack 100H
.data

arte_titulo db "   _____  _____  _____  _____           " ; , 10, 13
            db "  /  ___>/     \/  _  \/  _  \          "
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

.code
ESCREVE_STRING proc ;Fun??o para escreve as strings
    push ES   
    push BX

    mov BX, DS
    mov ES, BX

    mov AH, 13h
    mov AL, 01h    
    pop BX              
    xor BH, BH

    int 10h ;interrupcao para escrever a string
    
    pop ES       
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
    
    mov DH, 0
    mov DL, 0
    mov BL, 04H
    mov BP, offset arte_fase_1
    mov CX, tamanho_arte
    call ESCREVE_STRING
    
    mov DH, 8
    mov DL, 0
    mov BL, 0CH
    mov BP, offset arte_fase_2
    mov CX, tamanho_arte
    call ESCREVE_STRING
    
    mov DH, 16
    mov DL, 0
    mov BL, 0BH
    mov BP, offset arte_fase_3
    mov CX, tamanho_arte
    call ESCREVE_STRING
   
end MAIN