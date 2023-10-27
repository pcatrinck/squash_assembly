; autor: Patrick Dias Catrinck 
; Trabalho de programação da disciplina de Sistemas Embarcados

segment code
..start:
        mov         ax,data
        mov         ds,ax
        mov         ax,stack
        mov         ss,ax
        mov         sp,stacktop

; salvar modo corrente de video(vendo como esta o modo de video da maquina)
        mov     ah,0Fh
        int     10h
        mov     [modo_anterior],al   

; alterar modo de video para grafico 640x480 16 cores
        mov     al,12h
        mov     ah,0
        int     10h

;desenhar retas

        mov     byte[cor],branco_intenso    ;baixo
        mov     ax,0
        push    ax
        mov     ax,0
        push    ax
        mov     ax,639
        push    ax
        mov     ax,0
        push    ax
        call    line


        mov     byte[cor],branco_intenso    ;esquerda
        mov     ax,0
        push    ax
        mov     ax,0
        push    ax
        mov     ax,0
        push    ax
        mov     ax,479
        push    ax
        call    line

        mov     byte[cor],branco_intenso    ;cima
        mov     ax,0
        push    ax
        mov     ax,479
        push    ax
        mov     ax,639
        push    ax
        mov     ax,479
        push    ax
        call    line

        mov     byte[cor],branco_intenso    ;direita
        mov     ax,639
        push    ax
        mov     ax,0
        push    ax
        mov     ax,639
        push    ax
        mov     ax,479
        push    ax
        call    line

        mov     byte[cor],branco_intenso    ;titulo
        mov     ax,0
        push    ax
        mov     ax,440
        push    ax
        mov     ax,639
        push    ax
        mov     ax,440
        push    ax
        call    line
        
;desenha circulos 
        mov     byte[cor],vermelho
        mov     ax,word[p_bx]
        push    ax
        mov     ax,word[p_by]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle

;desenha o paddle
        mov     byte[cor],branco
        mov     ax,[p_px]
        push    ax
        mov     ax,[p_py]
        push    ax
        mov     ax,[p_pxl]
        push    ax
        mov     ax,[p_pya]
        push    ax
        call    desenha_retangulo

;escrever o cabecalho
        mov     cx,56			;numero de caracteres
        mov     bx,0
        mov     dh,0			;linha 0-29
        mov     dl,0 			;coluna 0-79
        mov	byte[cor],branco

escreve1:
        call    cursor
        mov     al,[bx+mens1]
        call    caracter
        inc     bx	                ;proximo caracter
        inc     dl	                ;avanca a coluna
        loop    escreve1

        mov     cx,78			;numero de caracteres
        mov     bx,0
        mov     dh,1			;linha 0-29
        mov     dl,0 			;coluna 0-79
        mov	byte[cor],branco

escreve2:
        call    cursor
        mov     al,[bx+mens2]
        call    caracter
        inc     bx	                ;proximo caracter
        inc     dl	                ;avanca a coluna
        loop    escreve2

nova_bola:
        mov     byte[cor],preto ; apaga a bola anterior
        mov     ax,[p_bx]
        push    ax
        mov     ax,[p_by]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle
        mov     bx, [vx]
        add     [p_bx], bx
        mov     bx, [vy]
        add     [p_by], bx

        mov     byte[cor],vermelho
        mov     ax,[p_bx]
        push    ax
        mov     ax,[p_by]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle

novo_retangulo:
        mov     byte[cor],preto
        mov     ax,[p_px]
        push    ax
        mov     ax,[p_py]
        push    ax
        mov     ax,[p_pxl]
        push    ax
        mov     ax,[p_pya]
        push    ax
        call    desenha_retangulo

        mov bx, [vy_ret]
        add [p_py], bx
        add [p_pya], bx

        mov     byte[cor],branco
        mov     ax,[p_px]
        push    ax
        mov     ax,[p_py]
        push    ax
        mov     ax,[p_pxl]
        push    ax
        mov     ax,[p_pya]
        push    ax
        call    desenha_retangulo

