$rootpath = "D:\workspace\richinf1"
$sqlInstance = "localhost"
$databaseName = "f1db"

#Rename the CSV Files to remove the underscores
Get-ChildItem $rootpath -Filter *.csv | Rename-Item -NewName {$_.Name -replace '_'}

$svr = Connect-dbaInstance -SqlInstance $sqlInstance

$dbExists = Get-DbaDatabase -SqlInstance $svr -Database $databaseName | Select-Object -Property Name

if($null -eq $dbExists)
{
    Write-Host "Database " $databaseName " doesn't exist attempting to create" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "Database " $databaseName " created" -ForegroundColor Green

    Write-Host "Creating tables" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)

    Start-Sleep -Seconds 10

    Write-Host "Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
}

if($dbExists.Name.Length -gt 0)
{
    Write-Host $databaseName " already exists, dropping keys and truncating tables" -ForegroundColor Yellow
    $objects = @()
    $objects += Get-DbaDbForeignKey -SqlInstance $svr -Database $databaseName
    $objects += Get-DbaDbView -SqlInstance $svr -Database $databaseName -ExcludeSystemView

    #https://jesspomfret.com/truncate-all-the-tables/

    # Script out the create statements for objects
    $createOptions = New-DbaScriptingOption
    $createOptions.Permissions = $true
    $createOptions.ScriptBatchTerminator = $true
    $createOptions.AnsiFile = $true 
    $objects | Export-DbaScript -FilePath ('{0}\CreateObjects.Sql' -f $rootpath) -ScriptingOptionsObject $createOptions

    # Script out the drop statements for objects
    $options = New-DbaScriptingOption
    $options.ScriptDrops = $true
    $objects | Export-DbaScript -FilePath ('{0}\DropObjects.Sql' -f $rootpath) -ScriptingOptionsObject $options

    # Run the drop scripts
    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\DropObjects.Sql' -f $rootpath)

    # Truncate the tables
    $svr.databases[$databaseName].Tables | ForEach-Object { $_.TruncateData() }
    
    # Run the create scripts
    Invoke-DbaQuery -SqlInstance $svr -Database $database -File ('{0}\CreateObjects.Sql' -f $rootpath)

    # Clear up the script files
    Remove-Item ('{0}\DropObjects.Sql' -f $rootpath), ('{0}\CreateObjects.Sql' -f $rootpath)

}

Write-Host "Attempting to populate drivers table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\1_f1db_drivers.sql' -f $rootpath)
Write-Host "Drivers table populated" -ForegroundColor Green

Write-Host "Attempting to populate constructors table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\2_f1db_constructors.sql' -f $rootpath)
Write-Host "constructors table populated" -ForegroundColor Green

Write-Host "Attempting to populate status table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\3_f1db_status.sql' -f $rootpath)
Write-Host "status table populated" -ForegroundColor Green

Write-Host "Attempting to populate circuits table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\4_f1db_circuits.sql' -f $rootpath)
Write-Host "circuits table populated" -ForegroundColor Green

Write-Host "Attempting to populate seasons table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\5_f1db_seasons.sql' -f $rootpath)
Write-Host "seasons table populated" -ForegroundColor Green

Write-Host "Attempting to populate races table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\9_f1db_races.sql' -f $rootpath)
Write-Host "races table populated" -ForegroundColor Green

Write-Host "Attempting to populate constructorResults table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\6_f1db_constructorResults.sql' -f $rootpath)
Write-Host "constructorResults table populated" -ForegroundColor Green

Write-Host "Attempting to populate constructorStandings table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\7_f1db_constructorStandings.sql' -f $rootpath)
Write-Host "constructorStandings table populated" -ForegroundColor Green

Write-Host "Attempting to populate driverstandings table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\8_f1db_driverstandings.sql' -f $rootpath)
Write-Host "driverstandings table populated" -ForegroundColor Green

Write-Host "Attempting to populate results table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\10_f1db_results.sql' -f $rootpath)
Write-Host "results table populated" -ForegroundColor Green

Write-Host "laptimes table populated" -ForegroundColor Green

Write-Host "Attempting to populate pitStops table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\12_f1db_pitStops.sql' -f $rootpath)
Write-Host "pitStops table populated" -ForegroundColor Green

Write-Host "Attempting to populate qualifying table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\13_f1db_qualifying.sql' -f $rootpath)
Write-Host "qualifying table populated" -ForegroundColor Green

Write-Host "Attempting to populate sprintresults table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\14_f1db_sprintresults.sql' -f $rootpath)
Write-Host "sprintresults table populated" -ForegroundColor Green

Start-Sleep -Seconds 30

Write-Host "Attempting to populate laptimes table" -ForegroundColor Yellow
Invoke-DbaQuery -SqlInstance $svr -File ('{0}\11_f1db_laptimes.sql' -f $rootpath) -EnableException
