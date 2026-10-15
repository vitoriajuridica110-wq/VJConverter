# 📄 Ecossistema VJ 4.2 — Estúdio de PDF e Imagens

Duas aplicações web gêmeas, em arquivo único cada, que processam documentos e fotos
**dentro do navegador do próprio usuário**. Hospedagem estática (GitHub + Vercel),
sem servidor e sem banco de dados.

| Arquivo | Programa | Cor | Ferramentas |
|---|---|---|---|
| `index.html` | VJ Converter — PDF | `#e5322d` | 26 |
| `img.html` | VJ IMG — Imagens | `#4d90fe` | 15 |
| `midia.html` | VJ Mídia — Vídeo e áudio | `#7c3aed` | 8 |

---

## 🛡️ Privacidade: o que é processado onde

Esta seção é o contrato com o usuário. Ela descreve o comportamento real do código.

### Processado 100% no aparelho (24 das 26 ferramentas de PDF, 13 das 13 de imagem)
Os arquivos são lidos e transformados na memória do navegador. Nada é enviado a
servidor nenhum — inclusive porque não existe servidor: o site é uma página estática.
Dá para conferir em F12 ➔ aba Rede: nenhuma requisição sai enquanto o arquivo é processado.

### ⚠️ As duas exceções, declaradas na interface
| Ferramenta | O que sai do aparelho | Controle do usuário |
|---|---|---|
| **Traduzir PDF** | O texto de todas as páginas vai para o tradutor do Google | Aviso no card, aviso na tela da ferramenta e caixa de confirmação obrigatória antes do envio |
| **Resumir com IA** | Só no modo "Google Gemini": o texto do PDF (até 28 mil caracteres) | O modo **Local** é o padrão e não envia nada; o modo nuvem exige chave própria e confirmação |

Ambas exibem, antes de enviar, um aviso explícito de não usar com peças sob segredo
de justiça, dados de crianças e adolescentes ou dados pessoais sensíveis.

### Precisa de internet na primeira vez (mas não envia seus arquivos)
- **OCR / ROC**: o reconhecimento roda no aparelho, mas o pacote do idioma português
  (~15 MB) é baixado uma vez e fica em cache.
- **Remover fundo (IA)**: o modelo é baixado uma vez e fica em cache.

### Tarja Preta Irreversível
A ferramenta *Ocultar PDF* rasteriza as páginas tarjadas e limpa os metadados, de modo
que o texto sob a tarja deixa de existir no arquivo final.

### Isolamento por usuário
Histórico de operações e chave de IA (modelo BYOK) ficam apenas no `localStorage` do
dispositivo. Um aluno nunca enxerga os dados de outro.

---

## 🚀 VJ Converter (`index.html`) — 26 ferramentas

