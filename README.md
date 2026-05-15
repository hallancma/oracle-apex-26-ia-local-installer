# 🚀 Oracle APEX Local Installer (Zero Config)

Bem-vindo ao **Oracle APEX Local Installer**! Este repositório contém a solução definitiva para você subir um ambiente de desenvolvimento completo do **Oracle APEX** rodando no banco **Oracle Database 23ai Free**, diretamente na sua máquina local (Windows, Mac ou Linux), com o menor esforço possível.

Adeus tutoriais gigantescos e configurações complexas no terminal! Com apenas **dois comandos**, você terá um banco de dados e o APEX rodando na porta 8181.

---

## 💡 O que este projeto faz?

Este projeto automatiza 100% o processo chato e repetitivo de configurar um ambiente Oracle local. Ele usa as imagens oficiais da Oracle via Docker para:
- Subir um container com o **Oracle Database 23ai Free**.
- Aguardar o banco de dados iniciar, configurar as *Tablespaces* otimizadas e ajustar trilhas de auditoria para não lotar o disco.
- Instalar a **versão exata do Oracle APEX** que você escolher de forma nativa e segura.
- Subir um servidor **ORDS (Oracle REST Data Services)** integrado e configurado para servir imagens e CSS.
- Aplicar correções de compatibilidade (Views) e políticas de segurança de rede (ACLs) automaticamente para permitir requisições de Web Services de dentro do APEX.

---

## 📦 Versões Suportadas do APEX

Você não está preso a uma versão específica! Este ambiente suporta a instalação (e atualização) para qualquer versão moderna do Oracle APEX. Basta fazer o download do `.zip` no site oficial da Oracle e colocar na pasta `versoes_apex`.

**Versões Homologadas e Recomendadas:**
- ✅ Oracle APEX **23.1** e **23.2**
- ✅ Oracle APEX **24.1** e **24.2**
- ✅ Oracle APEX **26ai** (e versões futuras)

---

## 💻 Estrutura do Repositório

O projeto é dividido em **três pastas**, focadas no seu Sistema Operacional. Basta entrar na pasta que corresponde ao seu computador e seguir o tutorial dentro dela:

- 🍎 `instalacao_apex_26_ia_mac/` - Otimizado para Mac (usa Colima e Docker Compose).
- 🐧 `instalacao_apex_26_ia_linux/` - Otimizado para distribuições Linux nativas (Ubuntu, Fedora, etc).
- 🪟 `instalacao_apex_26_ia_win/` - Otimizado para Windows (via Docker Desktop / WSL2), utilizando scripts `.bat`.

Cada uma dessas pastas é **totalmente independente**. Se a sua equipe inteira usa Windows, você pode simplesmente enviar a pasta `instalacao_apex_26_ia_win/` para eles!

---

## ⚡ Como Usar (Resumo)

O fluxo de uso básico se resume a 3 passos simples (leia o arquivo `TUTORIAL.md` dentro da pasta do seu sistema operacional para detalhes precisos):

1. **Baixe o APEX:** Coloque o arquivo `.zip` da versão desejada dentro da pasta `versoes_apex`.
2. **Setup Rápido:** Rode o `setup.sh` (ou .bat) para gerar as senhas seguras no arquivo `.env`.
3. **Instalação do Zero:** Rode o script `instala-tudo-do-zero` e vá tomar um café. Ele fará o resto.
4. **Pronto!** Acesse `http://localhost:8181/ords/apex`.

> Sempre que a Oracle lançar uma **versão nova** do APEX, você não precisa formatar o banco! Basta jogar o novo ZIP na pasta e rodar o script `atualiza-para-ultima-versao`. Ele vai plugar no seu banco de dados existente e fazer o upgrade de todos os pacotes PL/SQL sem você perder nenhuma aplicação já criada.

---

## 🛡️ Avisos e Segurança

- **Ambiente de Desenvolvimento:** Este repositório foi construído pensando exclusivamente no conforto do **desenvolvedor local**. As regras de segurança são relaxadas (as senhas não expiram, requisições externas são liberadas, SSL é contornado). **NUNCA exponha este container diretamente para a internet pública como um servidor de produção.**
- **Requisitos Mínimos:** Recomendamos pelo menos 16GB de RAM na máquina hospedeira para que os containers do Oracle 23ai + ORDS rodem de maneira fluida.

---

*Feito com automação pesada para você focar no que importa: programar.*
