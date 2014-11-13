<cfinvoke component="application" method="onsessionend">
<cfinvoke component="application" method="onsessionstart">
<cfset reRoute(destination="login.cfm", message="You have been signed out.")>