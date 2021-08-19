.386 
.model flat,stdcall
option casemap:none

include rally.inc

Janela proto :DWORD,:DWORD,:DWORD,:DWORD

; Macro que usamos na hora de colocar a musica no fundo
TEXT_ MACRO your_text:VARARG 
    LOCAL text_string
    .data
        text_string db your_text,0
    .code
    EXITM <addr text_string>
ENDM

.DATA
ClassName db "RallyWindowClass",0 
AppName db "RALLY-X",0         

.DATA?
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.CODE
start: 
    ; Primeira coisa que fazemos é dar play na musica
    invoke  uFMOD_PlaySong,TEXT_("musicas/musica.xm"),0,XM_FILE
    invoke GetModuleHandle, NULL                                      
    mov hInstance,eax 
    invoke GetCommandLine                   
    mov CommandLine,eax 

    ; Invocamos a janela grafica passando os parametros necessarios
    invoke Janela, hInstance, NULL, CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess, eax  
                                             
;------------------------------------------------------
; Carregamos as imagens de acordo com os numeros que 
; colocamos no arquivo rsrc.rc 
;------------------------------------------------------
carregaImagens proc              
    ; Imagens dos carrinhos vermelhos (inimigos)
    invoke LoadBitmap, hInstance, 100 ; Virado para direita
    mov DIREITA_MAU, eax
    invoke LoadBitmap, hInstance, 101 ; Virado para cima
    mov CIMA_MAU, eax
    invoke LoadBitmap, hInstance, 102 ; Virado para esquerda
    mov ESQUERDA_MAU, eax
    invoke LoadBitmap, hInstance, 103 ; Virado para baixo
    mov BAIXO_MAU, eax
    invoke LoadBitmap, hInstance, 104 ; Fumaca do carro
    mov FUMACA_IMG, eax
    ; Imagens do carrinho azul(jogador)
    invoke LoadBitmap, hInstance, 115 ; Virado para direita
    mov DIREITA, eax
    invoke LoadBitmap, hInstance, 116 ; Virado para cima
    mov CIMA, eax
    invoke LoadBitmap, hInstance, 117 ; Virado para esquerda
    mov ESQUERDA, eax
    invoke LoadBitmap, hInstance, 118 ; Virado para baixo
    mov BAIXO, eax
    ; Imagens que ficam no fundo dependendo da situacao do jogo
    invoke LoadBitmap, hInstance, 105 ; Imagem de fundo da situação 2
    mov img_fundo_lado_jogo, eax

    invoke LoadBitmap, hInstance, 109 ; Imagem de fundo da situação 1 
    mov img_inicial, eax
    invoke LoadBitmap, hInstance, 107 ; Imagem de fundo da situação 2
    mov img_fundo, eax
    invoke LoadBitmap, hInstance, 111 ; Imagem de fundo da situação 3
    mov img_fim, eax
    invoke LoadBitmap, hInstance, 110 ; Imagem de fundo da situação 4
    mov img_vitoria, eax
    invoke LoadBitmap, hInstance, 119 ; Simbolo da vida (contador de vida)
    mov VIDA, eax
    invoke LoadBitmap, hInstance, 112 ; Parede e bandeirinhas
    mov PAREDE_IMG, eax
    invoke LoadBitmap, hInstance, 114
    mov BANDEIRA_IMG, eax
    
    ret
carregaImagens endp

;------------------------------------------------------------
; Desenha a imagem de fundo de acordo com a situacao do jogo
;------------------------------------------------------------
desenharBackground proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
.if SITUACAO == 1 ; Imagem do menu inicial, onde o usurio precisa apertar enter para iniciar o jogo
    invoke SelectObject, _hMemDC2, img_inicial
    invoke BitBlt, _hMemDC, 0, 0, 1120, 960, _hMemDC2, 0, 0, SRCCOPY
.endif
.if SITUACAO == 2 ; Imagem de fundo de quando o jogo acontecendo
    invoke SelectObject, _hMemDC2, img_fundo
    invoke BitBlt, _hMemDC, 0, 0, 1120, 960, _hMemDC2, 0, 0, SRCCOPY
    invoke SelectObject, _hMemDC2, img_fundo_lado_jogo
    invoke BitBlt, _hMemDC, 840, 0, 280, 960, _hMemDC2, 0, 0, SRCCOPY
.endif
.if SITUACAO == 3 ; Imagem de quando a pessoa perde 
    invoke SelectObject, _hMemDC2, img_fim
    invoke BitBlt, _hMemDC, 0, 0, 1120, 960, _hMemDC2, 0, 0, SRCCOPY
.endif
.if SITUACAO == 4 ; Imagem de quando a pessoa vence
    invoke SelectObject, _hMemDC2, img_vitoria
    invoke BitBlt, _hMemDC, 0, 0, 1120, 960, _hMemDC2, 0, 0, SRCCOPY
