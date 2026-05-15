# Tutorial de Instalação do Oracle APEX 24.2+ / 26ai (Local - Windows)

Bem-vindo ao pacote de instalação do APEX! Siga os passos abaixo para configurar o seu ambiente.

## 1. Preparação dos Arquivos
Antes de tudo, você precisa ter o arquivo `.zip` da versão do Oracle APEX que deseja instalar (ex: `apex_26.1.zip`).
1. Crie uma pasta chamada `versoes_apex` na raiz deste projeto (se já não existir).
2. Coloque o arquivo `.zip` do APEX dentro da pasta `versoes_apex`. O script de atualização buscará a versão mais recente lá dentro.

## 2. Configurando o Ambiente
1. Certifique-se de ter o Docker Desktop e WSL2 configurados no seu Windows.
2. Abra o seu prompt de comando/PowerShell (ou WSL) nesta pasta e execute o script de setup inicial (via WSL/GitBash):
   ```bash
   bash setup.sh
   ```
   *(Isso irá gerar automaticamente as senhas seguras no arquivo `.env` para o banco de dados).*

## 3. Instalando o Banco e o APEX do Zero (Primeira Vez)
Se esta é a **primeira vez** que você está rodando o ambiente na sua máquina, você precisa criar o banco de dados e a estrutura base.
Certifique-se de ter o arquivo `.zip` dentro de `versoes_apex` e execute:
- Dê dois cliques em **`instala-tudo-do-zero.bat`**

*Este script vai ligar os containers, esperar o banco ser gerado, criar as tablespaces, descompactar o ZIP, instalar o APEX e configurar toda a segurança automaticamente (pode demorar até 15 minutos).*

## 4. Atualizando o Oracle APEX (Futuramente)
Sempre que quiser atualizar o APEX para uma versão mais nova (sem perder os seus dados), coloque o novo ZIP na pasta `versoes_apex`, certifique-se de que o banco está rodando e execute o script:
- Dê dois cliques em **`atualiza-para-ultima-versao.bat`**

O script fará o processo de atualização de forma segura.

## 5. Como Ligar e Desligar no dia a dia
Para não consumir a memória do seu computador quando não estiver trabalhando, use os scripts:
- Para Ligar: `start-env.bat`
- Para Desligar: `stop-env.bat`

Se algum dia você quiser apagar tudo e recomeçar do zero, use o `destroy-env.bat`.

## 6. Acessando o APEX
Após a instalação, abra o seu navegador e acesse:
👉 **http://localhost:8181/ords/apex**

- **Workspace:** `INTERNAL`
- **Username:** `ADMIN`
- **Password:** (Verifique a senha `ORACLE_PASSWORD` gerada dentro do arquivo `.env` que você criou)

> **⚠️ DICA IMPORTANTE DE CACHE (TELA QUEBRADA):**
> Se a tela do APEX aparecer "quebrada" ou sem estilo de CSS após uma atualização, não se desespere! O seu navegador salvou o estilo antigo. Basta pressionar **Ctrl + F5** ou **Ctrl + Shift + R** (ou acessar em janela anônima) para forçar o carregamento do visual novo correto.

## 7. Bônus: Utilizando o "Data Reporter" localmente
O novo recurso **Data Reporter** exige autenticação moderna baseada em tokens ou cabeçalhos HTTP. Para testar e validar localmente:
1. Acesse o Workspace `INTERNAL` e vá em **Manage Instance > Feature Configuration** (ou Security).
2. Mude o *Data Reporter Authentication Scheme* para **HTTP Header Variable**.
3. No seu navegador web, instale a extensão **ModHeader**.
4. Configure na extensão um novo Request Header com o Name `OAM_REMOTE_USER` e Value igual ao seu nome de usuário de trabalho (ex: `ADMIN` ou `HALLAN`).
5. Acesse o Data Reporter. O APEX lerá o cabeçalho injetado e liberará o seu acesso diretamente!
