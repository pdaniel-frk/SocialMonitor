<cfparam name="form.user_id" default="">
<cfparam name="form.email" default="">
<cfparam name="form.first_name" default="">
<cfparam name="form.last_name" default="">
<cfparam name="form.username" default="">
<cfparam name="form.timezone" default="">
<cfparam name="form.locale" default="">
<cfparam name="form.profile_url" default="">
<cfparam name="form.birthday_date" default="">
<cfparam name="form.userId" default="">

<cfif len(form.user_id) and len(form.userID)>
	
	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from FacebookUsers
			where user_id = <cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_varchar">
		)
		begin
			insert into FacebookUsers (
				user_id,
				email,
				first_name,
				last_name,
				username,
				timezone,
				locale,
				profile_url,
				birthday_date,
				addedBy
			)
			values (
				<cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.first_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.last_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.timezone#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.locale#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.profile_url#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.birthday_date#" null="#not len(form.birthday_date) or not isdate(form.birthday_date)#"cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#form.userId#" cfsqltype="cf_sql_varchar">
			)
		end
	</cfquery>
	
</cfif>