.endif
    ret
desenharBackground endp

;-------------------------------------------------------
; Desenha qualquer coisa passada no parametro de acordo 
; com a posicao passada
;-------------------------------------------------------
desenhaPos proc  uses eax _hMemDC:HDC, _hMemDC2:HDC, addrCoord:dword, addrPos:dword
assume edx:ptr coord
assume ecx:ptr coord
    mov edx, addrCoord 
    mov ecx, addrPos
    mov eax, [ecx].x
    mov ebx, [ecx].y
    invoke TransparentBlt, _hMemDC, eax, ebx, [edx].x, [edx].y, _hMemDC2, 0, 0, [edx].x, [edx].y, 16777215

ret
desenhaPos endp

;------------------------------------------------------
; Coloca no edx a direcao que o carrinho esta
;------------------------------------------------------
direcaoCarrinho proc
        .if carro.direcao == D_DIREITA
            mov edx, DIREITA
        .elseif carro.direcao == D_CIMA
            mov edx, CIMA
        .elseif carro.direcao == D_ESQUERDA
            mov edx, ESQUERDA
        .elseif carro.direcao == D_BAIXO
            mov edx, BAIXO
        .endif
ret
direcaoCarrinho endp

;------------------------------------------------------
; Desenha a pontuação e melhor pontuação na tela
;------------------------------------------------------
desenharPontuacoes proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
    LOCAL rect:RECT
    
    invoke SetTextColor, _hMemDC, 0FFFFFFh
    invoke SetBkMode, _hMemDC, 00FF8800h

    invoke wsprintf, addr buffer, chr$("%d"), melhor_pontuacao
    
    mov   rect.left, 900
    mov   rect.top , 150
    mov   rect.right, 950
    mov   rect.bottom, 100

    invoke DrawText, _hMemDC, addr buffer, -1, \
         addr rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE

    invoke wsprintf, addr buffer, chr$("%d"), carro.pontuacao

    mov   rect.top , 380

    invoke DrawText, _hMemDC, addr buffer, -1, \
         addr rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE
    ret
desenharPontuacoes endp

;------------------------------------------------------
; Desenha o jogador na tela e usa a proc de direcao colocando 
; a mesma no edx a fim de saber para qual direcao deve desenhar
;------------------------------------------------------
desenharJogador proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    invoke direcaoCarrinho ; A partir do que foi colocado no edx
    invoke SelectObject, _hMemDC2, edx ; Seleciona o que esta no edx
    invoke desenhaPos, _hMemDC, _hMemDC2, addr CARRO_TAMANHO_COORD, addr carro.jogadorObj.pos ; Desenha ele de acordo com posicao, tamanho, utilizando a proc desenha pos

    ret
desenharJogador endp

;------------------------------------------------------
; Desenha os inimigos na tela de acordo com a direcao 
; que estao andando
;------------------------------------------------------
desenharInim proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    .if carro1.direcao == D_DIREITA ; Carro 1: se estiver virado para direita, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, DIREITA_MAU
    .elseif carro1.direcao == D_ESQUERDA ; Carro 1: se estiver virado para esquerda, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, ESQUERDA_MAU
    .elseif carro1.direcao == D_CIMA ; Carro 1: se estiver virado para cima, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, CIMA_MAU
    .elseif carro1.direcao == D_BAIXO ; Carro 1: se estiver virado para baixo, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, BAIXO_MAU
    .endif
    invoke desenhaPos, _hMemDC, _hMemDC2, addr INIM_TAMANHO_COORD, addr carro1.inimObj.pos

    .if carro2.direcao == D_DIREITA ; Carro 2: se estiver virado para direita, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, DIREITA_MAU
    .elseif carro2.direcao == D_ESQUERDA ; Carro 2: se estiver virado para esquerda, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, ESQUERDA_MAU
    .elseif carro2.direcao == D_CIMA ; Carro 2: se estiver virado para cima, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, CIMA_MAU
    .elseif carro2.direcao == D_BAIXO ; Carro 2: se estiver virado para baixo, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, BAIXO_MAU
    .endif
    invoke desenhaPos, _hMemDC, _hMemDC2, addr INIM_TAMANHO_COORD, addr carro2.inimObj.pos

;Carro 3:
    .if carro3.direcao == D_DIREITA ; Carro 3: se estiver virado para direita, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, DIREITA_MAU
    .elseif carro3.direcao == D_ESQUERDA ; Carro 3: se estiver virado para esquerda, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, ESQUERDA_MAU
    .elseif carro3.direcao == D_CIMA ; Carro 3: se estiver virado para cima, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, CIMA_MAU
    .elseif carro3.direcao == D_BAIXO ; Carro 3: se estiver virado para baixo, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, BAIXO_MAU
    .endif
    invoke desenhaPos, _hMemDC, _hMemDC2, addr INIM_TAMANHO_COORD, addr carro3.inimObj.pos