**Automação e VJ Pro**
Fluxo de Trabalho 1-Clique (juntar + sumário + A4 + numerar + marca d'água + comprimir),
Sumário & Índice Clicável **sem limite de anexos** (quebra em várias páginas conforme
necessário, com links internos reais), Padronizador de Escala A4 e Extrator de Mídias.

**Organização e otimização**
Juntar (com arrastar e soltar), Dividir (intervalos, a cada X páginas, ou **por peso real
em MB**), Organizar páginas, Comprimir (vetorial preservando Ctrl+F, ou 3 níveis raster) e OCR.

**Conversores**
PDF ➔ Word `.docx` OpenXML (fusão de parágrafos, recuo ABNT 4 cm, destaque de Art. e §),
PDF ➔ Excel `.xlsx` (converte `R$ 1.234,56` em número somável), PDF ➔ PowerPoint,
PDF ➔ JPG, PDF ➔ Markdown, Word ➔ PDF e **Imagem ➔ PDF com filtro de nitidez**
(aceita JPG, PNG, WEBP, GIF, BMP e HEIC).

**Edição, segurança e IA**
Tarja Preta Irreversível, **Assinar com rubrica desenhada à mão** (ou carimbo de texto),
Recortar margens, Desbloquear & Sanitizar, Rodar, Marca d'água, Números de página
(`Fls. X / Y`), Comparar 2 PDFs, Resumir com IA (local ou nuvem) e Traduzir.

**Três acréscimos da versão 4.3:**
- **Comprimir até X MB** — tenta primeiro a otimização vetorial, que preserva o Ctrl+F;
  só então parte para níveis decrescentes de rasterização, pesando cada resultado de
  verdade. No máximo 7 tentativas, e avisa quando o alvo for impossível.
- **Assinatura à mão** — quadro de desenho na barra lateral; o traço é recortado e
  carimbado como PNG transparente. Continua **não sendo** assinatura ICP-Brasil, e isso
  está escrito na tela.
- **OCR com saída em PDF pesquisável** — o escaneamento continua igual, mas ganha uma
  camada de texto invisível posicionada palavra a palavra pelas coordenadas do Tesseract.
  O Ctrl+F passa a encontrar o conteúdo. É a operação mais lenta do site.

**UX**: lupa de alta resolução, banner de economia de peso, encadeamento de ferramentas
em 1 clique e painel 🩺 Motores com o estado das bibliotecas.

---

## 🖼️ VJ IMG (`img.html`) — 15 ferramentas

**Comprimir por peso-alvo** — você informa o limite do edital (`até 500 KB`) e o
programa descobre sozinho, por busca binária, a melhor qualidade que cabe nele.
Se nem na qualidade mínima couber, reduz as dimensões em passos de 20% até caber,
e avisa quando o alvo for impossível. PNG é trocado por JPG/WEBP neste modo, porque
PNG ignora o parâmetro de qualidade.

**Foto 3x4 / Documento** — gabarito biométrico sobre a foto, com linha verde no topo
da cabeça, linha vermelha no queixo, linha azul nos olhos e oval de referência. A
proporção do recorte fica travada no formato escolhido (3x4 a 300 ou 600 dpi, 5x7,
passaporte ou medidas próprias), então a foto nunca sai esticada. Saída em pixels
exatos, com fundo branco automático opcional e limite de peso opcional.

**Endireitar documento** — marque os 4 cantos do papel e a foto tirada em ângulo vira
um escaneamento de frente, por homografia com amostragem bilinear. Tem prévia ao vivo,
opção de forçar proporção A4 e o filtro de nitidez que clareia o fundo e apaga a sombra.
O quadrilátero é validado antes (nada de cantos em linha reta, cruzados ou côncavos).

Além dessas: Comprimir (preservando transparência), Redimensionar, **Recortar com alças arrastáveis**,
Converter para/de JPG, Editor de Fotos (filtros, transformar, desenhar, texto e stickers
**arrastáveis com o dedo**, moldura), Ampliar 2x/4x, **Remover Fundo**, Marca d'água,
Gerador de memes, Girar, **HTML para Imagem** (renderização real via html2canvas) e
**Desfocar rosto/placa** com intensidade proporcional à área.

**Remover Fundo** combina três motores automáticos (IA Estúdio HD / IA Rápida /
flood-fill para logos) com acabamento manual: laço poligonal com suavização de borda,
borracha, **pincel de restauração**, zoom até 400%, desfazer e **troca do fundo por cor
sólida** (branco ou azul, aceitos em foto 3x4 de documento).

---

## 🎬 VJ Mídia (`midia.html`) — 8 ferramentas

FFmpeg compilado para WebAssembly, rodando dentro do navegador: converter vídeo,
**comprimir até um peso em MB**, cortar trecho, extrair áudio, converter áudio,
remover a trilha de áudio, gerar GIF e redimensionar (incluindo recorte 9:16 para
Reels e Shorts). Nenhum arquivo sai do aparelho.

**Decisão de arquitetura, e o motivo:** é usado o núcleo de **thread única** do
ffmpeg.wasm. A versão multi-thread é mais rápida, mas exige os cabeçalhos COOP/COEP,
que isolam a origem e **quebrariam o carregamento das bibliotecas do `index.html` e do
`img.html`**. Velocidade de um programa novo não vale quebrar dois que já funcionam.

Limitações que estão escritas na própria tela, não só aqui: o núcleo tem cerca de
32 MB e é baixado na primeira vez; a conversão é mais lenta que num programa instalado
(um vídeo de 1 minuto leva de 1 a 3 minutos); e acima de uns 500 MB o navegador pode
ficar sem memória.

### Velocidade: troca de embalagem vs. recodificação

A distinção que mais importa no VJ Mídia:

| Operação | O que acontece | Tempo |
|---|---|---|
| Converter entre MP4 / MKV / MOV | Só troca a "embalagem" (`-c copy`) | **Segundos** |
| Cortar trecho (modo padrão) | Só copia o pedaço | **Segundos** |
| Remover áudio | Só descarta a trilha | **Segundos** |
| Converter para WEBM ou AVI | Refaz cada quadro | Minutos |
| Comprimir por MB, redimensionar, GIF, corte exato | Refaz cada quadro | Minutos |

MP4, MKV e MOV são caixas diferentes para o mesmo conteúdo. Trocar de uma para outra
não exige recalcular nada — e **a versão 4.3.3 corrigiu isto**: antes o programa
recodificava sempre, o que fazia um MP4→MKV de 2 minutos levar 10 minutos em vez de
poucos segundos.

O programa tenta a cópia primeiro e, se o conteúdo não couber no formato escolhido,
recodifica sozinho e avisa na tela. Tentar custa cerca de um segundo.

**Quando a recodificação é inevitável**, o tempo gira em torno de 5x a duração do vídeo
em 1080p, no núcleo de thread única. A interface mostra a estimativa antes de começar,
calculada a partir da duração e da resolução. Reduzir a resolução é o que mais acelera.

A compressão por MB calcula a taxa de bits a partir da duração (`alvo × 0,94 ÷ duração`,
descontando o áudio), então o resultado chega perto do limite sem garantir o valor exato
— e isso é dito ao usuário no fim, em vez de ser escondido.

## ⚠️ Os três programas precisam de um endereço web

Abrir os arquivos por clique duplo (`file:///C:/...`) **não funciona por inteiro**. Nesse
modo o navegador trata a página como origem `null` e proíbe a criação de *Workers*, por
segurança. Isso derruba:

- **todo o VJ Mídia** (o FFmpeg roda inteiramente dentro de um Worker);
- o **OCR** do VJ Converter;
- a **IA de remover fundo** do VJ IMG.

Não há como contornar isso pelo código — é uma regra do navegador. Os três programas
detectam a situação e mostram um aviso explicando o que fazer, em vez de falhar no meio
da operação.

Para testar antes de publicar, abra o Prompt de Comando na pasta do projeto e rode
`npx serve`; depois acesse o endereço `http://localhost:3000` que ele mostrar.

### ⚠️ A pasta `vendor/ffmpeg/` é obrigatória — não apague

O VJ Mídia **não funciona** sem estes três arquivos publicados junto com o site:

```
vendor/ffmpeg/ffmpeg.js         (4 KB)
vendor/ffmpeg/814.ffmpeg.js     (2,6 KB)  ← o Worker
vendor/ffmpeg/util.js           (3 KB)
```

**Por quê.** A biblioteca cria um *Worker* a partir do `814.ffmpeg.js`, e o navegador
proíbe criar Worker a partir de outro domínio — **inclusive em HTTPS**. Servida de um
CDN, ela falha sempre com `Failed to construct 'Worker'`.

A opção `classWorkerURL`, que existiria justamente para contornar isso, **está quebrada
na build UMD 0.12.10**: o empacotador gravou dentro do arquivo o caminho do computador
do autor da biblioteca (`file:///home/jeromewu/...`) como base da URL. Por isso ela não
é usada aqui.

A solução é servir a biblioteca do próprio domínio: ela descobre o caminho pelo
`document.currentScript.src` e encontra o Worker ao lado. O painel **🩺 Motor** verifica
ativamente se o `814.ffmpeg.js` está acessível e aponta o problema caso a pasta não
tenha subido.

Apenas o núcleo pesado (`ffmpeg-core`, ~32 MB) continua vindo do CDN — ele é baixado e
convertido em blob, o que o navegador permite, e seria grande demais para o repositório.

**Se um dia atualizar a versão do `@ffmpeg/ffmpeg`:** troque os três arquivos do
`vendor/ffmpeg/` pelos da versão nova, porque o nome do pedaço do Worker (`814`) muda
entre versões.

## 📱 Instalação como aplicativo (PWA)

`manifest.webmanifest` + `sw.js` + ícones tornam os dois programas instaláveis no
Windows, Android e iOS, e funcionais sem internet depois da primeira visita.
O Service Worker guarda apenas as páginas e as bibliotecas públicas — **nunca**
intercepta as requisições da IA ou do tradutor, e nunca vê arquivos do usuário.

> Ao publicar qualquer alteração, incremente `VERSION` no topo do `sw.js`.
> É isso que faz o navegador buscar a versão nova em vez de servir a antiga do cache.

---

## 🔐 Travamento das bibliotecas (SRI)

Todas as 12 bibliotecas estão com **versão fixa**, e não mais em `@latest`. Para
completar a proteção, rode uma vez no seu computador:

```bash
bash gerar-sri.sh
```

O script baixa cada biblioteca, calcula o hash SHA-384 e imprime as linhas `<script>`
prontas para colar nos dois HTML. Com o `integrity` preenchido, se um CDN for
comprometido o navegador se recusa a executar o código adulterado.

---

## 🗺️ Roadmap — o que ainda falta

- [ ] **GIF animado** a partir de várias imagens (precisa de uma biblioteca nova, `gif.js`).
- [ ] Trocar o fundo removido por **outra imagem**, não só por cor sólida.
- [ ] Detecção **automática** das bordas do documento no Endireitar (hoje os 4 cantos
      são marcados à mão, que é o caminho confiável em qualquer navegador).
- [ ] Detecção automática de rosto no Foto 3x4 (hoje o gabarito é encaixado à mão,
      porque a API de detecção facial não existe em todos os navegadores).
- [ ] Upscaling com IA de verdade (hoje é reamostragem de alta qualidade com realce —
      descrito assim na interface, sem prometer o que não entrega).
- [ ] Assinatura desenhada à mão no PDF (hoje o carimbo é textual; não é, e não se
      apresenta como, assinatura digital ICP-Brasil).
- [ ] Extrair as funções compartilhadas pelos dois arquivos para um `vj-core.js`,
      para que cada correção de UX não precise ser feita duas vezes.

---

## 📝 Histórico da versão 4.2

Correções de segurança e privacidade
- Declaradas na interface as duas ferramentas que enviam texto para o Google, com
  confirmação obrigatória antes do envio; o Resumo passou a ter modo local por padrão.
- Desfoque de rosto/placa agora é **proporcional e pixelizado** — o valor fixo de 14 px
  não escondia nada em fotos de celular.
- Versões de todas as bibliotecas travadas (`lucide@latest` era o caso mais grave),
  com fallback automático e script de SRI.
- Cabeçalhos HSTS, Permissions-Policy e COOP acrescentados ao `vercel.json`.

Correções de funcionamento
- **Remover fundo em lote**: cada imagem passou a ser segmentada a partir do próprio
  arquivo. Antes, da segunda imagem em diante saía o recorte da primeira, esticado.
- **HTML para Imagem**: passou a renderizar o HTML digitado; antes devolvia sempre um
  retângulo azul com texto fixo.
- **Dividir por MB**: cada parte é pesada de verdade antes de fechar. A estimativa
  anterior gerava partes acima do limite e o e-Proc recusava o upload.
- **Sumário clicável**: acabou o limite silencioso de 22 anexos, e o sumário do
  Fluxo 1-Clique ganhou os links que só a versão avulsa tinha.
- **Texto no PDF**: emojis, setas e símbolos fora do Latin-1 são convertidos antes de
  desenhar, em vez de derrubar a operação com "Erro:".
- **Sliders do editor** pararam de travar no meio do arraste.
- **Toque**: tarja preta, laço, borracha, pincel e cortina de comparação passaram a
  funcionar no celular (antes eram só mouse).
- Compressão de imagem preserva transparência; o redimensionamento parou de salvar
  bytes JPEG com extensão `.png`.
- Recorte em lote reposiciona e limita a área ao tamanho de cada imagem.
- Documentos PDF abertos para miniaturas passaram a ser liberados da memória.
- Erros no `img.html` passaram a ser avisados (antes falhavam em silêncio); um arquivo
  problemático não derruba mais o lote inteiro.
- Imagem ➔ PDF aceita PNG, WEBP e HEIC, e o **filtro de nitidez prometido no README
  passou a existir de fato** (normalização de iluminação por divisão de fundo).

---

© 2026 Ecossistema VJ. Processamento local, por padrão e por projeto.