del1:
        mov si, [p_px]
        add si, -10 ; raio
        cmp [p_bx], si
        je call_checa_topo

        mov si, 628
        cmp [p_bx], si
        jz reflete_direita

        mov si, 10
        cmp [p_bx], si
        jz reflete_esquerda

        mov si, 429
        cmp [p_by], si
        jz call_reflete_cima

        mov si, 11
        cmp [p_by], si
        jz call_reflete_baixo
        
        mov si, 2
        cmp [p_pya], si
        jle subindo

        mov si, 439
        cmp [p_py], si
        jge descendo

        mov ah, 0bh    ;BIOS.TestKey
        int 21h
        cmp al, 0
        jne call_jne_keyboard
        jmp continua
continua:
        call espera
        call nova_bola
        call novo_retangulo
        pop cx
        loop del1
        ret

espera:
        xor ax,ax
        mov ah, 86h
        mov dx, [delay] ; ficou melhor botar em dx, cx travava MUITO
        int 15h
        ret

call_checa_topo:
        jmp checa_topo
call_reflete_cima:
        jmp reflete_cima
call_reflete_baixo:
        jmp reflete_baixo
call_marca_ponto_jogador:
        jmp marca_ponto_jogador
call_jne_keyboard:
        jmp keyboard

reflete_direita:
        mov si, -1
        mov [vx], si
        mov si, 628
        cmp [p_bx], si
        jz  call_marca_ponto_computador
        jmp continua
reflete_esquerda:
        mov si, 1
        mov [vx], si
        ; mov si, 10
        ; cmp [p_bx], si
        ; jz  call_marca_ponto_jogador
        jmp continua
descendo:
        mov si,-1
        mov [vy_ret], si
        jmp continua
subindo:
        mov si,1
        mov [vy_ret], si
        jmp continua
reflete_cima:
        mov si, -1
        mov [vy], si
        jmp call_continua
reflete_baixo:
        mov si, 1
        mov [vy], si
        jmp call_continua
checa_topo:
        mov si, [p_py]
        add si, 3  ; margem
        cmp [p_by], si
        jle checa_base
        jmp call_continua
checa_base:
        mov si, [p_pya]
        add si, -3 ; margem
        cmp [p_by], si
        jnge call_continua
        mov si, -1
        cmp [vx],si
        je call_continua
        call call_marca_ponto_jogador
call_continua:
        jmp continua
keyboard:
        mov ah, 08H ;Ler caracter da STDIN
        int 21H
        cmp al, 'c'
        jz subindo
        cmp al, 'b'
        jz descendo
        cmp al, 'p'
        jz acelera
        cmp al, 'm'
        jz desacelera
        cmp al, 's'
        jz encerra
        jmp continua

call_marca_ponto_computador:
    jmp marca_ponto_computador

desacelera:
        mov si,20000
        cmp [delay], si
        je marca_velocidade
        mov si, 10000
        add[delay], si
        jmp marca_velocidade
acelera:
        mov si,0
        cmp [delay], si
        je marca_velocidade
        mov si, -10000
        add[delay], si
        jmp marca_velocidade

encerra:
        mov ah,0 ; set video mode
        mov al,[modo_anterior] ; recupera o modo anterior
        int 10h
        mov ax,4c00h
        int 21h

; velocidade_1:
;         mov ax,1
;         ret
; velocidade_2:
;         mov ax,2
;         ret
; velocidade_3:
;         mov ax,3
;         ret

marca_velocidade:
        mov     ax, [delay]   ; Load 'delay' into AX
        mov     cx, 10000     ; Set the divisor to 10,000
        xor     dx, dx        ; Clear DX to ensure the division result doesn't affect it
        div     cx            ; Divide AX by CX, result in AX (quotient), DX (remainder)
        add     ax,1
        ; mov ax, [delay]
        ; cmp ax,0
        ; je velocidade_3
        ; cmp ax,10000
        ; je velocidade_2
        ; cmp ax,20000
        ; je velocidade_1
        call    converte_para_ascii     
        mov     bx, string_ponto_computador       
        mov     cx, 2                   
        mov     dh, 1                 
        mov     dl, 72
        mov     byte [cor], branco_intenso    
        call    escreve_valor_loop
        jmp     continua