;Carro 4:
    .if carro4.direcao == D_DIREITA ; Carro 4: se estiver virado para direita, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, DIREITA_MAU
    .elseif carro4.direcao == D_ESQUERDA ; Carro 4: se estiver virado para esquerda, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, ESQUERDA_MAU
    .elseif carro4.direcao == D_CIMA ; Carro 4: se estiver virado para cima, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, CIMA_MAU
    .elseif carro4.direcao == D_BAIXO ; Carro 4: se estiver virado para baixo, desenha a imagem do carrinho vermelho para esse lado
        invoke SelectObject, _hMemDC2, BAIXO_MAU
    .endif
    invoke desenhaPos, _hMemDC, _hMemDC2, addr INIM_TAMANHO_COORD, addr carro4.inimObj.pos

    ret
desenharInim endp

;------------------------------------------------------
; Desenhamos a quantidade de vidas que o jogador possui na tela
;------------------------------------------------------
desenharVidas proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
    invoke SelectObject, _hMemDC2, VIDA 
    mov ebx, 0
    movzx ecx, carro.vida ; Guardamos no obj do jogador quanto de vida ele tem
    .if carro.vida == 1
        invoke TransparentBlt, _hMemDC, 990, 850,\
                VIDA_TAMANHO, VIDA_TAMANHO, _hMemDC2,\
                0, 0, VIDA_TAMANHO, VIDA_TAMANHO, 16777215
    .else
        invoke TransparentBlt, _hMemDC, 990, 850,\
                VIDA_TAMANHO, VIDA_TAMANHO, _hMemDC2,\
                0, 0, VIDA_TAMANHO, VIDA_TAMANHO, 16777215
        invoke TransparentBlt, _hMemDC, 1030, 850,\
                VIDA_TAMANHO, VIDA_TAMANHO, _hMemDC2,\
                0, 0, VIDA_TAMANHO, VIDA_TAMANHO, 16777215
    .endif

  ;  .while ebx != ecx ; Desenhamos o tanto de vida na tela de acordo com a qnt de acabamos de colocar no ecx
  ;      add eax, VIDA_TAMANHO
  ;      mul ebx
   ;     push ecx
  ;      invoke TransparentBlt, _hMemDC, eax, 920,\
  ;              VIDA_TAMANHO, VIDA_TAMANHO, _hMemDC2,\
   ;             0, 0, VIDA_TAMANHO, VIDA_TAMANHO, 16777215
  ;      pop ecx
  ;      inc ebx
   ; .endw
    ret
desenharVidas endp

;------------------------------------------------------
; Desenhamos a quantidade de gasolina que o jogador tem
;------------------------------------------------------
desenharGasolina proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC
        invoke SelectObject, _hMemDC2, img_fundo
        invoke BitBlt, _hMemDC, 855, 345, gasolina, 30, _hMemDC2, 0, 0, SRCCOPY
    ret
desenharGasolina endp

;------------------------------------------------------
; Desenhamos as coisas no mapa usando a proc desenhaPos
;------------------------------------------------------
desenharObjetos proc _hdc:HDC, _hMemDC:HDC, _hMemDC2:HDC

    invoke SelectObject, _hMemDC2, PAREDE_IMG ;paredes
    push eax
    assume eax:ptr parede
    mov eax, map.primeira_parede 
    .while eax != 0
        invoke desenhaPos, _hMemDC, _hMemDC2, addr PAREDE_TAMANHO_COORD, addr [eax].pos
        mov eax, [eax].proxima_parede
    .endw
    assume eax:nothing
    pop eax
    
    invoke SelectObject, _hMemDC2, BANDEIRA_IMG ;bandeira
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira1.bandeiraObj.pos
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira2.bandeiraObj.pos
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira3.bandeiraObj.pos
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira4.bandeiraObj.pos
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira5.bandeiraObj.pos
    invoke desenhaPos, _hMemDC, _hMemDC2, addr BANDEIRA_TAMANHO_COORD, addr bandeira6.bandeiraObj.pos

    invoke SelectObject, _hMemDC2, FUMACA_IMG ;fumaca
    invoke desenhaPos, _hMemDC, _hMemDC2, addr FUMACA_TAMANHO_COORD, addr fumaca1.fumacaObj.pos

    ret
desenharObjetos endp

;------------------------------------------------------
; Atualizamos as coisas da tela dependendo da sua situacao!
;------------------------------------------------------

