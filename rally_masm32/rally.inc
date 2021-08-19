
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include bibliotecas/ufmod.inc
includelib bibliotecas/ufmod.lib
include \masm32\include\masm32rt.inc
include \masm32\include\msimg32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\msimg32.lib

; Classe que é usada para definir posição e velocidade com (x, y)
coord struct 
    x dd 0      
    y dd 0
coord ends

; Classe mãe genérica com atributos que todo objeto tem
gameObject struct
    posInicial  coord <> 
    pos         coord <>
    velocidade  coord <>
gameObject ends

; Classe do jogador
jogador struct
    jogadorObj          gameObject <>
    vida                BYTE 2
    direcao             BYTE 0
    pontuacao           dd 0
jogador ends

; Classe dos carros inimigos
inim struct
    inimObj             gameObject <>
    direcao             BYTE  0
    dir_aleatoria       BYTE  0
    dir_inicial         BYTE  0
inim ends                 

; Classe da fumaça
fumaca struct
    fumacaObj      gameObject<>
    pode    BYTE 0
fumaca ends

; Classe dos blocos de parede
parede struct
    pos         coord<>
    proxima_parede   dd 0
parede ends

; Classe das bandeiras
bandeira struct
    bandeiraObj      gameObject<>
    proxima_bandeira    dd 0
bandeira ends

; Classe da parede e da bandeira iniciais
tudo struct
    primeira_parede  dd 0
    primeira_bandeira  dd 0
tudo ends

; Variáveis constantes
.CONST
    ; Tamanho da janela
    WINDOW_SIZE_X   EQU 1120
    WINDOW_SIZE_Y   EQU 960

    ; Define as direções (D, C, E e B) para facilitar compreensão,
    D_DIREITA         EQU 0 
    D_CIMA            EQU 1  
    D_ESQUERDA        EQU 2     
    D_BAIXO           EQU 3
 
    ; Define os tamanhos das imagens
    CARRO_TAMANHO     EQU 32
    INIM_TAMANHO      EQU 32
    VIDA_TAMANHO      EQU 32
    PAREDE_TAMANHO    EQU 40
    BANDEIRA_TAMANHO  EQU 16

    ; E define as velocidades dos carros
    CARRO_VELOCIDADE  EQU 6
    INIM_VELOCIDADE   EQU 6