marca_ponto_computador:
        mov     ax, [ponto_computador]
        add     ax, 1
        mov     [ponto_computador], ax
        mov     ax, [ponto_computador]  
        call    converte_para_ascii     
        mov     bx, string_ponto_computador       
        mov     cx, 2                   
        mov     dh, 1                 
        mov     dl, 25                  
        mov     byte [cor], vermelho    
        call    escreve_valor_loop
        jmp     continua

marca_ponto_jogador:
        mov     ax, [ponto_jogador]
        add     ax, 1
        mov     [ponto_jogador], ax
        mov     ax, [ponto_jogador]  
        call    converte_para_ascii  
        mov     bx, string_ponto_computador       
        mov     cx, 2       
        mov     dh, 1        
        mov     dl, 18          
        mov     byte [cor], azul  
        call    escreve_valor_loop
        call    reflete_direita

escreve_valor_loop:
        call    cursor
        mov     al, [bx]             
        call    caracter
        inc     bx                    
        inc     dl  
        loop    escreve_valor_loop
        ret

converte_para_ascii:
        push    ax                               ; empilha ax
        xor     dx, dx                           ; limpa dx antes de dividir
        mov     cx, 10                           ; numerador recebe 10
        div     cx                               ; divide ax por 10
        add     dl, '0'                          ; soma o valor do caracter 0 em ascii, para converter as dezenas
        mov     [string_ponto_computador+1], dl  ; guarda as unidades na casa do lado
        add     al, '0'                          ; converte pra ascii
        mov     [string_ponto_computador], al    ; termina de armazenar o resultado
        pop     ax                               ; restaura o valor de ax
        ret

;   funcao cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        mov     ah,2
        mov     bh,0
        int     10h
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
;_____________________________________________________________________________
;
;   funcao caracter escrito na posicao do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        push        bp
        mov         ah,9
        mov         bh,0
        mov         cx,1
        mov         bl,[cor]
        int         10h
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
;_____________________________________________________________________________
;
;   funcao plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
        push        bp
        mov     bp,sp
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        mov         ah,0ch
        mov         al,[cor]
        mov         bh,0
        mov         dx,479
        sub     dx,[bp+4]
        mov         cx,[bp+6]
        int         10h
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        pop     bp
        ret     4

;-----------------------------------------------------------------------------
;    funcao full_circle
;    push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor                    
full_circle:
    push    bp
    mov     bp,sp
    pushf                        ;coloca os flags na pilha
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    mov     ax,[bp+8]    ; resgata xc
    mov     bx,[bp+6]    ; resgata yc
    mov     cx,[bp+4]    ; resgata r
    
    mov     si,bx
    sub     si,cx
    push    ax          ;coloca xc na pilha         
    push    si          ;coloca yc-r na pilha
    mov     si,bx
    add     si,cx
    push    ax      ;coloca xc na pilha
    push    si      ;coloca yc+r na pilha
    call line
    
        
    mov     di,cx
    sub     di,1     ;di=r-1
    mov     dx,0    ;dx serah a variavel x. cx eh a variavel y
    
;aqui em cima a logica foi invertida, 1-r => r-1
;e as comparacoes passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:              ;loop
    mov     si,di
    cmp     si,0
    jg      inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov     si,dx       ;o jl eh importante porque trata-se de conta com sinal
    sal     si,1        ;multiplica por doi (shift arithmetic left)
    add     si,3
    add     di,si     ;nesse ponto d=d+2*dx+3
    inc     dx      ;incrementa dx
    jmp     plotar_full
inf_full:   
    mov     si,dx
    sub     si,cx       ;faz x - y (dx-cx), e salva em di 
    sal     si,1
    add     si,5
    add     di,si       ;nesse ponto d=d+2*(dx-cx)+5
    inc     dx      ;incrementa x (dx)
    dec     cx      ;decrementa y (cx)
    
