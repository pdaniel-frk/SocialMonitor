<cfcomponent displayname="Customers Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="insertCustomer" output="no" returntype="numeric">

		<cfargument name="name" required="yes">
		<cfargument name="industry" required="no" default="">
		<cfargument name="address1" required="no" default="">
		<cfargument name="address2" required="no" default="">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="no" default="">
		<cfargument name="province" required="no" default="">
		<cfargument name="country" required="no" default="US">
		<cfargument name="postalCode" required="no" default="">
		<cfargument name="phoneNumber" required="no" default="">

		<cfquery name="insertCustomer" datasource="#variables.dsn#">
			if not exists (
				select 1
				from Customers
				where name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			)
			begin
				insert into Customers (
					name,
					industry,
					address1,
					address2,
					city,
					state,
					province,
					country,
					postalCode,
					phoneNumber
				)
				values (
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.industry#" null="#not len(arguments.industry)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.address1#" null="#not len(arguments.address1)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.address2#" null="#not len(arguments.address2)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.city#" null="#not len(arguments.city)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.state#" null="#not len(arguments.state)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.province#" null="#not len(arguments.province)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.country#" null="#not len(arguments.country)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postalCode#" null="#not len(arguments.postalCode)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.phoneNumber#" null="#not len(arguments.phoneNumber)#" cfsqltype="cf_sql_varchar">
				)
			end

			select customerId = scope_identity()
		</cfquery>

		<!--- catch in case scope_identity doesnt work --->
		<cftry>

			<cfreturn insertCustomer.customerId>

			<cfcatch type="any">

				<cfquery name="customerSelect" datasource="#variables.dsn#">
					select max(customerId) as customerId
					from Customers
					where isdate(deleteDate) = 0
				</cfquery>

				<cfreturn customerSelect.customerId>

			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getCustomer" output="no">

		<cfargument name="customerId" required="no" default="">
		<cfargument name="name" required="yes">
		<cfargument name="industry" required="no" default="">
		<cfargument name="address1" required="no" default="">
		<cfargument name="address2" required="no" default="">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="no" default="">
		<cfargument name="province" required="no" default="">
		<cfargument name="country" required="no" default="US">
		<cfargument name="postalCode" required="no" default="">
		<cfargument name="phoneNumber" required="no" default="">

		<cfquery name="customerSelect" datasource="#variables.dsn#">
			select
				customerId,
				name,
				industry,
				address1,
				address2,
				city,
				state,
				province,
				country,
				postalCode,
				phoneNumber
			from Customers
			where isdate(deleteDate) = 0
			<cfif len(arguments.customerId)>
				and customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.name)>
				and name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.industry)>
				and industry = <cfqueryparam value="#arguments.industry#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.address1)>
				and address1 = <cfqueryparam value="#arguments.address1#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.address2)>
				and address2 = <cfqueryparam value="#arguments.address2#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.city)>
				and city = <cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.state)>
				and state = <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.province)>
				and province = <cfqueryparam value="#arguments.province#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.country)>
				and country = <cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.postalCode)>
				and postalCode = <cfqueryparam value="#arguments.postalCode#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.phoneNumber)>
				and phoneNumber = <cfqueryparam value="#arguments.phoneNumber#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn customerSelect>

	</cffunction>


	<cffunction name="updateCustomer" output="no">

		<cfargument name="customerId" required="yes">
		<cfargument name="name" required="yes">
		<cfargument name="industry" required="no" default="">
		<cfargument name="address1" required="no" default="">
		<cfargument name="address2" required="no" default="">
		<cfargument name="city" required="no" default="">
		<cfargument name="state" required="no" default="">
		<cfargument name="province" required="no" default="">
		<cfargument name="country" required="no" default="US">
		<cfargument name="postalCode" required="no" default="">
		<cfargument name="phoneNumber" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			update Customers
			set modifyDate = getdate()
			<cfif len(arguments.name)>
				, name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.industry)>
				, industry = <cfqueryparam value="#arguments.industry#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.address1)>
				, address1 = <cfqueryparam value="#arguments.address1#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.address2)>
				, address2 = <cfqueryparam value="#arguments.address2#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.city)>
				, city = <cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.state)>
				, state = <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.province)>
				, province = <cfqueryparam value="#arguments.province#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.country)>
				, country = <cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.postalCode)>
				, postalCode = <cfqueryparam value="#arguments.postalCode#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.phoneNumber)>
				, phoneNumber = <cfqueryparam value="#arguments.phoneNumber#" cfsqltype="cf_sql_varchar">
			</cfif>
			where customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
		</cfquery>

	</cffunction>


	<cffunction name="deleteCustomer" output="no">

		<cfargument name="customerId" required="no" default="">

		<cfquery datasource="#this.dsn#">
			update Customers
			set deleteDate = getdate()
			where customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn>

	</cffunction>

</cfcomponent>