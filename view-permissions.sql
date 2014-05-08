/** Get all views by user **/

select distinct * from (

select 
		w.name as workbook_name
	,	v.name as view_name
	,	regexp_replace(v.repository_url, '/sheets'::text, ''::text) AS view_url
	,	su.name as user_name
	,	s.url_namespace as site_url
	,	s.name as site_name
--	,	su.admin_level

from 
	next_gen_permissions ngp
	join system_users su on ngp.grantee_id = su.id
	join views v on ngp.authorizable_id = v.id
	join capabilities c on ngp.capability_id = c.id
	join workbooks w on v.workbook_id = w.id
	join sites s on v.site_id = s.id
where 
	ngp.grantee_type = 'User'
and ngp.authorizable_type = 'View'
and c.name = 'read'
-- and su.name='bsullins'

union all

/** Get views by group access **/

select 
		w.name as workbook_name
	,	v.name as view_name
	,	regexp_replace(v.repository_url, '/sheets'::text, ''::text) AS view_url
	,	uig.name as user_name
	,	s.url_namespace as site_url
	,	s.name as site_name
--	,	uig.admin_level
	
from 
	next_gen_permissions ngp
	join (

SELECT 
-- 		users.id
		system_users.name
-- 	,	users.login_at
-- 	,	system_users.friendly_name
-- 	,	users.licensing_role_id
-- 	,	licensing_roles.name AS licensing_role_name
-- 	,	system_users.domain_id
-- 	,	users.system_user_id
-- 	,	domains.name AS domain_name
-- 	,	domains.short_name AS domain_short_name
-- 	,	users.site_id
-- 	,	groups.name AS group_name
	,	groups.id as group_id
-- 	,	system_users.admin_level
	FROM 
			system_users
	join	users			on	users.system_user_id = system_users.id
	join	licensing_roles		on	users.licensing_role_id = licensing_roles.id 
	join	domains			on	system_users.domain_id = domains.id 
	join	group_users		on	group_users.user_id = users.id
	join	groups			on	group_users.group_id = groups.id
	
	) uig on ngp.grantee_id = uig.group_id
	join views v on ngp.authorizable_id = v.id
	join capabilities c on ngp.capability_id = c.id
	join workbooks w on v.workbook_id = w.id
	join sites s on v.site_id = s.id
where 
	ngp.grantee_type = 'Group'
and ngp.authorizable_type = 'View'
and c.name = 'read'
-- and uig.name='bsullins'
) as tbl