.DATA    
    big_buffer  db 65536 dup(?)
                db 65536 dup(?)
                db 65536 dup(?)

    paintstruct        PAINTSTRUCT <>

    ; Define as coordenadas de tamanho dos elementos gráficos
    CARRO_TAMANHO_COORD      coord <32,32>
    FUMACA_TAMANHO_COORD     coord <32,32>
    INIM_TAMANHO_COORD       coord <32,32>
    PAREDE_TAMANHO_COORD     coord <40,40>
    BANDEIRA_TAMANHO_COORD   coord <16,16>

    bandeira_quantidade     dd 6
    melhor_pontuacao        dd 0
    gasolina                dd 240

    ; Inicializando as variáveis que guardarão as imagens:
    img_fundo_lado_jogo        dd 0
    img_fundo        dd 0
    img_inicial      dd 0
    img_vitoria      dd 0
    img_fim          dd 0
    PAREDE_IMG       dd 0
    BANDEIRA_IMG     dd 0
    FUMACA_IMG       dd 0

    ; Direções do carro do jogador
    DIREITA      dd 0
    CIMA         dd 0
    ESQUERDA     dd 0
    BAIXO        dd 0

    ; Direções do carro dos inimigos
    DIREITA_MAU     dd 0
    CIMA_MAU        dd 0
    ESQUERDA_MAU    dd 0
    BAIXO_MAU       dd 0

    VIDA    dd 0

    buffer              db 256 dup(?)

    over byte 0 ;

    ; Instancia o carro do jogador
    carro jogador <<<360,880>, <360,880>,  <0,0>>, 2, D_CIMA, 0> 
    
    ; Instancia a fumaca
    fumaca1 fumaca< <<-100, -100>, <-100, -100>, <0,0>>, 0>

    ; Instancia os carrinhos vermelhos (inimigos)
    carro1 inim <<<40,880>, <40,880>,  <0,0>>, D_DIREITA, 0, D_DIREITA>
    carro2 inim <<<120,880>, <120,880>,  <0,0>>, D_BAIXO,  1, D_BAIXO>
    carro3 inim <<<200,880>, <200,880>,  <0,0>>, D_ESQUERDA, 2, D_ESQUERDA>
    carro4 inim <<<280,880>, <280,880>,  <0,0>>, D_CIMA,  3, D_CIMA>

    ; Instancia os blocos de parede
    parede0 parede  <<0, 0>, 0>
    parede1 parede  <<40, 0>, OFFSET parede0>
    parede2 parede  <<80, 0>, OFFSET parede1>
    parede3 parede  <<120, 0>, OFFSET parede2>
    parede4 parede  <<160, 0>, OFFSET parede3>
    parede5 parede  <<200,0>, OFFSET parede4>
    parede6 parede  <<240,0>, OFFSET parede5>
    parede7 parede  <<280,0>, OFFSET parede6>
    parede8 parede  <<320,0>, OFFSET parede7>
    parede9 parede  <<360,0>, OFFSET parede8>
    parede10 parede  <<400,0>, OFFSET parede9>
    parede11 parede  <<440,0>, OFFSET parede10>
    parede12 parede  <<480,0>, OFFSET parede11>
    parede13 parede  <<520,0>, OFFSET parede12>
    parede14 parede  <<560,0>, OFFSET parede13>
    parede15 parede  <<600,0>, OFFSET parede14>
    parede16 parede  <<640,0>, OFFSET parede15>
    parede17 parede  <<680,0>, OFFSET parede16>
    parede18 parede  <<720,0>, OFFSET parede17>
    parede19 parede  <<760,0>, OFFSET parede18>
    parede20 parede  <<800,0>, OFFSET parede19>
    paredeBaixo0 parede  <<0, 920>, OFFSET parede20>
    paredeBaixo1 parede  <<40, 920>, OFFSET paredeBaixo0>
    paredeBaixo2 parede  <<80,920>, OFFSET paredeBaixo1>
    paredeBaixo3 parede  <<120,920>, OFFSET paredeBaixo2>
    paredeBaixo4 parede  <<160,920>, OFFSET paredeBaixo3>
    paredeBaixo5 parede  <<200,920>, OFFSET paredeBaixo4>
    paredeBaixo6 parede  <<240,920>, OFFSET paredeBaixo5>
    paredeBaixo7 parede  <<280,920>, OFFSET paredeBaixo6>
    paredeBaixo8 parede  <<320,920>, OFFSET paredeBaixo7>
    paredeBaixo9 parede  <<360,920>, OFFSET paredeBaixo8>
    paredeBaixo10 parede  <<400,920>, OFFSET paredeBaixo9>
    paredeBaixo11 parede  <<440,920>, OFFSET paredeBaixo10>
    paredeBaixo12 parede  <<480,920>, OFFSET paredeBaixo11>
    paredeBaixo13 parede  <<520,920>, OFFSET paredeBaixo12>
    paredeBaixo14 parede  <<560,920>, OFFSET paredeBaixo13>
    paredeBaixo15 parede  <<600,920>, OFFSET paredeBaixo14>
    paredeBaixo16 parede  <<640,920>, OFFSET paredeBaixo15>
    paredeBaixo17 parede  <<680,920>, OFFSET paredeBaixo16>
    paredeBaixo18 parede  <<720,920>, OFFSET paredeBaixo17>
    paredeBaixo19 parede  <<760,920>, OFFSET paredeBaixo18>
    paredeBaixo20 parede  <<800,920>, OFFSET paredeBaixo19>
    paredeEsquerda2 parede  <<0,40>, OFFSET paredeBaixo20>
    paredeEsquerda3 parede  <<0,80>, OFFSET paredeEsquerda2>
    paredeEsquerda4 parede  <<0,120>, OFFSET paredeEsquerda3>
    paredeEsquerda5 parede  <<0,160>, OFFSET paredeEsquerda4>
    paredeEsquerda6 parede  <<0,200>, OFFSET paredeEsquerda5>
    paredeEsquerda7 parede  <<0,240>, OFFSET paredeEsquerda6>
    paredeEsquerda8 parede  <<0,280>, OFFSET paredeEsquerda7>
    paredeEsquerda9 parede  <<0,320>, OFFSET paredeEsquerda8>
    paredeEsquerda10 parede <<0,360>, OFFSET paredeEsquerda9>
    paredeEsquerda11 parede <<0,400>, OFFSET paredeEsquerda10>
    paredeEsquerda12 parede <<0,440>, OFFSET paredeEsquerda11>
    paredeEsquerda13 parede <<0,480>, OFFSET paredeEsquerda12>
    paredeEsquerda14 parede  <<0,520>, OFFSET paredeEsquerda13>
    paredeEsquerda15 parede  <<0,560>, OFFSET paredeEsquerda14>
    paredeEsquerda16 parede  <<0,600>, OFFSET paredeEsquerda15>
    paredeEsquerda17 parede  <<0,640>, OFFSET paredeEsquerda16>
    paredeEsquerda18 parede  <<0,680>, OFFSET paredeEsquerda17>
    paredeEsquerda19 parede  <<0,720>, OFFSET paredeEsquerda18>
    paredeEsquerda20 parede  <<0,760>, OFFSET paredeEsquerda19>
    paredeEsquerda21 parede  <<0,800>, OFFSET paredeEsquerda20>
    paredeEsquerda22 parede  <<0,840>, OFFSET paredeEsquerda21>
    paredeEsquerda23 parede  <<0,880>, OFFSET paredeEsquerda22>
    paredeDireita1 parede  <<800,40>, OFFSET paredeEsquerda23>
    paredeDireita2 parede  <<800,80>, OFFSET paredeDireita1>
    paredeDireita3 parede  <<800,120>, OFFSET paredeDireita2>
    paredeDireita4 parede  <<800,160>, OFFSET paredeDireita3>
    paredeDireita5 parede  <<800,200>, OFFSET paredeDireita4>
    paredeDireita6 parede  <<800,240>, OFFSET paredeDireita5>
    paredeDireita7 parede  <<800,280>, OFFSET paredeDireita6>
    paredeDireita8 parede  <<800,320>, OFFSET paredeDireita7>
    paredeDireita9 parede  <<800,360>, OFFSET paredeDireita8>
    paredeDireita10 parede <<800,400>, OFFSET paredeDireita9>
    paredeDireita11 parede <<800,440>, OFFSET paredeDireita10>
    paredeDireita12 parede <<800,480>, OFFSET paredeDireita11>
    paredeDireita13 parede <<800,520>, OFFSET paredeDireita12>
    paredeDireita14 parede  <<800,560>, OFFSET paredeDireita13>
    paredeDireita15 parede  <<800,600>, OFFSET paredeDireita14>
    paredeDireita16 parede  <<800,640>, OFFSET paredeDireita15>
    paredeDireita17 parede  <<800,680>, OFFSET paredeDireita16>
    paredeDireita18 parede  <<800,720>, OFFSET paredeDireita17>
    paredeDireita19 parede  <<800,760>, OFFSET paredeDireita18>
    paredeDireita20 parede  <<800,800>, OFFSET paredeDireita19>
    paredeDireita21 parede  <<800,840>, OFFSET paredeDireita20>
    paredeDireita22 parede  <<800,880>, OFFSET paredeDireita21>
    paredeInterna0 parede  <<80,80>, OFFSET paredeDireita22>
    paredeInterna1 parede  <<120,80>, OFFSET paredeInterna0>
    paredeInterna2 parede  <<160,80>, OFFSET paredeInterna1>
    paredeInterna3 parede  <<200,80>, OFFSET paredeInterna2>
    paredeInterna4 parede  <<240,80>, OFFSET paredeInterna3>
    paredeInterna5 parede  <<320,80>, OFFSET paredeInterna4>
    paredeInterna6 parede  <<360,80>, OFFSET paredeInterna5>
    paredeInterna7 parede  <<440,80>, OFFSET paredeInterna6>
    paredeInterna8 parede  <<480,80>, OFFSET paredeInterna7>
    paredeInterna9 parede  <<560,80>, OFFSET paredeInterna8>
    paredeInterna10 parede  <<600,80>, OFFSET paredeInterna9>
    paredeInterna11 parede  <<640,80>, OFFSET paredeInterna10>
    paredeInterna12 parede  <<720,80>, OFFSET paredeInterna11>
    paredeInterna13 parede  <<760,80>, OFFSET paredeInterna12>
    paredeInterna14 parede  <<80,120>, OFFSET paredeInterna13>
    paredeInterna15 parede  <<120,120>, OFFSET paredeInterna14>
    paredeInterna16 parede  <<160,120>, OFFSET paredeInterna15>
    paredeInterna17 parede  <<200,120>, OFFSET paredeInterna16>
    paredeInterna18 parede  <<240,120>, OFFSET paredeInterna17>
    paredeInterna19 parede  <<440,120>, OFFSET paredeInterna18>
    paredeInterna20 parede  <<480,120>, OFFSET paredeInterna19>
    paredeInterna21 parede  <<560,120>, OFFSET paredeInterna20>
    paredeInterna22 parede  <<600,120>, OFFSET paredeInterna21>
    paredeInterna23 parede  <<640,120>, OFFSET paredeInterna22>
    paredeInterna24 parede  <<720,120>, OFFSET paredeInterna23>
    paredeInterna25 parede  <<760,120>, OFFSET paredeInterna24>
    paredeInterna26 parede  <<200,160>, OFFSET paredeInterna25>
    paredeInterna27 parede  <<240,160>, OFFSET paredeInterna26>
    paredeInterna28 parede  <<320,160>, OFFSET paredeInterna27>
    paredeInterna29 parede  <<360,160>, OFFSET paredeInterna28>
    paredeInterna30 parede  <<400,160>, OFFSET paredeInterna29>
    paredeInterna31 parede  <<440,160>, OFFSET paredeInterna30>
    paredeInterna32 parede  <<480,160>, OFFSET paredeInterna31>
    paredeInterna33 parede  <<80,200>, OFFSET paredeInterna32>
    paredeInterna34 parede  <<120,200>, OFFSET paredeInterna33>
    paredeInterna35 parede  <<200,200>, OFFSET paredeInterna34>
    paredeInterna36 parede  <<240,200>, OFFSET paredeInterna35>
    paredeInterna37 parede  <<440,200>, OFFSET paredeInterna36>
    paredeInterna38 parede  <<480,200>, OFFSET paredeInterna37>
    paredeInterna39 parede  <<560,200>, OFFSET paredeInterna38>
    paredeInterna40 parede  <<600,200>, OFFSET paredeInterna39>
    paredeInterna41 parede  <<640,200>, OFFSET paredeInterna40>
    paredeInterna42 parede  <<680,200>, OFFSET paredeInterna41>
    paredeInterna43 parede  <<720,200>, OFFSET paredeInterna42>
    paredeInterna44 parede  <<80,240>, OFFSET paredeInterna43>
    paredeInterna45 parede  <<120,240>, OFFSET paredeInterna44>
    paredeInterna46 parede  <<200,240>, OFFSET paredeInterna45>
    paredeInterna47 parede  <<240,240>, OFFSET paredeInterna46>
    paredeInterna48 parede  <<320,240>, OFFSET paredeInterna47>
    paredeInterna49 parede  <<360,240>, OFFSET paredeInterna48>
    paredeInterna50 parede  <<440,240>, OFFSET paredeInterna49>
    paredeInterna51 parede  <<480,240>, OFFSET paredeInterna50>
    paredeInterna52 parede  <<560,240>, OFFSET paredeInterna51>
    paredeInterna53 parede  <<600,240>, OFFSET paredeInterna52>
    paredeInterna54 parede  <<640,240>, OFFSET paredeInterna53>
    paredeInterna55 parede  <<680,240>, OFFSET paredeInterna54>
    paredeInterna56 parede  <<720,240>, OFFSET paredeInterna55>
    paredeInterna57 parede  <<40,320>, OFFSET paredeInterna56>
    paredeInterna58 parede  <<80,320>, OFFSET paredeInterna57>
    paredeInterna59 parede  <<120,320>, OFFSET paredeInterna58>
    paredeInterna60 parede  <<160,320>, OFFSET paredeInterna59>
    paredeInterna61 parede  <<200,320>, OFFSET paredeInterna60>
    paredeInterna62 parede  <<280,320>, OFFSET paredeInterna61>
    paredeInterna63 parede  <<320,320>, OFFSET paredeInterna62>
    paredeInterna64 parede  <<400,320>, OFFSET paredeInterna63>
    paredeInterna65 parede  <<440,320>, OFFSET paredeInterna64>
    paredeInterna66 parede  <<480,320>, OFFSET paredeInterna65>
    paredeInterna67 parede  <<520,320>, OFFSET paredeInterna66>
    paredeInterna68 parede  <<600,320>, OFFSET paredeInterna67>
    paredeInterna69 parede  <<640,320>, OFFSET paredeInterna68>
    paredeInterna70 parede  <<680,320>, OFFSET paredeInterna69>
    paredeInterna71 parede  <<720,320>, OFFSET paredeInterna70>
    paredeInterna72 parede  <<40,360>, OFFSET paredeInterna71>
    paredeInterna73 parede  <<80,360>, OFFSET paredeInterna72>
    paredeInterna74 parede  <<120,360>, OFFSET paredeInterna73>
    paredeInterna75 parede  <<160,360>, OFFSET paredeInterna74>
    paredeInterna76 parede  <<200,360>, OFFSET paredeInterna75>
    paredeInterna77 parede  <<280,360>, OFFSET paredeInterna76>
    paredeInterna78 parede  <<320,360>, OFFSET paredeInterna77>
    paredeInterna79 parede  <<400,360>, OFFSET paredeInterna78>
    paredeInterna80 parede  <<440,360>, OFFSET paredeInterna79>
    paredeInterna81 parede  <<480,360>, OFFSET paredeInterna80>
    paredeInterna82 parede  <<520,360>, OFFSET paredeInterna81>
    paredeInterna83 parede  <<600,360>, OFFSET paredeInterna82>
    paredeInterna84 parede  <<640,360>, OFFSET paredeInterna83>
    paredeInterna85 parede  <<680,360>, OFFSET paredeInterna84>
    paredeInterna86 parede  <<720,360>, OFFSET paredeInterna85>
    paredeInterna87 parede  <<80,440>, OFFSET paredeInterna86>
    paredeInterna88 parede  <<120,440>, OFFSET paredeInterna87>
    paredeInterna89 parede  <<200,440>, OFFSET paredeInterna88>
    paredeInterna90 parede  <<240,440>, OFFSET paredeInterna89>
    paredeInterna91 parede  <<280,440>, OFFSET paredeInterna90>
    paredeInterna92 parede  <<360,440>, OFFSET paredeInterna91>
    paredeInterna93 parede  <<400,440>, OFFSET paredeInterna92>
    paredeInterna94 parede  <<440,440>, OFFSET paredeInterna93>
    paredeInterna95 parede  <<520,440>, OFFSET paredeInterna94>
    paredeInterna96 parede  <<560,440>, OFFSET paredeInterna95> 
    paredeInterna97 parede  <<600,440>, OFFSET paredeInterna96>
    paredeInterna98 parede  <<640,440>, OFFSET paredeInterna97>  
    paredeInterna99 parede  <<720, 440>, OFFSET paredeInterna98>
    paredeInterna100 parede <<360,40>, OFFSET paredeInterna99>
    paredeInterna101 parede <<80,480>, OFFSET paredeInterna100>
    paredeInterna102 parede <<120,480>, OFFSET paredeInterna101>
    paredeInterna103 parede <<200,480>, OFFSET paredeInterna102>
    paredeInterna104 parede <<240,480>, OFFSET paredeInterna103> 
    paredeInterna105 parede <<280,480>, OFFSET paredeInterna104>
    paredeInterna106 parede <<360,480>, OFFSET paredeInterna105>
    paredeInterna107 parede <<400,480>, OFFSET paredeInterna106> 
    paredeInterna108 parede <<440,480>, OFFSET paredeInterna107>
    paredeInterna109 parede <<520,480>, OFFSET paredeInterna108>
    paredeInterna110 parede <<560,480>, OFFSET paredeInterna109>
    paredeInterna111 parede <<600,480>, OFFSET paredeInterna110>   
    paredeInterna112 parede <<640,480>, OFFSET paredeInterna111>
    paredeInterna113 parede <<720,480>, OFFSET paredeInterna112>
    paredeInterna114 parede <<320,40>, OFFSET paredeInterna113>
    paredeInterna115 parede <<80,560>, OFFSET paredeInterna114>
    paredeInterna116 parede <<120,560>, OFFSET paredeInterna115>
    paredeInterna117 parede <<160,560>, OFFSET paredeInterna116>
    paredeInterna118 parede <<200,560>, OFFSET paredeInterna117> 
    paredeInterna119 parede <<240,560>, OFFSET paredeInterna118>
    paredeInterna120 parede <<280,560>, OFFSET paredeInterna119>
    paredeInterna121 parede <<320,560>, OFFSET paredeInterna120>
    paredeInterna122 parede <<400,560>, OFFSET paredeInterna121>   
    paredeInterna123 parede <<440,560>, OFFSET paredeInterna122>
    paredeInterna124 parede <<520,560>, OFFSET paredeInterna123>
    paredeInterna125 parede <<560,560>, OFFSET paredeInterna124>
    paredeInterna126 parede <<640,560>, OFFSET paredeInterna125>
    paredeInterna127 parede <<680,560>, OFFSET paredeInterna126>
    paredeInterna128 parede <<720,560>, OFFSET paredeInterna127>
    paredeInterna129 parede <<80,600>, OFFSET paredeInterna128>
    paredeInterna130 parede <<120,600>, OFFSET paredeInterna129> 
    paredeInterna131 parede <<160,600>, OFFSET paredeInterna130>
    paredeInterna132 parede <<200,600>, OFFSET paredeInterna131>
    paredeInterna133 parede <<240,600>, OFFSET paredeInterna132> 
    paredeInterna134 parede <<280,600>, OFFSET paredeInterna133>
    paredeInterna135 parede <<320,600>, OFFSET paredeInterna134>
    paredeInterna136 parede <<400,600>, OFFSET paredeInterna135>
    paredeInterna137 parede <<440,600>, OFFSET paredeInterna136> 
    paredeInterna138 parede <<520,600>, OFFSET paredeInterna137>
    paredeInterna139 parede <<560,600>, OFFSET paredeInterna138>
    paredeInterna140 parede <<640,600>, OFFSET paredeInterna139> 
    paredeInterna141 parede <<680,600>, OFFSET paredeInterna140>
    paredeInterna142 parede <<720,600>, OFFSET paredeInterna141>
    paredeInterna143 parede <<400,640>, OFFSET paredeInterna142>
    paredeInterna144 parede <<440,640>, OFFSET paredeInterna143> 
    paredeInterna145 parede <<520,640>, OFFSET paredeInterna144>
    paredeInterna146 parede <<560,640>, OFFSET paredeInterna145>
    paredeInterna147 parede <<440,640>, OFFSET paredeInterna146> 
    paredeInterna148 parede <<80,680>, OFFSET paredeInterna147>
    paredeInterna149 parede <<120,680>, OFFSET paredeInterna148>
    paredeInterna150 parede <<200,680>, OFFSET paredeInterna149>
    paredeInterna151 parede <<240,680>, OFFSET paredeInterna150> 
    paredeInterna152 parede <<280,680>, OFFSET paredeInterna151>
    paredeInterna153 parede <<320,680>, OFFSET paredeInterna152>
    paredeInterna154 parede <<400,680>, OFFSET paredeInterna153>
    paredeInterna155 parede <<440,680>, OFFSET paredeInterna154> 
    paredeInterna156 parede <<520,680>, OFFSET paredeInterna155>
    paredeInterna157 parede <<560,680>, OFFSET paredeInterna156>
    paredeInterna158 parede <<640,680>, OFFSET paredeInterna157> 
    paredeInterna159 parede <<680,680>, OFFSET paredeInterna158>
    paredeInterna160 parede <<720,680>, OFFSET paredeInterna159>
    paredeInterna161 parede <<80,720>, OFFSET paredeInterna160>
    paredeInterna162 parede <<120,720>, OFFSET paredeInterna161> 
    paredeInterna163 parede <<400,720>, OFFSET paredeInterna162>
    paredeInterna164 parede <<440,720>, OFFSET paredeInterna163>            
    paredeInterna165 parede <<640,720>, OFFSET paredeInterna164>
    paredeInterna166 parede <<680,720>, OFFSET paredeInterna165> 
    paredeInterna167 parede <<720,720>, OFFSET paredeInterna166>
    paredeInterna168 parede <<80,760>, OFFSET paredeInterna167>      
    paredeInterna169 parede <<120,760>, OFFSET paredeInterna168>   
    paredeInterna170 parede <<200,760>, OFFSET paredeInterna169>   
    paredeInterna171 parede <<280,760>, OFFSET paredeInterna170>   
    paredeInterna172 parede <<320,760>, OFFSET paredeInterna171>   
    paredeInterna173 parede <<520,760>, OFFSET paredeInterna172>   
    paredeInterna174 parede <<560,760>, OFFSET paredeInterna173>   
    paredeInterna175 parede <<480,800>, OFFSET paredeInterna174>   
    paredeInterna176 parede <<520,800>, OFFSET paredeInterna175>   
    paredeInterna177 parede <<560,800>, OFFSET paredeInterna176>   
    paredeInterna178 parede <<640,800>, OFFSET paredeInterna177>   
    paredeInterna179 parede <<720,520>, OFFSET paredeInterna178>   
    paredeInterna180 parede <<720,800>, OFFSET paredeInterna179>   
    paredeInterna181 parede <<80,840>, OFFSET paredeInterna180>
    paredeInterna182 parede <<160,840>, OFFSET paredeInterna181>      
    paredeInterna183 parede <<240,840>, OFFSET paredeInterna182>   
    paredeInterna184 parede <<320,840>, OFFSET paredeInterna183>   
    paredeInterna185 parede <<400,840>, OFFSET paredeInterna184>   
    paredeInterna186 parede <<480,840>, OFFSET paredeInterna185>   
    paredeInterna187 parede <<520,840>, OFFSET paredeInterna186>   
    paredeInterna188 parede <<560,840>, OFFSET paredeInterna187>   
    paredeInterna189 parede <<640,840>, OFFSET paredeInterna188>   
    paredeInterna190 parede <<720,760>, OFFSET paredeInterna189>   
    paredeInterna191 parede <<720,840>, OFFSET paredeInterna190>   
    paredeInterna192 parede <<80,880>, OFFSET paredeInterna191>   
    paredeInterna193 parede <<160,880>, OFFSET paredeInterna192>   
    paredeInterna194 parede <<240,880>, OFFSET paredeInterna193>
    paredeInterna195 parede <<320,880>, OFFSET paredeInterna194>   
    paredeInterna196 parede <<400,880>, OFFSET paredeInterna195>   
    paredeInterna197 parede <<640,880>, OFFSET paredeInterna196> 
    paredeInterna198 parede <<680,0>, OFFSET paredeInterna197> 
    paredeInterna199 parede <<720,0>, OFFSET paredeInterna198> 
    paredeInterna200 parede <<560,160>, OFFSET paredeInterna199> 
    paredeInterna201 parede <<600,160>, OFFSET paredeInterna200>                       
    paredeInterna202 parede <<640,160>, OFFSET paredeInterna201> 
    paredeInterna203 parede <<400,400>, OFFSET paredeInterna202>
    paredeInterna204 parede <<440,400>, OFFSET paredeInterna203>
    
    ; Instancia as bandeirinhas
    bandeira1 bandeira <<<170, 170>, <170, 180>, <0,0>>, 0>
    bandeira2 bandeira< <<410, 290>, <410, 290>, <0,0>>, OFFSET bandeira1>
    bandeira3 bandeira< <<690, 170>, <690, 170>, <0,0>>, OFFSET bandeira2>
    bandeira4 bandeira< <<610, 560>, <610, 560>, <0,0>>, OFFSET bandeira3>
    bandeira5 bandeira< <<250, 650>, <250, 650>, <0,0>>, OFFSET bandeira4>
    bandeira6 bandeira< <<770, 890>, <770, 890>, <0,0>>, OFFSET bandeira5>

    ; Instancia as parede e bandeira iniciais
    map tudo <OFFSET paredeInterna204, OFFSET bandeira6>

    ; Instancia variavel de coordenadas
    tempPos coord <0, 0>
    
    ; Instancia variavel que auxilia na troca de modo (menu, jogo e game over)
    SITUACAO      BYTE 1

; Instancia as threads
.DATA?
    hWnd HWND ?
    thread1ID DWORD ?
    thread2ID DWORD ?
    thread3ID DWORD ?