[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $rootpath,
    [string]
    $sqlInstance,
    [String]
    $databaseName,
    [int32]
    $testing
)

# $rootpath = "D:\workspace\richinf1"
# $sqlInstance = "localhost"
# $databaseName = "f1db"
# $testing = 0

$svr = Connect-dbaInstance -SqlInstance $sqlInstance

if($testing -eq 1)
{
    Write-Host "Running in test mode, attempting to drop " $databaseName " from " $sqlInstance -ForegroundColor Yellow
    Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false
}

$files = Get-ChildItem $rootpath -Filter *.csv
$total = $files | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "We found a total of " $total ".csv files" -ForegroundColor Yellow

#Rename the CSV Files to remove the underscores
foreach($file in $files)
{
    try {

        Write-Host "Attempting to rename " $file.Name " to match table name" -ForegroundColor Yellow
        Rename-Item $file.Name -NewName $file.Name.Replace("_","")
        Write-Host "Renamed " $file.Name " sucessfully to match table name" -ForegroundColor Green

    }
    catch {
        Write-Host "Renaming " $file.Name " failed" -ForegroundColor Red
    }    
}

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

Start-Sleep -Seconds 20

$files = Get-ChildItem $rootpath -Filter *.csv

foreach($file in $files)
{
    $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
    Write-Host "Attempting to import data into " $fileWithoutExtension " from " $file -ForegroundColor Yellow
    $filePath = $rootpath + "\" + $file.Name    
    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -NoProgress -KeepIdentity
}

if($null -eq $dbExists)
{
    Write-Host "Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
}