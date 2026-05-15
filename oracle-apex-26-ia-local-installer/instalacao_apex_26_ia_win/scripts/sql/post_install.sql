declare
  l_username varchar2(100) ;
begin
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
    ace => Xs$ace_type(
      privilege_list => Xs$name_list('connect')
    , principal_name => l_username
    , principal_type => xs_acl.ptype_db
    )
  );

  commit;
end;
/ 
commit;
exit;
