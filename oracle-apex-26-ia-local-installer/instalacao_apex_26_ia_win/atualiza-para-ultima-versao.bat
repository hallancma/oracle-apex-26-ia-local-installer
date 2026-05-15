@echo off
rem Script para ATUALIZAR o Oracle APEX para a versão mais recente no Windows

cd /d "%~dp0"

echo ==========================================================
echo Iniciando o processo de atualizacao do Oracle APEX...
echo ==========================================================

echo Procurando arquivo ZIP do APEX na pasta .\versoes_apex\...
for %%I in (.\versoes_apex\*.zip) do (
    set APEX_ZIP=%%I
    goto :found_zip
)
:found_zip

if "%APEX_ZIP%"=="" (
    echo Nenhum arquivo .zip encontrado na pasta .\versoes_apex\!
    pause
    exit /b 1
)

echo Descompactando a versao local (%APEX_ZIP%)...
rmdir /S /Q apex 2>nul
tar -xf "%APEX_ZIP%"
rmdir /S /Q META-INF 2>nul

echo Aplicando a correcao de compatibilidade de Views...
python fix_apex_views.py

echo Atualizando os pacotes no banco de dados (Isso pode demorar alguns minutos)...
cd apex
call sql -name local-26ai-sys @apexins.sql TBS_APEX TBS_APEX TEMP /i/
cd ..

echo Atualizando os arquivos estaticos (Imagens e CSS)...
if not exist apex-images mkdir apex-images
del /Q /S apex-images\* 2>nul
xcopy /E /I /Y apex\images\* apex-images\

echo Reiniciando o ORDS para carregar os novos arquivos estaticos...
docker restart local-26ai-ords

echo ==========================================================
echo Atualizacao do APEX finalizada com sucesso!
echo IMPORTANTE: Limpe o cache do seu navegador (F5 / Ctrl+Shift+R)
echo antes de acessar o APEX para evitar erros de CSS ou JavaScript antigos.
echo ==========================================================
pause
