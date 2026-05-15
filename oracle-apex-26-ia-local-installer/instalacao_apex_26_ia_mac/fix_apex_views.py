import re
import sys

filename = 'apex/core/apex_views.sql'

with open(filename, 'r', encoding='latin-1') as f:
    content = f.read()

# Remove the WITH FUNCTION block
pattern_with_func = re.compile(
    r'with function get_sub_status \(\s*p_subscription_scn in number,\s*p_master_scn\s*in number \)\s*return varchar2\s*is\s*begin\s*return case\s*when p_subscription_scn =\s*p_master_scn then \'UP_TO_DATE\'\s*when p_subscription_scn != p_master_scn then \'NEEDS_REFRESH\'\s*else \'UNKNOWN\'\s*end;\s*end get_sub_status;\n',
    re.IGNORECASE | re.MULTILINE
)

new_content = pattern_with_func.sub('', content)

# Replace the function call with the CASE expression
pattern_func_call = re.compile(r'get_sub_status \(\s*s\.version_scn,\s*m\.version_scn\s*\)', re.IGNORECASE)
case_expr = "case when s.version_scn = m.version_scn then 'UP_TO_DATE' when s.version_scn != m.version_scn then 'NEEDS_REFRESH' else 'UNKNOWN' end"

new_content = pattern_func_call.sub(case_expr, new_content)

if new_content == content:
    print("Patch not needed or already applied. Skipping...")
    sys.exit(0)

with open(filename, 'w', encoding='latin-1') as f:
    f.write(new_content)

print("Successfully patched apex_views.sql")
