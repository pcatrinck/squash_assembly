; autor: Patrick Dias Catrinck
; Trabalho de programação da disciplina de Sistemas Embarcados
;
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
        mov     ax,word[px]
        push    ax
        mov     ax,word[py]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle

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
	inc	dl	                ;avanca a coluna
    	loop    escreve1

        mov     cx,57			;numero de caracteres
    	mov     bx,0
    	mov     dh,1			;linha 0-29
    	mov     dl,0 			;coluna 0-79
	mov	byte[cor],branco

escreve2:
	call    cursor
    	mov     al,[bx+mens2]
	call    caracter
    	inc     bx	                ;proximo caracter
	inc	dl	                ;avanca a coluna
    	loop    escreve2

delay: ; Esteja atento pois talvez seja importante salvar contexto (no caso, CX, o que NÃO foi feito aqui).
        mov cx, word [velocidade] ; Carrega “velocidade” em cx (contador para loop)

del2:
        push cx ; Coloca cx na pilha para usa-lo em outro loop
        mov cx, 0800h ; Teste modificando este valor
        
del1:
        mov     byte[cor],preto
        mov     ax,[px]
        push    ax
        mov     ax,[py]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle

        mov bx, 628
        cmp [px], bx
        ;inc word [ptscontra]
        jz moveesquerda

        mov bx, 10
        cmp [px], bx
        ;inc word [ptspro]
        jz movedireita

        mov bx, 429
        cmp [py], bx
        jz movebaixo

        mov bx, 11
        cmp [py], bx
        jz movecima
        
continua:
        mov bx, [vx]
        add [px], bx
        mov bx, [vy]
        add [py], bx

        mov     byte[cor],vermelho
        mov     ax,[px]
        push    ax
        mov     ax,[py]
        push    ax
        mov     ax,10
        push    ax
        call    full_circle
        pop     cx                      ; Recupera cx da pilha
        
        loop del1                       ; No loop del1, cx é decrementado até que volte a ser zero
        
        loop del2                       ; No loop del2, cx é decrementado até que seja zero
        ret

call escreve1
call escreve2
call delay
call del1
call del2

moveesquerda:
    mov bx, -1
    mov [vx], bx
    jmp continua
movedireita:
    mov bx, 1
    mov [vx], bx
    jmp continua
movebaixo:
    mov bx, -1
    mov [vy], bx
    jmp continua
movecima:
    mov bx, 1
    mov [vy], bx
    jmp continua

sai:
    mov ah,0 ; set video mode
    mov al,[modo_anterior] ; recupera o modo anterior
    int 10h
    mov ax,4c00h
    int 21h


;delay




    
;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        push        bp
        mov         ah,2
        mov         bh,0
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
;   fun��o caracter escrito na posi��o do cursor
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
;   fun��o plot_xy
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
    mov     dx,0    ;dx ser� a vari�vel x. cx � a variavel y
    
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:              ;loop
    mov     si,di
    cmp     si,0
    jg      inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov     si,dx       ;o jl � importante porque trata-se de conta com sinal
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
    jb      fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
    jmp     stay_full       ;se cx (y) est� acima de dx (x), continua no loop
    
    
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
        push        bp
        mov         bp,sp
        pushf                        ;coloca os flags na pilha
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        mov     ax,[bp+10]   ; resgata os valores das coordenadas
        mov     bx,[bp+8]    ; resgata os valores das coordenadas
        mov     cx,[bp+6]    ; resgata os valores das coordenadas
        mov     dx,[bp+4]    ; resgata os valores das coordenadas
        cmp     ax,cx
        je      line2
        jb      line1
        xchg        ax,cx
        xchg        bx,dx
        jmp     line1
line2:      ; deltax=0
        cmp     bx,dx  ;subtrai dx de bx
        jb      line3
        xchg        bx,dx        ;troca os valores de bx e dx entre eles
line3:  ; dx > bx
        push        ax
        push        bx
        call        plot_xy
        cmp     bx,dx
        jne     line31
        jmp     fim_line
line31:     inc     bx
        jmp     line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
    ; cx > ax
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        ja      line32
        neg     dx
line32:     
        mov     [deltay],dx
        pop     dx

        push        ax
        mov     ax,[deltax]
        cmp     ax,[deltay]
        pop     ax
        jb      line5

    ; cx > ax e deltax>deltay
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx

        mov     si,ax
line4:
        push        ax
        push        dx
        push        si
        sub     si,ax   ;(x-x1)
        mov     ax,[deltay]
        imul        si
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
        idiv        word [deltax]
        add     ax,bx
        pop     si
        push        si
        push        ax
        call        plot_xy
        pop     dx
        pop     ax
        cmp     si,cx
        je      fim_line
        inc     si
        jmp     line4

line5:      cmp     bx,dx
        jb      line7
        xchg        ax,cx
        xchg        bx,dx
line7:
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx



        mov     si,bx
line6:
        push        dx
        push        si
        push        ax
        sub     si,bx   ;(y-y1)
        mov     ax,[deltax]
        imul        si
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
        idiv        word [deltay]
        mov     di,ax
        pop     ax
        add     di,ax
        pop     si
        push        di
        push        si
        call        plot_xy
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
cyan            equ     3
vermelho        equ     4
magenta         equ     5
marrom          equ     6
branco          equ     7
cinza           equ     8
azul_claro      equ     9
verde_claro     equ     10
cyan_claro      equ     11
rosa            equ     12
magenta_claro   equ     13
amarelo         equ     14
branco_intenso  equ     15

modo_anterior   db      0
linha           dw      0
coluna          dw      0
deltax          dw      0
deltay          dw      0   
mens1           db      'Exercicio de Programacao de Sistemas Embarcados 1 2023/2'
mens2           db      'Patrick Catrinck 00 x 00 Computador     Velocidade (1/3)'
ptspro          dw      0
ptscontra       dw      0
velocidade      dw      10
vx              dw      1
vy              dw      1
px              dw      320
py              dw      240
;*************************************************************************
segment stack stack
            resb        512
stacktop: