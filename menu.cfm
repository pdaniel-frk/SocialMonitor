<div class="navbar navbar-inverse navbar-fixed-top" role="navigation" style="min-width:960px;">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#"><cfoutput>#this.title#</cfoutput></a>
		</div>
		<div class="navbar-collapse collapse">
			<ul class="nav navbar-nav navbar-right">
				<cfif session.loggedIn>
					<li class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown">Reports <b class="caret"></b></a>
						<ul class="dropdown-menu">
							<li class="disabled"><a href="">Entries</a></li>
							<li class="disabled"><a href="">Traffic</a></li>
						</ul>
					</li>
					<li><a href="<cfoutput>#request.webRoot#</cfoutput>logout.cfm" data-target="#"><span class="add-on"><i class="glyphicon glyphicon-log-out"></i></span> Sign Out</a></li>
				<cfelse>
					<li><a href="<cfoutput>#request.webRoot#</cfoutput>login.cfm" data-target="#"><span class="add-on"><i class="glyphicon glyphicon-log-in"></i></span> Sign In</a></li>
				</cfif>
			</ul>
			<cfif session.loggedIn>
				<form class="navbar-form navbar-right" method="post">
					<input type="text" class="form-control" placeholder="Search&hellip;" name="searchTerm" id="searchTerm">
					<input type="hidden" name="searchKey" value="<cfoutput>#hash(getTickCount(), 'SHA-1')#</cfoutput>">
				</form>
			</cfif>
		</div>
	</div>
</div>