atualizarTela proc
    LOCAL hMemDC:HDC
    LOCAL hMemDC2:HDC
    LOCAL hBitmap:HDC
    LOCAL hDC:HDC

    invoke BeginPaint, hWnd, ADDR paintstruct
    mov hDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC2, eax
    invoke CreateCompatibleBitmap, hDC, WINDOW_SIZE_X, WINDOW_SIZE_Y
    mov hBitmap, eax
    invoke SelectObject, hMemDC, hBitmap
    invoke desenharBackground, hDC, hMemDC, hMemDC2 ; Desenhamos o backgroud (tbm de acordo com a situacao)

    .if SITUACAO == 2 ; Se estiver no jogo
        invoke desenharObjetos, hDC, hMemDC, hMemDC2 ; Desenhamos as tudo que ocorre no mesmo
        invoke desenharJogador, hDC, hMemDC, hMemDC2
        invoke desenharInim, hDC, hMemDC, hMemDC2   
        invoke desenharVidas, hDC, hMemDC, hMemDC2
        invoke desenharGasolina, hDC, hMemDC, hMemDC2
        invoke desenharPontuacoes, hDC, hMemDC, hMemDC2
    .endif

    invoke BitBlt, hDC, 0, 0, WINDOW_SIZE_X, WINDOW_SIZE_Y, hMemDC, 0, 0, SRCCOPY
    invoke DeleteDC, hMemDC
    invoke DeleteDC, hMemDC2
    invoke DeleteObject, hBitmap
    invoke EndPaint, hWnd, ADDR paintstruct

    ret
atualizarTela endp

;-------------------------------------------------------
; Nessa proc, sabemos se dois objetos quaisquer passados 
; pelo parametro estão colidindo
;-------------------------------------------------------
estaoColidindo proc obj1Pos:coord, obj2Pos:coord, obj1Tamanho:coord, obj2Tamanho:coord 

    push eax
    push ebx
    mov eax, obj1Pos.x
    add eax, obj1Tamanho.x 
    mov ebx, obj2Pos.x
    add ebx, obj2Tamanho.x

    .if obj1Pos.x < ebx && eax > obj2Pos.x
        mov eax, obj1Pos.y
        add eax, obj1Tamanho.y
        mov ebx, obj2Pos.y
        add ebx, obj2Tamanho.y ; Somamos os tamanhos no lugar do obj para termos exatamente as cordenadas de cada obj
        .if obj1Pos.y < ebx && eax > obj2Pos.y ; Colidiram
            mov edx, TRUE ; Guardamos no edx true
        .else
            mov edx, FALSE ; Se nao, guardamos false no edx
        .endif
    .else
        mov edx, FALSE
    .endif

    pop ebx
    pop eax

    ret

estaoColidindo endp

;---------------------------------------------------------------------------
; - Verifica se um objeto vai colidir com outro, antes da colisão ocorrer
; - Isso é necessário para que o carrinho do jogador e os carrinhos inimigos 
;   não fiquem presos na parede
;---------------------------------------------------------------------------
colidir proc uses ebx direcao:BYTE, addrObj:dword
assume eax:ptr gameObject
    mov eax, addrObj

    ; Pegam-se as coordenadas do objeto
    mov ebx, [eax].pos.x
    mov tempPos.x, ebx
    mov ebx, [eax].pos.y
    mov tempPos.y, ebx

    ; Subtrai ou adiciona 8 pixels às coordenadas de acordo com a direção
    ; e o deslocamento do carro nos eixos x e y
    .if direcao == 0 ; DIREITA
        add tempPos.x, 8
    .elseif direcao == 1 ; CIMA
        add tempPos.y, -8
    .elseif direcao == 2 ; ESQUERDA
        add tempPos.x, -8
    .elseif direcao == 3 ; BAIXO
        add tempPos.y, 8
    .endif

    push eax

    ; Verifica-se se os carros estão colidindo com a parede
    assume eax:ptr parede
    mov eax, map.primeira_parede 
    .while eax != 0
        invoke estaoColidindo, tempPos, [eax].pos, CARRO_TAMANHO_COORD, PAREDE_TAMANHO_COORD
        .if edx == TRUE
            pop eax
            ret
        .endif
        mov eax, [eax].proxima_parede
    .endw

    pop eax

ret
colidir endp

;-----------------------------------------------------
; Roda a variável de "próxima direção" de cada inimigo
;-----------------------------------------------------
direcaoAleatoriaInimigo proc uses eax addrInim:dword 
assume eax:ptr inim
    mov eax, addrInim

    .if [eax].dir_aleatoria < 3
        add [eax].dir_aleatoria, 1
    .elseif [eax].dir_aleatoria == 3
        mov [eax].dir_aleatoria, 0
    .endif

ret
direcaoAleatoriaInimigo endp