plotar_full:    
    mov     si,ax
    add     si,cx
    push    si      ;coloca a abcisa y+xc na pilha          
    mov     si,bx
    sub     si,dx
    push    si      ;coloca a ordenada yc-x na pilha
    mov     si,ax
    add     si,cx
    push    si      ;coloca a abcisa y+xc na pilha  
    mov     si,bx
    add     si,dx
    push    si      ;coloca a ordenada yc+x na pilha    
    call    line
    
    mov     si,ax
    add     si,dx
    push    si      ;coloca a abcisa xc+x na pilha          
    mov     si,bx
    sub     si,cx
    push    si      ;coloca a ordenada yc-y na pilha
    mov     si,ax
    add     si,dx
    push    si      ;coloca a abcisa xc+x na pilha  
    mov     si,bx
    add     si,cx
    push    si      ;coloca a ordenada yc+y na pilha    
    call    line
    
    mov     si,ax
    sub     si,dx
    push    si      ;coloca a abcisa xc-x na pilha          
    mov     si,bx
    sub     si,cx
    push    si      ;coloca a ordenada yc-y na pilha
    mov     si,ax
    sub     si,dx
    push    si      ;coloca a abcisa xc-x na pilha  
    mov     si,bx
    add     si,cx
    push    si      ;coloca a ordenada yc+y na pilha    
    call    line
    
    mov     si,ax
    sub     si,cx
    push    si      ;coloca a abcisa xc-y na pilha          
    mov     si,bx
    sub     si,dx
    push    si      ;coloca a ordenada yc-x na pilha
    mov     si,ax
    sub     si,cx
    push    si      ;coloca a abcisa xc-y na pilha  
    mov     si,bx
    add     si,dx
    push    si      ;coloca a ordenada yc+x na pilha    
    call    line
    
    cmp     cx,dx
    jb      fim_full_circle  ;se cx (y) estah abaixo de dx (x), termina     
    jmp     stay_full       ;se cx (y) estah acima de dx (x), continua no loop
    
    
fim_full_circle:
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    pop     bp
    ret     6
;-----------------------------------------------------------------------------
;
;   funcao line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
        push    bp
        mov     bp,sp
        pushf   ;coloca os flags na pilha
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        mov     ax,[bp+10]   ; resgata os valores das coordenadas
        mov     bx,[bp+8]    ; resgata os valores das coordenadas
        mov     cx,[bp+6]    ; resgata os valores das coordenadas
        mov     dx,[bp+4]    ; resgata os valores das coordenadas
        cmp     ax,cx
        je      line2
        jb      line1
        xchg    ax,cx
        xchg    bx,dx
        jmp     line1
line2:  ; deltax=0
        cmp     bx,dx        ;subtrai dx de bx
        jb      line3
        xchg    bx,dx        ;troca os valores de bx e dx entre eles
line3:  ; dx > bx
        push    ax
        push    bx
        call    plot_xy
        cmp     bx,dx
        jne     line31
        jmp     fim_line
line31:     inc     bx
        jmp     line3
;deltax <>0
line1:
; comparar modulos de deltax e deltay sabendo que cx>ax
    ; cx > ax
        push    cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push    dx
        sub     dx,bx
        ja      line32
        neg     dx
line32:     
        mov     [deltay],dx
        pop     dx

        push    ax
        mov     ax,[deltax]
        cmp     ax,[deltay]
        pop     ax
        jb      line5

    ; cx > ax e deltax>deltay
        push    cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push    dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx

        mov     si,ax
line4:
        push    ax
        push    dx
        push    si
        sub     si,ax   ;(x-x1)
        mov     ax,[deltay]
        imul    si
        mov     si,[deltax]     ;arredondar
        shr     si,1
; se numerador (DX)>0 soma se <0 subtrai
        cmp     dx,0
        jl      ar1
        add     ax,si
        adc     dx,0
        jmp     arc1
ar1:        sub     ax,si
        sbb     dx,0
arc1:
        idiv    word [deltax]
        add     ax,bx
        pop     si
        push    si
        push    ax
        call    plot_xy
        pop     dx
        pop     ax
        cmp     si,cx
        je      fim_line
        inc     si
        jmp     line4

line5:      cmp     bx,dx
        jb      line7
        xchg    ax,cx
        xchg    bx,dx
line7:
        push    cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push    dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx



        mov     si,bx
