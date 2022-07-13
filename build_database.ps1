[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $rootpath,
    [string]
    $sqlInstance,
    [String]
    $databaseName
)

# $rootpath = "D:\workspace\richinf1\source_files"
# $sqlInstance = "localhost"
# $databaseName = "f1db"
# $testing = 0

Write-Host "Atempting to open a connection to " $sqlInstance " ..." -ForegroundColor Yellow
$svr = Connect-dbaInstance -SqlInstance $sqlInstance

Write-Host "Running in test mode, attempting to drop " $databaseName " from " $sqlInstance -ForegroundColor Yellow
Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false

Write-Host "Getting all of the .csv files from " $rootpath -ForegroundColor Yellow
$files = Get-ChildItem $rootpath -Filter *.csv

$total = $files | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "A total of " $total ".csv files were found" -ForegroundColor Yellow

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

#Check if the database exists
$dbExists = Get-DbaDatabase -SqlInstance $svr -Database $databaseName | Select-Object -Property Name

#If the database doesn't exist and it shouldn't, as we dropped it at the top, create it. 
if($null -eq $dbExists)
{
    Write-Host "Database " $databaseName " doesn't exist attempting to create" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "Database " $databaseName " created" -ForegroundColor Green

    Write-Host "Creating tables" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)

}

#Pause the script for 20 seconds to make sure that the build database/table scripts has completed. 
Start-Sleep -Seconds 20

#Get all of the files again, do this now, as we renamed them earlier
$files = Get-ChildItem $rootpath -Filter *.csv

#Now we can attempt to import all of the CSV files 
foreach($file in $files)
{
    $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
    Write-Host "Attempting to import data into " $fileWithoutExtension " from " $file -ForegroundColor Yellow
    $filePath = $rootpath + "\" + $file.Name    
    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -NoProgress -KeepIdentity
}

#Once complete, add the keys to the tables
if($null -eq $dbExists)
{
    Write-Host "Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
}