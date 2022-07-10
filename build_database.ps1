$rootpath = "D:\workspace\ergast-mssql"
$sqlInstance = "localhost"
$databaseName = "f1db"

$svr = Connect-dbaInstance -SqlInstance $sqlInstance

$dbExists = Get-DbaDatabase -SqlInstance $svr -Database $databaseName | Select-Object -Property Name

if($null -eq $dbExists)
{
    New-DbaDatabase -SqlInstance $sqlInstance -Name $databaseName
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)
}

$objects = @()
$objects += Get-DbaDbForeignKey -SqlInstance $svr -Database $databaseName
$objects += Get-DbaDbView -SqlInstance $svr -Database $databaseName -ExcludeSystemView

#https://jesspomfret.com/truncate-all-the-tables/

# Script out the create statements for objects
$createOptions = New-DbaScriptingOption
$createOptions.Permissions = $true
$createOptions.ScriptBatchTerminator = $true
$createOptions.AnsiFile = $true
 
$objects | Export-DbaScript -FilePath -Database $databaseName ('{0}\CreateObjects.Sql' -f $rootpath) -ScriptingOptionsObject $createOptions

# Script out the drop statements for objects
$options = New-DbaScriptingOption
$options.ScriptDrops = $true
$objects| Export-DbaScript -FilePath ('{0}\DropObjects.Sql' -f $rootpath) -ScriptingOptionsObject $options

# Run the drop scripts
Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\DropObjects.Sql' -f $rootpath)

# Truncate the tables
$svr.databases[$databaseName].Tables | ForEach-Object { $_.TruncateData() }
 
# Run the create scripts
Invoke-DbaQuery -SqlInstance $svr -Database $database -File ('{0}\CreateObjects.Sql' -f $rootpath)

# Clear up the script files
Remove-Item ('{0}\DropObjects.Sql' -f $rootpath), ('{0}\CreateObjects.Sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\1_f1db_drivers.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\2_f1db_constructors.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\3_f1db_status.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\4_f1db_circuits.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\5_f1db_seasons.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\9_f1db_races.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\6_f1db_constructorResults.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\7_f1db_constructorStandings.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\8_f1db_driverstandings.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\10_f1db_results.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\11_f1db_laptimes.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\12_f1db_pitStops.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\13_f1db_qualifying.sql' -f $rootpath)

Invoke-DbaQuery -SqlInstance $svr -File ('{0}\14_f1db_sprintresults.sql' -f $rootpath)