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

exit;
