#!/usr/bin/env bash
# ============================================================================
#  gerar-sri.sh — trava as bibliotecas externas com verificação de integridade
#
#  POR QUE ISSO IMPORTA
#  Os dois programas carregam 12 bibliotecas de CDNs públicos. Se um desses
#  CDNs for invadido, o invasor passa a executar código dentro da página que
#  está lendo os seus PDFs na memória. O atributo integrity="..." resolve
#  isso: o navegador calcula o hash do arquivo baixado e se recusa a executá-lo
#  caso não bata com o valor esperado.
#
#  COMO USAR (no seu computador, na pasta do projeto):
#     bash gerar-sri.sh
#
#  O script baixa cada biblioteca, calcula o hash e imprime a linha <script>
#  completa, pronta para você substituir no index.html e no img.html.
#  Ele não altera nada sozinho — você confere e cola.
#
#  QUANDO REPETIR
#  Sempre que trocar a versão de alguma biblioteca. Se você atualizar a versão
#  e esquecer de atualizar o hash, a biblioteca para de carregar (o site avisa
#  no painel 🩺 Motores).
# ============================================================================

set -u

URLS=(
  "https://cdn.jsdelivr.net/npm/lucide@0.460.0/dist/umd/lucide.min.js"
  "https://unpkg.com/pdf-lib@1.17.1/dist/pdf-lib.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"
  "https://unpkg.com/docx@8.5.0/build/index.umd.js"
  "https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.6.0/mammoth.browser.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"
  "https://cdn.jsdelivr.net/gh/gitbrent/pptxgenjs@3.12.0/dist/pptxgen.bundle.js"
  "https://cdn.jsdelivr.net/npm/tesseract.js@5.1.1/dist/tesseract.min.js"
  "https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"
  "https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"
)

command -v curl    >/dev/null || { echo "ERRO: o comando 'curl' não está instalado."; exit 1; }
command -v openssl >/dev/null || { echo "ERRO: o comando 'openssl' não está instalado."; exit 1; }

echo
echo "Baixando ${#URLS[@]} bibliotecas e calculando os hashes..."
echo "Isso leva alguns segundos. Nenhum arquivo seu é enviado a lugar nenhum."
echo
echo "=============================================================="
echo " COPIE AS LINHAS ABAIXO PARA O index.html E O img.html"
echo "=============================================================="
echo

falhas=0
for url in "${URLS[@]}"; do
  if ! corpo=$(curl -fsSL --max-time 60 "$url"); then
    echo "<!-- FALHOU ao baixar: $url -->"
    falhas=$((falhas+1))
    continue
  fi
  hash=$(printf '%s' "$corpo" | openssl dgst -sha384 -binary | openssl base64 -A)
  echo "<script src=\"$url\" integrity=\"sha384-$hash\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"></script>"
done

echo
echo "=============================================================="
if [ "$falhas" -gt 0 ]; then
  echo " ATENÇÃO: $falhas biblioteca(s) não puderam ser baixadas."
  echo " Confira se a versão ainda existe no CDN antes de publicar."
else
  echo " Tudo certo. Substitua as linhas <script> correspondentes nos"
  echo " dois arquivos HTML, publique e abra o painel 🩺 Motores para"
  echo " confirmar que todas aparecem como ✓ OK."
fi
echo "=============================================================="
echo
echo "OBSERVAÇÃO: o Tailwind (cdn.tailwindcss.com) e os módulos de IA do"
echo "img.html geram conteúdo diferente a cada requisição, então não aceitam"
echo "integrity. Eles ficam de fora desta lista de propósito."
echo