line6:
        push    dx
        push    si
        push    ax
        sub     si,bx   ;(y-y1)
        mov     ax,[deltax]
        imul    si
        mov     si,[deltay]     ;arredondar
        shr     si,1
; se numerador (DX)>0 soma se <0 subtrai
        cmp     dx,0
        jl      ar2
        add     ax,si
        adc     dx,0
        jmp     arc2
ar2:        sub     ax,si
        sbb     dx,0
arc2:
        idiv    word [deltay]
        mov     di,ax
        pop     ax
        add     di,ax
        pop     si
        push    di
        push    si
        call    plot_xy
        pop     dx
        cmp     si,dx
        je      fim_line
        inc     si
        jmp     line6

fim_line:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        pop     bp
        ret     8

;-----------------------------------------------------------------------------
; Função desenha_retangulo
; push x1; push y1; push x2; push y2; call desenha_retangulo
; O retângulo é definido pelos pontos (x1, y1) e (x2, y2)
; A cor é definida na variável 'cor'

desenha_retangulo:
    push    bp
    mov     bp, sp
    pushf                 ; Coloca os flags na pilha
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    mov     ax, [bp + 10]  ; Resgata x1
    mov     bx, [bp + 8] ; Resgata y1
    mov     cx, [bp + 6] ; Resgata x2
    mov     dx, [bp + 4] ; Resgata y2

    ; Desenha as linhas do retângulo
    push    ax ; Coloca x1 na pilha
    push    bx ; Coloca y1 na pilha
    push    cx ; Coloca x2 na pilha
    push    bx ; Mantém y1 na pilha (reta horizontal superior)
    call    line

    push    ax ; Coloca x1 na pilha
    push    dx ; Coloca y2 na pilha
    push    cx ; Coloca x2 na pilha
    push    dx ; Mantém y2 na pilha (reta horizontal inferior)
    call    line

    push    ax ; Coloca x1 na pilha
    push    bx ; Coloca y1 na pilha
    push    ax ; Mantém x1 na pilha (reta vertical à esquerda)
    push    dx ; Coloca y2 na pilha
    call    line

    push    cx ; Coloca x2 na pilha
    push    bx ; Coloca y1 na pilha
    push    cx ; Mantém x2 na pilha (reta vertical à direita)
    push    dx ; Coloca y2 na pilha
    call    line

    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    pop     bp
    ret     8
;*******************************************************************
segment data

cor     db      branco_intenso

;   I R G B COR
;   0 0 0 0 preto
;   0 0 0 1 azul
;   0 0 1 0 verde
;   0 0 1 1 cyan
;   0 1 0 0 vermelho
;   0 1 0 1 magenta
;   0 1 1 0 marrom
;   0 1 1 1 branco
;   1 0 0 0 cinza
;   1 0 0 1 azul claro
;   1 0 1 0 verde claro
;   1 0 1 1 cyan claro
;   1 1 0 0 rosa
;   1 1 0 1 magenta claro
;   1 1 1 0 amarelo
;   1 1 1 1 branco intenso

preto           equ     0
azul            equ     1
verde           equ     2
vermelho        equ     4
branco          equ     7
branco_intenso  equ     15

modo_anterior    db      0
linha            dw      0
coluna           dw      0
deltax           dw      0
deltay           dw      0   
mens1            db      'Exercicio de Programacao de Sistemas Embarcados 1 2023/2'
mens2            db      'Patrick Catrinck  00  x  00  Computador                          Delay (03/03)'
delay            dw      20000
vx               dw      1
vy               dw      1
vy_ret           dw      0        ;velocidade em y do retangulo
p_bx             dw      320      ;posicao bola x
p_by             dw      240      ;posicao bola y
p_px             dw      600      ;posicao paddle x
p_py             dw      255      ;posicao paddle y
p_pxl            dw      610      ;posicao paddle x + largura (10)
p_pya            dw      215      ;posicao paddle y - altura  (50)
ponto_jogador    dw      0
ponto_computador dw      0
string_ponto_computador        db      "00"  
string_ponto_jogador           db      "00"  
string_tempo                   db      "0"  

;*************************************************************************
segment stack stack
            resb        512
stacktop: