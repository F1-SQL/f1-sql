$rootpath = "D:\workspace\richinf1"
$sqlInstance = "localhost"
$databaseName = "f1db"

$total = Get-ChildItem $rootpath -Filter *.csv | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "Found " $total ".csv files"

#Rename the CSV Files to remove the underscores
try {

    Write-Host "Attempting to rename csv files to match table names" -ForegroundColor Yellow
    Get-ChildItem $rootpath -Filter *.csv | Rename-Item -NewName {$_.Name -replace '_'}

}
catch
{
    Write-Host "Renaming files failed" -ForegroundColor Red
}

$svr = Connect-dbaInstance -SqlInstance $sqlInstance

$dbExists = Get-DbaDatabase -SqlInstance $svr -Database $databaseName | Select-Object -Property Name

if($null -eq $dbExists)
{
    Write-Host "Database " $databaseName " doesn't exist attempting to create" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "Database " $databaseName " created" -ForegroundColor Green

    Write-Host "Creating tables" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)

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

$files = Get-ChildItem $rootpath -Filter *.csv

foreach($file in $files)
{
    Write-Host "Attempting to import data into " $file.Name " from " $file -ForegroundColor Yellow
    Import-Csv -Path $rootpath + '\' + $file -SqlInstance $svr -Database $databaseName -Table [System.IO.Path]::GetFileNameWithoutExtension($file) -Delimiter "," 
}

if($null -eq $dbExists)
{
    Write-Host "Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
}