;---------------------------------------------------------------------------
; Atribui uma direção aos carros inimigos, a partir de uma direção aleatória
;---------------------------------------------------------------------------
direcaoInimigo proc uses eax ebx addrInim:dword 
assume eax:ptr inim
    mov eax, addrInim

    ; Pega a direcao do carro inimigo
    mov bh, [eax].dir_aleatoria

    ; Aleatorização das direções
    .if [eax].direcao == D_CIMA || [eax].direcao == D_BAIXO
        .if [eax].dir_aleatoria == D_DIREITA || [eax].dir_aleatoria == D_ESQUERDA
            invoke colidir, [eax].dir_aleatoria, addr [eax].inimObj 
            ; Se bateu em algum objeto, a direção atribuída será a oposta
            .if edx == TRUE
                .if [eax].dir_aleatoria == D_ESQUERDA
                    mov [eax].direcao, D_DIREITA
                .else
                    mov [eax].direcao, D_ESQUERDA
                .endif
            .else
                mov bh, [eax].dir_aleatoria
                mov [eax].direcao, bh
            .endif
        .endif
    .elseif [eax].direcao == D_DIREITA || [eax].direcao == D_ESQUERDA
        .if [eax].dir_aleatoria == D_BAIXO || [eax].dir_aleatoria == D_CIMA
            invoke colidir, [eax].dir_aleatoria, addr [eax].inimObj
            ; Se bateu em algum objeto, a direção atribuída sera a oposta
            .if edx == TRUE
                .if [eax].dir_aleatoria == D_CIMA
                    mov [eax].direcao, D_BAIXO
                .else
                    mov [eax].direcao, D_CIMA
                .endif
            .else
                mov bh, [eax].dir_aleatoria
                mov [eax].direcao, bh
            .endif
        .endif
    .endif

    ; Coloca a direcao final em edx
    .if [eax].direcao == D_DIREITA
            mov edx, DIREITA_MAU
        .elseif [eax].direcao == D_CIMA
            mov edx, CIMA_MAU
        .elseif [eax].direcao == D_ESQUERDA
            mov edx, ESQUERDA_MAU
        .elseif [eax].direcao == D_BAIXO
            mov edx, BAIXO_MAU
        .endif

ret
direcaoInimigo endp

;---------------------------------------------
; Move o carro inimigo, baseado na sua direção
;---------------------------------------------
moverInimigo proc uses eax ebx ecx addrInim:dword
    assume eax:ptr inim
    mov eax, addrInim

    ; Pega-se a velocidade dos inimigos
    mov ebx, [eax].inimObj.velocidade.x
    mov ecx, [eax].inimObj.velocidade.y

    invoke colidir, [eax].direcao, addr [eax].inimObj
    .if edx == FALSE ; Se não colidiu
        .if [eax].direcao == D_CIMA
            add [eax].inimObj.pos.y, -INIM_VELOCIDADE
        .elseif [eax].direcao == D_DIREITA
            add [eax].inimObj.pos.x,  INIM_VELOCIDADE
        .elseif [eax].direcao == D_BAIXO
            add [eax].inimObj.pos.y,  INIM_VELOCIDADE
        .elseif [eax].direcao == D_ESQUERDA
            add [eax].inimObj.pos.x,  -INIM_VELOCIDADE
        .endif
    .else 
        invoke direcaoInimigo, eax
    .endif
    ; Invoca função para aleatorizar a direção do movimento do inimigo
    invoke direcaoAleatoriaInimigo, eax

    assume eax:nothing
    ret
moverInimigo endp

;------------------------------------------------------
; Função para jogador se mover, baseado na velocidade
;------------------------------------------------------
moverJogador proc uses eax

    invoke colidir, carro.direcao, addr carro.jogadorObj
    ; Se não colidiu, troca-se a posição do carro do jogador, 
    ; de acordo com sua direção
    .if edx == FALSE 
        mov eax, carro.jogadorObj.pos.x
        mov ebx, carro.jogadorObj.velocidade.x
        .if bx > 7fh
            or bx, 65280
        .endif
        add eax, ebx
        mov carro.jogadorObj.pos.x, eax
        mov eax, carro.jogadorObj.pos.y
        mov ebx, carro.jogadorObj.velocidade.y
        .if bx > 7fh 
            or bx, 65280
        .endif
        add ax, bx
        mov carro.jogadorObj.pos.y, eax
    .endif
    ret
moverJogador endp

;------------------------------------------------------
; Reposiciona um objeto qualquer em sua posição inicial
;------------------------------------------------------
reposiciona proc uses eax ebx addrObj:dword
assume ecx:ptr  gameObject
    mov ecx, addrObj

    mov eax, [ecx].posInicial.x
    mov ebx, [ecx].posInicial.y

    mov [ecx].pos.x, eax
    mov [ecx].pos.y, ebx 

    mov [ecx].velocidade.x, 0
    mov [ecx].velocidade.y, 0

