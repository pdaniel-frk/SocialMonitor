<!--- <cflocation url="reports.cfm" addtoken="no"> --->
<cfset init("Schedules")>
<cfset getSchedules = oSchedules.getSchedules()>
<cfquery name="getScheduleServices" dbtype="query">
	select service, count(1) as cnt
	from getSchedules
	group by service
</cfquery>

<div class="page-header">
	<h1>Dashboard <small>This is just a dummy page until I figure out something to do with it</small></h1>
</div>

<div class="row">
	<div class="col-xs-12">
		<!--- <cfchart format="png" pieslicestyle="sliced" tipstyle="mousedown" style="red">
			<cfchartseries type="pie" datalabelstyle="none" query="getScheduleServices" itemcolumn="service" valuecolumn="cnt"/>
		</cfchart> --->
		<div style="width:200px;height:200px;" class="sparklines sparkline-pie"><cfoutput>#valueList(getScheduleServices.cnt)#</cfoutput></div>
	</div>
</div>

<div class="row placeholders">
	<div class="col-xs-6 col-sm-3 placeholder">
		<!--- <img data-src="holder.js/200x200/auto/sky" class="img-responsive" alt="Generic placeholder thumbnail"> --->
		<cfchart format="png" pieslicestyle="sliced" tipstyle="mousedown" style="blue">
			<cfchartseries type="pie" datalabelstyle="none">
				<cfchartdata item="Comments" value="#randRange(1,1000)#">
				<cfchartdata item="Likes" value="#randRange(1000,2000)#">
				<cfchartdata item="Shares" value="#randRange(1,100)#">
			</cfchartseries>
		</cfchart>
		<h4>Facebook</h4>
		<span class="text-muted">Something else</span>
	</div>
	<div class="col-xs-6 col-sm-3 placeholder">
		<!--- <img data-src="holder.js/200x200/auto/vine" class="img-responsive" alt="Generic placeholder thumbnail"> --->
		<cfchart format="png" pieslicestyle="sliced" tipstyle="mousedown" style="beige">
			<cfchartseries type="pie" datalabelstyle="none">
				<cfchartdata item="Comments" value="#randRange(1,1000)#">
				<cfchartdata item="Likes" value="#randRange(1000,2000)#">
				<cfchartdata item="Shares" value="#randRange(1,100)#">
			</cfchartseries>
		</cfchart>
		<h4>Instagram</h4>
		<span class="text-muted">Something else</span>
	</div>
	<div class="col-xs-6 col-sm-3 placeholder">
		<!--- <img data-src="holder.js/200x200/auto/sky" class="img-responsive" alt="Generic placeholder thumbnail"> --->
		<cfchart format="png" pieslicestyle="sliced" tipstyle="mousedown" style="silver">
			<cfchartseries type="pie" datalabelstyle="none">
				<cfchartdata item="Comments" value="#randRange(1,1000)#">
				<cfchartdata item="Likes" value="#randRange(1000,2000)#">
				<cfchartdata item="Shares" value="#randRange(1,100)#">
			</cfchartseries>
		</cfchart>
		<h4>Twitter</h4>
		<span class="text-muted">Something else</span>
	</div>
	<div class="col-xs-6 col-sm-3 placeholder">
		<!--- <img data-src="holder.js/200x200/auto/vine" class="img-responsive" alt="Generic placeholder thumbnail"> --->
		<cfchart format="png" pieslicestyle="sliced" tipstyle="mousedown" style="yellow">
			<cfchartseries type="pie" datalabelstyle="none">
				<cfchartdata item="Comments" value="#randRange(1,1000)#">
				<cfchartdata item="Likes" value="#randRange(1000,2000)#">
				<cfchartdata item="Shares" value="#randRange(1,100)#">
			</cfchartseries>
		</cfchart>
		<h4>Vine</h4>
		<span class="text-muted">Something else</span>
	</div>
</div>

<h2 class="sub-header">Section title</h2>
<div class="table-responsive">
	<table class="table table-striped">
		<thead>
			<tr>
				<th>#</th>
				<th>Header</th>
				<th>Header</th>
				<th>Header</th>
				<th>Header</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>1,001</td>
				<td>Lorem</td>
				<td>ipsum</td>
				<td>dolor</td>
				<td>sit</td>
			</tr>
			<tr>
				<td>1,002</td>
				<td>amet</td>
				<td>consectetur</td>
				<td>adipiscing</td>
				<td>elit</td>
			</tr>
			<tr>
				<td>1,003</td>
				<td>Integer</td>
				<td>nec</td>
				<td>odio</td>
				<td>Praesent</td>
			</tr>
			<tr>
				<td>1,003</td>
				<td>libero</td>
				<td>Sed</td>
				<td>cursus</td>
				<td>ante</td>
			</tr>
			<tr>
				<td>1,004</td>
				<td>dapibus</td>
				<td>diam</td>
				<td>Sed</td>
				<td>nisi</td>
			</tr>
			<tr>
				<td>1,005</td>
				<td>Nulla</td>
				<td>quis</td>
				<td>sem</td>
				<td>at</td>
			</tr>
			<tr>
				<td>1,006</td>
				<td>nibh</td>
				<td>elementum</td>
				<td>imperdiet</td>
				<td>Duis</td>
			</tr>
			<tr>
				<td>1,007</td>
				<td>sagittis</td>
				<td>ipsum</td>
				<td>Praesent</td>
				<td>mauris</td>
			</tr>
			<tr>
				<td>1,008</td>
				<td>Fusce</td>
				<td>nec</td>
				<td>tellus</td>
				<td>sed</td>
			</tr>
			<tr>
				<td>1,009</td>
				<td>augue</td>
				<td>semper</td>
				<td>porta</td>
				<td>Mauris</td>
			</tr>
			<tr>
				<td>1,010</td>
				<td>massa</td>
				<td>Vestibulum</td>
				<td>lacinia</td>
				<td>arcu</td>
			</tr>
			<tr>
				<td>1,011</td>
				<td>eget</td>
				<td>nulla</td>
				<td>Class</td>
				<td>aptent</td>
			</tr>
			<tr>
				<td>1,012</td>
				<td>taciti</td>
				<td>sociosqu</td>
				<td>ad</td>
				<td>litora</td>
			</tr>
			<tr>
				<td>1,013</td>
				<td>torquent</td>
				<td>per</td>
				<td>conubia</td>
				<td>nostra</td>
			</tr>
			<tr>
				<td>1,014</td>
				<td>per</td>
				<td>inceptos</td>
				<td>himenaeos</td>
				<td>Curabitur</td>
			</tr>
			<tr>
				<td>1,015</td>
				<td>sodales</td>
				<td>ligula</td>
				<td>in</td>
				<td>libero</td>
			</tr>
		</tbody>
	</table>
</div>
