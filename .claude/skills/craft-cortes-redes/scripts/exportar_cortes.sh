#!/bin/bash
# Exporta cortes do FilmCraft UM PROCESSO DA CLI POR CORTE, em sequência, para a memória voltar ao
# sistema ao fim de cada um. Rode com o servidor MCP do FilmCraft fechado ou sem projeto pesado aberto
# (dois processos com a live carregada estouram 14 GB de RAM).
#
# Uso: exportar_cortes.sh <projeto.fcproj> <pasta_finalizados> <pasta_logs> id:nome [id:nome ...]
#   id = item da sequência no projeto (project_inspect), nome = arquivo final sem .mp4
# Saída: uma linha "OK nome" ou "FALHA nome" por corte; para no primeiro erro.
set -u
P=$1; F=$2; L=$3; shift 3
CLI="$(dirname "$0")/../../../../filmcraft/target/release/filmcraft-cli"
mkdir -p "$L"
for par in "$@"; do
  id=${par%%:*}; n=${par#*:}
  printf '{"id":"sequence.open","params":{"item":%s}}\n{"id":"file.exportMedia","params":{"path":"%s/%s.mp4","format":"h264","width":1080,"height":1920,"fps":30,"bitrateMode":"crf","crf":20,"audioCodec":"aac","burnCaptions":true,"loudnessLufs":-14,"range":"entire","wait":true}}\n' "$id" "$F" "$n" > "$L/exp_$n.jsonl"
  if "$CLI" --compact --project "$P" run "$L/exp_$n.jsonl" > "$L/exp_$n.log" 2>&1; then
    echo "OK $n"
  else
    echo "FALHA $n"; tail -c 300 "$L/exp_$n.log"; exit 1
  fi
done
echo "TODOS PRONTOS"