ret
reposiciona endp

;---------------------------------------------------------------
; Reinicia todas as variáveis de um carro inimigo para o inicial
;---------------------------------------------------------------
restartInim proc uses eax ebx addrInim:dword
assume eax: ptr inim
    mov eax, addrInim
    
    mov bh, [eax].dir_inicial
    mov [eax].direcao, bh
    invoke reposiciona, addr [eax].inimObj

ret
restartInim endp

;-------------------------------------------------------
; Reposiciona tudo no lugar inicial quando o jogo acaba
;-------------------------------------------------------
gameOver proc
    ; Ressetta as vidas e a direção do jogador
    mov gasolina, 240
    mov carro.vida, 2
    mov carro.pontuacao, 0
    mov carro.direcao, D_CIMA
    invoke reposiciona, addr carro.jogadorObj

    ; Ressetta os carros inimigos
    invoke restartInim, addr carro1
    invoke restartInim, addr carro2
    invoke restartInim, addr carro3
    invoke restartInim, addr carro4

    ; Reposiciona as bandeirinhas,
    invoke reposiciona, addr bandeira1.bandeiraObj
    invoke reposiciona, addr bandeira2.bandeiraObj
    invoke reposiciona, addr bandeira3.bandeiraObj
    invoke reposiciona, addr bandeira4.bandeiraObj
    invoke reposiciona, addr bandeira5.bandeiraObj
    invoke reposiciona, addr bandeira6.bandeiraObj
    ; inclusive sua quantidade
    mov bandeira_quantidade, 6

    ret
gameOver endp

;-------------------------------------------------------------
; Verifica se o carro bateu em outro e faz ele perder uma vida
;-------------------------------------------------------------
colideInimigo proc addrInim:dword
assume ecx:ptr inim

    mov ecx, addrInim
    
    ; Se houve colisão entre dois carros
    invoke estaoColidindo, carro.jogadorObj.pos, [ecx].inimObj.pos, CARRO_TAMANHO_COORD, INIM_TAMANHO_COORD
    .if edx == TRUE
            ; Move o carro do jogador para o início
            mov carro.direcao, D_CIMA
            invoke reposiciona, addr carro.jogadorObj
            mov gasolina, 240

            .if carro.pontuacao > 2000
                sbb carro.pontuacao, 2000
            .endif

            dec carro.vida ; Perde uma vida
            .if carro.vida == 0 ; Se acabaram-se as vidas, o jogador perde
                invoke gameOver
                mov SITUACAO, 3 ; Perdeu
                ret
            .endif
    .endif

ret
colideInimigo endp

;--------------------------
; Da uma fumaca ao jogador
;--------------------------
darFumaca proc
    mov eax, fumaca.pode
    mov eax, 1
    ;mov fumaca.pode, eax
    ret
darFumaca endp

;---------------------------------
; Atualiza a pontuação do jogador
;---------------------------------
atualizarPontos proc
    mov eax, carro.pontuacao
    mov ebx, gasolina
    mov ecx, 1000
    add ebx, ecx
    add eax, ebx
    mov carro.pontuacao, eax
    ret
atualizarPontos endp

;--------------------------------------------------------------------------------
; Verifica se o carro coletou uma bandeira, somando nos pontos e dando uma fumaca
;--------------------------------------------------------------------------------
colideBandeira proc uses eax addrBandeira:dword
assume eax:ptr bandeira
    mov eax, addrBandeira
   
    ; Se houve colisao:
    invoke estaoColidindo, carro.jogadorObj.pos, [eax].bandeiraObj.pos, CARRO_TAMANHO_COORD, BANDEIRA_TAMANHO_COORD
        .if edx == TRUE
            ; Escodemos a bandeira,
            mov [eax].bandeiraObj.pos.x, -100 
            mov [eax].bandeiraObj.pos.y, -100
            add bandeira_quantidade, -1

            ; Damos uma fumaca ao jogador
            invoke darFumaca

            ; Somamos os pontos
            invoke atualizarPontos

            ; e vemos se pegou todas as bandeiras (ganhou)
            .if bandeira_quantidade == 0
                ; Se a pontuacao for maior que a melhor, temos um novo record
                mov eax, carro.pontuacao
                mov ebx, melhor_pontuacao
                cmp eax, ebx
                jg novoRec
                novoRec:
                    mov melhor_pontuacao, eax
                invoke gameOver
                mov SITUACAO, 4 ; Ganhou
            .endif
        .endif
ret
colideBandeira endp

