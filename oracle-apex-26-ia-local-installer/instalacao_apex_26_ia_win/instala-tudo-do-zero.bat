@echo off
rem Script para INSTALAR o Oracle APEX DO ZERO no Windows
rem Cria as tablespaces necessarias, instala o APEX local e configura o ambiente.

cd /d "%~dp0"

echo ==========================================================
echo Iniciando a Instalacao Completa do Oracle APEX (Do Zero)
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

echo Subindo os containers (caso nao estejam rodando)...
call start-env.bat

echo Aguardando o banco de dados Oracle (local-26ai) ficar saudavel...
echo Isso pode levar de 5 a 10 minutos na PRIMEIRA vez que o container e criado.
:wait_db
docker inspect --format "{{.State.Health.Status}}" local-26ai | findstr "healthy" >nul
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto wait_db
)
echo Banco de dados esta pronto!

echo Criando Tablespaces e configurando o banco de dados...
call sql -name local-26ai-sys @scripts\sql\init_db.sql

echo Descompactando a versao local (%APEX_ZIP%)...
rmdir /S /Q apex 2>nul
tar -xf "%APEX_ZIP%"
rmdir /S /Q META-INF 2>nul

echo Aplicando a correcao de compatibilidade de Views...
python fix_apex_views.py

echo Instalando o APEX no banco de dados (Isso pode demorar varios minutos)...
cd apex
call sql -name local-26ai-sys @apexins.sql TBS_APEX TBS_APEX TEMP /i/
cd ..

echo Atualizando os arquivos estaticos (Imagens e CSS)...
if not exist apex-images mkdir apex-images
del /Q /S apex-images\* 2>nul
xcopy /E /I /Y apex\images\* apex-images\

echo Reiniciando o ORDS para carregar os novos arquivos estaticos...
docker restart local-26ai-ords

echo Configurando Workspace settings e ACLs de seguranca...
call sql -name local-26ai-sys @scripts\sql\post_install.sql

echo ==========================================================
echo Instalacao do APEX do zero finalizada com sucesso!
echo Acesse: http://localhost:8181/ords/apex
echo ==========================================================
pause
