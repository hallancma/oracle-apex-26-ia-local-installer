#!/bin/bash
# Script para ATUALIZAR o Oracle APEX para a versão mais recente
# (Pode ser rodado a qualquer momento para atualizar o APEX sem perder os dados do banco)

set -e

# Garante que o script seja executado a partir do seu próprio diretório
cd "$(dirname "$0")"

source ./scripts/util/load_env.sh

echo "=========================================================="
echo "🚀 Iniciando o processo de atualização do Oracle APEX..."
echo "=========================================================="

echo "📦 Procurando arquivo ZIP do APEX na pasta ./versoes_apex/..."
APEX_ZIP=$(ls -1 ./versoes_apex/*.zip 2>/dev/null | head -n 1)

if [ -z "$APEX_ZIP" ]; then
    echo "❌ Nenhum arquivo .zip encontrado na pasta ./versoes_apex/!"
    exit 1
fi

echo "📦 Descompactando a versão local ($APEX_ZIP)..."
rm -rf ./apex || true

unzip -q "$APEX_ZIP"
rm -rf ./META-INF || true

echo "🛠 Aplicando a correção de compatibilidade de Views..."
python3 fix_apex_views.py

echo "⚙️  Atualizando os pacotes no banco de dados (Isso pode demorar alguns minutos)..."
cd ./apex || exit 1
sql -name "$DB_CONN_NAME" @apexins.sql TBS_APEX TBS_APEX TEMP /i/
cd ..

echo "🖼️  Atualizando os arquivos estáticos (Imagens e CSS)..."
mkdir -p ./apex-images
rm -rf ./apex-images/* || true
cp -r ./apex/images/* ./apex-images/

echo "🔄 Reiniciando o ORDS para carregar os novos arquivos estáticos..."
docker restart local-26ai-ords || true

echo "=========================================================="
echo "✅ Atualização do APEX finalizada com sucesso!"
echo "⚠️  IMPORTANTE: Limpe o cache do seu navegador (F5 / Ctrl+Shift+R)"
echo "   antes de acessar o APEX para evitar erros de CSS ou JavaScript antigos."
echo "=========================================================="