;---------------------------------------------------
; Função para gerenciar e mudar as situções do jogo 
;---------------------------------------------------
gerenciadorJogo proc p:dword
        LOCAL area:RECT

        .while SITUACAO == 1 ; Menu (espera o usuário apertar [ENTER])
            invoke Sleep, 30
        .endw

        jogo: ; Verificações constantes do jogo
        .while SITUACAO == 2 ; Jogo
            invoke Sleep, 30

            ; Verifica se colidiu com algum inimigo
            invoke colideInimigo, addr carro1
            invoke colideInimigo, addr carro2 
            invoke colideInimigo, addr carro3
            invoke colideInimigo, addr carro4

            ; Verifica se coletou alguma bandeira
            push eax
            assume eax:ptr bandeira
            mov eax, map.primeira_bandeira
            .while eax != 0
                invoke colideBandeira, eax
                mov eax, [eax].proxima_bandeira
            .endw
            assume eax:nothing
            pop eax

            ; Move o jogador e os carrinhos vermelhos
            invoke moverJogador
            invoke moverInimigo, addr carro1
            invoke moverInimigo, addr carro2
            invoke moverInimigo, addr carro3
            invoke moverInimigo, addr carro4

        .endw 
    
        ; Em ambos os casos, só será preciso apertar [ENTER] para recomeçar
        .while SITUACAO == 3 || SITUACAO == 4
            invoke Sleep, 30
        .endw

        ; Volta para a função jogo
        jmp jogo
ret
gerenciadorJogo endp

;-----------------------------------------------------------
; Muda o deslocamento do carro de acordo com a direção atual
;-----------------------------------------------------------
mudaVelocidadeJogador proc direcao:BYTE

    .if direcao == D_CIMA ; Se for para cima o y diminui e o x mantem
        mov carro.jogadorObj.velocidade.y, -CARRO_VELOCIDADE
        mov carro.jogadorObj.velocidade.x, 0
        mov carro.direcao, D_CIMA
    .elseif direcao == D_BAIXO ; Se for para baixo o y aumenta e o x mantem
        mov carro.jogadorObj.velocidade.y, CARRO_VELOCIDADE
        mov carro.jogadorObj.velocidade.x, 0
        mov carro.direcao, D_BAIXO
    .elseif direcao == D_DIREITA ; Se for para direita o y mantem e o x aumenta
        mov carro.jogadorObj.velocidade.x, CARRO_VELOCIDADE
        mov carro.jogadorObj.velocidade.y, 0
        mov carro.direcao, D_DIREITA
    .elseif direcao == D_ESQUERDA ; Se for para esquerda o y mantem e o x diminui
        mov carro.jogadorObj.velocidade.x, -CARRO_VELOCIDADE
        mov carro.jogadorObj.velocidade.y, 0
        mov carro.direcao, D_ESQUERDA
    .endif

    ; Limpa o ecx
    assume ecx: nothing
    ret
mudaVelocidadeJogador endp

;------------------------------------------------------------------
; Função que desenha a fumaça na parte traseira do carro do jogador
;------------------------------------------------------------------
;mostraFumaca proc uses eax ebx addrFumaca:dword
;assume eax:ptr fumaca
;    mov eax, addrFumaca
;    mov ebx, carro.jogador
;    .if [eax].pode == 1
;        .if carro.direcao == D_DIREITA
;            mov ebx, carro.jogadorObj.pos.x
;            sbb ebx, 40
;            mov [eax].fumacaObj.pos.x, ebx
;            mov ebx, carro.jogadorObj.pos.y
;             mov [eax].fumacaObj.pos.y, ebx
;         .elseif carro.direcao == D_CIMA
;             mov ebx, carro.jogadorObj.pos.y 
;             sbb ebx, 40
;             mov [eax].fumacaObj.pos.y, ebx
;             mov ebx, carro.jogadorObj.pos.x
;             mov [eax].fumacaObj.pos.x, ebx
;         .elseif carro.direcao == D_ESQUERDA
;             mov ebx, carro.jogadorObj.pos.x 
;             add ebx, 40
;             mov [eax].fumacaObj.pos.y, ebx
;             mov ebx, carro.jogadorObj.pos.y
;             mov [eax].fumacaObj.pos.x, ebx
;         .elseif carro.direcao == D_BAIXO
;             mov ebx, carro.jogadorObj.pos.y
;             add ebx, 40
;             mov [eax].fumacaObj.pos.y, ebx
;             mov ebx, carro.jogadorObj.pos.x
;             mov [eax].fumacaObj.pos.x, ebx
;         .endif
;         mov [eax].pode, 0
;     .endif

; ret
; mostraFumaca endp

