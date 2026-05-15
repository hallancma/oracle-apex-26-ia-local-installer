#!/bin/bash
# Script para INSTALAR o Oracle APEX DO ZERO
# Cria as tablespaces necessárias, instala o APEX local e configura o ambiente.

set -e

# Garante que o script seja executado a partir do seu próprio diretório
cd "$(dirname "$0")"

source ./scripts/util/load_env.sh
source ./scripts/util/get_ws_settings.sh

echo "=========================================================="
echo "🚀 Iniciando a Instalação Completa do Oracle APEX (Do Zero)"
echo "=========================================================="

echo "📦 Procurando arquivo ZIP do APEX na pasta ./versoes_apex/..."
APEX_ZIP=$(ls -1 ./versoes_apex/*.zip 2>/dev/null | head -n 1)

if [ -z "$APEX_ZIP" ]; then
    echo "❌ Nenhum arquivo .zip encontrado na pasta ./versoes_apex/!"
    exit 1
fi

echo "🟢 Subindo os containers (caso não estejam rodando)..."
./start-env.sh

echo "⏳ Aguardando o banco de dados Oracle (local-26ai) ficar saudável..."
echo "Isso pode levar de 5 a 10 minutos na PRIMEIRA vez que o container é criado."
until docker inspect --format "{{.State.Health.Status}}" local-26ai 2>/dev/null | grep -q "healthy"; do
  echo -n "."
  sleep 5
done
echo ""
echo "✅ Banco de dados está pronto!"

echo "🛠️ Criando Tablespaces e configurando o banco de dados..."
# otimização baseada no blog do Connor McDonald
sql -name "$DB_CONN_NAME" <<SQL
create tablespace audit_trail 
  datafile 'audit01.dbf' 
  size 20m 
  autoextend on next 2m;

begin
dbms_audit_mgmt.set_audit_trail_location(
   audit_trail_type=>dbms_audit_mgmt.audit_trail_aud_std,
   audit_trail_location_value=>'AUDIT_TRAIL');
end;
/

begin
dbms_audit_mgmt.set_audit_trail_location(
   audit_trail_type=>dbms_audit_mgmt.audit_trail_fga_std,
   audit_trail_location_value=>'AUDIT_TRAIL');
end;
/

begin
dbms_audit_mgmt.set_audit_trail_location(
   audit_trail_type=>dbms_audit_mgmt.audit_trail_db_std,
   audit_trail_location_value=>'AUDIT_TRAIL');
end;
/

begin
dbms_audit_mgmt.set_audit_trail_location(
   audit_trail_type=>dbms_audit_mgmt.audit_trail_unified,
   audit_trail_location_value=>'AUDIT_TRAIL');
end;
/

exec dbms_workload_repository.modify_baseline_window_size(window_size =>7); 
exec dbms_workload_repository.modify_snapshot_settings(retention=>7*1440);
exec dbms_stats.alter_stats_history_retention(7);
exec dbms_scheduler.set_scheduler_attribute('log_history',7);

begin
dbms_audit_mgmt.set_last_archive_timestamp(
   audit_trail_type=>dbms_audit_mgmt.audit_trail_unified,
   last_archive_time=>sysdate-7);
end;
/

create bigfile tablespace tbs_apex 
  datafile 'tbs_apex.dbf' 
  size 20m 
  autoextend on next 20m 
  maxsize 3g
;
SQL

echo "📦 Descompactando a versão local ($APEX_ZIP)..."
rm -rf ./apex || true
unzip -q "$APEX_ZIP"
rm -rf ./META-INF || true

echo "🛠 Aplicando a correção de compatibilidade de Views..."
python3 fix_apex_views.py

echo "⚙️  Instalando o APEX no banco de dados (Isso pode demorar vários minutos)..."
cd ./apex || exit 1
sql -name "$DB_CONN_NAME" @apexins.sql TBS_APEX TBS_APEX TEMP /i/
cd ..

echo "🖼️  Atualizando os arquivos estáticos (Imagens e CSS)..."
mkdir -p ./apex-images
rm -rf ./apex-images/* || true
cp -r ./apex/images/* ./apex-images/

echo "🔄 Reiniciando o ORDS para carregar os novos arquivos estáticos..."
docker restart local-26ai-ords || true

echo "⚙️  Configurando Workspace settings e ACLs de segurança..."
WS_SETTINGS=$(get_ws_settings "INTERNAL")

sql -name "$DB_CONN_NAME" <<SQL
  select user from dual;

  declare
    l_username varchar2(100) ;
  begin
    $WS_SETTINGS

    select creator
      into l_username
      from PUBLICSYN where SNAME = 'APEX_UTIL'
     fetch first 1 row only;

    execute IMMEDIATE ' update ' || l_username || q'!.wwv_flow_platform_prefs
        set VALUE = 604800
      where NAME = 'MAX_SESSION_IDLE_SEC'
    !';
    commit;

    execute IMMEDIATE ' update ' || l_username || q'!.wwv_flow_platform_prefs
        set VALUE = 604800
      where NAME = 'MAX_SESSION_LENGTH_SEC'
    !';
    commit;

    execute IMMEDIATE ' update ' || l_username || q'!.wwv_flow_platform_prefs
        set VALUE = 10000
      where NAME = 'ACCOUNT_LIFETIME_DAYS'
    !';
    commit;

    -- ACL to allow web service requests
    dbms_network_acl_admin.Append_host_ace(
      host => '*',
      ace => Xs\$ace_type(
        privilege_list => Xs\$name_list('connect')
      , principal_name => l_username
      , principal_type => xs_acl.ptype_db
      )
    );
    commit;
  end;
  / 
  commit;
SQL

echo "=========================================================="
echo "✅ Instalação do APEX do zero finalizada com sucesso!"
echo "👉 Acesse: http://localhost:8181/ords/apex"
echo "=========================================================="