;---------------------------------------------------------------
; Cria a janela do jogo e faz os procedimentos padrão do windows
; A função principal para instanciação da janela gráfica
;---------------------------------------------------------------
Janela proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL clientRect:RECT
    LOCAL wc:WNDCLASSEX                                                
    LOCAL msg:MSG 

    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_BYTEALIGNWINDOW
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 

    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground, NULL
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName ,OFFSET ClassName 

    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 

    invoke LoadCursor, NULL,IDC_ARROW 
    mov   wc.hCursor, eax 

    invoke RegisterClassEx, addr wc

    mov clientRect.left, 0
    mov clientRect.top, 0
    mov clientRect.right, WINDOW_SIZE_X
    mov clientRect.bottom, WINDOW_SIZE_Y

    invoke AdjustWindowRect, addr clientRect, WS_CAPTION, FALSE

    mov eax, clientRect.right
    sub eax, clientRect.left
    mov ebx, clientRect.bottom
    sub ebx, clientRect.top

    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
        WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
        CW_USEDEFAULT, CW_USEDEFAULT,\
        eax, ebx, NULL, NULL, hInst, NULL 
        
    mov   hWnd,eax 
    invoke ShowWindow, hWnd, CmdShow 
    invoke UpdateWindow, hWnd

    ; A janela vai ficar recebendo mensagens constantemente e as tratando 
    .WHILE TRUE
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    ; Retorna o código de saída no eax
    mov     eax,msg.wParam 
    ret 
Janela endp

;------------------------------------------------------
; Thread que usamos pata desenhar
;------------------------------------------------------

desenharThread proc p:DWORD
    .while !over
        invoke Sleep, 10
        invoke InvalidateRect, hWnd, NULL, FALSE

    .endw

    ret
desenharThread endp

;---------------------------------
; Thread para o tempo (gasolina)
;---------------------------------

gasolinaThread proc p:DWORD
    .while !over
        invoke Sleep, 150
            .if SITUACAO == 2 
                sbb gasolina, 1

                .if gasolina == 0 ; Se acabou a gasolina, o jogador perde
                    invoke gameOver
                    mov SITUACAO, 3 ; Perdeu
                .endif
            .endif
    .endw
    ret
gasolinaThread endp

;-------------------------------------------------------------
; Trata a mensagem recebida e executa ações no estado do jogo
;-------------------------------------------------------------
WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL direcao : BYTE
    mov direcao, -1

    ; No momento em que uma mensagem for recebida, ela será processada
    .IF uMsg == WM_CREATE ; Se for a 1º vez que o jogo está sendo aberto, deve-se criar:
        ; as imagens,
        invoke carregaImagens 

        ; thread do gerenciador do jogo
        mov eax, offset gerenciadorJogo 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread1ID 
        invoke CloseHandle, eax 
        
        ; thread de desenho
        mov eax, offset desenharThread 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID
        invoke CloseHandle, eax

        ; thread da gasolina
        mov eax, offset gasolinaThread 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread3ID
        invoke CloseHandle, eax

    .ELSEIF uMsg == WM_DESTROY ; Se o usuario fechar o jogo,
        invoke PostQuitMessage,NULL ; fecha-se a guia
    
    .ELSEIF uMsg == WM_PAINT ; Se for necessário desenhar objetos,
        invoke atualizarTela ; atualizamos a tela na proc

    .ELSEIF uMsg == WM_CHAR ; Tecla do teclado é pressionada:
        .if (wParam == 13) ; se for [ENTER],
            .if SITUACAO == 1 || SITUACAO == 3 || SITUACAO == 4
                mov SITUACAO, 2 ; o jogo começa (situação = 2);
            .endif
        .endif

    .ELSEIF uMsg == WM_KEYDOWN ; Tecla do teclado é pressionada:

        .if (wParam == 77h || wParam == 57h) ; tecla 'W'
            mov direcao, D_CIMA ;setta a direção para cima

        .elseif (wParam == 61h || wParam == 41h) ; tecla 'D'
            mov direcao, D_ESQUERDA ; direção = esquerda

        .elseif (wParam == 73h || wParam == 53h) ; tecla 'S'
            mov direcao, D_BAIXO ; direção = baixo

        .elseif (wParam == 64h || wParam == 44h) ; tecla 'D'
            mov direcao, D_DIREITA ; direção = direita

; Ao apertar [CTRL], o carro do jogador solta uma fumaça atrás de si para atrasar os inimigos
;       .elseif (wParam == VK_CONTROL) ;tecla 'Ctrl'
;           assume eax:ptr fumaca ;soltamos a fumaça
;           mov eax, map.fumaca
;           invoke mostraFumaca, eax, direcao

        .endif

        .if direcao != -1 ; Se o jogador mudou de direção
            invoke mudaVelocidadeJogador, direcao
            mov direcao, -1
        .endif

    .ELSE ;se não for nenhum dos casos, faz o default
        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam
        ret 
    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

end start